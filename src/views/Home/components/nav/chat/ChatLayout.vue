<template>
  <!-- 主容器，定义了背景和全局布局 -->
  <div class="gemini-chat-container" :class="{ 'theme-dark': isDarkTheme }">
    <!-- 聊天窗口，现在有了固定的最大尺寸，并居中显示 -->
    <div class="chat-app-window">
      <!-- 新增：返回按钮 -->
      <button @click="goBack" class="back-button" title="返回上一页">
        <i class="fas fa-arrow-left"></i>
      </button>

      <aside
          class="chat-sidebar"
          :class="{ 'is-hidden': isMobile && !sidebarOpen }"
      >
        <ChatSidebar
            :conversations="conversations"
            :active-chat-id="activeChatId"
            :current-user-id="currentUserId"
            @select="handleSelectChat"
            @delete-chat="handleDeleteChat"
        />
      </aside>
      <main class="chat-main">
        <!-- MODIFICATION: Added transition for smoother chat window switching -->
        <transition name="fade-main" mode="out-in">
          <ChatWindow
              v-if="activeChatId"
              :key="activeChatId"
              :chat="activeChat"
              :messages="messages"
              :current-user-id="currentUserId"
              :loading="loadingMessages"
              @send="handleSend"
              @delete-message="handleDeleteMessage"
          />
          <div v-else class="empty-state" key="empty">
            <div class="empty-card">
              <i class="fas fa-comments"></i>
              <h3>选择一个会话开始聊天</h3>
              <p>从左侧列表选择或开启一个新的对话</p>
            </div>
          </div>
        </transition>
      </main>
    </div>
    <!-- 手机端侧边栏切换按钮 -->
    <button
        v-if="isMobile"
        class="toggle-sidebar"
        @click="sidebarOpen = !sidebarOpen"
    >
      <i :class="['fas', sidebarOpen ? 'fa-xmark' : 'fa-user-group']"></i>
    </button>
    <!-- 全局加载提示 -->
    <GlobalLoading
        v-if="loadingConversations || initializing"
        :title="loadingTitle"
    />
  </div>
</template>

<script setup>
import { onMounted, ref, computed, watch, onBeforeUnmount } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useUserStore } from "@/stores/userStore";
import { useChatStore } from "@/stores/chatStore";
import ChatSidebar from "./ChatSidebar.vue";
import ChatWindow from "./ChatWindow.vue";
import GlobalLoading from "@/views/Admin/components/GlobalLoading.vue";
import chatApi from "@/api/chat";
import ws from "@/utils/websocket";
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";

// --- SCRIPT 逻辑 ---
const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const chatStore = useChatStore();
const currentUserId = computed(
    () => userStore.userInfo?.userId || userStore.userInfo?.id || null
);
const conversations = computed(() => chatStore.conversations);
const loadingConversations = computed(() => chatStore.loading);
const messages = ref([]);
const activeChatId = ref(null);
const loadingMessages = ref(false);
const initializing = ref(true);
const isMobile = window.matchMedia("(max-width: 900px)").matches;
const sidebarOpen = ref(!isMobile);
const isDarkTheme = ref(
    window.matchMedia("(prefers-color-scheme: dark)").matches
);
const activeChat = computed(
    () => conversations.value.find((c) => c.chatId === activeChatId.value) || null
);
const loadingTitle = computed(() => {
  if (initializing.value) return "加载中...";
  if (loadingConversations.value) return "刷新会话...";
  return "";
});
let unsubscribeWsHandler = null;

// 新增：返回上一页的函数
const goBack = () => {
  router.back();
};

