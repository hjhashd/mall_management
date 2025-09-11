<template>
  <div class="review-management-container animate-fade-in">
    <!-- 头部 -->
    <div class="header-bar">
      <h1 class="page-title">评价管理</h1>
    </div>

    <!-- 筛选控件 -->
    <div class="filter-controls">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <!-- 注意：搜索功能当前为前端实现，刷新或翻页后会重置。建议后续在后端实现该功能。 -->
        <input type="text" v-model="filters.searchQuery" placeholder="搜索商品名称 / 评价内容...">
      </div>
      <div class="filter-group">
        <select v-model="filters.ratingOption">
          <option value="">所有评分</option>
          <option value="good">好评 (4-5星)</option>
          <option value="medium">中评 (2-3星)</option>
          <option value="bad">差评 (1星)</option>
          <option value="has_image">有图评价</option>
        </select>
        <select v-model="filters.replyStatus">
          <option value="">所有回复状态</option>
          <option value="unreplied">待回复</option>
          <option value="replied">已回复</option>
        </select>
        <button class="reset-btn" @click="resetFilters">重置</button>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-state">
      <i class="fas fa-spinner fa-spin"></i>
      <p>正在加载评价数据...</p>
    </div>

    <!-- 错误状态 -->
    <div v-else-if="error" class="empty-state error-state">
      <i class="fas fa-exclamation-triangle"></i>
      <p>加载数据失败: {{ error }}</p>
      <button @click="fetchReviews" class="reset-btn">点击重试</button>
    </div>

    <!-- 评价列表 -->
    <div v-else class="reviews-list">
      <div v-if="displayedReviews.length === 0" class="empty-state">
        <i class="fas fa-comment-slash"></i>
        <p>没有找到匹配的评价</p>
      </div>
      <div
          v-for="(review, index) in displayedReviews"
          :key="review.reviewId"
          class="review-card animate-slide-up"
          :style="{ '--delay': `${index * 0.07}s` }"
      >
        <!-- 评价头部：用户信息和评分 -->
        <div class="card-header">
          <div class="user-info">
            <img :src="review.userAvatar || 'https://placehold.co/40x40/95a5a6/ffffff?text=U'" alt="avatar" class="user-avatar">
            <span class="username">{{ review.isAnonymous ? '匿名用户' : review.username }}</span>
          </div>
          <div class="rating-info">
            <span class="stars" :class="getRatingInfo(review.rating).className">
              <i v-for="n in 5" :key="n" class="fas fa-star" :class="{ 'filled': n <= review.rating }"></i>
            </span>
            <span class="rating-text" :class="getRatingInfo(review.rating).className">
              {{ getRatingInfo(review.rating).text }}
            </span>
          </div>
        </div>

        <!-- 评价主体：内容和图片 -->
        <div class="card-body">
          <p class="review-content">{{ review.content }}</p>
          <div v-if="review.imageUrls && review.imageUrls.length > 0" class="image-gallery">
            <img
                v-for="(img, imgIndex) in review.imageUrls"
                :key="imgIndex"
                :src="img"
                alt="review image"
                @click="openImageViewer(img)"
            >
          </div>
          <div class="review-meta">
            <span>评价时间: {{ formatDate(review.createdAt) }}</span>
          </div>
        </div>

        <!-- 关联商品 -->
        <div class="product-snippet">
          <img :src="review.productImage || 'https://placehold.co/100x100/cccccc/ffffff?text=P'" :alt="review.productName" class="product-image">
          <p class="product-name">{{ review.productName }}</p>
        </div>

        <!-- 回复区域 -->
        <div class="replies-section">
          <!-- 用户追评和其他回复 -->
          <div v-for="reply in review.replies" :key="reply.replyId" class="reply-item" :class="{'user-append': reply.isAppend}">
            <p class="reply-content">
              <strong>[{{ reply.isAppend ? '用户追评' : '用户回复' }}]</strong>
              {{ reply.content }}
            </p>
            <span class="reply-time">{{ formatDate(reply.createTime) }}</span>
          </div>
          <!-- 商家回复 -->
          <div v-if="review.sellerReply" class="reply-item seller-reply">
            <p class="reply-content">
              <strong>[商家回复]</strong>
              {{ review.sellerReply }}
            </p>
          </div>
          <!-- 回复操作区 -->
          <div class="reply-action" v-if="!review.sellerReply">
            <textarea v-model="review.newReply" placeholder="输入您的回复..."></textarea>
            <button @click="submitReply(review)" :disabled="submittingReply[review.reviewId]">
              <i v-if="submittingReply[review.reviewId]" class="fas fa-spinner fa-spin"></i>
              {{ submittingReply[review.reviewId] ? '提交中...' : '提交回复' }}
            </button>
          </div>
        </div>

        <!-- 操作按钮 -->
        <div class="card-actions">
          <button class="action-btn delete-btn" @click="confirmDelete(review.reviewId)">
            <i class="fas fa-trash-alt"></i> 删除评价
          </button>
        </div>
      </div>
    </div>

    <!-- 分页 -->
    <div v-if="totalPages > 1" class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1"><i class="fas fa-chevron-left"></i></button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages"><i class="fas fa-chevron-right"></i></button>
    </div>

    <!-- 图片查看器 -->
    <div v-if="isImageViewerOpen" class="image-viewer-overlay" @click="closeImageViewer">
      <img :src="imageViewerSrc" alt="评价大图" class="animate-fade-in">
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
// 确保从你的项目正确路径导入API函数
import { getAllReviews, addSellerReply, deleteReview } from '@/api/review.js';

