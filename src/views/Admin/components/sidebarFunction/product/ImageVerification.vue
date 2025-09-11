<template>
  <div class="image-verification-container animate-fade-in">
    <!-- 统计卡片区域 -->
    <div class="stats-grid">
      <div class="stat-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-icon icon-pending"><i class="fas fa-hourglass-half"></i></div>
        <div class="card-content">
          <p class="card-title">待审核图片</p>
          <h2 class="card-value">{{ stats.pending }}</h2>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.2s;">
        <div class="card-icon icon-approved"><i class="fas fa-check-double"></i></div>
        <div class="card-content">
          <p class="card-title">已通过图片</p>
          <h2 class="card-value">{{ stats.approved }}</h2>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.3s;">
        <div class="card-icon icon-rejected"><i class="fas fa-times-circle"></i></div>
        <div class="card-content">
          <p class="card-title">已拒绝图片</p>
          <h2 class="card-value">{{ stats.rejected }}</h2>
        </div>
      </div>
    </div>

    <!-- 头部：标题和操作区 -->
    <div class="header-bar">
      <h1 class="page-title">图片审核中心</h1>
      <div class="actions-group">
        <div class="filter-tabs">
          <button v-for="(label, value) in verificationStatusMap" :key="value"
                  :class="{ active: selectedStatus == value }"
                  @click="changeStatusFilter(parseInt(value))">
            {{ label }}
          </button>
        </div>
        <div class="search-box">
          <i class="fas fa-search search-icon"></i>
          <input type="text" v-model="searchQuery" @keyup.enter="handleSearch" placeholder="搜索商品ID/标题/图片ID...">
        </div>
      </div>
    </div>

    <!-- 批量操作栏 -->
    <div v-if="selectedImages.size > 0" class="batch-actions-bar animate-fade-in">
      <span>已选择 {{ selectedImages.size }} 张图片</span>
      <div class="batch-buttons">
        <button class="batch-btn btn-approve" @click="batchUpdateStatus(1)"><i class="fas fa-check"></i> 批量通过</button>
        <button class="batch-btn btn-reject" @click="openRejectModal(Array.from(selectedImages))"><i class="fas fa-times"></i> 批量拒绝</button>
      </div>
    </div>

    <!-- 图片审核网格 -->
    <div class="image-grid">
      <div v-if="loading" class="loading-state">
        <i class="fas fa-spinner fa-spin"></i>
        <p>正在加载...</p>
      </div>
      <div v-else-if="imageList.length === 0" class="empty-state">
        <i class="fas fa-images"></i>
        <p>当前分类下没有图片</p>
      </div>
      <div v-for="image in imageList" :key="image.imageId" class="image-card" :class="{ selected: selectedImages.has(image.imageId) }" @click="toggleSelection(image.imageId)">
        <div class="card-checkbox">
          <span class="checkmark"></span>
        </div>
        <div class="image-preview">
          <img :src="image.imageUrl" :alt="`Image for product ${image.productId}`" @error="onImageError">
          <div class="image-overlay">
            <button class="overlay-btn" @click.stop="viewFullImage(image.imageUrl)"><i class="fas fa-expand-arrows-alt"></i></button>
          </div>
        </div>
        <div class="card-content">
          <p class="product-info">商品ID: <strong>{{ image.productId }}</strong></p>
          <p class="product-title">{{ image.productTitle || '未知商品' }}</p>
          <p class="upload-time"><i class="fas fa-calendar-alt"></i> {{ formatDate(image.createdAt) }}</p>
          <div v-if="image.verificationStatus === 2 && image.rejectionReason" class="rejection-reason" :title="image.rejectionReason">
            <i class="fas fa-info-circle"></i> {{ image.rejectionReason }}
          </div>
        </div>
        <div v-if="image.verificationStatus === 0" class="card-actions">
          <button class="action-btn approve" @click.stop="updateStatus([{ imageId: image.imageId, status: 1 }])"><i class="fas fa-check"></i> 通过</button>
          <button class="action-btn reject" @click.stop="openRejectModal([image.imageId])"><i class="fas fa-times"></i> 拒绝</button>
        </div>
      </div>
    </div>

    <!-- 分页控件 -->
    <div class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1"><i class="fas fa-chevron-left"></i></button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页 (共 {{ pagination.total }} 条)</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages"><i class="fas fa-chevron-right"></i></button>
    </div>

    <!-- 拒绝理由模态框 (HTML结构不变) -->
    <div v-if="showRejectModal" class="modal-overlay" @click="closeRejectModal">
      <div class="modal-content reject-modal" @click.stop>
        <div class="modal-header">
          <h3>填写拒绝理由</h3>
          <button class="modal-close" @click="closeRejectModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <p>您将拒绝 {{ imagesToReject.length }} 张图片。请选择或输入拒绝原因：</p>
          <div class="reason-options">
            <button v-for="reason in commonReasons" :key="reason" @click="rejectionReason = reason">{{ reason }}</button>
          </div>
          <textarea v-model="rejectionReason" rows="4" placeholder="或在此输入自定义理由..."></textarea>
        </div>
        <div class="modal-footer">
          <button class="btn-cancel" @click="closeRejectModal">取消</button>
          <button class="btn-confirm-reject" @click="confirmRejection" :disabled="!rejectionReason">确认拒绝</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { getReviewImages, reviewImages } from '@/api/product';

