<template>
  <div class="modal-overlay" @click="handleClose">
    <div class="modal-content" @click.stop>
      <!-- 模态框头部 -->
      <div class="modal-header">
        <h3 class="modal-title">写评价</h3>
        <button @click="handleClose" class="close-btn">
          <i class="fas fa-times"></i>
        </button>
      </div>

      <!-- 模态框主体 -->
      <div class="modal-body">
        <form @submit.prevent="handleSubmit" class="review-form">
          <!-- 评分 -->
          <div class="form-group">
            <label class="form-label">评分</label>
            <div class="rating-input">
              <div class="stars">
                <i v-for="star in 5"
   :key="'star-' + star"
   @click="setRating(star)"
   @mouseenter="hoverRating = star"
   @mouseleave="hoverRating = 0"
   class="star"
   :class="{
     'fas fa-star': star <= (hoverRating || newReview.rating),
     'far fa-star': star > (hoverRating || newReview.rating)
   }"></i>
              </div>
              <span class="rating-text">{{ newReview.rating }}分</span>
            </div>
          </div>

          <!-- 评价内容 -->
          <div class="form-group">
            <label class="form-label">评价内容</label>
            <textarea
                v-model="newReview.content"
                class="form-textarea"
                rows="4"
                placeholder="请分享您的使用体验..."
                maxlength="500"
                required></textarea>
            <div class="char-count">
              {{ newReview.content.length }}/500
            </div>
          </div>

          <!-- 图片上传 -->
          <div class="form-group">
            <label class="form-label">上传图片</label>
            <div class="image-upload">
              <div class="upload-area" @click="triggerFileInput">
                <i class="fas fa-camera"></i>
                <span>点击上传图片</span>
                <span class="upload-hint">最多5张，每张不超过5MB</span>
              </div>
              <input
                  ref="fileInput"
                  type="file"
                  multiple
                  accept="image/*"
                  @change="handleFileChange"
                  style="display: none">
            </div>

            <!-- 图片预览 -->
            <div v-if="newReview.images.length > 0" class="image-preview">
              <div v-for="(image, index) in newReview.images"
                   :key="'preview-' + index"
                   class="preview-item">
                <img :src="image.preview" :alt="'Preview ' + (index + 1)">
                <button @click="removeImage(index)" class="remove-btn">
                  <i class="fas fa-times"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- 匿名评价 -->
          <div class="form-group">
            <label class="checkbox-label">
              <input
                  type="checkbox"
                  v-model="newReview.isAnonymous"
                  class="checkbox-input">
              <span class="checkmark"></span>
              匿名评价
            </label>
          </div>

          <!-- 表单操作 -->
          <div class="form-actions">
            <button type="button" @click="handleClose" class="btn btn-secondary">
              取消
            </button>
            <button type="submit" class="btn btn-primary" :disabled="!isFormValid || submitting">
              {{ submitting ? '提交中...' : '提交评价' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { submitReview } from '@/api/review'

const props = defineProps({
  productId: {
    type: Number,
    required: true
  },
  orderItemId: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close', 'submit'])

// 响应式数据
const newReview = ref({
  rating: 0,
  content: '',
  images: [], // 注意：这里存储的是 {file, preview} 对象
  isAnonymous: false
})

const fileInput = ref(null)
const submitting = ref(false)
const hoverRating = ref(0) // 添加这行：鼠标悬停评分

// 计算属性
const isFormValid = computed(() => {
  return newReview.value.rating > 0 &&
      newReview.value.content.trim().length > 0
})

// 方法定义
const setRating = (rating) => {
  newReview.value.rating = rating
  hoverRating.value = 0 // 这里保持 .value，因为这是在脚本中
}

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileChange = (event) => {
  const files = Array.from(event.target.files)

  files.forEach(file => {
    if (newReview.value.images.length >= 5) {
      alert('最多只能上传5张图片')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      alert('图片大小不能超过5MB')
      return
    }

    if (!file.type.startsWith('image/')) {
      alert('请选择图片文件')
      return
    }

    // 创建预览URL
    const reader = new FileReader()
    reader.onload = (e) => {
      newReview.value.images.push({
        file: file,
        preview: e.target.result
      })
    }
    reader.readAsDataURL(file)
  })

  event.target.value = ''
}

const removeImage = (index) => {
  const removedImage = newReview.value.images.splice(index, 1)[0]
  // 释放预览URL内存
  if (removedImage.preview) {
    URL.revokeObjectURL(removedImage.preview)
  }
}

const handleClose = () => {
  // 清理预览URL
  newReview.value.images.forEach(img => {
    if (img.preview) {
      URL.revokeObjectURL(img.preview)
    }
  })
  emit('close')
}

const handleSubmit = async () => {
  if (!isFormValid.value) return

  submitting.value = true

  try {
    const formData = new FormData()
    formData.append('orderItemId', props.orderItemId)
    formData.append('productId', props.productId)
    formData.append('rating', newReview.value.rating)
    formData.append('content', newReview.value.content)
    formData.append('isAnonymous', newReview.value.isAnonymous)

    // 注意：这里只添加 file 对象，不添加 preview
    newReview.value.images.forEach(imageObj => {
      formData.append('images', imageObj.file)
    })

    const response = await submitReview(formData)

    if (response.data.success) {
      // 清理预览URL
      newReview.value.images.forEach(img => {
        if (img.preview) {
          URL.revokeObjectURL(img.preview)
        }
      })

      // 重置表单
      newReview.value = {
        rating: 0,
        content: '',
        images: [],
        isAnonymous: false
      }
      emit('submit')
    } else {
      alert(response.data.message || '评价提交失败')
    }
  } catch (error) {
    console.error('提交评价失败:', error)
    alert('评价提交失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
/* 你的样式保持不变 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.modal-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #999;
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
}

.rating-input {
  display: flex;
  align-items: center;
  gap: 10px;
}

.stars {
  display: flex;
  gap: 5px;
}

.star {
  font-size: 24px;
  cursor: pointer;
  color: #ddd;
  transition: color 0.2s;
}

.star.fas.fa-star {
  color: #ffd700;
}

.rating-text {
  font-size: 16px;
  color: #666;
}

.form-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: vertical;
  font-family: inherit;
}

.char-count {
  text-align: right;
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}

.upload-area {
  border: 2px dashed #ddd;
  border-radius: 4px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  transition: border-color 0.2s;
}

.upload-area:hover {
  border-color: #007bff;
}

.upload-area i {
  font-size: 24px;
  color: #999;
  margin-bottom: 10px;
}

.upload-hint {
  display: block;
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}

.image-preview {
  display: flex;
  gap: 10px;
  margin-top: 15px;
  flex-wrap: wrap;
}

.preview-item {
  position: relative;
  width: 80px;
  height: 80px;
}

.preview-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.remove-btn {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #ff4444;
  color: white;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 12px;
  cursor: pointer;
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.checkbox-input {
  margin-right: 8px;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