// --- 状态管理 ---
const reviews = ref([]);
const loading = ref(true);
const error = ref(null);
const submittingReply = ref({}); // 单独跟踪每个回复的提交状态

const filters = ref({
  searchQuery: '',
  ratingOption: '', // 用于 <select> 的 v-model
  replyStatus: '',
});

const pagination = ref({
  currentPage: 1,
  pageSize: 5,
  totalItems: 0,
});

// --- 计算属性 ---
const totalPages = computed(() => Math.ceil(pagination.value.totalItems / pagination.value.pageSize));

// 前端搜索实现 (仅对当前页数据生效)
const displayedReviews = computed(() => {
  if (!filters.value.searchQuery) {
    return reviews.value;
  }
  const query = filters.value.searchQuery.toLowerCase();
  return reviews.value.filter(review =>
      (review.productName && review.productName.toLowerCase().includes(query)) ||
      (review.content && review.content.toLowerCase().includes(query))
  );
});


// --- API调用与逻辑 ---
const fetchReviews = async () => {
  loading.value = true;
  error.value = null;
  try {
    const params = {
      page: pagination.value.currentPage,
      size: pagination.value.pageSize,
      hasImage: null,
      rating: null,
      hasSellerReply: null,
    };

    // 映射前端筛选条件到后端API参数
    switch (filters.value.ratingOption) {
      case 'good': params.rating = 5; break; // 后端目前只支持单星筛选，这里简化处理
      case 'medium': params.rating = 3; break;
      case 'bad': params.rating = 1; break;
      case 'has_image': params.hasImage = true; break;
    }
    if (filters.value.replyStatus) {
      params.hasSellerReply = filters.value.replyStatus === 'replied';
    }

    const response = await getAllReviews(params);
    // 修改这里：使用 response.data.data 而不是 response.data
    reviews.value = response.data.data.list.map(r => ({ ...r, newReply: '' }));
    pagination.value.totalItems = response.data.data.total;

  } catch (err) {
    console.error("获取评价失败:", err);
    error.value = err.response?.data?.message || err.message || '网络错误，请稍后重试';
  } finally {
    loading.value = false;
  }
};

onMounted(fetchReviews);

