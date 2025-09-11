<script setup>
const props = defineProps({
  product: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['add-to-cart', 'toggle-favorite']);

const getConditionText = (condition) => {
  const conditions = { 1: '全新', 2: '95新', 3: '9成新', 4: '8成新', 5: '7成新及以下' };
  return conditions[condition] || '未知';
};

const getConditionColor = (condition) => {
  const colors = {
    1: '#28a745', // 全新 - 绿色
    2: '#17a2b8', // 95新 - 蓝色
    3: '#ffc107', // 9成新 - 黄色
    4: '#fd7e14', // 8成新 - 橙色
    5: '#dc3545'  // 7成新及以下 - 红色
  };
  return colors[condition] || '#6c757d';
};

const isNewProduct = (createdAt) => {
  if (!createdAt) return false;
  const sevenDays = 7 * 24 * 60 * 60 * 1000;
  return (Date.now() - new Date(createdAt).getTime()) < sevenDays;
};

const handleAddToCart = () => {
  emit('add-to-cart', props.product);
};

const handleToggleFavorite = () => {
  emit('toggle-favorite', props.product.id);
};
</script>

<template>
  <div class="product-card">
    <!-- 商品图片链接 -->
    <router-link :to="`/product/${product.id}`" class="product-link">
      <div class="product-image-wrapper">
        <img
            :src="product.image || 'http://localhost:8080/uploads/products/example.png'"
            :alt="product.title"
            class="product-image"
        >

        <!-- 商品徽章 -->
        <div class="product-badges">
          <span v-if="isNewProduct(product.createdAt)" class="badge badge-new">
            <i class="fas fa-star"></i>
            新品
          </span>
          <span
              class="badge badge-condition"
              :style="{ backgroundColor: getConditionColor(product.condition) }"
          >
            {{ getConditionText(product.condition) }}
          </span>
        </div>

        <!-- 悬浮快速操作 -->
        <div class="quick-actions">
          <button
              class="quick-btn quick-favorite"
              @click.prevent="handleToggleFavorite"
              :class="{ 'active': product.isFavoritedByCurrentUser }"
              title="收藏"
          >
            <i :class="product.isFavoritedByCurrentUser ? 'fas fa-heart' : 'far fa-heart'"></i>
          </button>
          <button
              class="quick-btn quick-cart"
              @click.prevent="handleAddToCart"
              title="加入购物车"
          >
            <i class="fas fa-shopping-cart"></i>
          </button>
        </div>

        <!-- 价格标签 -->
        <div class="price-tag">
          ¥{{ product.price ? product.price.toFixed(2) : '0.00' }}
        </div>
      </div>
    </router-link>

    <!-- 商品信息 -->
    <div class="product-info">
      <h3 class="product-title" :title="product.title">
        {{ product.title }}
      </h3>

      <div class="product-meta">
        <div class="meta-item location">
          <i class="fas fa-map-marker-alt"></i>
          <span>{{ product.school || product.location || '未知位置' }}</span>
        </div>
        <!-- [!code focus:5] -->
        <!-- [!COMMENT] 根据你的要求，此处的商品分类信息已被移除 -->
      </div>
    </div>
  </div>
</template>

<style scoped>
.product-card {
  background: #fff;
  border-radius: 20px;
  overflow: hidden;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
}

.product-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 20px;
  padding: 2px;
  background: linear-gradient(45deg, var(--primary-color), var(--hover-color));
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.product-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 40px rgba(92, 158, 83, 0.2);
}

.product-card:hover::before {
  opacity: 1;
}

.product-link {
  text-decoration: none;
  color: inherit;
  /* 让链接也成为 flex 容器，使其子元素（图片包装器）可以拉伸 */
  display: flex;
  flex: 1;
  min-height: 0;
}

.product-image-wrapper {
  position: relative;
  /* 移除固定高度，使用 aspect-ratio 确保图片区域为正方形，并能响应式缩放 */
  aspect-ratio: 1 / 1;
  width: 100%;
  background: linear-gradient(135deg, var(--secondary-color) 0%, #f1f5f1 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  /* 确保图片区域可以自动拉伸以填充可用空间 */
  flex: 1;
  min-height: 0; /* flex 布局中的重要修复，防止内容溢出 */
}

.product-image {
  /* 调整大小以更好地适应新的包装器 */
  max-width: 90%;
  max-height: 90%;
  object-fit: contain;
  transition: all 0.4s ease;
  border-radius: 12px;
}

.product-card:hover .product-image {
  transform: scale(1.08);
}

/* 商品徽章 */
.product-badges {
  position: absolute;
  top: 12px;
  left: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 2;
}

.badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
  color: white;
  display: flex;
  align-items: center;
  gap: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(10px);
}

.badge-new {
  background: linear-gradient(135deg, #ff6b6b, #ff5252);
  animation: shimmer 2s infinite;
}

.badge-condition {
  background: var(--primary-color);
}

@keyframes shimmer {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.8;
  }
}

/* 快速操作按钮 */
.quick-actions {
  position: absolute;
  top: 12px;
  right: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  opacity: 0;
  transform: translateX(20px);
  transition: all 0.3s ease;
  z-index: 2;
}

.product-card:hover .quick-actions {
  opacity: 1;
  transform: translateX(0);
}

.quick-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.9);
  color: var(--text-muted-color);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.quick-btn:hover {
  transform: scale(1.1);
  color: white;
}

.quick-favorite:hover,
.quick-favorite.active {
  background: #ff6b6b;
  color: white;
}

.quick-cart:hover {
  background: var(--primary-color);
  color: white;
}

/* 价格标签 */
.price-tag {
  position: absolute;
  bottom: 12px;
  right: 12px;
  background: linear-gradient(135deg, var(--primary-color), #4a8c3a);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 700;
  box-shadow: 0 4px 12px rgba(92, 158, 83, 0.3);
  z-index: 2;
}

/* 商品信息区域 */
.product-info {
  /* 调整内边距，使其更紧凑 */
  padding: 16px;
  display: flex;
  flex-direction: column;
  /* 移除 flex: 1，让其高度由内容决定 */
  flex-shrink: 0;
  gap: 10px;
  border-top: 1px solid var(--border-color);
}

.product-title {
  font-size: 1rem;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 2.8em; /* 保持两行的高度 */
}

.product-meta {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: auto; /* 将元数据推到底部 */
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text-muted-color);
}

.meta-item i {
  width: 14px;
  text-align: center;
  opacity: 0.7;
}

.meta-item span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.location i {
  color: #e74c3c;
}

.category i {
  color: var(--primary-color);
}

/* 响应式设计调整 */
@media (max-width: 768px) {
  .product-card {
    border-radius: 16px;
  }

  .product-info {
    padding: 14px;
    gap: 8px;
  }

  .product-title {
    font-size: 0.95rem;
  }
}
</style>
