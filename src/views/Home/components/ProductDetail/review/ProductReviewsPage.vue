<template>
  <HomeNavbar />
  <div class="reviews-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <div class="header-content">
          <div class="product-info">
            <img :src="productInfo.image" :alt="productInfo.name" class="product-image">
            <div class="product-details">
              <h1 class="product-name">{{ productInfo.name }}</h1>
              <div class="product-rating">
                <div class="stars">
                  <i v-for="star in 5" :key="'star-' + star"
                     class="fas"
                     :class="star <= Math.floor(productInfo.averageRating) ? 'fa-star' :
                             star <= productInfo.averageRating + 0.5 ? 'fa-star-half-alt' : 'far fa-star'"></i>
                </div>
                <span class="rating-score">{{ productInfo.averageRating.toFixed(1) }}</span>
                <span class="rating-count">({{ productInfo.totalReviews }} 条评价)</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 筛选和排序 -->
    <div class="filter-section">
      <div class="container">
        <div class="filter-content">
          <div class="filter-group">
            <label class="filter-label">评分筛选:</label>
            <div class="filter-options">
              <button
                  v-for="rating in [5, 4, 3, 2, 1]"
                  :key="'rating-' + rating"
                  @click="filterByRating(rating)"
                  :class="['filter-btn', { active: selectedRating === rating }]">
                {{ rating }}星
              </button>
              <button
                  @click="clearRatingFilter"
                  :class="['filter-btn', { active: selectedRating === null }]">
                全部
              </button>
            </div>
          </div>

          <div class="filter-group">
            <label class="filter-label">排序方式:</label>
            <div class="filter-options">
              <button
                  v-for="sort in sortOptions"
                  :key="'sort-' + sort.value"
                  @click="changeSort(sort.value)"
                  :class="['filter-btn', { active: currentSort === sort.value }]">
                {{ sort.label }}
              </button>
            </div>
          </div>

          <div class="filter-group">
            <label class="filter-label">内容筛选:</label>
            <div class="filter-options">
              <button
                  @click="toggleImageFilter"
                  :class="['filter-btn', { active: hasImageFilter }]">
                有图片
              </button>
              <button
                  @click="toggleReplyFilter"
                  :class="['filter-btn', { active: hasReplyFilter }]">
                有回复
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 评价列表 -->
    <div class="reviews-section">
      <div class="container">
        <div class="reviews-header">
          <h2 class="section-title">用户评价</h2>
          <button v-if="canReview" @click="handleWriteReview" class="btn-write-review">
            <i class="fas fa-edit"></i> 写评价
          </button>
        </div>

        <div class="reviews-content">
          <div v-if="loading" class="loading-state">
            <div class="loading-spinner"></div>
            <p>正在加载评价...</p>
          </div>

          <div v-else-if="reviews.length === 0" class="empty-state">
            <i class="fas fa-comments"></i>
            <h3>还没有评价</h3>
            <p>快来抢沙发吧~</p>
          </div>

          <div v-else class="reviews-list">
            <ReviewCard
                v-for="review in reviews"
                :key="review.reviewId"
                :review="review"
                @reply="handleReply"
                @like="handleLike"
                @delete-review="handleDeleteReview"
                @delete-reply="handleDeleteReply"
            />
          </div>

          <!-- 分页 -->
          <div v-if="totalPages > 1" class="pagination-wrapper">
            <Pagination
                :current-page="currentPage"
                :total-pages="totalPages"
                @page-change="handlePageChange" />
          </div>
        </div>
      </div>
    </div>

    <!-- 评价表单模态框 -->
    <ReviewFormModal
        v-if="showReviewForm"
        :product-id="productId"
        :order-item-id="reviewableOrderItem?.orderItemId || null"
        @close="showReviewForm = false"
        @submit="handleReviewSubmit" />

    <!-- 回复表单模态框 -->
    <ReplyFormModal
        v-if="showReplyForm"
        :review="selectedReview"
        @close="showReplyForm = false"
        @submit="handleReplySubmit" />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'
import ReviewCard from './ReviewCard.vue'
import ReviewFormModal from './ReviewFormModal.vue'
import ReplyFormModal from './ReplyFormModal.vue'
import Pagination from './Pagination.vue'
import { getProductReviews, getProductRatingSummary,getPendingReviews,deleteReview, deleteReply  } from '@/api/review'
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import { getProductDetail } from '@/api/product'

// 定义 props
const props = defineProps({
  productId: {
    type: [String, Number],
    required: true
  }
})

// 添加响应式变量
const reviewableOrderItem = ref(null)
const showReviewForm = ref(false)