// 监听筛选和页码变化，重新获取数据
watch(
    [() => filters.value.ratingOption, () => filters.value.replyStatus, () => pagination.value.currentPage],
    () => {
      // 每次筛选变化都回到第一页
      if (pagination.value.currentPage !== 1) {
        pagination.value.currentPage = 1;
      } else {
        fetchReviews();
      }
    },
    { deep: true }
);


// --- 用户操作 ---
const resetFilters = () => {
  filters.value = { searchQuery: '', ratingOption: '', replyStatus: '' };
  if (pagination.value.currentPage !== 1) {
    pagination.value.currentPage = 1;
  } else {
    fetchReviews();
  }
};

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
  }
};

const submitReply = async (review) => {
  const replyContent = review.newReply.trim();
  if (!replyContent) {
    alert('回复内容不能为空！'); // 在真实项目中请使用UI组件库的Message消息提示
    return;
  }

  submittingReply.value[review.reviewId] = true;
  try {
    await addSellerReply(review.reviewId, replyContent);
    // 成功后刷新当前页数据
    await fetchReviews();
  } catch (err) {
    console.error("回复提交失败:", err);
    alert('回复失败: ' + (err.response?.data?.message || err.message));
  } finally {
    submittingReply.value[review.reviewId] = false;
  }
};

const confirmDelete = async (reviewId) => {
  // 在真实项目中请使用UI组件库的Modal确认框
  if (window.confirm(`确定要删除这条评价吗？此操作不可逆。`)) {
    try {
      await deleteReview(reviewId);
      alert('删除成功');
      // 如果删除的是当前页的最后一条数据，且不是第一页，则返回上一页
      if (reviews.value.length === 1 && pagination.value.currentPage > 1) {
        pagination.value.currentPage--;
      } else {
        await fetchReviews();
      }
    } catch (err) {
      console.error("删除评价失败:", err);
      alert('删除失败: ' + (err.response?.data?.message || err.message));
    }
  }
};

// --- 辅助函数 ---
const getRatingInfo = (rating) => {
  if (rating >= 4) return { text: '好评', className: 'rating-good' };
  if (rating >= 2) return { text: '中评', className: 'rating-medium' };
  return { text: '差评', className: 'rating-bad' };
};

const formatDate = (dateString) => dateString ? new Date(dateString).toLocaleString('zh-CN', { hour12: false }) : '';

const isImageViewerOpen = ref(false);
const imageViewerSrc = ref('');
const openImageViewer = (src) => {
  imageViewerSrc.value = src;
  isImageViewerOpen.value = true;
};
const closeImageViewer = () => isImageViewerOpen.value = false;
</script>

<style scoped>
/* 样式部分保持不变，此处省略... */
/* 新增加载和错误状态的样式 */
.loading-state, .error-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--text-secondary);
  background: var(--bg-primary);
  border-radius: var(--border-radius-md);
  border: 2px dashed var(--border-color);
}
.loading-state i, .error-state i {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: var(--accent-color);
}
.error-state i {
  color: #dc2626;
}
.loading-state p, .error-state p {
  margin: 0 0 1rem;
  font-size: 1.1rem;
  font-weight: 500;
}
.error-state button {
  font-size: 0.95rem;
  padding: 0.75rem 1.5rem;
}
/* 其他样式... */
.review-management-container {
  font-family: var(--font-family-base);
  padding: 1.5rem;
  background: var(--bg-secondary);
  min-height: 100vh;
}

.animate-fade-in {
  animation: fadeIn 0.6s ease-out forwards;
}

.animate-slide-up {
  opacity: 0;
  animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  animation-delay: var(--delay, 0s);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.header-bar {
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--border-color);
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.page-title::before {
  content: '';
  display: inline-block;
  width: 4px;
  height: 1.75rem;
  background: var(--accent-color);
  border-radius: 2px;
}

.filter-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 1.25rem;
  padding: 1.75rem;
  background: var(--bg-primary);
  border-radius: var(--border-radius-md);
  border: 1px solid var(--border-color);
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px var(--shadow-color);
}

