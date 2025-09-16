<template>
  <HomeNavbar />
  <div :class="$style.pageWrapper">
    <div :class="$style.chatLayout">
      <!-- Sidebar -->
      <div :class="[$style.sidebar, { [$style.isOpen]: isSidebarOpen }]">
        <div :class="$style.sidebarContent">
          <div :class="$style.sidebarHeader">
            <h3>聊天历史</h3>
            <button :class="$style.actionBtn" @click="startNewConversation" title="新聊天">
              <i class="fas fa-plus"></i>
            </button>
          </div>
          <ul :class="$style.historyList">
            <li v-if="historyList.length === 0" :class="$style.noHistory">暂无历史记录</li>
            <!-- 使用计算属性 displayHistoryList 来渲染列表 -->
            <li v-for="session in displayHistoryList" :key="session.conversationId || 'new-chat'"
                :class="[$style.historyItem, { [$style.active]: currentConversationId === session.conversationId }]"
                @click="selectConversation(session.conversationId)">
              <div :class="$style.historyItemContent">
                <i class="far fa-comment-dots"></i>
                <!-- 【核心修改】优先显示 summary，不存在时显示 firstQuestion -->
                <span>{{ getDisplayTitle(session.summary || session.firstQuestion) }}</span>
              </div>
              <!-- 只有真实会话才显示删除按钮 -->
              <button v-if="session.conversationId" :class="$style.deleteBtn" @click.stop="deleteConversation(session.conversationId)">
                <i class="fas fa-trash"></i>
              </button>
            </li>
          </ul>
          <div :class="$style.sidebarFooter">
            <div v-if="userStore.isLoggedIn" :class="$style.userInfo">
              <!-- 【修改】显示用户头像图片 -->
              <div :class="$style.avatar">
                <img v-if="userStore.userInfo?.avatarPath" :src="userStore.userInfo.avatarPath" alt="User Avatar" />
                <span v-else>{{ userStore.userInfo.username.charAt(0).toUpperCase() }}</span>
              </div>
              <div :class="$style.userDetails">
                <span :class="$style.username">{{ userStore.userInfo.username }}</span>
                <span :class="$style.status">在线</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Chat Interface -->
      <div :class="$style.mainContent">
        <div :class="$style.header">
          <button :class="$style.sidebarToggleBtn" @click="toggleSidebar" title="切换历史记录">
            <i class="fas fa-bars"></i>
          </button>
          <div :class="$style.chatInfo">
            <!-- 【修改】显示AI助手SVG图标 -->
            <div :class="$style.chatIcon">
              <img src="http://localhost:8080/uploads/avatar/deepseek.png" alt="AI Icon" />
            </div>
            <div :class="$style.chatTitleGroup">
              <h2>DeepSeek AI 助手</h2>
              <p>基于 DeepSeek 大语言模型</p>
            </div>
          </div>
        </div>

        <div :class="$style.chatContainer" ref="chatContainer">
          <div class="message ai-message" v-if="messages.length === 0 && !isLoading" :class="$style.message">
            <div :class="[$style.avatarContainer, $style.aiAvatar]">
              <img src="http://localhost:8080/uploads/avatar/deepseek.png" alt="AI Avatar" />
            </div>
            <div :class="$style.messageContent">
              <div :class="[$style.bubble, $style.aiBubble]">你好！我是AI助手，很高兴为您服务。请问有什么可以帮您的吗？</div>
            </div>
          </div>

          <div v-for="(message, index) in messages" :key="index" :class="[$style.message, message.role === 'user' ? $style.userMessage : '']">
            <!-- 【修改】显示AI和用户的头像图片 -->
            <div :class="[$style.avatarContainer, message.role === 'assistant' ? $style.aiAvatar : $style.userAvatar]">
              <img v-if="message.role === 'assistant'" src="http://localhost:8080/uploads/avatar/deepseek.png" alt="AI Avatar" />
              <template v-else>
                <img v-if="userStore.userInfo?.avatarPath" :src="userStore.userInfo.avatarPath" alt="User Avatar" />
                <span v-else>{{ userStore.userInfo?.username?.charAt(0).toUpperCase() || 'U' }}</span>
              </template>
            </div>
            <div :class="$style.messageContent">
              <div :class="[$style.bubble, message.role === 'assistant' ? $style.aiBubble : $style.userBubble]">
                <!-- 【FIX for Double Loader】 Conditionally show typing indicator IN the bubble -->
                <div v-if="isLoading && message.role === 'assistant' && !message.rawContent" :class="$style.typingIndicator">
                  <span></span><span></span><span></span>
                </div>
                <div v-else v-html="message.content"></div>
              </div>
            </div>
          </div>

          <!-- 【REMOVED】The separate loading indicator block is removed to prevent double loaders. -->

        </div>

        <div :class="$style.inputArea">
          <div :class="$style.inputBox">
            <textarea v-model="userInput" placeholder="输入您的问题..."
                      @keydown="handleKeydown"
                      @input="adjustTextareaHeight"
                      ref="textarea"
                      :disabled="isLoading"
                      rows="1"
            ></textarea>
            <button :class="$style.sendBtn" @click="sendMessage" :disabled="isLoading || !userInput.trim()">
              发送
            </button>
          </div>
          <p :class="$style.inputHint">提示: 按 Enter 发送消息, Shift + Enter 换行</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref, onMounted, onUnmounted, nextTick, computed, watch} from 'vue';
