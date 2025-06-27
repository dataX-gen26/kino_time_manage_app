<template>
  <div>
    <div v-if="events.length > 0" class="space-y-4">
      <div v-for="event in events" :key="event.id" class="bg-white rounded-xl shadow-md p-4 flex flex-col md:flex-row items-start md:items-center gap-4 transition-all duration-300">
        <div class="flex-shrink-0 w-full md:w-32 text-center md:text-left border-b md:border-b-0 md:border-r pb-2 md:pb-0 md:pr-4 border-gray-200">
          <p class="font-bold text-indigo-600">{{ event.isAllDay ? '終日' : formatTime(event.start) + ' - ' + formatTime(event.end) }}</p>
        </div>
        <div class="flex-grow">
          <p class="font-semibold text-gray-800">{{ event.summary }}</p>
          <p v-if="event.actual && event.actual.memo" class="text-sm text-gray-600 mt-1 pl-2 border-l-2 border-indigo-200">
            <lucide-vue-next.MessageSquare :size="14" class="inline-block mr-1" /> {{ event.actual.memo }}
          </p>
        </div>
        <div v-if="event.isUnplanned" class="flex-shrink-0">
          <span class="text-xs font-semibold inline-block py-1 px-2 uppercase rounded-full text-green-600 bg-green-200">
            予定外
          </span>
        </div>
        <div class="flex-shrink-0 flex items-center gap-3 self-end md:self-center">
          <button @click="$emit('saveActual', event.id, 'completed', event.isUnplanned)" :class="['p-2 rounded-full transition-colors', event.actual && event.actual.status === 'completed' ? 'bg-green-500 text-white' : 'bg-gray-200 hover:bg-green-200']">
            <lucide-vue-next.Check :size="20" />
          </button>
          <button @click="$emit('openMemoModal', event.id, event.actual ? event.actual.memo : '', event.isUnplanned)" :class="['p-2 rounded-full transition-colors', event.actual && event.actual.status === 'not_done' ? 'bg-red-500 text-white' : 'bg-gray-200 hover:bg-red-200']">
            <lucide-vue-next.X :size="20" />
          </button>
        </div>
      </div>
    </div>
    <div v-else class="text-center py-16 bg-white rounded-xl shadow-md">
      <lucide-vue-next.CalendarCheck2 :size="48" class="mx-auto text-gray-400" />
      <p class="mt-4 text-lg text-gray-600">この日の予定はありません。</p>
      <p class="text-sm text-gray-500">カレンダーに予定を追加するか、「予定外タスクを追加」してください。</p>
    </div>
  </div>
</template>
<script setup>
const props = defineProps({
  events: Array,
  formatTime: Function
});
</script>
