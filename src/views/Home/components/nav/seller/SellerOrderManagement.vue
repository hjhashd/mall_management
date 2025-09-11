<template>
  <div class="seller-order-management">
    <h3 class="component-title"><i class="fas fa-dolly-flatbed me-2"></i>订单履约中心</h3>

    <div class="status-tabs mb-4">
      <ul class="nav nav-pills">
        <li v-for="status in statuses" :key="status.value" class="nav-item">
          <button
              class="nav-link"
              :class="{ 'active': activeStatus === status.value }"
              @click="activeStatus = status.value"
          >
            <i :class="status.icon" class="me-1"></i> {{ status.label }}
          </button>
        </li>
      </ul>
    </div>

    <!-- 订单列表 -->
    <div v-if="activeStatus !== 'after-sales'">
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-success" role="status">
          <span class="visually-hidden">加载中...</span>
        </div>
        <p class="mt-3 text-muted">正在加载订单数据...</p>
      </div>

      <div v-else-if="error" class="alert alert-danger text-center">
        <i class="fas fa-exclamation-triangle me-2"></i>
        {{ error }}
      </div>

      <div v-else-if="filteredOrders.length > 0" class="order-list">
        <div v-for="order in filteredOrders" :key="order.orderId" class="order-card-seller">
          <div class="order-header-seller">
            <div>
              <span class="order-id">订单号：{{ order.orderId }}</span>
              <span class="order-time">{{ formatDate(order.createdAt) }}</span>
            </div>
            <span class="order-status-badge" :class="getStatusClass(order.status)">
              {{ getStatusText(order.status) }}
            </span>
          </div>

          <div class="order-body-seller">
            <div class="order-items-seller">
              <div v-for="item in order.items" :key="item.itemId" class="order-item-seller">
                <img :src="item.productImage" :alt="item.productName" class="product-image-seller" @error="handleImageError">
                <div class="product-info-seller">
                  <p class="product-name-seller">{{ item.productName }}</p>
                  <p class="product-spec-seller">数量: {{ item.quantity }} | 单价: ¥{{ item.unitPrice.toFixed(2) }}</p>
                </div>
                <p class="product-total-seller">¥{{ item.totalPrice.toFixed(2) }}</p>
              </div>
            </div>

            <div class="shipping-info-seller">
              <div class="buyer-address">
                <div class="buyer-info-header">
                  <h6><i class="fas fa-user me-2"></i>买家收货信息</h6>
                  <router-link
                      v-if="order.buyerId"
                      :to="{ name: 'Chat', query: { peerId: order.buyerId } }"
                      class="buyer-avatar-link"
                      title="联系买家"
                  >
                    <img v-if="order.buyerAvatarUrl" :src="order.buyerAvatarUrl" :alt="order.receiverName" class="buyer-avatar"/>
                    <div v-else class="avatar-placeholder">{{ order.receiverName ? order.receiverName.charAt(0) : '?' }}</div>
                  </router-link>
                </div>

                <p><strong>{{ order.receiverName }}</strong>, {{ order.receiverPhone }}</p>
                <p>{{ order.shippingAddress }}</p>
                <p v-if="order.userRemark" class="user-remark">备注: {{ order.userRemark }}</p>
              </div>
              <div class="logistics-details" v-if="order.status >= 3">
                <h6><i class="fas fa-truck me-2"></i>物流信息</h6>
                <p><strong>{{ order.shippingCompany }}</strong></p>
                <p>运单号: {{ order.trackingNumber }}</p>
              </div>
            </div>
          </div>

          <div class="order-footer-seller">
            <span class="total-amount-seller">订单总额: <strong>¥{{ order.totalAmount.toFixed(2) }}</strong></span>
            <div class="order-actions-seller">
              <button v-if="order.status === 2" class="btn btn-success btn-sm" @click="openShippingModal(order)">
                <i class="fas fa-truck me-1"></i> 发货
              </button>
              <span v-if="order.status === 5" class="text-muted">订单已取消</span>
              <span v-if="[6, 7].includes(order.status)" class="text-danger">订单售后中</span>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-5 empty-state">
        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
        <h4 class="mb-3 text-secondary">该分类下暂无订单</h4>
      </div>
    </div>

    <!-- 售后管理列表 -->
    <div v-if="activeStatus === 'after-sales'" class="after-sales-list">
      <div v-if="afterSalesLoading" class="text-center py-5">
        <div class="spinner-border text-warning" role="status"><span class="visually-hidden">加载中...</span></div>
      </div>
      <div v-else-if="afterSaleApplications.length === 0" class="text-center py-5 empty-state">
        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
        <h4 class="mb-3 text-secondary">暂无售后申请</h4>
      </div>
      <div v-else>
        <div v-for="app in afterSaleApplications" :key="app.afterSaleId" class="order-card-seller">
          <div class="order-header-seller">
            <div>
              <span class="order-id">售后单号: {{ app.afterSaleId }}</span>
              <span class="order-time">申请于: {{ formatDate(app.createdAt) }}</span>
            </div>
            <span class="order-status-badge" :class="getAfterSaleStatusClass(app.status)">
              {{ getAfterSaleStatusText(app.status) }}
            </span>
          </div>
          <div class="order-body-seller">
            <div class="order-items-seller">
              <div class="order-item-seller">
                <img :src="app.productImage" :alt="app.productName" class="product-image-seller" @error="handleImageError">
                <div class="product-info-seller">
                  <p class="product-name-seller">{{ app.productName }}</p>
                  <p class="product-spec-seller">订单号: {{ app.orderId }}</p>
                  <p class="product-spec-seller">数量: {{ app.quantity }} | 申请退款: ¥{{ app.refundAmount.toFixed(2) }}</p>
                </div>
              </div>
            </div>
            <div class="shipping-info-seller">
              <h6><i class="fas fa-comment-dots me-2"></i>申请理由</h6>
              <p>{{ app.reason }}</p>
              <div v-if="app.evidenceImages">
                <h6><i class="fas fa-images me-2"></i>凭证图片</h6>
                <div class="evidence-images">
                  <img v-for="(img, index) in app.evidenceImages.split(',')" :key="index" :src="img" alt="凭证" class="evidence-image" @click="() => showImage(img)">
                </div>
              </div>

              <div v-if="[6, 7].includes(app.status) && app.adminRemark" class="platform-remark">
                <h6><i class="fas fa-gavel me-2"></i>平台仲裁意见</h6>
                <p>{{ app.adminRemark }}</p>
              </div>
            </div>
          </div>
          <div class="order-footer-seller">
            <span class="total-amount-seller">申请退款: <strong>¥{{ app.refundAmount.toFixed(2) }}</strong></span>
            <div class="order-actions-seller">
              <button v-if="app.status === 0" class="btn btn-info btn-sm" @click="openAfterSaleModal(app)">
                <i class="fas fa-tasks me-1"></i> 处理申请
              </button>
              <span v-else class="text-muted">已处理</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 发货模态框 -->
    <div class="modal fade" id="shippingModal" tabindex="-1" aria-labelledby="shippingModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="shippingModalLabel"><i class="fas fa-shipping-fast me-2"></i>填写发货信息</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <p><strong>订单号:</strong> {{ shippingInfo.orderId }}</p>
            <form @submit.prevent="submitShipment">
              <div class="mb-3">
                <label for="shippingCompany" class="form-label">选择物流公司</label>
                <select class="form-select" id="shippingCompany" v-model="shippingInfo.shippingCompany" required>
                  <option disabled value="">请选择...</option>
                  <option>顺丰速运</option>
                  <option>中通快递</option>
                  <option>申通快递</option>
                  <option>圆通速递</option>
                  <option>韵达快递</option>
                  <option>百世快递</option>
                  <option>邮政EMS</option>
                </select>
              </div>
              <div class="mb-3">
                <label for="trackingNumber" class="form-label">物流单号</label>
                <input type="text" class="form-control" id="trackingNumber" v-model.trim="shippingInfo.trackingNumber" required placeholder="请输入物流运单号">
              </div>
              <div class="modal-footer pb-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                  <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                  {{ isSubmitting ? '提交中...' : '确认发货' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- 售后处理模态框 -->
    <div class="modal fade" id="afterSaleModal" tabindex="-1" aria-labelledby="afterSaleModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="afterSaleModalLabel"><i class="fas fa-undo-alt me-2"></i>处理售后申请</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div v-if="currentApplication">
              <p><strong>商品名称:</strong> {{ currentApplication.productName }}</p>
              <p><strong>申请理由:</strong> {{ currentApplication.reason }}</p>
              <p><strong>申请退款金额:</strong> <span class="text-danger fw-bold">¥{{ currentApplication.refundAmount.toFixed(2) }}</span></p>
              <div v-if="currentApplication.evidenceImages">
                <h6><strong>凭证图片:</strong></h6>
                <div class="evidence-images-modal">
                  <img v-for="(img, index) in currentApplication.evidenceImages.split(',')" :key="index" :src="img" alt="凭证" class="evidence-image-modal-item" @click="() => showImage(img)">
                </div>
              </div>
              <hr>
              <div class="mb-3">
                <label for="sellerRemark" class="form-label">卖家备注 (可选，拒绝时建议填写)</label>
                <textarea class="form-control" id="sellerRemark" v-model="afterSaleProcessing.remark" rows="3"></textarea>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
            <button type="button" class="btn btn-danger" @click="handleApplication('reject')" :disabled="isSubmitting">
              <i class="fas fa-times-circle me-1"></i> 拒绝退款
            </button>
            <button type="button" class="btn btn-success" @click="handleApplication('approve')" :disabled="isSubmitting">
              <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
              <i v-else class="fas fa-check-circle me-1"></i>
              {{ isSubmitting ? '处理中...' : '同意退款' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 图片预览模态框 -->
    <div class="modal fade" id="imagePreviewModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-body p-0">
            <img :src="previewImageUrl" class="img-fluid w-100" alt="图片预览">
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, reactive, watch } from 'vue';
import { useRoute } from 'vue-router'; // 【新增】引入 useRoute 钩子
import { Modal } from 'bootstrap';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import { getSellerOrderList, shipOrder, getSellerAfterSaleList, processAfterSaleApplication } from '@/api/order';

// --- 响应式状态定义 ---
const route = useRoute(); // 【新增】获取当前路由信息
const loading = ref(true);
const error = ref(null);
const orders = ref([]);
const activeStatus = ref(2); // 默认显示"待发货"
const shippingModalInstance = ref(null);
const isSubmitting = ref(false);

// --- 售后相关状态 ---
const afterSalesLoading = ref(true);
const afterSaleApplications = ref([]);
const afterSaleModalInstance = ref(null);
const imagePreviewModalInstance = ref(null);
const previewImageUrl = ref('');
const currentApplication = ref(null);
const afterSaleProcessing = reactive({
  remark: ''
});

// 发货信息表单
const shippingInfo = reactive({
  orderId: null,
  shippingCompany: '',
  trackingNumber: '',
});

// 筛选状态的定义
const statuses = [
  { value: 2, label: '待发货', icon: 'fas fa-box' },
  { value: 3, label: '待收货', icon: 'fas fa-truck-loading' },
  { value: 4, label: '已完成', icon: 'fas fa-check-circle' },
  { value: 'after-sales', label: '售后管理', icon: 'fas fa-undo-alt' },
];

// --- 生命周期函数 ---
onMounted(() => {
  const modalEl = document.getElementById('shippingModal');
  if (modalEl) shippingModalInstance.value = new Modal(modalEl);

  const afterSaleModalEl = document.getElementById('afterSaleModal');
  if (afterSaleModalEl) afterSaleModalInstance.value = new Modal(afterSaleModalEl);

  const imageModalEl = document.getElementById('imagePreviewModal');
  if(imageModalEl) imagePreviewModalInstance.value = new Modal(imageModalEl);

  // 【新增】检查 URL 中是否有 category 参数
  if (route.query.category === 'after-sales') {
    activeStatus.value = 'after-sales';
    fetchAfterSaleApplications(); // 立即加载售后申请数据
  } else {
    fetchSellerOrders(); // 否则，加载常规订单数据
  }
});

// 【可选】监听路由参数的变化，以防组件复用时参数变化
watch(
    () => route.query.category,
    (newCategory) => {
      if (newCategory === 'after-sales' && activeStatus.value !== 'after-sales') {
        activeStatus.value = 'after-sales';
        fetchAfterSaleApplications();
      } else if (newCategory !== 'after-sales' && activeStatus.value === 'after-sales') {
        activeStatus.value = 2; // 或者其他默认值
        fetchSellerOrders();
      }
    }
);

// --- 监听器 ---
watch(activeStatus, (newStatus) => {
  if (newStatus === 'after-sales' && afterSaleApplications.value.length === 0) {
    fetchAfterSaleApplications();
  }
});

// --- 计算属性 ---
const filteredOrders = computed(() => {
  if (activeStatus.value === 'after-sales') return [];
  return orders.value.filter(order => order.status === activeStatus.value);
});

// --- 方法 ---
const fetchSellerOrders = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await getSellerOrderList();
    if (response.data.success) {
      orders.value = response.data.data;
    } else {
      throw new Error(response.data.message || '获取订单数据失败');
    }
  } catch (err) {
    console.error("获取卖家订单失败:", err);
    error.value = err.message || '网络错误，请稍后重试。';
  } finally {
    loading.value = false;
  }
};