// --- 静态配置 ---
const verificationStatusMap = { 0: '待审核', 1: '已通过', 2: '已拒绝' };
const commonReasons = ['图片不清晰', '内容违规', '非商品实拍图', '包含联系方式'];

// --- 响应式状态 ---
const imageList = ref([]);
const stats = ref({ pending: 0, approved: 0, rejected: 0 });
const loading = ref(true);
const searchQuery = ref('');
const selectedStatus = ref(0);
const selectedImages = ref(new Set());
const showRejectModal = ref(false);
const rejectionReason = ref('');
const imagesToReject = ref([]);
const pagination = ref({ currentPage: 1, pageSize: 12, total: 0 });

// --- 计算属性 ---
const totalPages = computed(() => Math.ceil(pagination.value.total / pagination.value.pageSize) || 1);

// --- API 调用 ---

// 新增: 获取顶部统计数据的函数
const fetchStats = async () => {
  try {
    // 并行发起三个请求来获取各个状态的图片总数
    const [pendingRes, approvedRes, rejectedRes] = await Promise.all([
      getReviewImages({status: 0, page: 1, size: 1}), // 待审核
      getReviewImages({status: 1, page: 1, size: 1}), // 已通过
      getReviewImages({status: 2, page: 1, size: 1})  // 已拒绝
    ]);

    // 从各自的响应中提取 total 并更新 stats
    if (pendingRes.data && pendingRes.data.success) {
      stats.value.pending = pendingRes.data.data.total;
    }
    if (approvedRes.data && approvedRes.data.success) {
      stats.value.approved = approvedRes.data.data.total;
    }
    if (rejectedRes.data && rejectedRes.data.success) {
      stats.value.rejected = rejectedRes.data.data.total;
    }
  } catch (error) {
    console.error("获取统计数据失败:", error);
  }
};

const fetchImages = async () => {
  loading.value = true;
  selectedImages.value.clear();
  try {
    const params = {
      status: selectedStatus.value,
      page: pagination.value.currentPage,
      size: pagination.value.pageSize,
    };
    if (searchQuery.value) {
      params.query = searchQuery.value;
    }
    const response = await getReviewImages(params);
    if (response.data && response.data.success) {
      imageList.value = response.data.data.items;
      pagination.value.total = response.data.data.total;
    } else {
      console.error("获取图片列表失败:", response.data ? response.data.message : '响应格式不正确');
      imageList.value = [];
      pagination.value.total = 0;
    }
  } catch (error) {
    console.error("API请求异常:", error);
    imageList.value = [];
    pagination.value.total = 0;
  } finally {
    loading.value = false;
  }
};

// --- 方法 ---
const updateStatus = async (reviews) => {
  try {
    const response = await reviewImages(reviews);
    if (response.data && response.data.success) {
      await fetchImages(); // 重新加载当前列表
      await fetchStats();  // 更新: 操作成功后，重新获取统计数据
    } else {
      console.error("审核操作失败:", response.data ? response.data.message : '响应格式不正确');
    }
  } catch (error) {
    console.error("审核API请求异常:", error);
  }
};

const handleSearch = () => {
  pagination.value.currentPage = 1;
  fetchImages();
};

const batchUpdateStatus = (status) => {
  const reviews = Array.from(selectedImages.value).map(id => ({imageId: id, status: status}));
  updateStatus(reviews);
};

const openRejectModal = (ids) => {
  imagesToReject.value = ids;
  showRejectModal.value = true;
};

const closeRejectModal = () => {
  showRejectModal.value = false;
  rejectionReason.value = '';
  imagesToReject.value = [];
};

const confirmRejection = () => {
  const reviews = imagesToReject.value.map(id => ({
    imageId: id,
    status: 2,
    reason: rejectionReason.value
  }));
  updateStatus(reviews);
  closeRejectModal();
};

const changeStatusFilter = (status) => {
  selectedStatus.value = status;
  // pagination.value.currentPage = 1; // 这行是多余的，因为 watch 中已经处理了
};

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
    fetchImages();
  }
};

const toggleSelection = (id) => {
  if (selectedImages.value.has(id)) {
    selectedImages.value.delete(id);
  } else {
    selectedImages.value.add(id);
  }
};

