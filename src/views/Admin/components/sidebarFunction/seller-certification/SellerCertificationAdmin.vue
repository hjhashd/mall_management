<template>
  <div class="cert-admin-container animate-fade-in">
    <div class="header-bar">
      <h1 class="page-title">商家认证审核</h1>
      <div class="controls-wrapper">
        <div class="filter-tabs">
          <button
              v-for="tab in filterTabs"
              :key="tab.status"
              :class="{ active: activeFilter === tab.status }"
              @click="changeFilter(tab.status)"
          >
            <i :class="tab.icon"></i>
            <span>{{ tab.label }}</span>
            <span v-if="get_count(tab.status) > 0" class="count-badge">{{ get_count(tab.status) }}</span>
          </button>
        </div>
        <div class="sort-control">
          <i class="fas fa-sort-amount-down"></i>
          <select v-model="sortOption" class="sort-dropdown">
            <option value="date_desc">按申请时间倒序</option>
            <option value="date_asc">按申请时间正序</option>
            <option value="name_asc">按商家名称排序 (A-Z)</option>
          </select>
        </div>
      </div>
    </div>

    <div v-if="isLoading" class="empty-state">
      <i class="fas fa-spinner fa-spin"></i>
      <p>正在加载数据...</p>
    </div>

    <div v-else class="certs-list">
      <div v-if="sortedCerts.length === 0" class="empty-state">
        <i class="fas fa-file-alt"></i>
        <p>当前分类下没有认证申请</p>
      </div>
      <div
          v-for="(cert, index) in sortedCerts"
          :key="cert.certificationId"
          class="cert-card animate-slide-up"
          :class="`status-border-${cert.status}`"
          :style="{ '--delay': `${index * 0.07}s` }"
      >
        <div class="card-main-content">
          <div class="card-info">
            <div class="info-header">
              <h3 class="business-name">{{ cert.businessName }}</h3>
              <span class="status-badge" :class="`status-${cert.status}`">
                {{ getStatusText(cert.status) }}
              </span>
            </div>
            <p class="applicant-info">
              <i class="fas fa-user-tie"></i>
              <span>申请人: <strong>{{ cert.username }}</strong></span>
            </p>
            <p class="apply-time">
              <i class="fas fa-clock"></i>
              <span>申请时间: {{ formatDate(cert.createdAt) }}</span>
            </p>
          </div>
        </div>
        <div class="card-actions">
          <button class="details-btn" @click="openDetailsModal(cert)">
            <i class="fas fa-file-alt"></i>
            <span>查看详情</span>
          </button>
          <template v-if="cert.status === 0">
            <button class="approve-btn" @click="handleApprove(cert.certificationId)">
              <i class="fas fa-check"></i> <span>通过</span>
            </button>
            <button class="reject-btn" @click="openRejectModal(cert)">
              <i class="fas fa-times"></i> <span>拒绝</span>
            </button>
          </template>
        </div>
      </div>
    </div>

    <div v-if="totalPages > 1" class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1">
        <i class="fas fa-chevron-left"></i>
      </button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages">
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>

    <div v-if="isDetailsModalOpen" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-content animate-fade-in">
        <button class="close-btn" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        <h2>认证申请详情</h2>
        <div class="details-grid">
          <div class="detail-item">
            <label>商家名称</label>
            <p>{{ selectedCert.businessName }}</p>
          </div>
          <div class="detail-item">
            <label>经营类型</label>
            <p>{{ selectedCert.businessType }}</p>
          </div>
          <div class="detail-item">
            <label>联系电话</label>
            <p>{{ selectedCert.contactPhone }}</p>
          </div>
          <div class="detail-item">
            <label>联系邮箱</label>
            <p>{{ selectedCert.contactEmail }}</p>
          </div>
          <div class="detail-item full-width">
            <label>经营地址</label>
            <p>{{ selectedCert.businessAddress }}</p>
          </div>
          <div class="detail-item full-width">
            <label>经营描述</label>
            <p>{{ selectedCert.businessDescription || '未填写' }}</p>
          </div>
          <div class="detail-item full-width">
            <label>营业执照</label>
            <img
                :src="selectedCert.businessLicense"
                alt="营业执照"
                class="license-thumbnail"
                @click="openImageViewer(selectedCert.businessLicense)"
            />
          </div>
        </div>
      </div>
    </div>

    <div v-if="isRejectModalOpen" class="modal-overlay" @click.self="closeRejectModal">
      <div class="modal-content small-modal animate-fade-in">
        <button class="close-btn" @click="closeRejectModal"><i class="fas fa-times"></i></button>
        <h3>拒绝认证申请</h3>
        <p>请填写拒绝原因，此原因将反馈给申请人。</p>
        <textarea v-model="rejectReason" placeholder="例如：营业执照不清晰、信息填写不完整等"></textarea>
        <button class="confirm-reject-btn" @click="handleReject">确认拒绝</button>
      </div>
    </div>

    <div v-if="isImageViewerOpen" class="image-viewer-overlay" @click="closeImageViewer">
      <img :src="imageViewerSrc" alt="营业执照大图" class="animate-fade-in">
    </div>
  </div>