import {useUserStore} from '@/stores/userStore';
import {marked} from 'marked';
import DOMPurify from 'dompurify';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import {getHistory, getConversation, deleteConversation as apiDeleteConversation} from '@/api/ai-chat';
// 导入新的 WebSocket 服务
import wsChat from '@/utils/websocket-ai';

const userStore = useUserStore();
const userId = computed(() => userStore.userInfo?.userId);

const historyList = ref([]);
const messages = ref([]);
const userInput = ref('');
const currentConversationId = ref(null);
const isLoading = ref(false);
const isSidebarOpen = ref(true);

const chatContainer = ref(null);
const textarea = ref(null);

// 监听器清理函数数组
let unsubscribeFunctions = [];

// 【新增】计算属性，用于在开始新对话时，在历史列表中显示 "新对话"
const displayHistoryList = computed(() => {
  if (currentConversationId.value === null) {
    // 将 "新对话" 插入到列表的最前面
    return [
      { conversationId: null, firstQuestion: '新对话' },
      ...historyList.value
    ];
  }
  return historyList.value;
});

onMounted(() => {
  if (userId.value) {
    fetchHistory();
  }
});

onUnmounted(() => {
  // 组件卸载时，断开连接并清理所有监听器
  wsChat.disconnect();
  unsubscribeFunctions.forEach(unsub => unsub());
  unsubscribeFunctions = [];
});


watch(userId, (newUserId) => {
  if (newUserId) {
    fetchHistory();
  } else {
    startNewConversation();
    historyList.value = [];
  }
});

const fetchHistory = async () => {
  if (!userId.value) return;
  try {
    const response = await getHistory(userId.value);
    // 【修复】在这里过滤掉数组中的 null 或 undefined 值
    historyList.value = response.data.filter(session => session);
  } catch (error) {
    console.error('Error fetching history:', error);
  }
};

const fetchConversation = async (conversationId) => {
  try {
    const response = await getConversation(conversationId);
    const records = response.data;
    messages.value = records.flatMap(r => [
      {role: 'user', content: renderMarkdown(r.question)},
      {role: 'assistant', content: renderMarkdown(r.answer)}
    ]);
    scrollToBottom();
  } catch (error) {
    console.error('Error fetching conversation:', error);
    messages.value = [{role: 'assistant', content: '加载会话失败'}];
  }
};

const deleteConversation = async (conversationId) => {
  if (!window.confirm('确定要删除此会话吗？')) return;
  try {
    await apiDeleteConversation(conversationId);
    if (currentConversationId.value === conversationId) {
      startNewConversation();
    }
    await fetchHistory();
  } catch (error) {
    console.error('Error deleting conversation:', error);
  }
};