watch(
    activeChatId,
    (newId) => {
      chatStore.setActiveChatId(newId);
    },
    { immediate: true }
);
async function loadMessages(chatId) {
  if (!chatId) return;
  loadingMessages.value = true;
  try {
    const response = await chatApi.getChatMessages(chatId);
    messages.value = response.list || [];
    chatStore.markChatAsRead(chatId);
  } catch (error) {
    console.error(`加载消息失败 (chatId: ${chatId}):`, error);
    messages.value = [];
  } finally {
    loadingMessages.value = false;
  }
}
function handleSelectChat(chatId) {
  if (activeChatId.value === chatId) return;
  activeChatId.value = chatId;
  loadMessages(chatId);
  if (isMobile) sidebarOpen.value = false;
}
function handleSend({ chatId, content, messageType, attachmentUrl }) {
  if ((!content || content.trim() === "") && !attachmentUrl) return;
  if (!ws.isConnected()) {
    // 使用 custom modal代替 alert
    alert("连接已断开，无法发送消息。");
    return;
  }
  const optimisticMessage = {
    messageId: `temp_${Date.now()}`,
    chatId,
    senderId: currentUserId.value,
    content,
    messageType,
    attachmentUrl,
    createdAt: new Date().toISOString(),
    isRead: 0,
    senderName: userStore.userInfo?.username || "我",
    senderAvatar: userStore.userInfo?.avatarPath || "",
  };
  messages.value.push(optimisticMessage);
  try {
    ws.sendMessage("CHAT_MESSAGE", { chatId, content, messageType, attachmentUrl });
  } catch (e) {
    console.error("WebSocket 消息发送失败:", e);
    const msgIndex = messages.value.findIndex(
        (m) => m.messageId === optimisticMessage.messageId
    );
    if (msgIndex > -1) messages.value[msgIndex].error = true;
  }
}
function handleComponentSpecificMessage(msg) {
  const payload = msg?.data || msg;
  if (!payload || payload.chatId !== activeChatId.value) return;
  const tempMsgIndex = messages.value.findIndex(
      (m) => m.messageId.toString().startsWith("temp_") && m.content === payload.content
  );
  if (tempMsgIndex > -1) {
    messages.value.splice(tempMsgIndex, 1, payload);
  } else {
    messages.value.push(payload);
  }
  chatStore.markChatAsRead(payload.chatId);
}
async function handleDeleteMessage(messageId) {
  try {
    await chatApi.deleteMessage(messageId);
    const index = messages.value.findIndex((m) => m.messageId === messageId);
    if (index !== -1) messages.value.splice(index, 1);
  } catch (error) {
    // 使用 custom modal代替 alert
    alert("删除失败，请重试。");
  }
}
async function handleDeleteChat(chatIdToDelete) {
  try {
    await chatApi.deleteChat(chatIdToDelete);
    await chatStore.fetchConversations();
  } catch (error) {
    // 使用 custom modal代替 alert
    alert("删除失败，请重试。");
  }
}
function setupMessageHandlers() {
  if (unsubscribeWsHandler) unsubscribeWsHandler();
  unsubscribeWsHandler = ws.onMessage(
      "CHAT_MESSAGE",
      handleComponentSpecificMessage
  );
  console.log("ChatLayout: 组件专用的消息监听器已设置。");
}
watch(
    () => chatStore.conversations,
    (newConversations) => {
      if (
          activeChatId.value &&
          !newConversations.some((c) => c.chatId === activeChatId.value)
      ) {
        activeChatId.value = null;
        messages.value = [];
      }
    },
    { deep: true }
);
async function initiateChatFromRoute() {
  const peerId = route.query.peerId;
  if (peerId && !isNaN(peerId)) {
    try {
      const chat = await chatApi.findOrCreateChat(Number(peerId));
      chatStore.addConversation(chat);
      handleSelectChat(chat.chatId);
      router.replace({ path: "/chat", query: {} });
    } catch (error) {
      // 使用 custom modal代替 alert
      alert("无法开始新的对话。");
      router.replace({ path: "/chat", query: {} });
    }
  }
}
onMounted(async () => {
  initializing.value = true;
  try {
    if (!userStore.hydrated) userStore.restoreFromStorage();
    if (userStore.token) {
      if (chatStore.conversations.length === 0) {
        await chatStore.fetchConversations();
      }
      await initiateChatFromRoute();
      setupMessageHandlers();
    }
  } finally {
    initializing.value = false;
  }
});
onBeforeUnmount(() => {
  if (unsubscribeWsHandler) {
    unsubscribeWsHandler();
    console.log("ChatLayout: 组件已卸载，取消专用的消息监听器。");
  }
  chatStore.setActiveChatId(null);
});
</script>

<style scoped>
/* --- 全新样式，适配毛玻璃主题 --- */
.chat-app-window {
  width: 100%;
  height: 100%;
  max-width: 1200px;
  max-height: 90vh; /* 限制最大高度 */
  display: grid;
  grid-template-columns: 320px 1fr; /* 侧边栏和主窗口比例 */
  border-radius: var(--border-radius-lg);
  overflow: hidden;
  position: relative; /* 修改：为返回按钮定位提供基准 */
  animation: fadeIn 0.8s var(--transition-medium) backwards;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

/* 新增：返回按钮样式 */
.back-button {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 110; /* 确保在侧边栏之上 */
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.25);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.2s ease-in-out;
  backdrop-filter: blur(5px);
}

.back-button:hover {
  background: rgba(0, 0, 0, 0.5);
  transform: scale(1.05);
}

.chat-sidebar {
  width: 320px;
  flex-shrink: 0;
  border-radius: 16px;
  overflow: hidden; /* 确保子元素不会超出圆角 */
  animation: dissolveIn 0.5s ease-out forwards;
}

.chat-main {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  margin-left: 16px;
  border-radius: 16px;
  overflow: hidden;
  animation: dissolveIn 0.6s ease-out forwards;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  /* 应用毛玻璃效果 */
  background: var(--glass-bg-primary);
  backdrop-filter: blur(var(--glass-blur-radius));
  border: 1px solid var(--glass-border-color);
}

.empty-card {
  text-align: center;
  color: var(--text-color-secondary);
  animation: fadeIn 0.5s ease;
}

.empty-card i {
  font-size: 52px;
  margin-bottom: 20px;
  color: var(--text-color-tertiary);
}

.empty-card h3 {
  color: var(--text-color-primary);
  margin: 0 0 8px;
  font-weight: 600;
}

.toggle-sidebar {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: 1px solid var(--glass-border-color);
  background-color: var(--accent-color);
  color: white;
  font-size: 22px;
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: var(--shadow-md);
  z-index: 1000;
  transition: all 0.3s ease;
  backdrop-filter: blur(5px);
}

.toggle-sidebar:hover {
  transform: translateY(-3px) scale(1.05);
  background-color: var(--accent-color-hover);
}

/* NEW: Styles for the main content transition */
.fade-main-enter-active,
.fade-main-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.fade-main-enter-from,
.fade-main-leave-to {
  opacity: 0;
  transform: translateY(5px);
}


@media (max-width: 900px) {
  .chat-app-window {
    max-width: 100%;
    max-height: 100vh;
    border-radius: 0;
  }

  .chat-sidebar {
    position: absolute;
    width: 100%;
    height: 100%;
    z-index: 100;
    border-radius: 0;
    padding-top: 60px; /* 为返回按钮留出空间 */
  }

  .chat-sidebar.is-hidden {
    display: none;
  }

  .chat-main {
    margin-left: 0;
    width: 100%;
    height: 100%;
    border-radius: 0;
  }

  .back-button {
    top: 15px;
    left: 15px;
  }
}
</style>
