<template>
  <div id="app" v-cloak class="min-h-screen flex flex-col">
    <HeaderBar :isLoggedIn="isLoggedIn" @signout="handleSignoutClick" />
    <main class="flex-grow container mx-auto p-4 md:p-6">
      <LoginView v-if="!isLoggedIn" @login="handleAuthClick" :error="error" />
      <template v-else>
        <DateControls
          :formattedDate="formattedDate"
          :isLoading="isLoading"
          @changeDay="changeDay"
          @refresh="fetchEvents"
          @openUnplannedTaskModal="openUnplannedTaskModal"
        />
        <div v-if="isLoading" class="flex justify-center items-center py-16">
          <div class="loader"></div>
        </div>
        <div v-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg relative" role="alert">
          <strong class="font-bold">エラー: </strong>
          <span class="block sm:inline">{{ error }}</span>
        </div>
        <EventList
          v-if="!isLoading && !error"
          :events="eventsWithActuals"
          :formatTime="formatTime"
          @saveActual="saveActual"
          @openMemoModal="openMemoModal"
        />
      </template>
    </main>
    <FooterBar />
    <MemoModal
      v-if="isMemoModalOpen"
      :memo="currentMemo"
      @close="closeMemoModal"
      @save="saveMemo"
      @updateMemo="val => currentMemo = val"
    />
    <UnplannedTaskModal
      v-if="isUnplannedTaskModalOpen"
      :unplannedTask="unplannedTask"
      @close="() => isUnplannedTaskModalOpen = false"
      @add="addUnplannedTask"
      @updateTask="val => { unplannedTask.summary = val.summary; unplannedTask.time = val.time; }"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, reactive } from 'vue';
import HeaderBar from './components/HeaderBar.vue';
import LoginView from './components/LoginView.vue';
import DateControls from './components/DateControls.vue';
import EventList from './components/EventList.vue';
import MemoModal from './components/MemoModal.vue';
import UnplannedTaskModal from './components/UnplannedTaskModal.vue';
import FooterBar from './components/FooterBar.vue';

// Google APIキー・クライアントID
const API_KEY = 'YOUR_API_KEY'; // ここにAPIキーを入力
const CLIENT_ID = 'YOUR_CLIENT_ID'; // ここにクライアントIDを入力
const SCOPES = 'https://www.googleapis.com/auth/calendar.readonly';

// --- 状態管理 ---
const isLoggedIn = ref(false);
const events = ref([]);
const actuals = ref({});
const currentDate = ref(new Date());
const isLoading = ref(false);
const error = ref(null);

const isMemoModalOpen = ref(false);
const currentEventId = ref(null);
const currentMemo = ref('');
const currentEventIsUnplanned = ref(false);

const isUnplannedTaskModalOpen = ref(false);
const unplannedTask = reactive({ summary: '', time: '12:00' });

let tokenClient;

onMounted(() => {
  if (window.gapi && window.google) {
    gapi.load('client', initializeGapiClient);
    tokenClient = google.accounts.oauth2.initTokenClient({
      client_id: CLIENT_ID,
      scope: SCOPES,
      callback: (tokenResponse) => {
        if (tokenResponse && tokenResponse.access_token) {
          gapi.client.setToken(tokenResponse);
          isLoggedIn.value = true;
          fetchEvents();
        } else {
          error.value = 'Google認証に失敗しました。';
        }
      },
    });
    loadActuals();
  }
});

async function initializeGapiClient() {
  await gapi.client.init({
    apiKey: API_KEY,
    discoveryDocs: ['https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest'],
  });
}

function handleAuthClick() {
  if (API_KEY === 'YOUR_API_KEY' || CLIENT_ID === 'YOUR_CLIENT_ID') {
    error.value = 'APIキーまたはクライアントIDが設定されていません。コード内の指示に従って設定してください。';
    alert(error.value);
    return;
  }
  error.value = null;
  tokenClient.requestAccessToken({ prompt: 'consent' });
}

function handleSignoutClick() {
  const token = gapi.client.getToken();
  if (token !== null) {
    google.accounts.oauth2.revoke(token.access_token, () => {
      gapi.client.setToken('');
      isLoggedIn.value = false;
      events.value = [];
    });
  }
}

