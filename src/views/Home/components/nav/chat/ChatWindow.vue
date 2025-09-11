<template>
  <div class="window glass-panel">
    <header class="window-header">
      <div class="peer">
        <div class="avatar-container">
          <img
              v-if="peerAvatar"
              :src="peerAvatar"
              :alt="peerName"
              class="avatar-img"
              @error="handleAvatarError"
          />
          <div v-else class="avatar" :data-initial="peerInitial"></div>
          <!-- 【新增】在线状态指示器 -->
          <span v-if="isPeerOnline" class="online-indicator"></span>
        </div>
        <div class="info">
          <h4>{{ peerName }}</h4>
          <!-- 【修改】根据 isPeerOnline 动态显示文本和 class -->
          <span class="sub" :class="{ 'is-online': isPeerOnline }">
            {{ isPeerOnline ? "在线" : "离线" }}
          </span>
        </div>
      </div>
      <div class="actions">
        <button class="ghost"><i class="fas fa-ellipsis"></i></button>
      </div>
    </header>

    <section ref="scrollBox" class="message-box">
      <template v-for="(m, index) in messages" :key="m.messageId || m.createdAt">
        <div
            v-if="shouldShowTimestamp(m, messages[index - 1])"
            class="timestamp"
        >
          <span>{{ formatTimestamp(m.createdAt) }}</span>
        </div>
        <MessageItem
            :message="m"
            :is-self="m.senderId === currentUserId"
            :current-user-avatar="currentUserAvatar"
            @delete-message="handleDeleteMessage"
        />
      </template>
      <div v-if="loading" class="loading-line">
        <i class="fas fa-circle-notch fa-spin"></i>
      </div>
    </section>

    <footer class="composer">
      <div class="tools">
        <button class="ghost" @click="triggerImage">
          <i class="fas fa-image"></i>
        </button>
        <input
            ref="fileInput"
            type="file"
            accept="image/*"
            hidden
            @change="handleImage"
        />
      </div>
      <div class="input-wrapper">
        <input
            v-model="draft"
            class="input"
            placeholder="输入消息..."
            @keydown.enter.exact.prevent="doSend"
        />
      </div>
      <button class="send" :disabled="!canSend" @click="doSend">
        <i class="fas fa-paper-plane"></i>
      </button>
    </footer>
  </div>
</template>

<script setup>
import { computed, onUpdated, ref, watch } from "vue";
import { useUserStore } from "@/stores/userStore";
// 【新增】引入 useChatStore 用于获取用户在线状态
import { useChatStore } from "@/stores/chatStore";
import MessageItem from "./MessageItem.vue";
import { uploadImage } from "@/api/chat.js";

const userStore = useUserStore();
// 【新增】获取 chatStore 实例
const chatStore = useChatStore();

const props = defineProps({
  chat: { type: Object, default: null },
  messages: { type: Array, default: () => [] },
  currentUserId: { type: Number, required: true },
  loading: { type: Boolean, default: false },
});

const emit = defineEmits(["send", "delete-message"]);

function handleDeleteMessage(messageId) {
  emit("delete-message", messageId);
}

const draft = ref("");
const fileInput = ref(null);
const scrollBox = ref(null);

const peerId = computed(() => {
  if (!props.chat) return null;
  return props.chat.user1Id === props.currentUserId
      ? props.chat.user2Id
      : props.chat.user1Id;
});

// 【新增】创建一个计算属性来获取对方的在线状态
const isPeerOnline = computed(() => {
  if (!peerId.value) {
    return false; // 如果没有对方ID，则默认为离线
  }
  // 使用 chatStore 中的 getter 来检查状态
  return chatStore.isUserOnline(peerId.value);
});

const peerName = computed(() => {
  if (!props.chat) return "";
  return props.chat.user1Id === props.currentUserId
      ? props.chat.user2Name
      : props.chat.user1Name;
});

