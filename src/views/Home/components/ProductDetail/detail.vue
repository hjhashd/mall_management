<template>
  <HomeNavbar />
  <div class="product-detail-container">

    <!-- 1. 添加 :key 属性 -->
    <!-- 当路由参数 id 变化时，这个 key 会变化，强制 ProductDetail 组件重新创建和加载 -->
    <ProductDetail :key="route.params.id" @productLoaded="handleProductLoaded" />

    <!-- 切换区域 -->
    <div class="tab-switcher">
      <button
          :class="['tab-button', { active: activeTab === 'comments' }]"
          @click="activeTab = 'comments'"
      >
        商品评价
      </button>
      <button
          :class="['tab-button', { active: activeTab === 'merchant' }]"
          @click="activeTab = 'merchant'"
      >
        商家信息
      </button>
    </div>

    <!-- 根据状态显示对应组件 -->
    <div class="tab-content">
      <!-- 2. 为依赖 productId 的组件也添加 key，确保它们也能正确刷新 -->
      <CommentEntry v-if="activeTab === 'comments'" :key="`comments-${route.params.id}`" :productId="Number(route.params.id)" />
      <MerchantInfo v-if="activeTab === 'merchant'" :sellerId="sellerId" />
    </div>

    <AIRec v-if="route.params.id" :key="`airec-${route.params.id}`" :product-id="Number(route.params.id)" />
    <footer class="footer">
      <p>© 2023 家居生活馆 - 让生活更温暖舒适</p>
      <p>基于AI算法的个性化推荐系统，为您提供更贴心的购物体验</p>
    </footer>
  </div>
</template>

<script setup>
import ProductDetail from './ProductInfo.vue';
import AIRec from './AIRec.vue';
import MerchantInfo from './MerchantInfo.vue';
import CommentEntry from './CommentEntry.vue';
// 3. 引入 watch
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";

// 获取路由参数
const route = useRoute();

// 定义一个 ref 来存储从子组件获取的 sellerId
const sellerId = ref(null);

// 定义一个方法来处理子组件传递过来的事件和数据
const handleProductLoaded = (id) => {
  console.log('从 ProductInfo 组件获取到的 Seller ID:', id);
  sellerId.value = id;
};

// 添加响应式状态控制显示哪个组件
const activeTab = ref('comments'); // 默认显示商品评价

// 4. 监听路由参数的变化
watch(
    () => route.params.id,
    (newId, oldId) => {
      // 当从一个商品详情页跳转到另一个时，确保页面滚动到顶部
      if (newId !== oldId && typeof window !== 'undefined') {
        window.scrollTo(0, 0);
      }
    }
);
</script>

<style>
/* 样式部分保持不变 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

:root {
  --primary: #FF6B6B;
  --secondary: #4ECDC4;
  --accent: #FFD166;
  --light: #FFF5E4;
  --dark: #333333;
  --gray: #888888;
  --light-gray: #F5F5F5;
  --border-radius: 12px;
  --box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
}

body {
  font-family: 'Noto Sans SC', sans-serif;
  background-color: #FFFCF5;
  color: var(--dark);
  line-height: 1.6;
  background-image: linear-gradient(to bottom, #fffcf5, #fffaf0);
}

.product-detail-container {
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 90px;
}

.tab-switcher {
  display: flex;
  margin: 30px 0;
  border-bottom: 2px solid var(--light-gray);
}

.tab-button {
  padding: 12px 24px;
  background: none;
  border: none;
  font-size: 18px;
  font-weight: 500;
  color: var(--gray);
  cursor: pointer;
  position: relative;
  transition: color 0.3s ease;
}

.tab-button:hover {
  color: var(--dark);
}

.tab-button.active {
  color: var(--primary);
}

.tab-button.active::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 100%;
  height: 3px;
  background-color: var(--primary);
  border-radius: 3px;
}

.tab-content {
  min-height: 300px; /* 确保切换时布局稳定 */
}

.footer {
  text-align: center;
  padding: 40px 0;
  color: var(--gray);
  margin-top: 60px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}
</style>
