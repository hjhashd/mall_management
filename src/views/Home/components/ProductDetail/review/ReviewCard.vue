<template>
  <div class="review-card">
    <!-- 评价头部 -->
    <div class="review-header">
      <div class="reviewer-info">
        <div class="avatar">
          <img v-if="review.userAvatar" :src="review.userAvatar" :alt="review.username">
          <i v-else class="fas fa-user"></i>
        </div>
        <div class="user-details">
          <div class="username">
            {{ review.isAnonymous ? '匿名用户' : review.username }}
            <span v-if="review.isAnonymous" class="anonymous-badge">匿名</span>
          </div>
          <div class="review-meta">
            <div class="rating">
              <i v-for="star in 5" :key="'star-' + star"
                 class="fas"
                 :class="star <= review.rating ? 'fa-star' : 'far fa-star'"></i>
              <span class="rating-text">{{ review.rating }}分</span>
            </div>
            <span class="review-date">{{ formatDate(review.createdAt) }}</span>
          </div>
        </div>
      </div>

      <div class="review-actions">
        <button @click="$emit('like', review)" class="action-btn like-btn">
          <i class="fas fa-thumbs-up"></i>
          <span>有用 ({{ review.likes || 0 }})</span>
        </button>
        <button @click="$emit('reply', review)" class="action-btn reply-btn">
          <i class="fas fa-reply"></i>
          <span>回复</span>
        </button>
        <button
            v-if="canDeleteReview"
            @click.stop="$emit('delete-review', review)"
            class="action-btn delete-btn"
        >
          <i class="fas fa-trash"></i>
          <span>删除</span>
        </button>
      </div>
    </div>

    <!-- 评价内容 -->
    <div class="review-content">
      <p class="review-text">{{ review.content }}</p>
    </div>

    <!-- 评价图片 - 重构后的样式 -->
    <div v-if="review.imageUrls && review.imageUrls.length > 0" class="review-images-grid">
      <div
          v-for="(image, index) in displayedImages"
          :key="'img-' + index"
          class="image-grid-item"
          @click="previewImage(image, index)"
      >
        <img :src="image" :alt="'Review image ' + (index + 1)" class="grid-image">
        <div v-if="index === 4 && hasMoreImages" class="more-overlay">
          +{{ review.imageUrls.length - 5 }}
        </div>
      </div>
    </div>

    <!-- 卖家回复 -->
    <div v-if="review.sellerReply" class="seller-reply">
      <div class="reply-header">
        <div class="seller-avatar">
          <i class="fas fa-store"></i>
        </div>
        <div class="reply-info">
          <div class="seller-name">卖家回复</div>
          <div class="reply-date">{{ formatDate(review.sellerReplyTime) }}</div>
        </div>
      </div>
      <div class="reply-content">
        {{ review.sellerReply }}
      </div>
    </div>

    <!-- 回复列表 -->
    <div v-if="review.replies && review.replies.length > 0" class="replies-section">
      <!-- 展开/收起提示 -->
      <div class="replies-toggle" @click="toggleReplies">
    <span class="toggle-text">
      {{ isRepliesExpanded ? '收起回复' : '查看回复' }}
      <span class="reply-count">({{ review.replies.length }}条)</span>
    </span>
        <i :class="['toggle-icon', 'fas', isRepliesExpanded ? 'fa-chevron-up' : 'fa-chevron-down']"></i>
      </div>

      <!-- 回复列表 -->
      <div v-show="isRepliesExpanded" class="replies-list">
        <div v-for="reply in review.replies" :key="reply.replyId" class="reply-item">
          <div class="reply-avatar">
            <img v-if="reply.userAvatar" :src="reply.userAvatar" :alt="reply.username">
            <i v-else class="fas fa-user"></i>
          </div>
          <div class="reply-content">
            <div class="reply-header">
              <span class="reply-username">{{ reply.username }}</span>
              <span v-if="reply.isAppend" class="append-badge">追评</span>
              <span v-if="reply.repliedToUsername" class="reply-to">
            回复 @{{ reply.repliedToUsername }}
          </span>
            </div>
            <div class="reply-text">{{ reply.content }}</div>
            <div class="reply-meta">
              <span class="reply-date">{{ formatDate(reply.createTime) }}</span>
              <div class="reply-actions">
                <button @click="handleReplyToReply(reply)" class="reply-btn-small">
                  <i class="fas fa-reply"></i> 回复
                </button>
                <button
                    v-if="canDeleteReply(reply)"
                    @click.stop="handleDeleteReply(reply)"
                    class="delete-btn-small"
                >
                  <i class="fas fa-trash"></i> 删除
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 全新设计的图片预览模态框 -->
    <teleport to="body">
      <transition name="modal" appear>
        <div
            v-if="previewState.isVisible"
            class="image-preview-modal"
            @click="handleModalBackdropClick"
        >
          <div class="preview-container" @click.stop>
            <!-- 关闭按钮 -->
            <button class="preview-close" @click.stop="closePreview">
              <i class="fas fa-times"></i>
            </button>

            <!-- 上一张按钮 -->
            <button
                v-if="review.imageUrls && review.imageUrls.length > 1"
                class="nav-button prev-button"
                @click.stop="prevImage"
            >
              <i class="fas fa-chevron-left"></i>
            </button>

            <!-- 图片展示区域 -->
            <div class="image-wrapper">
              <img
                  :src="previewState.currentImage"
                  :alt="`Preview ${previewState.currentIndex + 1}`"
                  class="preview-image"
                  @load="onImageLoad"
              >
              <div class="loading-spinner" v-if="previewState.loading">
                <i class="fas fa-spinner fa-spin"></i>
              </div>
            </div>

            <!-- 下一张按钮 -->
            <button
                v-if="review.imageUrls && review.imageUrls.length > 1"
                class="nav-button next-button"
                @click.stop="nextImage"
            >
              <i class="fas fa-chevron-right"></i>
            </button>

            <!-- 图片信息 -->
            <div class="preview-info">
              <span class="image-counter">
                {{ (previewState.currentIndex + 1) }} / {{ review.imageUrls?.length || 0 }}
              </span>
              <span class="image-actions">
                <button class="action-icon" @click.stop="downloadImage">
                  <i class="fas fa-download"></i>
                </button>
              </span>
            </div>
          </div>
        </div>
      </transition>
    </teleport>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useUserStore } from '@/stores/userStore'