const openShippingModal = (order) => {
  shippingInfo.orderId = order.orderId;
  shippingInfo.shippingCompany = '';
  shippingInfo.trackingNumber = '';
  if (shippingModalInstance.value) {
    shippingModalInstance.value.show();
  }
};

const submitShipment = async () => {
  if (isSubmitting.value) return;
  isSubmitting.value = true;
  try {
    const response = await shipOrder(shippingInfo.orderId, {
      shippingCompany: shippingInfo.shippingCompany,
      trackingNumber: shippingInfo.trackingNumber,
    });
    if (response.data.success) {
      const orderIndex = orders.value.findIndex(o => o.orderId === shippingInfo.orderId);
      if (orderIndex !== -1) {
        orders.value[orderIndex].status = 3;
        orders.value[orderIndex].shippingCompany = shippingInfo.shippingCompany;
        orders.value[orderIndex].trackingNumber = shippingInfo.trackingNumber;
        orders.value[orderIndex].shippedAt = new Date().toISOString();
      }
      if (shippingModalInstance.value) shippingModalInstance.value.hide();
      alert(`订单 ${shippingInfo.orderId} 发货成功！`);
    } else {
      throw new Error(response.data.message || '发货失败');
    }
  } catch (err) {
    console.error("发货失败:", err);
    alert(`发货失败: ${err.message}`);
  } finally {
    isSubmitting.value = false;
  }
};