</template>

<script setup>
import {ref, computed, onMounted, watch} from 'vue';
// 1. 导入你的 API 请求函数
import {getCertificationList, reviewCertification} from '@/api/sellerCertification'; // 确认路径是否正确
// 建议：引入一个UI库的提示组件，能提供更好的用户体验
// import { ElMessage, ElMessageBox } from 'element-plus';

// --- 状态管理 ---
const certifications = ref([]); // 只存储当前页的数据
const totalCount = ref(0);      // 用于存储数据总数
const isLoading = ref(true);    // 加载状态，默认为true

const activeFilter = ref(0); // 0: 待审核, 1: 已认证, 2: 拒绝
const sortOption = ref('date_desc');
const pagination = ref({currentPage: 1, pageSize: 5});

const isDetailsModalOpen = ref(false);
const isRejectModalOpen = ref(false);
const isImageViewerOpen = ref(false);
const selectedCert = ref(null);
const rejectReason = ref('');
const imageViewerSrc = ref('');

// --- API & 数据处理 ---

// 2. 创建一个集中的数据获取函数
const fetchCertifications = async () => {
  isLoading.value = true;
  try {
    // 调用 API 获取数据
    const response = await getCertificationList(
        pagination.value.currentPage,
        pagination.value.pageSize,
        activeFilter.value
    );

    // 根据你提供的数据结构解析 response
    if (response.data.success && response.data) {
      certifications.value = response.data.data.items;
      totalCount.value = response.data.total;
    } else {
      console.error("获取数据失败:", response.data.message);
      // ElMessage.error(response.message || '获取列表失败');
    }
  } catch (error) {
    console.error("请求认证列表时出错:", error);
    // ElMessage.error('获取认证列表失败，请检查网络');
  } finally {
    isLoading.value = false;
  }
};

// 3. 在组件挂载时调用API
onMounted(() => {
  fetchCertifications();
});

// 4. 监听筛选和分页变化，自动重新获取数据
watch(activeFilter, () => {
  pagination.value.currentPage = 1; // 切换筛选时，重置到第一页
  fetchCertifications();
});
watch(() => pagination.value.currentPage, fetchCertifications);


// --- 计算属性 ---
const filterTabs = ref([
  {status: 0, label: '待审核', icon: 'fas fa-hourglass-half'},
  {status: 1, label: '已认证', icon: 'fas fa-check-circle'},
  {status: 2, label: '已拒绝', icon: 'fas fa-times-circle'},
]);

const get_count = (status) => computed(() => certifications.value.filter(c => c.status === status).length).value;

// 5. 排序逻辑 (在前端对当前页数据进行排序)
const sortedCerts = computed(() => {
  const list = [...certifications.value];
  switch (sortOption.value) {
    case 'date_desc':
      return list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    case 'date_asc':
      return list.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    case 'name_asc':
      // businessName 可能为 null, 做一下处理
      return list.sort((a, b) => (a.businessName || '').localeCompare(b.businessName || '', 'zh-CN'));
    default:
      return list;
  }
});

const totalPages = computed(() => {
  if (totalCount.value === 0) return 1;
  return Math.ceil(totalCount.value / pagination.value.pageSize);
});

// --- 方法 ---
const changeFilter = (status) => {
  activeFilter.value = status;
};

const getStatusText = (status) => {
  const map = {0: '待审核', 1: '已认证', 2: '已拒绝'};
  return map[status] || '未知';
};

const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  return new Date(dateString).toLocaleString('zh-CN', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
};

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
  }
};

