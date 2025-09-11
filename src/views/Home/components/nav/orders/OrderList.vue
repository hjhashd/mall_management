<template>
  <div>
    <HomeNavbar />

    <!-- 使用新的全局页面容器样式 -->
    <main class="order-module__page-container">
      <div class="container">
        <h2 class="mb-4 fw-bold text-success">
          <i class="fas fa-list-alt me-2"></i>我的订单
        </h2>

        <!-- 状态切换Tabs -->
        <div class="status-tabs order-module__status-tabs mb-4">
          <ul class="nav nav-pills">
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === null }" @click="changeStatus(null)">
                <i class="fas fa-list me-1"></i>全部
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 1 }" @click="changeStatus(1)">
                <i class="fas fa-wallet me-1"></i>待付款
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 2 }" @click="changeStatus(2)">
                <i class="fas fa-box-open me-1"></i>待发货
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 3 }" @click="changeStatus(3)">
                <i class="fas fa-truck me-1"></i>待收货
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 'pending_review' }" @click="changeStatus('pending_review')">
                <i class="fas fa-comment me-1"></i>待评价
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 'reviewed' }" @click="changeStatus('reviewed')">
                <i class="fas fa-check-circle me-1"></i>已评价
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ 'active': activeStatus === 6 }" @click="changeStatus(6)">
                <i class="fas fa-undo me-1"></i>退款/售后
              </button>
            </li>
          </ul>
        </div>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-success" role="status">
            <span class="visually-hidden">加载中...</span>
          </div>
          <p class="mt-3 text-muted">正在加载订单数据...</p>
        </div>

        <div v-else-if="filteredOrders.length > 0">
          <div v-for="order in filteredOrders" :key="order.orderId" class="order-module__card order-module__list-card">
            <div class="order-module__list-header">
              <div class="d-flex justify-content-between align-items-center">
                <span class="order-id fw-semibold">订单号：{{ order.orderId }}</span>
                <span class="order-module__status-badge" :class="getStatusClass(order)">
                  {{ getStatusText(order) }}
                </span>
              </div>
              <div class="order-time text-muted small mt-1">
                下单时间：{{ formatDate(order.createdAt) }}
              </div>
            </div>

            <div class="order-module__list-items-container">
              <div v-for="item in order.items" :key="item.itemId" class="order-module__list-item">
                <router-link :to="`/product/${item.productId}`">
                  <img :src="item.productImage || defaultImage" class="order-module__product-image" :alt="item.productName" @error="e => e.target.src = defaultImage">
                </router-link>

                <div class="order-module__product-info">
                  <router-link :to="`/product/${item.productId}`" class="text-decoration-none text-dark">
                    <h6 class="mb-1">{{ item.productName }}</h6>
                  </router-link>
                  <p class="text-muted small mb-1">数量：{{ item.quantity }}</p>
                  <p class="fw-bold text-success mb-0">¥{{ item.totalPrice.toFixed(2) }}</p>
                </div>

                <!-- ========================= -->
                <!-- 【核心修改区域】售后状态与操作按钮区域 -->
                <!-- ========================= -->
                <div class="item-actions text-end" style="min-width: 120px;">
                  <!-- 1. 评价逻辑：独立判断，优先显示 -->
                  <!-- 仅当订单状态为已完成(4)时，此区域才可见 -->
                  <div v-if="order.status === 4" class="mb-2">
                    <button v-if="!item.isReviewed" class="btn btn-outline-success btn-sm" @click="commentItem(item)">
                      去评价
                    </button>
                    <span v-else class="text-muted small">
                      已评价
                    </span>
                  </div>

                  <!-- 2. 售后逻辑：独立判断 -->
                  <!-- A. "申请售后"按钮 - 已修复 -->
                  <button v-if="item.itemStatus === 1 && isWithinRefundPeriod(order, item)"
                          class="btn btn-outline-danger btn-sm"
                          @click="goToRefundPage(item.itemId)">
                    申请售后
                  </button>

                  <!-- B. 售后处理状态的显示 -->
                  <div v-else-if="item.itemStatus === 2" class="after-sales-status-display">
                    <span class="text-warning small fw-bold">
                      <i class="fas fa-sync-alt fa-spin me-1"></i>售后处理中
                    </span>
                    <p class="text-muted small mb-0">等待卖家处理</p>
                  </div>
                  <div v-else-if="item.itemStatus === 3" class="after-sales-status-display">
                    <span class="text-success small fw-bold">
                      <i class="fas fa-check-circle me-1"></i>退款成功
                    </span>
                  </div>
                  <div v-else-if="item.itemStatus === 4" class="after-sales-status-display">
                    <span class="text-danger small fw-bold">
                      <i class="fas fa-times-circle me-1"></i>卖家已拒绝
                    </span>
                    <button class="btn btn-primary btn-sm mt-2" @click="handleAppeal(item.afterSaleId, item.itemId)" :disabled="appealingId === item.itemId">
                      <span v-if="appealingId === item.itemId" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
                      <i v-else class="fas fa-gavel me-1"></i>
                      {{ appealingId === item.itemId ? '提交中' : '申请平台介入' }}
                    </button>
                  </div>
                  <div v-else-if="item.itemStatus === 5" class="after-sales-status-display">
                    <span class="text-primary small fw-bold">
                      <i class="fas fa-shield-alt me-1"></i>平台处理中
                    </span>
                    <p class="text-muted small mb-0">3个工作日内将有结果</p>
                  </div>
                  <!-- 超出售后期限的提示 -->
                  <div v-else-if="item.itemStatus === 1 && !isWithinRefundPeriod(order, item)" class="after-sales-status-display">
                    <span class="text-muted small">
                      <i class="fas fa-clock me-1"></i>已超出售后期限
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="order-module__list-footer">
              <div class="d-flex justify-content-between align-items-center flex-wrap">
                <span class="total-amount mb-2 mb-md-0 fs-5 fw-bold text-success">总计：¥{{ order.totalAmount.toFixed(2) }}</span>
                <div v-if="order.items.length === 1 && order.items[0].itemStatus !== 1" class="order-actions-status">
                  <span class="text-warning fw-bold">此订单正在退款/售后中</span>
                </div>
                <div v-else class="order-actions d-flex gap-2 flex-wrap justify-content-end">
                  <button class="btn btn-outline-primary btn-sm" @click="viewOrderDetail(order.orderId)">查看详情</button>
                  <button v-if="order.status === 1" class="btn btn-success btn-sm" @click="payOrder(order.orderId)">立即付款</button>
                  <button v-if="order.status === 3" class="btn btn-success btn-sm" @click="handleConfirmReceive(order.orderId)" :disabled="confirmingId === order.orderId">
                    <span v-if="confirmingId === order.orderId" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
                    {{ confirmingId === order.orderId ? '处理中...' : '确认收货' }}
                  </button>
                  <!-- 订单级别的申请售后按钮也需要相应修改 -->
                  <button v-if="hasRefundableItems(order)" class="btn btn-outline-danger btn-sm" @click="showRefundModal(order)">申请售后</button>
                  <button v-if="order.status === 1" class="btn btn-outline-secondary btn-sm" @click="cancelOrder(order.orderId)">取消订单</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-5">
          <i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i>
          <h4 class="mb-3 text-secondary">该分类下暂无订单</h4>
          <a href="/" class="btn btn-success px-4 rounded-pill">
            <i class="fas fa-shopping-bag me-2"></i>立即去购物
          </a>
        </div>
      </div>
    </main>

    <!-- 退款商品选择模态框 -->
    <div class="modal fade" id="refundModal" tabindex="-1" aria-labelledby="refundModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-light">
            <h5 class="modal-title" id="refundModalLabel"><i class="fas fa-undo me-2 text-danger"></i>选择售后商品</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <p class="text-muted mb-3">请选择需要申请售后的商品：</p>
            <div class="refund-item-list">
              <div v-for="item in selectedOrderForRefund?.items" :key="item.itemId" class="refund-item-card border rounded p-3 mb-3 d-flex align-items-center" :class="{ 'selected-item': selectedItemForRefund?.itemId === item.itemId, 'disabled-item': item.itemStatus !== 1 || !isWithinRefundPeriod(selectedOrderForRefund, item) }" @click="item.itemStatus === 1 && isWithinRefundPeriod(selectedOrderForRefund, item) ? selectRefundItem(item) : null">
                <img :src="item.productImage || defaultImage" class="rounded me-3" style="width: 60px; height: 60px; object-fit: cover;" :alt="item.productName" @error="e => e.target.src = defaultImage">
                <div class="flex-grow-1">
                  <h6 class="mb-1">{{ item.productName }}</h6>
                  <p class="mb-1 text-muted small">数量：{{ item.quantity }}</p>
                  <p class="mb-0 fw-bold text-success">¥{{ item.totalPrice.toFixed(2) }}</p>
                </div>
                <div v-if="item.itemStatus !== 1" class="ms-3 text-end">
                  <span class="badge bg-warning text-dark">已在售后中</span>
                </div>
                <div v-else-if="!isWithinRefundPeriod(selectedOrderForRefund, item)" class="ms-3 text-end">
                  <span class="badge bg-secondary text-light">已超期</span>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i class="fas fa-times me-1"></i>取消</button>
            <button type="button" class="btn btn-danger" :disabled="!selectedItemForRefund" @click="proceedToRefund"><i class="fas fa-arrow-right me-1"></i>去申请</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast 提示 -->
    <div id="simpleToast" class="toast align-items-center text-white border-0 position-fixed bottom-0 end-0 m-3" :class="{'show': showToast, 'bg-success': toastType === 'success', 'bg-danger': toastType === 'error'}" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body">
          <i :class="toastType === 'success' ? 'fas fa-check-circle me-2' : 'fas fa-exclamation-circle me-2'"></i>
          <span v-html="toastMessage"></span>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" @click="showToast = false"></button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import { getOrderList,appealAfterSale, confirmReceive as apiConfirmReceive, cancelOrder as apiCancelOrder } from '@/api/order';
