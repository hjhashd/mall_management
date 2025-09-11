<template>
  <!-- 根容器现在只负责布局 -->
  <div class="message-management-container">
    <!-- 筛选区域子组件 -->
    <MessageFilterSection
        :filter-form="filterForm"
        @open-send-message="openSendMessageModal"
        @refresh-messages="refreshMessages"
        @search-messages="searchMessages"
        @reset-filter="resetFilter"
        @update-filter-form="handleFilterFormUpdate"
    />

    <!-- 列表区域子组件 -->
    <MessageListSection
        :message-list="messageList"
        :loading="loading"
        :pagination="pagination"
        :selected-messages="selectedMessages"
        :current-message="currentMessage"
        :sending="sending"
        :saving-as-draft="savingAsDraft"
        :dialog-title="dialogTitle"
        :message-form="messageForm"
        :message-form-errors="messageFormErrors"
        :is-send-modal-visible="showSendMessageModal"
        :is-detail-modal-visible="showMessageDetailModal"
        @toggle-select-all="toggleSelectAll"
        @toggle-select-message="toggleSelectMessage"
        @prev-page="prevPage"
        @next-page="nextPage"
        @go-to-page="goToPage"
        @view-message="viewMessage"
        @edit-message="editMessage"
        @delete-message="deleteMessageHandler"
        @save-as-draft="saveAsDraft"
        @send-message="sendMessageHandler"
        @close-modal="closeModal"
        :get-message-type-class="getMessageTypeClass"
        :get-message-type-name="getMessageTypeName"
        :get-status-badge-class="getStatusBadgeClass"
        :get-status-name="getStatusName"
        :format-date="formatDate"
    />

    <!-- 自定义Toast提示框 -->
    <transition name="toast-fade">
      <div v-if="showToast" :class="['custom-toast', `toast-${toastType}`]">
        <div class="toast-content">
          <i :class="getToastIcon()"></i>
          <span v-html="toastMessage"></span>
        </div>
        <button type="button" class="toast-close-btn" @click="showToast = false">&times;</button>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue';
import dayjs from 'dayjs';
// 【关键改动 1】: 导入 saveMessage，移除 createMessage 和 updateMessage
import { fetchMessages, saveMessage, deleteMessage } from '@/api/message';
import MessageFilterSection from './MessageFilterSection.vue';
import MessageListSection from './MessageListSection.vue';
import { useNotificationStore } from '@/stores/notificationStore';

// --- 数据状态 ---
const loading = ref(false);
const sending = ref(false);
const savingAsDraft = ref(false);
const showSendMessageModal = ref(false);
const showMessageDetailModal = ref(false);
const messageList = ref([]);
const selectedMessages = ref([]);
const currentMessage = ref({});
const pagination = reactive({ currentPage: 1, pageSize: 10, total: 0 });
const notificationStore = useNotificationStore();
const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success');
const filterForm = reactive({ type: '', status: '', startDate: '', endDate: '' });
const messageForm = reactive({ id: null, type: '', title: '', content: '', recipients: [], scheduledTime: '' });
const messageFormErrors = reactive({ type: '', title: '', content: '', recipients: '' });
const dialogTitle = ref('发送新消息');

// --- 方法 ---
const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;
  setTimeout(() => { showToast.value = false; }, 3000);
};

const getToastIcon = () => ({
  success: 'fas fa-check-circle',
  error: 'fas fa-exclamation-circle',
  info: 'fas fa-info-circle'
}[toastType.value] || 'fas fa-info-circle');

const openSendMessageModal = () => {
  dialogTitle.value = '发送新消息';
  resetMessageForm();
  showSendMessageModal.value = true;
};

const resetMessageForm = () => {
  messageForm.id = null;
  messageForm.type = '';
  messageForm.title = '';
  messageForm.content = '';
  messageForm.recipients = [];
  messageForm.scheduledTime = '';
  Object.keys(messageFormErrors).forEach(key => { messageFormErrors[key] = ''; });
};

