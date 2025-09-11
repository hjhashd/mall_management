<template>
  <div class="review-item">
    <div class="review-header">
      <div class="user-info">
        <img :src="review.userAvatar || 'https://picsum.photos/50/50'" :alt="review.userName" class="user-avatar">
        <span class="user-name">{{ review.userName }}</span>
      </div>
      <div class="review-meta">
        <div class="rating">
          <i v-for="n in review.rating" :key="'star-' + n" class="fas fa-star"></i>
        </div>
        <span class="review-date">{{ formattedDate }}</span>
      </div>
    </div>

    <div class="review-content">
      {{ review.content }}
    </div>

    <div class="review-images" v-if="review.imageUrls && review.imageUrls.length">
      <img
          v-for="(img, index) in review.imageUrls"
          :key="index"
          :src="img"
          alt="评价图片"
          class="review-img"
      >
    </div>

    <div class="review-product">
      <i class="fas fa-box-open"></i>
      <span>评价商品: {{ review.productName }}</span>
    </div>

    <div class="seller-reply-section" v-if="review.sellerReply">
      <div class="seller-reply-display">
        <strong>商家回复:</strong> {{ review.sellerReply }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, computed } from 'vue';

const props = defineProps({
  review: {
    type: Object,
    required: true,
    default: () => ({
      reviewId: 0,
      userName: '',
      userAvatar: '',
      rating: 5,
      createdAt: new Date().toISOString(),
      content: '',
      productName: '',
      imageUrls: [],
      sellerReply: null
    })
  }
});

// 格式化日期
const formattedDate = computed(() => {
  if (!props.review.createdAt) return '';
  return new Date(props.review.createdAt).toLocaleDateString();
});
</script>

<style scoped>
.review-item {
  padding: 20px;
  border: 1px solid #f0f0f0;
  border-radius: 12px;
  background-color: #fff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.review-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-weight: 600;
  color: #333;
}

.review-meta {
  display: flex;
  align-items: center;
  gap: 15px;
}

.rating {
  color: #FFD166;
}

.review-date {
  font-size: 13px;
  color: #999;
}

.review-content {
  color: #444;
  line-height: 1.7;
  margin-bottom: 15px;
  font-size: 14px;
}

.review-images {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.review-img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  border: 1px solid #eee;
  transition: transform 0.3s ease;
}

.review-img:hover {
  transform: scale(1.05);
}

.review-product {
  font-size: 13px;
  color: #555;
  margin-bottom: 15px;
  padding: 8px 12px;
  background-color: #f8f9fa;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.seller-reply-section {
  margin-top: 15px;
}

.seller-reply-display {
  background-color: #FFF5E4;
  padding: 10px 15px;
  border-radius: 8px;
  font-size: 14px;
  color: #555;
  border-left: 3px solid #FFD166;
}

/* [REMOVED] 移除了 .seller-reply-action, .reply-input, .reply-btn 的样式 */
</style>