import { Modal } from 'bootstrap';

const router = useRouter();
const allOrders = ref([]);
const loading = ref(true);
const activeStatus = ref(null);
const defaultImage = 'https://placehold.co/80x100/e2e8f0/e2e8f0?text=...';
const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success');
const confirmingId = ref(null);
const appealingId = ref(null); // 控制平台申诉按钮状态
const selectedOrderForRefund = ref(null);
const selectedItemForRefund = ref(null);
const refundModalInstance = ref(null);

// 添加售后期限配置（天）
const REFUND_PERIOD_DAYS = 7; // 假设售后期限为7天

onMounted(async () => {
  await fetchOrders();
});

const fetchOrders = async () => {
  try {
    loading.value = true;
    const response = await getOrderList();
    if (response.data.success) {
      allOrders.value = response.data.data || [];
    } else {
      showToastMessage(response.data.message || '获取订单列表失败', 'error');
    }
  } catch (error) {
    console.error('获取订单列表出错:', error);
    showToastMessage('网络错误，请稍后重试', 'error');
  } finally {
    loading.value = false;
  }
};

// 检查是否在售后期限内
const isWithinRefundPeriod = (order, item) => {
  // 只有已完成或已收货的订单才需要检查售后期限
  if (order.status !== 3 && order.status !== 4) return true;

  const orderDate = new Date(order.createdAt);
  const currentDate = new Date();
  const diffTime = Math.abs(currentDate - orderDate);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  return diffDays <= REFUND_PERIOD_DAYS;
};