const refreshMessages = () => loadMessages();
const searchMessages = () => { pagination.currentPage = 1; loadMessages(); };
const resetFilter = () => {
  Object.assign(filterForm, { type: '', status: '', startDate: '', endDate: '' });
  pagination.currentPage = 1;
  loadMessages();
};

const loadMessages = async () => {
  loading.value = true;
  try {
    const params = {
      page: pagination.currentPage - 1,
      size: pagination.pageSize,
      type: filterForm.type || undefined,
      status: filterForm.status || undefined,
      startDate: filterForm.startDate ? dayjs(filterForm.startDate).format('YYYY-MM-DDTHH:mm:ss') : undefined,
      endDate: filterForm.endDate ? dayjs(filterForm.endDate).format('YYYY-MM-DDTHH:mm:ss') : undefined,
    };
    const response = await fetchMessages(params);
    messageList.value = response.data.data.content || [];
    pagination.total = response.data.data.page.totalElements || 0;
  } catch (error) {
    console.error('加载消息列表失败:', error);
    showToastMessage('加载消息列表失败: ' + (error.message || '未知错误'), 'error');
  } finally {
    loading.value = false;
  }
};

const toggleSelectAll = (event) => {
  if (event.target.checked) {
    selectedMessages.value = messageList.value.map(msg => msg.messageId);
  } else {
    selectedMessages.value = [];
  }
};

const toggleSelectMessage = (messageId) => {
  const index = selectedMessages.value.indexOf(messageId);
  if (index > -1) {
    selectedMessages.value.splice(index, 1);
  } else {
    selectedMessages.value.push(messageId);
  }
};

const prevPage = () => {
  if (pagination.currentPage > 1) {
    pagination.currentPage--;
    loadMessages();
  }
};

const nextPage = () => {
  if (pagination.currentPage < Math.ceil(pagination.total / pagination.pageSize)) {
    pagination.currentPage++;
    loadMessages();
  }
};

const goToPage = (page) => {
  if (page !== pagination.currentPage) {
    pagination.currentPage = page;
    loadMessages();
  }
};

const viewMessage = (message) => {
  currentMessage.value = message;
  showMessageDetailModal.value = true;
};

const editMessage = (message) => {
  dialogTitle.value = '编辑消息';
  Object.assign(messageForm, {
    id: message.messageId,
    type: message.type,
    title: message.title,
    content: message.content,
    recipients: message.recipients,
    scheduledTime: message.scheduledTime ? dayjs(message.scheduledTime).format('YYYY-MM-DDTHH:mm') : '',
  });
  showSendMessageModal.value = true;
};

const deleteMessageHandler = async (message) => {
  if (confirm(`确定要删除消息"${message.title}"吗？`)) {
    try {
      await deleteMessage(message.messageId);
      showToastMessage('消息删除成功', 'success');
      loadMessages();
    } catch (error) {
      console.error('删除消息失败:', error);
      showToastMessage('删除消息失败: ' + (error.message || '未知错误'), 'error');
    }
  }
};

const validateForm = () => {
  let isValid = true;
  Object.keys(messageFormErrors).forEach(key => { messageFormErrors[key] = ''; });
  if (!messageForm.type) { messageFormErrors.type = '请选择消息类型'; isValid = false; }
  if (!messageForm.title.trim()) { messageFormErrors.title = '请输入消息标题'; isValid = false; }
  if (!messageForm.content.trim()) { messageFormErrors.content = '请输入消息内容'; isValid = false; }
  if (messageForm.recipients.length === 0) { messageFormErrors.recipients = '请选择接收对象'; isValid = false; }
  return isValid;
};

