import { useUserStore } from '@/stores/userStore';

// 使用模块级变量来管理状态
let webSocket = null;
let isConnected = false;
let messageHandlers = new Map();
let messageId = 0;
let reconnectAttempts = 0;
const maxReconnectAttempts = 5;
let reconnectTimer = null;
let connectionOptions = {};

// 连接函数
export function connect(options = {}) {
    return new Promise((resolve, reject) => {
        const {
            url = '/ws',
            onConnect = () => {},
            onDisconnect = () => {},
            onError = (error) => console.error('WebSocket error:', error),
            reconnectDelay = 5000
        } = options;

        // 保存选项用于重连
        connectionOptions = options;

        try {
            const userStore = useUserStore();

            if (!userStore.hydrated) {
                userStore.restoreFromStorage();
            }

            const token = userStore.token;

            if (!token || token === 'null' || token === 'undefined') {
                const error = new Error('No authentication token available');
                onError(error);
                reject(error);
                return;
            }

            // 如果已有连接，先关闭
            if (webSocket) {
                disconnect();
            }

            webSocket = new WebSocket(`${url}?userId=${useUserStore().userInfo?.userId}`);

            // 设置连接超时
            const connectionTimeout = setTimeout(() => {
                if (webSocket && webSocket.readyState !== WebSocket.OPEN) {
                    const error = new Error('WebSocket connection timeout');
                    onError(error);
                    webSocket.close();
                    reject(error);
                }
            }, 10000);

            // 设置 WebSocket 事件处理
            webSocket.onopen = (event) => {
                clearTimeout(connectionTimeout);
                console.log('WebSocket connected:', event);
                isConnected = true;
                reconnectAttempts = 0; // 重置重连计数

                onConnect(event);
                resolve(webSocket);
            };

            webSocket.onmessage = (event) => {
                try {
                    const message = JSON.parse(event.data);
                    console.log('WebSocket message received:', message);

                    // 根据消息类型分发处理
                    if (message.type && messageHandlers.has(message.type)) {
                        const handlers = messageHandlers.get(message.type);
                        handlers.forEach(handler => handler(message));
                    }

                    // 通用消息处理
                    if (messageHandlers.has('ALL')) {
                        const handlers = messageHandlers.get('ALL');
                        handlers.forEach(handler => handler(message));
                    }
                } catch (parseError) {
                    console.error('Failed to parse message:', event.data, parseError);
                    // 直接传递原始数据
                    if (messageHandlers.has('RAW')) {
                        const handlers = messageHandlers.get('RAW');
                        handlers.forEach(handler => handler(event.data));
                    }
                }
            };

            webSocket.onclose = (event) => {
                clearTimeout(connectionTimeout);
                console.log('WebSocket disconnected:', event);
                isConnected = false;
                onDisconnect(event);

                // 如果不是正常关闭，尝试重连
                if (event.code !== 1000 && reconnectAttempts < maxReconnectAttempts) {
                    attemptReconnect();
                }
            };

            webSocket.onerror = (event) => {
                clearTimeout(connectionTimeout);
                console.error('WebSocket error:', event);
                onError(event);
            };

        } catch (error) {
            console.error('Failed to create WebSocket connection:', error);
            onError(error);
            reject(error);
        }
    });
}

// 重连函数
function attemptReconnect() {
    if (reconnectTimer) {
        clearTimeout(reconnectTimer);
    }

    reconnectTimer = setTimeout(() => {
        reconnectAttempts++;
        console.log(`Attempting to reconnect... (${reconnectAttempts}/${maxReconnectAttempts})`);
        connect(connectionOptions);
    }, connectionOptions.reconnectDelay || 5000);
}
// 检查连接状态
export function isConnectedStatus() {
    return isConnected && webSocket && webSocket.readyState === WebSocket.OPEN;
}

// 发送消息
export function sendMessage(type, payload, options = {}) {
    if (!isConnectedStatus()) {
        throw new Error('WebSocket is not connected. Please connect first.');
    }

    try {
        const message = {
            id: ++messageId,
            type: type,
            timestamp: Date.now(),
            data: payload,
            ...options
        };

        webSocket.send(JSON.stringify(message));
        console.log(`Message sent:`, message);
        return messageId;
    } catch (error) {
        console.error('Failed to send message:', error);
        throw error;
    }
}

// 监听消息
export function onMessage(messageType, callback) {
    if (!messageHandlers.has(messageType)) {
        messageHandlers.set(messageType, []);
    }

    const handlers = messageHandlers.get(messageType);
    handlers.push(callback);

    // 返回取消监听的函数
    return () => {
        const index = handlers.indexOf(callback);
        if (index > -1) {
            handlers.splice(index, 1);
        }
    };
}

// 监听所有消息
export function onAnyMessage(callback) {
    return onMessage('ALL', callback);
}

// 监听原始消息
export function onRawMessage(callback) {
    return onMessage('RAW', callback);
}

// 断开连接
export function disconnect(callback = () => {}) {
    if (reconnectTimer) {
        clearTimeout(reconnectTimer);
        reconnectTimer = null;
    }

    if (webSocket) {
        try {
            webSocket.close(1000, 'Normal closure');
            webSocket = null;
            isConnected = false;
            messageHandlers.clear();
            console.log('WebSocket disconnected');
            callback();
        } catch (error) {
            console.error('Error during disconnection:', error);
            callback(error);
        }
    } else {
        callback();
    }
}

// 获取 WebSocket 实例
export function getClient() {
    return webSocket;
}

// 获取连接状态
export function getConnectionStatus() {
    if (!webSocket) return 'disconnected';
    switch (webSocket.readyState) {
        case WebSocket.CONNECTING: return 'connecting';
        case WebSocket.OPEN: return 'connected';
        case WebSocket.CLOSING: return 'closing';
        case WebSocket.CLOSED: return 'disconnected';
        default: return 'unknown';
    }
}

// 默认导出
export default {
    connect,
    disconnect,
    sendMessage,
    onMessage,
    onAnyMessage,
    onRawMessage,
    isConnected: isConnectedStatus,
    getConnectionStatus,
    getClient
};
