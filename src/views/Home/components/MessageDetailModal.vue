<!-- components/MessageDetailModal.vue -->
<template>
  <div v-if="visible" class="modal-overlay" @click.self="close">
    <div class="modal-content" v-if="message">
      <button class="close-button" @click="close">&times;</button>

      <!-- 【新增】带有图标的头部，明确“系统通知” -->
      <div class="modal-header">
        <i class="fas fa-bullhorn notification-icon"></i>
        <h3 class="modal-title">系统通知</h3>
      </div>

      <h4 class="message-title">{{ message.title }}</h4>
      <p class="modal-time">发送于: {{ formatTime(message.sendTime) }}</p>

      <div class="modal-body" v-html="message.content"></div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  visible: {
    type: Boolean,
    required: true,
  },
  message: {
    type: Object,
    default: () => null,
  },
});

const emit = defineEmits(['close']);

const close = () => {
  emit('close');
};

const formatTime = (dateString) => {
  if (!dateString) return 'N/A';
  // 使用更友好的时间格式
  return new Date(dateString).toLocaleString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};
</script>

<style scoped>
/* 【优化】整体样式调整 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
  backdrop-filter: blur(5px);
}
.modal-content {
  background: white;
  padding: 25px 30px;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  position: relative;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
  border-top: 5px solid #4a90e2; /* 增加顶部高亮条 */
}
.close-button {
  position: absolute;
  top: 15px;
  right: 15px;
  background: none;
  border: none;
  font-size: 28px;
  cursor: pointer;
  color: #aaa;
  transition: color 0.2s;
}
.close-button:hover {
  color: #333;
}

/* 【新增】头部样式 */
.modal-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 15px;
}
.notification-icon {
  font-size: 1.8rem;
  color: #4a90e2;
}
.modal-title {
  margin: 0;
  font-size: 1.5rem;
  color: #333;
  font-weight: 600;
}
.message-title {
  font-size: 1.2rem;
  color: #444;
  margin-top: 0;
  margin-bottom: 8px;
  font-weight: 500;
}
.modal-time {
  font-size: 0.8rem;
  color: #999;
  margin-bottom: 20px;
  border-bottom: 1px solid #eee;
  padding-bottom: 15px;
}
.modal-body {
  margin-top: 15px;
  line-height: 1.7;
  color: #555;
  max-height: 60vh;
  overflow-y: auto;
  padding-right: 10px; /* 防止滚动条遮挡内容 */
}
/* 美化滚动条 */
.modal-body::-webkit-scrollbar {
  width: 6px;
}
.modal-body::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}
.modal-body::-webkit-scrollbar-thumb:hover {
  background: #aaa;
}
</style>
