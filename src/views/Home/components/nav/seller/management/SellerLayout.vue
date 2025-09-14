<template>
  <a-layout style="height: 100vh; background-color: #f8f9fa;">
    <!-- =============================================================== -->
    <!-- 左侧侧边栏 (Sidebar) -->
    <!-- =============================================================== -->
    <a-layout-sider :width="256" theme="light" class="sider-shadow">
      <!-- Logo区域 -->
      <div class="logo">
        <ShoppingCartOutlined class="logo-icon" />
        <h1 class="logo-title">卖家中心</h1>
      </div>

      <!-- 菜单导航 -->
      <a-menu
          v-model:selectedKeys="selectedKeys"
          mode="inline"
          class="custom-menu"
          @click="handleMenuClick"
      >
        <a-menu-item v-for="item in menuItems" :key="item.component">
          <template #icon>
            <component :is="item.icon" />
          </template>
          <span>{{ item.name }}</span>
        </a-menu-item>
      </a-menu>
    </a-layout-sider>

    <!-- =============================================================== -->
    <!-- 主内容区 (Main Content) -->
    <!-- =============================================================== -->
    <a-layout>
      <!-- 顶部导航栏 (Navbar) -->
      <a-layout-header class="header">
        <div class="header-left">
          <!-- 已集成：返回按钮 -->
          <a-button type="text" @click="goBack" class="back-button">
            <template #icon><ArrowLeftOutlined /></template>
            返回
          </a-button>
          <!-- 动态显示用户名 -->
          <h2 class="header-title">欢迎回来, {{ userInfo?.username || '卖家' }}!</h2>
        </div>
        <div class="header-right">
          <!-- 已集成：消息通知功能 -->
          <div class="notification-wrapper">
            <a-badge :count="totalUnreadCount" :offset="[-5, 5]">
              <a-button shape="circle" class="action-icon" @click.stop="toggleNotificationDropdown">
                <BellOutlined />
              </a-button>
            </a-badge>

            <div v-if="showNotificationDropdown" class="notification-dropdown">
              <div class="notification-header">
                <h6>消息通知</h6>
                <span class="notification-count">{{ totalUnreadCount }}条未读</span>
              </div>
              <div class="notification-list">
                <template v-if="allUnreadItems.length > 0">
                  <div
                      v-for="item in allUnreadItems"
                      :key="item.id"
                      class="notification-item"
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
                <div v-else class="notification-empty">
                  <img src="https://gw.alipayobjects.com/zos/rmsportal/sAuJeJzSKbUmHfBQRzmZ.svg" alt="no-data" />
                  <p>暂无新消息</p>
                </div>
              </div>
              <div class="notification-footer" v-if="totalUnreadCount > 0">
                <button @click="markAllAsRead" class="view-all-btn">全部标记为已读</button>
              </div>
            </div>
          </div>

          <!-- 动态显示用户头像 -->
          <a-avatar :src="userInfo?.avatarPath || 'https://placehold.co/100x100/E2E8F0/475569?text=U'" size="large"/>
          <div class="user-info">
            <!-- 动态显示用户名和角色 -->
            <div class="user-name">{{ userInfo?.username }}</div>
            <div class="user-role">{{ userRoleText }}</div>
          </div>
        </div>
      </a-layout-header>

      <!-- 页面内容 -->
      <a-layout-content class="content">
        <div class="content-wrapper">
          <component
              :is="activeComponent"
              :product-id="editingProductId"
              @add-product="showReviewForm"
              @edit-product="showReviewForm"
              @back-to-list="showProductList"
          />
        </div>
      </a-layout-content>
    </a-layout>
  </a-layout>

  <!-- =============================================================== -->
  <!-- 新增：消息详情模态框 -->
  <!-- =============================================================== -->
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
import {ref, computed, h, onMounted, onUnmounted} from 'vue';
import {useRouter} from 'vue-router';
import { useRoute } from 'vue-router';

