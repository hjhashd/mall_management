<template>
  <div class="main-content">
    <!-- 顶部排序栏 -->
    <div class="sorting-section">
      <div class="sorting-header">
        <h2>我的收藏</h2>
        <p>珍藏心仪好物</p>
      </div>
      <div class="sorting-controls">
        <span class="sort-label">排序：</span>
        <div class="sort-buttons">
          <button
              v-for="sort in sortOptions"
              :key="sort.value"
              :class="{ active: sortType === sort.value }"
              @click="changeSort(sort.value)"
              class="sort-btn"
          >
            <i :class="sort.icon"></i>
            {{ sort.label }}
          </button>
        </div>
      </div>
    </div>
    <!-- 商品统计 -->
    <div class="product-stats">
      <div class="stats-item">
        <i class="fas fa-heart" style="color: #5c9e53;"></i>
        <span>共收藏 <strong>{{ totalProducts }}</strong> 件商品</span>
      </div>
      <div class="view-toggle">
        <button :class="{ active: viewMode === 'grid' }" @click="viewMode = 'grid'">
          <i class="fas fa-th"></i>
        </button>
        <button :class="{ active: viewMode === 'list' }" @click="viewMode = 'list'">
          <i class="fas fa-list"></i>
        </button>
      </div>
    </div>
    <!-- 加载状态 -->
    <div v-if="loading" class="loading-overlay">
      <div class="spinner"></div>
      <p>加载中...</p>
    </div>

    <!-- 商品列表 -->
    <div class="product-list" :class="{ 'list-view': viewMode === 'list' }">
      <ProductCard
          v-for="product in products"
          :key="product.id"
          :product="product"
          :view-mode="viewMode"
          @update:favorite="handleUnfavorite(product.id)"
      />
    </div>
    <!-- 分页控件 -->
    <div class="pagination" v-if="totalPages > 1">
      <button
          class="page-btn"
          :disabled="currentPage === 1"
          @click="changePage(currentPage - 1)"
      >
        <i class="fas fa-chevron-left"></i>
        上一页
      </button>
      <div class="page-numbers">
        <button
            v-for="(page, index) in visiblePages"
            :key="`page-${index}`"
            :class="{ active: page === currentPage }"
            @click="changePage(page)"
            class="page-number"
            v-if="page !== '...'"
        >
          {{ page }}
        </button>
        <span v-else class="ellipsis">...</span>
      </div>
      <button
          class="page-btn"
          :disabled="currentPage === totalPages"
          @click="changePage(currentPage + 1)"
      >
        下一页
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>
    <!-- 空状态 -->
    <div v-if="products.length === 0 && !loading" class="empty-state">
      <div class="empty-icon">
        <i class="fas fa-heart-broken" style="color: #5c9e53;"></i>
      </div>
      <h3>您还没有收藏任何商品</h3>
      <p>发现更多心仪好物，添加到收藏吧</p>
      <router-link to="/search" class="reset-btn">
        <i class="fas fa-search"></i>
        去发现好物
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import ProductCard from '@/views/Home/components/nav/ProductCard.vue';

// 接收父组件传递的属性
const props = defineProps({
  products: {
    type: Array,
    default: () => []
  },
  totalProducts: {
    type: Number,
    default: 0
  },
  currentPage: {
    type: Number,
    default: 1
  },
  pageSize: {
    type: Number,
    default: 12
  },
  sortType: {
    type: String,
    default: 'newest'
  },
  loading: Boolean
});

// 定义事件
const emit = defineEmits(['sort-changed', 'page-changed', 'unfavorite']);

// 状态管理
const viewMode = ref('grid');

// 排序选项
const sortOptions = ref([
  { value: 'newest', label: '最新收藏', icon: 'fas fa-clock' },
  { value: 'price_asc', label: '价格升序', icon: 'fas fa-sort-amount-up' },
  { value: 'price_desc', label: '价格降序', icon: 'fas fa-sort-amount-down' },
  { value: 'discount', label: '折扣力度', icon: 'fas fa-fire' }
]);

// 计算总页数
const totalPages = computed(() =>
    Math.ceil(props.totalProducts / props.pageSize)
);