const setupWebSocketListeners = () => {
  // 清理旧的监听器
  unsubscribeFunctions.forEach(unsub => unsub());
  unsubscribeFunctions = [];

  // 设置新的监听器
  const unsubMessage = wsChat.onMessage('message', (data) => {
    if (isLoading.value) isLoading.value = false;
    let lastMessage = messages.value[messages.value.length - 1];
    if (lastMessage && lastMessage.role === 'assistant') {
      if (lastMessage.rawContent === undefined) lastMessage.rawContent = '';
      lastMessage.rawContent += data.content;
      lastMessage.content = renderMarkdown(lastMessage.rawContent);
      scrollToBottom();
    }
  });

  const unsubComplete = wsChat.onMessage('complete', (data) => {
    if (!currentConversationId.value) {
      currentConversationId.value = data.conversationId;
    }

    // 【FIX for Summary Delay】
    // Ideal Fix: Backend should send summary in 'complete' message for instant update.
    // This frontend code handles that case.
    if (data.summary && data.conversationId) {
      const sessionInHistory = historyList.value.find(s => s.conversationId === data.conversationId);
      if (sessionInHistory) {
        // Update existing summary
        sessionInHistory.summary = data.summary;
      } else {
        // This was a new chat, refetch the list to get the new item.
        fetchHistory();
      }
    } else {
      // Fallback: If backend doesn't send summary, just refetch history.
      // This might still show the old title due to the race condition.
      fetchHistory();
    }

    wsChat.disconnect();
  });

  const unsubError = wsChat.onMessage('error', (data) => {
    isLoading.value = false;
    let lastMessage = messages.value[messages.value.length - 1];
    if (lastMessage && lastMessage.role === 'assistant') {
      lastMessage.content = `发生错误: ${data.content}`;
    }
    wsChat.disconnect();
  });

  // 保存清理函数
  unsubscribeFunctions.push(unsubMessage, unsubComplete, unsubError);
};

const sendMessage = async () => {
  if (!userInput.value.trim()) return;

  const trimmedInput = userInput.value.trim();
  messages.value.push({role: 'user', content: renderMarkdown(trimmedInput)});
  userInput.value = '';
  adjustTextareaHeight();
  isLoading.value = true;
  scrollToBottom();

  // 【FIX for Double Loader】 This placeholder is now used for the inline typing indicator
  messages.value.push({role: 'assistant', content: '', rawContent: ''});
  scrollToBottom();

  try {
    // 如果未连接，则先连接
    if (!wsChat.isConnected) {
      const conversationIdToSend = currentConversationId.value || `web_${Date.now()}`;

      await wsChat.connect({
        params: {conversationId: conversationIdToSend},
      });
      // 连接成功后，设置监听器
      setupWebSocketListeners();
    }

    // 发送消息
    wsChat.sendMessage({question: trimmedInput});

  } catch (error) {
    isLoading.value = false;
    const lastMessage = messages.value[messages.value.length - 1];
    if (lastMessage) {
      lastMessage.content = '连接AI助手失败，请稍后重试。';
    }
    console.error("Failed to connect or send message:", error);
  }
};


const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value;
};

const startNewConversation = () => {
  currentConversationId.value = null;
  messages.value = [];
  userInput.value = '';
  isLoading.value = false;
  wsChat.disconnect();
};

const selectConversation = (id) => {
  if (currentConversationId.value === id) return;
  startNewConversation(); // 先重置状态
  if (id) {
    currentConversationId.value = id;
    fetchConversation(id);
  }
};

const handleKeydown = (e) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
};

const adjustTextareaHeight = () => {
  nextTick(() => {
    const el = textarea.value;
    if (!el) return;
    el.style.height = 'auto';
    el.style.height = `${el.scrollHeight}px`;
  });
};

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight;
    }
  });
};

const getDisplayTitle = (title) => {
  if (!title) return '新对话';
  return title.length > 18 ? `${title.substring(0, 18)}...` : title;
};

