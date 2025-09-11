<template>
  <section class="merchant-info">
    <h2 class="section-title">商家信息</h2>
    <div class="merchant-card">
      <div class="merchant-header">
        <i class="fas fa-store merchant-icon"></i>
        <div class="merchant-details">
          <h3 class="merchant-name">{{ merchant.name }} <i v-if="merchant.verified" class="fas fa-check-circle verified-badge" title="认证商家"></i></h3>
          <div class="merchant-rating">
            <div class="stars small">
              <i v-for="n in Math.floor(merchant.rating)" :key="'star-' + n" class="fas fa-star"></i>
              <i v-if="merchant.rating % 1 !== 0" class="fas fa-star-half-alt"></i>
              <i v-for="n in (5 - Math.ceil(merchant.rating))" :key="'empty-star-' + n" class="far fa-star"></i>
            </div>
            <span class="score">{{ merchant.rating.toFixed(1) }} 分</span>
            <span class="review-count">({{ merchant.totalReviews }} 评价)</span>
          </div>
        </div>
      </div>

      <div class="merchant-meta">
        <div class="meta-item">
          <i class="fas fa-map-marker-alt"></i>
          <span>发货地：{{ merchant.location }}</span>
        </div>
        <div class="meta-item">
          <i class="fas fa-shipping-fast"></i>
          <span>平均发货：{{ merchant.avgDeliveryTime }}</span>
        </div>
        <div class="meta-item">
          <i class="fas fa-undo-alt"></i>
          <span>售后服务：{{ merchant.afterSalePolicy }}</span>
        </div>
      </div>

      <p class="merchant-description">
        {{ merchant.description }}
      </p>

      <div class="merchant-actions">
        <!-- 根据 isCurrentUserSeller 的值来决定显示哪个按钮 -->
        <template v-if="isCurrentUserSeller">
          <router-link to="/store" class="btn btn-primary small-btn">
            <i class="fas fa-edit"></i> 店铺信息
          </router-link>
          <router-link to="/seller-layout" class="btn btn-outline small-btn">
            <i class="fas fa-chart-line"></i> 查看店铺数据
          </router-link>
        </template>
        <template v-else>
          <button class="btn btn-outline small-btn">
            <i class="fas fa-comment-dots"></i> 联系商家
          </button>
          <!-- 路由链接现在会动态指向卖家的店铺页面 -->
          <router-link :to="`/store/${sellerId}`" class="btn btn-primary small-btn">
            <i class="fas fa-shopping-bag"></i> 进入店铺
          </router-link>
        </template>
      </div>
    </div>
  </section>
</template>

<script setup>
import { reactive, computed, watch } from 'vue';
import { useUserStore } from '@/stores/userStore'; // 引入你的 Pinia user store

// 1. 实例化 user store
const userStore = useUserStore();

// 2. 定义 props 来继续接收从父组件传来的 sellerId
// 这是必要的，因为本组件需要知道当前展示的是哪个卖家的信息
const props = defineProps({
  sellerId: {
    type: [Number, String],
    default: null
  }
});

// 3. 从 Pinia store 中响应式地获取当前登录用户的ID
// 假设你的 userInfo 对象中有一个 'id' 字段
const currentUserId = computed(() => userStore.userInfo?.userId);

// 4. 计算属性现在会比较 prop传入的sellerId 和 store中的currentUserId
const isCurrentUserSeller = computed(() => {
  // 确保两个ID都存在且相等
  console.log(`卖家ID: ${props.sellerId}, 当前用户ID: ${currentUserId.value}`);
  return props.sellerId && currentUserId.value && props.sellerId === currentUserId.value;
});


// 在真实场景中，你应该根据 props.sellerId 去API请求商家数据
// 这里我们依然使用静态数据作为演示
const merchant = reactive({
  id: 1001, // 假设这个商家的ID是1001
  name: '暖居生活旗舰店',
  verified: true,
  rating: 4.8,
  totalReviews: 8760,
  location: '上海市',
  avgDeliveryTime: '24小时内',
  afterSalePolicy: '7天无理由退换，1年质保',
  description: '暖居生活旗舰店专注于提供高品质家居用品，致力于打造舒适、温馨的居家环境。我们严格把控产品质量，提供优质的售后服务，让您的购物无忧。',
});

// 建议: 添加一个侦听器，当 sellerId 变化时，重新获取商家数据
watch(() => props.sellerId, (newId) => {
  if (newId) {
    console.log(`需要获取ID为 ${newId} 的商家信息`);
    // 在这里调用API获取商家数据的函数，例如: fetchMerchantData(newId);
  }
}, { immediate: true }); // immediate: true 会让侦听器在组件挂载时立即执行一次

</script>

<style scoped>
/* 样式保持不变 */
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

.merchant-info {
  margin-top: 60px; /* 与其他section保持一致的顶部外边距 */
  margin-bottom: 50px;
}

.section-title {
  font-family: 'Playfair Display', serif;
  font-size: 28px;
  margin-bottom: 30px;
  position: relative;
  padding-bottom: 15px;
  color: var(--dark);
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 3px;
  background: var(--primary);
  border-radius: 3px;
}

.merchant-card {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  padding: 30px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.merchant-header {
  display: flex;
  align-items: center;
  gap: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid var(--light-gray);
}

.merchant-icon {
  font-size: 40px;
  color: var(--primary);
}

.merchant-details {
  flex-grow: 1;
}

.merchant-name {
  font-family: 'Playfair Display', serif;
  font-size: 24px;
  font-weight: 600;
  color: var(--dark);
  margin-bottom: 5px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.verified-badge {
  color: var(--secondary); /* 认证图标的颜色 */
  font-size: 18px;
}

.merchant-rating {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--gray);
  font-size: 14px;
}

.stars.small {
  font-size: 16px; /* 商家评分星星小一点 */
  color: var(--accent);
}

.score {
  font-weight: 600;
  color: var(--dark);
}

.merchant-meta {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  font-size: 15px;
  color: #555;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--light-gray);
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.meta-item i {
  color: var(--secondary);
  font-size: 18px;
}

.merchant-description {
  color: #666;
  line-height: 1.7;
  font-size: 15px;
}

.merchant-actions {
  display: flex;
  gap: 15px;
  margin-top: 10px;
}

.small-btn {
  padding: 8px 18px; /* 按钮可以稍微小一点 */
  font-size: 15px;
}

.btn-primary {
  background: var(--primary);
  color: white;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--primary);
  color: var(--primary);
}

.btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
}

/* 响应式调整 */
@media (max-width: 600px) {
  .merchant-meta {
    grid-template-columns: 1fr;
  }
  .merchant-actions {
    flex-direction: column;
  }
}
</style>