const peerAvatar = computed(() => {
  if (!props.chat) return null;
  if (props.chat.user1Avatar && props.chat.user2Avatar) {
    return props.chat.user1Id === props.currentUserId
        ? props.chat.user2Avatar
        : props.chat.user1Avatar;
  }
  return null;
});

const peerInitial = computed(() => {
  return peerName.value.slice(0, 1);
});

const currentUserAvatar = computed(() => {
  if (!props.chat) return "";
  return props.chat.user1Id === props.currentUserId
      ? props.chat.user1Avatar
      : props.chat.user2Avatar;
});

const canSend = computed(() => draft.value.trim().length > 0);

function triggerImage() {
  fileInput.value?.click();
}

async function handleImage(e) {
  const file = e.target.files?.[0];
  if (!file) return;
  try {
    const permanentUrl = await uploadImage(file);
    if (permanentUrl) {
      emit("send", {
        chatId: props.chat.chatId,
        content: "",
        messageType: 2,
        attachmentUrl: permanentUrl,
      });
    }
  } catch (error) {
    console.error("上传失败:", error);
    alert("图片上传失败，请稍后重试。");
  } finally {
    if (fileInput.value) {
      fileInput.value.value = "";
    }
  }
}

function doSend() {
  if (!canSend.value) return;
  emit("send", {
    chatId: props.chat.chatId,
    content: draft.value.trim(),
    messageType: 1,
  });
  draft.value = "";
}

function handleAvatarError(event) {
  event.target.style.display = "none";
}

function scrollToBottom() {
  const box = scrollBox.value;
  if (!box) return;
  setTimeout(() => {
    box.scrollTo({ top: box.scrollHeight, behavior: "smooth" });
  }, 50);
}

const TIME_THRESHOLD_MINUTES = 5;

function shouldShowTimestamp(currentMessage, previousMessage) {
  if (!previousMessage) {
    return true;
  }
  const currentTime = new Date(currentMessage.createdAt).getTime();
  const previousTime = new Date(previousMessage.createdAt).getTime();
  const diffInMinutes = (currentTime - previousTime) / (1000 * 60);
  return diffInMinutes > TIME_THRESHOLD_MINUTES;
}

function formatTimestamp(dateString) {
  const messageDate = new Date(dateString);
  const now = new Date();

  const startOfDay = (date) => {
    const newDate = new Date(date);
    newDate.setHours(0, 0, 0, 0);
    return newDate;
  };

  const messageDay = startOfDay(messageDate);
  const today = startOfDay(now);
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  const oneWeekAgo = new Date(today);
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

  const timeFormat = {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  };

  if (messageDay.getTime() === today.getTime()) {
    return messageDate.toLocaleTimeString("zh-CN", timeFormat);
  }
  if (messageDay.getTime() === yesterday.getTime()) {
    return `昨天 ${messageDate.toLocaleTimeString("zh-CN", timeFormat)}`;
  }
  if (messageDate > oneWeekAgo) {
    const dayOfWeek = new Intl.DateTimeFormat("zh-CN", {
      weekday: "long",
    }).format(messageDate);
    return `${dayOfWeek} ${messageDate.toLocaleTimeString("zh-CN", timeFormat)}`;
  }
  return messageDate.toLocaleDateString("zh-CN", {
    year: "numeric",
    month: "numeric",
    day: "numeric",
  });
}

watch(() => props.messages.length, scrollToBottom, { flush: "post" });
onUpdated(scrollToBottom);
</script>

<style scoped>
/* --- 样式基本保持不变，只为在线状态添加新样式 --- */
.window {
  height: 100%;
  display: grid;
  grid-template-rows: 70px 1fr 72px;
  border-radius: 16px;
  overflow: hidden;
  background: var(--glass-bg-primary);
  backdrop-filter: blur(var(--glass-blur-radius));
  -webkit-backdrop-filter: blur(var(--glass-blur-radius));
  border: 1px solid var(--glass-border-color);
}

