<template>
  <div class="product-detail" v-if="product">
    <!-- 商品图片展示区 -->
    <div class="product-gallery">
      <div class="gallery-container">
        <div class="main-image-container">
          <img
              :src="mainImage"
              :alt="product.title"
              class="main-image"
              @mousemove="handleZoom"
              @mouseleave="zoomActive = false"
          />
          <div
              class="zoom-view"
              v-if="zoomActive"
              :style="zoomStyle"
          ></div>
          <div class="image-badge" v-if="product.conditionText">
            <span class="badge">{{ product.conditionText }}</span>
          </div>
        </div>
        <div class="thumbnails-container">
          <div
              v-for="(image, index) in product.images"
              :key="index"
              class="thumbnail-container"
              @click="changeImage(image.imageUrl)"
              @mouseenter="startThumbnailHover(index)"
              @mouseleave="stopThumbnailHover"
          >
            <img
                :src="image.imageUrl"
                :alt="product.title"
                :class="{ thumbnail: true, active: image.imageUrl === mainImage }"
            />
            <div class="thumbnail-overlay" :class="{ 'show': thumbnailHoverIndex === index }">
              <i class="fas fa-search"></i>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 商品信息区 -->
    <div class="product-info">
      <div class="category-breadcrumb">
        <span class="category">{{ product.category.categoryName }}</span>
        <span class="divider">/</span>
        <span class="location">
          <i class="fas fa-map-marker-alt"></i> {{ product.location }}
        </span>
      </div>

      <h1 class="product-title">{{ product.title }}</h1>

      <div class="stats">
        <div class="stat-item">
          <i class="fas fa-eye"></i>
          <span>{{ product.viewCount }}次浏览</span>
        </div>
        <div class="stat-item">
          <i class="fas fa-heart"></i>
          <span>{{ product.favoriteCount }}人收藏</span>
        </div>
        <div class="stat-item stock" :class="{ 'low-stock': product.stock <= 3 }">
          <i class="fas fa-box-open"></i>
          <span>库存{{ product.stock }}件</span>
        </div>
      </div>

      <div class="price-section">
        <div class="price">
          <span class="current-price">¥{{ product.currentPrice.toFixed(2) }}</span>
          <span class="original-price" v-if="product.originalPrice">
            <span class="price-line">¥{{ product.originalPrice.toFixed(2) }}</span>
            <span class="discount-percent">
              {{ calculateDiscount(product.currentPrice, product.originalPrice) }}
            </span>
          </span>
        </div>
        <div class="price-tag">
          <span>二手价</span>
        </div>
      </div>

      <div class="description-box">
        <h3 class="section-title"><i class="fas fa-file-alt"></i> 商品描述</h3>
        <p class="description">{{ product.description }}</p>
      </div>

      <div class="specs-box" v-if="product.specs">
        <h3 class="section-title"><i class="fas fa-info-circle"></i> 规格参数</h3>
        <div class="specs-grid">
          <div v-for="(value, name) in product.specs" :key="name" class="spec-item">
            <span class="spec-name">{{ name }}：</span>
            <span class="spec-value">{{ value }}</span>
          </div>
        </div>
      </div>

      <div class="action-section">
        <div class="quantity-selector">
          <span class="quantity-label">数量：</span>
          <div class="quantity-control">
            <button
                class="qty-btn minus"
                @click="updateQuantity(-1)"
                :disabled="quantity <= 1"
            >
              <i class="fas fa-minus"></i>
            </button>
            <input
                type="text"
                class="qty-input"
                v-model.number="quantity"
                @change="validateQuantity"
            />
            <button
                class="qty-btn plus"
                @click="updateQuantity(1)"
                :disabled="quantity >= product.stock"
            >
              <i class="fas fa-plus"></i>
            </button>
          </div>
          <span class="stock-hint" v-if="product.stock <= 5">
            仅剩{{ product.stock }}件！
          </span>
        </div>

        <div class="action-buttons">
          <button
              class="btn btn-primary pulse"
              @click="addToCart"
              :disabled="product.stock <= 0"
          >
            <i class="fas fa-shopping-cart"></i>
            <span>{{ product.stock > 0 ? '加入购物车' : '已售罄' }}</span>
          </button>
          <button
              class="btn btn-favorite"
              @click="toggleFavorite"
              :class="{ 'favorited': product.favoritedByCurrentUser }"
          >
            <i class="fas" :class="product.favoritedByCurrentUser ? 'fa-heart' : 'fa-heart-o'"></i>
            {{ product.favoritedByCurrentUser ? '已收藏' : '收藏' }}
          </button>
        </div>
      </div>
    </div>
  </div>

  <div v-else-if="loading" class="loading-container">
    <div class="loading-spinner">
      <div class="spinner"></div>
      <p>正在加载商品信息...</p>
    </div>
  </div>

  <div v-else class="error-container">
    <div class="error-message">
      <i class="fas fa-exclamation-triangle"></i>
      <p>商品不存在或加载失败</p>
      <button class="btn btn-retry" @click="retryLoad">重试</button>
    </div>
  </div>

  <div id="simpleToast"
       class="toast align-items-center text-white border-0 position-fixed bottom-0 end-0 m-3"
       :style="{
       background: toastType === 'success' ? '#28a745' : '#dc3545',
       display: showToast ? 'flex' : 'none'
     }">
    <div class="d-flex">
      <div class="toast-body">
        <i :class="toastType === 'success' ? 'fas fa-check-circle me-2' : 'fas fa-exclamation-circle me-2'"></i>
        <span v-html="toastMessage"></span>
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto"
              @click="showToast = false"></button>
    </div>
  </div>
