// src/stores/notificationStore.js
import { defineStore } from 'pinia';
// 假设你有一个API管理文件
import {
    getUnreadNotifications,
    markNotificationAsRead,
    markAllNotificationsAsRead
} from '@/api/notification';

export const useNotificationStore = defineStore('notification', {
    state: () => ({
        notifications: [],
        unreadCount: 0,
        initialized: false,
        // 【新增】用于从 App.vue 传递通知到 MessageManagement.vue
        newAdminMessage: null,
    }),

    actions: {
        // 【修改】初始化时，用从API获取的数据
        initNotifications(notifications = []) {
            this.notifications = notifications.map(n => ({
                ...n,
                // 后端返回的 is_read 是 0 或 1，我们转为布尔值
                unread: !n.isRead,
                // 确保 content 是对象
                content: typeof n.content === 'string' ? JSON.parse(n.content) : n.content,
            }));
            this.updateUnreadCount();
            this.initialized = true;
        },

        // 【新增】从后端拉取未读通知
        async fetchUnreadNotifications() {
            try {
                const response = await getUnreadNotifications();
                if (response.data.success) {
                    // 使用 initNotifications 来设置
                    this.initNotifications(response.data.data);
                }
            } catch (error) {
                console.error('获取未读通知失败:', error);
            }
        },

        // [核心修改] 收到 WebSocket 消息时调用，直接添加后端传来的完整通知对象
        addNotification(newNotification) {
            // 检查通知是否已存在，防止重复添加
            if (this.notifications.some(n => n.notificationId === newNotification.notificationId)) {
                console.log(`通知 ${newNotification.notificationId} 已存在，跳过添加。`);
                return;
            }

            // 将后端对象构造成前端需要的格式
            const formattedNotification = {
                ...newNotification,
                // 确保 unread 状态和前端保持一致
                unread: true,
                isRead: false,
                // 确保 content 是对象
                content: typeof newNotification.content === 'string'
                    ? JSON.parse(newNotification.content)
                    : newNotification.content,
            };

            this.notifications.unshift(formattedNotification);
            this.updateUnreadCount();
        },


        // 【修改】标记为已读，并调用API
        async markAsRead(notificationId) {
            const notification = this.notifications.find(n => n.notificationId === notificationId);
            if (notification && notification.unread) {
                notification.unread = false;
                this.updateUnreadCount();

                // [核心修复] 移除对 'ws-' ID的检查，因为所有通知现在都有真实的数据库ID
                try {
                    // 调用API同步到后端
                    await markNotificationAsRead(notificationId);
                } catch (error) {
                    console.error(`标记通知 ${notificationId} 为已读失败:`, error);
                    // 可选：如果API失败，可以把状态回滚
                    notification.unread = true;
                    this.updateUnreadCount();
                }
            }
        },

        // 【修改】标记所有为已读，并调用API
        async markAllAsRead() {
            // 先在前端立即更新UI
            this.notifications.forEach(n => {
                if (n.unread) {
                    n.unread = false;
                }
            });
            this.updateUnreadCount();

            try {
                // 然后调用API
                await markAllNotificationsAsRead();
            } catch (error) {
                console.error('标记所有通知为已读失败:', error);
                // 可选：失败时可以重新拉取数据以同步状态
                this.fetchUnreadNotifications();
            }
        },

        updateUnreadCount() {
            this.unreadCount = this.notifications.filter(n => n.unread).length;
        },

        // 【新增】action，由 App.vue 中的 WebSocket 监听器调用
        setNewAdminMessage(messageData) {
            this.newAdminMessage = messageData;
        },

        // 【新增】action，由 MessageManagement.vue 处理完通知后调用
        clearNewAdminMessage() {
            this.newAdminMessage = null;
        },
    }
});

