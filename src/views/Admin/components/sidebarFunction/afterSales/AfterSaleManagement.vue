<template>
  <div class="after-sale-management-container">
    <header class="page-header">
      <h1 class="header-title">
        <i class="fas fa-gavel header-icon"></i>
        售后仲裁中心
      </h1>
      <p class="header-description">在这里审查和处理用户与卖家之间的售后纠纷，您的决定将是最终裁决。</p>
    </header>

    <div class="filter-tabs">
      <button
          v-for="tab in tabs"
          :key="tab.status"
          class="tab-button"
          :class="{ 'active': activeStatus === tab.status }"
          @click="activeStatus = tab.status"
      >
        <i :class="tab.icon"></i>
        <span>{{ tab.label }}</span>
        <span v-if="getTabCount(tab.status)" class="tab-count">{{ getTabCount(tab.status) }}</span>
      </button>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>正在加载争议案件...</p>
    </div>
    <div v-else-if="filteredApplications.length === 0" class="empty-state">
      <i class="fas fa-check-circle empty-icon"></i>
      <h4>太棒了！</h4>
      <p>当前分类下没有需要处理的售后申请。</p>
    </div>

    <div v-else class="applications-grid">
      <div
          v-for="(app, index) in filteredApplications"
          :key="app.afterSaleId"
          class="dispute-card"
          :style="{ animationDelay: `${index * 50}ms` }"
      >
        <div class="card-header">
          <span class="card-id">仲裁ID: #{{ app.afterSaleId }}</span>
          <span class="card-status-badge" :class="getStatusClass(app.status)">
            <i :class="getStatusIcon(app.status)"></i>
            {{ getStatusText(app.status) }}
          </span>
        </div>

        <div class="card-body">
          <div class="info-section product-info">
            <img :src="app.productImage" alt="商品图片" class="product-image" @error="handleImageError">
            <div class="product-details">
              <p class="product-name">{{ app.productName }}</p>
              <p class="product-meta">订单号: {{ app.orderId }}</p>
            </div>
          </div>
          <div class="info-section">
            <strong class="section-title">买家申请理由</strong>
            <p class="section-content">{{ app.reason }}</p>
          </div>
          <div class="info-section">
            <strong class="section-title">卖家拒绝理由</strong>
            <p class="section-content seller-remark">{{ app.sellerRemark || '卖家未填写拒绝理由' }}</p>
          </div>
          <div v-if="app.evidenceImages" class="info-section">
            <strong class="section-title">相关凭证</strong>
            <div class="evidence-gallery">
              <img
                  v-for="(img, idx) in app.evidenceImages.split(',')"
                  :key="idx"
                  :src="img"
                  alt="凭证"
                  class="evidence-thumbnail"
                  @click="showImage(img)"
              >
            </div>
          </div>
        </div>

        <div class="card-footer">
          <span class="refund-amount">
            申请退款: <strong>¥{{ app.refundAmount ? app.refundAmount.toFixed(2) : '0.00' }}</strong>
          </span>
          <div v-if="app.status === 5" class="action-buttons">
            <button class="btn-judge reject" @click="openDecisionModal(app, 'reject')">
              <i class="fas fa-times-circle"></i> 驳回申请
            </button>
            <button class="btn-judge approve" @click="openDecisionModal(app, 'approve')">
              <i class="fas fa-check-circle"></i> 同意退款
            </button>
          </div>
          <div v-else class="final-remark">
            <strong>最终裁决:</strong> {{ app.adminRemark }}
          </div>
        </div>
      </div>
    </div>

    <div class="modal-overlay" :class="{ 'open': isModalOpen }">
      <div class="modal-content" :class="{ 'open': isModalOpen }">
        <h3 class="modal-title">
          <i class="fas fa-pen-fancy"></i>
          填写仲裁意见
        </h3>
        <p v-if="currentApplication" class="modal-subtitle">
          您正在为 <strong>#{{ currentApplication.afterSaleId }}</strong> 号仲裁案件做出最终决定。
        </p>
        <textarea
            v-model="adminRemark"
            class="modal-textarea"
            placeholder="请详细填写您的判决理由，这将作为最终结果通知双方..."
        ></textarea>
        <div class="modal-actions">
          <button class="modal-btn cancel" @click="isModalOpen = false">取消</button>
          <button
              class="modal-btn confirm"
              :class="decisionType === 'approve' ? 'approve' : 'reject'"
              @click="submitDecision"
              :disabled="isSubmitting"
          >
            <span v-if="isSubmitting" class="spinner-sm"></span>
            <span v-else>
              <i :class="decisionType === 'approve' ? 'fas fa-check' : 'fas fa-times'"></i>
              确认{{ decisionType === 'approve' ? '同意' : '驳回' }}
            </span>
          </button>
        </div>
      </div>
    </div>

    <div class="modal-overlay" :class="{ 'open': isImageViewerOpen }" @click="isImageViewerOpen = false">
      <img :src="viewerImageUrl" class="image-viewer-content" alt="图片预览">
    </div>
  </div>
