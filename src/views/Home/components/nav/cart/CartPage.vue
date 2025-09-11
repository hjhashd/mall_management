<template>
  <div>
    <HomeNavbar />
    <main class="cart-container">
      <div class="container">
        <h2 class="mb-4 fw-bold text-success">
          <i class="fas fa-shopping-cart me-2"></i>我的购物车
        </h2>

        <!-- 加载状态 -->
        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-success" role="status">
            <span class="visually-hidden">加载中...</span>
          </div>
          <p class="mt-3 text-muted">正在加载购物车数据...</p>
        </div>

        <!-- 购物车内容 -->
        <div v-else-if="cartItems.length > 0" class="row">
          <!-- 商品列表 -->
          <div class="col-lg-8">
            <div class="cart-items-container">
              <CartItem
                  v-for="item in cartItems"
                  :key="item.cartId"
                  :item="item"
                  @update-quantity="updateQuantity"
                  @delete-item="deleteItem"
              />
            </div>

            <!-- 清空购物车按钮 -->
            <div class="text-center mt-4">
              <button
                class="btn btn-outline-danger"
                @click="clearCart"
                :disabled="clearing"
              >
                <i class="fas fa-trash me-2"></i>
                {{ clearing ? '清空中...' : '清空购物车' }}
              </button>
            </div>
          </div>

          <!-- 结算摘要 -->
          <div class="col-lg-4">
            <CartSummary
                :total-quantity="totalQuantity"
                :total-price="totalPrice"
                :loading="processing"
                @handle-payment="handlePayment"
            />
          </div>
        </div>

        <!-- 空购物车提示 -->
        <div class="text-center py-5" v-else>
          <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
          <h4 class="mb-3 text-secondary">您的购物车还是空的</h4>
          <a href="/" class="btn btn-success px-4 rounded-pill">
            <i class="fas fa-book-open me-2"></i>立即去选购
          </a>
        </div>
      </div>
    </main>

    <!-- 提示框 -->
    <div id="simpleToast" class="toast align-items-center text-white border-0 position-fixed bottom-0 end-0 m-3"
         :style="{ background: toastType === 'success' ? '#28a745' : '#dc3545', display: showToast ? 'block' : 'none' }">
      <div class="d-flex">
        <div class="toast-body">
          <i :class="toastType === 'success' ? 'fas fa-check-circle me-2' : 'fas fa-exclamation-circle me-2'"></i>
          <span v-html="toastMessage"></span>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto"
                @click="showToast = false"></button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import CartItem from './CartItem.vue';
import CartSummary from './CartSummary.vue';
import { Modal } from 'bootstrap';
import {
  getCartItems,
  updateCartItemQuantity,
  deleteCartItem,
  clearCart as apiClearCart
} from '@/api/cart';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";

// 初始化路由
const router = useRouter();

// 响应式数据
const cartItems = ref([]);
const loading = ref(true);
const clearing = ref(false);
const processing = ref(false);

// 提示框状态
const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success');


onMounted(() => {
  fetchCartItems();
});

// 获取购物车数据
const fetchCartItems = async () => {
  try {
    loading.value = true;
    const response = await getCartItems();

    if (response.data.success) {
      cartItems.value = response.data.data || [];
    } else {
      console.error('获取购物车失败:', response.data.message);
      showToastMessage('获取购物车数据失败', 'error');
    }
  } catch (error) {
    console.error('获取购物车出错:', error);
    showToastMessage('网络错误，请稍后重试', 'error');
  } finally {
    loading.value = false;
  }
};

// 计算属性 - 总数量和总价格
const totalQuantity = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.quantity, 0);
});

const totalPrice = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (item.price * item.quantity), 0).toFixed(2);
});

// 更新数量 - 采用类似ProductInfo的逻辑
const updateQuantity = async (cartId, newQuantity) => {
  const item = cartItems.value.find(item => item.cartId === cartId);
  if (!item) return;

  // 检查库存限制
  if (newQuantity < 1) {
    showToastMessage('商品数量不能少于1', 'error');
    return;
  }

  if (newQuantity > item.stock) {
    showToastMessage(`库存不足，最多只能购买${item.stock}件`, 'error');
    return;
  }

  try {
    const response = await updateCartItemQuantity(cartId, newQuantity);

    if (response.data.success) {
      item.quantity = newQuantity;
      showToastMessage('数量已更新', 'success');
    } else {
      showToastMessage('更新数量失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('更新数量出错:', error);
    showToastMessage('更新数量失败，请稍后重试', 'error');
  }
};

// 删除商品
const deleteItem = async (cartId) => {
  if (!confirm('确定要删除该商品吗？')) return;

  try {
    const response = await deleteCartItem(cartId);

    if (response.data.success) {
      const index = cartItems.value.findIndex(item => item.cartId === cartId);
      if (index !== -1) {
        cartItems.value.splice(index, 1);
        showToastMessage('删除成功', 'success');
      }
    } else {
      showToastMessage('删除失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('删除商品出错:', error);
    showToastMessage('删除失败，请稍后重试', 'error');
  }
};

// 清空购物车
const clearCart = async () => {
  if (!confirm('确定要清空整个购物车吗？此操作不可恢复。')) return;

  try {
    clearing.value = true;
    const response = await apiClearCart();

    if (response.data.success) {
      cartItems.value = [];
      showToastMessage('购物车已清空', 'success');
    } else {
      showToastMessage('清空购物车失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('清空购物车出错:', error);
    showToastMessage('清空购物车失败，请稍后重试', 'error');
  } finally {
    clearing.value = false;
  }
};

// 显示提示信息
const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;
  setTimeout(() => {
    showToast.value = false;
  }, 3000);
};

// 处理支付 - 修改为跳转到订单确认页
const handlePayment = () => {
  if (cartItems.value.length === 0) {
    showToastMessage('购物车为空', 'error');
    return;
  }

  // 将购物车数据存储到localStorage作为备用
  localStorage.setItem('checkoutCart', JSON.stringify(cartItems.value));

  // 导航到订单确认页，并传递购物车数据
  router.push({
    path: '/order-confirm',
    state: {
      cartItems: cartItems.value
    }
  });
};

</script>

<style scoped>
/* 基础样式 */
.cart-container {
  background: var(--secondary-color);
  min-height: 70vh;
  padding: 3rem 0 2rem 0;
  padding-top: 80px;
}

.cart-items-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/* 加载动画样式 */
.spinner-border {
  width: 3rem;
  height: 3rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .cart-container {
    padding: 2rem 0 1rem 0;
    padding-top: 60px;
  }

  .container {
    padding: 0 15px;
  }
}
</style>
