<template>
  <div class="comments-modal" :class="{ active: show }" @click="handleOverlayClick">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2><i class="fas fa-comments"></i> 评论详情</h2>
        <button class="close-btn" @click="$emit('close')">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <div class="modal-body">
        <div class="post-detail" v-if="post">
          <div class="post-header">
            <div class="user-info">
              <div class="user-avatar">
                <img v-if="post.user && post.user.avatar" :src="post.user.avatar" :alt="post.user.name" />
                <div v-else class="avatar-placeholder">
                  <i class="fas fa-user"></i>
                </div>
              </div>
              <div class="user-details">
                <h3>{{ post.user ? post.user.name : '匿名用户' }}</h3>
                <div class="post-time"><i class="far fa-clock"></i> {{ post.createdAt }}</div>
              </div>
            </div>
          </div>
          <div class="post-content">
            <h2>{{ post.title }}</h2>
            <p>{{ post.content }}</p>
            <div class="post-image" v-if="post.featuredImage">
              <img :src="post.featuredImage" :alt="post.title" />
            </div>
          </div>
        </div>

        <div class="comment-section">
          <h3 class="section-title">
            <i class="fas fa-comment"></i>
            全部评论 ({{ post && post.comments ? post.comments.length : 0 }})
          </h3>

          <div class="comment-list" v-if="post && post.comments && post.comments.length > 0">
            <div class="comment-card" v-for="comment in post.comments" :key="comment.commentId">
              <div class="comment-header">
                <div class="comment-avatar">
                  <img v-if="comment.user && comment.user.avatar" :src="comment.user.avatar" :alt="comment.user.name" />
                  <div v-else class="avatar-placeholder">
                    <i class="fas fa-user"></i>
                  </div>
                </div>
                <div class="comment-info">
                  <h4>{{ comment.user ? comment.user.name : '匿名用户' }}</h4>
                  <div class="comment-time"><i class="far fa-clock"></i> {{ comment.createdAt }}</div>
                </div>
              </div>
              <div class="comment-content">
                <p>{{ comment.content }}</p>
              </div>
            </div>
          </div>
          <div v-else-if="post" class="no-comments">
            <i class="fas fa-comment-slash"></i>
            <p>暂无评论，快来抢沙发吧！</p>
          </div>
        </div>

        <div class="comment-form">
          <h3 class="section-title"><i class="fas fa-pen"></i> 发表评论</h3>
          <div class="form-group">
            <textarea
                id="comment"
                class="form-control"
                placeholder="写下您的想法... (支持换行)"
                v-model="newCommentText"
            ></textarea>
          </div>
          <div class="form-actions">
            <button class="btn btn-secondary" @click="$emit('close')">
              <i class="fas fa-arrow-left"></i> 返回
            </button>
            <button class="btn btn-primary" @click="submitComment" :disabled="!newCommentText.trim()">
              <i class="fas fa-paper-plane"></i> 发表评论
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref, watch} from 'vue';

const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  post: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'add-comment']);
const newCommentText = ref('');

// 监听show prop，以便在弹窗打开时清除评论框内容
watch(() => props.show, (newValue) => {
  if (newValue) {
    newCommentText.value = '';
  }
});

const handleOverlayClick = (event) => {
  // 如果点击的是背景层而不是弹窗内容，则关闭弹窗
  if (event.target.classList.contains('comments-modal')) {
    emit('close');
  }
};

const submitComment = () => {
  if (newCommentText.value.trim() !== '') {
    emit('add-comment', newCommentText.value);
    // 提交后清空输入框
    newCommentText.value = '';
  }
};
</script>

<style scoped>
/* 弹窗背景 */
.comments-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.comments-modal.active {
  opacity: 1;
  visibility: visible;
}