.window-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  border-bottom: 1px solid var(--glass-border-color);
  flex-shrink: 0;
  background: var(--glass-bg-secondary);
  backdrop-filter: blur(var(--glass-blur-radius));
}

.peer {
  display: flex;
  align-items: center;
  gap: 14px;
}
.peer .avatar-container {
  /* 【修改】添加 position: relative; 以便定位指示器 */
  position: relative;
  width: 44px;
  height: 44px;
}
.peer .avatar-img,
.peer .avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid rgba(255, 255, 255, 0.7);
}
.peer .avatar {
  background: linear-gradient(135deg, var(--accent-color), #a29bfe);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
}
.peer .avatar::after {
  content: attr(data-initial);
}
.peer .info h4 {
  margin: 0;
  color: var(--text-color-primary);
  font-weight: 600;
  font-size: 17px;
}
.peer .info .sub {
  color: var(--text-color-secondary);
  font-size: 13px;
  /* 【新增】添加过渡效果，让颜色变化更平滑 */
  transition: color 0.3s ease;
}

/* 【新增】在线状态的专属颜色 */
.peer .info .sub.is-online {
  color: #4caf50; /* 一个代表在线的绿色 */
}

/* 【新增】在线状态指示器的样式 */
.online-indicator {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 10px;
  height: 10px;
  background-color: #4caf50;
  border-radius: 50%;
  border: 2px solid var(--glass-bg-primary); /* 让指示器和背景有区分 */
  box-sizing: content-box;
}

.actions .ghost {
  background: transparent;
  border: none;
  color: var(--text-color-secondary);
  font-size: 16px;
  padding: 10px;
  border-radius: 50%;
  transition: all 0.2s ease;
}
.actions .ghost:hover {
  background: var(--glass-bg-tertiary);
  color: var(--text-color-primary);
}

.message-box {
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.timestamp {
  text-align: center;
  margin: 12px 0 20px;
}

.timestamp span {
  background-color: rgba(0, 0, 0, 0.1);
  color: #fff;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.theme-dark .timestamp span {
  background-color: rgba(255, 255, 255, 0.1);
  color: var(--text-color-secondary);
}

.loading-line {
  text-align: center;
  color: var(--text-color-secondary);
  padding: 20px;
}

.composer {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 0 24px;
  border-top: 1px solid var(--glass-border-color);
  flex-shrink: 0;
  background: var(--glass-bg-secondary);
  backdrop-filter: blur(var(--glass-blur-radius));
}

.tools .ghost {
  background: transparent;
  border: none;
  padding: 10px 12px;
  border-radius: 12px;
  color: var(--text-color-secondary);
  font-size: 20px;
  transition: all 0.2s ease;
}
.tools .ghost:hover {
  background: var(--glass-bg-tertiary);
  color: var(--accent-color);
}

.input-wrapper {
  flex: 1;
  position: relative;
}

.input {
  height: 48px;
  width: 100%;
  border: 1px solid transparent;
  background: var(--glass-bg-tertiary);
  border-radius: 12px;
  padding: 0 16px;
  outline: none;
  font-family: inherit;
  font-size: 15px;
  color: var(--text-color-primary);
  transition: all 0.3s ease;
}
.input::placeholder {
  color: var(--text-color-tertiary);
}

.input:focus {
  border-color: var(--accent-color);
  background: var(--glass-bg-secondary);
  box-shadow: 0 0 0 4px var(--accent-glow-color);
}

.send {
  height: 48px;
  width: 48px;
  border: none;
  background: var(--accent-color);
  color: #fff;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 600;
  transition: all 0.2s ease;
  flex-shrink: 0;
}
.send:hover:not(:disabled) {
  background: var(--accent-color-hover);
  transform: scale(1.05) translateY(-2px);
  box-shadow: var(--shadow-md);
}
.send:disabled {
  background: var(--text-color-tertiary);
  cursor: not-allowed;
  opacity: 0.6;
}
</style>