const props = defineProps({
  review: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['reply', 'like', 'delete-review', 'delete-reply'])

// 计算属性 - 是否可以删除评价（用户自己或管理员）
const canDeleteReview = computed(() => {
  const userStore = useUserStore()
  return (
      (userStore.isLoggedIn && userStore.userInfo?.userId === props.review.userId) ||
      userStore.isAdmin
  )
})

// 方法 - 是否可以删除回复（用户自己或管理员）
const canDeleteReply = (reply) => {
  const userStore = useUserStore()
  return (
      (userStore.isLoggedIn && userStore.userInfo?.user_id === reply.userId) ||
      userStore.isAdmin
  )
}

const handleReplyToReply = (reply) => {
  emit('reply', { ...props.review, replyTo: reply })
}

// 处理删除回复
const handleDeleteReply = (reply) => {
  emit('delete-reply', { review: props.review, reply })
}

const userStore = useUserStore()

// 图片预览状态管理
const previewState = reactive({
  isVisible: false,
  currentImage: '',
  currentIndex: 0,
  loading: false
})

// 计算属性 - 显示的图片（最多5张）
const displayedImages = computed(() => {
  if (!props.review.imageUrls) return []
  return props.review.imageUrls.slice(0, 5)
})

// 是否有更多图片
const hasMoreImages = computed(() => {
  return props.review.imageUrls && props.review.imageUrls.length > 5
})

// 计算属性 - 可删除权限
const canDelete = computed(() => {
  return userStore.isLoggedIn &&
      userStore.userInfo &&
      userStore.userInfo.user_id === props.review.userId
})

// 方法
const formatDate = (dateString) => {
  if (!dateString) return ''

  const date = new Date(dateString)
  const now = new Date()
  const diff = now - date

  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 2592000000) return `${Math.floor(diff / 86400000)}天前`

  return date.toLocaleDateString()
}

// 处理模态框背景点击
const handleModalBackdropClick = (event) => {
  // 只有点击背景区域才关闭（不是点击内容区域）
  if (event.target === event.currentTarget) {
    closePreview()
  }
}

// 图片预览方法
const previewImage = (imageUrl, index = 0) => {
  if (index >= 4 && hasMoreImages.value) {
    // 点击更多按钮时，显示第5张图片（实际是第6张）
    index = 5
  }

  previewState.currentImage = imageUrl
  previewState.currentIndex = index
  previewState.isVisible = true
  previewState.loading = true

  // 防止背景滚动
  document.body.style.overflow = 'hidden'
}

// 关闭预览
const closePreview = () => {
  previewState.isVisible = false
  // 恢复背景滚动
  document.body.style.overflow = ''
}

// 图片加载完成
const onImageLoad = () => {
  previewState.loading = false
}

// 获取图片数组（用于导航）
const getImageArray = () => {
  return props.review.imageUrls || []
}

