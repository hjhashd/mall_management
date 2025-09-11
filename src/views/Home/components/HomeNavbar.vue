<template>
  <nav class="simplified-navbar fixed-top" :class="{ 'scrolled': scrolled, 'hidden': isNavbarHidden }">
    <div class="container">
      <div class="navbar-content">
        <router-link to="/" class="brand-logo">
          <div class="logo-icon">
            <i class="fas fa-leaf"></i>
          </div>
          <span class="brand-name">循环集市</span>
        </router-link>

        <button class="mobile-toggle" @click="toggleNavbar" :class="{ 'active': navbarExpanded }">
          <span></span>
          <span></span>
          <span></span>
        </button>

        <div class="navbar-menu" :class="{ 'expanded': navbarExpanded }">
          <ul class="nav-links">
            <li v-for="item in navItems" :key="item.path" class="nav-item">
              <router-link :to="item.path" class="nav-link" :class="{ 'active': isActive(item.path) }">
                {{ item.title }}
              </router-link>
            </li>
          </ul>

          <div class="navbar-actions">
            <!-- 购物车 -->
            <router-link to="/cart" class="action-icon cart-icon">
              <i class="fas fa-shopping-cart"></i>
              <span class="cart-badge" v-if="cartStore.totalQuantity > 0">
                {{ cartStore.totalQuantity }}
              </span>
            </router-link>

            <!-- 消息通知中心 -->
            <div class="notification-wrapper">
              <button class="action-icon" @click="toggleNotificationDropdown" :class="{ 'active': showNotificationDropdown }">
                <i class="fas fa-bell"></i>
                <span v-if="totalUnreadCount > 0" class="notification-badge">{{ totalUnreadCount }}</span>
              </button>

              <div class="notification-dropdown" :class="{ 'show': showNotificationDropdown }">
                <div class="notification-header">
                  <h6>消息通知</h6>
                  <span class="notification-count">{{ totalUnreadCount }}条未读</span>
                </div>
                <div class="notification-list">
                  <!-- 使用 allUnreadItems 渲染列表 -->
                  <template v-if="allUnreadItems.length > 0">
                    <div
                        v-for="item in allUnreadItems"
                        :key="item.id"
                        class="notification-item"
                        :class="{ 'unread': item.isUnread }"
                        @click="item.action"
                    >
                      <div class="notification-icon" :class="item.iconClass">
                        <i :class="item.icon"></i>
                      </div>
                      <div class="notification-content">
                        <div class="notification-title">{{ item.title }}</div>
                        <div class="notification-desc">{{ item.description }}</div>
                        <div class="notification-time">{{ item.time }}</div>
                      </div>
                      <div v-if="item.isUnread" class="unread-dot"></div>
                    </div>
                  </template>

                  <div v-else class="notification-item">
                    <div class="notification-content" style="text-align: center; color: #999;">
                      <div class="notification-desc">暂无新消息</div>
                    </div>
                  </div>
                </div>
                <div class="notification-footer" v-if="totalUnreadCount > 0">
                  <button @click="markAllAsRead" class="view-all-btn">全部标记为已读</button>
                </div>
              </div>
            </div>

            <!-- 用户区域 -->
            <div class="user-wrapper">
              <div v-if="!isLoggedIn" class="auth-buttons">
                <router-link to="/login" class="btn-login">登录</router-link>
                <router-link to="/register" class="btn-register">注册</router-link>
              </div>
              <div v-else class="user-menu">
                <button class="user-btn" @click="toggleUserDropdown" :class="{ 'active': showUserDropdown }">
                  <div class="user-avatar">
                    <img v-if="userInfo?.avatarPath" :src="userInfo.avatarPath" alt="用户头像">
                    <span v-else>{{ userName.slice(0, 1) }}</span>
                  </div>
                </button>
                <div class="user-dropdown" :class="{ 'show': showUserDropdown }">
                  <div class="user-profile">
                    <div class="profile-avatar">
                      <img v-if="userInfo?.avatarPath" :src="userInfo.avatarPath" alt="用户头像">
                      <span v-else>{{ userName.slice(0, 1) }}</span>
                    </div>
                    <div class="profile-info">
                      <div class="profile-name">{{ userName }}</div>
                      <div class="profile-role">{{ isAdmin ? '管理员' : '用户' }}</div>
                    </div>
                  </div>
                  <div class="dropdown-menu-list">
                    <router-link to="/favorite" class="dropdown-item">
                      <i class="fas fa-book"></i>
                      <span>收藏</span>
                    </router-link>
                    <template v-if="isAdmin">
                      <div class="dropdown-divider"></div>
                      <router-link to="/admin" class="dropdown-item">
                        <i class="fas fa-cog"></i>
                        <span>系统管理</span>
                      </router-link>
                    </template>
                    <div class="dropdown-divider"></div>
                    <button @click="logout" class="dropdown-item logout-item">
                      <i class="fas fa-sign-out-alt"></i>
                      <span>退出登录</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <NotificationDetailModal
      :visible="isModalVisible"
      :notification="selectedNotification"
      @close="closeModal"
  />

  <MessageDetailModal
      :visible="isMessageModalVisible"
      :message="selectedMessage"
      @close="closeMessageModal"
  />