const fetchAfterSaleApplications = async () => {
  afterSalesLoading.value = true;
  try {
    const response = await getSellerAfterSaleList();
    if (response.data.success) {
      afterSaleApplications.value = response.data.data;
    } else {
      throw new Error(response.data.message || '获取售后数据失败');
    }
  } catch (err) {
    console.error("获取售后申请失败:", err);
    error.value = err.message || '网络错误，请稍后重试。';
  } finally {
    afterSalesLoading.value = false;
  }
};

const openAfterSaleModal = (application) => {
  currentApplication.value = application;
  afterSaleProcessing.remark = '';
  if (afterSaleModalInstance.value) {
    afterSaleModalInstance.value.show();
  }
};

/**
 * 处理售后申请（同意/拒绝）
 */
const handleApplication = async (action) => {
  if (!currentApplication.value) return;
  if (action === 'reject' && !afterSaleProcessing.remark.trim()) {
    alert('拒绝退款时，请填写处理备注。');
    return;
  }
  isSubmitting.value = true;
  try {
    // API调用时，将 admin_remark 改为 seller_remark
    const response = await processAfterSaleApplication(
        currentApplication.value.afterSaleId,
        action,
        afterSaleProcessing.remark
    );
    if (response.data.success) {
      alert('处理成功！');
      fetchAfterSaleApplications();
      if (afterSaleModalInstance.value) {
        afterSaleModalInstance.value.hide();
      }
    } else {
      throw new Error(response.data.message || '处理失败');
    }
  } catch (err) {
    console.error("处理售后申请失败:", err);
    alert(`处理失败: ${err.message}`);
  } finally {
    isSubmitting.value = false;
  }
};