const renderMarkdown = (content) => {
  if (typeof content !== 'string' || !content) return '';
  const rawHtml = marked.parse(content, {
    highlight: function (code, lang) {
      const language = hljs.getLanguage(lang) ? lang : 'plaintext';
      return hljs.highlight(code, {language}).value;
    },
    gfm: true,
    breaks: true,
  });
  return DOMPurify.sanitize(rawHtml);
};
</script>

<style module>
:root {
  --page-bg: #f4f6f8;
  --sidebar-bg: #ffffff;
  --chat-bg: #ffffff;
  --text-primary: #1a1a1a;
  --text-secondary: #6c757d;
  --text-light: #f8f9fa;
  --accent-color: #007bff;
  --accent-hover: #0056b3;
  --border-color: #dee2e6;
  --sidebar-width: 280px;
  --font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

.pageWrapper {
  width: 100%;
  height: calc(100vh - 60px); /* 减去顶部导航栏高度 */
  background-color: var(--page-bg);
  padding: 24px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  align-items: center;
  padding-top: 80px;
}

.chatLayout {
  width: 100%;
  height: 100%;
  max-width: 1200px;
  display: flex;
  background-color: var(--chat-bg);
  border-radius: 12px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.sidebar {
  width: var(--sidebar-width);
  background-color: var(--sidebar-bg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  transition: width 0.3s ease-in-out, padding 0.3s ease-in-out;
  overflow: hidden;
}

.sidebar:not(.isOpen) {
  width: 0;
  padding: 0;
  border-right: none;
}

.sidebarContent {
  width: var(--sidebar-width); /* Fixed width for content */
  height: 100%;
  display: flex;
  flex-direction: column;
}

.sidebarHeader {
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
  flex-shrink: 0;
}

.sidebarHeader h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  white-space: nowrap;
}

.actionBtn {
  font-size: 1rem;
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-secondary);
}

.actionBtn:hover {
  color: var(--accent-color);
}

.historyList {
  flex-grow: 1;
  overflow-y: auto;
  list-style: none;
  padding: 0.5rem;
  margin: 0;
}

.historyItem {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s ease, color 0.2s ease;
  margin-bottom: 4px;
  gap: 8px;
  white-space: nowrap;
}

.historyItem:hover {
  background-color: #e9ecef;
}

.historyItem.active {
  background-color: var(--accent-color);
  color: var(--text-light);
}

.historyItem.active .historyItemContent,
.historyItem.active .deleteBtn {
  color: var(--text-light);
}

.historyItemContent {
  flex-grow: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 0.9rem;
  overflow: hidden;
  color: var(--text-primary);
}

.historyItemContent span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.deleteBtn {
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-secondary);
  font-size: 0.85rem;
  opacity: 0;
  transition: opacity 0.2s;
}

.historyItem:hover .deleteBtn {
  opacity: 1;
}

.deleteBtn:hover {
  color: #dc3545;
}

.noHistory {
  color: var(--text-secondary);
  text-align: center;
  padding-top: 20px;
  font-size: 0.9rem;
}

.sidebarFooter {
  padding: 1rem;
  border-top: 1px solid var(--border-color);
  flex-shrink: 0;
}

.userInfo {
  display: flex;
  align-items: center;
  gap: 12px;
  white-space: nowrap;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: var(--accent-color);
  color: white;
  font-weight: bold;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 1.2rem;
  flex-shrink: 0;
  overflow: hidden;
}

