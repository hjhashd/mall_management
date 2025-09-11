<template>
  <div class="order-management-container">
    <!-- 头部：标题、筛选和排序 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <i class="fas fa-clipboard-list"></i>
          订单管理
        </h1>
        <p class="page-subtitle">管理和跟踪所有订单状态</p>
      </div>
      <div class="header-actions">
        <div class="sort-control">
          <label class="sort-label">
            <i class="fas fa-sort-amount-down"></i>
            排序方式
          </label>
          <select v-model="sortOption" class="sort-dropdown">
            <option value="date_desc">按订单时间倒序</option>
            <option value="date_asc">按订单时间正序</option>
            <option value="amount_desc">按订单金额倒序</option>
            <option value="amount_asc">按订单金额正序</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 筛选标签 -->
    <div class="filter-section">
      <div class="filter-tabs">
        <button
            v-for="tab in filterTabs"
            :key="tab.status"
            class="filter-tab"
            :class="{ active: activeFilter === tab.status }"
            @click="changeFilter(tab.status)"
        >
          <i :class="tab.icon"></i>
          <span class="tab-label">{{ tab.label }}</span>
          <span v-if="getOrderCount(tab.status) > 0" class="count-badge">
            {{ getOrderCount(tab.status) }}
          </span>
        </button>
      </div>
    </div>

    <!-- 订单列表 -->
    <div class="orders-section">
      <!-- 修改说明: 增加加载中状态 -->
      <div v-if="isLoading" class="loading-state">
        <div class="spinner"></div>
        <p>正在加载订单...</p>
      </div>

      <div v-else-if="paginatedOrders.length === 0" class="empty-state">
        <div class="empty-icon">
          <i class="fas fa-file-invoice-dollar"></i>
        </div>
        <h3>暂无订单数据</h3>
        <p>当前筛选条件下没有找到相关订单</p>
      </div>

      <div
          v-for="(order, index) in paginatedOrders"
          :key="order.orderId"
          class="order-card"
          :style="{ '--animation-delay': `${index * 0.1}s` }"
      >
        <!-- 卡片头部 -->
        <div class="card-header">
          <div class="order-info">
            <span class="order-id">
              <i class="fas fa-hashtag"></i>
              {{ order.orderId }}
            </span>
            <span class="order-time">
              <i class="fas fa-clock"></i>
              {{ formatDate(order.createdAt) }}
            </span>
          </div>
          <div class="order-status">
            <span class="status-badge" :class="getStatusInfo(order.status).className">
              <i :class="getStatusInfo(order.status).icon"></i>
              {{ getStatusInfo(order.status).text }}
            </span>
          </div>
        </div>

        <!-- 卡片主体 -->
        <div class="card-body">
          <div class="user-section">
            <div class="user-info">
              <div class="info-row">
                <i class="fas fa-user"></i>
                <span class="label">买家:</span>
                <!-- 修改说明: 使用从后端获取的真实数据 -->
                <span class="value">{{ order.buyerUsername }}</span>
              </div>
              <div class="info-row">
                <i class="fas fa-store"></i>
                <span class="label">卖家:</span>
                <span class="value">{{ order.sellerUsername }}</span>
              </div>
            </div>
          </div>

          <div class="amount-section">
            <div class="total-amount">¥{{ formatCurrency(order.totalAmount) }}</div>
            <div class="item-count">共 {{ order.items ? order.items.length : 0 }} 件商品</div>
          </div>

          <div class="actions-section">
            <div class="action-buttons">
              <button class="btn btn-outline" @click="openDetailsModal(order)">
                <i class="fas fa-eye"></i>
                查看详情
              </button>
              <!-- 修改说明: 为按钮绑定真实操作事件 -->
              <button v-if="order.status === 1" class="btn btn-primary" @click="handlePayment(order.orderId)">
                <i class="fas fa-credit-card"></i>
                去支付
              </button>
              <button v-if="order.status === 2" class="btn btn-warning" @click="handleShip(order.orderId)">
                <i class="fas fa-shipping-fast"></i>
                填写运单号
              </button>
              <button v-if="order.status === 3" class="btn btn-success" @click="handleConfirmReceive(order.orderId)">
                <i class="fas fa-check"></i>
                确认收货
              </button>
              <button v-if="order.status === 1" class="btn btn-danger-outline" @click="handleCancelOrder(order.orderId)">
                <i class="fas fa-times"></i>
                取消订单
              </button>
              <button v-if="order.status === 4 && order.items && !order.items.every(i => i.isReviewed)" class="btn btn-info" @click="handleReview(order.orderId)">
                <i class="fas fa-star"></i>
                评价
              </button>
              <button v-if="[3, 4].includes(order.status)" class="btn btn-outline" @click="handleViewLogistics(order.orderId)">
                <i class="fas fa-truck"></i>
                查看物流
              </button>
              <button class="btn btn-ghost expand-toggle" @click="toggleOrderDetails(order.orderId)">
                {{ expandedOrderId === order.orderId ? '收起' : '展开' }}
                <i class="fas" :class="expandedOrderId === order.orderId ? 'fa-chevron-up' : 'fa-chevron-down'"></i>
              </button>
            </div>
          </div>
        </div>

        <!-- 展开的商品详情 -->
        <div v-if="expandedOrderId === order.orderId" class="order-details">
          <div class="details-header">
            <h4>
              <i class="fas fa-boxes"></i>
              商品明细
            </h4>
          </div>
          <div class="items-list">
            <div v-for="item in order.items" :key="item.itemId" class="order-item">
              <div class="item-image">
                <img :src="item.productImage" :alt="item.productName"/>
              </div>
              <div class="item-content">
                <h5 class="product-name">{{ item.productName }}</h5>
                <p class="product-spec">成色: {{ item.condition }}新</p>
              </div>
              <div class="item-price">
                <div class="unit-price">¥{{ formatCurrency(item.unitPrice) }}</div>
                <div class="quantity">x {{ item.quantity }}</div>
              </div>
              <div class="item-status">
                <span class="item-status-badge" :class="getItemStatusInfo(item.itemStatus).className">
                  {{ getItemStatusInfo(item.itemStatus).text }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分页控件 -->
    <div v-if="totalPages > 1" class="pagination-wrapper">
      <div class="pagination">
        <button
            class="pagination-btn"
            @click="changePage(pagination.currentPage - 1)"
            :disabled="pagination.currentPage <= 1"
        >
          <i class="fas fa-chevron-left"></i>
        </button>

        <div class="pagination-info">
          第 {{ pagination.currentPage }} / {{ totalPages }} 页
          <span class="total-info">(共 {{ sortedAndFilteredOrders.length }} 条记录)</span>
        </div>

        <button
            class="pagination-btn"
            @click="changePage(pagination.currentPage + 1)"
            :disabled="pagination.currentPage >= totalPages"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>
    </div>

    <!-- 订单详情模态框 -->
    <div v-if="isDetailsModalOpen" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-container">
        <div class="modal-header">
          <h2>
            <i class="fas fa-file-invoice"></i>
            订单详情
          </h2>
          <button class="modal-close" @click="closeDetailsModal">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <div v-if="selectedOrder" class="modal-body">
          <div class="details-grid">
            <div class="detail-group">
              <label>订单号</label>
              <div class="detail-value">{{ selectedOrder.orderId }}</div>
            </div>
            <div class="detail-group">
              <label>订单状态</label>
              <div class="detail-value">
                <span class="status-badge" :class="getStatusInfo(selectedOrder.status).className">
                  <i :class="getStatusInfo(selectedOrder.status).icon"></i>
                  {{ getStatusInfo(selectedOrder.status).text }}
                </span>
              </div>
            </div>
            <div class="detail-group">
              <label>订单总额</label>
              <div class="detail-value amount">¥{{ formatCurrency(selectedOrder.totalAmount) }}</div>
            </div>
            <div class="detail-group">
              <label>支付方式</label>
              <div class="detail-value">{{ selectedOrder.paymentMethod || '未支付' }}</div>
            </div>
            <div class="detail-group full-width">
              <label>收货信息</label>
              <div class="detail-value">
                <div class="address-info">
                  <div><strong>{{ selectedOrder.receiverName }}</strong></div>
                  <div>{{ selectedOrder.receiverPhone }}</div>
                  <div>{{ selectedOrder.shippingAddress }}</div>
                </div>
              </div>
            </div>
            <div class="detail-group full-width">
              <label>物流信息</label>
              <div class="detail-value">
                <div v-if="selectedOrder.trackingNumber" class="logistics-info">
                  <div><strong>{{ selectedOrder.shippingCompany }}</strong></div>
                  <div>运单号: {{ selectedOrder.trackingNumber }}</div>
                </div>
                <div v-else class="no-logistics">暂无物流信息</div>
              </div>
            </div>
            <div class="detail-group full-width">
              <label>买家备注</label>
              <div class="detail-value">
                {{ selectedOrder.userRemark || '无备注' }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
// 修改说明: 导入真实API
import { getOrderList, confirmReceive, cancelOrder } from '@/api/order';

// --- 状态管理 ---
const allOrders = ref([]); // 存储从后端获取的所有订单
const isLoading = ref(true); // 加载状态
const activeFilter = ref(0); // 默认显示全部
const sortOption = ref('date_desc');
const pagination = ref({ currentPage: 1, pageSize: 5 });
const expandedOrderId = ref(null);
const isDetailsModalOpen = ref(false);
const selectedOrder = ref(null);


// --- API 调用 ---
const fetchOrders = async () => {
  isLoading.value = true;
  try {
    const response = await getOrderList();
    if (response.data.success) {
      // 后端返回的数据字段是驼峰, e.g. orderId, totalAmount
      allOrders.value = response.data.data;
    } else {
      console.error("获取订单失败:", response.data.message);
      // 在这里可以添加用户提示，例如使用一个通知组件
    }
  } catch (error) {
    console.error("请求订单列表时出错:", error);
  } finally {
    isLoading.value = false;
  }
};

// --- 生命周期钩子 ---
onMounted(() => {
  fetchOrders(); // 组件挂载时获取真实数据
});


// --- 计算属性 ---
const filterTabs = ref([
  { status: 0, label: '全部', icon: 'fas fa-list-ul' },
  { status: 1, label: '待付款', icon: 'fas fa-wallet' },
  { status: 2, label: '待发货', icon: 'fas fa-box-open' },
  { status: 3, label: '待收货', icon: 'fas fa-truck' },
  { status: 4, label: '已完成', icon: 'fas fa-check-circle' },
  { status: 5, label: '已取消', icon: 'fas fa-times-circle' },
]);

const getOrderCount = (status) => {
  if (status === 0) return allOrders.value.length;
  return allOrders.value.filter(o => o.status === status).length;
};

const sortedAndFilteredOrders = computed(() => {
  let result = activeFilter.value === 0
      ? [...allOrders.value]
      : allOrders.value.filter(order => order.status === activeFilter.value);

  switch (sortOption.value) {
    case 'date_desc':
      result.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      break;
    case 'date_asc':
      result.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
      break;
    case 'amount_desc':
      result.sort((a, b) => b.totalAmount - a.totalAmount);
      break;
    case 'amount_asc':
      result.sort((a, b) => a.totalAmount - b.totalAmount);
      break;
  }
  return result;
});

const totalPages = computed(() => Math.ceil(sortedAndFilteredOrders.value.length / pagination.value.pageSize));

const paginatedOrders = computed(() => {
  const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
  const end = start + pagination.value.pageSize;
  return sortedAndFilteredOrders.value.slice(start, end);
});

// --- 方法 ---
const changeFilter = (status) => {
  activeFilter.value = status;
  pagination.value.currentPage = 1;
};

const getStatusInfo = (status) => {
  const statuses = {
    1: { text: '待付款', className: 'status-pending', icon: 'fas fa-wallet' },
    2: { text: '待发货', className: 'status-processing', icon: 'fas fa-box-open' },
    3: { text: '待收货', className: 'status-shipping', icon: 'fas fa-truck' },
    4: { text: '已完成', className: 'status-completed', icon: 'fas fa-check-circle' },
    5: { text: '已取消', className: 'status-cancelled', icon: 'fas fa-times-circle' },
    6: { text: '退款中', className: 'status-refunding', icon: 'fas fa-undo' },
    7: { text: '已退款', className: 'status-refunded', icon: 'fas fa-history' },
  };
  return statuses[status] || { text: '未知', className: 'status-unknown', icon: 'fas fa-question-circle' };
};

const getItemStatusInfo = (status) => {
  const statuses = {
    1: { text: '正常', className: 'item-status-normal' },
    2: { text: '售后中', className: 'item-status-after-sale' },
    3: { text: '已退款', className: 'item-status-refunded' },
    4: { text: '卖家拒绝', className: 'item-status-rejected' },
    5: { text: '平台介入', className: 'item-status-platform' },
  };
  return statuses[status] || { text: '未知', className: 'item-status-unknown' };
};

const formatDate = (dateString) => new Date(dateString).toLocaleString('zh-CN');
const formatCurrency = (amount) => (amount ? amount.toFixed(2) : '0.00');

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
  }
};