</template>

<script setup>
import {ref, reactive, onMounted} from 'vue';
import {useRoute} from 'vue-router';
import {getProductDetail, addToCart as apiAddToCart, toggleFavorite as apiToggleFavorite} from '@/api/product';
import {useCartStore} from '@/stores/cartStore'

const cartStore = useCartStore()

// 1. 定义要触发的事件
const emit = defineEmits(['productLoaded']);

const route = useRoute();

// 响应式数据
const product = ref(null);
const mainImage = ref('');
const quantity = ref(1);
const loading = ref(true);
const zoomActive = ref(false);
const zoomStyle = reactive({
  backgroundImage: '',
  backgroundPosition: '0% 0%'
});
const thumbnailHoverIndex = ref(null);

const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success'); // 'success' 或 'error'

const triggerToast = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;

  // 3秒后自动关闭
  setTimeout(() => {
    showToast.value = false;
  }, 3000);
};

// 计算折扣百分比
const calculateDiscount = (current, original) => {
  if (!original || original <= 0) return '';
  const discount = ((original - current) / original * 100).toFixed(0);
  return `省${discount}%`;
};

// 获取商品详情
const fetchProductDetail = async (productId) => {
  try {
    loading.value = true;
    const response = await getProductDetail(productId);

    if (response.data.success) {
      product.value = response.data.data;

      // 2. 假设API返回的数据中包含 sellerId
      // 触发 'productLoaded' 事件，并把 sellerId 传递出去
      if (product.value && product.value.sellerId) {
        emit('productLoaded', product.value.sellerId);
      }

      // 设置默认主图
      if (product.value.images && product.value.images.length > 0) {
        const mainImg = product.value.images.find(img => img.main) || product.value.images[0];
        mainImage.value = mainImg.imageUrl;
        zoomStyle.backgroundImage = `url(${mainImage.value})`;
      }
    } else {
      console.error('获取商品详情失败:', response.data.message);
    }
  } catch (error) {
    console.error('获取商品详情出错:', error);
  } finally {
    loading.value = false;
  }
};

// 图片放大效果
const handleZoom = (e) => {
  if (!product.value.images || product.value.images.length === 0) return;

  const container = e.currentTarget;
  const containerRect = container.getBoundingClientRect();

  // 计算鼠标在图片中的位置百分比
  const x = e.clientX - containerRect.left;
  const y = e.clientY - containerRect.top;
  const xPercent = (x / containerRect.width) * 100;
  const yPercent = (y / containerRect.height) * 100;

  zoomActive.value = true;
  zoomStyle.backgroundPosition = `${xPercent}% ${yPercent}%`;
};

