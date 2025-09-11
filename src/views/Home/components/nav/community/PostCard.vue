<!-- PostCard.vue -->
<template>
  <div class="post-card">
    <div class="post-header">
      <div class="user-info">
        <!-- 使用 router-link 的条件判断 -->
        <router-link
            v-if="post.user && post.user.userId && currentUser && post.user.userId !== currentUser.userId"
            :to="{ name: 'Chat', query: { peerId: post.user.userId } }"
            @click.stop
            class="user-avatar-link"
            title="和TA沟通"
        >
          <div class="user-avatar">
            <img v-if="post.user.avatar" :src="post.user.avatar" :alt="post.user.name"/>
            <div v-else class="avatar-placeholder">{{ post.user.name ? post.user.name.charAt(0) : '?' }}</div>
          </div>
        </router-link>

        <!-- 不满足条件时，只显示头像，不带链接 -->
        <div v-else class="user-avatar">
          <img v-if="post.user && post.user.avatar" :src="post.user.avatar" :alt="post.user.name" />
          <div v-else class="avatar-placeholder">{{ post.user ? post.user.name.charAt(0) : '?' }}</div>
        </div>

        <div class="user-details">
          <h3 class="user-name">{{ post.user ? post.user.name : '匿名用户' }}</h3>
          <p class="post-time">{{ post.createdAt }}</p>
        </div>
      </div>
      <div class="post-category">
        {{ post.category }}
      </div>
    </div>

    <div class="post-body" @click="$emit('open-comments', post.postId)">
      <h2 class="post-title">{{ post.title }}</h2>
      <p class="post-content">{{ post.content }}</p>
    </div>

    <div class="post-image-wrapper" v-if="post.featuredImage" @click="$emit('open-comments', post.postId)">
      <img :src="post.featuredImage" :alt="post.title" class="post-image" />
    </div>

    <div class="post-footer">
      <div class="stat-item like-btn">
        <i class="far fa-heart"></i>
        <span>{{ post.likeCount }}</span>
      </div>
      <div class="stat-item comment-btn" @click.stop="$emit('open-comments', post.postId)">
        <i class="far fa-comment"></i>
        <span>{{ post.commentCount }}</span>
      </div>
      <div class="stat-item view-btn">
        <i class="far fa-eye"></i>
        <span>{{ post.viewCount }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  post: { type: Object, required: true },
  currentUser: { type: Object, required: true }
});
defineEmits(['open-comments']);
</script>

<style scoped>
.post-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-large);
  box-shadow: var(--shadow-md);
  padding: var(--spacing-base);
  display: flex;
  flex-direction: column;
  gap: 20px;
  transition: transform var(--transition-medium), box-shadow var(--transition-medium), border-color var(--transition-medium);
  cursor: pointer;
}

.post-card:hover {
  transform: translateY(-6px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary);
}

/* --- Header --- */
.post-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}
.user-avatar, .user-avatar-link {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid var(--color-border);
  flex-shrink: 0;
  transition: var(--transition-fast);
}
.post-card:hover .user-avatar, .post-card:hover .user-avatar-link {
  border-color: var(--color-primary);
  transform: scale(1.1);
}
.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: var(--color-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
  font-weight: 600;
}
.user-details .user-name {
  font-size: 1rem;
  color: var(--color-text-primary);
  margin: 0;
  font-weight: 600;
}
.user-details .post-time {
  color: var(--color-text-secondary);
  font-size: 0.85rem;
  margin: 2px 0 0 0;
}
.post-category {
  background: var(--color-primary-light);
  color: var(--color-primary);
  padding: 6px 14px;
  border-radius: var(--radius-full);
  font-size: 0.8rem;
  font-weight: 600;
  flex-shrink: 0;
}

/* --- Body --- */
.post-body {
  text-decoration: none;
  color: inherit;
}
.post-title {
  color: var(--color-text-primary);
  margin: 0 0 10px 0;
  font-size: 1.3rem;
  font-weight: 700;
  line-height: 1.4;
  transition: color var(--transition-fast);
}
.post-card:hover .post-title {
  color: var(--color-primary);
}
.post-content {
  color: var(--color-text-secondary);
  line-height: 1.7;
  margin: 0;
  font-size: 1rem;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* --- Image --- */
.post-image-wrapper {
  width: 100%;
  border-radius: var(--radius-medium);
  overflow: hidden;
  height: 240px;
  background-color: var(--color-background);
}
.post-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--transition-slow);
}
.post-card:hover .post-image {
  transform: scale(1.05);
}

/* --- Footer --- */
.post-footer {
  display: flex;
  justify-content: flex-start;
  gap: 28px;
  padding-top: 16px;
  border-top: 1px solid var(--color-border);
}
.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  font-weight: 500;
  transition: color var(--transition-fast);
}
.stat-item i {
  font-size: 1.1rem;
}
.stat-item.comment-btn:hover {
  color: var(--color-primary);
}
.stat-item.like-btn:hover {
  color: #E53E3E; /* Red for likes */
}
</style>