// Ant Design Icons
import {
  ShoppingCartOutlined,
  DashboardOutlined,
  ShoppingOutlined,
  DatabaseOutlined,
  CarOutlined,
  BarChartOutlined,
  UsergroupAddOutlined,
  SettingOutlined,
  QuestionCircleOutlined,
  BellOutlined,
  ArrowLeftOutlined,
  CommentOutlined,
} from '@ant-design/icons-vue';
// Pinia Stores
import {storeToRefs} from 'pinia';
import {useUserStore} from '@/stores/userStore.js';
import {useChatStore} from '@/stores/chatStore.js';
import {useNotificationStore} from '@/stores/notificationStore.js';
import {useMessageStore} from '@/stores/messageStore.js';
// Vue Components
import Dashboard from './dashboard.vue';
import SellerOrderManagement from "@/views/Home/components/nav/seller/SellerOrderManagement.vue";
import ProductManagement from "@/views/Home/components/nav/seller/management/ProductManagement.vue";
import Review from "@/views/Home/components/nav/seller/management/Review.vue";
import HelpCenter from "@/views/Home/components/nav/seller/management/HelpCenter.vue";
import ShopSettings from "@/views/Home/components/nav/seller/management/ShopSettings.vue";
import ReviewManagement from "@/views/Home/components/nav/seller/management/ReviewManagement.vue";
import Data from "@/views/Home/components/nav/seller/management/Data.vue";
import FollowManagement from "@/views/Home/components/nav/seller/management/FollowManagement.vue";

// 新增：引入模态框组件，请确保路径正确
import NotificationDetailModal from '@/views/Home/components/NotificationDetailModal.vue';
import MessageDetailModal from '@/views/Home/components/MessageDetailModal.vue';


const router = useRouter();
const route = useRoute();

// --- 路由和基础状态 ---
const selectedKeys = ref(['Dashboard']);
const goBack = () => {
  router.back();
};

// --- 菜单数据 ---
const menuItems = ref([
  {name: '仪表盘', icon: DashboardOutlined, component: 'Dashboard'},
  {name: '订单管理', icon: ShoppingOutlined, component: 'SellerOrderManagement'},
  {name: '商品管理', icon: DatabaseOutlined, component: 'ProductManagement'},
  {name: '评价管理', icon: CommentOutlined, component: 'ReviewManagement'},
  {name: '数据分析', icon: BarChartOutlined, component: 'Data'},
  {name: '客户管理', icon: UsergroupAddOutlined, component: 'FollowManagement'},
  {name: '店铺设置', icon: SettingOutlined, component: 'ShopSettings'},
  {name: '帮助中心', icon: QuestionCircleOutlined, component: 'HelpCenter'},
]);

// --- 动态组件 ---
const components = {
  Dashboard,
  SellerOrderManagement,
  ProductManagement,
  Review,
  ReviewManagement,
  Data,
  FollowManagement,
  ShopSettings,
  HelpCenter,
};

const currentProductView = ref('list');
const editingProductId = ref(null);

const showReviewForm = (productId = null) => {
  editingProductId.value = productId;
  currentProductView.value = 'form';
};

const showProductList = () => {
  editingProductId.value = null;
  currentProductView.value = 'list';
};


const activeComponent = computed(() => {
  const mainComponentKey = selectedKeys.value[0];

  if (mainComponentKey === 'ProductManagement') {
    return currentProductView.value === 'form'
        ? components['Review']
        : components['ProductManagement'];
  }
  return components[mainComponentKey];
});

const handleMenuClick = ({key}) => {
  selectedKeys.value = [key];

  // 更新URL查询参数
  router.replace({
    query: {
      ...route.query,
      activeMenu: key
    }
  });

  if (key === 'ProductManagement' && currentProductView.value === 'form') {
    showProductList();
  }
};

// ===============================================================
// 开始：集成的消息通知逻辑
// ===============================================================
const userStore = useUserStore();
const chatStore = useChatStore();
const notificationStore = useNotificationStore();
const messageStore = useMessageStore();

const {userInfo} = storeToRefs(userStore);