const toggleOrderDetails = (orderId) => {
  expandedOrderId.value = expandedOrderId.value === orderId ? null : orderId;
};

const openDetailsModal = (order) => {
  selectedOrder.value = order;
  isDetailsModalOpen.value = true;
};
const closeDetailsModal = () => isDetailsModalOpen.value = false;

// --- 修改说明: 新增订单操作处理函数 ---
const handleConfirmReceive = async (orderId) => {
  if (!confirm('您确定要确认收货吗？')) return;
  try {
    const response = await confirmReceive(orderId);
    if (response.data.success) {
      alert('操作成功！');
      fetchOrders(); // 重新加载数据
    } else {
      alert(`操作失败: ${response.data.message}`);
    }
  } catch (error) {
    alert(`请求失败: ${error.message}`);
  }
};

const handleCancelOrder = async (orderId) => {
  if (!confirm('您确定要取消这个订单吗？此操作不可恢复。')) return;
  try {
    const response = await cancelOrder(orderId);
    if (response.data.success) {
      alert('订单已取消！');
      fetchOrders(); // 重新加载数据
    } else {
      alert(`操作失败: ${response.data.message}`);
    }
  } catch (error) {
    alert(`请求失败: ${error.message}`);
  }
};

// 以下为占位函数，您可以根据业务逻辑补充实现
const handlePayment = (orderId) => alert(`功能待开发：支付订单 ${orderId}`);
const handleShip = (orderId) => alert(`功能待开发：为订单 ${orderId} 填写运单号`);
const handleReview = (orderId) => alert(`功能待开发：评价订单 ${orderId}`);
const handleViewLogistics = (orderId) => alert(`功能待开发：查看订单 ${orderId} 的物流`);

