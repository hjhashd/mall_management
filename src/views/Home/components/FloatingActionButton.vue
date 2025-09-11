<template>
  <div class="floating-action-button-container">
    <div v-if="isExpanded" class="fab-menu">
      <button class="fab-menu-item" @click="goToTop">
        <i class="fas fa-rocket"></i>
        <span class="tooltip-text">返回顶部</span>
      </button>
      <router-link to="/ai-assistant" class="fab-menu-item" @click="handleAIAssistantClick">
        <i class="fas fa-robot"></i>
        <span class="tooltip-text">AI定价助手</span>
      </router-link>
      <router-link to="/cart" class="fab-menu-item" @click="handleCartClick">
        <i class="fas fa-shopping-bag"></i>
        <span class="tooltip-text">购物车</span>
      </router-link>
      <router-link to="/chat" class="fab-menu-item" @click="handleChatClick">
    <i class="fas fa-comment-dots"></i>
    <span class="tooltip-text">聊天记录</span>
  </router-link>
    </div>
    <button class="fab-main-button" @click="toggleExpand">
      <i :class="['fas', isExpanded ? 'fa-xmark' : 'fa-wand-magic-sparkles']"></i>
    </button>
  </div>
</template>

<script setup>
import {ref} from 'vue';

const isExpanded = ref(false);

const toggleExpand = () => {
  isExpanded.value = !isExpanded.value;
};

const goToTop = () => {
  window.scrollTo({top: 0, behavior: 'smooth'});
  isExpanded.value = false; // Collapse after action
};

const handleCartClick = () => {
  isExpanded.value = false; // Collapse after action
};

const handleAddressClick = () => {
  isExpanded.value = false; // Collapse after action
};

const handleAIAssistantClick = () => {
  isExpanded.value = false; // Collapse after action
};

const handleChatClick = () => {
  isExpanded.value = false; // 点击后关闭菜单
  // 你可以在这里添加聊天逻辑，例如打开聊天窗口、WebSocket 初始化等
};
</script>

<style scoped>
/* Container for the FAB */
.floating-action-button-container {
  position: fixed;
  bottom: 30px;
  right: 30px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

/* Main FAB Button */
.fab-main-button {
  background: linear-gradient(135deg, #5c9e53 0%, #46783a 100%);
  color: white;
  border: none;
  border-radius: 50%;
  width: 60px;
  height: 60px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 24px;
  cursor: pointer;
  box-shadow: 0 6px 16px rgba(92, 158, 83, 0.3);
  transition: all 0.3s ease;
  margin-top: 12px;
}

.fab-main-button:hover {
  background: linear-gradient(135deg, #46783a 0%, #3a622e 100%);
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 24px rgba(92, 158, 83, 0.4);
}

/* FAB Menu */
.fab-menu {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-bottom: 12px;
}

/* Individual Menu Item Button */
.fab-menu-item {
  background: white;
  color: #5c9e53;
  border: 2px solid #e6f0e6;
  border-radius: 50%;
  width: 52px;
  height: 52px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  text-decoration: none;
}

.fab-menu-item:hover {
  background: #f7faf5;
  color: #46783a;
  transform: translateX(-8px) scale(1.1);
  box-shadow: 0 6px 16px rgba(92, 158, 83, 0.25);
  border-color: #d7e3d7;
}

/* Tooltip for menu items */
.tooltip-text {
  visibility: hidden;
  background: linear-gradient(135deg, #3b4a30 0%, #2c3825 100%);
  color: white;
  text-align: center;
  border-radius: 25px;
  padding: 8px 16px;
  position: absolute;
  z-index: 1;
  right: 65px;
  opacity: 0;
  transition: all 0.3s ease;
  white-space: nowrap;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.fab-menu-item:hover .tooltip-text {
  visibility: visible;
  opacity: 1;
  transform: translateX(-5px);
}

/* Pulse animation for main button */
.fab-main-button::before {
  content: '';
  position: absolute;
  top: -5px;
  left: -5px;
  right: -5px;
  bottom: -5px;
  border-radius: 50%;
  background: rgba(92, 158, 83, 0.2);
  animation: pulse 2s infinite;
  z-index: -1;
}

@keyframes pulse {
  0% {
    transform: scale(0.8);
    opacity: 1;
  }
  70% {
    transform: scale(1.2);
    opacity: 0;
  }
  100% {
    transform: scale(1.2);
    opacity: 0;
  }
}

/* 更加平滑的展开动画 */
.fab-menu {
  animation: fadeInUp 0.3s ease forwards;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>