async function fetchEvents() {
  if (!isLoggedIn.value) return;
  isLoading.value = true;
  error.value = null;
  events.value = [];
  try {
    const timeMin = new Date(currentDate.value);
    timeMin.setHours(0, 0, 0, 0);
    const timeMax = new Date(currentDate.value);
    timeMax.setHours(23, 59, 59, 999);
    const request = {
      calendarId: 'primary',
      timeMin: timeMin.toISOString(),
      timeMax: timeMax.toISOString(),
      showDeleted: false,
      singleEvents: true,
      orderBy: 'startTime',
    };
    const response = await gapi.client.calendar.events.list(request);
    const calendarEvents = response.result.items.map(event => ({
      id: event.id,
      summary: event.summary,
      start: event.start.dateTime || event.start.date,
      end: event.end.dateTime || event.end.date,
      isAllDay: !!event.start.date,
      isUnplanned: false,
    }));
    events.value = calendarEvents;
  } catch (err) {
    console.error('Execute error', err);
    error.value = 'カレンダーの予定の取得に失敗しました。時間をおいて再度お試しください。';
    if (err.result && err.result.error && err.result.error.message) {
      error.value += ` (${err.result.error.message})`;
    }
  } finally {
    isLoading.value = false;
  }
}

function loadActuals() {
  const savedActuals = localStorage.getItem('yojitsuAppActuals');
  if (savedActuals) {
    actuals.value = JSON.parse(savedActuals);
  }
}

function saveActualToStorage() {
  localStorage.setItem('yojitsuAppActuals', JSON.stringify(actuals.value));
}

function saveActual(eventId, status, isUnplanned = false) {
  if (!actuals.value[eventId]) {
    actuals.value[eventId] = { status: '', memo: '' };
  }
  actuals.value[eventId].status = status;
  if (status === 'completed') {
    actuals.value[eventId].memo = '';
  }
  actuals.value[eventId].date = formattedDateKey.value;
  actuals.value[eventId].isUnplanned = isUnplanned;
  saveActualToStorage();
}

function openMemoModal(eventId, memo, isUnplanned) {
  currentEventId.value = eventId;
  currentMemo.value = memo;
  currentEventIsUnplanned.value = isUnplanned;
  isMemoModalOpen.value = true;
}

function closeMemoModal() {
  isMemoModalOpen.value = false;
}

function saveMemo() {
  saveActual(currentEventId.value, 'not_done', currentEventIsUnplanned.value);
  actuals.value[currentEventId.value].memo = currentMemo.value;
  saveActualToStorage();
  closeMemoModal();
}

function openUnplannedTaskModal() {
  unplannedTask.summary = '';
  unplannedTask.time = new Date().toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
  isUnplannedTaskModalOpen.value = true;
}

function addUnplannedTask() {
  if (!unplannedTask.summary.trim()) {
    alert('タスク内容を入力してください。');
    return;
  }
  const newId = `unplanned-${Date.now()}`;
  const [hours, minutes] = unplannedTask.time.split(':');
  const taskDate = new Date(currentDate.value);
  taskDate.setHours(parseInt(hours), parseInt(minutes));
  const newEvent = {
    id: newId,
    summary: unplannedTask.summary,
    start: taskDate.toISOString(),
    end: taskDate.toISOString(),
    isAllDay: false,
    isUnplanned: true,
  };
  actuals.value[newId] = {
    status: 'unspecified',
    memo: '',
    date: formattedDateKey.value,
    isUnplanned: true,
    summary: newEvent.summary,
    start: newEvent.start,
    end: newEvent.end,
  };
  saveActualToStorage();
  isUnplannedTaskModalOpen.value = false;
}

const formattedDate = computed(() => {
  return currentDate.value.toLocaleDateString('ja-JP', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });
});
const formattedDateKey = computed(() => {
  return currentDate.value.toISOString().split('T')[0];
});
const eventsWithActuals = computed(() => {
  const googleEvents = events.value.map(event => ({
    ...event,
    actual: actuals.value[event.id],
  }));
  const unplannedEvents = Object.keys(actuals.value)
    .filter(key => key.startsWith('unplanned-') && actuals.value[key].date === formattedDateKey.value)
    .map(key => {
      const actual = actuals.value[key];
      return {
        id: key,
        summary: actual.summary,
        start: actual.start,
        end: actual.end,
        isAllDay: false,
        isUnplanned: true,
        actual: actual,
      };
    });
  const allEvents = [...googleEvents, ...unplannedEvents];
  return allEvents.sort((a, b) => {
    if (a.isAllDay) return -1;
    if (b.isAllDay) return 1;
    return new Date(a.start) - new Date(b.start);
  });
});

function changeDay(delta) {
  if (delta === 0) {
    currentDate.value = new Date();
  } else {
    const newDate = new Date(currentDate.value);
    newDate.setDate(newDate.getDate() + delta);
    currentDate.value = newDate;
  }
  fetchEvents();
}

function formatTime(dateTimeStr) {
  if (!dateTimeStr) return '';
  return new Date(dateTimeStr).toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.loader {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-left-color: #4f46e5;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
[v-cloak] { display: none; }
</style>