</template>

<script setup>
import {ref, onMounted, onUnmounted, computed} from 'vue'
import {useUserStore} from '@/stores/userStore'
import {useCartStore} from '@/stores/cartStore'
import {useChatStore} from '@/stores/chatStore'
import {useNotificationStore} from '@/stores/notificationStore'
import {storeToRefs} from 'pinia'
import {message} from 'ant-design-vue'
import {useRouter} from 'vue-router'
import NotificationDetailModal from './NotificationDetailModal.vue'
import { useMessageStore } from '@/stores/messageStore';
import MessageDetailModal from './MessageDetailModal.vue';

const userStore = useUserStore()
const cartStore = useCartStore()
const chatStore = useChatStore()
const notificationStore = useNotificationStore()
const messageStore = useMessageStore();
const router = useRouter()

const {isLoggedIn: storeLoggedIn, userInfo, isAdmin} = storeToRefs(userStore)
const currentUserId = computed(() => userInfo.value?.userId || userInfo.value?.id || null)
const isLoggedIn = computed(() => storeLoggedIn.value)
const userName = computed(() => userInfo.value?.username || '未登录')

// ====================================================
// ============ 模态框相关状态 ============
// ====================================================
const isModalVisible = ref(false)
const selectedNotification = ref(null)

const handleSystemNotificationClick = (notification) => {
  selectedNotification.value = notification;
  isModalVisible.value = true;
  showNotificationDropdown.value = false;

  if (notification.notificationId && notification.unread) {
    notificationStore.markAsRead(notification.notificationId);
  }
}

const closeModal = () => {
  isModalVisible.value = false;
  selectedNotification.value = null;
}

const isMessageModalVisible = ref(false);
const selectedMessage = ref(null);

const handleSystemMessageClick = (message) => {
  selectedMessage.value = message;
  isMessageModalVisible.value = true;
  showNotificationDropdown.value = false;

  if (message.isUnread) {
    messageStore.markAsRead(message.messageId);
  }
};

const closeMessageModal = () => {
  isMessageModalVisible.value = false;
  selectedMessage.value = null;
};
// ====================================================

const unreadChatCount = computed(() => {
  return chatStore.conversations.reduce((total, chat) => total + (chat.unreadCount || 0), 0);
});

const totalUnreadCount = computed(() => {
  return unreadChatCount.value + notificationStore.unreadCount + messageStore.unreadCount;
})

// --- 【核心修改】只聚合所有未读的通知和消息 ---
const allUnreadItems = computed(() => {
  // 1. 聊天通知 (本身就是未读的)
  const chatNotifications = chatStore.conversations
      .filter(chat => (chat.unreadCount || 0) > 0 && chat.lastMessage)
      .map(chat => {
        const isUser1 = chat.user1Id === currentUserId.value;
        const peerName = isUser1 ? chat.user2Name : chat.user1Name;
        return {
          id: `chat-${chat.chatId}-${chat.lastMessageTime}`,
          type: 'chat',
          isUnread: true,
          icon: 'fas fa-comment',
          iconClass: 'success',
          title: peerName || '新消息',
          description: truncateMessage(chat.lastMessage),
          time: formatTime(chat.lastMessageTime),
          timestamp: new Date(chat.lastMessageTime).getTime(),
          action: () => goToChat(chat.chatId)
        };
      });

  // 2. 系统通知 (只筛选未读)
  const systemNotifications = notificationStore.notifications
      .filter(notif => notif.unread) // <-- 修改点
      .map(notif => {
        const content = notif.content || {};
        let icon = 'fas fa-info-circle';
        if (notif.type === 'order_shipped') icon = 'fas fa-truck';
        if (notif.type === 'after_sale_processed') icon = 'fas fa-undo-alt';
        if (notif.type === 'admin_judgment') icon = 'fas fa-gavel';

        return {
          id: `notif-${notif.notificationId}`,
          ...notif,
          isUnread: notif.unread,
          icon: icon,
          iconClass: 'warning',
          title: content.title || '系统通知',
          description: truncateMessage(content.message),
          time: formatTime(notif.createdAt),
          timestamp: new Date(notif.createdAt).getTime(),
          action: () => handleSystemNotificationClick(notif)
        };
      });

  // 3. 系统消息 (只筛选未读)
  const systemMessages = messageStore.messages
      .filter(msg => msg.isUnread) // <-- 修改点
      .map(msg => ({
        id: `msg-${msg.messageId}`,
        type: 'system-message',
        isUnread: msg.isUnread,
        icon: 'fas fa-bullhorn',
        iconClass: 'info',
        title: msg.title,
        description: truncateMessage(msg.content),
        time: formatTime(msg.sendTime),
        timestamp: new Date(msg.sendTime).getTime(),
        action: () => handleSystemMessageClick(msg)
      }));

  // 4. 合并并排序
  return [...chatNotifications, ...systemNotifications, ...systemMessages].sort((a, b) => b.timestamp - a.timestamp);
});