// 【关键改动 2】: 统一保存处理函数，使用 saveMessage 替代 createMessage
const handleSave = async (status) => {
  if (!validateForm()) return;

  const isSavingDraft = status === 'draft';
  if (isSavingDraft) {
    savingAsDraft.value = true;
  } else {
    sending.value = true;
  }

  try {
    const payload = { ...messageForm, status };
    // 使用 saveMessage 统一处理新建和更新
    await saveMessage(payload);

    showToastMessage(isSavingDraft ? '草稿保存成功' : '消息发送成功', 'success');
    showSendMessageModal.value = false;
    loadMessages();
  } catch (error) {
    const action = isSavingDraft ? '保存草稿' : '发送消息';
    console.error(`${action}失败:`, error);
    showToastMessage(`${action}失败: ` + (error.message || '未知错误'), 'error');
  } finally {
    if (isSavingDraft) {
      savingAsDraft.value = false;
    } else {
      sending.value = false;
    }
  }
};

const saveAsDraft = () => handleSave('draft');
const sendMessageHandler = () => handleSave('sent');

const closeModal = (modalId) => {
  if (modalId === 'sendMessageModal') showSendMessageModal.value = false;
  if (modalId === 'messageDetailModal') showMessageDetailModal.value = false;
};

const handleFilterFormUpdate = (field, value) => {
  filterForm[field] = value;
};

// 工具方法
const getMessageTypeClass = (type) => ({
  system: 'success',
  user: 'primary',
  marketing: 'warning'
}[type] || 'secondary');

const getMessageTypeName = (type) => ({
  system: '系统通知',
  user: '用户消息',
  marketing: '营销推广'
}[type] || '未知类型');

const getStatusBadgeClass = (status) => ({
  sent: 'status-sent',
  draft: 'status-draft',
  failed: 'status-failed'
}[status] || 'status-unknown');

const getStatusName = (status) => ({
  sent: '已发送',
  draft: '草稿',
  failed: '发送失败'
}[status] || '未知状态');

const formatDate = (dateString) => (dateString ? dayjs(dateString).format('YYYY-MM-DD HH:mm') : '');

onMounted(loadMessages);

watch(() => notificationStore.newAdminMessage, (newMessageData) => {
  if (newMessageData) {
    showToastMessage(newMessageData.message || '消息列表有更新', 'info');
    loadMessages();
    notificationStore.clearNewAdminMessage();
  }
}, { deep: true });
</script>
<!-- 关键改动：移除 scoped，让样式可以应用到子组件 -->
<style>
/* ==================================
   1. 基础卡片与容器样式 (已使用CSS变量)
   ================================== */
.message-management-container {
  background-color: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
}

.action-bar-card,
.filter-card,
.list-card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-md);
  box-shadow: 0 4px 20px var(--shadow-color);
  margin-bottom: 24px;
  transition: all 0.3s ease;
}

.action-bar-card:hover,
.filter-card:hover,
.list-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 32px var(--shadow-color);
}

.action-bar-card { padding: 24px 32px; }
.filter-card { padding: 24px 32px; }

/* ==================================
   2. 筛选区 (MessageFilterSection)
   ================================== */
.action-bar-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; }
.action-bar-title { display: flex; align-items: center; gap: 12px; font-size: 24px; font-weight: 600; margin: 0; color: var(--text-primary); }
.action-bar-title i { color: var(--accent-color); }
.action-buttons { display: flex; gap: 12px; }

.filter-card-header { margin-bottom: 24px; }
.filter-card-title { display: flex; align-items: center; gap: 8px; font-size: 18px; font-weight: 500; margin: 0; color: var(--text-primary); }
.filter-card-title i { color: var(--accent-color); }

.form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 24px; align-items: flex-end; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group-wide { grid-column: span 2; }
.form-actions { display: flex; gap: 12px; }
.form-label { font-weight: 500; color: var(--text-secondary); font-size: 14px; }

.form-control {
  padding: 10px 14px;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  background: var(--bg-primary);
  color: var(--text-primary);
  font-size: 14px;
  transition: all 0.2s ease;
  outline: none;
}
.form-control:focus {
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px var(--shadow-color);
}
.date-range-input { display: flex; align-items: center; gap: 12px; }
.date-separator { color: var(--text-secondary); }

/* ==================================
   3. 列表区 (MessageListSection)
   ================================== */