/* 弹窗内容 */
.modal-content {
  background: linear-gradient(145deg, #ffffff 0%, #f8f9ff 100%);
  border-radius: 20px;
  width: 95%;
  max-width: 700px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25),
  0 0 0 1px rgba(255, 255, 255, 0.1);
  transform: scale(0.95) translateY(20px);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.comments-modal.active .modal-content {
  transform: scale(1) translateY(0);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 25px 30px;
  background: linear-gradient(135deg, #1e88e5 0%, #1565c0 100%);
  color: white;
  border-bottom: none;
}

.modal-header h2 {
  font-size: 1.6rem;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
}

.modal-header h2 i {
  font-size: 1.4rem;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  font-size: 1.2rem;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.modal-body {
  padding: 25px 30px;
  overflow-y: auto;
  flex-grow: 1;
  background: #f8fafc;
}

/* 帖子详情 */
.post-detail {
  background: white;
  border-radius: 16px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  border: 1px solid rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.post-detail:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);
}

.post-header {
  margin-bottom: 20px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.user-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid #e3f2fd;
  flex-shrink: 0;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #1e88e5 0%, #1565c0 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.user-details h3 {
  font-size: 1.2rem;
  color: #1976d2;
  margin: 0 0 5px 0;
  font-weight: 600;
}

.post-time {
  color: #64748b;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 5px;
}

.post-content h2 {
  font-size: 1.5rem;
  color: #0f172a;
  margin: 0 0 15px 0;
  font-weight: 700;
  line-height: 1.3;
}

.post-content p {
  color: #475569;
  line-height: 1.7;
  margin-bottom: 20px;
  font-size: 1.05rem;
}

/* 帖子图片 */
.post-image {
  margin: 20px 0;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.post-image img {
  width: 100%;
  height: auto;
  display: block;
  max-height: 300px;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.post-image img:hover {
  transform: scale(1.02);
}

/* 章节标题 */
.section-title {
  font-size: 1.3rem;
  color: #1976d2;
  margin: 0 0 20px 0;
  padding-bottom: 12px;
  border-bottom: 2px solid #e3f2fd;
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
}

/* 评论区域 */
.comment-section {
  margin-bottom: 30px;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.comment-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  animation: slideIn 0.4s ease-out;
}

.comment-card:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  transform: translateY(-3px);
}

.comment-header {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.comment-avatar {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #e3f2fd;
  flex-shrink: 0;
}

.comment-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comment-info {
  margin-left: 15px;
  flex: 1;
}

.comment-info h4 {
  font-size: 1.05rem;
  color: #1976d2;
  margin: 0 0 3px 0;
  font-weight: 600;
}

.comment-time {
  color: #64748b;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  gap: 5px;
}

.comment-content p {
  color: #334155;
  line-height: 1.6;
  margin: 0;
  font-size: 1rem;
  padding-left: 60px;
}

.no-comments {
  text-align: center;
  color: #64748b;
  padding: 40px 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.no-comments i {
  font-size: 2.5rem;
  color: #94a3b8;
  margin-bottom: 15px;
}

.no-comments p {
  font-size: 1.1rem;
  margin: 0;
  color: #64748b;
}

/* 评论表单 */
.comment-form {
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.comment-form .section-title {
  margin-top: 0;
}

.form-group {
  margin-bottom: 25px;
}

.form-control {
  width: 100%;
  padding: 16px 20px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: #f8fafc;
  font-size: 1rem;
  transition: all 0.3s ease;
  box-sizing: border-box;
  color: #1e293b;
  font-family: inherit;
  min-height: 120px;
  resize: vertical;
}

.form-control:focus {
  outline: none;
  border-color: #1e88e5;
  box-shadow: 0 0 0 4px rgba(30, 136, 229, 0.2);
  background: white;
}

.form-control::placeholder {
  color: #94a3b8;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
}

.btn {
  padding: 12px 25px;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-width: 120px;
}

.btn-primary {
  background: linear-gradient(135deg, #1e88e5 0%, #1565c0 100%);
  color: white;
  border: none;
  box-shadow: 0 4px 15px rgba(30, 136, 229, 0.3);
}

.btn-primary:hover:not(:disabled) {
  background: linear-gradient(135deg, #1976d2 0%, #0d47a1 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(30, 136, 229, 0.4);
}

.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
  opacity: 0.7;
}

.btn-secondary {
  background: #f1f5f9;
  color: #475569;
  border: 2px solid #e2e8f0;
}

.btn-secondary:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* 动画 */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 滚动条样式 */
.modal-body::-webkit-scrollbar {
  width: 8px;
}

.modal-body::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 4px;
}

.modal-body::-webkit-scrollbar-thumb {
  background: #c7d2fe;
  border-radius: 4px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: #a5b4fc;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .modal-content {
    width: 98%;
    max-width: none;
    margin: 10px;
    border-radius: 16px;
  }

  .modal-header {
    padding: 20px;
  }

  .modal-header h2 {
    font-size: 1.3rem;
  }

  .modal-body {
    padding: 20px;
  }

  .post-detail, .comment-form {
    padding: 20px;
  }

  .user-info {
    flex-direction: column;
    text-align: center;
    gap: 10px;
  }

  .comment-content p {
    padding-left: 0;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }

  .section-title {
    font-size: 1.2rem;
  }
}
</style>
