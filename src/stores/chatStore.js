import { defineStore } from 'pinia';
import { useUserStore } from './userStore';
import chatApi from '@/api/chat';

export const useChatStore = defineStore('chat', {
    state: () => ({
        conversations: [],
        loading: false,
        activeChatId: null,
        // key是userId，value是布尔值 (true: online, false: offline)
        onlineStatus: {},
    }),

    actions: {
        async fetchConversations() {
            this.loading = true;
            try {
                // 因为 api/chat.js 已经解包，这里直接拿到 conversationsArray
                const conversationsArray = await chatApi.getUserChats();
                if (Array.isArray(conversationsArray)) {
                    this.conversations = conversationsArray; // 后端已经排序，可以直接赋值
                } else {
                    this.conversations = [];
                }
            } catch (error) {
                console.error('获取会话列表失败:', error);
                this.conversations = [];
            } finally {
                this.loading = false;
            }
        },

        handleIncomingMessage(newMessage) {
            const userStore = useUserStore();
            const currentUserId = userStore.userInfo?.userId || userStore.userInfo?.id;
            const chatIndex = this.conversations.findIndex(c => c.chatId === newMessage.chatId);

            if (chatIndex !== -1) {
                const chat = this.conversations[chatIndex];

                // 完整覆盖消息类型
                if (newMessage.messageType === 2) {
                    chat.lastMessage = '[图片]';
                } else if (newMessage.messageType === 3) {
                    chat.lastMessage = '[商品卡片]';
                } else {
                    chat.lastMessage = newMessage.content;
                }

                chat.lastMessageTime = newMessage.createdAt;

                // 使用后端提供的单一 unreadCount 字段
                if (newMessage.senderId !== currentUserId && this.activeChatId !== newMessage.chatId) {
                    chat.unreadCount = (chat.unreadCount || 0) + 1;
                }

                this.conversations.splice(chatIndex, 1);
                this.conversations.unshift(chat);
            } else {
                this.fetchConversations();
            }
        },

        async markChatAsRead(chatId) {
            if (!chatId) return;

            const chat = this.conversations.find(c => c.chatId === chatId);
            if (chat && chat.unreadCount > 0) {
                chat.unreadCount = 0; // 前端立即更新UI
                try {
                    await chatApi.markAsRead(chatId);
                } catch (error) {
                    console.error(`标记已读失败 (chatId: ${chatId}):`, error);
                }
            }
        },

        setActiveChatId(chatId) {
            this.activeChatId = chatId;
            if (chatId) {
                this.markChatAsRead(chatId);
            }
        },

        addConversation(chat) {
            const existingIndex = this.conversations.findIndex(c => c.chatId === chat.chatId);
            if (existingIndex > -1) {
                this.conversations.splice(existingIndex, 1);
            }
            this.conversations.unshift(chat);
        },

        // --- 新增：一个 action 用来更新用户的在线状态 ---
        setUserStatus(userId, isOnline) {
            this.onlineStatus[userId] = isOnline;
        },
    },

    getters: {
        // --- 新增：一个 getter 用来方便地检查某个用户是否在线 ---
        isUserOnline: (state) => {
            return (userId) => !!state.onlineStatus[userId];
        },
    },
});