// 切换主图
const changeImage = (src) => {
  mainImage.value = src;
  zoomStyle.backgroundImage = `url(${src})`;
  zoomActive.value = false;
};

// 缩略图悬停效果
const startThumbnailHover = (index) => {
  thumbnailHoverIndex.value = index;
};

const stopThumbnailHover = () => {
  thumbnailHoverIndex.value = null;
};

// 更新购买数量
const updateQuantity = (change) => {
  const newValue = quantity.value + change;
  if (newValue >= 1 && newValue <= product.value.stock) {
    quantity.value = newValue;
  }
};

// 验证输入数量
const validateQuantity = () => {
  if (isNaN(quantity.value)) {
    quantity.value = 1;
    return;
  }

  quantity.value = Math.max(1, Math.min(product.value.stock, Math.floor(quantity.value)));
};

// 加入购物车
const addToCart = async () => {
  if (!product.value || product.value.stock <= 0) {
    triggerToast('商品已售罄', 'error');
    return;
  }

  try {
    // 确保购物车数据是最新的
    await cartStore.fetchCartItems();

    const cartQuantity = cartStore.getItemQuantity(product.value.productId);

    if (quantity.value > (product.value.stock - cartQuantity)) {
      triggerToast(`最多还可再添加 ${product.value.stock - cartQuantity} 件`, 'error');
      return;
    }

    const response = await apiAddToCart(product.value.productId, quantity.value);

    if (response.data.success) {
      // 更新本地购物车状态
      cartStore.updateCartSummary(
          quantity.value,
          product.value.currentPrice * quantity.value
      );

      // 刷新购物车商品列表
      await cartStore.fetchCartItems();

      triggerToast(`已添加 ${quantity.value} 件 ${product.value.title} 到购物车`);
    } else {
      triggerToast('加入购物车失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('加入购物车出错:', error);
    triggerToast('加入购物车失败，请稍后重试', 'error');
  }
};

// 收藏/取消收藏
const toggleFavorite = async () => {
  if (!product.value) return;

  try {
    const response = await apiToggleFavorite(product.value.productId);

    if (response.data.success) {
      product.value.favoritedByCurrentUser = !product.value.favoritedByCurrentUser;
      product.value.favoriteCount += product.value.favoritedByCurrentUser ? 1 : -1;

      // 显示反馈
      triggerToast(product.value.favoritedByCurrentUser ? '已添加到收藏夹' : '已从收藏夹移除');
    } else {
      triggerToast('操作失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('收藏操作出错:', error);
    triggerToast('操作失败，请稍后重试', 'error');
  }
};

// 重试加载
const retryLoad = () => {
  const productId = route.params.id;
  if (productId) {
    fetchProductDetail(parseInt(productId, 10));
  }
};

// 组件挂载时获取商品详情
onMounted(() => {
  const productId = route.params.id;

  if (productId && productId !== 'undefined' && productId !== 'null') {
    const productIdNum = parseInt(productId, 10);
    if (Number.isInteger(productIdNum) && productIdNum > 0) {
      fetchProductDetail(productIdNum);
    }
  }
});
</script>

<style scoped>
:root {
  --primary: #FF6B6B;
  --primary-light: #FF8E8E;
  --primary-dark: #E04F4F;
  --secondary: #4ECDC4;
  --accent: #FFD166;
  --light: #FFF5E4;
  --dark: #333333;
  --gray: #888888;
  --light-gray: #F5F5F5;
  --lighter-gray: #FAFAFA;
  --border-color: #E0E0E0;
  --border-radius: 12px;
  --border-radius-sm: 8px;
  --box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  --box-shadow-sm: 0 4px 12px rgba(0, 0, 0, 0.05);
  --transition: all 0.3s ease;
  --transition-fast: all 0.15s ease;
  --box-shadow-inner: inset 0 2px 4px 0 rgba(0, 0, 0, 0.05);
}

/* 基础布局 */
.product-detail {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
  position: relative;
}

/* 图片展示区 */
.product-gallery {
  position: sticky;
  top: 20px;
  align-self: start;
}

.gallery-container {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  padding: 20px;
  border: 1px solid var(--border-color);
}

.main-image-container {
  position: relative;
  background: var(--lighter-gray);
  border-radius: var(--border-radius-sm);
  overflow: hidden;
  margin-bottom: 20px;
  cursor: zoom-in;
  border: 1px solid var(--border-color);
  box-shadow: var(--box-shadow-inner);
  transition: var(--transition);
}

.main-image-container:hover {
  box-shadow: 0 0 0 1px var(--primary);
}

.main-image {
  width: 100%;
  height: 500px;
  object-fit: contain;
  display: block;
  background-color: var(--lighter-gray);
  transition: var(--transition);
}

.main-image:hover {
  transform: scale(1.02);
}

.zoom-view {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: 200%;
  pointer-events: none;
  z-index: 10;
  opacity: 0;
  animation: fadeIn 0.3s forwards;
  border-radius: var(--border-radius-sm);
}

@keyframes fadeIn {
  to {
    opacity: 1;
  }
}

.image-badge {
  position: absolute;
  top: 15px;
  left: 15px;
  z-index: 5;
}

.badge {
  display: inline-block;
  padding: 5px 10px;
  background-color: rgba(0, 0, 0, 0.7);
  color: white;
  border-radius: var(--border-radius-sm);
  font-size: 12px;
  font-weight: 500;
}

.thumbnails-container {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding: 5px;
  background: var(--light-gray);
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
}

.thumbnail-container {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: var(--border-radius-sm);
  overflow: hidden;
  cursor: pointer;
  transition: var(--transition);
  border: 2px solid transparent;
  background: white;
}

.thumbnail-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.thumbnail {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition);
}

.thumbnail-container:hover .thumbnail,
.thumbnail.active {
  border-color: var(--primary);
}

.thumbnail-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  opacity: 0;
  transition: var(--transition);
  border-radius: var(--border-radius-sm);
}

.thumbnail-overlay.show {
  opacity: 1;
}

/* 商品信息区 */
.product-info {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  padding: 30px;
}

.category-breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--gray);
  font-size: 14px;
  margin-bottom: 10px;
}

