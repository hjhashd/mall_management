<script setup>
import ProductCard from './ProductCard.vue';
import { computed } from 'vue';

const props = defineProps({
  products: { type: Array, default: () => [] },
  currentPage: { type: Number, default: 1 },
  totalPages: { type: Number, default: 1 },
  leftSidebarCollapsed: { type: Boolean, default: false },
  rightSidebarCollapsed: { type: Boolean, default: false },
  sortMode: { type: String, default: 'popular' },
  displayMode: { type: String, default: 'search' }
});

const emit = defineEmits(['change-page', 'add-to-cart', 'toggle-favorite']);

// [!code focus:4]
// [!COMMENT] 移除客户端过滤，因为过滤逻辑已移至父组件的API调用中
const displayedProducts = computed(() => {
  return props.products;
});

// 新增：根据排序模式动态生成标题和图标
const dynamicSection = computed(() => {
  if (props.displayMode === 'recommend') {
    return { title: 'AI 智能推荐', icon: 'fas fa-wand-magic-sparkles' };
  }

  const titleMap = {
    'newest': { title: '最新发布', icon: 'fas fa-star' },
    'popular': { title: '热门商品', icon: 'fas fa-fire' },
    'favorite_desc': { title: '收藏精选', icon: 'fas fa-heart' },
    'price_asc': { title: '价格从低到高', icon: 'fas fa-tags' },
    'price_desc': { title: '价格从高到低', icon: 'fas fa-tags' },
    'discount_desc': { title: '超值折扣', icon: 'fas fa-percent' }
  };

  return titleMap[props.sortMode] || { title: '商品列表', icon: 'fas fa-th-large' };
});


// 计算网格布局类名
const gridLayoutClass = computed(() => {
  const leftCollapsed = props.leftSidebarCollapsed;
  const rightCollapsed = props.rightSidebarCollapsed;

  if (leftCollapsed && rightCollapsed) {
    return 'grid-layout-full';
  } else if (leftCollapsed || rightCollapsed) {
    return 'grid-layout-expanded';
  } else {
    return 'grid-layout-normal';
  }
});

const changePage = (page) => {
  emit('change-page', page);
};

const onAddToCart = (product) => {
  emit('add-to-cart', product);
};

const onToggleFavorite = (productId) => {
  emit('toggle-favorite', productId);
};
</script>

<template>
  <div>
    <section class="product-list-section">
      <h2 class="section-title">
        <i :class="dynamicSection.icon"></i>
        {{ dynamicSection.title }}
      </h2>
      <div class="product-grid" :class="gridLayoutClass">
        <ProductCard
            v-for="product in displayedProducts"
            :key="product.id"
            :product="product"
            @add-to-cart="onAddToCart"
            @toggle-favorite="onToggleFavorite"
        />
      </div>
      <!-- [!code focus:4] -->
      <!-- [!COMMENT] 此处判断条件更新，因为 displayedProducts 现在总是等于 products -->
      <div v-if="products.length > 0 && displayedProducts.length === 0" class="no-products-message">
        <i class="fas fa-box-open"></i>
        <p>当前页面暂时没有"上架"的商品。</p>
        <span class="no-products-tip">请尝试切换页面或调整筛选条件</span>
      </div>

      <div v-if="products.length === 0" class="empty-state">
        <div class="empty-icon">
          <i class="fas fa-search"></i>
        </div>
        <h3>暂无相关商品</h3>
        <p>试试调整搜索条件或浏览其他分类</p>
      </div>
    </section>

    <div class="pagination-container" v-if="totalPages > 1">
      <div class="pagination-wrapper">
        <button
            class="page-btn page-prev"
            :class="{ 'disabled': currentPage === 1 }"
            @click="changePage(currentPage - 1)"
            :disabled="currentPage === 1"
        >
          <i class="fas fa-chevron-left"></i>
          <span>上一页</span>
        </button>

        <div class="page-numbers">
          <button
              v-for="page in Math.min(totalPages, 5)"
              :key="page"
              class="page-number"
              :class="{ 'active': currentPage === page }"
              @click="changePage(page)"
          >
            {{ page }}
          </button>
        </div>

        <button
            class="page-btn page-next"
            :class="{ 'disabled': currentPage === totalPages }"
            @click="changePage(currentPage + 1)"
            :disabled="currentPage === totalPages"
        >
          <span>下一页</span>
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>

      <div class="page-info">
        第 {{ currentPage }} 页，共 {{ totalPages }} 页
      </div>
    </div>
  </div>
