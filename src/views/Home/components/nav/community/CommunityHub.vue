<template>
  <HomeNavbar />
  <div class="community-hub-container">
    <!-- 1. 顶部欢迎与介绍区域 -->
    <div class="hub-header-card">
      <div class="hub-header-content">
        <i class="fas fa-university hub-main-icon"></i>
        <h1 class="hub-main-title">欢迎来到校园社区中心</h1>
        <p class="hub-main-subtitle">
          在这里，我们倡导公平、互助与信任。无论是解决交易纠纷，还是寻找心仪的物品，社区都将为你提供支持。
        </p>
      </div>
    </div>

    <!-- 2. 功能选择区域 -->
    <div class="hub-selection-grid">
      <!-- 卡片一：校园法庭 -->
      <div class="hub-feature-card" @click="navigateTo('/court')">
        <div class="hub-card-icon-wrapper court-icon-bg">
          <i class="fas fa-gavel hub-card-icon"></i>
        </div>
        <div class="hub-card-content">
          <h2 class="hub-card-title">校园法庭</h2>
          <p class="hub-card-description">
            遇到交易纠纷？别担心。在这里，每位同学都是陪审员。提交你的案件，让社区的力量为你主持公道，共同裁定真相。
          </p>
        </div>
        <button class="hub-card-button court-button">
          进入法庭 <i class="fas fa-arrow-right"></i>
        </button>
      </div>

      <!-- 卡片二：求购专区 -->
      <div class="hub-feature-card" @click="navigateTo('/community')">
        <div class="hub-card-icon-wrapper wanted-icon-bg">
          <i class="fas fa-bullhorn hub-card-icon"></i>
        </div>
        <div class="hub-card-content">
          <h2 class="hub-card-title">求购专区</h2>
          <p class="hub-card-description">
            遍寻不得的旧书，梦寐以求的游戏机？发布你的求购需求，让闲置物品找到新主人，让全校同学帮你一起寻找。
          </p>
        </div>
        <button class="hub-card-button wanted-button">
          发布求购 <i class="fas fa-arrow-right"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";

const router = useRouter();

/**
 * 导航到指定路径
 * @param {string} path - 目标路由路径
 */
const navigateTo = (path) => {
  router.push(path);
};
</script>

<style scoped>
/* * ===================================================================
 * Community Hub Component Styles
 * -------------------------------------------------------------------
 * 使用 'hub-' 前缀确保样式隔离，风格统一
 * ===================================================================
 */

/* --- 1. 基础与容器 --- */
.community-hub-container {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
  background-color: #f8f9fa; /* 更柔和的背景色 */
  min-height: 100vh;
  padding-top: 80px;
  box-sizing: border-box;
}

/* --- 2. 顶部欢迎卡片 --- */
.hub-header-card {
  max-width: 900px;
  margin: 0 auto 48px auto;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px;
  padding: 48px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
  overflow: hidden;
  position: relative;
}
/* 添加一些装饰性元素 */
.hub-header-card::before {
  content: '';
  position: absolute;
  top: -50px;
  left: -50px;
  width: 150px;
  height: 150px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  opacity: 0.5;
}
.hub-main-icon {
  font-size: 48px;
  margin-bottom: 16px;
  display: block;
}
.hub-main-title {
  font-size: 32px;
  font-weight: 700;
  margin: 0 0 12px 0;
}
.hub-main-subtitle {
  font-size: 16px;
  max-width: 600px;
  margin: 0 auto;
  opacity: 0.9;
  line-height: 1.6;
}

/* --- 3. 功能选择网格布局 --- */
.hub-selection-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 32px;
  max-width: 900px;
  margin: 0 auto;
}

/* --- 4. 功能卡片样式 --- */
.hub-feature-card {
  background-color: #ffffff;
  border-radius: 16px;
  border: 1px solid #e9ecef;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  padding: 32px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  cursor: pointer;
}
.hub-feature-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
}
.hub-card-icon-wrapper {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}
.hub-card-icon {
  font-size: 36px;
  color: white;
}
/* 不同功能的图标背景色 */
.court-icon-bg { background: linear-gradient(135deg, #007bff, #0056b3); }
.wanted-icon-bg { background: linear-gradient(135deg, #ffc107, #d39e00); }

.hub-card-content {
  flex-grow: 1; /* 让内容区占据多余空间，按钮始终在底部 */
}
.hub-card-title {
  font-size: 22px;
  font-weight: 600;
  color: #212529;
  margin: 0 0 12px 0;
}
.hub-card-description {
  font-size: 15px;
  color: #6c757d;
  line-height: 1.7;
  margin-bottom: 24px;
}
.hub-card-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 500;
  font-size: 16px;
  color: white;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  width: 80%;
  margin-top: auto; /* 将按钮推到底部 */
}
.court-button {
  background-color: #007bff;
  box-shadow: 0 4px 15px rgba(0, 123, 255, 0.2);
}
.court-button:hover {
  background-color: #0056b3;
  transform: translateY(-2px);
}
.wanted-button {
  background-color: #ffc107;
  box-shadow: 0 4px 15px rgba(255, 193, 7, 0.2);
}
.wanted-button:hover {
  background-color: #d39e00;
  transform: translateY(-2px);
}

/* --- 5. 响应式设计 --- */
@media (max-width: 768px) {
  .community-hub-container {
    padding: 24px 16px;
  }
  .hub-main-title {
    font-size: 28px;
  }
  .hub-header-card {
    padding: 32px;
  }
  .hub-selection-grid {
    gap: 24px;
  }
}
</style>
