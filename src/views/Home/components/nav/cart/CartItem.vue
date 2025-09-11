<template>
  <div class="cart-item"
       :data-cart-id="item.cartId"
       :data-product-id="item.productId || 'INVALID'">
    <div class="row align-items-center">
      <!-- 商品封面 -->
      <div class="col-3">
        <img :src="getProductImage()" class="product-thumbnail" :alt="getProductTitle()">
      </div>

      <!-- 商品信息 -->
      <div class="col-5">
        <h5 class="mb-2 fw-semibold">{{ getProductTitle() }}</h5>
        <p class="text-muted small mb-2">{{ getProductAuthor() }}</p>
        <div class="d-flex align-items-center gap-2">
          <span class="badge bg-success bg-opacity-10 text-success" v-if="getProductCondition()">
            {{ getProductCondition() }}成新
          </span>
          <span class="stock-info">库存：{{ getProductStock() }}</span>
        </div>
      </div>

      <!-- 操作区域 -->
      <div class="col-4">
        <div class="d-flex align-items-center justify-content-end gap-3">
          <!-- 数量控件 - 采用类似ProductInfo的逻辑 -->
          <div class="quantity-control">
            <button class="quantity-btn" @click="updateQuantity(-1)" :disabled="item.quantity <= 1">
              <i class="fas fa-minus"></i>
            </button>
            <input type="number"
                   :id="'quantity-' + item.cartId"
                   v-model.number="localQuantity"
                   min="1"
                   :max="getProductStock()"
                   class="quantity-input"
                   @change="handleInputChange"
                   @blur="handleBlur">
            <button class="quantity-btn" @click="updateQuantity(1)" :disabled="item.quantity >= getProductStock()">
              <i class="fas fa-plus"></i>
            </button>
          </div>

          <!-- 价格和删除 -->
          <div class="text-end">
            <div class="price-tag" :id="'price-' + item.cartId">
              ¥{{ (getProductPrice() * item.quantity).toFixed(2) }}
            </div>
            <button class="btn btn-link delete-btn p-0 small trash-animation"
                    @click="$emit('delete-item', item.cartId)">
              <i class="fas fa-trash me-1"></i>删除
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  item: {
    type: Object,
    required: true,
    default: () => ({})
  }
});

const emit = defineEmits(['update-quantity', 'delete-item']);

// 本地数量状态，用于输入框
const localQuantity = ref(props.item.quantity);

// 监听props变化，同步本地数量
watch(() => props.item.quantity, (newQuantity) => {
  localQuantity.value = newQuantity;
});

// 获取商品图片
const getProductImage = () => {
  if (props.item.images && props.item.images.length > 0) {
    return props.item.images[0].imageUrl;
  }
  if (props.item.book && props.item.book.coverImage) {
    return props.item.book.coverImage;
  }
  return 'https://via.placeholder.com/100x120?text=商品';
};

// 获取商品标题
const getProductTitle = () => {
  return props.item.title || props.item.book?.title || '未知商品';
};

// 获取商品作者/品牌
const getProductAuthor = () => {
  return props.item.author || props.item.book?.author || props.item.brand || '未知';
};

// 获取商品成色
const getProductCondition = () => {
  return props.item.condition || props.item.book?.condition || '';
};

// 获取商品库存
const getProductStock = () => {
  return props.item.stock || props.item.book?.stock || 0;
};

// 获取商品价格
const getProductPrice = () => {
  return props.item.price || props.item.currentPrice || props.item.book?.price || 0;
};

// 更新数量 - 采用类似ProductInfo的逻辑
const updateQuantity = (change) => {
  const newValue = localQuantity.value + change;

  // 检查库存限制
  if (newValue >= 1 && newValue <= getProductStock()) {
    localQuantity.value = newValue;
    emit('update-quantity', props.item.cartId, newValue);
  }
};

// 输入框改变时处理
const handleInputChange = () => {
  const newValue = parseInt(localQuantity.value);

  if (isNaN(newValue) || newValue < 1) {
    localQuantity.value = 1;
    emit('update-quantity', props.item.cartId, 1);
  } else if (newValue > getProductStock()) {
    localQuantity.value = getProductStock();
    emit('update-quantity', props.item.cartId, getProductStock());
  } else {
    emit('update-quantity', props.item.cartId, newValue);
  }
};

// 输入框失去焦点时处理
const handleBlur = () => {
  if (localQuantity.value !== props.item.quantity) {
    handleInputChange();
  }
};
</script>

<style>
/* 复用原有的样式 */
:root {
  --primary-color: #5c9e53; /* 柔和绿色 */
  --secondary-color: #f7faf5; /* 更浅的淡灰绿背景 */
  --hover-color: #e6f0e6; /* 悬浮背景淡绿 */
  --text-muted-color: #6b7a63; /* 柔和的文字灰绿 */
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
}

.cart-item {
  background: #fff;
  border-radius: 16px;
  margin-bottom: 1.8rem;
  padding: 1.8rem 2rem;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
  transition: all 0.35s ease;
}

.cart-item:hover {
  box-shadow: 0 6px 20px rgba(92, 158, 83, 0.25);
  transform: translateY(-4px);
}

.quantity-control {
  width: 150px;
  border: 1.5px solid var(--border-color);
  border-radius: 30px;
  background: #fafefa;
  overflow: hidden;
  box-shadow: inset 0 0 5px rgb(141 181 128 / 0.1);
  display: flex;
  align-items: center;
}

.quantity-btn {
  width: 40px;
  border: none;
  background: transparent;
  color: var(--primary-color);
  font-weight: 600;
  font-size: 1.25rem;
  line-height: 1;
  transition: background-color 0.3s ease, color 0.3s ease;
  cursor: pointer;
  user-select: none;
}

.quantity-btn:hover:not(:disabled) {
  background: var(--hover-color);
  border-radius: 8px;
}

.quantity-btn:disabled {
  color: #ccc;
  cursor: not-allowed;
}

.quantity-input {
  flex-grow: 1;
  border: none;
  text-align: center;
  font-weight: 600;
  font-size: 1rem;
  background: transparent;
  color: #3b4a30;
  outline-offset: 2px;
  user-select: text;
}

.quantity-input::-webkit-inner-spin-button,
.quantity-input::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.price-tag {
  color: var(--primary-color);
  font-weight: 700;
  font-size: 1.35rem;
  user-select: none;
}

.product-thumbnail {
  width: 100px;
  height: 120px;
  object-fit: contain;
  border-radius: 10px;
  padding: 0.5rem;
  background: white;
  border: 1.5px solid var(--border-color);
  box-shadow: 0 1px 5px rgb(92 158 83 / 0.1);
  transition: box-shadow 0.3s ease;
  user-select: none;
}

.product-thumbnail:hover {
  box-shadow: 0 4px 15px rgb(92 158 83 / 0.25);
}

.delete-btn {
  color: #d9534f !important;
  opacity: 0.85;
  font-weight: 600;
  transition: all 0.3s ease;
  cursor: pointer;
  user-select: none;
}

.delete-btn:hover {
  opacity: 1;
  transform: scale(1.12);
}

.stock-info {
  font-size: 0.9rem;
  color: var(--text-muted-color);
  user-select: none;
}

.trash-animation {
  transition: transform 0.3s ease;
  transform-origin: center;
}

.trash-animation:hover {
  transform: rotate(-15deg) scale(1.1);
}

/* 小屏幕适配 */
@media (max-width: 768px) {
  .quantity-control {
    width: 120px;
  }

  .product-thumbnail {
    width: 80px;
    height: 100px;
  }

  .price-tag {
    font-size: 1.1rem;
  }
}
</style>