.search-bar {
  flex: 1 1 320px;
  position: relative;
}

.search-bar i {
  position: absolute;
  top: 50%;
  left: 1rem;
  transform: translateY(-50%);
  color: var(--text-secondary);
  z-index: 1;
}

.search-bar input {
  width: 100%;
  padding: 0.875rem 1rem 0.875rem 2.75rem;
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
  background: var(--bg-secondary);
  color: var(--text-primary);
  font-size: 0.95rem;
  transition: all 0.3s ease;
}

.search-bar input:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.1);
}

.filter-group {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}

.filter-group select {
  padding: 0.875rem 1.25rem;
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
  background: var(--bg-secondary);
  color: var(--text-primary);
  cursor: pointer;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  min-width: 150px;
}

.filter-group select:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.1);
}

.reset-btn {
  padding: 0.875rem 1.75rem;
  border: 1px solid var(--border-color);
  background: var(--bg-primary);
  color: var(--text-secondary);
  border-radius: var(--border-radius-sm);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  white-space: nowrap;
}

.reset-btn:hover {
  color: var(--accent-color);
  border-color: var(--accent-color);
  background: var(--bg-hover);
  transform: translateY(-1px);
}

.reviews-list {
  display: grid;
  gap: 1.75rem;
}

.review-card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-md);
  overflow: hidden;
  transition: all 0.4s ease;
  box-shadow: 0 2px 12px var(--shadow-color);
}

.review-card:hover {
  box-shadow: 0 8px 32px var(--shadow-color);
  transform: translateY(-2px);
  border-color: var(--accent-color);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.75rem;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.875rem;
}

.user-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 2px solid var(--border-color);
  object-fit: cover;
}

.username {
  font-weight: 600;
  color: var(--text-primary);
  font-size: 1rem;
}

.rating-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.stars .fa-star {
  color: #e2e8f0;
  font-size: 0.95rem;
}

.stars .fa-star.filled {
  color: #fbbf24;
}

.rating-text {
  font-weight: 600;
  font-size: 0.9rem;
  padding: 0.25rem 0.75rem;
  border-radius: var(--border-radius-sm);
}

.rating-good {
  color: #059669;
  background: rgba(5, 150, 105, 0.1);
}

.rating-medium {
  color: #d97706;
  background: rgba(217, 119, 6, 0.1);
}

.rating-bad {
  color: #dc2626;
  background: rgba(220, 38, 38, 0.1);
}

.card-body {
  padding: 1.75rem;
}

.review-content {
  color: var(--text-primary);
  line-height: 1.7;
  margin-bottom: 1.25rem;
  font-size: 1rem;
  white-space: pre-wrap;
}

.image-gallery {
  display: flex;
  gap: 0.875rem;
  flex-wrap: wrap;
  margin-bottom: 1.25rem;
}

.image-gallery img {
  width: 88px;
  height: 88px;
  border-radius: var(--border-radius-sm);
  object-fit: cover;
  cursor: pointer;
  transition: transform 0.3s ease;
  border: 2px solid var(--border-color);
}

.image-gallery img:hover {
  transform: scale(1.08);
  border-color: var(--accent-color);
}

.review-meta {
  font-size: 0.875rem;
  color: var(--text-secondary);
  padding: 0.75rem 1rem;
  background: var(--bg-hover);
  border-radius: var(--border-radius-sm);
  border-left: 3px solid var(--accent-color);
}

.product-snippet {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 1.25rem 1.75rem;
  background: var(--bg-secondary);
  border-top: 1px solid var(--border-color);
}

.product-image {
  width: 56px;
  height: 56px;
  border-radius: var(--border-radius-sm);
  border: 2px solid var(--border-color);
  object-fit: cover;
}

.product-name {
  font-weight: 500;
  color: var(--text-primary);
  margin: 0;
  font-size: 0.95rem;
}

.replies-section {
  padding: 1.75rem;
  border-top: 1px solid var(--border-color);
  background: rgba(var(--accent-color), 0.02);
}

