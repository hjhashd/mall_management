<template>
  <HomeNavbar />
  <div class="favorites-container">
    <!-- 装饰背景元素 -->
    <div class="decoration-bg">
      <div class="floating-circle circle-1"></div>
      <div class="floating-circle circle-2"></div>
      <div class="floating-circle circle-3"></div>
      <div class="wave-decoration"></div>
    </div>

    <!-- 主内容区 -->
    <div class="main-content">
      <FavoriteProducts
          :products="favoriteProducts"
          :total-products="totalFavorites"
          :current-page="currentPage"
          :page-size="pageSize"
          :sort-type="sortType"
          :loading="loading"
          @sort-changed="handleSortChanged"
          @page-changed="handlePageChanged"
          @unfavorite="handleUnfavorite"
      />
    </div>
  </div>
</template>

<script setup>
import {ref, onMounted} from 'vue';
import FavoriteProducts from './FavoriteProducts.vue';
import { getUserFavorites, toggleFavorite as apiToggleFavorite } from '@/api/product';
import HomeNavbar from '@/views/Home/components/HomeNavbar.vue';
// 状态管理
const favoriteProducts = ref([]);
const totalFavorites = ref(0);
const currentPage = ref(1);
const pageSize = ref(12);
const sortType = ref('newest');
const loading = ref(false);

// 将后端返回的数据映射为 ProductCard 所需结构
const mapToCardProduct = (item) => {
  const id = item.productId ?? item.id;
  const title = item.title ?? item.name ?? '';
  const currentPrice = item.currentPrice ?? item.price ?? 0;
  const originalPrice = item.originalPrice ?? item.original_price ?? null;
  const image = item.imageUrl ?? item.image ?? (item.images && item.images.length > 0 ? item.images[0].imageUrl : '');
  const location = item.location ?? item.sellerLocation ?? '';
  const createdAt = item.createdAt ?? item.created_at ?? '';

  // 计算折扣（按九折显示），如果有原价
  let discountRate = null;
  if (originalPrice && currentPrice && originalPrice > 0) {
    const rate = (currentPrice / originalPrice) * 10;
    discountRate = Number(rate.toFixed(1));
  }

  const condition = item.condition ?? 1;
  const conditionTextMap = {
    1: '全新',
    2: '几乎全新',
    3: '良好',
    4: '一般'
  };

  return {
    id,
    title,
    price: currentPrice,
    original_price: originalPrice,
    image,
    location,
    created_at: createdAt?.toString().slice(0, 10),
    discountRate,
    condition,
    conditionText: conditionTextMap[condition] ?? '全新',
    isFavorite: true
  };
};

const mapSortParam = (type) => {
  switch (type) {
    case 'price_asc': return 'priceAsc';
    case 'price_desc': return 'priceDesc';
    case 'discount': return 'discount';
    case 'newest':
    default: return 'newest';
  }
};

// 实际调用后端获取收藏列表
const fetchFavorites = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      size: pageSize.value,
      sort: mapSortParam(sortType.value)
    };
    const resp = await getUserFavorites(params);

    // 兼容多种数据结构
    const payload = resp?.data?.data ?? resp?.data ?? {};
    const items = payload.items ?? payload.records ?? payload.list ?? payload.content ?? [];
    const total = payload.total ?? payload.totalCount ?? payload.totalElements ?? items.length;

    favoriteProducts.value = Array.isArray(items) ? items.map(mapToCardProduct) : [];
    totalFavorites.value = Number.isFinite(total) ? total : (Array.isArray(items) ? items.length : 0);
  } catch (e) {
    console.error('获取收藏商品失败:', e);
    favoriteProducts.value = [];
    totalFavorites.value = 0;
  } finally {
    loading.value = false;
  }
};

// 处理排序变化
const handleSortChanged = (type) => {
  sortType.value = type;
  currentPage.value = 1;
  fetchFavorites();
};

// 处理分页变化
const handlePageChanged = (newPage) => {
  currentPage.value = newPage;
  fetchFavorites();
};

// 处理取消收藏
const handleUnfavorite = async (productId) => {
  try {
    const resp = await apiToggleFavorite(productId);
    if (resp?.data?.success) {
      // 从当前列表移除该商品
      favoriteProducts.value = favoriteProducts.value.filter(p => p.id !== productId);
      totalFavorites.value = Math.max(0, totalFavorites.value - 1);

      // 如果当前页被清空且不是第一页，回退并刷新
      if (favoriteProducts.value.length === 0 && currentPage.value > 1) {
        currentPage.value -= 1;
        fetchFavorites();
      }
    } else {
      alert('操作失败: ' + (resp?.data?.message ?? '未知错误'));
    }
  } catch (e) {
    console.error('取消收藏失败:', e);
    alert('操作失败，请稍后重试');
  }
};

// 组件挂载时加载数据
onMounted(() => {
  fetchFavorites();
});
</script>

<style scoped>
.favorites-container {
  display: flex;
  min-height: 100vh;
  background: linear-gradient(135deg, #f7faf7 0%, #e6f0e6 50%, #f0f4f0 100%);
  position: relative;
  overflow: hidden;
  padding-top: 20px;
  box-sizing: border-box;
}

/* 装饰背景 */
.decoration-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

.floating-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(92, 158, 83, 0.08);
  animation: float 8s ease-in-out infinite;
}

.circle-1 {
  top: 10%;
  left: 5%;
  width: 120px;
  height: 120px;
  animation-delay: 0s;
}

.circle-2 {
  top: 60%;
  right: 8%;
  width: 80px;
  height: 80px;
  animation-delay: 2s;
}

.circle-3 {
  bottom: 30%;
  left: 15%;
  width: 100px;
  height: 100px;
  animation-delay: 4s;
}

.wave-decoration {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 200px;
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 120'%3E%3Cpath d='M985.66,92.83C906.67,72,823.78,31,743.84,14.19c-82.26-17.34-168.06-16.33-250.45.39-57.84,11.73-114,31.07-172,41.86A600.21,600.21,0,0,1,0,27.35V120H1200V95.8C1132.19,118.92,1055.71,111.31,985.66,92.83Z' fill='%235c9e53' fill-opacity='0.1'/%3E%3C/svg%3E") no-repeat center;
  background-size: cover;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}

.main-content {
  flex: 1;
  padding: 1.5rem;
  z-index: 2;
  margin: 20px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.1);
  border: 1px solid #d7e3d7;
}

/* 响应式样式 */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
    margin: 10px;
  }
}
</style>
