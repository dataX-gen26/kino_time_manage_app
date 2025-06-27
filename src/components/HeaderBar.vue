<template>
  <header class="bg-white shadow-md">
    <div class="container mx-auto px-4 py-3 flex justify-between items-center">
      <div class="flex items-center gap-3">
        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-indigo-600"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="m9 16 2 2 4-4"/></svg>
        <h1 class="text-xl md:text-2xl font-bold text-gray-800">予実管理アプリ</h1>
      </div>
      <div v-if="isLoggedIn">
        <button @click="$emit('signout')" class="bg-indigo-500 hover:bg-indigo-600 text-white font-bold py-2 px-4 rounded-lg transition-colors duration-200 flex items-center gap-2">
          <lucide-vue-next.LogOut :size="18" />
          <span>ログアウト</span>
        </button>
      </div>
    </div>
  </header>
</template>

<script setup>
const props = defineProps({
  isLoggedIn: Boolean
});
</script>
