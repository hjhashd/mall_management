<template>
  <div class="ai-assistant-container">
    <div class="chat-header">
      <div class="header-left">
        <router-link to="/" class="back-button">
          <i class="fas fa-arrow-left"></i>
        </router-link>
        <h1 class="chat-title">AI定价助手</h1>
      </div>
      <div class="header-right">
        <button class="header-action">
          <i class="fas fa-ellipsis-v"></i>
        </button>
      </div>
    </div>

    <div class="chat-body">
      <div class="chat-messages" ref="messagesContainer">
        <!-- 系统消息 -->
        <div class="message system-message">
          <div class="message-content">
            <p>👋 你好！我是AI定价助手，可以帮你分析商品价格和市场行情。</p>
            <p>你可以这样问我：</p>
            <ul>
              <li>「这个二手笔记本电脑定价多少合适？」</li>
              <li>「我的商品如何定价才能更快卖出？」</li>
              <li>「类似商品的市场价格是多少？」</li>
            </ul>
          </div>
        </div>

        <!-- AI消息示例 -->
        <div class="message ai-message">
          <div class="avatar">
            <i class="fas fa-robot"></i>
          </div>
          <div class="message-content">
            <p>根据我的分析，类似配置的二手笔记本电脑在市场上的价格区间为2000-2500元。</p>
            <p>考虑到您的电脑使用了3年，但保养良好，建议定价在2200元左右，这样既有竞争力又能保证合理利润。</p>
          </div>
          <div class="message-time">14:25</div>
        </div>

        <!-- 用户消息示例 -->
        <div class="message user-message">
          <div class="message-content">
            <p>我有一台用了3年的联想笔记本，i5处理器，8GB内存，512GB固态硬盘，请问大概值多少钱？</p>
          </div>
          <div class="message-time">14:24</div>
        </div>
      </div>

      <div class="chat-input-area">
        <div class="input-container">
          <button class="input-action">
            <i class="fas fa-image"></i>
          </button>
          <input 
            type="text" 
            class="chat-input" 
            placeholder="输入你的问题..." 
            v-model="userInput"
            @keyup.enter="sendMessage"
          />
          <button class="send-button" @click="sendMessage">
            <i class="fas fa-paper-plane"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const userInput = ref('');
const messagesContainer = ref(null);

const sendMessage = () => {
  // 这里只是UI展示，实际逻辑需要自行实现
  if (userInput.value.trim() === '') return;
  
  // 清空输入
  userInput.value = '';
  
  // 滚动到底部
  setTimeout(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
    }
  }, 100);
};
</script>

<style scoped>
.ai-assistant-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f7faf5;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(135deg, #5c9e53 0%, #46783a 100%);
  color: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-button {
  color: white;
  font-size: 18px;
  text-decoration: none;
}

.chat-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.header-action {
  background: transparent;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.header-action:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.chat-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column-reverse;
}

.message {
  margin-bottom: 16px;
  max-width: 80%;
  position: relative;
}

.system-message {
  align-self: center;
  max-width: 90%;
  background-color: #f0f4ff;
  border-radius: 12px;
  padding: 12px 16px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
  margin-bottom: 24px;
}

.system-message .message-content {
  color: #4a5568;
}

.system-message .message-content ul {
  margin: 8px 0 0 0;
  padding-left: 20px;
}

.system-message .message-content li {
  margin-bottom: 4px;
}

.ai-message {
  align-self: flex-start;
  display: flex;
  margin-bottom: 24px;
}

.ai-message .avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #5c9e53 0%, #46783a 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.ai-message .message-content {
  background-color: white;
  border-radius: 0 12px 12px 12px;
  padding: 12px 16px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
  color: #333;
}

.user-message {
  align-self: flex-end;
  margin-bottom: 24px;
}

.user-message .message-content {
  background: linear-gradient(135deg, #5c9e53 0%, #46783a 100%);
  color: white;
  border-radius: 12px 0 12px 12px;
  padding: 12px 16px;
  box-shadow: 0 2px 6px rgba(92, 158, 83, 0.2);
}

.message-time {
  font-size: 12px;
  color: #a0aec0;
  margin-top: 4px;
  text-align: right;
}

.ai-message .message-time {
  margin-left: 48px;
}

.message-content p {
  margin: 0 0 8px 0;
}

.message-content p:last-child {
  margin-bottom: 0;
}

.chat-input-area {
  padding: 16px 20px;
  background-color: white;
  border-top: 1px solid #e2e8f0;
}

.input-container {
  display: flex;
  align-items: center;
  background-color: #f7faf5;
  border: 1px solid #d7e3d7;
  border-radius: 24px;
  padding: 8px 16px;
  transition: border-color 0.2s;
}

.input-container:focus-within {
  border-color: #5c9e53;
  box-shadow: 0 0 0 2px rgba(92, 158, 83, 0.2);
}

.input-action {
  background: transparent;
  border: none;
  color: #718096;
  font-size: 18px;
  cursor: pointer;
  padding: 4px;
  margin-right: 8px;
  transition: color 0.2s;
}

.input-action:hover {
  color: #5c9e53;
}

.chat-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 16px;
  padding: 8px 0;
  outline: none;
  color: #4a5568;
}

.send-button {
  background: linear-gradient(135deg, #5c9e53 0%, #46783a 100%);
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  margin-left: 8px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.send-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(92, 158, 83, 0.3);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .message {
    max-width: 90%;
  }
  
  .system-message {
    max-width: 100%;
  }
}
</style>