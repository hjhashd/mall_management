import request from '@/utils/request';

/**
 * 获取用户的聊天历史列表
 * @param {string} userId 用户ID
 * @param {number} limit 返回的记录数
 * @returns {Promise} an axios promise
 */
export const getHistory = (userId, limit = 20) => {
    // 使用 axios 的 params 来处理 URL 查询参数
    return request.get('/history', {
        params: {
            userId,
            limit
        }
    });
};

/**
 * 获取指定会话的详细消息记录
 * @param {string} conversationId 会话ID
 * @returns {Promise} an axios promise
 */
export const getConversation = (conversationId) => {
    return request.get(`/conversation/${conversationId}`);
};

/**
 * 删除指定的会话
 * @param {string} conversationId 会话ID
 * @returns {Promise} an axios promise
 */
export const deleteConversation = (conversationId) => {
    return request.delete(`/conversation/${conversationId}`);
};