// 响应式数据
const scrolled = ref(false)
const navbarExpanded = ref(false)
const showNotificationDropdown = ref(false)
const showUserDropdown = ref(false)
const isNavbarHidden = ref(false)
let lastScrollY = 0
const hideThreshold = 100

const navItems = [
  {title: '首页', path: '/'},
  {title: '分类', path: '/search'},
  {title: '订单详情', path: '/orders'},
  {title: '社区', path: '/communityHub'},
  {title: '个人中心', path: '/user-center'}
]

// 方法
const goToChat = (chatId) => {
  router.push(`/chat?chatId=${chatId}`)
  showNotificationDropdown.value = false
}

const markAllAsRead = () => {
  chatStore.conversations.forEach(chat => {
    if (chat.unreadCount > 0) {
      chatStore.markChatAsRead(chat.chatId);
    }
  });
  notificationStore.markAllAsRead();
  messageStore.markAllAsRead();
  showNotificationDropdown.value = false;
};

const handleScroll = () => {
  const currentScrollY = window.scrollY
  scrolled.value = currentScrollY > 50
  if (currentScrollY > hideThreshold && currentScrollY > lastScrollY) {
    isNavbarHidden.value = true
  } else if (currentScrollY < lastScrollY || currentScrollY <= hideThreshold) {
    isNavbarHidden.value = false
  }
  lastScrollY = currentScrollY
}

const isActive = (path) => router.currentRoute.value.path === path
const toggleNavbar = () => navbarExpanded.value = !navbarExpanded.value
const toggleNotificationDropdown = (e) => {
  e.stopPropagation()
  showNotificationDropdown.value = !showNotificationDropdown.value
  if (showNotificationDropdown.value) showUserDropdown.value = false
}
const toggleUserDropdown = (e) => {
  e.stopPropagation()
  showUserDropdown.value = !showUserDropdown.value
  if (showUserDropdown.value) showNotificationDropdown.value = false
}
const logout = () => {
  userStore.logout()
  showUserDropdown.value = false
  message.success('已退出登录', 3)
}
const handleClickOutside = (event) => {
  if (!event.target.closest('.notification-wrapper') &&
      !event.target.closest('.user-wrapper') &&
      (showNotificationDropdown.value || showUserDropdown.value)) {
    showNotificationDropdown.value = false
    showUserDropdown.value = false
  }
}
const truncateMessage = (content, maxLength = 25) => {
  if (!content) return ''
  return content.length > maxLength ? content.substring(0, maxLength) + '...' : content
}
const formatTime = (date) => {
  if (!date) return ''
  const now = new Date()
  const messageTime = new Date(date)
  const diffMinutes = Math.floor((now - messageTime) / (1000 * 60))
  if (diffMinutes < 1) return '刚刚'
  if (diffMinutes < 60) return `${diffMinutes}分钟前`
  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours < 24) return `${diffHours}小时前`
  const diffDays = Math.floor(diffHours / 24)
  if (diffDays < 7) return `${diffDays}天前`
  return messageTime.toLocaleDateString()
}


// 生命周期钩子
onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  document.addEventListener('click', handleClickOutside)
  if (isLoggedIn.value) {
    cartStore.fetchCartSummary()
  }
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* 你的 CSS 样式保持不变 */
.simplified-navbar {
  background: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  z-index: 1000;
  padding: 0;
}

.simplified-navbar.hidden {
  transform: translateY(-100%);
}

.simplified-navbar.scrolled {
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.navbar-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.8rem 0;
}

.brand-logo {
  display: flex;
  align-items: center;
  font-size: 1.2rem;
  font-weight: 600;
  color: #333;
  text-decoration: none;
  gap: 8px;
}