.list-card { overflow: hidden; }
.list-card-header, .list-card-footer { padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; background: var(--bg-secondary); }
.list-card-header { border-bottom: 1px solid var(--border-color); }
.list-card-footer { border-top: 1px solid var(--border-color); }
.list-card-title { gap: 8px; }
.record-count { font-size: 14px; color: var(--text-secondary); }

.table-responsive { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; }
.data-table th, .data-table td { padding: 12px 16px; text-align: left; border-bottom: 1px solid var(--border-color); vertical-align: middle; }
.data-table th { background: var(--bg-secondary); font-weight: 500; color: var(--text-primary); font-size: 14px; }
.data-table td { font-size: 14px; color: var(--text-secondary); }
.data-table tbody tr:hover { background-color: var(--bg-hover); }
.selected-row { background-color: var(--bg-hover) !important; }

.checkbox-col { width: 40px; }
.content-col { max-width: 250px; }
.count-col, .status-col, .actions-col { text-align: center; }
.actions-col { width: 150px; }
.time-col { width: 160px; }
.text-center { text-align: center; }

.form-check-input { width: 16px; height: 16px; }
.title-cell { display: flex; align-items: center; gap: 8px; }
.content-truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 250px; }
.time-text { color: var(--text-secondary); }

.type-badge, .status-badge, .count-badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 500; display: inline-block; }
.type-success { background: rgba(22, 163, 74, 0.1); color: #16a34a; }
.type-primary { background: rgba(37, 99, 235, 0.1); color: #2563eb; }
.type-warning { background: rgba(217, 119, 6, 0.1); color: #d97706; }
.status-sent { background: rgba(22, 163, 74, 0.1); color: #16a34a; }
.status-draft { background: rgba(2, 132, 199, 0.1); color: #0284c7; }
.status-failed { background: rgba(220, 38, 38, 0.1); color: #dc2626; }
.count-badge { background: rgba(67, 56, 202, 0.1); color: #4338ca; }

.action-buttons { display: flex; gap: 8px; justify-content: center; }
.action-btn { width: 32px; height: 32px; border: none; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s ease; background: var(--bg-secondary); color: var(--text-secondary); }
.action-btn:hover { background: var(--bg-hover); color: var(--accent-color); }

.state-cell { text-align: center; padding: 48px 0; color: var(--text-secondary); }
.state-cell > * { display: block; margin: 0 auto; }
.empty-icon { font-size: 48px; margin-bottom: 16px; opacity: 0.5; }
.spinner { width: 24px; height: 24px; border: 3px solid var(--border-color); border-top-color: var(--accent-color); border-radius: 50%; animation: spin 1s linear infinite; }
.spinner-sm { width: 16px; height: 16px; border-width: 2px; }
@keyframes spin { to { transform: rotate(360deg); } }

.page-size-selector { display: flex; align-items: center; gap: 8px; font-size: 14px; color: var(--text-secondary); }
.page-size-select { padding: 4px 8px; border-radius: var(--border-radius-sm); border: 1px solid var(--border-color); background: var(--bg-primary); color: var(--text-primary); }
.pagination-controls { display: flex; list-style: none; margin: 0; padding: 0; gap: 4px; }
.pagination-controls a { display: block; min-width: 32px; height: 32px; line-height: 32px; text-align: center; border-radius: var(--border-radius-sm); text-decoration: none; color: var(--text-secondary); background: var(--bg-primary); border: 1px solid var(--border-color); transition: all 0.2s ease; }
.pagination-controls li.active a, .pagination-controls a:hover { background: var(--accent-color); color: white; border-color: var(--accent-color); }
.pagination-controls li.disabled a { opacity: 0.5; pointer-events: none; }

/* ==================================
   4. 模态框 (Modal)
   ================================== */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); display: flex; align-items: center; justify-content: center; z-index: 9999; backdrop-filter: var(--backdrop-filter); }
.modal-container { background: var(--bg-primary); border-radius: var(--border-radius-md); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); width: 90%; max-width: 800px; display: flex; flex-direction: column; max-height: 90vh; }
.modal-container.modal-sm { max-width: 500px; }
.modal-header { padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); }
.modal-title { font-size: 18px; font-weight: 600; margin: 0; display: flex; align-items: center; gap: 8px; color: var(--text-primary); }
.modal-close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-secondary); }
.modal-body { padding: 24px; overflow-y: auto; }
.modal-footer { padding: 16px 24px; display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--border-color); background: var(--bg-secondary); }
.modal-fade-enter-active, .modal-fade-leave-active { transition: opacity 0.3s ease; }
.modal-fade-enter-from, .modal-fade-leave-to { opacity: 0; }
.modal-fade-enter-active .modal-container, .modal-fade-leave-active .modal-container { transition: transform 0.3s ease; }
.modal-fade-enter-from .modal-container, .modal-fade-leave-to .modal-container { transform: scale(0.95); }

