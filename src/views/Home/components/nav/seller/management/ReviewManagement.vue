<template>
  <div class="review-management-container">
    <a-card :bordered="false" class="header-card">
      <div class="header-content">
        <h1 class="page-title">评价管理</h1>
        <p class="page-description">在这里查看并回复所有商品的顾客评价。</p>
      </div>
    </a-card>

    <a-card :bordered="false" class="table-card">
      <!-- 筛选区域 -->
      <div class="filter-bar">
        <a-form layout="inline" :model="filters">
          <a-form-item label="评分">
            <a-select v-model:value="filters.rating" placeholder="所有评分" style="width: 120px" allow-clear @change="handleFilterChange">
              <a-select-option :value="5">⭐⭐⭐⭐⭐</a-select-option>
              <a-select-option :value="4">⭐⭐⭐⭐</a-select-option>
              <a-select-option :value="3">⭐⭐⭐</a-select-option>
              <a-select-option :value="2">⭐⭐</a-select-option>
              <a-select-option :value="1">⭐</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="回复状态">
            <a-select v-model:value="filters.hasSellerReply" placeholder="全部" style="width: 120px" allow-clear @change="handleFilterChange">
              <a-select-option :value="true">已回复</a-select-option>
              <a-select-option :value="false">未回复</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="内容">
            <a-select v-model:value="filters.hasImage" placeholder="全部" style="width: 120px" allow-clear @change="handleFilterChange">
              <a-select-option :value="true">有图</a-select-option>
              <a-select-option :value="false">无图</a-select-option>
            </a-select>
          </a-form-item>
        </a-form>
      </div>

      <!-- 评价表格 -->
      <a-table
          :columns="columns"
          :data-source="reviews"
          :loading="loading"
          :pagination="pagination"
          row-key="reviewId"
          @change="handleTableChange"
          class="review-table"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'product'">
            <div class="product-cell">
              <a-image :width="60" :src="record.productImage || 'https://placehold.co/100x100/E2E8F0/475569?text=No+Image'" class="product-image"/>
              <span class="product-name">{{ record.productName }}</span>
            </div>
          </template>

          <template v-if="column.key === 'user'">
            <div class="user-cell">
              <a-avatar :src="record.userAvatar">{{ record.username.charAt(0) }}</a-avatar>
              <span>{{ record.username }}</span>
            </div>
          </template>

          <template v-if="column.key === 'content'">
            <div class="content-cell">
              <a-rate :value="record.rating" disabled />
              <p class="review-text">{{ record.content }}</p>
              <div v-if="record.imageUrls && record.imageUrls.length > 0" class="image-gallery">
                <a-image-preview-group>
                  <a-image v-for="(url, index) in record.imageUrls" :key="index" :width="50" :src="url" />
                </a-image-preview-group>
              </div>
            </div>
          </template>

          <template v-if="column.key === 'sellerReply'">
            <div v-if="record.sellerReply" class="seller-reply-display">
              <span class="reply-tag">已回复:</span>
              <p>{{ record.sellerReply }}</p>
            </div>
            <div v-else>
              <a-tag color="orange">待回复</a-tag>
            </div>
          </template>

          <template v-if="column.key === 'action'">
            <a-button type="primary" size="small" @click="openReplyModal(record)">
              {{ record.sellerReply ? '修改回复' : '回复' }}
            </a-button>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 回复弹窗 -->
    <a-modal
        v-model:open="replyModalVisible"
        :title="`回复 ${currentReview?.username} 的评价`"
        @ok="submitReply"
        :confirm-loading="replyModalLoading"
    >
      <a-textarea
          v-model:value="sellerReplyText"
          placeholder="请输入您的回复..."
          :rows="4"
          show-count
          :maxlength="200"
      />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import { getAllReviews, addSellerReply } from '@/api/review';
import { message } from 'ant-design-vue';
// 1. 导入 userStore
import { useUserStore } from '@/stores/userStore';

