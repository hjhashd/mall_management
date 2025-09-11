import request from '@/utils/request'
import { useUserStore } from '@/stores/userStore'

// 提取到公共工具文件或确保两个文件中的实现一致
  function isValidToken(token) {
  if (!token) return false
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    const currentTime = Math.floor(Date.now() / 1000)
    return payload.exp > currentTime
  } catch (e) {
    return false
  }
}

function getToken() {
  return (
      localStorage.getItem('authToken') ||
      sessionStorage.getItem('authToken') ||
      null
  )
}

function getCurrentUserId() {
  try {
    const stored = localStorage.getItem('userInfo') || sessionStorage.getItem('userInfo')
    if (stored) {
      const u = JSON.parse(stored)
      return u.user_id || u.id || u.userId || 1
    }
  } catch {}
  return 1
}

async function getUserChats() {
  try {
    const res = await request.get('/chat/chats')
    // 返回 data 字段
    return res.data.data || res.data
  } catch (e) {
    if (e.response && e.response.status === 401) {
      const token = getToken()
      if (token && isValidToken(token)) {
        console.warn('API endpoint returned 401 but token is valid - endpoint may not be implemented')
      } else {
        const userStore = useUserStore()
        userStore.logout()
        if (window.location.pathname !== '/login') {
          window.location.href = '/login'
        }
        throw e
      }
    }
    console.warn('API request failed, using mock data:', e.message)
    const current = getCurrentUserId()
    return mock.chats(current)
  }
}

/**
 * 上传文件
 * @param {File} file - 要上传的文件对象
 * @returns {Promise<string>} - 返回上传成功后的永久URL
 */
export async function uploadImage(file) {
  const formData = new FormData();
  formData.append('file', file);

  try {
    const res = await request.post('/v1/upload/image', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data.url;
  } catch (error) {
    console.error('Image upload failed:', error);
    throw error;
  }
}

async function getChatMessages(chatId) {
  try {
    const res = await request.get(`/chat/chats/${chatId}/messages`)
    return res.data.data || res.data
  } catch (e) {
    console.error(`获取会话 ${chatId} 的消息失败:`, e);
    throw e;
  }
}

async function sendMessage({ chatId, content, messageType = 1, attachmentUrl = null }) {
  try {
    const res = await request.post('/chat/messages', {
      chatId: chatId,
      content,
      messageType,
      attachmentUrl
    })
    return res.data.data || res.data
  } catch (e) {
    console.error('发送消息失败:', e);
    throw e;
  }
}

async function markAsRead(chatId) {
  try {
    // 使用 POST 请求更符合 RESTful 风格，表示一种操作
    await request.post(`/chat/chats/${chatId}/read`)
  } catch (e) {
    console.error(`标记会话 ${chatId} 为已读失败:`, e);
    // 标记已读失败通常不需要阻塞用户，所以可以不抛出错误
  }
}

async function deleteMessage(messageId) {
  try {
    const res = await request.delete(`/chat/messages/${messageId}`);
    return res.data;
  } catch (error) {
    console.error('删除消息失败:', error);
    throw error;
  }
}

async function deleteChat(chatId) {
  try {
    const res = await request.delete(`/chat/chats/${chatId}`);
    return res.data;
  } catch (error) {
    console.error('删除会话失败:', error);
    throw error;
  }
}

async function findOrCreateChat(peerId) {
  try {
    const res = await request.post('/chat/chats/find-or-create', { peerId });
    return res.data.data || res.data;
  } catch (error) {
    console.error('查找或创建会话失败:', error);
    throw error;
  }
}

export default {
  getUserChats,
  getChatMessages,
  sendMessage,
  markAsRead,
  deleteMessage,
  deleteChat,
  findOrCreateChat
}
