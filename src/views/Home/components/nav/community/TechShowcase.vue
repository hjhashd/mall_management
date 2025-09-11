<template>
  <div class="community-container">
    <div class="community-header">
      <h1 class="header-title">求购专区</h1>
    </div>

    <div class="community-content">
      <FilterSidebar
          @update-filters="applyFilters"
          @update-collapse="updateLeftSidebarCollapse"
      />

      <div class="post-list" :style="postListStyle">
        <PostCard
            v-for="(post, index) in filteredPosts"
            :key="post.postId"
            :post="post"
            :current-user="currentUser"
            @open-comments="openComments"
            class="post-card-item"
            :style="{ animationDelay: `${index * 50}ms` }"
        />
        <div v-if="loadingPosts" class="loading-state">
          <i class="fas fa-spinner fa-spin fa-2x"></i>
          <p>正在同步数据...</p>
        </div>
        <div v-else-if="filteredPosts.length === 0" class="no-posts-found">
          <i class="fas fa-satellite-dish fa-2x"></i>
          <p>未搜索到相关条目</p>
          <p class="no-posts-hint">尝试调整筛选条件或成为第一个发布者</p>
        </div>
      </div>

      <div class="post-form frosted-panel" :class="{ 'is-collapsed': isRightSidebarCollapsed }">
        <div class="sidebar-header" @click="toggleRightSidebar" :title="isRightSidebarCollapsed ? '展开面板' : '收起面板'">
          <h2><i class="fas fa-plus-circle"></i> 发布需求</h2>
          <i class="fas toggle-icon" :class="isRightSidebarCollapsed ? 'fa-chevron-left' : 'fa-chevron-right'"></i>
        </div>

        <div class="sidebar-content" v-if="!isRightSidebarCollapsed">
          <div class="form-group">
            <label for="post-title" class="form-label">标题</label>
            <input
                type="text"
                id="post-title"
                class="form-control"
                placeholder="求购：最新款AI降噪耳机"
                v-model="newPost.title"
            />
          </div>
          <div class="form-group">
            <label for="post-category" class="form-label">分类</label>
            <select
                id="post-category"
                class="form-control"
                v-model="newPost.category"
            >
              <option value="">选择分类</option>
              <option value="智能硬件">智能硬件</option>
              <option value="数码影音">数码影音</option>
              <option value="设计软件">设计软件</option>
              <option value="极客外设">极客外设</option>
              <option value="生活科技">生活科技</option>
            </select>
          </div>
          <div class="form-group">
            <label for="post-content" class="form-label">详细描述</label>
            <textarea
                id="post-content"
                class="form-control"
                placeholder="具体需求、预算范围、期望成色等"
                v-model="newPost.content"
            ></textarea>
          </div>
          <div class="form-group">
            <label for="post-image" class="form-label">参考图片 (可选)</label>
            <div class="file-upload-wrapper">
              <input
                  type="file"
                  id="post-image"
                  class="file-upload-input"
                  @change="handleImageUpload"
                  accept="image/jpeg,image/png,image/webp"
              />
              <div class="file-upload-hint">
                <i class="fas fa-cloud-upload-alt"></i>
                <span v-if="newPost.featuredImage">{{ newPost.featuredImage.name }}</span>
                <span v-else>点击或拖拽上传</span>
              </div>
            </div>
          </div>
          <button
              class="btn btn-primary btn-block"
              @click="submitPost"
              :disabled="!newPost.title || !newPost.content || !newPost.category"
          >
            <i class="fas fa-paper-plane"></i> 提交发布
          </button>
        </div>
      </div>
    </div>

    <CommentsModal
        :show="showCommentsModal"
        :post="selectedPost"
        @close="closeComments"
        @add-comment="handleAddComment"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import PostCard from './PostCard.vue';
import CommentsModal from './CommentsModal.vue';
import FilterSidebar from './FilterSidebar.vue';
import { getCommunityPosts, getPostComments, createNewPost, addPostComment } from '@/api/community';
import { useUserStore } from '@/stores/userStore';