const viewFullImage = (url) => {
  window.open(url, '_blank');
};

const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  return new Date(dateString).toLocaleString('zh-CN');
};

const onImageError = (event) => {
  event.target.src = 'https://placehold.co/600x600/ef4444/f0f0f5?text=Image+Error';
};

// --- 生命周期和侦听器 ---
onMounted(() => {
  fetchImages();
  fetchStats(); // 更新: 组件挂载时也要获取统计数据
});

watch(selectedStatus, () => {
  pagination.value.currentPage = 1;
  fetchImages();
});

</script>

<style scoped>
/* 基础样式 */
.image-verification-container {
  padding: 2rem;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary, #f0f0f5);
}

.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards var(--delay, 0s);
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 统计卡片 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: var(--bg-primary, #ffffff);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, none);
  display: flex;
  align-items: center;
  gap: 1.5rem;
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15));
}

.card-icon {
  font-size: 2rem;
  padding: 1rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
}

.icon-pending {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.1));
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.icon-approved {
  background: linear-gradient(135deg, rgba(46, 204, 113, 0.2), rgba(39, 174, 96, 0.1));
  color: #2ecc71;
  border: 1px solid rgba(46, 204, 113, 0.3);
}

.icon-rejected {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(220, 38, 38, 0.1));
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.card-content {
  flex: 1;
}

.card-title {
  font-size: 0.875rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0 0 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
}

