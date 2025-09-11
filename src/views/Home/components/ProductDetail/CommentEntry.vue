<template>
  <section class="comment-entry-section">
    <h2 class="section-title">用户评价</h2>
    <div class="comment-entry-card">
      <div class="rating-summary">
        <span class="average-score">{{ commentData.averageRating.toFixed(1) }}</span>
        <div class="rating-details">
          <div class="stars big">
            <i v-for="n in Math.floor(commentData.averageRating)" :key="'full-star-' + n" class="fas fa-star"></i>
            <i v-if="commentData.averageRating % 1 !== 0" class="fas fa-star-half-alt"></i>
            <i v-for="n in (5 - Math.ceil(commentData.averageRating))" :key="'empty-star-' + n" class="far fa-star"></i>
          </div>
          <span class="review-count-text">{{ commentData.totalComments }} 条评论</span>
        </div>
      </div>

      <div class="action-area">
        <!-- 点击时跳转到评论页面 -->
        <router-link :to="`/product/${productId}/reviews`" class="btn btn-outline">
          <i class="fas fa-comments"></i> 查看全部评论 ({{ commentData.totalComments }})
        </router-link>
      </div>
    </div>
  </section>
</template>

<script setup>
import { reactive, onMounted } from 'vue';
// 1. 导入获取评分统计的API函数
//    请确保路径 '@api/review' 与您的项目结构相匹配
import { getProductRatingSummary } from '@/api/review';

// 定义props接收productId
const props = defineProps({
  productId: {
    type: [Number, String], // 路由参数可能是字符串，最好同时接受两种类型
    required: true
  }
});

// 2. 初始化响应式数据，避免在加载时显示假数据
const commentData = reactive({
  averageRating: 0.0,
  totalComments: 0,
});

// 3. 在组件挂载后，异步获取真实数据
onMounted(async () => {
  console.log(`Fetching comment summary data for product ID: ${props.productId}...`);
  try {
    // 调用API函数，并传入productId
    const response = await getProductRatingSummary(props.productId);

    // 假设API成功返回的数据结构是 { success: true, message: "...", data: { total: 588, average: 4.7, ... } }
    if (response && response.data.data) {
      // 4. 将获取到的真实数据更新到响应式对象中
      commentData.averageRating = response.data.data.average || 0;
      commentData.totalComments = response.data.data.total || 0;
    } else {
      console.warn('Failed to get comment summary or response data is empty.');
    }
  } catch (error) {
    // 5. 捕获并处理API请求中可能发生的错误
    console.error('Error fetching comment summary:', error);
    // 在这里可以设置一些错误状态的提示
  }
});
</script>

<style scoped>
/* 样式部分无需修改，保持原样即可 */
:root {
  --primary: #FF6B6B;
  --secondary: #4ECDC4;
  --accent: #FFD166;
  --dark: #333333;
  --gray: #888888;
  --light-gray: #F5F5F5;
  --border-radius: 12px;
  --box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
}

.comment-entry-section {
  margin-top: 60px; /* 与其他section保持一致的顶部外边距 */
  margin-bottom: 50px;
}

.section-title {
  font-family: 'Playfair Display', serif;
  font-size: 28px;
  margin-bottom: 30px;
  position: relative;
  padding-bottom: 15px;
  color: var(--dark);
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 3px;
  background: var(--primary);
  border-radius: 3px;
}

.comment-entry-card {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  padding: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap; /* 确保在小屏幕上换行 */
  gap: 20px; /* 元素之间的间距 */
}

.rating-summary {
  display: flex;
  align-items: center;
  gap: 15px;
}

.average-score {
  font-family: 'Playfair Display', serif;
  font-size: 48px; /* 大号评分数字 */
  font-weight: 700;
  color: var(--primary);
  line-height: 1; /* 确保垂直居中 */
}

.rating-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.stars.big {
  font-size: 24px; /* 大号星星 */
  color: var(--accent);
}

.review-count-text {
  font-size: 16px;
  color: var(--gray);
}

.action-area {
  /* 确保按钮不会被压缩 */
  flex-shrink: 0;
}

.btn {
  padding: 12px 25px; /* 按钮大小适中 */
  border-radius: 30px;
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  border: none;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--primary);
  color: var(--primary);
}

.btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .comment-entry-card {
    flex-direction: column;
    align-items: flex-start; /* 左对齐 */
  }
}

@media (max-width: 480px) {
  .average-score {
    font-size: 40px;
  }
  .stars.big {
    font-size: 20px;
  }
  .btn {
    width: 100%; /* 小屏幕下按钮宽度适应 */
    justify-content: center;
  }
}
</style>
