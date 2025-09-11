<template>
  <div class="main-content">
    <!-- 顶部排序栏 -->
    <div class="sorting-section">
      <div class="sorting-header">
        <h2>闲置好物</h2>
        <p>发现生活中的美好物品</p>
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
        <i class="fas fa-cube"></i>
        <span>共找到 <strong>{{ totalProducts }}</strong> 件商品</span>
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

    <!-- 错误提示 -->
    <div v-if="error" class="error-message">
      <i class="fas fa-exclamation-triangle"></i>
      {{ error }}
      <button @click="$emit('reset-filters')">重试</button>
    </div>

    <!-- 商品列表 -->
    <div class="product-list" :class="{ 'list-view': viewMode === 'list' }">
      <ProductCard
          v-for="product in products"
          :key="product.id"
          :product="product"
          :view-mode="viewMode"
          @update:favorite="handleFavoriteUpdate(product, $event)"
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
    <div v-if="products.length === 0 && !loading && !error" class="empty-state">
      <div class="empty-icon">
        <i class="fas fa-search"></i>
      </div>
      <h3>没有找到相关商品</h3>
      <p>试试调整筛选条件或搜索关键词</p>
      <button class="reset-btn" @click="onResetFilters">
        <i class="fas fa-redo"></i>
        重置筛选条件
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import ProductCard from './ProductCard.vue';
// 导入 API 方法
import { toggleFavorite } from '@/api/product'

// 在现有代码中添加处理函数
const handleFavoriteUpdate = async (product, newFavoriteStatus) => {
  try {
    // 调用 API 更新收藏状态
    await toggleFavorite(product.id)

    // 更新本地状态（乐观更新）
    const index = props.products.findIndex(p => p.id === product.id)
    if (index !== -1) {
      // 创建新数组避免直接修改 prop
      const updatedProducts = [...props.products]
      updatedProducts[index] = {
        ...updatedProducts[index],
        isFavorite: newFavoriteStatus
      }

      // 通知父组件更新数据（假设父组件通过 v-model 管理 products）
      emit('update:products', updatedProducts)
    }
  } catch (error) {
    console.error('收藏操作失败:', error)
    // 可以在这里添加错误提示
  }
}

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
  loading: Boolean,
  error: String
});

// 定义事件
const emit = defineEmits(['sort-changed', 'page-changed', 'reset-filters']);

// 状态管理
const viewMode = ref('grid');

// 排序选项
const sortOptions = ref([
  { value: 'newest', label: '最新发布', icon: 'fas fa-clock' },
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

const onResetFilters = () => {
  emit('reset-filters');
};
</script>

<style scoped>
/* 主内容区样式 */
.main-content {
  flex: 1;
  padding: 2rem;
  padding-left: 1.5rem;
  z-index: 2;
  margin: 20px 20px 20px 0;
}

.sorting-section {
  margin-top: -25px;
  background: white;
  border-radius: 24px;
  padding: 1.0rem 2rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  margin-bottom: 1.5rem;
}

.sorting-header {
  margin-bottom: 1.5rem;
}

.sorting-header h2 {
  font-size: 1.75rem;
  margin: 0 0 0.5rem 0;
  color: #1e293b;
}

.sorting-header p {
  color: #64748b;
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
  color: #475569;
}

.sort-buttons {
  display: flex;
  gap: 0.5rem;
}

.sort-btn {
  padding: 0.5rem 1rem;
  border-radius: 12px;
  background: rgba(226, 232, 240, 0.5);
  border: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sort-btn:hover {
  background: #e2e8f0;
}

.sort-btn.active {
  background: #3b82f6;
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
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: #475569;
  font-size: 0.95rem;
}

.stats-item strong {
  color: #3b82f6;
  font-weight: 600;
}

.view-toggle {
  display: flex;
  gap: 0.25rem;
  background: #f1f5f9;
  border-radius: 12px;
  padding: 0.25rem;
}

.view-toggle button {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: #94a3b8;
  cursor: pointer;
  transition: all 0.2s ease;
}

.view-toggle button:hover {
  background: #e2e8f0;
}

.view-toggle button.active {
  background: white;
  color: #3b82f6;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
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
  border-radius: 12px;
  background: white;
  border: 2px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s ease;
}

.page-btn:hover:not(:disabled) {
  border-color: #3b82f6;
  color: #3b82f6;
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
  border-radius: 12px;
  background: white;
  border: 2px solid #e2e8f0;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.page-number:hover {
  border-color: #3b82f6;
  color: #3b82f6;
}

.page-number.active {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.ellipsis {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #94a3b8;
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
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(59, 130, 246, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.empty-icon i {
  font-size: 2.5rem;
  color: #3b82f6;
}

.empty-state h3 {
  font-size: 1.5rem;
  color: #1e293b;
  margin: 0 0 0.75rem 0;
}

.empty-state p {
  color: #64748b;
  margin: 0 0 1.5rem 0;
  max-width: 400px;
}

.empty-state .reset-btn {
  padding: 0.875rem 1.5rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 16px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.3);
}

.empty-state .reset-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

/* 响应式样式 */
@media (max-width: 1024px) {
  .product-list {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 1.5rem;
    margin: 0;
  }

  .sorting-controls {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .product-card.list-card {
    flex-direction: column;
  }

  .product-card.list-card .product-image-wrapper {
    width: 100%;
    height: 220px;
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
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-left-color: #3498db;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-message, .no-results {
  text-align: center;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
  margin: 1rem 0;
}

.error-message i {
  color: #e74c3c;
  font-size: 2rem;
  margin-bottom: 1rem;
}

.no-results i {
  color: #95a5a6;
  font-size: 3rem;
  margin-bottom: 1rem;
}
</style>