// 计算可见的分页按钮
const visiblePages = computed(() => {
  const pages = [];
  const total = totalPages.value;
  const current = props.currentPage;

  if (total <= 7) {
    for (let i = 1; i <= total; i++) {
      pages.push(i);
    }
  } else {
    if (current <= 4) {
      for (let i = 1; i <= 5; i++) {
        pages.push(i);
      }
      pages.push('...', total);
    } else if (current >= total - 3) {
      pages.push(1, '...');
      for (let i = total - 4; i <= total; i++) {
        pages.push(i);
      }
    } else {
      pages.push(1, '...');
      for (let i = current - 1; i <= current + 1; i++) {
        pages.push(i);
      }
      pages.push('...', total);
    }
  }

  return pages;
});

// 方法
const changeSort = (type) => {
  emit('sort-changed', type);
};

const changePage = (newPage) => {
  if (newPage >= 1 && newPage <= totalPages.value) {
    emit('page-changed', newPage);
  }
};

const handleUnfavorite = (productId) => {
  emit('unfavorite', productId);
};
</script>

<style scoped>
/* 主内容区样式 */
.sorting-section {
  background: white;
  border-radius: 16px;
  padding: 1.5rem 2rem;
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.1);
  margin-bottom: 1.5rem;
  border: 1px solid #d7e3d7;
}

.sorting-header {
  margin-bottom: 1.5rem;
}

.sorting-header h2 {
  font-size: 1.75rem;
  margin: 0 0 0.5rem 0;
  color: #3b4a30;
}

.sorting-header p {
  color: #6b7a63;
  margin: 0;
  font-size: 1rem;
}

.sorting-controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.sort-label {
  font-weight: 500;
  color: #5c9e53;
}

.sort-buttons {
  display: flex;
  gap: 0.5rem;
}

.sort-btn {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  background: #e9f5e9;
  border: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  color: #3b4a30;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sort-btn:hover {
  background: #d7e3d7;
}

.sort-btn.active {
  background: #5c9e53;
  color: white;
}

/* 商品统计 */
.product-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  background: white;
  border-radius: 16px;
  padding: 1rem 1.5rem;
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.1);
  border: 1px solid #d7e3d7;
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: #3b4a30;
  font-size: 0.95rem;
}

.stats-item strong {
  color: #5c9e53;
  font-weight: 600;
}

.view-toggle {
  display: flex;
  gap: 0.25rem;
  background: #e9f5e9;
  border-radius: 8px;
  padding: 0.25rem;
}

.view-toggle button {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 8px;
  background: transparent;
  color: #6b7a63;
  cursor: pointer;
  transition: all 0.2s ease;
}

.view-toggle button:hover {
  background: #d7e3d7;
}

.view-toggle button.active {
  background: white;
  color: #5c9e53;
  box-shadow: 0 2px 6px rgba(92, 158, 83, 0.1);
}

/* 商品列表 */
.product-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.product-list.list-view {
  grid-template-columns: 1fr;
}

/* 分页控件 */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  margin: 2rem 0;
}

.page-btn {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  background: white;
  border: 1px solid #d7e3d7;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  color: #3b4a30;
  cursor: pointer;
  transition: all 0.2s ease;
}

.page-btn:hover:not(:disabled) {
  border-color: #5c9e53;
  color: #5c9e53;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 0.25rem;
}

.page-number {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  background: white;
  border: 1px solid #d7e3d7;
  color: #3b4a30;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.page-number:hover {
  border-color: #5c9e53;
  color: #5c9e53;
}

.page-number.active {
  background: #5c9e53;
  border-color: #5c9e53;
  color: white;
}

.ellipsis {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #6b7a63;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 3rem 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.1);
  border: 1px solid #d7e3d7;
}

.empty-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(92, 158, 83, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.empty-icon i {
  font-size: 2.5rem;
  color: #5c9e53;
}

.empty-state h3 {
  font-size: 1.5rem;
  color: #3b4a30;
  margin: 0 0 0.75rem 0;
}

.empty-state p {
  color: #6b7a63;
  margin: 0 0 1.5rem 0;
  max-width: 400px;
}

.empty-state .reset-btn {
  padding: 0.875rem 1.5rem;
  background: #5c9e53;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(92, 158, 83, 0.2);
  text-decoration: none;
}

.empty-state .reset-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(92, 158, 83, 0.3);
}

/* 加载状态 */
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.spinner {
  border: 4px solid rgba(92, 158, 83, 0.1);
  border-left-color: #5c9e53;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 响应式样式 */
@media (max-width: 1024px) {
  .product-list {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  }
}

@media (max-width: 768px) {
  .sorting-controls {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .product-stats {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }

  .page-numbers {
    display: none;
  }

  .product-list {
    grid-template-columns: 1fr;
  }
}
</style>