</template>

<script setup>
import {ref, onMounted, computed, watch} from 'vue';
// 步骤 1: 导入真实的 API 函数，注意路径是否正确
import { getAdminAfterSaleList, judgeAfterSaleApplication } from '@/api/order';

// --- 响应式状态 ---
const loading = ref(true);
const allApplications = ref([]);
const activeStatus = ref(5); // 默认显示“待处理”
const isModalOpen = ref(false);
const isImageViewerOpen = ref(false);
const viewerImageUrl = ref('');
const currentApplication = ref(null);
const decisionType = ref('approve'); // 'approve' or 'reject'
const adminRemark = ref('');
const isSubmitting = ref(false);

const tabs = [
  { status: 5, label: '待处理', icon: 'fas fa-hourglass-half' },
  { status: 'all', label: '全部案件', icon: 'fas fa-archive' },
  { status: 6, label: '平台同意', icon: 'fas fa-check-double' },
  { status: 7, label: '平台拒绝', icon: 'fas fa-ban' },
];

// --- 计算属性 ---
const filteredApplications = computed(() => {
  if (activeStatus.value === 'all') {
    return allApplications.value;
  }
  return allApplications.value.filter(app => app.status === activeStatus.value);
});

const getTabCount = (status) => {
  if (status === 'all') return 0;
  return allApplications.value.filter(app => app.status === status).length;
}

// --- 生命周期钩子 ---
onMounted(() => {
  fetchApplications();
});

watch(activeStatus, () => {
  fetchApplications();
});
// --- 方法 ---
const fetchApplications = async () => {
  loading.value = true;

  try {
    // 根据 activeStatus 获取不同状态的申请
    const statusToFetch = activeStatus.value === 'all' ? null : activeStatus.value;
    const response = await getAdminAfterSaleList(statusToFetch);

    if (response.data.success) {
      allApplications.value = response.data.data;
    } else {
      console.error("获取申请列表失败:", response.data.message);
      allApplications.value = [];
    }
  } catch (error) {
    console.error("请求售后列表时发生网络错误:", error);
  } finally {
    loading.value = false;
  }
};
const openDecisionModal = (app, type) => {
  currentApplication.value = app;
  decisionType.value = type;
  adminRemark.value = '';
  isModalOpen.value = true;
};

const submitDecision = async () => {
  if (!adminRemark.value.trim()) {
    // 替换 alert 为更友好的提示方式
    console.warn('仲裁意见不能为空');
    return;
  }
  isSubmitting.value = true;

  // 提交
  try {
    const response = await judgeAfterSaleApplication(
        currentApplication.value.afterSaleId,
        decisionType.value,
        adminRemark.value
    );

    if (response.data.success) {
      // 成功后，关闭模态框并刷新列表，以获取最新状态
      isModalOpen.value = false;
      await fetchApplications(); // 重新加载数据
    } else {
      console.error("提交裁决失败:", response.data.message);
      // 可以在此提示用户失败
    }
  } catch (error) {
    console.error("提交裁决时发生网络错误:", error);
  } finally {
    isSubmitting.value = false;
  }
};