// 上一张图片
const prevImage = () => {
  const images = getImageArray()
  if (images.length <= 1) return

  previewState.loading = true
  const newIndex = previewState.currentIndex > 0
      ? previewState.currentIndex - 1
      : images.length - 1
  previewState.currentIndex = newIndex
  previewState.currentImage = images[newIndex]
}

// 下一张图片
const nextImage = () => {
  const images = getImageArray()
  if (images.length <= 1) return

  previewState.loading = true
  const newIndex = previewState.currentIndex < images.length - 1
      ? previewState.currentIndex + 1
      : 0
  previewState.currentIndex = newIndex
  previewState.currentImage = images[newIndex]
}

// 下载图片
const downloadImage = () => {
  const link = document.createElement('a')
  link.href = previewState.currentImage
  link.download = `review-image-${previewState.currentIndex + 1}.jpg`
  link.click()
}
// 添加响应式变量来控制回复展开状态
const isRepliesExpanded = ref(false)

// 切换回复展开/收起
const toggleReplies = () => {
  isRepliesExpanded.value = !isRepliesExpanded.value
}
</script>

<style scoped>
.review-card {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 12px;
  padding: 24px;
  transition: all 0.3s ease;
  margin-bottom: 20px;
}

.review-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

/* 评价头部 */
.review-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.reviewer-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar i {
  font-size: 20px;
  color: #6c757d;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.username {
  font-weight: 600;
  color: #212529;
  display: flex;
  align-items: center;
  gap: 8px;
}

.anonymous-badge {
  background: #e9ecef;
  color: #6c757d;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
}

.review-meta {
  display: flex;
  align-items: center;
  gap: 16px;
}

.rating {
  display: flex;
  align-items: center;
  gap: 4px;
}

.rating i {
  color: #ffc107;
  font-size: 14px;
}

.rating-text {
  color: #495057;
  font-weight: 600;
  font-size: 14px;
}

.review-date {
  color: #6c757d;
  font-size: 14px;
}

.review-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  background: none;
  border: 1px solid #dee2e6;
  color: #6c757d;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
}

.action-btn:hover {
  border-color: #007bff;
  color: #007bff;
}

.like-btn:hover {
  border-color: #28a745;
  color: #28a745;
}

.reply-btn:hover {
  border-color: #007bff;
  color: #007bff;
}

.delete-btn:hover {
  border-color: #dc3545;
  color: #dc3545;
}

/* 评价内容 */
.review-content {
  margin-bottom: 20px;
}

.review-text {
  color: #212529;
  line-height: 1.6;
  margin: 0;
  font-size: 16px;
}

/* 重构后的图片网格布局 */
.review-images-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  grid-gap: 8px;
  margin-bottom: 20px;
  max-width: 500px;
}

.image-grid-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #f8f9fa;
}

.image-grid-item:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1;
}

.grid-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.more-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
}

/* 全新设计的图片预览模态框 */
.image-preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  backdrop-filter: blur(10px);
}

.preview-container {
  position: relative;
  width: 90vw;
  height: 90vh;
  max-width: 1200px;
  max-height: 800px;
  display: flex;
  flex-direction: column;
}

/* 关闭按钮 */
.preview-close {
  position: absolute;
  top: -50px;
  right: 0;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 20px;
  transition: all 0.3s ease;
  z-index: 10;
}

.preview-close:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

/* 图片展示区域 */
.image-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.05);
}

.preview-image {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
}

/* 加载动画 */
.loading-spinner {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 32px;
  color: white;
}

/* 导航按钮 */
.nav-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 20px;
  transition: all 0.3s ease;
  z-index: 10;
}

.nav-button:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-50%) scale(1.1);
}

.prev-button {
  left: 20px;
}

.next-button {
  right: 20px;
}

/* 图片信息栏 */
.preview-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
}

.image-counter {
  font-weight: 500;
}

.action-icon {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-icon:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

/* 模态框动画 */
.modal-enter-active,
.modal-leave-active {
  transition: all 0.3s ease;
}

.modal-enter-from {
  opacity: 0;
  transform: scale(0.9);
}

.modal-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

/* 卖家回复 */
.seller-reply {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 20px;
  border-left: 4px solid #007bff;
}

.reply-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.seller-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #007bff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 14px;
}

.reply-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.seller-name {
  font-weight: 600;
  color: #007bff;
  font-size: 14px;
}

.reply-date {
  color: #6c757d;
  font-size: 12px;
}

.reply-content {
  color: #495057;
  line-height: 1.5;
  font-size: 14px;
}

/* 回复列表 */
.replies-section {
  border-top: 1px solid #e9ecef;
  padding-top: 20px;
}

.replies-header h4 {
  margin: 0 0 16px 0;
  color: #495057;
  font-size: 16px;
}

