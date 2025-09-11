<template>
  <div class="modal-overlay" @click="handleClose">
    <div class="modal-content" @click.stop>
      <!-- 模态框头部 -->
      <div class="modal-header">
        <h3 class="modal-title">{{ replyTargetTitle }}</h3>
        <button @click="handleClose" class="close-btn">
          <i class="fas fa-times"></i>
        </button>
      </div>

      <!-- 模态框主体 -->
      <div class="modal-body">
        <!-- 要回复的评价信息 -->
        <div class="review-info">
          <div class="reviewer-info">
            <div class="avatar">
              <img v-if="replyTarget.userAvatar" :src="replyTarget.userAvatar" :alt="replyTarget.username">
              <i v-else class="fas fa-user"></i>
            </div>
            <div class="user-details">
              <div class="username">
                {{ replyTarget.isAnonymous ? '匿名用户' : replyTarget.username }}
                <span v-if="replyTarget.isAnonymous" class="anonymous-badge">匿名</span>
              </div>
              <div v-if="!review.replyTo" class="review-rating">
                <i v-for="star in 5" :key="'star-' + star"
                   class="fas"
                   :class="star <= replyTarget.rating ? 'fa-star' : 'far fa-star'"></i>
                <span class="rating-text">{{ replyTarget.rating }}分</span>
              </div>
            </div>
          </div>
          <div class="review-content">
            <p>{{ replyTarget.content }}</p>
          </div>
        </div>

        <!-- 回复表单 -->
        <form @submit.prevent="handleSubmit" class="reply-form">
          <!-- 回复内容 -->
          <div class="form-group">
            <label class="form-label">回复内容</label>
            <textarea
              v-model="replyContent"
              class="form-textarea"
              rows="4"
              placeholder="写下您的回复..."
              maxlength="300"
              required></textarea>
            <div class="char-count">
              {{ replyContent.length }}/300
            </div>
          </div>

          <!-- 是否为追评 -->
          <div v-if="!review.replyTo" class="form-group">
            <label class="checkbox-label">
              <input
                type="checkbox"
                v-model="isAppend"
                class="checkbox-input">
              <span class="checkmark"></span>
              这是追评
            </label>
          </div>

          <!-- 表单操作 -->
          <div class="form-actions">
            <button type="button" @click="handleClose" class="btn btn-secondary">
              取消
            </button>
            <button type="submit" class="btn btn-primary" :disabled="!isFormValid">
              发送回复
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { submitReply } from '@/api/review'

const props = defineProps({
  review: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close', 'submit'])

// 响应式数据
const replyContent = ref('')
const isAppend = ref(false)
const submitting = ref(false)

// 计算属性
const isFormValid = computed(() => {
  return replyContent.value.trim().length > 0
})

// 新增计算属性，用于确定回复目标的标题
const replyTargetTitle = computed(() => {
  return props.review.replyTo ? '回复评论' : '回复评价'
})

// 新增计算属性，用于确定回复的目标对象
const replyTarget = computed(() => {
  return props.review.replyTo || props.review
})

// 方法
const handleClose = () => {
  emit('close')
}

const handleSubmit = async () => {
  if (!isFormValid.value) return

  // 验证reviewId是否存在
  if (!props.review.reviewId) {
    alert('评价ID不能为空')
    return
  }

  submitting.value = true

  try {
    const replyData = {
      reviewId: props.review.reviewId,
      content: replyContent.value,
      repliedToUserId: props.review.userId ? props.review.userId : null,
      repliedToUsername: props.review.username ? props.review.username : null,
      isAppend: isAppend.value
    }

    const response = await submitReply(replyData)

    if (response.data.success) {
      // 重置表单
      replyContent.value = ''
      isAppend.value = false

      emit('submit')
    } else {
      alert(response.data.message || '回复提交失败')
    }
  } catch (error) {
    console.error('提交回复失败:', error)
    alert('回复提交失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 24px 0 24px;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 20px;
}

.modal-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #212529;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  color: #6c757d;
  cursor: pointer;
  padding: 8px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: #f8f9fa;
  color: #495057;
}

.modal-body {
  padding: 24px;
  max-height: calc(90vh - 100px);
  overflow-y: auto;
}

/* 评价信息 */
.review-info {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 24px;
  border-left: 4px solid #007bff;
}

.reviewer-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #e9ecef;
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
  font-size: 18px;
  color: #6c757d;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.username {
  font-weight: 600;
  color: #212529;
  font-size: 14px;
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

.review-rating {
  display: flex;
  align-items: center;
  gap: 4px;
}

.review-rating i {
  color: #ffc107;
  font-size: 12px;
}

.rating-text {
  color: #495057;
  font-weight: 600;
  font-size: 12px;
}

.review-content {
  color: #495057;
  line-height: 1.5;
  font-size: 14px;
}

.review-content p {
  margin: 0;
}

/* 回复表单 */
.reply-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 600;
  color: #495057;
  font-size: 14px;
}

.form-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.5;
  resize: vertical;
  transition: border-color 0.3s ease;
}

.form-textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.char-count {
  text-align: right;
  font-size: 12px;
  color: #6c757d;
}

/* 复选框 */
.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  font-size: 14px;
  color: #495057;
}

.checkbox-input {
  display: none;
}

.checkmark {
  width: 20px;
  height: 20px;
  border: 2px solid #dee2e6;
  border-radius: 4px;
  position: relative;
  transition: all 0.3s ease;
}

.checkbox-input:checked + .checkmark {
  background: #007bff;
  border-color: #007bff;
}

.checkbox-input:checked + .checkmark::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

/* 表单操作 */
.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding-top: 20px;
  border-top: 1px solid #e9ecef;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 100px;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0056b3;
  transform: translateY(-2px);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover {
  background: #545b62;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .modal-content {
    max-width: 100%;
    margin: 20px;
  }

  .modal-header {
    padding: 20px 20px 0 20px;
  }

  .modal-body {
    padding: 20px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .modal-overlay {
    padding: 10px;
  }

  .modal-content {
    margin: 10px;
  }

  .avatar {
    width: 32px;
    height: 32px;
  }

  .avatar i {
    font-size: 14px;
  }

  .username {
    font-size: 13px;
  }

  .review-rating i {
    font-size: 10px;
  }

  .rating-text {
    font-size: 11px;
  }
}
</style>