.message-form { display: flex; flex-direction: column; gap: 16px; }
.form-group label { font-weight: 500; font-size: 14px; color: var(--text-primary); }
.form-group .required { color: var(--danger-color); }
.form-group input, .form-group select, .form-group textarea { width: 100%; padding: 10px 14px; border: 1px solid var(--border-color); border-radius: var(--border-radius-sm); font-size: 14px; background: var(--bg-secondary); color: var(--text-primary); }
.form-group select[multiple] { height: 120px; }
.form-text { font-size: 12px; color: var(--text-secondary); }
.is-invalid { border-color: var(--danger-color) !important; }
.invalid-feedback { font-size: 12px; color: var(--danger-color); }

.detail-grid { display: grid; gap: 16px; }
.detail-item { display: grid; grid-template-columns: 100px 1fr; gap: 8px; align-items: start; }
.detail-item strong { color: var(--text-primary); }
.detail-item.content-item { grid-template-columns: 1fr; }
.content-box { background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--border-radius-sm); padding: 12px; margin-top: 4px; white-space: pre-wrap; word-break: break-all; }

/* ==================================
   5. 通用按钮与Toast
   ================================== */
.btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 10px 20px; border: 1px solid transparent; border-radius: var(--border-radius-sm); font-weight: 500; font-size: 14px; cursor: pointer; transition: all 0.2s ease; text-decoration: none; }
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-primary { background: var(--accent-color); color: white; }
.btn-primary:hover:not(:disabled) { background: var(--accent-color-hover); }
.btn-secondary { background: var(--bg-secondary); color: var(--text-primary); border-color: var(--border-color); }
.btn-secondary:hover:not(:disabled) { background: var(--bg-hover); }
.btn-outline { background: transparent; color: var(--text-secondary); border-color: var(--border-color); }
.btn-outline:hover:not(:disabled) { background: var(--bg-hover); color: var(--accent-color); border-color: var(--accent-color); }

.custom-toast { position: fixed; bottom: 20px; right: 20px; padding: 12px 20px; border-radius: var(--border-radius-md); color: #fff; display: flex; align-items: center; justify-content: space-between; min-width: 300px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15); z-index: 10000; }
.toast-success { background-color: #28a745; }
.toast-error { background-color: #dc3545; }
.toast-info { background-color: #17a2b8; }
.toast-content { display: flex; align-items: center; }
.toast-content i { margin-right: 10px; }
.toast-close-btn { background: none; border: none; color: white; font-size: 20px; line-height: 1; cursor: pointer; opacity: 0.8; padding: 0 0 0 15px; }
.toast-close-btn:hover { opacity: 1; }
.toast-fade-enter-active, .toast-fade-leave-active { transition: opacity 0.3s ease, transform 0.3s ease; }
.toast-fade-enter-from, .toast-fade-leave-to { opacity: 0; transform: translateY(20px); }

/* 响应式设计 */
@media (max-width: 992px) {
  .form-group-wide { grid-column: span 1; }
}
@media (max-width: 768px) {
  .action-bar-header { flex-direction: column; align-items: stretch; }
  .form-row { grid-template-columns: 1fr; gap: 16px; }
  .form-actions { flex-direction: column; }
  .btn { width: 100%; }
}
</style>
