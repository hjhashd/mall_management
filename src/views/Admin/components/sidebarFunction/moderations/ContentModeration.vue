<template>
  <div class="moderation-container">
    <!-- 通知/Toast 容器 -->
    <div class="notification-container">
      <transition-group name="notification-fade">
        <div v-for="notification in notifications" :key="notification.id" :class="['notification', `notification-${notification.type}`]">
          <i :class="notification.icon" class="notification-icon"></i>
          <p>{{ notification.message }}</p>
          <button @click="removeNotification(notification.id)" class="notification-close-btn">&times;</button>
        </div>
      </transition-group>
    </div>

    <!-- 头部：标题和筛选 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <i class="fas fa-tasks"></i>
          事务待办
        </h1>
        <p class="page-subtitle">审核和管理用户提交的各类内容</p>
      </div>
      <div class="header-actions">
        <div class="filter-tabs">
          <button
              :class="['filter-btn', { active: filterStatus === null }]"
              @click="changeFilter(null)"
          >
            <i class="fas fa-list-ul"></i> 全部
          </button>
          <button
              :class="['filter-btn', { active: filterStatus === 0 }]"
              @click="changeFilter(0)"
          >
            <i class="fas fa-hourglass-half"></i> 待审核
          </button>
          <button
              :class="['filter-btn', { active: filterStatus === 1 }]"
              @click="changeFilter(1)"
          >
            <i class="fas fa-check-circle"></i> 已通过
          </button>
          <button
              :class="['filter-btn', { active: filterStatus === 2 }]"
              @click="changeFilter(2)"
          >
            <i class="fas fa-times-circle"></i> 已拒绝
          </button>
        </div>
      </div>
    </div>

    <!-- 主体内容区 -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>正在加载待办任务...</p>
    </div>

    <div v-else class="moderation-list">
      <!-- 空状态 -->
      <div v-if="paginatedTasks.length === 0" class="empty-state">
        <div class="empty-icon"><i class="fas fa-check-double"></i></div>
        <h3>干得漂亮！</h3>
        <p>当前筛选条件下没有待办事项</p>
      </div>

      <!-- 任务卡片列表 -->
      <div
          v-for="(task, index) in paginatedTasks"
          :key="task.moderation_id"
          class="moderation-card"
          :style="{ '--animation-delay': `${index * 0.05}s` }"
      >
        <div class="moderation-card-header">
          <div class="content-type-icon" :class="getStatusInfo(task.status).class">
            <i :class="getIconForType(task.content_type)"></i>
          </div>
          <div class="content-info">
            <h4 class="content-title">
              {{ getContentTypeName(task.content_type) }} 审核
              <span class="content-id">#{{ task.content_id }}</span>
            </h4>
            <p class="submission-time">
              提交于: {{ new Date(task.created_at).toLocaleString() }}
            </p>
          </div>
          <div class="status-badge" :class="getStatusInfo(task.status).class">
            {{ getStatusInfo(task.status).text }}
          </div>
        </div>
        <div class="moderation-card-body">
          <p class="content-preview">{{ task.content }}</p>
          <div v-if="task.status === 2 && task.reason" class="rejection-reason">
            <strong>拒绝原因:</strong> {{ task.reason }}
          </div>
        </div>
        <div v-if="task.status === 0" class="moderation-card-actions">
          <button class="btn btn-danger-outline" @click="openRejectModal(task)">
            <i class="fas fa-times"></i> 拒绝
          </button>
          <button class="btn btn-success" @click="handleApprove(task)">
            <i class="fas fa-check"></i> 通过
          </button>
        </div>
      </div>

      <!-- 分页 -->
      <div v-if="totalPages > 1" class="pagination-wrapper">
        <div class="pagination">
          <button
              class="pagination-btn"
              @click="changePage(pagination.currentPage - 1)"
              :disabled="pagination.currentPage <= 1"
          >
            <i class="fas fa-chevron-left"></i>
          </button>
          <div class="pagination-info">
            第 {{ pagination.currentPage }} / {{ totalPages }} 页
          </div>
          <button
              class="pagination-btn"
              @click="changePage(pagination.currentPage + 1)"
              :disabled="pagination.currentPage >= totalPages"
          >
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- 拒绝原因模态框 -->
    <div v-if="isRejectModalOpen" class="modal-overlay" @click.self="closeRejectModal">
      <div class="modal-container">
        <div class="modal-header">
          <h2><i class="fas fa-comment-slash"></i> 填写拒绝原因</h2>
          <button class="modal-close" @click="closeRejectModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="rejectionReason">请输入拒绝该内容的具体原因：</label>
            <textarea
                id="rejectionReason"
                v-model="rejectionReason"
                rows="4"
                placeholder="例如：内容包含不当言论、图片不清晰等。"
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline" @click="closeRejectModal">取消</button>
          <button class="btn btn-danger" @click="processReject" :disabled="isSaving || !rejectionReason.trim()">
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-paper-plane'"></i>
            {{ isSaving ? '提交中...' : '确认拒绝' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 通用确认模态框 -->
    <div v-if="isConfirmModalOpen" class="modal-overlay" @click.self="closeConfirmModal">
      <div class="modal-container confirmation-modal">
        <div class="modal-header">
          <h2 class="confirmation-title">
            <i class="fas fa-exclamation-triangle"></i> {{ confirmModalConfig.title }}
          </h2>
          <button class="modal-close" @click="closeConfirmModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <p v-html="confirmModalConfig.message"></p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline" @click="closeConfirmModal">取消</button>
          <button class="btn btn-success" @click="executeConfirmAction">确认</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';

// --- API 模拟 ---
// 在真实项目中，这些函数应移至 api 文件中并发出真实的网络请求
const mockDatabase = ref([
  { moderation_id: 1, content_type: 'product', content_id: 101, content: '这是一款全新的智能手表，拥有超长续航和健康监测功能。', status: 0, reason: null, created_at: '2025-08-29T10:00:00Z' },
  { moderation_id: 2, content_type: 'review', content_id: 202, content: '这家餐厅的服务太棒了，食物也很美味，强烈推荐！', status: 0, reason: null, created_at: '2025-08-29T09:30:00Z' },
  { moderation_id: 3, content_type: 'post', content_id: 303, content: '分享我的周末旅行日记，风景超美！', status: 1, reason: null, created_at: '2025-08-28T18:00:00Z' },
  { moderation_id: 4, content_type: 'comment', content_id: 404, content: '这个价格太贵了，不值得。', status: 2, reason: '包含负面评价，但不违规', created_at: '2025-08-28T15:20:00Z' },
  { moderation_id: 5, content_type: 'product', content_id: 102, content: '出售二手手机，9成新，价格面议。', status: 2, reason: '不允许发布二手交易信息', created_at: '2025-08-28T11:05:00Z' },
  { moderation_id: 6, content_type: 'review', content_id: 203, content: '好评！', status: 1, reason: null, created_at: '2025-08-27T20:45:00Z' },
  { moderation_id: 7, content_type: 'post', content_id: 304, content: '有人知道怎么解决这个问题吗？在线等，急！', status: 0, reason: null, created_at: '2025-08-29T11:00:00Z' },
]);

const mockApi = {
  getModerationTasks: async ({ page, pageSize, status }) => {
    console.log(`Fetching tasks: page=${page}, pageSize=${pageSize}, status=${status}`);
    return new Promise(resolve => {
      setTimeout(() => {
        const filtered = mockDatabase.value.filter(task => status === null || task.status === status);
        const totalItems = filtered.length;
        const items = filtered.slice((page - 1) * pageSize, page * pageSize);
        resolve({
          data: { success: true, data: { items, totalItems } }
        });
      }, 500);
    });
  },
  processTask: async (moderationId, newStatus, reason = null) => {
    return new Promise(resolve => {
      setTimeout(() => {
        const task = mockDatabase.value.find(t => t.moderation_id === moderationId);
        if (task) {
          task.status = newStatus;
          task.reason = reason;
          task.processed_at = new Date().toISOString();
          resolve({ data: { success: true, message: '操作成功' } });
        } else {
          resolve({ data: { success: false, message: '任务不存在' } });
        }
      }, 300);
    });
  }
};
// --- 结束 API 模拟 ---

// --- 状态管理 ---
const allTasks = ref([]);
const isLoading = ref(true);
const isSaving = ref(false);
const filterStatus = ref(0); // 默认显示“待审核”
const pagination = ref({ currentPage: 1, pageSize: 5, total: 0 });

const isRejectModalOpen = ref(false);
const selectedTask = ref(null);
const rejectionReason = ref('');

const notifications = ref([]);
let notificationIdCounter = 0;

const isConfirmModalOpen = ref(false);
const confirmModalConfig = ref({ title: '', message: '', onConfirm: null });

// --- 数据获取 ---
const fetchData = async () => {
  isLoading.value = true;
  try {
    const response = await mockApi.getModerationTasks({
      page: pagination.value.currentPage,
      pageSize: pagination.value.pageSize,
      status: filterStatus.value,
    });
    if (response.data?.success) {
      allTasks.value = response.data.data.items || [];
      pagination.value.total = response.data.data.totalItems || 0;
    } else {
      showNotification('获取待办列表失败', 'error');
    }
  } catch (error) {
    console.error("请求数据时出错:", error);
    showNotification("请求数据时出错，请检查网络或联系管理员。", 'error');
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchData);

// --- 计算属性 ---
const totalPages = computed(() => Math.ceil(pagination.value.total / pagination.value.pageSize));
const paginatedTasks = computed(() => allTasks.value);

// --- 通知方法 ---
const showNotification = (message, type = 'success', duration = 3500) => {
  const icons = {
    success: 'fas fa-check-circle',
    error: 'fas fa-exclamation-circle',
    info: 'fas fa-info-circle',
  };
  const id = notificationIdCounter++;
  notifications.value.push({ id, message, type, icon: icons[type] || icons.info });
  setTimeout(() => removeNotification(id), duration);
};

const removeNotification = (id) => {
  const index = notifications.value.findIndex(n => n.id === id);
  if (index !== -1) notifications.value.splice(index, 1);
};

// --- 确认模态框方法 ---
const openConfirmModal = (title, message, onConfirm) => {
  confirmModalConfig.value = { title, message, onConfirm };
  isConfirmModalOpen.value = true;
};
const closeConfirmModal = () => isConfirmModalOpen.value = false;
const executeConfirmAction = async () => {
  if (confirmModalConfig.value.onConfirm) {
    await confirmModalConfig.value.onConfirm();
  }
  closeConfirmModal();
};

// --- 核心业务逻辑 ---
const changeFilter = (status) => {
  filterStatus.value = status;
  pagination.value.currentPage = 1; // 重置到第一页
};

watch(filterStatus, fetchData);

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
    fetchData();
  }
};

const handleApprove = (task) => {
  openConfirmModal(
      '确认通过',
      `您确定要通过 <strong>[${getContentTypeName(task.content_type)} #${task.content_id}]</strong> 这条内容吗？`,
      async () => {
        isSaving.value = true;
        try {
          const response = await mockApi.processTask(task.moderation_id, 1);
          if (response.data?.success) {
            showNotification('内容已通过');
            await fetchData();
          } else {
            showNotification(response.data.message || '操作失败', 'error');
          }
        } catch (error) {
          showNotification('操作失败，请重试', 'error');
        } finally {
          isSaving.value = false;
        }
      }
  );
};

const openRejectModal = (task) => {
  selectedTask.value = task;
  rejectionReason.value = '';
  isRejectModalOpen.value = true;
};

const closeRejectModal = () => {
  isRejectModalOpen.value = false;
  selectedTask.value = null;
};

const processReject = async () => {
  if (!rejectionReason.value.trim() || !selectedTask.value) return;
  isSaving.value = true;
  try {
    const response = await mockApi.processTask(selectedTask.value.moderation_id, 2, rejectionReason.value);
    if (response.data?.success) {
      showNotification('内容已拒绝');
      closeRejectModal();
      await fetchData();
    } else {
      showNotification(response.data.message || '操作失败', 'error');
    }
  } catch (error) {
    showNotification('操作失败，请重试', 'error');
  } finally {
    isSaving.value = false;
  }
};


// --- UI 辅助函数 ---
const getIconForType = (type) => {
  const icons = {
    product: 'fas fa-box-open',
    review: 'fas fa-star',
    post: 'fas fa-file-alt',
    comment: 'fas fa-comment'
  };
  return icons[type] || 'fas fa-question-circle';
};

const getContentTypeName = (type) => {
  const names = { product: '商品', review: '评价', post: '帖子', comment: '评论' };
  return names[type] || '未知类型';
};

const getStatusInfo = (status) => {
  switch (status) {
    case 0: return { text: '待审核', class: 'status-pending' };
    case 1: return { text: '已通过', class: 'status-approved' };
    case 2: return { text: '已拒绝', class: 'status-rejected' };
    default: return { text: '未知', class: 'status-default' };
  }
};

</script>

<style scoped>
/* 组件样式继承父主题变量并增强对比度 */
.moderation-container {
  padding: 1.5rem !important;
  font-family: var(--font-family-base, 'Inter', sans-serif) !important;
  color: var(--text-primary, #1e293b) !important;
  background: var(--bg-secondary, #f7f9fc) !important;
  min-height: 100vh !important;
  animation: fadeIn 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) !important;
}

@keyframes fadeIn { 
  from { opacity: 0; transform: translateY(20px); } 
  to { opacity: 1; transform: translateY(0); } 
}

/* 通知样式增强 */
.notification-container { 
  position: fixed !important; 
  top: 20px !important; 
  right: 20px !important; 
  z-index: 2000 !important; 
  display: flex !important; 
  flex-direction: column !important; 
  gap: 12px !important; 
}

.notification { 
  display: flex !important; 
  align-items: center !important; 
  gap: 12px !important; 
  padding: 14px 20px !important; 
  border-radius: var(--border-radius-sm, 0.5rem) !important; 
  color: white !important; 
  min-width: 320px !important; 
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important; 
  animation: slideInRight 0.4s ease-out !important;
  font-weight: 500 !important;
}

.notification-success { 
  background: linear-gradient(135deg, #22c55e, #16a34a) !important; 
  border-left: 4px solid #15803d !important;
}

.notification-error { 
  background: linear-gradient(135deg, #ef4444, #dc2626) !important; 
  border-left: 4px solid #b91c1c !important;
}

.notification-info { 
  background: linear-gradient(135deg, var(--accent-color, #4a6cf7), var(--accent-color-hover, #3b57d6)) !important; 
  border-left: 4px solid var(--accent-color-hover, #3b57d6) !important;
}

.notification-icon { 
  font-size: 1.3rem !important; 
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.2)) !important;
}

.notification p { 
  margin: 0 !important; 
  flex-grow: 1 !important; 
  font-size: 0.95rem !important;
  line-height: 1.4 !important;
}

.notification-close-btn { 
  background: none !important; 
  border: none !important; 
  color: white !important; 
  opacity: 0.8 !important; 
  font-size: 1.4rem !important; 
  cursor: pointer !important; 
  transition: all 0.3s ease !important;
  width: 24px !important;
  height: 24px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

.notification-close-btn:hover { 
  opacity: 1 !important; 
  transform: scale(1.1) !important;
}

.notification-fade-enter-active, .notification-fade-leave-active { 
  transition: all 0.5s ease !important; 
}

.notification-fade-enter-from, .notification-fade-leave-to { 
  opacity: 0 !important; 
  transform: translateX(100%) !important; 
}

@keyframes slideInRight { 
  from { transform: translateX(100%); opacity: 0; } 
  to { transform: translateX(0); opacity: 1; } 
}

/* 页面头部样式增强 */
.page-header { 
  display: flex !important; 
  justify-content: space-between !important; 
  align-items: flex-start !important; 
  flex-wrap: wrap !important; 
  gap: 2rem !important; 
  margin-bottom: 2.5rem !important; 
  padding: 2rem 0 !important; 
  border-bottom: 2px solid var(--border-color, #e2e8f0) !important;
  background: var(--bg-primary, #ffffff) !important;
  border-radius: var(--border-radius-md, 0.75rem) !important;
  box-shadow: 0 2px 8px var(--shadow-color, rgba(74, 108, 247, 0.1)) !important;
}

.header-content {
  padding: 0 1.5rem !important;
}

.page-title { 
  display: flex !important; 
  align-items: center !important; 
  gap: 1rem !important; 
  margin: 0 0 1rem 0 !important; 
  font-size: 2.2rem !important; 
  font-weight: 700 !important; 
  color: var(--text-primary, #1e293b) !important;
}

.page-title i { 
  color: var(--accent-color, #4a6cf7) !important; 
  font-size: 2rem !important;
  filter: drop-shadow(0 2px 4px rgba(74, 108, 247, 0.2)) !important;
}

.page-subtitle { 
  margin: 0 !important; 
  color: var(--text-secondary, #64748b) !important;
  font-size: 1.1rem !important;
  font-weight: 500 !important;
}

.header-actions {
  padding: 0 1.5rem !important;
}

.filter-tabs { 
  display: flex !important; 
  align-items: center !important; 
  gap: 0.75rem !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
  padding: 0.75rem !important; 
  border-radius: var(--border-radius-md, 0.75rem) !important;
  border: 1px solid var(--border-color, #e2e8f0) !important;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.06) !important;
}

.filter-btn { 
  padding: 0.875rem 1.5rem !important; 
  border: none !important; 
  border-radius: var(--border-radius-sm, 0.5rem) !important; 
  background: transparent !important; 
  color: var(--text-secondary, #64748b) !important; 
  font-weight: 600 !important; 
  cursor: pointer !important; 
  transition: all 0.3s ease !important; 
  display: inline-flex !important; 
  align-items: center !important; 
  justify-content: center !important;
  gap: 0.625rem !important;
  font-size: 0.95rem !important;
  white-space: nowrap !important;
}

.filter-btn:hover { 
  background: var(--bg-hover, #eff4ff) !important; 
  color: var(--accent-color, #4a6cf7) !important;
  transform: translateY(-1px) !important;
}

.filter-btn.active { 
  background: var(--accent-color, #4a6cf7) !important; 
  color: white !important; 
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.3) !important;
  transform: translateY(-1px) !important;
}

.filter-btn i {
  font-size: 1rem !important;
}

/* 加载与空状态增强 */
.loading-state, .empty-state { 
  display: flex !important; 
  flex-direction: column !important; 
  align-items: center !important; 
  justify-content: center !important; 
  padding: 5rem 2rem !important; 
  text-align: center !important; 
  color: var(--text-secondary, #64748b) !important;
  background: var(--bg-primary, #ffffff) !important;
  border-radius: var(--border-radius-md, 0.75rem) !important;
  box-shadow: 0 2px 8px var(--shadow-color, rgba(74, 108, 247, 0.1)) !important;
}

.spinner { 
  width: 60px !important; 
  height: 60px !important; 
  border: 6px solid var(--bg-secondary, #f7f9fc) !important; 
  border-top-color: var(--accent-color, #4a6cf7) !important; 
  border-radius: 50% !important; 
  animation: spin 1s linear infinite !important; 
  margin-bottom: 1.5rem !important; 
}

@keyframes spin { 
  to { transform: rotate(360deg); } 
}

.empty-state { 
  border: 3px dashed var(--border-color, #e2e8f0) !important; 
  margin-top: 1.5rem !important; 
}

.empty-icon { 
  font-size: 4rem !important; 
  color: var(--accent-color, #4a6cf7) !important; 
  opacity: 0.7 !important; 
  margin-bottom: 1.5rem !important;
  filter: drop-shadow(0 2px 8px rgba(74, 108, 247, 0.2)) !important;
}

.empty-state h3 { 
  margin: 0 0 1rem !important; 
  color: var(--text-primary, #1e293b) !important;
  font-size: 1.5rem !important;
  font-weight: 600 !important;
}

.empty-state p { 
  margin: 0 !important; 
  color: var(--text-secondary, #64748b) !important; 
  font-size: 1.1rem !important;
  font-weight: 500 !important;
}

/* 任务卡片列表增强 */
.moderation-list {
  display: grid !important;
  grid-template-columns: 1fr !important;
  gap: 2rem !important;
}

.moderation-card {
  background: var(--bg-primary, #ffffff) !important;
  border: 2px solid var(--border-color, #e2e8f0) !important;
  border-radius: var(--border-radius-md, 0.75rem) !important;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
  overflow: hidden !important;
  animation: slideUp 0.6s ease-out both !important;
  animation-delay: var(--animation-delay, 0s) !important;
  display: flex !important;
  flex-direction: column !important;
  box-shadow: 0 4px 12px var(--shadow-color, rgba(74, 108, 247, 0.1)) !important;
}

@keyframes slideUp { 
  from { opacity: 0; transform: translateY(30px); } 
  to { opacity: 1; transform: translateY(0); } 
}

.moderation-card:hover { 
  transform: translateY(-5px) !important; 
  box-shadow: 0 12px 35px var(--shadow-color, rgba(74, 108, 247, 0.15)) !important; 
  border-color: var(--accent-color, #4a6cf7) !important;
}

.moderation-card-header { 
  display: flex !important; 
  align-items: center !important; 
  gap: 1.25rem !important; 
  padding: 1.5rem 2rem !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
  border-bottom: 2px solid var(--border-color, #e2e8f0) !important; 
}

.content-type-icon { 
  width: 52px !important; 
  height: 52px !important; 
  display: flex !important; 
  align-items: center !important; 
  justify-content: center !important; 
  color: white !important; 
  border-radius: 50% !important; 
  font-size: 1.4rem !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15) !important;
  background: var(--accent-color, #4a6cf7) !important;
}

.content-info { 
  flex: 1 !important; 
}

.content-title { 
  margin: 0 0 0.5rem 0 !important; 
  font-size: 1.2rem !important; 
  color: var(--text-primary, #1e293b) !important;
  font-weight: 600 !important;
}

.content-id { 
  font-weight: 500 !important; 
  color: var(--accent-color, #4a6cf7) !important; 
  font-size: 1rem !important;
  background: rgba(74, 108, 247, 0.1) !important;
  padding: 0.25rem 0.5rem !important;
  border-radius: 0.25rem !important;
  margin-left: 0.5rem !important;
}

.submission-time { 
  margin: 0 !important; 
  font-size: 0.9rem !important; 
  color: var(--text-secondary, #64748b) !important;
  font-weight: 500 !important;
}

.status-badge { 
  padding: 0.5rem 1rem !important; 
  border-radius: 25px !important; 
  font-size: 0.85rem !important; 
  font-weight: 700 !important; 
  color: white !important;
  text-transform: uppercase !important;
  letter-spacing: 0.5px !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15) !important;
}

.status-pending { 
  background: linear-gradient(135deg, #f59e0b, #d97706) !important; 
}

.status-approved { 
  background: linear-gradient(135deg, #10b981, #059669) !important; 
}

.status-rejected { 
  background: linear-gradient(135deg, #ef4444, #dc2626) !important; 
}

.status-default { 
  background: linear-gradient(135deg, #6b7280, #4b5563) !important; 
}

.moderation-card-body { 
  padding: 2rem !important; 
  flex-grow: 1 !important; 
}

.content-preview { 
  margin: 0 !important; 
  line-height: 1.7 !important; 
  color: var(--text-primary, #1e293b) !important;
  font-size: 1.05rem !important;
  font-weight: 400 !important;
}

.rejection-reason { 
  margin-top: 1.5rem !important; 
  padding: 1rem 1.25rem !important; 
  background: rgba(239, 68, 68, 0.08) !important; 
  border-left: 4px solid #ef4444 !important; 
  border-radius: var(--border-radius-sm, 0.5rem) !important; 
  color: #dc2626 !important; 
  font-size: 0.95rem !important;
  font-weight: 500 !important;
}

.rejection-reason strong { 
  color: #b91c1c !important;
  font-weight: 700 !important;
}

.moderation-card-actions { 
  display: flex !important; 
  justify-content: flex-end !important; 
  gap: 1.25rem !important; 
  padding: 1.5rem 2rem !important; 
  border-top: 2px solid var(--border-color, #e2e8f0) !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
}

/* 按钮样式增强 */
.btn { 
  display: inline-flex !important; 
  align-items: center !important; 
  justify-content: center !important; 
  gap: 0.625rem !important; 
  padding: 0.875rem 1.75rem !important; 
  border: 2px solid transparent !important; 
  border-radius: var(--border-radius-sm, 0.5rem) !important; 
  font-size: 0.95rem !important; 
  font-weight: 600 !important; 
  cursor: pointer !important; 
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) !important; 
  white-space: nowrap !important;
  text-transform: none !important;
  letter-spacing: 0.25px !important;
}

.btn:disabled { 
  opacity: 0.6 !important; 
  cursor: not-allowed !important;
  transform: none !important;
}

.btn-success { 
  background: linear-gradient(135deg, #10b981, #059669) !important; 
  color: white !important; 
  border-color: #059669 !important;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3) !important;
}

.btn-success:hover:not(:disabled) { 
  background: linear-gradient(135deg, #059669, #047857) !important; 
  border-color: #047857 !important; 
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4) !important;
}

.btn-danger { 
  background: linear-gradient(135deg, #ef4444, #dc2626) !important; 
  color: white !important; 
  border-color: #dc2626 !important;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3) !important;
}

.btn-danger:hover:not(:disabled) { 
  background: linear-gradient(135deg, #dc2626, #b91c1c) !important; 
  border-color: #b91c1c !important; 
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4) !important;
}

.btn-danger-outline { 
  background: transparent !important; 
  color: #ef4444 !important; 
  border-color: #ef4444 !important; 
}

.btn-danger-outline:hover { 
  background: #ef4444 !important; 
  color: white !important;
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(239, 68, 68, 0.3) !important;
}

.btn-outline { 
  background: transparent !important; 
  color: var(--text-secondary, #64748b) !important; 
  border-color: var(--border-color, #e2e8f0) !important; 
}

.btn-outline:hover { 
  color: var(--accent-color, #4a6cf7) !important; 
  border-color: var(--accent-color, #4a6cf7) !important; 
  background: var(--bg-hover, #eff4ff) !important;
  transform: translateY(-1px) !important;
}

/* 分页样式增强 */
.pagination-wrapper { 
  display: flex !important; 
  justify-content: center !important; 
  margin-top: 3rem !important; 
}

.pagination { 
  display: flex !important; 
  align-items: center !important; 
  gap: 1.25rem !important;
  background: var(--bg-primary, #ffffff) !important;
  padding: 1rem 2rem !important;
  border-radius: var(--border-radius-md, 0.75rem) !important;
  border: 2px solid var(--border-color, #e2e8f0) !important;
  box-shadow: 0 4px 12px var(--shadow-color, rgba(74, 108, 247, 0.1)) !important;
}

.pagination-btn { 
  width: 48px !important; 
  height: 48px !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
  border: 2px solid var(--border-color, #e2e8f0) !important; 
  border-radius: var(--border-radius-sm, 0.5rem) !important; 
  cursor: pointer !important; 
  transition: all 0.3s ease !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  font-size: 1.1rem !important;
  color: var(--text-primary, #1e293b) !important;
}

.pagination-btn:hover:not(:disabled) { 
  background: var(--accent-color, #4a6cf7) !important; 
  border-color: var(--accent-color, #4a6cf7) !important; 
  color: white !important;
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(74, 108, 247, 0.3) !important;
}

.pagination-btn:disabled { 
  opacity: 0.4 !important; 
  cursor: not-allowed !important;
  transform: none !important;
}

.pagination-info { 
  font-weight: 600 !important;
  color: var(--text-primary, #1e293b) !important;
  font-size: 1.1rem !important;
  padding: 0 1rem !important;
}

/* 模态框样式增强 */
.modal-overlay { 
  position: fixed !important; 
  top: 0 !important; 
  left: 0 !important; 
  right: 0 !important; 
  bottom: 0 !important; 
  background: rgba(0, 0, 0, 0.7) !important; 
  backdrop-filter: blur(12px) !important; 
  display: flex !important; 
  align-items: center !important; 
  justify-content: center !important; 
  z-index: 1400 !important; 
  animation: modalFadeIn 0.4s ease-out !important;
  padding: 20px !important;
}

@keyframes modalFadeIn { 
  from { opacity: 0; backdrop-filter: blur(0px); } 
  to { opacity: 1; backdrop-filter: blur(12px); } 
}

.modal-container { 
  background: var(--bg-primary, #ffffff) !important; 
  border-radius: var(--border-radius-md, 0.75rem) !important; 
  box-shadow: 0 25px 80px rgba(0, 0, 0, 0.25) !important; 
  width: 100% !important; 
  max-width: 520px !important; 
  max-height: calc(100vh - 40px) !important;
  overflow: hidden !important; 
  animation: modalSlideIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
  border: 2px solid var(--border-color, #e2e8f0) !important;
}

@keyframes modalSlideIn { 
  from { opacity: 0; transform: scale(0.8) translateY(-20px); } 
  to { opacity: 1; transform: scale(1) translateY(0); } 
}

.modal-header { 
  display: flex !important; 
  justify-content: space-between !important; 
  align-items: center !important; 
  padding: 2rem 2.5rem !important; 
  border-bottom: 2px solid var(--border-color, #e2e8f0) !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
}

.modal-header h2 { 
  display: flex !important; 
  align-items: center !important; 
  gap: 1rem !important; 
  margin: 0 !important; 
  font-size: 1.6rem !important;
  color: var(--text-primary, #1e293b) !important;
  font-weight: 700 !important;
}

.modal-close { 
  background: transparent !important; 
  border: none !important; 
  font-size: 1.6rem !important; 
  cursor: pointer !important; 
  color: var(--text-secondary, #64748b) !important; 
  transition: all 0.3s ease !important;
  width: 40px !important;
  height: 40px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  border-radius: 50% !important;
}

.modal-close:hover { 
  color: #ef4444 !important; 
  transform: rotate(90deg) scale(1.1) !important;
  background: rgba(239, 68, 68, 0.1) !important;
}

.modal-body { 
  padding: 2.5rem !important;
  overflow-y: auto !important;
  max-height: 60vh !important;
}

.modal-footer { 
  display: flex !important; 
  justify-content: flex-end !important; 
  align-items: center !important; 
  gap: 1.25rem !important; 
  padding: 2rem 2.5rem !important; 
  border-top: 2px solid var(--border-color, #e2e8f0) !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
}

.confirmation-modal .modal-header .confirmation-title { 
  color: var(--accent-color, #4a6cf7) !important; 
}

.confirmation-modal .modal-header .confirmation-title i { 
  color: #f59e0b !important;
}

/* 表单样式增强 */
.form-group { 
  margin-bottom: 2rem !important; 
}

.form-group label { 
  display: block !important; 
  margin-bottom: 0.75rem !important; 
  font-weight: 600 !important; 
  color: var(--text-primary, #1e293b) !important;
  font-size: 1.05rem !important;
}

.form-group textarea {
  width: 100% !important;
  padding: 1rem 1.25rem !important;
  border: 2px solid var(--border-color, #e2e8f0) !important;
  border-radius: var(--border-radius-sm, 0.5rem) !important;
  background: var(--bg-secondary, #f7f9fc) !important;
  transition: all 0.3s ease !important;
  resize: vertical !important;
  min-height: 120px !important;
  font-family: inherit !important;
  font-size: 1rem !important;
  line-height: 1.6 !important;
  color: var(--text-primary, #1e293b) !important;
}

.form-group textarea:focus {
  outline: none !important;
  border-color: var(--accent-color, #4a6cf7) !important;
  background: var(--bg-primary, #ffffff) !important;
  box-shadow: 0 0 0 4px rgba(74, 108, 247, 0.1) !important;
  transform: translateY(-1px) !important;
}

.form-group textarea::placeholder {
  color: var(--text-secondary, #64748b) !important;
  font-style: italic !important;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .moderation-container {
    padding: 1rem !important;
  }
  
  .page-header { 
    flex-direction: column !important; 
    align-items: stretch !important;
    padding: 1.5rem !important;
    gap: 1.5rem !important;
  }
  
  .filter-tabs { 
    width: 100% !important; 
    overflow-x: auto !important; 
    justify-content: flex-start !important;
    gap: 0.5rem !important;
  }
  
  .filter-btn {
    font-size: 0.9rem !important;
    padding: 0.75rem 1.25rem !important;
  }
  
  .moderation-card-header {
    padding: 1.25rem !important;
    flex-direction: column !important;
    text-align: center !important;
    gap: 1rem !important;
  }
  
  .moderation-card-body {
    padding: 1.5rem !important;
  }
  
  .moderation-card-actions {
    flex-direction: column !important;
    gap: 1rem !important;
    padding: 1.25rem !important;
  }
  
  .btn {
    width: 100% !important;
    justify-content: center !important;
  }
  
  .modal-container {
    margin: 1rem !important;
    max-width: calc(100vw - 2rem) !important;
  }
  
  .modal-header,
  .modal-body,
  .modal-footer {
    padding: 1.5rem !important;
  }
  
  .modal-header h2 {
    font-size: 1.4rem !important;
  }
  
  .modal-footer {
    flex-direction: column !important;
    gap: 1rem !important;
  }
  
  .modal-footer .btn {
    width: 100% !important;
  }
  
  .pagination-wrapper {
    margin-top: 2rem !important;
  }
  
  .pagination {
    flex-direction: column !important;
    gap: 1rem !important;
    padding: 1.5rem !important;
  }
  
  .pagination-info {
    order: -1 !important;
    text-align: center !important;
  }
  
  .notification {
    min-width: 280px !important;
    margin: 0 1rem !important;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 1.8rem !important;
  }
  
  .page-subtitle {
    font-size: 1rem !important;
  }
  
  .content-type-icon {
    width: 44px !important;
    height: 44px !important;
    font-size: 1.2rem !important;
  }
  
  .content-title {
    font-size: 1.1rem !important;
  }
  
  .status-badge {
    padding: 0.4rem 0.8rem !important;
    font-size: 0.8rem !important;
  }
  
  .filter-btn {
    padding: 0.625rem 1rem !important;
    font-size: 0.85rem !important;
  }
  
  .notification {
    min-width: 250px !important;
    padding: 12px 16px !important;
  }
  
  .notification-icon {
    font-size: 1.1rem !important;
  }
  
  .notification p {
    font-size: 0.9rem !important;
  }
}

/* 额外的视觉增强 */
.moderation-card::before {
  content: '' !important;
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  height: 4px !important;
  background: linear-gradient(90deg, var(--accent-color, #4a6cf7), var(--accent-color-hover, #3b57d6)) !important;
  transform: scaleX(0) !important;
  transition: transform 0.3s ease !important;
  transform-origin: left !important;
}

.moderation-card {
  position: relative !important;
}

.moderation-card:hover::before {
  transform: scaleX(1) !important;
}

/* 加载动画增强 */
.spinner::after {
  content: '' !important;
  position: absolute !important;
  top: 50% !important;
  left: 50% !important;
  width: 20px !important;
  height: 20px !important;
  margin: -10px 0 0 -10px !important;
  border-radius: 50% !important;
  background: var(--accent-color, #4a6cf7) !important;
  animation: pulse 1.5s ease-in-out infinite !important;
}

@keyframes pulse {
  0%, 100% { transform: scale(0.8); opacity: 0.5; }
  50% { transform: scale(1.2); opacity: 1; }
}

/* 滚动条样式 */
.modal-body::-webkit-scrollbar {
  width: 8px !important;
}

.modal-body::-webkit-scrollbar-track {
  background: var(--bg-secondary, #f7f9fc) !important;
  border-radius: 4px !important;
}

.modal-body::-webkit-scrollbar-thumb {
  background: var(--border-color, #e2e8f0) !important;
  border-radius: 4px !important;
  transition: background 0.3s ease !important;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: var(--text-secondary, #64748b) !important;
}

/* 焦点状态增强 */
.filter-btn:focus,
.btn:focus,
.pagination-btn:focus {
  outline: 3px solid rgba(74, 108, 247, 0.3) !important;
  outline-offset: 2px !important;
}

.form-group textarea:focus {
  outline: 3px solid rgba(74, 108, 247, 0.3) !important;
  outline-offset: 2px !important;
}

/* 禁用状态增强 */
.btn:disabled {
  background: var(--bg-secondary, #f7f9fc) !important;
  color: var(--text-secondary, #64748b) !important;
  border-color: var(--border-color, #e2e8f0) !important;
  box-shadow: none !important;
}

/* 文本选择样式 */
::selection {
  background: rgba(74, 108, 247, 0.2) !important;
  color: var(--text-primary, #1e293b) !important;
}

::-moz-selection {
  background: rgba(74, 108, 247, 0.2) !important;
  color: var(--text-primary, #1e293b) !important;
}

/* 图标动画增强 */
.btn i,
.filter-btn i,
.notification-icon {
  transition: transform 0.3s ease !important;
}

.btn:hover i,
.filter-btn:hover i {
  transform: scale(1.1) !important;
}

.btn:active i,
.filter-btn:active i {
  transform: scale(0.95) !important;
}

/* 成功状态特殊样式 */
.status-approved.content-type-icon {
  background: linear-gradient(135deg, #10b981, #059669) !important;
  animation: successPulse 2s ease-in-out infinite !important;
}

@keyframes successPulse {
  0%, 100% { box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
  50% { box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5); }
}

/* 拒绝状态特殊样式 */
.status-rejected.content-type-icon {
  background: linear-gradient(135deg, #ef4444, #dc2626) !important;
  animation: errorShake 0.5s ease-in-out !important;
}

@keyframes errorShake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-2px); }
  75% { transform: translateX(2px); }
}

/* 待审核状态特殊样式 */
.status-pending.content-type-icon {
  background: linear-gradient(135deg, #f59e0b, #d97706) !important;
  animation: pendingBlink 1.5s ease-in-out infinite !important;
}

@keyframes pendingBlink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

/* 深色模式适配 */
@media (prefers-color-scheme: dark) {
  .moderation-container {
    --text-primary: #f8fafc;
    --text-secondary: #cbd5e1;
    --bg-primary: #1e293b;
    --bg-secondary: #0f172a;
    --bg-hover: #334155;
    --border-color: #475569;
  }
}

/* 高对比度模式适配 */
@media (prefers-contrast: high) {
  .moderation-card {
    border-width: 3px !important;
  }
  
  .btn {
    border-width: 3px !important;
    font-weight: 700 !important;
  }
  
  .status-badge {
    border: 2px solid rgba(255, 255, 255, 0.8) !important;
  }
}

/* 减少动画模式适配 */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  
  .moderation-card:hover {
    transform: none !important;
  }
  
  .btn:hover {
    transform: none !important;
  }
}

/* 打印样式 */
@media print {
  .notification-container,
  .modal-overlay,
  .moderation-card-actions,
  .pagination-wrapper {
    display: none !important;
  }
  
  .moderation-card {
    border: 2px solid #000 !important;
    break-inside: avoid !important;
    margin-bottom: 1rem !important;
  }
  
  .page-header {
    border-bottom: 3px solid #000 !important;
  }
}
</style>