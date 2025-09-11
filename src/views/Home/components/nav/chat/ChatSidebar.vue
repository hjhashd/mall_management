<template>
  <div class="sidebar glass-panel">
    <div class="sidebar-header">
      <h3>对话</h3>
      <div class="search-box">
        <i class="fas fa-magnifying-glass search-icon"></i>
        <input
            v-model="searchKeyword"
            placeholder="搜索..."
            @keyup.enter="performSearch"
        />
      </div>
    </div>
    <div class="conversation-list">
      <button
          v-for="chat in displayList"
          :key="chat.chatId"
          class="conversation-item"
          :class="{ active: chat.chatId === activeChatId }"
          @click="$emit('select', chat.chatId)"
          @contextmenu.prevent="showContextMenu($event, chat)"
      >
        <div class="avatar-container">
          <img
              v-if="getAvatar(chat) && !avatarErrorMap[chat.chatId]"
              :src="getAvatar(chat)"
              :alt="getName(chat)"
              class="avatar-img"
              @error="handleAvatarError(chat.chatId)"
          />
          <div v-else class="avatar" :data-initial="getInitial(chat)"></div>
          <div v-if="chat.unreadCount > 0" class="unread-badge">
            {{ chat.unreadCount > 99 ? "99+" : chat.unreadCount }}
          </div>
        </div>
        <div class="meta">
          <div class="top-row">
            <span class="name">{{ getName(chat) }}</span>
            <span class="time">{{ formatTime(chat.lastMessageTime) }}</span>
          </div>
          <div class="bottom-row">
            <span class="last">{{ chat.lastMessage || "暂无消息" }}</span>
          </div>
        </div>
      </button>

      <div v-if="displayList.length === 0" class="empty-list-state">
        <i class="fas fa-inbox"></i>
        <p>{{ searchKeyword ? "未找到相关对话" : "暂无对话" }}</p>
      </div>
    </div>

    <div
        v-if="contextMenu.visible"
        class="context-menu glass-panel"
        :style="{ top: contextMenu.y + 'px', left: contextMenu.x + 'px' }"
    >
      <button @click="confirmDeleteChat">
        <i class="fas fa-trash-alt"></i> 删除对话
      </button>
    </div>

    <div v-if="deleteConfirmation.visible" class="modal-overlay">
      <div class="modal-content glass-panel">
        <p>确定要删除与 "{{ deleteConfirmation.name }}" 的对话吗？</p>
        <span>此操作无法恢复。</span>
        <div class="modal-actions">
          <button class="btn-cancel" @click="cancelDelete">取消</button>
          <button class="btn-confirm" @click="executeDelete">确认删除</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// --- SCRIPT 逻辑保持不变 ---
import { computed, ref, watch, onMounted, onUnmounted } from "vue";
const props = defineProps({
  conversations: { type: Array, default: () => [] },
  activeChatId: { type: Number, default: null },
  currentUserId: { type: Number, default: null },
});
const emit = defineEmits(["select", "delete-chat"]);
const searchKeyword = ref("");
const isSearching = ref(false);
const avatarErrorMap = ref({});
const displayList = computed(() => {
  if (!isSearching.value || !searchKeyword.value.trim()) {
    return props.conversations;
  }
  const keyword = searchKeyword.value.trim().toLowerCase();
  return props.conversations.filter((c) => {
    const name = getName(c).toLowerCase();
    return (
        name.includes(keyword) || (c.lastMessage || "").toLowerCase().includes(keyword)
    );
  });
});
function performSearch() {
  isSearching.value = true;
}
const contextMenu = ref({ visible: false, x: 0, y: 0, chat: null });
const deleteConfirmation = ref({ visible: false, chatId: null, name: "" });
function showContextMenu(event, chat) {
  contextMenu.value = {
    visible: true,
    x: event.clientX,
    y: event.clientY,
    chat: chat,
  };
}
function hideContextMenu() {
  contextMenu.value.visible = false;
}

function confirmDeleteChat() {
  const chatToDelete = contextMenu.value.chat;
  if (chatToDelete) {
    deleteConfirmation.value = {
      visible: true,
      chatId: chatToDelete.chatId,
      name: getName(chatToDelete),
    };
  }
  hideContextMenu();
}

function cancelDelete() {
  deleteConfirmation.value.visible = false;
}

function executeDelete() {
  if (deleteConfirmation.value.chatId) {
    emit("delete-chat", deleteConfirmation.value.chatId);
  }
  cancelDelete();
}

onMounted(() => {
  window.addEventListener("click", hideContextMenu);
});
onUnmounted(() => {
  window.removeEventListener("click", hideContextMenu);
});

function getName(chat) {
  if (chat.user1Name && chat.user2Name) {
    return chat.user1Id === props.currentUserId ? chat.user2Name : chat.user1Name;
  }
  const peerId =
      chat.user1Id === props.currentUserId ? chat.user2Id : chat.user1Id;
  return `用户 ${peerId}`;
}

function getAvatar(chat) {
  if (chat.user1Avatar && chat.user2Avatar) {
    return chat.user1Id === props.currentUserId
        ? chat.user2Avatar
        : chat.user1Avatar;
  }
  return null;
}