.reply-item {
  padding: 1.25rem;
  border-radius: var(--border-radius-sm);
  margin-bottom: 1rem;
  transition: all 0.3s ease;
}

.reply-item:last-child {
  margin-bottom: 0;
}

.seller-reply {
  background: var(--bg-hover);
  border-left: 4px solid var(--accent-color);
  box-shadow: 0 2px 8px var(--shadow-color);
}

.user-append {
  background: rgba(217, 119, 6, 0.05);
  border-left: 4px solid #d97706;
}

.reply-content {
  margin: 0 0 0.75rem;
  color: var(--text-primary);
  line-height: 1.6;
  font-size: 0.95rem;
  white-space: pre-wrap;
}

.reply-content strong {
  margin-right: 0.75rem;
}
.seller-reply .reply-content strong {
  color: var(--accent-color);
}
.user-append .reply-content strong {
  color: #d97706;
}


.reply-time {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-style: italic;
}

.reply-action {
  margin-top: 1.75rem;
  padding: 1.25rem;
  background: var(--bg-primary);
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
}

.reply-action textarea {
  width: 100%;
  min-height: 88px;
  padding: 1rem;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  background: var(--bg-secondary);
  color: var(--text-primary);
  margin-bottom: 1rem;
  font-family: inherit;
  font-size: 0.95rem;
  line-height: 1.5;
  resize: vertical;
  transition: all 0.3s ease;
}

.reply-action textarea:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.1);
}

.reply-action button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-left: auto;
  padding: 0.75rem 1.75rem;
  border: none;
  background: var(--accent-color);
  color: white;
  border-radius: var(--border-radius-sm);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.95rem;
  white-space: nowrap;
}

.reply-action button:hover {
  background: var(--accent-color-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.3);
}
.reply-action button:disabled {
  background: #ccc;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.card-actions {
  padding: 1.25rem 1.75rem;
  border-top: 1px solid var(--border-color);
  text-align: right;
  background: var(--bg-secondary);
}

.action-btn {
  background: transparent;
  border: 1px solid transparent;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 0.625rem 1.25rem;
  border-radius: var(--border-radius-sm);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  white-space: nowrap;
}

.delete-btn {
  color: #dc2626;
  border-color: rgba(220, 38, 38, 0.2);
}

.delete-btn:hover {
  color: #ffffff;
  background: #dc2626;
  border-color: #dc2626;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.3);
}

.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 2.5rem;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--bg-primary);
  border-radius: var(--border-radius-md);
  border: 1px solid var(--border-color);
}

.pagination-controls button {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  width: 42px;
  height: 42px;
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.pagination-controls button:hover:not(:disabled) {
  background: var(--accent-color);
  color: white;
  border-color: var(--accent-color);
  transform: translateY(-1px);
}

.pagination-controls button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

.pagination-controls span {
  font-weight: 600;
  color: var(--text-primary);
  padding: 0 1rem;
  font-size: 0.95rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--text-secondary);
  background: var(--bg-primary);
  border-radius: var(--border-radius-md);
  border: 2px dashed var(--border-color);
}

.empty-state i {
  font-size: 3.5rem;
  opacity: 0.6;
  margin-bottom: 1rem;
  color: var(--accent-color);
}

.empty-state p {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 500;
}

.image-viewer-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1001;
  cursor: pointer;
  backdrop-filter: blur(8px);
}

.image-viewer-overlay img {
  max-width: 90vw;
  max-height: 90vh;
  object-fit: contain;
  border-radius: var(--border-radius-md);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
}

@media (max-width: 768px) {
  .review-management-container {
    padding: 1rem;
  }

  .filter-controls {
    flex-direction: column;
    gap: 1rem;
  }

  .search-bar {
    flex: 1 1 100%;
  }

  .filter-group {
    justify-content: center;
  }

  .card-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .pagination-controls {
    justify-content: center;
  }
}
</style>