const showImage = (url) => {
  previewImageUrl.value = url;
  if(imagePreviewModalInstance.value) {
    imagePreviewModalInstance.value.show();
  }
};

// --- 辅助函数 ---

/**
 * 图片加载失败时的处理函数
 * @param {Event} e - 事件对象
 */
const handleImageError = (e) => {
  e.target.src = 'http://localhost:8080/uploads/products/example.png';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  });
};

const getStatusText = (status) => {
  const map = {1: '待付款', 2: '待发货', 3: '待收货', 4: '已完成', 5: '已取消', 6: '退款中', 7: '已退款'};
  return map[status] || '未知状态';
};

const getStatusClass = (status) => {
  const map = {
    2: 'status-pending-shipment',
    3: 'status-shipped',
    4: 'status-completed',
    5: 'status-cancelled',
    6: 'status-refunding',
    7: 'status-refunding'
  };
  return map[status] || 'status-default';
};

const getAfterSaleStatusText = (status) => {
  const map = {
    0: '申请中',
    1: '卖家同意',
    2: '卖家拒绝',
    3: '退款成功',
    4: '售后关闭',
    5: '平台介入中', // 新增
    6: '平台同意退款', // 新增
    7: '平台拒绝退款'  // 新增
  };
  return map[status] || '未知状态';
};

const getAfterSaleStatusClass = (status) => {
  const map = {
    0: 'status-refunding',      // 申请中 (红色)
    1: 'status-completed',      // 卖家同意 (绿色)
    2: 'status-cancelled',      // 卖家拒绝 (灰色)
    5: 'status-pending-shipment', // 平台介入中 (橙色)
    6: 'status-completed',      // 平台同意 (绿色)
    7: 'status-cancelled',      // 平台拒绝 (灰色)
  };
  return map[status] || 'status-default';
};
</script>

