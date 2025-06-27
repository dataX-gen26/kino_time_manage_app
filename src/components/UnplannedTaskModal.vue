<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl p-6 w-full max-w-lg">
      <h3 class="text-lg font-bold mb-4">予定外タスクの追加</h3>
      <div class="space-y-4">
        <div>
          <label for="taskTitle" class="block text-sm font-medium text-gray-700">タスク内容</label>
          <input type="text" id="taskTitle" v-model="localTask.summary" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm" placeholder="例：資料作成">
        </div>
        <div>
          <label for="taskTime" class="block text-sm font-medium text-gray-700">実施時間</label>
          <input type="time" id="taskTime" v-model="localTask.time" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
        </div>
      </div>
      <div class="mt-6 flex justify-end gap-3">
        <button @click="$emit('close')" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded-lg transition-colors">キャンセル</button>
        <button @click="addTask" class="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded-lg transition-colors">追加</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, watch } from 'vue';
const props = defineProps({
  unplannedTask: Object,
  show: { type: Boolean, default: true }
});
const emit = defineEmits(['close', 'add', 'updateTask']);
const localTask = ref({ ...props.unplannedTask });
watch(() => props.unplannedTask, (val) => { localTask.value = { ...val }; });
function addTask() {
  emit('updateTask', localTask.value);
  emit('add');
}
</script>