// 处理删除评价
const handleDeleteReview = async (review) => {
  if (!confirm('确定要删除这条评价吗？')) return

  try {
    await deleteReview(review.reviewId)
    // 删除成功后刷新列表
    await fetchReviews()
    await fetchRatingSummary()
    await fetchProductInfo()
    alert('评价删除成功')
  } catch (error) {
    console.error('删除评价失败:', error)
    alert('删除失败: ' + (error.response?.data?.message || '请稍后重试'))
  }
}

// 处理删除回复
const handleDeleteReply = async ({ review, reply }) => {
  if (!confirm('确定要删除这条回复吗？')) return;

  try {
    console.log('准备删除 replyId:', reply.replyId);
    await deleteReply(reply.replyId); // 等删除完成
    await fetchReviews(); // 再刷新列表
    alert('回复删除成功');
  } catch (error) {
    console.error('删除回复失败:', error);
    alert('删除失败: ' + (error.response?.data?.message || '请稍后重试'));
  }
};

// 修改写评价处理逻辑
const handleWriteReview = async () => {
  try {
    // 调用时传入商品ID
    const response = await getPendingReviews({ productId: productId.value })

    // 检查响应结构
    if (response.data && response.data.data.length > 0) {
      // 直接使用第一个匹配项
      reviewableOrderItem.value = response.data.data[0];
      showReviewForm.value = true
    } else {
      alert('您没有可评价该商品的订单项')
    }
  } catch (error) {
    console.error('获取可评价订单项失败:', error)
    alert('无法获取可评价订单项，请重试')
  }
}

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 响应式数据
const productId = computed(() => parseInt(props.productId))
const loading = ref(false)
const reviews = ref([])
const currentPage = ref(1)
const totalPages = ref(1)
const showReplyForm = ref(false)
const selectedReview = ref(null)

// 筛选和排序
const selectedRating = ref(null)
const currentSort = ref('created_at')
const hasImageFilter = ref(false)
const hasReplyFilter = ref(false)
const globalAverageRating = ref(0)

// 排序选项
const sortOptions = [
  { label: '最新', value: 'created_at' },
  { label: '评分最高', value: 'rating' },
  { label: '最有用', value: 'helpful' }
]

// 商品信息
const productInfo = reactive({
  name: '',
  image: '',
  averageRating: 0,
  totalReviews: 0
})

// 评分统计
const ratingSummary = reactive({
  total: 0,
  average: 0,
  distribution: []
})

// 计算属性
const canReview = computed(() => {
  return userStore.isLoggedIn && userStore.userInfo
})

//获取商品详情
const fetchProductInfo = async () => {
  try {
    const response = await getProductDetail(productId.value)
    const data = response.data.data || response.data

    // 更新商品信息
    productInfo.name = data.title || '未知商品'

    // 查找 main 为 true 的图片
    const mainImage = data.images?.find(img => img.main === true)
    productInfo.image = mainImage?.imageUrl || 'http://localhost:8080/uploads/problems/404.png'  // 使用可选链操作符避免报错

    productInfo.averageRating = globalAverageRating.value || 0
    productInfo.totalReviews = ratingSummary.total || 0
  } catch (error) {
    console.error('获取商品信息失败:', error)
    productInfo.name = '商品信息加载失败'
    productInfo.image = 'http://localhost:8080/uploads/products/example.png'
    productInfo.averageRating = 0
    productInfo.totalReviews = 0
  }
}

// 方法
const fetchReviews = async () => {
  loading.value = true
  try {
    const response = await getProductReviews(productId.value, {
      page: currentPage.value,
      size: 10,
      rating: selectedRating.value,
      sort: currentSort.value,
      order: 'desc',
      hasImage: hasImageFilter.value,
      hasSellerReply: hasReplyFilter.value
    })

    // 根据PageInfo结构获取数据
    reviews.value = response.data.data.list || [];
    totalPages.value = response.data.data.total || 1

  } catch (error) {
    console.error('获取评价失败:', error)
    // 可以添加用户友好的错误提示
  } finally {
    loading.value = false
  }
}

const fetchRatingSummary = async () => {
  try {
    const response = await getProductRatingSummary(productId.value)
    Object.assign(ratingSummary, response.data.data)
    productInfo.totalReviews = response.data.data.total
    globalAverageRating.value = response.data.data.average
  } catch (error) {
    console.error('获取评分统计失败:', error)
  }
}

const filterByRating = (rating) => {
  selectedRating.value = selectedRating.value === rating ? null : rating
  currentPage.value = 1
  fetchReviews()
}

const clearRatingFilter = () => {
  selectedRating.value = null
  currentPage.value = 1
  fetchReviews()
}

const changeSort = (sort) => {
  currentSort.value = sort
  currentPage.value = 1
  fetchReviews()
}