const showImage = (url) => {
  viewerImageUrl.value = url;
  isImageViewerOpen.value = true;
}

const handleImageError = (e) => {
  e.target.src = 'https://placehold.co/100x100/ccc/FFFFFF?text=Error';
}

// --- 辅助函数 ---
const getStatusText = (status) => {
  // 增加对其他状态的兼容
  const map = { 0: '申请中', 1: '卖家同意', 2: '卖家拒绝', 3: '已退款', 4: '售后关闭', 5: '待平台处理', 6: '平台同意', 7: '平台拒绝' };
  return map[status] || '未知状态';
};
const getStatusIcon = (status) => {
  const map = { 5: 'fas fa-gavel', 6: 'fas fa-check-double', 7: 'fas fa-ban' };
  return map[status] || 'fas fa-question-circle';
};
const getStatusClass = (status) => {
  const map = { 5: 'pending', 6: 'approved', 7: 'rejected' };
  return map[status] || 'default';
};
</script>

<style scoped>
/* 样式部分保持不变 */
.after-sale-management-container {
  padding: 1.5rem 2rem;
  animation: fadeIn 0.5s ease-out;
  /* 从父组件继承CSS变量 */
  --card-bg: var(--bg-primary);
  --card-border: var(--border-color);
  --card-shadow: var(--shadow-color, rgba(0,0,0,0.06));
  --title-color: var(--text-primary);
  --subtitle-color: var(--text-secondary);
  --accent-color-light: var(--accent-color);
  --success-color: #10b981;
  --danger-color: #ef4444;
  --warning-color: #f59e0b;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 页面头部 */
.page-header {
  margin-bottom: 2rem;
}
.header-title {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--title-color);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.header-icon {
  color: var(--accent-color);
}
.header-description {
  font-size: 1rem;
  color: var(--subtitle-color);
  margin-top: 0.5rem;
}

/* 筛选标签 */
.filter-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid var(--card-border);
}
.tab-button {
  padding: 0.75rem 1.25rem;
  border: none;
  background: transparent;
  color: var(--subtitle-color);
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.tab-button:after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  width: 100%;
  height: 3px;
  background: var(--accent-color);
  transform: scaleX(0);
  transition: transform 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}
.tab-button.active {
  color: var(--accent-color);
}
.tab-button.active:after {
  transform: scaleX(1);
}
.tab-count {
  background-color: var(--bg-hover, rgba(var(--accent-color), 0.1));
  color: var(--accent-color);
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 12px;
  font-weight: 700;
}


/* 加载与空状态 */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 0;
  text-align: center;
  color: var(--subtitle-color);
}
.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var(--bg-hover, rgba(var(--accent-color), 0.2));
  border-top-color: var(--accent-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
.empty-icon {
  font-size: 3rem;
  color: var(--success-color);
  margin-bottom: 1rem;
}

/* 卡片网格布局 */
.applications-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 1.5rem;
}
.dispute-card {
  background: var(--card-bg);
  border: 1px solid var(--card-border);
  border-radius: var(--border-radius-md, 12px);
  box-shadow: 0 2px 8px var(--card-shadow);
  display: flex;
  flex-direction: column;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  opacity: 0;
  animation: slideInUp 0.4s ease-out forwards;
}
.dispute-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px var(--card-shadow);
}
@keyframes slideInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.card-header, .card-footer {
  padding: 1rem 1.25rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header {
  border-bottom: 1px solid var(--card-border);
}
.card-footer {
  border-top: 1px solid var(--card-border);
  background-color: var(--bg-hover, rgba(var(--accent-color), 0.03));
}
.card-id {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--subtitle-color);
}
.card-status-badge {
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.25rem 0.75rem;
  border-radius: 99px;
  display: flex;
  align-items: center;
  gap: 0.3rem;
}
.card-status-badge.pending { background-color: rgba(245, 158, 11, 0.1); color: #d97706; }
.card-status-badge.approved { background-color: rgba(16, 185, 129, 0.1); color: var(--success-color); }
.card-status-badge.rejected { background-color: rgba(239, 68, 68, 0.1); color: var(--danger-color); }

.card-body {
  padding: 1.25rem;
  flex-grow: 1;
}
.info-section {
  margin-bottom: 1rem;
}
.info-section:last-child { margin-bottom: 0; }
.section-title {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--subtitle-color);
  display: block;
  margin-bottom: 0.5rem;
}
.section-content {
  font-size: 0.9rem;
  color: var(--title-color);
  line-height: 1.6;
}
.seller-remark {
  background-color: rgba(239, 68, 68, 0.05);
  padding: 0.5rem;
  border-radius: 6px;
  border-left: 3px solid var(--danger-color);
}