.card-value {
  font-size: 2rem;
  font-weight: 700;
  margin: 0 0 0.5rem;
  color: var(--text-primary, #f0f0f5);
}

.card-trend {
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: var(--text-secondary, #a0a0b0);
}

.card-trend.positive {
  color: #10b981;
}

.card-trend.negative {
  color: #ef4444;
}

/* 头部栏 */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0;
  color: var(--text-primary, #f0f0f5);
}

.actions-group {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.filter-tabs {
  display: flex;
  background: var(--bg-primary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 4px;
}

.filter-tabs button {
  background: transparent;
  border: none;
  color: var(--text-secondary, #a0a0b0);
  padding: 0.5rem 1rem;
  border-radius: var(--border-radius-sm, 6px);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.filter-tabs button.active {
  background: var(--accent-color, #9f78ff);
  color: #fff;
  box-shadow: 0 2px 10px var(--shadow-color, rgba(159, 120, 255, 0.3));
}

.search-box {
  position: relative;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary, #a0a0b0);
}

.search-box input {
  background: var(--bg-primary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.6rem 1rem 0.6rem 2.5rem;
  color: var(--text-primary, #f0f0f5);
  width: 250px;
}

.search-box input::placeholder {
  color: var(--text-secondary, #a0a0b0);
}

/* 批量操作栏 */
.batch-actions-bar {
  background: var(--bg-hover, rgba(159, 120, 255, 0.1));
  border: 1px solid var(--accent-color, rgba(159, 120, 255, 0.3));
  padding: 0.75rem 1.5rem;
  margin-bottom: 1.5rem;
  border-radius: var(--border-radius-sm, 8px);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.batch-actions-bar span {
  font-weight: 600;
  color: var(--text-primary, #f0f0f5);
}

.batch-buttons {
  display: flex;
  gap: 1rem;
}

.batch-btn {
  padding: 0.5rem 1rem;
  border-radius: var(--border-radius-sm, 6px);
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-approve {
  background-color: #2ecc71;
  color: #fff;
}

.btn-reject {
  background-color: #ef4444;
  color: #fff;
}

/* 图片网格 */
.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.image-card {
  background: var(--bg-primary, #ffffff);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 12px);
  overflow: hidden;
  transition: all 0.3s ease;
  position: relative;
  cursor: pointer;
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
}

.image-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.2));
  border-color: var(--accent-color, #9f78ff);
}

.image-card.selected {
  border-color: var(--accent-color, #9f78ff);
  box-shadow: 0 0 0 3px var(--shadow-color, rgba(159, 120, 255, 0.5));
}

.image-preview {
  position: relative;
  width: 100%;
  padding-top: 100%; /* 1:1 Aspect Ratio */
}

.image-preview img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  opacity: 0;
  transition: opacity 0.3s ease;
  display: flex;
  justify-content: center;
  align-items: center;
}

.image-card:hover .image-overlay {
  opacity: 1;
}

.overlay-btn {
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  font-size: 1rem;
  cursor: pointer;
}

.card-content {
  padding: 1rem;
}

.product-info, .product-title, .upload-time {
  margin: 0 0 0.5rem 0;
  color: var(--text-secondary, #a0a0b0);
  font-size: 0.85rem;
}

.product-title {
  font-size: 1rem;
  color: var(--text-primary, #f0f0f5);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rejection-reason {
  background: rgba(239, 68, 68, 0.1);
  color: #f87171;
  padding: 0.5rem;
  border-radius: var(--border-radius-sm, 6px);
  font-size: 0.8rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-actions {
  display: flex;
  gap: 0.5rem;
  padding: 0 1rem 1rem;
}

.action-btn {
  flex: 1;
  padding: 0.6rem;
  border-radius: var(--border-radius-sm, 6px);
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn.approve {
  background: #2ecc71;
  color: #fff;
}

.action-btn.reject {
  background: #ef4444;
  color: #fff;
}

.action-btn:hover {
  opacity: 0.8;
}

/* 复选框样式 */
.card-checkbox {
  position: absolute;
  top: 1rem;
  left: 1rem;
  z-index: 2;
}

.checkmark {
  height: 22px;
  width: 22px;
  background-color: rgba(0, 0, 0, 0.5);
  border: 2px solid #fff;
  border-radius: 4px;
  transition: all 0.2s ease;
  display: block;
  position: relative;
}

.image-card.selected .checkmark {
  background-color: var(--accent-color, #9f78ff);
  border-color: var(--accent-color, #9f78ff);
}

.checkmark:after {
  content: "";
  position: absolute;
  display: none;
  left: 7px;
  top: 3px;
  width: 5px;
  height: 10px;
  border: solid white;
  border-width: 0 3px 3px 0;
  transform: rotate(45deg);
}

.image-card.selected .checkmark:after {
  display: block;
}

/* 空状态和分页 */
.empty-state, .loading-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 4rem 0;
  color: var(--text-secondary, #a0a0b0);
}

.empty-state i, .loading-state i {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 2rem;
  gap: 1rem;
}

.pagination-controls button {
  background: var(--bg-primary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  color: var(--text-secondary, #a0a0b0);
  border-radius: var(--border-radius-sm, 8px);
  width: 36px;
  height: 36px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.pagination-controls button:hover:not(:disabled) {
  background: var(--bg-hover, rgba(255, 255, 255, 0.1));
  color: var(--text-primary, #f0f0f5);
}

.pagination-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-controls span {
  color: var(--text-primary, #f0f0f5);
  font-weight: 500;
}

/* 模态框 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(5px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: var(--bg-primary, #2a2c3d);
  border-radius: var(--border-radius-md, 16px);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  width: 90%;
  max-width: 500px;
}

.modal-header {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--text-primary, #f0f0f5);
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--text-secondary, #a0a0b0);
  cursor: pointer;
  transition: color 0.3s ease;
}

.modal-close:hover {
  color: var(--text-primary, #f0f0f5);
}

.modal-body {
  padding: 1.5rem;
}

.modal-body p {
  margin: 0 0 1rem;
  color: var(--text-secondary, #a0a0b0);
}

.reason-options {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.reason-options button {
  background: var(--bg-hover, rgba(255, 255, 255, 0.1));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.2));
  color: var(--text-primary, #f0f0f5);
  padding: 0.5rem 0.75rem;
  border-radius: var(--border-radius-sm, 6px);
  cursor: pointer;
  transition: all 0.3s ease;
}

.reason-options button:hover {
  background: var(--accent-color, #9f78ff);
  color: #fff;
}

.modal-body textarea {
  width: 100%;
  box-sizing: border-box;
  background: var(--bg-hover, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.75rem;
  color: var(--text-primary, #f0f0f5);
  resize: vertical;
  min-height: 100px;
}

.modal-body textarea::placeholder {
  color: var(--text-secondary, #a0a0b0);
}

.modal-footer {
  padding: 1rem 1.5rem;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  border-top: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.btn-cancel, .btn-confirm-reject {
  padding: 0.75rem 1.5rem;
  border-radius: var(--border-radius-sm, 8px);
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-cancel {
  background: var(--bg-hover, rgba(255, 255, 255, 0.1));
  color: var(--text-primary, #f0f0f5);
}

.btn-cancel:hover {
  background: var(--bg-hover, rgba(255, 255, 255, 0.2));
}

.btn-confirm-reject {
  background: #ef4444;
  color: #fff;
}

.btn-confirm-reject:hover:not(:disabled) {
  background: #dc2626;
}

.btn-confirm-reject:disabled {
  background: var(--text-secondary, #a0a0b0);
  cursor: not-allowed;
  opacity: 0.6;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .image-verification-container {
    padding: 1rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .header-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .actions-group {
    flex-direction: column;
    gap: 1rem;
  }

  .search-box input {
    width: 100%;
  }

  .image-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }

  .modal-content {
    width: 95%;
    margin: 1rem;
  }
}

@media (max-width: 480px) {
  .image-grid {
    grid-template-columns: 1fr;
  }

  .stat-card {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }

  .batch-actions-bar {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>
