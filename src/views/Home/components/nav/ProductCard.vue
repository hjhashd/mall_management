<template>
  <div class="product-card" :class="{ 'list-card': viewMode === 'list' }">
    <div class="product-image-wrapper">
      <img :src="product.image" alt="商品图片" class="product-image">
      <div class="product-badge" v-if="product.discountRate">
        <i class="fas fa-fire"></i>
        {{ product.discountRate }}折
      </div>
      <div class="condition-badge" :class="'condition-' + product.condition">
        {{ product.conditionText }}
      </div>
      <div class="product-overlay">
        <router-link :to="`/product/${product.id}`" class="quick-view-btn router-link-button">
          <i class="fas fa-eye"></i>
          快速预览
        </router-link>
      </div>
    </div>
    <div class="product-info">
      <h3 class="product-title">{{ product.title }}</h3>
      <div class="price-section">
        <span class="current-price">¥{{ product.price }}</span>
        <span class="original-price" v-if="product.original_price">¥{{ product.original_price }}</span>
      </div>
      <div class="meta-info">
        <div class="meta-item">
          <i class="fas fa-map-marker-alt"></i>
          <span>{{ product.location }}</span>
        </div>
        <div class="meta-item">
          <i class="fas fa-clock"></i>
          <span>{{ product.created_at }}</span>
        </div>
      </div>
      <div class="card-actions">
        <button class="contact-btn">
          <i class="fas fa-comment"></i>
          联系卖家
        </button>
        <!-- 更新收藏按钮 -->
        <button
            class="favorite-btn"
            :class="{ active: product.isFavorite }"
            @click="toggleFavorite"
        >
          <i class="fas fa-heart"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
// 定义 props
const props = defineProps({
  product: {
    type: Object,
    required: true
  },
  viewMode: {
    type: String,
    default: 'grid'
  }
});

// 定义 emit
const emit = defineEmits(['update:favorite']);

// 切换收藏状态
const toggleFavorite = () => {
  emit('update:favorite', !props.product.isFavorite);
};
</script>


<style scoped>
/* 商品卡片样式 */
.product-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
  position: relative;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12);
}

.product-image-wrapper {
  position: relative;
  width: 100%;
  height: 220px;
  overflow: hidden;
}

.product-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.product-card:hover .product-image {
  transform: scale(1.05);
}

.product-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: linear-gradient(135deg, #f59e0b, #ef4444);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  z-index: 2;
}

.condition-badge {
  position: absolute;
  bottom: 12px;
  left: 12px;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  color: white;
  z-index: 2;
}

.condition-1 {
  background: linear-gradient(135deg, #10b981, #34d399);
}

.condition-2 {
  background: linear-gradient(135deg, #0ea5e9, #60a5fa);
}

.condition-3 {
  background: linear-gradient(135deg, #f59e0b, #fbbf24);
}

.condition-4 {
  background: linear-gradient(135deg, #ef4444, #f87171);
}

.product-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: 1;
}

.product-card:hover .product-overlay {
  opacity: 1;
}

.quick-view-btn {
  background: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 20px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quick-view-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.product-info {
  padding: 1.25rem;
}

.product-title {
  font-size: 1.1rem;
  margin: 0 0 0.75rem 0;
  color: #1e293b;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.price-section {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.current-price {
  font-size: 1.25rem;
  font-weight: 700;
  color: #3b82f6;
}

.original-price {
  font-size: 0.9rem;
  text-decoration: line-through;
  color: #94a3b8;
}

.meta-info {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.25rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.85rem;
  color: #64748b;
}

.card-actions {
  display: flex;
  justify-content: space-between;
}

.contact-btn {
  flex: 1;
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  color: white;
  border: none;
  padding: 0.75rem;
  border-radius: 12px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.contact-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.3);
}

.favorite-btn {
  width: 42px;
  height: 42px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: #f1f5f9;
  border: none;
  margin-left: 0.75rem;
  color: #94a3b8;
  cursor: pointer;
  transition: all 0.3s ease;
}

.favorite-btn:hover {
  background: #fee2e2;
  color: #ef4444;
}

.favorite-btn.active {
  background: #fee2e2;
  color: #ef4444;
}

/* 列表视图样式 */
.product-card.list-card {
  display: flex;
}

.product-card.list-card .product-image-wrapper {
  width: 240px;
  height: 180px;
  flex-shrink: 0;
}

.product-card.list-card .product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.product-card.list-card .product-title {
  -webkit-line-clamp: 1;
}

.product-card.list-card .price-section {
  margin-bottom: 0.5rem;
}

.product-card.list-card .meta-info {
  margin-bottom: auto;
}

.product-card.list-card .card-actions {
  justify-content: flex-start;
  margin-top: 1rem;
}


</style>