// 检查订单是否有可申请售后的商品
const hasRefundableItems = (order) => {
  return order.items.some(item =>
      item.itemStatus === 1 && isWithinRefundPeriod(order, item)
  );
};

const changeStatus = (status) => {
  activeStatus.value = status;
};

const filteredOrders = computed(() => {
  if (activeStatus.value === null) return allOrders.value;
  if (activeStatus.value === 'pending_review') {
    return allOrders.value.filter(order =>
        order.status === 4 && order.items.some(item => !item.isReviewed)
    );
  } else if (activeStatus.value === 'reviewed') {
    return allOrders.value.filter(order =>
        order.status === 4 && order.items.every(item => item.isReviewed)
    );
  } else if (activeStatus.value === 6) {
    return allOrders.value.filter(order => {
      const isOrderInRefund = [6, 7].includes(order.status);
      const hasItemInRefund = order.items.some(item => item.itemStatus !== 1);
      return isOrderInRefund || hasItemInRefund;
    });
  }
  return allOrders.value.filter(order => order.status === activeStatus.value);
});

const getStatusClass = (order) => {
  const statusMap = {
    1: 'order-module__status-badge--pending',
    2: 'order-module__status-badge--shipped',
    3: 'order-module__status-badge--shipped',
    4: 'order-module__status-badge--completed',
    5: 'order-module__status-badge--cancelled',
    6: 'order-module__status-badge--pending',
    7: 'order-module__status-badge--cancelled',
  };
  if (order.status === 4 && order.items.some(item => !item.isReviewed)) {
    return 'order-module__status-badge--review';
  }
  if (order.status === 4 && order.items.every(item => item.isReviewed)) {
    return 'order-module__status-badge--completed';
  }
  return statusMap[order.status] || 'order-module__status-badge--cancelled';
};

