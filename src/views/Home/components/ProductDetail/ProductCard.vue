<template>
  <!-- 为整个卡片容器添加点击事件 -->
  <div class="product-card" @click="goToDetail">
    <div class="product-image">
      <img :src="product.image" :alt="product.name" class="product-img">
      <span :class="['status-badge', statusClass]">{{ product.statusText }}</span>
    </div>

    <div class="product-info">
      <h3 class="product-name" :title="product.name">{{ product.name }}</h3>
      <div class="product-meta">
        <span class="product-price">¥{{ product.price.toFixed(2) }}</span>
        <span class="product-stock">库存: {{ product.stock }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
// 1. 导入 useRouter
import { useRouter } from 'vue-router';

const props = defineProps({
  product: {
    type: Object,
    required: true,
    default: () => ({
      id: 0,
      name: '商品名称',
      price: 0,
      image: '',
      stock: 0,
      status: 1,
      statusText: '上架中'
    })
  }
});

// 2. 获取 router 实例
const router = useRouter();

// 3. 定义跳转方法
const goToDetail = () => {
  // 检查 product.id 是否存在，以防万一
  if (props.product && props.product.id) {
    router.push(`/product/${props.product.id}`);
  }
};

// 根据商品状态返回不同的CSS类
const statusClass = computed(() => {
  switch (props.product.status) {
    case 1:
      return 'status-on-sale';   // 上架中
    case 2:
      return 'status-delisted';  // 已下架
    case 3:
      return 'status-sold-out';  // 售罄
    case 4:
      return 'status-in-review'; // 待审核
    default:
      return '';
  }
});
</script>

<style scoped>
.product-card {
  background-color: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  /* 4. 添加鼠标悬停时的手型光标，提升用户体验 */
  cursor: pointer;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 20px rgba(0, 0, 0, 0.1);
}

.product-image {
  position: relative;
  height: 180px;
  overflow: hidden;
}

.product-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.status-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  color: white;
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 20px;
  font-weight: 500;
}

.status-on-sale {
  background-color: #28a745;
}

/* 绿色 */
.status-delisted {
  background-color: #6c757d;
}

/* 灰色 */
.status-sold-out {
  background-color: #dc3545;
}

/* 红色 */
.status-in-review {
  background-color: #ffc107;
}

/* 黄色 */

.product-info {
  padding: 15px;
  flex-grow: 1;
}

.product-name {
  font-size: 15px;
  color: #333;
  margin-bottom: 10px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.4;
}

.product-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-price {
  font-size: 16px;
  font-weight: 700;
  color: #FF6B6B;
}

.product-stock {
  font-size: 13px;
  color: #888;
}
</style>
