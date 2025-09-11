<template>
  <section class="ai-recommendations">
    <h2 class="section-title">为您推荐</h2>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-container">
      <div class="spinner"></div>
      <p>正在为您加载个性化推荐...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <p>{{ error }}</p>
    </div>

    <!-- Content: Display recommendations if available -->
    <div v-else-if="recommendations.length > 0" class="recommendation-container">
      <!-- Add @click event to navigate to product detail page -->
      <div
          v-for="rec in recommendations"
          :key="rec.id"
          class="recommendation-card"
          @click="goToProductDetail(rec.id)"
      >
        <div v-if="rec.badge" class="rec-badge">{{ rec.badge }}</div>
        <!-- Added an error handler for images -->
        <img :src="rec.image" :alt="rec.title" class="rec-image" @error="onImageError">
        <div class="rec-content">
          <h3 class="rec-title">{{ rec.title }}</h3>
          <div class="rec-price">¥{{ rec.price }}</div>
          <div class="rec-reason">
            <span class="reason-label">推荐理由</span>
            {{ rec.reason }}
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State: Display when no recommendations are found -->
    <div v-else class="empty-container">
      <p>暂时没有找到适合您的推荐商品。</p>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
// 假设您的API请求函数在这里定义
import { getRecommendations, getSimilarProducts, getCartRecommendations } from '@/api/product';
import { useCartStore } from '@/stores/cartStore';

const props = defineProps({
  productId: {
    type: Number,
    required: true
  }
});

const recommendations = ref([]);
const isLoading = ref(true);
const error = ref(null);
const router = useRouter();
const cartStore = useCartStore();

const goToProductDetail = (productId) => {
  if (productId) {
    router.push({ name: 'ProductDetail', params: { id: productId } });
  }
};

const onImageError = (event) => {
  event.target.src = 'https://placehold.co/600x400/EEE/31343C?text=Image+Not+Found';
};

const formatProduct = (product, type) => {
  const types = {
    guess: {
      badge: '猜你喜欢',
      reason: '基于您的浏览记录，为您甄选的个性化好物。'
    },
    similar: {
      badge: '看了又看',
      reason: '与您正在查看的商品相似，发现更多可能。'
    },
    cart: {
      badge: '购物车配套',
      reason: '与您购物车中的商品搭配，让购物体验更完整。'
    }
  };

  if (!product) return null;

  return {
    id: product.id,
    title: product.title,
    price: product.price,
    image: product.image,
    badge: types[type].badge,
    reason: types[type].reason
  };
};

// --- 修改后的数据获取逻辑 ---
const fetchAiRecommendations = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    if (!cartStore.initialized) {
      await cartStore.fetchCartSummary();
    }
    const isCartEmpty = cartStore.itemCount === 0;

    // 1. 【修改】移除API调用中的所有分页参数 (如 pageSize, size)
    // 注意: 您可能也需要去 @/api/product.js 文件中修改这些函数的定义，让它们不再接收分页参数。
    const apiCalls = [
      getRecommendations(),
      getSimilarProducts(props.productId)
    ];

    if (!isCartEmpty) {
      apiCalls.push(getCartRecommendations());
    }

    const [guessRes, similarRes, cartRes] = await Promise.allSettled(apiCalls);

    const finalRecommendations = [];
    const addedIds = new Set();

    const addRecommendation = (product, type) => {
      if (product && !addedIds.has(product.id)) {
        finalRecommendations.push(formatProduct(product, type));
        addedIds.add(product.id);
      }
    }

    // 2. 【修改】简化推荐结果的处理逻辑
    // 后端现在返回的是一个最多包含一个元素的数组，所以我们直接取第一个元素 res.value.data.data[0]

    // 优先级 1: "猜你喜欢"
    if (guessRes.status === 'fulfilled' && guessRes.value?.data?.data?.[0]) {
      addRecommendation(guessRes.value.data.data[0], 'guess');
    }
    // 优先级 2: “看了又看”
    if (similarRes.status === 'fulfilled' && similarRes.value?.data?.data?.[0]) {
      addRecommendation(similarRes.value.data.data[0], 'similar');
    }
    // 优先级 3: “购物车配套”
    if (!isCartEmpty && cartRes?.status === 'fulfilled' && cartRes.value?.data?.data?.[0]) {
      addRecommendation(cartRes.value.data.data[0], 'cart');
    }

    recommendations.value = finalRecommendations;

  } catch (e) {
    console.error("加载AI推荐商品失败:", e);
    error.value = "加载推荐商品失败，请稍后再试。";
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  if (props.productId) {
    fetchAiRecommendations();
  } else {
    console.error("AI 推荐组件: 必须提供 'productId' 属性。");
    error.value = "无法加载推荐，缺少关键信息。";
    isLoading.value = false;
  }
});
</script>

<style scoped>
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

.ai-recommendations {
  margin-top: 60px;
}

.section-title {
  font-family: 'Playfair Display', serif;
  font-size: 28px;
  margin-bottom: 30px;
  position: relative;
  padding-bottom: 15px;
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

.recommendation-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 25px;
}

.recommendation-card {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  overflow: hidden;
  transition: var(--transition);
  position: relative; /* For badge positioning */
  cursor: pointer; /* Add cursor pointer to indicate it's clickable */
}

.recommendation-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
}

.rec-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.rec-content {
  padding: 20px;
}

.rec-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 10px;
}

.rec-price {
  color: var(--primary);
  font-weight: 700;
  margin-bottom: 15px;
  font-size: 18px;
}

.rec-reason {
  background: var(--light);
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
  margin-top: 15px;
  position: relative;
}

.rec-reason::before {
  content: '';
  position: absolute;
  top: -10px;
  left: 20px;
  width: 0;
  height: 0;
  border-left: 10px solid transparent;
  border-right: 10px solid transparent;
  border-bottom: 10px solid var(--light);
}

.reason-label {
  font-weight: 600;
  color: var(--secondary);
  display: block;
  margin-bottom: 5px;
}

.rec-badge {
  position: absolute;
  top: 15px;
  right: 15px;
  background: var(--secondary);
  color: white;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  z-index: 10;
}

/* New styles for loading, error, and empty states */
.loading-container, .error-container, .empty-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 250px;
  background-color: var(--light-gray);
  border-radius: var(--border-radius);
  color: var(--gray);
  font-size: 16px;
  grid-column: 1 / -1; /* Make it span all columns */
}

.error-container {
  color: var(--primary);
}

.spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border-left-color: var(--secondary);
  margin-bottom: 20px;
  animation: spin 1s ease infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@media (max-width: 900px) {
  .recommendation-container {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .recommendation-container {
    grid-template-columns: 1fr;
  }
}
</style>
