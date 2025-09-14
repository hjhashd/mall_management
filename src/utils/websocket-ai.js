import { useUserStore } from '@/stores/userStore';

let webSocket = null;
let messageHandlers = new Map();

// 用于处理竞态条件：存储正在进行的连接Promise
let connectionPromise = null;

export function connect(options = {}) {
    // 如果已有连接正在进行或已完成，直接返回该Promise
    if (connectionPromise) {
        return connectionPromise;
    }

    connectionPromise = new Promise((resolve, reject) => {
        // 如果WebSocket已经处于打开状态，直接成功返回
        if (webSocket && webSocket.readyState === WebSocket.OPEN) {
            return resolve(webSocket);
        }

        if (webSocket && webSocket.readyState === WebSocket.CONNECTING) {
            console.log("WebSocket is already connecting.");
            return;
        }


        const {
            // 【修改】将默认 URL 改为和 App.vue 一样的绝对路径
            url = 'ws://localhost:8080/ws-chat',
            onOpen = () => {},
            onClose = () => {},
            onError = (error) => console.error('AI Chat WebSocket error:', error),
            params = {}
        } = options;

        const userStore = useUserStore();
        const token = userStore.token;

        if (!token || token === 'null' || token === 'undefined') {
            const error = new Error('User is not logged in or token is missing.');
            onError(error);
            connectionPromise = null; // 重置Promise
            return reject(error);
        }

        const queryParams = new URLSearchParams();
        if (userStore.userInfo && userStore.userInfo.userId) {
            queryParams.append('userId', userStore.userInfo.userId);
        }


        Object.keys(params).forEach(key => {
            if (params[key] !== null && params[key] !== undefined) {
                queryParams.append(key, params[key]);
            }
        });

        // 【修改】由于 url 已经是绝对路径，直接拼接参数即可
        const fullUrl = `${url}?${queryParams.toString()}`;
        console.log(`Connecting to WebSocket: ${fullUrl}`); // 添加日志方便调试

        try {
            webSocket = new WebSocket(fullUrl);

            const connectionTimeout = setTimeout(() => {
                if (webSocket.readyState !== WebSocket.OPEN) {
                    const error = new Error('WebSocket connection timeout.');
                    webSocket.close(); // 确保关闭
                    onError(error);
                    connectionPromise = null; // 重置Promise
                    reject(error);
                }
            }, 10000);

            webSocket.onopen = (event) => {
                clearTimeout(connectionTimeout);
                console.log('AI Chat WebSocket connected.');
                onOpen(event);
                resolve(webSocket);
            };

            webSocket.onmessage = (event) => {
                try {
                    const message = JSON.parse(event.data);
                    if (message.type && messageHandlers.has(message.type)) {
                        messageHandlers.get(message.type).forEach(handler => handler(message));
                    }
                } catch (e) {
                    console.error('Failed to parse incoming message:', event.data, e);
                }
            };

            webSocket.onclose = (event) => {
                clearTimeout(connectionTimeout);
                console.log('AI Chat WebSocket disconnected.');
                webSocket = null;
                connectionPromise = null; // 连接关闭后，允许重新连接
                onClose(event);
            };

            webSocket.onerror = (event) => {
                clearTimeout(connectionTimeout);
                onError(event);
                connectionPromise = null; // 重置Promise
                reject(new Error('WebSocket error occurred.'));
            };

        } catch (error) {
            onError(error);
            connectionPromise = null; // 重置Promise
            reject(error);
        }
    });

    return connectionPromise;
}

/**
 * Disconnects the WebSocket connection.
 */
export function disconnect() {
    if (webSocket) {
        webSocket.close(1000, 'User disconnected');
        // onclose事件处理器会自动将 webSocket 和 connectionPromise 置为 null
    }
}

/**
 * Sends a message through the WebSocket.
 * @param {object} payload - The data to send.
 */
export function sendMessage(payload) {
    if (webSocket && webSocket.readyState === WebSocket.OPEN) {
        webSocket.send(JSON.stringify(payload));
    } else {
        console.error('WebSocket is not connected.');
    }
}

/**
 * Registers a callback for a specific message type.
 * @param {string} messageType - The type of message to listen for.
 * @param {Function} callback - The function to call when a message of that type is received.
 * @returns {Function} An unsubscribe function to remove the listener.
 */
export function onMessage(messageType, callback) {
    if (!messageHandlers.has(messageType)) {
        messageHandlers.set(messageType, []);
    }
    messageHandlers.get(messageType).push(callback);

    // Return an unsubscribe function
    return () => {
        const handlers = messageHandlers.get(messageType);
        if (handlers) {
            const index = handlers.indexOf(callback);
            if (index > -1) {
                handlers.splice(index, 1);
            }
        }
    };
}

const wsChat = {
    connect,
    disconnect,
    sendMessage,
    onMessage,
    get isConnected() {
        return webSocket && webSocket.readyState === WebSocket.OPEN;
    }
};

export default wsChat;