const userRoleText = computed(() => {
  if (userInfo.value?.roles && Array.isArray(userInfo.value.roles)) {
    return userInfo.value.roles.map(role => {
      if (role === 'ROLE_ADMIN') return '管理员';
      if (role === 'ROLE_SELLER') return '卖家';
      return role;
    }).join(' | ');
  }
  return '用户';
});


const currentUserId = computed(() => userInfo.value?.userId || userInfo.value?.id || null);

const showNotificationDropdown = ref(false);

const unreadChatCount = computed(() => chatStore.conversations.reduce((total, chat) => total + (chat.unreadCount || 0), 0));
const totalUnreadCount = computed(() => unreadChatCount.value + notificationStore.unreadCount + messageStore.unreadCount);

// --- [新增] 模态框相关状态和方法 ---
const isModalVisible = ref(false);
const selectedNotification = ref(null);
const isMessageModalVisible = ref(false);
const selectedMessage = ref(null);

const handleSystemNotificationClick = (notification) => {
  selectedNotification.value = notification;
  isModalVisible.value = true;
  showNotificationDropdown.value = false; // 关闭下拉框

  // 标记为已读
  if (notification.notificationId && notification.unread) {
    notificationStore.markAsRead(notification.notificationId);
  }
};

const handleSystemMessageClick = (message) => {
  selectedMessage.value = message;
  isMessageModalVisible.value = true;
  showNotificationDropdown.value = false; // 关闭下拉框

  // 标记为已读
  if (message.messageId && message.isUnread) {
    messageStore.markAsRead(message.messageId);
  }
};

const closeModal = () => {
  isModalVisible.value = false;
  selectedNotification.value = null;
};

const closeMessageModal = () => {
  isMessageModalVisible.value = false;
  selectedMessage.value = null;
};
// --- [结束] 模态框相关状态和方法 ---


const allUnreadItems = computed(() => {
  const chatNotifications = chatStore.conversations
      .filter(chat => (chat.unreadCount || 0) > 0 && chat.lastMessage)
      .map(chat => {
        const isUser1 = chat.user1Id === currentUserId.value;
        const peerName = isUser1 ? chat.user2Name : chat.user1Name;
        return {
          id: `chat-${chat.chatId}-${chat.lastMessageTime}`,
          type: 'chat',
          isUnread: true,
          icon: 'fa fa-comment',
          iconClass: 'success',
          title: peerName || '新消息',
          description: truncateMessage(chat.lastMessage),
          time: formatTime(chat.lastMessageTime),
          timestamp: new Date(chat.lastMessageTime).getTime(),
          action: () => goToChat(chat.chatId)
        };
      });

  const systemNotifications = notificationStore.notifications
      .filter(notif => notif.unread)
      .map(notif => {
        const content = notif.content || {};
        let icon = 'fa fa-info-circle';
        let iconClass = 'warning';

        switch (notif.type) {
          case 'NEW_FOLLOWER':
            icon = 'fa fa-user-plus';
            iconClass = 'success';
            break;
          case 'AFTER_SALE_APPLICATION':
            icon = 'fa fa-question-circle';
            iconClass = 'danger';
            break;
        }

        return {
          id: `notif-${notif.notificationId}`,
          ...notif,
          isUnread: notif.unread,
          icon: icon,
          iconClass: iconClass,
          title: content.title || '系统通知',
          description: truncateMessage(content.message),
          time: formatTime(notif.createdAt),
          timestamp: new Date(notif.createdAt).getTime(),
          action: () => handleSystemNotificationClick(notif)
        };
      });

  const systemMessages = messageStore.messages
      .filter(msg => msg.isUnread)
      .map(msg => ({
        id: `msg-${msg.messageId}`,
        ...msg, // 包含原始消息对象的所有字段
        type: 'system-message',
        isUnread: msg.isUnread,
        icon: 'fa fa-bullhorn',
        iconClass: 'info',
        title: msg.title,
        description: truncateMessage(msg.content),
        time: formatTime(msg.sendTime),
        timestamp: new Date(msg.sendTime).getTime(),
        action: () => handleSystemMessageClick(msg)
      }));

  return [...chatNotifications, ...systemNotifications, ...systemMessages].sort((a, b) => b.timestamp - a.timestamp);
});

