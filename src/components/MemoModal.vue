<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-2xl p-6 w-full max-w-lg">
      <h3 class="text-lg font-bold mb-4">実績の記録</h3>
      <p class="mb-2 text-sm text-gray-600">実施しなかった理由や、代わりに行ったことを記録できます。</p>
      <textarea v-model="localMemo" rows="4" class="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" placeholder="例：急な打ち合わせが入ったため"></textarea>
      <div class="mt-6 flex justify-end gap-3">
        <button @click="$emit('close')" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded-lg transition-colors">キャンセル</button>
        <button @click="save" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded-lg transition-colors">保存</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, watch, computed } from 'vue';
const props = defineProps({
  memo: String,
  show: { type: Boolean, default: true }
});
const emit = defineEmits(['close', 'save', 'updateMemo']);
const localMemo = ref(props.memo || '');
watch(() => props.memo, (val) => { localMemo.value = val; });
function save() {
  emit('updateMemo', localMemo.value);
  emit('save');
}
</script>