.userDetails {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.username {
  font-weight: 600;
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.status {
  font-size: 0.75rem;
  color: #28a745;
}

.mainContent {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.header {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--border-color);
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sidebarToggleBtn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background-color: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sidebarToggleBtn:hover {
  color: var(--accent-color);
  background-color: #f8f9fa;
}

.chatInfo {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.chatIcon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  color: white;
  display: grid;
  place-items: center;
  font-size: 1.5rem;
}

.chatTitleGroup h2 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.chatTitleGroup p {
  margin: 2px 0 0;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.chatContainer {
  flex-grow: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

.message {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
  max-width: 90%;
  align-items: flex-start;
  /* 【新增】消息出现动画 */
  animation: messageFadeIn 0.5s ease-in-out;
}

.userMessage {
  margin-left: auto;
  flex-direction: row-reverse;
}

.avatarContainer {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
  font-weight: 600;
  font-size: 1rem;
  margin-top: 4px;
  overflow: hidden;
}

.aiAvatar {
  background-color: #f0f0f0;
  color: white;
}

.userAvatar {
  background-color: var(--accent-color);
  color: white;
}

.bubble {
  padding: 0.75rem 1rem;
  border-radius: 12px;
  font-size: 0.95rem;
  line-height: 1.6;
  width: fit-content;
  max-width: 100%;
  word-wrap: break-word;
}

.aiBubble {
  background-color: #e9ecef;
  color: var(--text-primary);
  border-top-left-radius: 4px;
}

.userBubble {
  background-color: var(--accent-color);
  color: white;
  border-top-right-radius: 4px;
}

.bubble :deep(p:last-child) {
  margin-bottom: 0;
}

.bubble :deep(pre) {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  padding: 0.8em;
  margin: 0.8em 0;
  overflow-x: auto;
  font-size: 0.85em;
}

.bubble :deep(code) {
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, Courier, monospace;
}

.bubble :deep(pre code) {
  background: none;
  padding: 0;
}

.bubble :deep(ol), .bubble :deep(ul) {
  padding-left: 20px;
}

.inputArea {
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--border-color);
  background-color: #f8f9fa;
  flex-shrink: 0;
}

.inputBox {
  position: relative;
}

.inputBox textarea {
  width: 100%;
  padding: 0.75rem 6rem 0.75rem 1rem;
  border-radius: 8px;
  background-color: var(--chat-bg);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
  resize: none;
  font-family: inherit;
  font-size: 1rem;
  line-height: 1.5;
  max-height: 150px;
  overflow-y: auto;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.inputBox textarea:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.15);
}

.sendBtn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  padding: 0.5rem 1.25rem;
  border-radius: 6px;
  background-color: var(--accent-color);
  color: white;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: background-color 0.2s;
}

.sendBtn:hover {
  background-color: var(--accent-hover);
}

.sendBtn:disabled {
  background-color: #a1a1a1;
  cursor: not-allowed;
}

.inputHint {
  font-size: 0.75rem;
  color: var(--text-secondary);
  margin: 0.5rem 0 0;
  text-align: left;
}

/* 【优化】加载动画的容器，确保小点垂直居中 */
.typingIndicator {
  display: flex;
  align-items: center;
  padding: 0.2rem 0; /* Add some vertical padding */
}

/* 【优化】加载中气泡的呼吸动画 */
.aiBubble.typingIndicator {
  animation: pulse-bg 2s infinite ease-in-out;
}

/* 【优化】加载小点样式 */
.typingIndicator span {
  width: 8px;
  height: 8px;
  background-color: var(--text-secondary);
  border-radius: 50%;
  display: inline-block;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typingIndicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typingIndicator span:nth-child(2) {
  animation-delay: -0.16s;
  margin: 0 6px;
}
.typingIndicator span:nth-child(3) {
  animation-delay: 0s;
}

/* 【新增】图片头像样式 */
.avatar img, .avatarContainer img {
  width: 100%;
  height: 100%;
  object-fit: cover; /* 确保图片覆盖整个容器，不变形 */
}

.chatIcon img {
  width: 28px;
  height: 28px;
}


/* 【新增】消息淡入动画 */
@keyframes messageFadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 【新增】加载中气泡背景脉动动画 */
@keyframes pulse-bg {
  0% { background-color: #e9ecef; }
  50% { background-color: #e1e5e9; }
  100% { background-color: #e9ecef; }
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1.0);
  }
}

@media (max-width: 768px) {
  .pageWrapper {
    padding: 0;
    height: 100vh;
  }

  .chatLayout {
    border-radius: 0;
    border: none;
    height: 100%;
  }

  .sidebar {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 1000;
    box-shadow: 4px 0px 15px rgba(0, 0, 0, 0.1);
  }
}
</style>