const toggleImageFilter = () => {
  hasImageFilter.value = !hasImageFilter.value
  currentPage.value = 1
  fetchReviews()
}

const toggleReplyFilter = () => {
  hasReplyFilter.value = !hasReplyFilter.value
  currentPage.value = 1
  fetchReviews()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchReviews()
}

const handleReply = (review) => {
  selectedReview.value = review
  showReplyForm.value = true
}

const handleLike = (review) => {
  // 处理点赞逻辑
  console.log('点赞评价:', review.reviewId)
}

const handleReviewSubmit = async () => {
  showReviewForm.value = false
  await fetchReviews()
  await fetchRatingSummary()
  await fetchProductInfo() // 添加这行 - 刷新商品信息
}

const handleReplySubmit = () => {
  showReplyForm.value = false
  fetchReviews()
}

// 监听筛选条件变化
watch([selectedRating, currentSort, hasImageFilter, hasReplyFilter], () => {
  currentPage.value = 1
})

// 生命周期
onMounted(async () => {
  await fetchRatingSummary()  // 先获取评分统计
  await fetchProductInfo()    // 再获取商品信息
  await fetchReviews()        // 最后获取评价
})
</script>

<style scoped>
.reviews-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 80px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* 页面头部 */
.page-header {
  background: white;
  border-bottom: 1px solid #e9ecef;
  padding: 20px 0;
}

.header-content {
  display: flex;
  align-items: center;
}

.product-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.product-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
}

.product-name {
  font-size: 24px;
  font-weight: 700;
  color: #212529;
  margin: 0 0 10px 0;
}

.product-rating {
  display: flex;
  align-items: center;
  gap: 10px;
}

.stars {
  color: #ffc107;
  font-size: 16px;
}

.rating-score {
  font-size: 18px;
  font-weight: 600;
  color: #212529;
}

.rating-count {
  color: #6c757d;
  font-size: 14px;
}

/* 评分概览 */
.rating-overview {
  background: white;
  padding: 30px 0;
  margin-bottom: 20px;
}

.overview-content {
  display: flex;
  align-items: center;
  gap: 60px;
}

.overall-rating {
  text-align: center;
  min-width: 120px;
}

.rating-score {
  font-size: 48px;
  font-weight: 700;
  color: #212529;
  line-height: 1;
}

.rating-stars {
  color: #ffc107;
  font-size: 20px;
  margin: 5px 0;
}

.rating-count {
  color: #6c757d;
  font-size: 14px;
}

.rating-distribution {
  flex: 1;
}

.rating-bar {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.bar-label {
  width: 60px;
  font-size: 14px;
  color: #6c757d;
}

.bar-container {
  flex: 1;
  height: 8px;
  background: #e9ecef;
  border-radius: 4px;
  overflow: hidden;
  margin: 0 15px;
}

.bar-fill {
  height: 100%;
  background: #ffc107;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.bar-percent {
  width: 40px;
  text-align: right;
  font-size: 14px;
  color: #6c757d;
}

/* 筛选区域 */
.filter-section {
  background: white;
  padding: 20px 0;
  margin-bottom: 20px;
  border-bottom: 1px solid #e9ecef;
}

.filter-content {
  display: flex;
  align-items: center;
  gap: 40px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 15px;
}

.filter-label {
  font-weight: 600;
  color: #495057;
  white-space: nowrap;
}

.filter-options {
  display: flex;
  gap: 8px;
}

.filter-btn {
  padding: 6px 12px;
  border: 1px solid #dee2e6;
  background: white;
  color: #6c757d;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
}

.filter-btn:hover {
  border-color: #007bff;
  color: #007bff;
}

.filter-btn.active {
  background: #007bff;
  border-color: #007bff;
  color: white;
}

/* 评价区域 */
.reviews-section {
  background: white;
  border-radius: 12px;
  margin-bottom: 30px;
  overflow: hidden;
}

.reviews-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30px;
  border-bottom: 1px solid #e9ecef;
}

.section-title {
  font-size: 24px;
  font-weight: 700;
  color: #212529;
  margin: 0;
}

.btn-write-review {
  background: #007bff;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-write-review:hover {
  background: #0056b3;
  transform: translateY(-2px);
}

.reviews-content {
  padding: 30px;
}

.loading-state {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #495057;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.pagination-wrapper {
  margin-top: 40px;
  display: flex;
  justify-content: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .overview-content {
    flex-direction: column;
    gap: 30px;
  }

  .filter-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }

  .filter-group {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .reviews-header {
    flex-direction: column;
    gap: 20px;
    align-items: flex-start;
  }

  .btn-write-review {
    width: 100%;
    justify-content: center;
  }
}
</style>