.product-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  object-fit: cover;
  border: 1px solid var(--card-border);
}
.product-name {
  font-weight: 600;
  color: var(--title-color);
}
.product-meta {
  font-size: 0.8rem;
  color: var(--subtitle-color);
}

.evidence-gallery {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}
.evidence-thumbnail {
  width: 50px;
  height: 50px;
  border-radius: 6px;
  object-fit: cover;
  cursor: pointer;
  transition: transform 0.2s ease;
  border: 1px solid var(--card-border);
}
.evidence-thumbnail:hover {
  transform: scale(1.1);
}

.refund-amount {
  font-size: 0.9rem;
  color: var(--subtitle-color);
}
.refund-amount strong {
  font-size: 1.1rem;
  color: var(--danger-color);
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}
.btn-judge {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.btn-judge.reject { background-color: #fee2e2; color: var(--danger-color); }
.btn-judge.reject:hover { background-color: #fecaca; }
.btn-judge.approve { background-color: #d1fae5; color: var(--success-color); }
.btn-judge.approve:hover { background-color: #a7f3d0; }

.final-remark {
  font-size: 0.85rem;
  color: var(--subtitle-color);
}

/* 模态框样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1200;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s ease, visibility 0.3s ease;
}
.modal-overlay.open {
  opacity: 1;
  visibility: visible;
}
.modal-content {
  background: var(--card-bg);
  padding: 2rem;
  border-radius: var(--border-radius-md, 16px);
  width: 90%;
  max-width: 500px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
  transform: scale(0.95) translateY(10px);
  transition: transform 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}
.modal-content.open {
  transform: scale(1) translateY(0);
}
.modal-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--title-color);
  margin-bottom: 0.5rem;
}
.modal-subtitle {
  color: var(--subtitle-color);
  margin-bottom: 1.5rem;
}
.modal-textarea {
  width: 100%;
  min-height: 120px;
  padding: 0.75rem;
  border: 1px solid var(--card-border);
  border-radius: var(--border-radius-sm, 8px);
  font-family: inherit;
  font-size: 0.9rem;
  resize: vertical;
  background-color: var(--bg-hover, rgba(var(--accent-color), 0.05));
}
.modal-textarea:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(var(--accent-color), 0.3);
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1.5rem;
}
.modal-btn {
  padding: 0.6rem 1.25rem;
  border-radius: var(--border-radius-sm, 8px);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}
.modal-btn.cancel {
  background-color: var(--card-border);
  color: var(--subtitle-color);
}
.modal-btn.cancel:hover {
  background-color: var(--bg-hover, #d1d5db);
}
.modal-btn.confirm.approve { background-color: var(--success-color); color: white; }
.modal-btn.confirm.reject { background-color: var(--danger-color); color: white; }
.modal-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
.spinner-sm {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
  display: inline-block;
}

/* 图片预览 */
.image-viewer-content {
  max-width: 90vw;
  max-height: 90vh;
  object-fit: contain;
  border-radius: var(--border-radius-md, 12px);
  box-shadow: 0 10px 40px rgba(0,0,0,0.4);
}
</style>