const toggleNotificationDropdown = () => {
  showNotificationDropdown.value = !showNotificationDropdown.value;
};

const goToChat = (chatId) => {
  router.push(`/chat?chatId=${chatId}`);
  showNotificationDropdown.value = false;
};

const markAllAsRead = () => {
  chatStore.conversations.forEach(chat => {
    if (chat.unreadCount > 0) chatStore.markChatAsRead(chat.chatId);
  });
  notificationStore.markAllAsRead();
  messageStore.markAllAsRead();
  showNotificationDropdown.value = false;
};

const truncateMessage = (content, maxLength = 25) => {
  if (!content) return '';
  return content.length > maxLength ? `${content.substring(0, maxLength)}...` : content;
};

const formatTime = (date) => {
  if (!date) return '';
  const now = new Date();
  const messageTime = new Date(date);
  const diffMinutes = Math.floor((now - messageTime) / 60000);
  if (diffMinutes < 1) return '刚刚';
  if (diffMinutes < 60) return `${diffMinutes}分钟前`;
  const diffHours = Math.floor(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours}小时前`;
  const diffDays = Math.floor(diffHours / 24);
  if (diffDays < 7) return `${diffDays}天前`;
  return messageTime.toLocaleDateString();
};

const handleClickOutside = (event) => {
  if (!event.target.closest('.notification-wrapper')) {
    showNotificationDropdown.value = false;
  }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  const activeMenu = route.query.activeMenu;
  if (activeMenu && menuItems.value.some(item => item.component === activeMenu)) {
    selectedKeys.value = [activeMenu];

    if (activeMenu === 'ProductManagement' && route.query.view === 'form') {
      const productId = route.query.productId;
      showReviewForm(productId || null);
    }
  }
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});
</script>

<style scoped>
/* =============================================================== */
/* 全局与布局优化 (Global & Layout Optimization) */
/* =============================================================== */
.sider-shadow {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  z-index: 10;
  border-right: 1px solid #f0f0f0;
}

/* =============================================================== */
/* 侧边栏样式 (Sider Styles) */
/* =============================================================== */
.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 64px;
  padding: 0 24px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 8px; /* 为菜单和Logo之间增加间距 */
}
.logo-icon {
  font-size: 28px;
  color: #4f46e5; /* 品牌主色 */
  transition: transform 0.3s ease;
}
.logo:hover .logo-icon {
  transform: rotate(-10deg);
}
.logo-title {
  margin: 0 0 0 12px;
  font-size: 20px;
  font-weight: 600;
  color: #1f2937; /* 深色文字，更有质感 */
  vertical-align: middle;
}
.custom-menu {
  border-right: 0;
  padding: 0 8px; /* 菜单项左右留出空隙 */
}
:deep(.ant-menu-item) {
  margin: 4px 0 !important;
  width: 100%;
  border-radius: 8px !important;
  transition: all 0.2s ease-in-out;
  padding-left: 16px !important;
}
:deep(.ant-menu-item .anticon) {
  font-size: 16px;
  min-width: 14px;
}
:deep(.ant-menu-item-selected) {
  background-color: #eef2ff !important; /* 柔和的选中背景色 */
  color: #4f46e5 !important; /* 品牌主色 */
  font-weight: 500;
}
:deep(.ant-menu-item-selected .anticon) {
  color: #4f46e5 !important;
}
:deep(.ant-menu-item:not(.ant-menu-item-selected):hover) {
  background-color: #f4f5f7 !important;
  color: #1f2937 !important;
}

/* =============================================================== */
/* 头部样式 (Header Styles) */
/* =============================================================== */
.header {
  background: #fff;
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e5e7eb; /* 更柔和的边框色 */
  height: 64px;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}
.back-button {
  color: #6b7280;
  font-weight: 500;
}
.back-button:hover {
  background-color: #f4f5f7 !important;
  color: #1f2937 !important;
}
.header-title {
  margin: 0;
  font-size: 20px; /* 稍大一点更醒目 */
  font-weight: 600;
  color: #111827;
}
.header-right {
  display: flex;
  align-items: center;
  gap: 20px; /* 稍微拉开间距 */
}
.action-icon {
  border: none;
  background-color: transparent;
  width: 40px;
  height: 40px;
  transition: background-color 0.2s;
}
.action-icon:hover {
  background-color: #f4f5f7;
}
.action-icon .anticon {
  font-size: 20px;
  color: #6b7280;
}
.user-info {
  line-height: 1.4;
  text-align: left;
}
.user-name {
  font-weight: 600; /* 加粗用户名 */
  color: #111827;
}
.user-role {
  font-size: 12px;
  color: #9ca3af; /* 柔和的次要文字颜色 */
}

/* =============================================================== */
/* 内容区样式 (Content Area Styles) */
/* =============================================================== */
.content {
  padding: 24px;
  margin: 0;
  background: #f8f9fa; /* 使用更柔和的背景色 */
  overflow-y: auto;
}
.content-wrapper {
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.05), 0 2px 4px -2px rgb(0 0 0 / 0.05);
  min-height: calc(100vh - 64px - 48px); /* 动态计算最小高度 */
}


/* =============================================================== */
/* 通知下拉框样式 (Notification Dropdown Styles) */
/* =============================================================== */
.notification-wrapper {
  position: relative;
}
.notification-dropdown {
  position: absolute;
  top: 55px;
  right: -10px; /* 稍微偏移，让箭头对准 */
  width: 350px; /* 适当加宽 */
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  z-index: 1000;
  border: 1px solid #f0f0f0;
  overflow: hidden; /* 配合圆角 */
}
.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #eee;
}
.notification-header h6 {
  margin: 0;
  font-weight: 600;
  color: #111827;
}
.notification-count {
  font-size: 12px;
  color: #888;
  background-color: #f4f5f7;
  padding: 2px 8px;
  border-radius: 12px;
}
.notification-list {
  max-height: 320px;
  overflow-y: auto;
}
/* 优化滚动条样式 */
.notification-list::-webkit-scrollbar {
    width: 6px;
}
.notification-list::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 6px;
}
.notification-list::-webkit-scrollbar-track {
    background: #f4f5f7;
}
.notification-item {
  display: flex;
  align-items: flex-start; /* 顶部对齐，防止内容过多时图标居中 */
  padding: 12px 16px;
  border-bottom: 1px solid #f5f5f5;
  cursor: pointer;
  transition: background-color 0.2s;
  position: relative;
}
.notification-item:last-child {
  border-bottom: none;
}
.notification-item:hover {
  background-color: #f8f9fa;
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
/* 更新图标颜色，更柔和 */
.notification-icon.success { background-color: #e0f2f1; color: #009688; }
.notification-icon.warning { background-color: #fff8e1; color: #ffab00; }
.notification-icon.info { background-color: #e3f2fd; color: #2196f3; }
.notification-icon.danger { background-color: #ffebee; color: #f44336; }
.notification-content {
  flex: 1;
  min-width: 0;
}
.notification-title {
  font-weight: 500;
  margin-bottom: 4px; /* 增加标题和描述的间距 */
  color: #333;
}
.notification-desc {
  font-size: 13px;
  color: #555;
  white-space: normal;
  line-height: 1.5;
}
.notification-time {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}
.unread-dot {
  width: 8px;
  height: 8px;
  background-color: #4f46e5; /* 使用品牌主色 */
  border-radius: 50%;
  flex-shrink: 0;
  margin-left: 8px;
  align-self: center;
}
.notification-empty {
  text-align: center;
  padding: 40px 0;
  color: #999;
}
.notification-empty img {
  width: 80px;
  height: 80px;
  margin-bottom: 16px;
}
.notification-footer {
  padding: 8px;
  text-align: center;
  border-top: 1px solid #eee;
  background-color: #f8f9fa;
}
.view-all-btn {
  background: none;
  border: none;
  color: #4f46e5;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  width: 100%;
  padding: 8px 0;
  border-radius: 8px;
  transition: background-color 0.2s;
}
.view-all-btn:hover {
  background-color: #eef2ff;
}
</style>
