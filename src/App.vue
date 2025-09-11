<template>
  <router-view />
</template>

<script setup>
import {onMounted, watch} from 'vue';
import {useUserStore} from '@/stores/userStore';
import {useChatStore} from '@/stores/chatStore';
import {useCartStore} from '@/stores/cartStore';
import {useNotificationStore} from '@/stores/notificationStore';
import {useMessageStore} from '@/stores/messageStore';
import ws from '@/utils/websocket';
import {useRouter} from 'vue-router';

const userStore = useUserStore();
const chatStore = useChatStore();
const cartStore = useCartStore();
const notificationStore = useNotificationStore();
const messageStore = useMessageStore();
const router = useRouter();

router.beforeEach((to, from) => {
  if (from.path.startsWith('/chat') && !to.path.startsWith('/chat')) {
    chatStore.setActiveChatId(null);
  }
});

watch(() => userStore.token, (newToken, oldToken) => {
  if (newToken) {
    if (ws.isConnected()) {
      console.log('WebSocket is already connected.');
      return;
    }
    ws.connect({
      url: 'ws://localhost:8080/ws',
      onConnect: () => {
        console.log('全局WebSocket连接成功');

        ws.onMessage('ALL', (msg) => {
          if (!msg || !msg.data) {
            console.warn('Received an invalid WebSocket message:', msg);
            return;
          }

          const messageType = msg.type;
          const messageData = msg.data;

          if (messageType === 'NEW_MESSAGE') {
            console.log('接收到新的系统消息:', messageData);
            messageStore.handleNewMessage(messageData);
          } else if (messageType === 'CHAT_MESSAGE') {
            chatStore.handleIncomingMessage(messageData);
          } else if (messageType === 'USER_STATUS_UPDATE') {
            chatStore.setUserStatus(messageData.userId, messageData.isOnline);
          }
          // --- [核心修改] 统一处理所有来自后端的系统通知 ---
          else if ([
            'ORDER_SHIPPED',
            'AFTER_SALE_PROCESSED',
            'AFTER_SALE_APPLICATION',
            'ADMIN_JUDGMENT',
            'NEW_FOLLOWER',
            'PENDING_SHIPMENT_REMINDER' //  <-- 【核心新增】添加新的通知类型
          ].includes(messageType)) {
            console.log(`接收到系统通知 (${messageType}):`, messageData);
            // 假设 messageData 是后端存入数据库后，返回的完整通知对象
            notificationStore.addNotification(messageData);
          }
          // ---
          else if (messageType === 'ADMIN_MESSAGE_UPDATE') {
            console.log('接收到后台消息更新通知:', messageData);
            notificationStore.setNewAdminMessage(messageData);
          }
        });
      },
      onError: (error) => console.error('全局WebSocket连接失败:', error),
    });

    chatStore.fetchConversations();
    notificationStore.fetchUnreadNotifications();
    messageStore.fetchMessages();
    cartStore.fetchCartSummary();

  } else if (oldToken && !newToken) {
    console.log('检测到用户登出，断开WebSocket连接。');
    ws.disconnect();
  }
}, {immediate: true});

onMounted(() => {
  if (!userStore.hydrated) {
    userStore.restoreFromStorage();
  }
  if (userStore.token) {
    cartStore.fetchCartSummary();
  }
});
</script>