<style scoped>
/* 原始样式保持不变 */
.seller-order-management {
  background-color: #f8f9fa;
  padding: 2rem;
  border-radius: 12px;
  padding-top: 70px;
}

.component-title {
  color: #343a40;
  font-weight: 700;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 0.5rem;
}

/* 状态标签页样式 */
.status-tabs .nav-link {
  border-radius: 20px;
  padding: 0.5rem 1.25rem;
  border: 1px solid #dee2e6;
  color: #6c757d;
  transition: all 0.2s ease;
  background-color: #fff;
  margin-right: 0.5rem;
  font-weight: 500;
}

.status-tabs .nav-link.active {
  background-color: #28a745;
  color: white;
  border-color: #28a745;
}

/* 订单卡片样式 */
.order-card-seller {
  background-color: #fff;
  border: 1px solid #dee2e6;
  border-radius: 10px;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
  transition: box-shadow 0.3s ease;
}

.order-card-seller:hover {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.order-header-seller {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
  border-top-left-radius: 10px;
  border-top-right-radius: 10px;
}

.order-id {
  font-weight: 600;
  color: #343a40;
}

.order-time {
  font-size: 0.85rem;
  color: #6c757d;
  margin-left: 1rem;
}

.order-status-badge {
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: #fff;
}

.status-pending-shipment {
  background-color: #fd7e14;
}

.status-shipped {
  background-color: #17a2b8;
}

.status-completed {
  background-color: #28a745;
}

.status-cancelled {
  background-color: #6c757d;
}

.status-refunding {
  background-color: #dc3545;
}

.status-default {
  background-color: #adb5bd;
}

.order-body-seller {
  display: flex;
  padding: 1.5rem;
  gap: 1.5rem;
}

.order-items-seller {
  flex: 2;
}

.order-item-seller {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.order-item-seller:last-child {
  margin-bottom: 0;
}

.product-image-seller {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
  margin-right: 1rem;
}

.product-info-seller {
  flex-grow: 1;
}

.product-name-seller {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.product-spec-seller {
  font-size: 0.85rem;
  color: #6c757d;
  margin: 0;
}

.product-total-seller {
  font-weight: 600;
  min-width: 80px;
  text-align: right;
}

.shipping-info-seller {
  flex: 1;
  border-left: 1px solid #e9ecef;
  padding-left: 1.5rem;
  font-size: 0.9rem;
}

.shipping-info-seller h6 {
  font-weight: 700;
  color: #495057;
}

.shipping-info-seller p {
  margin-bottom: 0.5rem;
  line-height: 1.6;
}

.user-remark {
  background-color: #fff3cd;
  color: #856404;
  padding: 0.5rem;
  border-radius: 5px;
  font-size: 0.85rem;
}

.logistics-details {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px dashed #dee2e6;
}

.order-footer-seller {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  border-top: 1px solid #e9ecef;
  border-bottom-left-radius: 10px;
  border-bottom-right-radius: 10px;
}

.total-amount-seller {
  font-size: 1.1rem;
  color: #dc3545;
}

.empty-state {
  background-color: #fff;
  padding: 4rem;
  border-radius: 10px;
  border: 1px dashed #dee2e6;
}

.buyer-info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.buyer-info-header h6 {
  margin-bottom: 0;
}

.buyer-avatar-link {
  display: block;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #e9ecef;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.buyer-avatar-link:hover {
  transform: scale(1.1);
  box-shadow: 0 0 10px rgba(0, 123, 255, 0.5);
}

.buyer-avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #007bff;
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
}

.evidence-images {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}
.evidence-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  border: 1px solid #ddd;
  transition: transform 0.2s;
}
.evidence-image:hover {
  transform: scale(1.1);
}

.evidence-images-modal {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}
.evidence-image-modal-item {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  border: 1px solid #eee;
}

@media (max-width: 992px) {
  .order-body-seller {
    flex-direction: column;
  }

  .shipping-info-seller {
    border-left: none;
    padding-left: 0;
    margin-top: 1.5rem;
    border-top: 1px solid #e9ecef;
    padding-top: 1.5rem;
  }
}

.platform-remark {
  margin-top: 1rem;
  padding: 0.75rem 1rem;
  background-color: #e6f7ff;
  border-left: 4px solid #1890ff;
  border-radius: 4px;
}

.platform-remark h6 {
  color: #1890ff;
  font-weight: 600;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.platform-remark p {
  margin-bottom: 0;
  font-size: 0.85rem;
  color: #333;
}
</style>