</template>

<style scoped>
.product-list-section {
  margin-bottom: 2rem;
}

.section-title {
  font-size: 1.8rem;
  font-weight: 700;
  color: var(--primary-color);
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 2rem;
  padding: 1rem 0;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 4px;
  background: linear-gradient(90deg, var(--primary-color), var(--hover-color));
  border-radius: 2px;
}

.section-title i {
  color: #ff6b6b;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

/* 响应式网格布局 */
.product-grid {
  display: grid;
  gap: 24px;
  margin-bottom: 2rem;
  transition: all 0.3s ease;
}

.grid-layout-normal {
  grid-template-columns: repeat(4, 1fr);
}

.grid-layout-expanded {
  grid-template-columns: repeat(5, 1fr);
}

.grid-layout-full {
  grid-template-columns: repeat(6, 1fr);
}

@media (max-width: 1400px) {
  .grid-layout-full {
    grid-template-columns: repeat(5, 1fr);
  }

  .grid-layout-expanded {
    grid-template-columns: repeat(4, 1fr);
  }

  .grid-layout-normal {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 1200px) {
  .grid-layout-full,
  .grid-layout-expanded {
    grid-template-columns: repeat(4, 1fr);
  }

  .grid-layout-normal {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 992px) {
  .product-grid {
    grid-template-columns: repeat(3, 1fr) !important;
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr) !important;
    gap: 16px;
  }

  .section-title {
    font-size: 1.5rem;
  }
}

@media (max-width: 576px) {
  .product-grid {
    grid-template-columns: 1fr !important;
    gap: 16px;
  }
}

.no-products-message, .empty-state {
  text-align: center;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border-radius: 16px;
  margin: 2rem 0;
}

.no-products-message {
  border: 2px dashed var(--border-color);
}

.no-products-message i, .empty-icon i {
  font-size: 3rem;
  color: var(--text-muted-color);
  margin-bottom: 1rem;
}

.empty-icon i {
  font-size: 4rem;
  opacity: 0.5;
}

.no-products-message p, .empty-state p {
  font-size: 1.1rem;
  color: var(--text-muted-color);
  margin-bottom: 0.5rem;
}

.empty-state h3 {
  font-size: 1.5rem;
  color: var(--text-muted-color);
  margin-bottom: 0.5rem;
}

.no-products-tip {
  font-size: 0.9rem;
  color: var(--text-muted-color);
  opacity: 0.8;
}

.pagination-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  margin-top: 3rem;
  padding: 2rem;
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border-radius: 16px;
  box-shadow: 0 4px 20px var(--shadow-color);
}

.pagination-wrapper {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.page-btn {
  background: white;
  border: 2px solid var(--border-color);
  color: var(--text-muted-color);
  padding: 12px 20px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 100px;
  justify-content: center;
}

.page-btn:hover:not(.disabled) {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.3);
}

.page-btn.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 8px;
}

.page-number {
  background: white;
  border: 2px solid var(--border-color);
  color: var(--text-muted-color);
  width: 44px;
  height: 44px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.page-number:hover {
  background: var(--hover-color);
  border-color: var(--primary-color);
  color: var(--primary-color);
  transform: translateY(-2px);
}

.page-number.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.3);
}

.page-info {
  font-size: 14px;
  color: var(--text-muted-color);
  background: var(--hover-color);
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 500;
}

@media (max-width: 768px) {
  .pagination-wrapper {
    flex-wrap: wrap;
    justify-content: center;
  }

  .page-btn {
    padding: 10px 16px;
    min-width: 80px;
  }

  .page-btn span {
    display: none;
  }

  .page-number {
    width: 40px;
    height: 40px;
  }
}
</style>