.category {
  color: var(--primary);
}

.divider {
  opacity: 0.5;
}

.location {
  font-size: 13px;
}

.product-title {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 15px 0;
  color: var(--dark);
  line-height: 1.3;
}

.stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid var(--border-color);
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: var(--gray);
}

.stat-item i {
  font-size: 14px;
}

.stat-item.stock {
  color: var(--primary-dark);
}

.stat-item.low-stock {
  color: #FF6B6B;
  font-weight: 500;
}

.price-section {
  display: flex;
  align-items: flex-end;
  gap: 15px;
  margin-bottom: 25px;
}

.price {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.current-price {
  font-size: 32px;
  font-weight: 700;
  color: var(--primary);
}

.original-price {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  color: var(--gray);
}

.price-line {
  text-decoration: line-through;
}

.discount-percent {
  background-color: var(--primary-light);
  color: var(--primary-dark); /* 主色深色调 */
  border: 1px solid var(--primary-dark); /* 边框 */
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 500;
}

.price-tag {
  background-color: var(--light);
  color: var(--primary-dark);
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.description-box,
.specs-box {
  margin-bottom: 25px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border-color);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  margin: 0 0 15px 0;
  color: var(--dark);
}

.section-title i {
  color: var(--primary);
  font-size: 16px;
}

.description {
  color: #555;
  line-height: 1.8;
  margin: 0;
  white-space: pre-line;
}

.specs-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.spec-item {
  display: flex;
  font-size: 14px;
}

.spec-name {
  color: var(--gray);
  min-width: 80px;
}

.spec-value {
  color: var(--dark);
  font-weight: 500;
}

/* 操作区域 */
.action-section {
  margin-top: 30px;
}

.quantity-selector {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
}

.quantity-label {
  font-size: 14px;
  color: var(--dark);
}

.quantity-control {
  display: flex;
  align-items: center;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  overflow: hidden;
}

.qty-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: var(--light-gray);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: var(--transition-fast);
}

