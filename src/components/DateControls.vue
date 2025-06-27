<template>
  <div class="bg-white p-4 rounded-xl shadow-md mb-6 flex flex-col md:flex-row justify-between items-center gap-4">
    <div class="flex items-center gap-4">
      <button @click="$emit('changeDay', -1)" class="p-2 rounded-full hover:bg-gray-200 transition-colors"><lucide-vue-next.ChevronLeft :size="24" /></button>
      <h2 class="text-xl md:text-2xl font-bold w-48 text-center">{{ formattedDate }}</h2>
      <button @click="$emit('changeDay', 1)" class="p-2 rounded-full hover:bg-gray-200 transition-colors"><lucide-vue-next.ChevronRight :size="24" /></button>
      <button @click="$emit('changeDay', 0)" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded-lg transition-colors text-sm">今日</button>
    </div>
    <div class="flex items-center gap-4">
      <button @click="$emit('refresh')" :disabled="isLoading" class="bg-white border border-indigo-500 text-indigo-500 hover:bg-indigo-50 font-bold py-2 px-4 rounded-lg transition-colors flex items-center gap-2 text-sm">
        <lucide-vue-next.RefreshCw :size="16" :class="{'animate-spin': isLoading}" />
        <span>更新</span>
      </button>
      <button @click="$emit('openUnplannedTaskModal')" class="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded-lg transition-colors flex items-center gap-2 text-sm">
        <lucide-vue-next.Plus :size="16" />
        <span>予定外タスクを追加</span>
      </button>
    </div>
  </div>
</template>
<script setup>
const props = defineProps({
  formattedDate: String,
  isLoading: Boolean
});
</script>
