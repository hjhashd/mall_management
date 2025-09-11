<template>
  <div class="shop-page-container">
    <HomeNavbar />
    <!-- 店铺头部信息 -->
    <div class="shop-header">
      <div class="shop-banner">
        <img :src="shop.bannerUrl || 'https://picsum.photos/1200/300'" alt="店铺横幅" class="banner-img">
      </div>

      <div class="shop-info-header">
        <div class="shop-logo">
          <img :src="shop.logoUrl" alt="店铺Logo" class="logo-img">
        </div>

        <div class="shop-basic-info">
          <div class="shop-name-rating">
            <h1 class="shop-name">
              {{ shop.name }}
              <i v-if="shop.verified" class="fas fa-check-circle verified-badge" title="认证商家"></i>
            </h1>

            <div class="shop-rating">
              <div class="stars">
                <i v-for="n in Math.floor(shop.averageRating)" :key="'star-' + n" class="fas fa-star"></i>
                <i v-if="shop.averageRating % 1 !== 0" class="fas fa-star-half-alt"></i>
                <i v-for="n in (5 - Math.ceil(shop.averageRating))" :key="'empty-star-' + n" class="far fa-star"></i>
              </div>
              <span class="rating-value">{{ shop.averageRating.toFixed(1) }}</span>
              <span class="review-count">({{ shop.totalReviews }} 评价)</span>
            </div>
          </div>

          <div class="shop-meta-short">
            <div class="meta-item">
              <i class="fas fa-map-marker-alt"></i>
              <span>{{ shop.location }}</span>
            </div>
            <div class="meta-item">
              <i class="fas fa-calendar-alt"></i>
              <span>开店时间：{{ shop.openDate }}</span>
            </div>
            <div class="meta-item">
              <i class="fas fa-shopping-cart"></i>
              <span>总销量：{{ shop.totalSales }}</span>
            </div>
          </div>
        </div>

        <!-- [修改] 只有当访问的不是自己的店铺时，才显示关注和联系按钮 -->
        <div class="shop-actions" v-if="!isOwnShop">
          <button class="btn btn-outline" @click="handleContact" :disabled="loading.shopInfo">
            <i class="fas fa-comment-dots"></i> 联系商家
          </button>
          <button class="btn btn-primary" v-if="!isFollowing" @click="handleFollow" :disabled="followLoading || loading.shopInfo">
            <i :class="followLoading ? 'fas fa-spinner fa-spin' : 'fas fa-plus'"></i>
            {{ followLoading ? '处理中...' : '关注店铺' }}
          </button>
          <button class="btn btn-primary" v-else @click="handleUnfollow" :disabled="followLoading || loading.shopInfo">
            <i :class="followLoading ? 'fas fa-spinner fa-spin' : 'fas fa-check'"></i>
            {{ followLoading ? '处理中...' : '已关注' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 店铺统计数据 -->
    <div class="shop-stats">
      <div class="stat-card" v-for="(stat, index) in shopStats" :key="index">
        <div class="stat-icon"><i :class="stat.icon"></i></div>
        <div class="stat-content">
          <div class="stat-value">
            <span>{{ stat.value }}</span>
          </div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
      </div>
      <div v-if="loading.stats" v-for="i in 4" :key="'loader-' + i" class="stat-card">
        <div class="stat-icon"><i class="fas fa-spinner fa-spin"></i></div>
        <div class="stat-content">
          <div class="stat-value">
            <span class="loading-text">加载中...</span>
          </div>
          <div class="stat-label">正在加载</div>
        </div>
      </div>
    </div>

    <!-- 店铺详情内容 -->
    <div class="shop-content">
      <div class="shop-main-content">
        <!-- 商品列表 -->
        <div class="shop-section products-section">
          <div class="section-header">
            <h2 class="section-title">
              <i class="fas fa-shopping-bag"></i> 店铺商品
            </h2>
          </div>
          <div v-if="loading.products" class="loading-placeholder">正在加载商品...</div>
          <div v-else-if="products.length === 0" class="empty-state">该店铺暂未上架商品</div>
          <div v-else class="products-grid">
            <SellerProductCard
                v-for="product in products"
                :key="product.id"
                :product="product"
            />
          </div>

          <!-- 分页 -->
          <div class="pagination" v-if="pagination.total > pagination.size">
            <button class="page-btn" @click="changePage(pagination.page - 1)" :disabled="pagination.page <= 1">
              <i class="fas fa-chevron-left"></i>
            </button>
            <span>第 {{ pagination.page }} / {{ totalPages }} 页</span>
            <button class="page-btn" @click="changePage(pagination.page + 1)" :disabled="pagination.page >= totalPages">
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
        </div>

        <!-- 顾客评价 -->
        <div class="shop-section reviews-section">
          <h2 class="section-title">
            <i class="fas fa-comments"></i> 顾客评价
          </h2>
          <div v-if="loading.reviews" class="loading-placeholder">正在加载评价...</div>
          <div v-else-if="reviews.length === 0" class="empty-state">暂无评价</div>
          <div v-else class="reviews-list">
            <SellerReviewItem
                v-for="review in reviews"
                :key="review.reviewId"
                :review="review"
            />
          </div>
        </div>
      </div>

      <div class="shop-sidebar">
        <div class="sidebar-section announcements">
          <h3 class="sidebar-title">
            <i class="fas fa-bullhorn"></i> 店铺公告
          </h3>
          <div v-if="loading.shopInfo" class="loading-placeholder">...</div>
          <div v-else class="announcement-content">
            <p>{{ shop.announcement || '店主很懒，还没有留下任何公告。' }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 通知消息 -->
    <div class="notification" :class="[notification.type, { show: notification.show }]">
      {{ notification.message }}
    </div>
  </div>
</template>

<script setup>
import { reactive, computed, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useUserStore } from '@/stores/userStore'; // [新增] 引入 Pinia store
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import SellerProductCard from "./ProductCard.vue";
import SellerReviewItem from "./ReviewItem.vue";
import { getShopSettings, getShopStats, getSellerProducts } from '@/api/shop.js';
import { getSellerReviews } from "@/api/review.js";
// [新增] 假设你有一个专门管理关注API的文件
import { followUser, unfollowUser, checkFollowStatus } from "@/api/user.js";

const router = useRouter();
const userStore = useUserStore(); // [新增] 使用 user store

const props = defineProps({
  sellerId: {
    type: String,
    required: false,
    default: null
  }
});

const loading = reactive({
  shopInfo: true,
  stats: true,
  products: true,
  reviews: true,
});

const shop = reactive({
  userId: null,
  name: '加载中...',
  logoUrl: 'https://picsum.photos/100/100',
  bannerUrl: 'https://picsum.photos/1200/300',
  averageRating: 0.0,
  totalReviews: 0,
  totalSales: 0,
  location: '未知',
  openDate: '未知',
  verified: false,
  announcement: '加载中...'
});

const shopStats = ref([]);
const products = ref([]);
const reviews = ref([]);
const isFollowing = ref(false);
const followLoading = ref(false); // [新增] 用于防止重复点击

// [新增] 判断当前查看的是否为自己的店铺
const isOwnShop = computed(() => {
  return userStore.userInfo && shop.userId && userStore.userInfo.userId === shop.userId;
});

const pagination = reactive({
  page: 1,
  size: 8,
  total: 0
});

const totalPages = computed(() => Math.ceil(pagination.total / pagination.size));

const notification = reactive({ show: false, message: '', type: '' });

const showNotification = (message, type = 'info') => {
  notification.message = message;
  notification.type = type;
  notification.show = true;
  setTimeout(() => { notification.show = false; }, 3000);
};

// [新增] 检查关注状态
const updateFollowStatus = async (sellerUserId) => {
  // 如果是自己的店铺，或未登录，则不执行检查
  if (!userStore.isLoggedIn || !sellerUserId || userStore.userInfo.userId === sellerUserId) {
    isFollowing.value = false;
    return;
  }
  try {
    const response = await checkFollowStatus(userStore.userInfo.userId, sellerUserId);
    if (response.data.success) {
      isFollowing.value = response.data.data.isFollowing;
    }
  } catch (error) {
    console.error("检查关注状态失败:", error);
  }
};


const fetchShopData = async (targetSellerId) => {
  loading.shopInfo = true;
  try {
    const params = targetSellerId ? { sellerId: targetSellerId } : undefined;
    const response = await getShopSettings(params);
    if (response.data.success) {
      const backendData = response.data.data;
      // [修复] 将 backendData.userId 修改为 backendData.sellerId
      shop.userId = backendData.sellerId;
      shop.name = backendData.shopName || '未知店铺';
      shop.logoUrl = backendData.logoUrl || 'https://picsum.photos/100/100';
      shop.bannerUrl = backendData.bannerUrl || 'https://picsum.photos/1200/300';
      shop.location = backendData.location || '未知';
      shop.verified = backendData.isVerified || false;
      shop.announcement = backendData.announcement || '店主很懒，还没有留下任何公告。';
      shop.openDate = backendData.openDate ? new Date(backendData.openDate).toLocaleDateString() : '未知';

      // [修改] 获取到店铺userId后，立即检查关注状态
      await updateFollowStatus(shop.userId);

    } else {
      showNotification(response.data.message || '获取店铺数据失败', 'error');
    }
  } catch (error) {
    console.error("获取店铺数据时出错:", error);
    showNotification('网络错误，无法加载店铺数据', 'error');
  } finally {
    loading.shopInfo = false;
  }
};

const fetchShopStats = async (targetSellerId) => {
  loading.stats = true;
  try {
    const params = targetSellerId ? {sellerId: targetSellerId} : undefined;
    const response = await getShopStats(params);
    if (response.data.success) {
      const data = response.data.data;
      shopStats.value = [
        {icon: 'fas fa-box-open', value: data.onSaleCount || 0, label: '在售商品'},
        {icon: 'fas fa-shopping-bag', value: data.monthlyOrders || 0, label: '本月销量'},
        {icon: 'fas fa-star', value: data.rating ? data.rating.toFixed(1) : '暂无', label: '店铺评分'},
        {icon: 'fas fa-file-invoice', value: data.pendingOrders || 0, label: '待处理订单'}
      ];
      shop.averageRating = data.rating || 0;
      shop.totalReviews = data.totalReviews || 0;
      shop.totalSales = data.monthlyOrders || 0;
    } else {
      showNotification(response.data.message || '获取店铺统计数据失败', 'error');
    }
  } catch (error) {
    console.error("获取店铺统计数据时出错:", error);
    showNotification('获取店铺统计数据失败', 'error');
  } finally {
    loading.stats = false;
  }
};

const fetchSellerProducts = async (targetSellerId) => {
  loading.products = true;
  try {
    const params = {
      page: pagination.page,
      size: pagination.size,
    };
    if (targetSellerId) {
      params.sellerId = targetSellerId;
    }
    const response = await getSellerProducts(params);
    if (response.data.success) {
      products.value = response.data.data.items;
      pagination.total = response.data.data.total;
    } else {
      showNotification(response.data.message || '获取商品列表失败', 'error');
    }
  } catch (error) {
    console.error("获取商品列表时出错:", error);
    showNotification('网络错误，无法加载商品列表', 'error');
  } finally {
    loading.products = false;
  }
};

const fetchSellerReviews = async (targetSellerId) => {
  loading.reviews = true;
  try {
    const params = targetSellerId ? {sellerId: targetSellerId} : undefined;
    const response = await getSellerReviews(params);
    if (response.data.success) {
      reviews.value = response.data.data;
    } else {
      showNotification(response.data.message || '获取评价列表失败', 'error');
    }
  } catch (error) {
    console.error("获取评价列表时出错:", error);
    showNotification('网络错误，无法加载评价列表', 'error');
  } finally {
    loading.reviews = false;
  }
};

const fetchAllShopData = (id) => {
  fetchShopData(id);
  fetchShopStats(id);
  fetchSellerProducts(id);
  fetchSellerReviews(id);
}

const changePage = (newPage) => {
  if (newPage < 1 || newPage > totalPages.value) return;
  pagination.page = newPage;
  fetchSellerProducts(props.sellerId);
};

const handleContact = () => {
  // [修复] 增加对shop.userId的判断
  if (shop.userId) {
    router.push({
      name: 'Chat',
      query: {peerId: shop.userId}
    });
  } else {
    showNotification('无法获取商家信息，请稍后再试', 'error');
  }
};


// [修改] 实现真实的关注逻辑
const handleFollow = async () => {
  if (!userStore.isLoggedIn) {
    showNotification('请先登录再关注店铺', 'error');
    router.push('/login');
    return;
  }
  if (isOwnShop.value) {
    showNotification('不能关注自己的店铺', 'error');
    return;
  }
  // [修复] 增加对shop.userId的判断
  if (!shop.userId) {
    showNotification('无法获取店铺信息，请稍后再试', 'error');
    return;
  }

  followLoading.value = true;
  try {
    const followerId = userStore.userInfo.userId;
    const followedId = shop.userId;
    const response = await followUser(followerId, followedId);
    if (response.data.success) {
      isFollowing.value = true;
      showNotification('已成功关注店铺', 'success');
    } else {
      showNotification(response.data.message || '关注失败', 'error');
    }
  } catch (error) {
    showNotification('网络错误，关注失败', 'error');
  } finally {
    followLoading.value = false;
  }
};

// [修改] 实现真实的取关逻辑
const handleUnfollow = async () => {
  if (!userStore.isLoggedIn) return;

  // [修复] 增加对shop.userId的判断
  if (!shop.userId) {
    showNotification('无法获取店铺信息，请稍后再试', 'error');
    return;
  }

  followLoading.value = true;
  try {
    const followerId = userStore.userInfo.userId;
    const followedId = shop.userId;
    const response = await unfollowUser(followerId, followedId);
    if (response.data.success) {
      isFollowing.value = false;
      showNotification('已取消关注店铺', 'success');
    } else {
      showNotification(response.data.message || '取消关注失败', 'error');
    }
  } catch (error) {
    showNotification('网络错误，取消关注失败', 'error');
  } finally {
    followLoading.value = false;
  }
};

onMounted(() => {
  fetchAllShopData(props.sellerId);
});

watch(() => props.sellerId, (newId, oldId) => {
  if (newId !== oldId) {
    pagination.page = 1;
    pagination.total = 0;
    fetchAllShopData(newId);
  }
}, {immediate: false});
</script>

<style scoped>
/* 样式与之前版本基本一致，此处省略，只添加新样式 */
.loading-placeholder, .empty-state {
  text-align: center;
  color: #999;
  padding: 40px;
  background-color: #f8f9fa;
  border-radius: 12px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 15px;
  margin-top: 20px;
  color: #555;
}

.page-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 1px solid #ddd;
  background-color: white;
  cursor: pointer;
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  background-color: #f0f0f0;
  border-color: #bbb;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.shop-page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 80px 20px 50px;
  background-color: #fff;
}

/* 店铺头部样式 */
.shop-header {
  margin-bottom: 30px;
}

.shop-banner {
  width: 100%;
  height: 300px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 20px;
  background-color: #f0f2f5; /* 添加背景色以防图片加载失败 */
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.shop-banner:hover .banner-img {
  transform: scale(1.02);
}

.shop-info-header {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.shop-logo {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  border: 4px solid white;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  flex-shrink: 0;
  background-color: #f0f2f5; /* 添加背景色以防图片加载失败 */
}

.logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.shop-basic-info {
  flex-grow: 1;
  min-width: 300px;
}

.shop-name-rating {
  margin-bottom: 10px;
}

.shop-name {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin-bottom: 8px;
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.verified-badge {
  color: #4ECDC4;
  font-size: 22px;
}

.shop-rating {
  display: flex;
  align-items: center;
  gap: 10px;
}

.stars {
  color: #FFD166;
  font-size: 18px;
}

.rating-value {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.review-count {
  color: #888;
}

.shop-meta-short {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  color: #888;
  font-size: 14px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.meta-item i {
  color: #4ECDC4;
}

.shop-actions {
  display: flex;
  gap: 15px;
  flex-shrink: 0;
}

.btn {
  padding: 10px 20px;
  border-radius: 30px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s ease;
  border: none;
  font-size: 14px;
}

.btn:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

.btn-primary {
  background-color: #FF6B6B;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #ff8a8a;
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
}

.btn-outline {
  background-color: transparent;
  border: 1px solid #FF6B6B;
  color: #FF6B6B;
}

.btn-outline:hover:not(:disabled) {
  background-color: #FFF5E4;
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(255, 107, 107, 0.1);
}

.shop-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
  padding: 20px;
  background-color: #F5F5F5;
  border-radius: 12px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 25px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background-color: #FFF5E4;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #FF6B6B;
  font-size: 24px;
}

.stat-content {
  flex-grow: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin-bottom: 5px;
}

.stat-label {
  color: #888;
  font-size: 14px;
}

.shop-content {
  display: flex;
  gap: 30px;
}

.shop-main-content {
  flex: 3;
}

.shop-sidebar {
  flex: 1;
  min-width: 250px;
}

.shop-section {
  background-color: white;
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding-bottom: 10px;
  border-bottom: 2px solid #F5F5F5;
}

.section-title i {
  color: #FF6B6B;
}

.sidebar-section {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
}

.sidebar-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 10px;
  border-bottom: 1px solid #F5F5F5;
}

.sidebar-title i {
  color: #FF6B6B;
}

.announcement-content {
  padding: 10px;
  background-color: #FFF5E4;
  border-radius: 8px;
  color: #666;
  font-size: 14px;
  line-height: 1.6;
}

.notification {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 15px 25px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  z-index: 1100;
  opacity: 0;
  transform: translateY(-20px);
  transition: all 0.3s ease;
}

.notification.show {
  opacity: 1;
  transform: translateY(0);
}

.notification.success {
  background-color: #4CAF50;
}

.notification.error {
  background-color: #f44336;
}

.loading-text {
  color: #999;
  font-style: italic;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.6;
  }
  50% {
    opacity: 1;
  }
}
</style>