const getStatusText = (order) => {
  const statusMap = { 1: '待付款', 2: '待发货', 3: '待收货', 4: '已完成', 5: '已取消', 6: '退款中', 7: '已退款' };
  if (order.status === 4) {
    if (!order.items || order.items.length === 0) return '已完成';
    const allReviewed = order.items.every(item => item.isReviewed);
    return allReviewed ? '已评价' : '待评价';
  }
  if ([2, 3, 4].includes(order.status) && order.items.some(item => item.itemStatus !== 1)) {
    return `${statusMap[order.status]} (部分售后中)`;
  }
  return statusMap[order.status] || '未知状态';
};

const formatDate = (dateString) => {
  if (!dateString) return '未知时间';
  return new Date(dateString).toLocaleString('zh-CN', { hour12: false });
};

const viewOrderDetail = (orderId) => router.push(`/order/${orderId}`);
const payOrder = (orderId) => router.push(`/payment/${orderId}`);
const commentItem = (item) => router.push(`/product/${item.productId}/reviews?orderItemId=${item.itemId}`);
const goToRefundPage = (itemId) => router.push(`/refund/${itemId}`);

const handleConfirmReceive = async (orderId) => {
  if (confirmingId.value) return;
  confirmingId.value = orderId;
  try {
    const response = await apiConfirmReceive(orderId);
    if (response.data.success) {
      showToastMessage('确认收货成功！', 'success');
      await fetchOrders();
    } else {
      showToastMessage(response.data.message || '操作失败，请重试', 'error');
    }
  } catch (error) {
    console.error('确认收货失败:', error);
    showToastMessage('网络错误，请稍后重试', 'error');
  } finally {
    confirmingId.value = null;
  }
};

const cancelOrder = async (orderId) => {
  try {
    const response = await apiCancelOrder(orderId);
    if (response.data.success) {
      showToastMessage('订单已取消', 'success');
      await fetchOrders();
    } else {
      showToastMessage(response.data.message || '取消失败', 'error');
    }
  } catch (error) {
    showToastMessage('操作失败，请稍后重试', 'error');
  }
};

const showRefundModal = (order) => {
  selectedOrderForRefund.value = order;
  selectedItemForRefund.value = null;
  const modalEl = document.getElementById('refundModal');
  if (modalEl) {
    if (!refundModalInstance.value) {
      refundModalInstance.value = new Modal(modalEl);
    }
    refundModalInstance.value.show();
  }
};

const selectRefundItem = (item) => {
  selectedItemForRefund.value = item;
};

const proceedToRefund = () => {
  if (selectedItemForRefund.value) {
    if (refundModalInstance.value) {
      refundModalInstance.value.hide();
    }
    router.push(`/refund/${selectedItemForRefund.value.itemId}`);
  }
};

// 平台申诉
const handleAppeal = async (afterSaleId, itemId) => {
  if (!afterSaleId) {
    showToastMessage('无法申诉，售后信息丢失', 'error');
    return;
  }
  if (appealingId.value) return;
  appealingId.value = itemId;

  try {
    const response = await appealAfterSale(afterSaleId);
    if (response.data.success) {
      showToastMessage('申诉已提交，请耐心等待平台处理结果。', 'success');
      const order = allOrders.value.find(o => o.items.some(i => i.itemId === itemId));
      if (order) {
        const item = order.items.find(i => i.itemId === itemId);
        if (item) {
          item.itemStatus = 5; // 设置为平台介入中
        }
      }
    } else {
      showToastMessage(response.data.message || '申诉失败', 'error');
    }
  } catch (error) {
    console.error('申诉失败:', error);
    showToastMessage('网络错误，请稍后重试', 'error');
  } finally {
    appealingId.value = null;
  }
};

const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;
  setTimeout(() => {
    showToast.value = false;
  }, 3000);
};
</script>

<style scoped>
.item-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: center;
}

.after-sales-status-display {
  text-align: right;
}

.refund-item-card.disabled-item {
  opacity: 0.6;
  cursor: not-allowed;
}

.refund-item-card.selected-item {
  border-color: #198754 !important;
  background-color: rgba(25, 135, 84, 0.1);
}
</style>