.replies-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.reply-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.reply-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  flex-shrink: 0;
}

.reply-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.reply-avatar i {
  font-size: 14px;
  color: #6c757d;
}

.reply-content {
  flex: 1;
}

.reply-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.reply-username {
  font-weight: 600;
  color: #212529;
  font-size: 14px;
}

.append-badge {
  background: #28a745;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
}

.reply-to {
  color: #007bff;
  font-size: 12px;
}

.reply-text {
  color: #495057;
  line-height: 1.5;
  margin-bottom: 8px;
  font-size: 14px;
}

.reply-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.reply-date {
  color: #6c757d;
  font-size: 12px;
}

.reply-btn-small {
  background: none;
  border: none;
  color: #007bff;
  cursor: pointer;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

.reply-btn-small:hover {
  background: #e3f2fd;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .review-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .review-actions {
    width: 100%;
    justify-content: space-between;
  }

  .action-btn {
    flex: 1;
    justify-content: center;
    padding: 8px 6px;
    font-size: 12px;
  }

  .action-btn span {
    display: none;
  }

  .review-images-grid {
    grid-template-columns: repeat(4, 1fr);
    max-width: 100%;
  }

  .image-grid-item {
    aspect-ratio: 1;
  }

  .preview-container {
    width: 100vw;
    height: 100vh;
    max-width: none;
    max-height: none;
    border-radius: 0;
  }

  .preview-close {
    top: 15px;
    right: 15px;
  }

  .nav-button {
    width: 40px;
    height: 40px;
    font-size: 16px;
  }

  .prev-button {
    left: 10px;
  }

  .next-button {
    right: 10px;
  }

  .preview-info {
    padding: 12px;
    font-size: 12px;
  }

  .reply-item {
    flex-direction: column;
    gap: 8px;
    padding: 12px;
  }

  .reply-avatar {
    align-self: flex-start;
  }
}

/* 添加回复删除按钮样式 */
.delete-btn-small {
  background: none;
  border: none;
  color: #dc3545;
  cursor: pointer;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

.delete-btn-small:hover {
  background: #f8d7da;
}

@media (max-width: 480px) {
  .review-card {
    padding: 16px;
    margin-bottom: 12px;
  }

  .review-images-grid {
    grid-template-columns: repeat(3, 1fr);
    grid-gap: 6px;
  }

  .review-actions {
    gap: 4px;
  }

  .action-btn {
    padding: 6px 4px;
    font-size: 11px;
  }
}
/* 回复展开/收起提示 */
.replies-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  cursor: pointer;
  color: #666;
  border-bottom: 1px solid #eee;
  margin-bottom: 15px;
}

.replies-toggle:hover {
  color: #333;
}

.toggle-text {
  font-size: 14px;
  font-weight: 500;
}

.reply-count {
  color: #999;
  margin-left: 5px;
}

.toggle-icon {
  font-size: 12px;
  transition: transform 0.2s ease;
}

.replies-toggle:hover .toggle-icon {
  color: #007bff;
}

/* 回复列表样式优化 */
.replies-list {
  margin-top: 10px;
}

.reply-item {
  display: flex;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.reply-item:last-child {
  border-bottom: none;
}

.reply-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 12px;
  flex-shrink: 0;
}

.reply-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.reply-avatar i {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f0f0f0;
  color: #999;
  font-size: 14px;
}

.reply-content {
  flex: 1;
  min-width: 0;
}

.reply-header {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
  flex-wrap: wrap;
  gap: 8px;
}

.reply-username {
  font-weight: 500;
  font-size: 14px;
  color: #333;
}

.append-badge {
  background-color: #ff6b35;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 10px;
}

.reply-to {
  color: #666;
  font-size: 13px;
}

.reply-text {
  font-size: 14px;
  line-height: 1.5;
  color: #333;
  margin-bottom: 8px;
  word-wrap: break-word;
}

.reply-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 10px;
}

.reply-date {
  font-size: 12px;
  color: #999;
}

/* 优化按钮排列 */
.reply-actions {
  display: flex;
  gap: 8px;
}

.reply-btn-small,
.delete-btn-small {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  font-size: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.reply-btn-small {
  color: #007bff;
  border-color: #007bff;
}

.reply-btn-small:hover {
  background-color: #007bff;
  color: white;
}

.delete-btn-small {
  color: #dc3545;
  border-color: #dc3545;
}

.delete-btn-small:hover {
  background-color: #dc3545;
  color: white;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .reply-item {
    padding: 12px 0;
  }

  .reply-header {
    gap: 6px;
  }

  .reply-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .reply-actions {
    align-self: flex-end;
  }
}

</style>