.brand-logo .logo-icon {
  font-size: 1.4rem;
  color: #4CAF50;
}

.brand-name {
  color: #333;
  font-weight: 600;
}

/* 移动端切换按钮 */
.mobile-toggle {
  display: none;
  flex-direction: column;
  justify-content: center;
  width: 30px;
  height: 30px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.mobile-toggle:hover {
  background: rgba(76, 175, 80, 0.1);
}

.mobile-toggle span {
  width: 22px;
  height: 2px;
  background: #555;
  margin: 3px 0;
  transition: all 0.3s ease;
  border-radius: 1px;
}

.mobile-toggle.active span:nth-child(1) {
  transform: rotate(45deg) translate(4px, 4px);
}

.mobile-toggle.active span:nth-child(2) {
  opacity: 0;
}

.mobile-toggle.active span:nth-child(3) {
  transform: rotate(-45deg) translate(4px, -4px);
}

/* 导航菜单 */
.navbar-menu {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex: 1;
  margin-left: 2rem;
}

.nav-links {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 1rem;
}

.nav-item {
  position: relative;
}

.nav-link {
  display: block;
  padding: 0.5rem 0.8rem;
  color: #555;
  text-decoration: none;
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
  font-size: 0.9rem;
}

.nav-link:hover,
.nav-link.active {
  color: #4CAF50;
  background: rgba(76, 175, 80, 0.08);
}

.nav-link.active::after {
  content: '';
  position: absolute;
  bottom: -3px;
  left: 50%;
  transform: translateX(-50%);
  width: 6px;
  height: 6px;
  background: #4CAF50;
  border-radius: 50%;
}

/* 右侧功能区 */
.navbar-actions {
  display: flex;
  align-items: center;
  gap: 0.8rem; /* 减小间距 */
}

/* 动作图标（购物车、消息） */
.action-icon {
  border: none; /* 移除按钮的边框 */
  outline: none; /* 去掉焦点时的边框 */
}

.action-icon:hover,
.action-icon.active {
  color: #4CAF50;
  background: rgba(76, 175, 80, 0.1); /* 更轻的背景色 */
}

.cart-badge,
.notification-badge {
  position: absolute;
  top: -1px; /* 调整位置 */
  right: -1px; /* 调整位置 */
  background: #4CAF50;
  color: white;
  font-size: 0.55rem; /* 减小字体 */
  font-weight: 600;
  padding: 0 3px; /* 减小内边距 */
  border-radius: 10px;
  min-width: 12px;
  height: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 通知中心样式 */
.notification-wrapper {
  position: relative;
}

.action-icon {
  position: relative;
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.action-icon:hover {
  background-color: #f5f5f5;
}

.notification-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #ff4757;
  color: white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  width: 320px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  display: none;
  margin-top: 8px;
}

.notification-dropdown.show {
  display: block;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #eee;
}

.notification-list {
  max-height: 300px;
  overflow-y: auto;
}

.notification-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f5f5f5;
  cursor: pointer;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background-color: #f8f9fa;
}

.notification-item.unread {
  background-color: #f0f7ff;
}

.notification-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.notification-icon.success {
  background-color: #e8f5e9;
  color: #4caf50;
}

.notification-icon.warning {
  background-color: #fff3e0;
  color: #ff9800;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-weight: 500;
  margin-bottom: 2px;
  color: #333;
}

.notification-desc {
  font-size: 13px;
  color: #555; /* 加深颜色，从 #666 改为 #555 */
  white-space: normal; /* 允许换行，避免内容被强制截断 */
  line-height: 1.4;
  /* 移除 overflow, text-overflow, 因为 truncateMessage 已经处理了截断 */
}

.notification-time {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
}

.unread-dot {
  width: 8px;
  height: 8px;
  background-color: #ff4757;
  border-radius: 50%;
  flex-shrink: 0;
  margin-left: 8px;
}

.notification-footer {
  padding: 12px 16px;
  text-align: center;
  border-top: 1px solid #eee;
}

.view-all-btn {
  background: none;
  border: none;
  color: #4a90e2;
  cursor: pointer;
  font-size: 14px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.view-all-btn:hover {
  background-color: #f0f7ff;
}

/* 用户区域样式 */
.auth-buttons {
  display: flex;
  gap: 0.4rem; /* 减小间距 */
}

.btn-login,
.btn-register {
  padding: 0.3rem 0.6rem; /* 减小内边距 */
  border-radius: 4px; /* 减小圆角 */
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
  font-size: 0.8rem; /* 减小字体 */
}

.btn-login {
  color: #555;
  border: 1px solid #e0e0e0;
  background: white;
}

.btn-login:hover {
  color: #4CAF50;
  border-color: #4CAF50;
}

.btn-register {
  color: white;
  background: #4CAF50;
  border: 1px solid transparent;
}

.btn-register:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.2);
}