</script>

<style scoped>
/* 增加一个危险操作按钮的样式 */
.btn-danger-outline {
  background: transparent;
  color: #e74c3c;
  border-color: #e74c3c;
}
.btn-danger-outline:hover {
  background: #e74c3c;
  color: white;
}
/* 增加加载状态样式 */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem;
  text-align: center;
  color: var(--text-secondary, #64748b);
}
.spinner {
  width: 50px;
  height: 50px;
  border: 5px solid rgba(74, 108, 247, 0.2);
  border-top-color: var(--accent-color, #4a6cf7);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}

.order-management-container {
  padding: 0;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary, #1e293b);
  animation: fadeIn 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ==================== 页面头部 ==================== */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  padding: 1.5rem 0;
  border-bottom: 1px solid var(--border-color, #e2e8f0);
}

.header-content {
  flex: 1;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary, #1e293b);
}

.page-title i {
  color: var(--accent-color, #4a6cf7);
  font-size: 1.75rem;
}

.page-subtitle {
  margin: 0;
  color: var(--text-secondary, #64748b);
  font-size: 1rem;
  line-height: 1.5;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sort-control {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sort-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-secondary, #64748b);
}

.sort-dropdown {
  background-color: var(--bg-primary, #ffffff);
  border: 2px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-md, 0.75rem);
  padding: 0.75rem 1rem;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-primary, #1e293b);
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 200px;
}

.sort-dropdown:hover {
  border-color: var(--accent-color, #4a6cf7);
}

.sort-dropdown:focus {
  outline: none;
  border-color: var(--accent-color, #4a6cf7);
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.1);
}

/* ==================== 筛选标签 ==================== */
.filter-section {
  margin-bottom: 2rem;
}

.filter-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  padding: 1rem;
  background: var(--bg-secondary, #f7f9fc);
  border-radius: var(--border-radius-md, 0.75rem);
  border: 1px solid var(--border-color, #e2e8f0);
}

.filter-tab {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: transparent;
  border: 2px solid transparent;
  border-radius: var(--border-radius-sm, 0.5rem);
  color: var(--text-secondary, #64748b);
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.filter-tab:hover {
  color: var(--accent-color, #4a6cf7);
  background: var(--bg-hover, #eff4ff);
}

.filter-tab.active {
  background: var(--accent-color, #4a6cf7);
  border-color: var(--accent-color, #4a6cf7);
  color: white;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--shadow-color, rgba(74, 108, 247, 0.3));
}

.tab-label {
  font-size: 0.9rem;
}

.count-badge {
  background: rgba(255, 255, 255, 0.2);
  color: inherit;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 700;
  min-width: 20px;
  text-align: center;
}

.filter-tab:not(.active) .count-badge {
  background: var(--accent-color, #4a6cf7);
  color: white;
}

/* ==================== 订单列表 ==================== */
.orders-section {
  margin-bottom: 2rem;
}

.order-card {
  background: var(--bg-primary, #ffffff);
  border: 1px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-md, 0.75rem);
  margin-bottom: 1.5rem;
  transition: all 0.3s ease;
  overflow: hidden;
  animation: slideUp 0.5s ease-out;
  animation-delay: var(--animation-delay, 0s);
  animation-fill-mode: both;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.order-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px var(--shadow-color, rgba(74, 108, 247, 0.15));
  border-color: var(--accent-color, #4a6cf7);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  background: var(--bg-secondary, #f7f9fc);
  border-bottom: 1px solid var(--border-color, #e2e8f0);
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.order-id {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 700;
  color: var(--text-primary, #1e293b);
  font-size: 1rem;
}

.order-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: var(--text-secondary, #64748b);
}

.order-status .status-badge {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-pending { background-color: rgba(243, 156, 18, 0.15); color: #f39c12; }
.status-processing { background-color: rgba(52, 152, 219, 0.15); color: #3498db; }
.status-shipping { background-color: rgba(142, 68, 173, 0.15); color: #8e44ad; }
.status-completed { background-color: rgba(46, 204, 113, 0.15); color: #2ecc71; }
.status-cancelled { background-color: rgba(149, 165, 166, 0.15); color: #95a5a6; }
.status-refunded { background-color: rgba(149, 165, 166, 0.15); color: #95a5a6; }
.status-refunding { background-color: rgba(231, 76, 60, 0.15); color: #e74c3c; }

.card-body {
  display: grid;
  grid-template-columns: 1fr auto auto;
  gap: 2rem;
  align-items: center;
  padding: 1.5rem;
}

.user-section .user-info {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.9rem;
}

.info-row i {
  width: 16px;
  text-align: center;
  color: var(--accent-color, #4a6cf7);
}

.info-row .label {
  color: var(--text-secondary, #64748b);
  min-width: 40px;
}

.info-row .value {
  font-weight: 600;
  color: var(--text-primary, #1e293b);
}

.amount-section {
  text-align: right;
}

.total-amount {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--accent-color, #4a6cf7);
  margin-bottom: 0.25rem;
}

.item-count {
  font-size: 0.85rem;
  color: var(--text-secondary, #64748b);
}

.actions-section {
  display: flex;
  justify-content: flex-end;
}

.action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: center;
}

/* ==================== 按钮样式 ==================== */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.25rem;
  border: 2px solid transparent;
  border-radius: var(--border-radius-sm, 0.5rem);
  font-size: 0.85rem;
  font-weight: 600;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.btn-primary {
  background: var(--accent-color, #4a6cf7);
  color: white;
  border-color: var(--accent-color, #4a6cf7);
}

.btn-primary:hover {
  background: var(--accent-color-hover, #3b57d6);
  border-color: var(--accent-color-hover, #3b57d6);
  transform: translateY(-1px);
}

.btn-outline {
  background: transparent;
  color: var(--text-secondary, #64748b);
  border-color: var(--border-color, #e2e8f0);
}

.btn-outline:hover {
  color: var(--accent-color, #4a6cf7);
  border-color: var(--accent-color, #4a6cf7);
  background: var(--bg-hover, #eff4ff);
}

.btn-warning {
  background: #f39c12;
  color: white;
  border-color: #f39c12;
}

.btn-warning:hover {
  background: #e67e22;
  border-color: #e67e22;
}

.btn-success {
  background: #2ecc71;
  color: white;
  border-color: #2ecc71;
}

.btn-success:hover {
  background: #27ae60;
  border-color: #27ae60;
}

.btn-info {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

.btn-info:hover {
  background: #2980b9;
  border-color: #2980b9;
}

.btn-ghost {
  background: transparent;
  color: var(--text-secondary, #64748b);
  border-color: transparent;
}

.btn-ghost:hover {
  color: var(--accent-color, #4a6cf7);
  background: var(--bg-hover, #eff4ff);
}

.expand-toggle i {
  transition: transform 0.3s ease;
}

/* ==================== 展开详情 ==================== */
.order-details {
  border-top: 1px solid var(--border-color, #e2e8f0);
  animation: expandDown 0.3s ease-out;
}

@keyframes expandDown {
  from {
    opacity: 0;
    max-height: 0;
  }
  to {
    opacity: 1;
    max-height: 500px;
  }
}

.details-header {
  padding: 1rem 1.5rem 0.5rem;
}

.details-header h4 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary, #1e293b);
}

.details-header i {
  color: var(--accent-color, #4a6cf7);
}

.items-list {
  padding: 0 1.5rem 1.5rem;
}

.order-item {
  display: grid;
  grid-template-columns: 60px 1fr auto auto;
  gap: 1rem;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-color, #e2e8f0);
}

.order-item:last-child {
  border-bottom: none;
}

.item-image {
  width: 60px;
  height: 60px;
  border-radius: var(--border-radius-sm, 0.5rem);
  overflow: hidden;
}

.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.item-content {
  flex: 1;
}

.product-name {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--text-primary, #1e293b);
  margin: 0 0 0.25rem 0;
  line-height: 1.4;
}

.product-spec {
  font-size: 0.8rem;
  color: var(--text-secondary, #64748b);
  margin: 0;
}

.item-price {
  text-align: right;
}

.unit-price {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--text-primary, #1e293b);
  margin-bottom: 0.25rem;
}

.quantity {
  font-size: 0.8rem;
  color: var(--text-secondary, #64748b);
}

.item-status {
  text-align: center;
}

.item-status-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.item-status-normal { background-color: rgba(46, 204, 113, 0.15); color: #2ecc71; }
.item-status-after-sale { background-color: rgba(243, 156, 18, 0.15); color: #f39c12; }
.item-status-refunded { background-color: rgba(149, 165, 166, 0.15); color: #95a5a6; }
.item-status-rejected { background-color: rgba(231, 76, 60, 0.15); color: #e74c3c; }
.item-status-platform { background-color: rgba(52, 152, 219, 0.15); color: #3498db; }

/* ==================== 空状态 ==================== */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: var(--bg-secondary, #f7f9fc);
  border-radius: var(--border-radius-md, 0.75rem);
  border: 2px dashed var(--border-color, #e2e8f0);
}

.empty-icon {
  margin-bottom: 1.5rem;
}

.empty-icon i {
  font-size: 4rem;
  color: var(--text-secondary, #64748b);
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary, #1e293b);
  font-size: 1.25rem;
}

.empty-state p {
  margin: 0;
  color: var(--text-secondary, #64748b);
  font-size: 1rem;
}

/* ==================== 分页 ==================== */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 2rem;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: var(--bg-primary, #ffffff);
  border: 1px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-md, 0.75rem);
}

.pagination-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: var(--bg-primary, #ffffff);
  border: 2px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-sm, 0.5rem);
  color: var(--text-primary, #1e293b);
  cursor: pointer;
  transition: all 0.3s ease;
}

.pagination-btn:hover:not(:disabled) {
  background: var(--accent-color, #4a6cf7);
  border-color: var(--accent-color, #4a6cf7);
  color: white;
  transform: translateY(-1px);
}

.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

.pagination-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-primary, #1e293b);
  min-width: 200px;
  text-align: center;
}

.total-info {
  font-size: 0.75rem;
  font-weight: 400;
  color: var(--text-secondary, #64748b);
}

/* ==================== 模态框 ==================== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1400;
  padding: 20px;
  animation: modalFadeIn 0.3s ease-out;
}

@keyframes modalFadeIn {
  from {
    opacity: 0;
    backdrop-filter: blur(0px);
  }
  to {
    opacity: 1;
    backdrop-filter: blur(8px);
  }
}

.modal-container {
  background: var(--bg-primary, #ffffff);
  border: 1px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-md, 0.75rem);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 800px;
  max-height: calc(100vh - 40px);
  overflow: hidden;
  animation: modalSlideIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: scale(0.8) translateY(-50px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--border-color, #e2e8f0);
  background: var(--bg-secondary, #f7f9fc);
}

.modal-header h2 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary, #1e293b);
}

.modal-header i {
  color: var(--accent-color, #4a6cf7);
}

.modal-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: transparent;
  border: 2px solid transparent;
  border-radius: var(--border-radius-sm, 0.5rem);
  color: var(--text-secondary, #64748b);
  cursor: pointer;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: var(--danger-color, #ef4444);
  border-color: var(--danger-color, #ef4444);
  color: white;
  transform: rotate(90deg);
}

.modal-body {
  padding: 2rem;
  max-height: calc(100vh - 200px);
  overflow-y: auto;
}

.modal-body::-webkit-scrollbar {
  width: 6px;
}

.modal-body::-webkit-scrollbar-track {
  background: var(--bg-secondary, #f7f9fc);
}

.modal-body::-webkit-scrollbar-thumb {
  background: var(--accent-color, #4a6cf7);
  border-radius: 3px;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.detail-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.detail-group.full-width {
  grid-column: 1 / -1;
}

.detail-group label {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-secondary, #64748b);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  padding: 1rem;
  background: var(--bg-hover, #eff4ff);
  border: 1px solid var(--border-color, #e2e8f0);
  border-radius: var(--border-radius-sm, 0.5rem);
  font-weight: 500;
  color: var(--text-primary, #1e293b);
  line-height: 1.6;
}

.detail-value.amount {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--accent-color, #4a6cf7);
}

.address-info div, .logistics-info div {
  margin-bottom: 0.25rem;
}

.address-info div:last-child, .logistics-info div:last-child {
  margin-bottom: 0;
}

.no-logistics {
  color: var(--text-secondary, #64748b);
  font-style: italic;
}

/* ==================== 响应式设计 ==================== */
@media (max-width: 1200px) {
  .card-body {
    grid-template-columns: 1fr auto;
    gap: 1.5rem;
  }

  .actions-section {
    grid-column: 1 / -1;
    justify-content: flex-start;
    margin-top: 1rem;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .header-actions { width: 100%; }
  .sort-control { width: 100%; }
  .sort-dropdown { width: 100%; }
  .filter-tabs { flex-direction: column; gap: 0.5rem; }
  .filter-tab { justify-content: center; }

  .card-body {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .amount-section { text-align: left; order: -1; }
  .actions-section { order: 1; }
  .action-buttons { flex-direction: column; width: 100%; }
  .btn { width: 100%; justify-content: center; }

  .order-item {
    grid-template-columns: 50px 1fr;
    gap: 0.75rem;
  }

  .item-price,
  .item-status {
    grid-column: 2;
    text-align: left;
    margin-top: 0.5rem;
  }

  .modal-container { margin: 10px; max-width: calc(100vw - 20px); }
  .modal-header, .modal-body { padding: 1.25rem; }
  .details-grid { grid-template-columns: 1fr; gap: 1rem; }
  .pagination { flex-direction: column; gap: 1rem; text-align: center; }
  .pagination-info { order: -1; }
}
</style>