// 日期格式化函数
const formatDate = (date, fmt = 'yyyy-MM-dd HH:mm') => {
  const d = new Date(date);
  const o = {
    'M+': d.getMonth() + 1, 'd+': d.getDate(), 'H+': d.getHours(), 'm+': d.getMinutes(),
    's+': d.getSeconds(), 'q+': Math.floor((d.getMonth() + 3) / 3), S: d.getMilliseconds()
  };
  if (/(y+)/.test(fmt)) {
    fmt = fmt.replace(RegExp.$1, (d.getFullYear() + '').substr(4 - RegExp.$1.length));
  }
  for (let k in o) {
    if (new RegExp('(' + k + ')').test(fmt)) {
      fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? o[k] : ('00' + o[k]).substr(('' + o[k]).length));
    }
  }
  return fmt;
};

const posts = ref([]);
const newPost = ref({ title: '', category: '', content: '', featuredImage: null, });
const showCommentsModal = ref(false);
const selectedPost = ref(null);
const currentFilters = ref({ category: '', keyword: '', minLikes: '', });
const isLeftSidebarCollapsed = ref(false);
const isRightSidebarCollapsed = ref(false);
const loadingPosts = ref(true);
const userStore = useUserStore();

const currentUser = computed(() => ({
  userId: userStore.userInfo?.userId,
  name: userStore.userInfo?.username || '当前用户',
  avatar: userStore.userInfo?.avatarPath || '我'
}));

const applyFilters = (filters) => {
  currentFilters.value = filters;
  fetchPosts();
};

const updateLeftSidebarCollapse = (isCollapsed) => {
  isLeftSidebarCollapsed.value = isCollapsed;
};

const toggleRightSidebar = () => {
  isRightSidebarCollapsed.value = !isRightSidebarCollapsed.value;
};

const postListStyle = computed(() => {
  if (isLeftSidebarCollapsed.value && isRightSidebarCollapsed.value) {
    return {'margin-left': '0', 'margin-right': '0'};
  }
  else if (isLeftSidebarCollapsed.value) {
    return {'margin-left': '0'};
  }
  else if (isRightSidebarCollapsed.value) {
    return {'margin-right': '0'};
  }
  return {};
});

// 获取帖子列表
const fetchPosts = async () => {
  loadingPosts.value = true;
  try {
    const response = await getCommunityPosts(currentFilters.value);
    const postData = response.data.data?.list || [];
    posts.value = postData.map(post => ({
      ...post,
      user: post.user ? {
        userId: post.user.userId,
        name: post.user.username || '未知用户',
        avatar: post.user.avatarPath || '?'
      } : {name: '未知用户', avatar: '?'},
      imageIcon: post.featuredImage ? 'fas fa-image' : 'fas fa-image',
      createdAt: formatDate(post.createdAt),
    }));
  } catch (error) {
    console.error('Error fetching posts:', error);
    posts.value = [];
  } finally {
    loadingPosts.value = false;
  }
};

// 处理图片上传
const handleImageUpload = (event) => {
  const file = event.target.files[0];
  if (file) {
    newPost.value.featuredImage = file;
  }
};

// 提交新帖子
const submitPost = async () => {
  if (!userStore.isLoggedIn) {
    alert('请先登录才能发布内容！');
    return;
  }
  if (!newPost.value.title || !newPost.value.content || !newPost.value.category) {
    alert('请填写完整的帖子信息！');
    return;
  }

  const formData = new FormData();
  formData.append('title', newPost.value.title);
  formData.append('content', newPost.value.content);
  formData.append('category', newPost.value.category);
  formData.append('userId', currentUser.value.userId);
  if (newPost.value.featuredImage) {
    formData.append('featuredImage', newPost.value.featuredImage);
  }

  try {
    await createNewPost(formData);
    alert('发布成功！');
    newPost.value = {title: '', category: '', content: '', featuredImage: null};
    fetchPosts();
  } catch (error) {
    console.error('Error submitting post:', error);
    alert('发布失败！');
  }
};

// 打开评论弹窗
const openComments = async (postId) => {
  const post = posts.value.find(p => p.postId === postId);
  if (post) {
    selectedPost.value = post;
    showCommentsModal.value = true;
    try {
      const response = await getPostComments(postId);
      const commentData = response.data.data?.list || response.data.data || [];
      selectedPost.value.comments = commentData.map(comment => ({
        ...comment,
        user: comment.user ? {
          name: comment.user.username || '评论用户',
          avatar: comment.user.avatarPath || '?'
        } : {name: '评论用户', avatar: '?'},
        createdAt: formatDate(comment.createdAt),
      }));
    } catch (error) {
      console.error('Error fetching comments:', error);
      selectedPost.value.comments = [];
    }
  }
};