.user-wrapper {
  position: relative;
}

.user-btn {
  display: flex;
  align-items: center;
  padding: 0.2rem; /* 减小内边距 */
  background: transparent;
  border: none; /* 移除边框 */
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.user-btn:hover,
.user-btn.active {
  background: rgba(76, 175, 80, 0.1);
}

.user-avatar {
  width: 28px; /* 减小尺寸 */
  height: 28px; /* 减小尺寸 */
  border-radius: 6px; /* 减小圆角 */
  background: #4CAF50;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  overflow: hidden;
  flex-shrink: 0;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.user-dropdown {
  position: absolute;
  top: calc(100% + 6px);
  right: 0;
  width: 220px; /* 减小宽度 */
  background: white;
  border-radius: 8px; /* 减小圆角 */
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); /* 更柔和的阴影 */
  opacity: 0;
  visibility: hidden;
  transform: translateY(-5px);
  transition: all 0.2s ease;
  overflow: hidden;
  z-index: 1000;
  border: 1px solid #f0f0f0; /* 更轻的边框 */
}

.user-dropdown.show {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}

.user-profile {
  padding: 0.8rem; /* 减小内边距 */
  background: #f9f9f9;
  display: flex;
  align-items: center;
  gap: 0.6rem; /* 减小间距 */
}

.profile-avatar {
  width: 36px; /* 减小尺寸 */
  height: 36px; /* 减小尺寸 */
  border-radius: 6px; /* 减小圆角 */
  background: #4CAF50;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 0.9rem; /* 减小字体 */
  overflow: hidden;
}

.profile-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-info {
  flex: 1;
}

.profile-name {
  font-weight: 600;
  color: #333;
  font-size: 0.85rem; /* 减小字体 */
  margin-bottom: 0.1rem; /* 减小间距 */
}

.profile-role {
  color: #777;
  font-size: 0.7rem; /* 减小字体 */
}

.dropdown-menu-list {
  padding: 0.3rem 0; /* 减小内边距 */
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 0.5rem; /* 减小间距 */
  padding: 0.4rem 0.8rem; /* 减小内边距 */
  color: #555;
  text-decoration: none;
  border-radius: 4px;
  transition: all 0.2s ease;
  cursor: pointer;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  font-size: 0.8rem; /* 减小字体 */
}

.dropdown-item:hover {
  background: rgba(76, 175, 80, 0.05);
  color: #4CAF50;
}

.dropdown-item i {
  width: 12px; /* 减小图标 */
  color: #999;
  transition: color 0.2s ease;
}

.dropdown-item:hover i {
  color: #4CAF50;
}

.dropdown-divider {
  height: 1px;
  background: #f0f0f0;
  margin: 0.2rem 0; /* 减小间距 */
}

.logout-item {
  color: #F44336;
}

.logout-item:hover {
  background: rgba(244, 67, 54, 0.05);
  color: #D32F2F;
}

.logout-item:hover i {
  color: #D32F2F;
}

/* 移动端响应式 */
@media (max-width: 992px) {
  .mobile-toggle {
    display: flex;
  }

  .navbar-menu {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border-radius: 0 0 8px 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    padding: 0.8rem;
    margin: 0;
    flex-direction: column;
    align-items: stretch;
    gap: 0.8rem;
    opacity: 0;
    visibility: hidden;
    transform: translateY(-10px);
    transition: all 0.3s ease;
  }

  .navbar-menu.expanded {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
  }

  .nav-links {
    flex-direction: column;
    width: 100%;
    gap: 0.5rem;
  }

  .nav-link {
    padding: 0.5rem 0.8rem;
    width: 100%;
  }

  .navbar-actions {
    flex-direction: column;
    width: 100%;
    gap: 0.6rem;
  }

  .notification-dropdown,
  .user-dropdown {
    position: static;
    width: 100%;
    margin-top: 0.3rem;
    opacity: 1;
    visibility: visible;
    transform: none;
    box-shadow: none;
    border: 1px solid #eee;
  }

  .auth-buttons {
    width: 100%;
  }

  .btn-login,
  .btn-register {
    flex: 1;
    text-align: center;
    padding: 0.4rem 0.6rem;
  }
}

/* 购物车图标样式 */
.cart-icon {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cart-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #ff4d4f;
  color: white;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  z-index: 1;
}
</style>
