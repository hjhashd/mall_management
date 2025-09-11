import request from '@/utils/request' // 确保路径正确

/**
 * 获取消息列表 (用于后台管理)
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export const fetchMessages = (params) => {
    return request.get('/messages', { params });
};

/**
 * 保存消息（创建或更新）
 * @param {Object} messageData - 消息数据
 * @returns {Promise}
 */
export const saveMessage = (messageData) => {
    return request.post('/messages', messageData);
};

/**
 * 删除消息
 * @param {number|string} id - 消息ID
 * @returns {Promise}
 */
export const deleteMessage = (id) => {
    return request.delete(`/messages/${id}`);
};

/**
 * 获取当前用户的系统消息列表
 */
export const fetchUserMessages = () => {
    return request.get('/messages/user');
};

/**
 * 将单条消息标记为已读
 * @param {number} messageId 消息ID
 */
export const markMessageAsRead = (messageId) => {
    // 【关键修正】使用模板字符串 (反引号 `) 来动态拼接URL
    return request.post(`/messages/user/${messageId}/read`);
};

/**
 * 将所有消息标记为已读
 */
export const markAllMessagesAsRead = () => {
    return request.post('/messages/user/read-all');
};