// --- 表格列定义 ---
const columns = [
  { title: '商品信息', key: 'product', width: '25%' },
  { title: '评价用户', key: 'user', width: '15%' },
  { title: '评价内容', key: 'content', width: '30%' },
  { title: '商家回复', key: 'sellerReply', width: '15%' },
  { title: '操作', key: 'action', width: '10%', align: 'center' },
];

// --- 响应式状态 ---
const reviews = ref([]);
const loading = ref(false);
const filters = reactive({
  rating: null,
  hasSellerReply: null,
  hasImage: null,
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50'],
});

// --- 回复弹窗状态 ---
const replyModalVisible = ref(false);
const replyModalLoading = ref(false);
const currentReview = ref(null);
const sellerReplyText = ref('');

// 2. 初始化 userStore
const userStore = useUserStore();

// --- API 调用 ---
const fetchReviews = async () => {
  // 确保在发起请求前，用户信息已加载
  if (!userStore.userInfo?.userId) {
    message.error('无法获取卖家信息，请重新登录后再试');
    loading.value = false; // 停止加载状态
    return;
  }

  loading.value = true;
  try {
    const params = {
      page: pagination.current,
      size: pagination.pageSize,
      // 3. 将 sellerId 添加到请求参数中
      sellerId: userStore.userInfo.userId,
      ...filters,
    };
    const response = await getAllReviews(params);
    if (response.data.success) {
      reviews.value = response.data.data.list;
      pagination.total = response.data.data.total;
    } else {
      message.error(response.data.message || '获取评价列表失败');
    }
  } catch (error) {
    message.error('网络错误，请稍后再试');
    console.error("Failed to fetch reviews:", error);
  } finally {
    loading.value = false;
  }
};

// --- 事件处理 ---
onMounted(fetchReviews);

const handleTableChange = (pager) => {
  pagination.current = pager.current;
  pagination.pageSize = pager.pageSize;
  fetchReviews();
};

const handleFilterChange = () => {
  pagination.current = 1; // 筛选条件改变时，回到第一页
  fetchReviews();
};

const openReplyModal = (review) => {
  currentReview.value = review;
  sellerReplyText.value = review.sellerReply || '';
  replyModalVisible.value = true;
};

const submitReply = async () => {
  if (!sellerReplyText.value.trim()) {
    message.warning('回复内容不能为空');
    return;
  }

  replyModalLoading.value = true;
  try {
    const response = await addSellerReply(currentReview.value.reviewId, sellerReplyText.value);
    if (response.data.success) {
      message.success('回复成功');
      replyModalVisible.value = false;
      await fetchReviews(); // 刷新列表
    } else {
      message.error(response.data.message || '回复失败');
    }
  } catch (error) {
    message.error('网络错误，回复失败');
    console.error("Failed to submit reply:", error);
  } finally {
    replyModalLoading.value = false;
  }
};
</script>

<style scoped>
.review-management-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.header-card {
  border-radius: 8px;
}

.header-content {
  padding: 8px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.page-description {
  font-size: 14px;
  color: #6b7280;
}

.table-card {
  border-radius: 8px;
}

.filter-bar {
  margin-bottom: 24px;
}

.product-cell {
  display: flex;
  align-items: center;
}

.product-image {
  border-radius: 4px;
  margin-right: 12px;
  object-fit: cover;
}

.product-name {
  font-weight: 500;
  color: #333;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.content-cell .review-text {
  margin: 8px 0;
  color: #333;
  -webkit-line-clamp: 2;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.image-gallery .ant-image {
  margin-right: 8px;
  border-radius: 4px;
  cursor: pointer;
}

.seller-reply-display {
  font-size: 13px;
  background-color: #f7f7f7;
  padding: 8px;
  border-radius: 4px;
}

.seller-reply-display .reply-tag {
  font-weight: bold;
  color: #1890ff;
  margin-right: 4px;
}

.review-table .ant-table-cell {
  vertical-align: top;
}
</style>