// 模态框和查看器操作
const openDetailsModal = (cert) => {
  selectedCert.value = cert;
  isDetailsModalOpen.value = true;
};
const closeDetailsModal = () => isDetailsModalOpen.value = false;

const openRejectModal = (cert) => {
  selectedCert.value = cert;
  rejectReason.value = '';
  isRejectModalOpen.value = true;
};
const closeRejectModal = () => isRejectModalOpen.value = false;

const openImageViewer = (src) => {
  imageViewerSrc.value = src;
  isImageViewerOpen.value = true;
};
const closeImageViewer = () => isImageViewerOpen.value = false;

// 6. 更新审核操作方法以调用 API
const handleApprove = async (certId) => {
  // 可以加入确认弹窗以防止误操作
  // if (!confirm('确定要通过此认证申请吗？')) return;

  try {
    const response = await reviewCertification(certId, 1, null);
    if (response.data.success) {
      // alert('审核通过成功！');
      await fetchCertifications(); // 操作成功后刷新列表
    } else {
      // alert(`操作失败: ${response.message}`);
      console.error("通过审核失败:", response.data.message);
    }
  } catch (error) {
    // alert('操作失败，请稍后重试');
    console.error("通过审核时发生网络错误:", error);
  }
};

const handleReject = async () => {
  if (!rejectReason.value.trim()) {
    alert('请填写拒绝原因！');
    return;
  }

  try {
    const response = await reviewCertification(selectedCert.value.certificationId, 2, rejectReason.value);
    if (response.data.success) {
      // alert('拒绝操作成功！');
      closeRejectModal();
      await fetchCertifications(); // 操作成功后刷新列表
    } else {
      // alert(`操作失败: ${response.message}`);
      console.error("拒绝审核失败:", response.data.message);
    }
  } catch (error) {
    // alert('操作失败，请稍后重试');
    console.error("拒绝审核时发生网络错误:", error);
  }
};
</script>

<style scoped>
/* 样式部分保持不变，直接从你的原文件中复制过来即可 */
.cert-admin-container {
  padding: 0;
  font-family: var(--font-family-base, 'Inter', sans-serif);
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out forwards;
}

.animate-slide-up {
  opacity: 0;
  animation: slideUp 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  animation-delay: var(--delay, 0s);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
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

/* 头部 */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  margin: 0;
  color: var(--text-primary);
}