.qty-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.qty-btn:not(:disabled):hover {
  background: var(--primary);
  color: white;
}

.qty-input {
  width: 50px;
  height: 36px;
  border: none;
  text-align: center;
  font-size: 15px;
  font-weight: 500;
  border-left: 1px solid var(--border-color);
  border-right: 1px solid var(--border-color);
}

.stock-hint {
  font-size: 13px;
  color: var(--primary-dark);
  font-weight: 500;
  margin-left: auto;
}

.action-buttons {
  display: flex;
  gap: 15px;
}

.btn {
  flex: 1;
  padding: 12px 20px;
  border-radius: var(--border-radius-sm);
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  border: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 15px;
}

/* 更新现有的 .btn-primary 样式 */
.btn-primary {
  background: var(--primary) !important;
  color: white;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px rgba(255, 107, 107, 0.2);
}

/* 悬停效果 */
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(255, 107, 107, 0.3);
}

/* 点击效果 */
.btn-primary:active {
  transform: translateY(1px);
  box-shadow: 0 2px 4px rgba(255, 107, 107, 0.3);
}

/* 添加加载动画效果 */
.btn-primary.loading {
  position: relative;
  color: transparent;
}

.btn-primary.loading::after {
  content: "";
  position: absolute;
  width: 20px;
  height: 20px;
  top: 50%;
  left: 50%;
  margin: -10px 0 0 -10px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

/* 禁用状态 */
.btn-primary:disabled {
  background: #cccccc !important;
  transform: none !important;
  box-shadow: none !important;
  cursor: not-allowed;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

/* 更新现有的 .btn-favorite 样式 */
.btn-favorite {
  background: white;
  color: var(--primary);
  border: 1px solid var(--primary);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

/* 悬停效果 */
.btn-favorite:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
}

/* 点击效果 */
.btn-favorite:active {
  transform: translateY(1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* 已收藏状态 */
.btn-favorite.favorited {
  background: var(--primary);
  color: white;
  animation: pulse 0.5s ease;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* 心跳动画 */
@keyframes pulse {
  0% {
    transform: scale(1);
  }
  25% {
    transform: scale(1.1);
  }
  50% {
    transform: scale(0.95);
  }
  75% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

/* 添加点击涟漪效果 */
.btn-favorite::after {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 5px;
  height: 5px;
  background: rgba(255, 107, 107, 0.3);
  opacity: 0;
  border-radius: 100%;
  transform: scale(1, 1) translate(-50%, -50%);
  transform-origin: 50% 50%;
}

.btn-favorite:active::after {
  animation: ripple 0.6s ease-out;
}

@keyframes ripple {
  to {
    transform: scale(20, 20) translate(-50%, -50%);
    opacity: 0;
  }
}

@keyframes highlight {
  0% {
    box-shadow: 0 0 0 0 rgba(255, 107, 107, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(255, 107, 107, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(255, 107, 107, 0);
  }
}


/* 加载状态 */
.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.loading-spinner {
  text-align: center;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 107, 107, 0.2);
  border-radius: 50%;
  border-top-color: var(--primary);
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* 错误状态 */
.error-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.error-message {
  text-align: center;
  max-width: 300px;
}

.error-message i {
  font-size: 40px;
  color: var(--primary);
  margin-bottom: 15px;
}

.error-message p {
  margin-bottom: 20px;
  color: var(--gray);
}

.btn-retry {
  background: var(--primary);
  color: white;
  padding: 8px 20px;
  border-radius: 20px;
}

.btn-retry:hover {
  background: var(--primary-dark);
}

/* 响应式设计 */
@media (max-width: 992px) {
  .product-detail {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .product-gallery {
    position: static;
  }

  .main-image {
    height: 400px;
  }

  .specs-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 576px) {
  .product-info {
    padding: 20px;
  }

  .product-title {
    font-size: 24px;
  }

  .current-price {
    font-size: 28px;
  }

  .action-buttons {
    flex-direction: column;
  }

}
</style>
