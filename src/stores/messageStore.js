import { defineStore } from 'pinia';
import { fetchUserMessages, markMessageAsRead, markAllMessagesAsRead } from '@/api/message';

export const useMessageStore = defineStore('message', {
    state: () => ({
        messages: [],
        unreadCount: 0,
    }),

    actions: {
        handleNewMessage(newMessage) {
            const exists = this.messages.some(msg => msg.messageId === newMessage.messageId);
            if (!exists) {
                this.messages.unshift({ ...newMessage, isUnread: true });
                this.unreadCount++;
            }
        },

        async fetchMessages() {
            try {
                const res = await fetchUserMessages();

                const responseData = res.data;

                if (responseData.success && responseData.data) {
                    // responseData.data 对应 UserMessagesResponseDTO
                    this.messages = responseData.data.list || [];
                    this.unreadCount = responseData.data.unreadCount || 0;
                } else {
                    console.error('获取系统消息失败:', responseData.message || '返回数据格式不正确');
                    this.messages = [];
                    this.unreadCount = 0;
                }
            } catch (error) {
                console.error('请求系统消息接口时出错:', error);
                this.messages = [];
                this.unreadCount = 0;
            }
        },

        async markAsRead(messageId) {
            const message = this.messages.find(msg => msg.messageId === messageId && msg.isUnread);
            if (message) {
                message.isUnread = false;
                this.unreadCount--;
                try {
                    await markMessageAsRead(messageId);
                } catch (error) {
                    console.error('标记消息已读失败，正在回滚状态:', error);
                    // 如果API调用失败，则回滚前端的状态
                    message.isUnread = true;
                    this.unreadCount++;
                }
            }
        },

        async markAllAsRead() {
            if (this.unreadCount === 0) return;

            const originalMessages = JSON.parse(JSON.stringify(this.messages));
            const originalUnreadCount = this.unreadCount;

            this.messages.forEach(msg => msg.isUnread = false);
            this.unreadCount = 0;

            try {
                await markAllMessagesAsRead();
            } catch (error) {
                console.error('全部标记已读失败:', error);
                this.messages = originalMessages;
                this.unreadCount = originalUnreadCount;
            }
        }
    },
});