.controls-wrapper {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

/* 筛选标签 */
.filter-tabs {
  display: flex;
  background: var(--bg-secondary, rgba(40, 42, 60, 0.5));
  border-radius: var(--border-radius-md, 12px);
  padding: 0.4rem;
  border: 1px solid var(--border-color);
}

.filter-tabs button {
  background: transparent;
  border: none;
  color: var(--text-secondary, #a0a0b0);
  padding: 0.6rem 1rem;
  border-radius: var(--border-radius-sm, 8px);
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.filter-tabs button:hover {
  color: var(--accent-color, #9f78ff);
}

.filter-tabs button.active {
  background: var(--accent-color, #9f78ff);
  color: white;
  box-shadow: 0 4px 15px var(--shadow-color, rgba(159, 120, 255, 0.3));
}

.count-badge {
  background: rgba(0, 0, 0, 0.1);
  color: var(--text-secondary);
  padding: 0.1rem 0.5rem;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 500;
}

.filter-tabs button.active .count-badge {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

/* 排序控件 */
.sort-control {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
}

.sort-dropdown {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  padding: 0.6rem 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

.sort-dropdown:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 2px var(--shadow-color);
}

/* 列表和卡片 */
.certs-list {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
}

.cert-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-left-width: 4px;
  border-radius: var(--border-radius-md, 16px);
  backdrop-filter: var(--backdrop-filter, blur(10px));
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  padding: 1.5rem;
  gap: 1rem;
  transition: all 0.3s ease;
}

.cert-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.1));
  border-color: var(--accent-color, #9f78ff);
}

.status-border-0 {
  border-left-color: #f39c12;
}

.status-border-1 {
  border-left-color: #2ecc71;
}

.status-border-2 {
  border-left-color: #e74c3c;
}

.card-main-content {
  flex: 1 1 400px;
  min-width: 0; /* 修正flex布局中内容溢出的问题 */
}

.info-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
  gap: 1rem;
}

.business-name {
  font-size: 1.25rem;
  margin: 0;
  color: var(--text-primary, #fff);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.status-badge {
  padding: 0.3rem 0.8rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
  flex-shrink: 0;
}

.status-0 {
  background-color: rgba(243, 156, 18, 0.1);
  color: #f39c12;
}

.status-1 {
  background-color: rgba(46, 204, 113, 0.1);
  color: #2ecc71;
}

.status-2 {
  background-color: rgba(231, 76, 60, 0.1);
  color: #e74c3c;
}

.card-info p {
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.card-info strong {
  color: var(--text-primary);
  font-weight: 500;
}

.card-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  flex-shrink: 0;
  margin-left: auto;
}

.details-btn, .approve-btn, .reject-btn {
  border: 1px solid transparent;
  padding: 0.6rem 1.2rem;
  border-radius: var(--border-radius-sm, 8px);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.details-btn {
  background: var(--bg-hover);
  color: var(--text-secondary);
  border-color: var(--border-color);
}

.details-btn:hover {
  border-color: var(--accent-color);
  color: var(--accent-color);
  background: var(--bg-primary);
}

.approve-btn {
  background: #2ecc71;
  color: white;
}

.approve-btn:hover {
  background: #28b463;
  transform: scale(1.05);
}

.reject-btn {
  background: #e74c3c;
  color: white;
}

.reject-btn:hover {
  background: #c0392b;
  transform: scale(1.05);
}

/* 空状态 & 加载状态 */
.empty-state {
  text-align: center;
  padding: 4rem 0;
  color: var(--text-secondary, #a0a0b0);
  background: var(--bg-secondary);
  border-radius: var(--border-radius-md);
}

.empty-state i {
  font-size: 3rem;
  opacity: 0.7;
}

.empty-state p {
  margin-top: 1rem;
  font-size: 1.1rem;
}

/* 分页 */
.pagination-controls {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 2rem;
  gap: 0.75rem;
  color: var(--text-secondary);
}

.pagination-controls button {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  width: 38px;
  height: 38px;
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  transition: all 0.3s ease;
}

.pagination-controls button:hover:not(:disabled) {
  background-color: var(--accent-color);
  border-color: var(--accent-color);
  color: white;
}

.pagination-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 模态框 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(5px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: var(--bg-primary, #1e2139);
  color: var(--text-primary, #fff);
  padding: 2rem;
  border-radius: var(--border-radius-md, 16px);
  border: 1px solid var(--border-color);
  width: 90%;
  max-width: 800px;
  position: relative;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
}

.modal-content h2, .modal-content h3 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  color: var(--text-primary, #fff);
}

.close-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: none;
  border: none;
  color: var(--text-secondary);
  font-size: 1.5rem;
  cursor: pointer;
}

.details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.detail-item {
  font-size: 0.9rem;
}

.detail-item.full-width {
  grid-column: 1 / -1;
}

.detail-item label {
  color: var(--text-secondary, #a0a0b0);
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.detail-item p {
  margin: 0;
  background: var(--bg-hover, rgba(255, 255, 255, 0.05));
  padding: 0.75rem;
  border-radius: var(--border-radius-sm, 8px);
  word-wrap: break-word;
}

.license-thumbnail {
  max-width: 200px;
  border-radius: var(--border-radius-sm, 8px);
  cursor: pointer;
  transition: transform 0.3s ease;
}

.license-thumbnail:hover {
  transform: scale(1.05);
}

.small-modal {
  max-width: 450px;
  text-align: center;
}

.small-modal p {
  color: var(--text-secondary);
  margin-bottom: 1.5rem;
}

.small-modal textarea {
  width: 100%;
  height: 100px;
  background: var(--bg-hover, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  padding: 0.75rem;
  color: var(--text-primary);
  margin-bottom: 1.5rem;
}

.confirm-reject-btn {
  width: 100%;
  padding: 0.8rem;
  background: #e74c3c;
  color: white;
  border: none;
  border-radius: var(--border-radius-sm);
  font-weight: 600;
  cursor: pointer;
  transition: background 0.3s ease;
}

.confirm-reject-btn:hover {
  background: #c0392b;
}

.image-viewer-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.85);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1001;
  cursor: pointer;
}

.image-viewer-overlay img {
  max-width: 90vw;
  max-height: 90vh;
  object-fit: contain;
}
</style>