// 关闭评论弹窗
const closeComments = () => {
  showCommentsModal.value = false;
  selectedPost.value = null;
};

// 添加评论
const handleAddComment = async (newCommentText) => {
  if (!userStore.isLoggedIn) {
    alert('请先登录才能评论！');
    return;
  }
  if (!selectedPost.value) return;

  try {
    const data = {
      content: newCommentText,
      userId: currentUser.value.userId,
      postId: selectedPost.value.postId,
    };
    await addPostComment(selectedPost.value.postId, data);
    alert('评论成功！');
    openComments(selectedPost.value.postId);
  } catch (error) {
    console.error('Error adding comment:', error);
    alert('评论失败！');
  }
};

// 组件挂载时初始化
onMounted(() => {
  userStore.restoreFromStorage();
  fetchPosts();
});

// 过滤帖子
const filteredPosts = computed(() => {
  let filtered = [...posts.value];
  if (currentFilters.value.category) {
    filtered = filtered.filter(post => post.category === currentFilters.value.category);
  }
  if (currentFilters.value.keyword) {
    const keyword = currentFilters.value.keyword.toLowerCase();
    filtered = filtered.filter(post =>
        post.title.toLowerCase().includes(keyword) ||
        post.content.toLowerCase().includes(keyword)
    );
  }
  if (currentFilters.value.minLikes) {
    const minLikes = parseInt(currentFilters.value.minLikes);
    filtered = filtered.filter(post => post.likeCount >= minLikes);
  }
  return filtered;
});
</script>

<style scoped>
/* Scoped styles are now minimal, layout is handled globally */
.community-container {
  max-width: 1600px;
  margin: 0 auto;
  padding: 40px var(--spacing-large) 80px;
}

.community-header {
  text-align: center;
  margin-bottom: 60px;
}

.header-title {
  font-size: 3.5rem;
  font-weight: 800;
  color: var(--color-text-primary);
  margin-bottom: 12px;
  letter-spacing: -1px;
}

.header-subtitle {
  font-size: 1.2rem;
  color: var(--color-text-secondary);
}

.community-content {
  display: flex;
  gap: var(--spacing-large);
  align-items: flex-start;
}

.post-list {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  gap: var(--spacing-large);
  transition: margin 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.post-card-item {
  opacity: 0;
  transform: translateY(20px);
  animation: slide-fade-in 0.5s ease-out forwards;
}

.post-form {
  width: var(--sidebar-width);
  padding: var(--spacing-base);
  position: sticky;
  top: 40px;
  flex-shrink: 0;
  overflow: hidden;
  transition: all var(--transition-slow);
}

.frosted-panel {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: var(--radius-large);
  box-shadow: var(--shadow-xl);
}

.post-form.is-collapsed {
  width: 0;
  padding: var(--spacing-base) 0;
  border-color: transparent;
  background: transparent;
  backdrop-filter: none;
  -webkit-backdrop-filter: none;
  box-shadow: none;
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  margin-bottom: var(--spacing-large);
  color: var(--color-text-primary);
  padding: 0 5px;
}

.sidebar-header h2 {
  font-size: 1.2rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 12px;
  white-space: nowrap;
}

.toggle-icon {
  color: var(--color-text-secondary);
  transition: transform var(--transition-medium);
}

.post-form.is-collapsed .toggle-icon {
  transform: rotate(180deg);
}

/* Form elements are styled globally now */
.loading-state, .no-posts-found {
  text-align: center;
  color: var(--color-text-secondary);
  padding: 60px 30px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-large);
}

.loading-state i, .no-posts-found i {
  margin-bottom: 18px;
  color: var(--color-primary);
}

.no-posts-hint {
  font-size: 0.9rem;
  color: #ADB5BD;
  margin-top: 8px;
}

@keyframes slide-fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 991px) {
  .community-content {
    flex-direction: column;
  }

  .post-form, .filter-sidebar {
    width: 100%;
    position: static;
  }

  .post-form.is-collapsed {
    width: 100%;
  }

  .post-list {
    order: 3;
  }

  .filter-sidebar {
    order: 1;
  }

  .post-form {
    order: 2;
  }
}

@media (max-width: 600px) {
  .community-container {
    padding: 20px 15px 60px;
  }

  .header-title {
    font-size: 2.5rem;
  }

  .header-subtitle {
    font-size: 1rem;
  }
}
</style>