function getInitial(chat) {
  return getName(chat).slice(0, 1).toUpperCase();
}

function formatTime(t) {
  if (!t) return "";
  const d = new Date(t);
  const now = new Date();
  const isToday = d.toDateString() === now.toDateString();
  return isToday
      ? d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      : d.toLocaleDateString();
}

function handleAvatarError(chatId) {
  avatarErrorMap.value[chatId] = true;
}

watch(searchKeyword, (newVal) => {
  if (!newVal.trim()) {
    isSearching.value = false;
  }
});
</script>

<style scoped>
/* --- 全新样式，适配毛玻璃主题 --- */
.sidebar {
  height: 100%;
  display: flex;
  flex-direction: column;
  border-radius: 16px;
  overflow: hidden; /* 确保子元素不超出圆角 */
}

.sidebar-header {
  padding: 24px 20px 20px;
  flex-shrink: 0;
  border-bottom: 1px solid var(--glass-border-color);
}

.sidebar-header h3 {
  margin: 0 0 16px;
  color: var(--text-color-primary);
  font-size: 22px;
  font-weight: 700;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--glass-bg-tertiary);
  border: 1px solid transparent;
  border-radius: 12px;
  padding: 10px 14px;
  transition: all 0.3s ease;
}

.search-box:focus-within {
  border-color: var(--accent-color);
  box-shadow: 0 0 0 4px var(--accent-glow-color);
}

.search-icon {
  color: var(--text-color-tertiary);
  font-size: 14px;
}

.search-box input {
  border: none;
  outline: none;
  width: 100%;
  background: transparent;
  color: var(--text-color-primary);
  font-size: 15px;
}

.search-box input::placeholder {
  color: var(--text-color-tertiary);
}

.conversation-list {
  overflow-y: auto;
  flex: 1;
  padding: 8px;
}

.conversation-item {
  width: 100%;
  display: grid;
  grid-template-columns: 48px 1fr;
  gap: 14px;
  padding: 12px;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 12px;
  text-align: left;
  cursor: pointer;
  /* MODIFICATION: Refined transition for smoother visual feedback */
  transition: background-color 0.25s ease-out, border-color 0.25s ease-out,
  transform 0.2s ease-out, box-shadow 0.25s ease-out;
}

/* 增强悬停时的毛玻璃效果 */
.conversation-item:hover {
  background: var(--glass-bg-secondary);
  border-color: var(--glass-border-color);
  transform: translateY(-2px);
  box-shadow: var(--shadow-sm);
}

.conversation-item.active {
  background: var(--glass-bg-secondary);
  border-color: var(--accent-color);
}

.conversation-item.active:hover {
  transform: translateY(0);
}

.avatar-container {
  position: relative;
  width: 48px;
  height: 48px;
  flex-shrink: 0;
}

.avatar-img,
.avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.avatar {
  background: linear-gradient(135deg, var(--accent-color), #a29bfe);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 18px;
}

.avatar::after {
  content: attr(data-initial);
}

.unread-badge {
  position: absolute;
  top: 0;
  right: 0;
  background: #ff4757;
  color: white;
  border-radius: 50%;
  min-width: 22px;
  height: 22px;
  padding: 0 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  border: 2px solid var(--glass-bg-primary);
  /* 使用新的发光动画 */
  animation: pulse-glow 2.5s infinite;
}

.meta {
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-width: 0;
}

.meta .top-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.meta .name {
  color: var(--text-color-primary);
  font-weight: 600;
  font-size: 15px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.meta .time {
  color: var(--text-color-tertiary);
  font-size: 12px;
  flex-shrink: 0;
}

.meta .last {
  color: var(--text-color-secondary);
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.empty-list-state {
  text-align: center;
  padding: 60px 20px;
  color: var(--text-color-tertiary);
}

.empty-list-state i {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.7;
}

/* --- 右键菜单和模态框样式 --- */
.context-menu {
  position: fixed;
  padding: 8px;
  z-index: 1000;
  border-radius: 12px;
  animation: fadeIn 0.1s ease;
}

.context-menu button {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 10px 16px;
  border: none;
  background: none;
  text-align: left;
  cursor: pointer;
  border-radius: 8px;
  color: var(--text-color-primary);
  transition: background 0.2s ease;
}

.context-menu button:hover {
  background-color: var(--glass-bg-secondary);
  color: var(--accent-color);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  padding: 28px;
  border-radius: 16px;
  text-align: center;
  max-width: 400px;
}

.modal-content p {
  margin: 0 0 8px;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-color-primary);
}

.modal-content span {
  color: var(--text-color-secondary);
  margin-bottom: 24px;
  display: block;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.modal-actions button {
  padding: 10px 24px;
  border-radius: 10px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-cancel {
  background-color: var(--glass-bg-tertiary);
  color: var(--text-color-secondary);
}

.btn-cancel:hover {
  background-color: var(--glass-bg-secondary);
}

.btn-confirm {
  background-color: #d93025;
  color: white;
}

.btn-confirm:hover {
  background-color: #c02820;
  transform: translateY(-2px);
}
</style>
