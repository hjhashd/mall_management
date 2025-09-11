<template>
  <div>
    <!-- 消息列表 -->
    <div class="list-card">
      <div class="list-card-header">
        <h5 class="list-card-title">
          <i class="fas fa-list"></i>
          <span>消息列表</span>
        </h5>
        <span class="record-count">共 {{ pagination.total }} 条记录</span>
      </div>
      <div class="table-responsive">
        <table class="data-table">
          <thead>
          <tr>
            <th class="checkbox-col">
              <input
                  type="checkbox"
                  class="form-check-input"
                  :checked="selectedMessages.length === messageList.length && messageList.length > 0"
                  @change="$emit('toggle-select-all', $event)"
              />
            </th>
            <th>消息标题</th>
            <th class="content-col">消息内容</th>
            <th class="count-col">接收人数</th>
            <th class="status-col">发送状态</th>
            <th class="time-col">发送时间</th>
            <th class="actions-col">操作</th>
          </tr>
          </thead>
          <tbody>
          <tr v-if="loading">
            <td colspan="7" class="state-cell">
              <div class="spinner"></div>
              <span>加载中...</span>
            </td>
          </tr>
          <tr v-else-if="messageList.length === 0">
            <td colspan="7" class="state-cell">
              <i class="fas fa-inbox empty-icon"></i>
              <span>暂无消息数据</span>
            </td>
          </tr>
          <tr
              v-else
              v-for="message in messageList"
              :key="message.messageId"
              :class="{ 'selected-row': selectedMessages.includes(message.messageId) }"
          >
            <td>
              <input
                  type="checkbox"
                  class="form-check-input"
                  :checked="selectedMessages.includes(message.messageId)"
                  @change="$emit('toggle-select-message', message.messageId)"
              />
            </td>
            <td>
              <div class="title-cell">
                <strong>{{ message.title }}</strong>
                <span :class="['type-badge', `type-${getMessageTypeClass(message.type)}`]">
                    {{ getMessageTypeName(message.type) }}
                  </span>
              </div>
            </td>
            <td>
              <div class="content-truncate" :title="message.content">
                {{ message.content }}
              </div>
            </td>
            <td class="text-center">
              <span class="count-badge">{{ message.recipientCount }}</span>
            </td>
            <td>
                <span :class="['status-badge', getStatusBadgeClass(message.status)]">
                  {{ getStatusName(message.status) }}
                </span>
            </td>
            <td>
              <small class="time-text">{{ formatDate(message.sendTime) }}</small>
            </td>
            <td>
              <div class="action-buttons">
                <button class="action-btn" @click="$emit('view-message', message)" title="查看">
                  <i class="fas fa-eye"></i>
                </button>
                <button v-if="message.status === 'draft'" class="action-btn" @click="$emit('edit-message', message)" title="编辑">
                  <i class="fas fa-edit"></i>
                </button>
                <button class="action-btn" @click="$emit('delete-message', message)" title="删除">
                  <i class="fas fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
      <!-- 分页 -->
      <div class="list-card-footer">
        <div class="page-size-selector">
          <span>每页显示</span>
          <select class="page-size-select" @change="onPageSizeChange">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="50">50</option>
          </select>
          <span>条</span>
        </div>
        <nav>
          <ul class="pagination-controls">
            <li :class="{ disabled: pagination.currentPage === 1 }">
              <a href="#" @click.prevent="$emit('prev-page')">&laquo;</a>
            </li>
            <li v-for="page in pageNumbers" :key="page" :class="{ active: page === pagination.currentPage }">
              <a href="#" @click.prevent="$emit('go-to-page', page)">{{ page }}</a>
            </li>
            <li :class="{ disabled: pagination.currentPage === totalPages }">
              <a href="#" @click.prevent="$emit('next-page')">&raquo;</a>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- 发送/编辑消息模态框 - 已移除 Teleport -->
    <transition name="modal-fade">
      <div v-if="isSendModalVisible" class="modal-overlay" @click.self="$emit('close-modal', 'sendMessageModal')">
        <div class="modal-container">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-paper-plane"></i>{{ dialogTitle }}</h5>
            <button class="modal-close-btn" @click="$emit('close-modal', 'sendMessageModal')">&times;</button>
          </div>
          <div class="modal-body">
            <form @submit.prevent class="message-form">
              <!-- 消息类型 -->
              <div class="form-group-with-label">
                <label class="form-label">消息类型 <span class="required">*</span></label>
                <select v-model="messageForm.type" :class="['form-control', { 'is-invalid': messageFormErrors.type }]">
                  <option value="">请选择消息类型</option>
                  <option value="system">系统通知</option>
                  <option value="user">用户消息</option>
                  <option value="marketing">营销推广</option>
                </select>
                <div class="invalid-feedback">{{ messageFormErrors.type }}</div>
              </div>
              <!-- 消息标题 -->
              <div class="form-group-with-label">
                <label class="form-label">消息标题 <span class="required">*</span></label>
                <input type="text" v-model="messageForm.title" placeholder="请输入消息标题" :class="['form-control', { 'is-invalid': messageFormErrors.title }]"/>
                <div class="invalid-feedback">{{ messageFormErrors.title }}</div>
              </div>
              <!-- 消息内容 -->
              <div class="form-group-with-label">
                <label class="form-label">消息内容 <span class="required">*</span></label>
                <textarea rows="5" v-model="messageForm.content" placeholder="请输入消息内容" :class="['form-control', { 'is-invalid': messageFormErrors.content }]"></textarea>
                <div class="invalid-feedback">{{ messageFormErrors.content }}</div>
              </div>
              <!-- 接收对象 -->
              <div class="form-group-with-label">
                <label class="form-label">接收对象 <span class="required">*</span></label>
                <select v-model="messageForm.recipients" multiple :class="['form-control', { 'is-invalid': messageFormErrors.recipients }]">
                  <option value="all">所有用户</option>
                  <option value="vip">VIP用户</option>
                  <option value="normal">普通用户</option>
                </select>
                <div class="form-text">按住 Ctrl/Command 键可多选</div>
                <div class="invalid-feedback">{{ messageFormErrors.recipients }}</div>
              </div>
              <!-- 定时发送 -->
              <div class="form-group-with-label">
                <label class="form-label">定时发送</label>
                <input type="datetime-local" v-model="messageForm.scheduledTime" class="form-control" />
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="$emit('close-modal', 'sendMessageModal')">取消</button>
            <button class="btn btn-outline" @click="$emit('save-as-draft')" :disabled="savingAsDraft">
              <span v-if="savingAsDraft" class="spinner-sm"></span>
              <i v-else class="fas fa-save"></i>
              保存草稿
            </button>
            <button class="btn btn-primary" @click="$emit('send-message')" :disabled="sending">
              <span v-if="sending" class="spinner-sm"></span>
              <i v-else class="fas fa-paper-plane"></i>
              发送消息
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- 消息详情模态框 - 已移除 Teleport -->
    <transition name="modal-fade">
      <div v-if="isDetailModalVisible" class="modal-overlay" @click.self="$emit('close-modal', 'messageDetailModal')">
        <div class="modal-container modal-sm">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-info-circle"></i>消息详情</h5>
            <button class="modal-close-btn" @click="$emit('close-modal', 'messageDetailModal')">&times;</button>
          </div>
          <div class="modal-body">
            <div class="detail-grid">
              <div class="detail-item">
                <div class="detail-label">消息标题：</div>
                <div class="detail-value">{{ currentMessage.title }}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">消息类型：</div>
                <div class="detail-value"><span :class="['type-badge', `type-${getMessageTypeClass(currentMessage.type)}`]">{{ getMessageTypeName(currentMessage.type) }}</span></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">发送状态：</div>
                <div class="detail-value"><span :class="['status-badge', getStatusBadgeClass(currentMessage.status)]">{{ getStatusName(currentMessage.status) }}</span></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">接收人数：</div>
                <div class="detail-value">{{ currentMessage.recipientCount }}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">发送时间：</div>
                <div class="detail-value">{{ formatDate(currentMessage.sendTime) }}</div>
              </div>
              <div class="detail-item full-width-item">
                <div class="detail-label">消息内容：</div>
                <div class="content-box">{{ currentMessage.content }}</div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="$emit('close-modal', 'messageDetailModal')">关闭</button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import {computed} from 'vue';

const props = defineProps({
  messageList: Array,
  loading: Boolean,
  pagination: Object,
  selectedMessages: Array,
  currentMessage: Object,
  sending: Boolean,
  savingAsDraft: Boolean,
  dialogTitle: String,
  messageForm: Object,
  messageFormErrors: Object,
  isSendModalVisible: Boolean,
  isDetailModalVisible: Boolean,
  getMessageTypeClass: Function,
  getMessageTypeName: Function,
  getStatusBadgeClass: Function,
  getStatusName: Function,
  formatDate: Function,
});

const emit = defineEmits([
  'toggle-select-all',
  'toggle-select-message',
  'prev-page',
  'next-page',
  'go-to-page',
  'view-message',
  'edit-message',
  'delete-message',
  'save-as-draft',
  'send-message',
  'close-modal',
  'update:pageSize'
]);

// 计算总页数
const totalPages = computed(() => Math.ceil(props.pagination.total / props.pagination.pageSize));

// 计算分页按钮
const pageNumbers = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let start = Math.max(1, props.pagination.currentPage - Math.floor(maxVisible / 2));
  let end = Math.min(totalPages.value, start + maxVisible - 1);
  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1);
  }
  for (let i = start; i <= end; i++) {
    pages.push(i);
  }
  return pages;
});

// 处理分页大小变化
const onPageSizeChange = (event) => {
  const pageSize = parseInt(event.target.value);
  emit('update:pageSize', pageSize);
};
</script>

<style scoped>
/*
  模态框样式 - 独立且有条理的设计
  这里移除了 Teleport，因此样式现在和组件模板在同一个作用域内。
*/

/* ==================================
   模态框基础结构 - 重置所有可能的全局影响
   ================================== */
.modal-overlay {
  /* 重置定位和层级 */
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
  z-index: 9999 !important;

  /* 背景和模糊效果 */
  background: linear-gradient(135deg, rgba(0, 0, 0, 0.4) 0%, rgba(0, 0, 0, 0.7) 100%) !important;
  -webkit-backdrop-filter: var(--backdrop-filter, blur(8px)) !important;
  backdrop-filter: var(--backdrop-filter, blur(8px)) !important;

  /* 布局 */
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;

  /* 内边距确保模态框与边框有距离 */
  padding: 20px !important;
  box-sizing: border-box !important;
}

.modal-container {
  /* 重置所有可能继承的样式 */
  position: relative !important;
  margin: 0 auto !important;

  /* 尺寸约束 */
  width: 100% !important;
  max-width: 800px !important;
  max-height: calc(100vh - 40px) !important; /* 确保顶部和底部都有20px边距 */

  /* 背景和边框 */
  background: var(--bg-primary, #ffffff) !important;
  border: 1px solid var(--border-color, rgba(226, 232, 240, 0.8)) !important;
  border-radius: var(--border-radius-md, 16px) !important;

  /* 阴影效果 - 多层次设计 */
  box-shadow:
    /* 主要阴影 */
      0 25px 50px rgba(0, 0, 0, 0.25),
        /* 主题色阴影 */
      0 10px 30px var(--shadow-color, rgba(74, 108, 247, 0.15)),
        /* 边框光晕 */
      0 0 0 1px var(--border-color, rgba(226, 232, 240, 0.5)),
        /* 内部高光 */
      inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;

  /* 布局 */
  display: flex !important;
  flex-direction: column !important;
  overflow: hidden !important;

  /* 字体和过渡 */
  font-family: var(--font-family-base, 'Inter', sans-serif) !important;
  transition: all var(--transition-speed, 0.3s) cubic-bezier(0.34, 1.56, 0.64, 1) !important;

  /* 重置可能的全局影响 */
  text-align: left !important;
  color: var(--text-primary, #1e293b) !important;
  line-height: 1.5 !important;
}

.modal-container.modal-sm {
  max-width: 500px !important;
}

/* ==================================
   模态框头部 - 清晰的视觉分层
   ================================== */
.modal-header {
  /* 重置和定位 */
  position: relative !important;
  flex-shrink: 0 !important;

  /* 间距 */
  padding: 24px 32px 20px 32px !important;

  /* 布局 */
  display: flex !important;
  justify-content: space-between !important;
  align-items: center !important;

  /* 背景 - 精致的渐变设计 */
  background: linear-gradient(135deg,
  var(--bg-secondary, #f7f9fc) 0%,
  var(--bg-primary, #ffffff) 100%) !important;

  /* 边框 */
  border-bottom: 2px solid var(--border-color, rgba(226, 232, 240, 0.6)) !important;
  border-radius: var(--border-radius-md, 16px) var(--border-radius-md, 16px) 0 0 !important;

  /* 细微装饰 */
  box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.05),
      inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
}

.modal-title {
  /* 重置 */
  margin: 0 !important;
  padding: 0 !important;

  /* 排版 */
  font-size: 22px !important;
  font-weight: 600 !important;
  line-height: 1.3 !important;
  color: var(--text-primary, #1e293b) !important;

  /* 布局 */
  display: flex !important;
  align-items: center !important;
  gap: 12px !important;

  /* 视觉效果 */
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.05) !important;
}

.modal-title i {
  font-size: 20px !important;
  color: var(--accent-color, #4a6cf7) !important;
  /* 图标发光效果 */
  filter: drop-shadow(0 0 6px var(--shadow-color, rgba(74, 108, 247, 0.3))) !important;
  transition: all 0.3s ease !important;
}

.modal-close-btn {
  /* 重置按钮样式 */
  background: none !important;
  border: none !important;
  padding: 0 !important;
  margin: 0 !important;

  /* 尺寸和布局 */
  width: 40px !important;
  height: 40px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;

  /* 外观 */
  font-size: 24px !important;
  color: var(--text-secondary, #64748b) !important;
  border-radius: var(--border-radius-sm, 8px) !important;
  cursor: pointer !important;

  /* 过渡效果 */
  transition: all 0.2s ease !important;

  /* 背景效果 */
  background: rgba(0, 0, 0, 0.05) !important;
}

.modal-close-btn:hover {
  color: var(--text-primary, #1e293b) !important;
  background: var(--bg-hover, rgba(74, 108, 247, 0.1)) !important;
  transform: scale(1.1) !important;
}

/* ==================================
   模态框主体 - 内容区域优化
   ================================== */
.modal-body {
  /* 重置和布局 */
  flex: 1 !important;
  overflow-y: auto !important;

  /* 间距 */
  padding: 32px !important;

  /* 背景 */
  background: var(--bg-primary, #ffffff) !important;

  /* 滚动条样式 */
  scrollbar-width: thin !important;
  scrollbar-color: var(--border-color, #e2e8f0) transparent !important;
}

.modal-body::-webkit-scrollbar {
  width: 6px !important;
}

.modal-body::-webkit-scrollbar-track {
  background: transparent !important;
}

.modal-body::-webkit-scrollbar-thumb {
  background: var(--border-color, #e2e8f0) !important;
  border-radius: 3px !important;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: var(--accent-color, #4a6cf7) !important;
}

/* ==================================
   模态框底部 - 操作区域
   ================================== */
.modal-footer {
  /* 重置和定位 */
  flex-shrink: 0 !important;

  /* 间距 */
  padding: 24px 32px !important;

  /* 布局 */
  display: flex !important;
  justify-content: flex-end !important;
  align-items: center !important;
  gap: 16px !important;

  /* 背景和边框 */
  background: var(--bg-secondary, #f7f9fc) !important;
  border-top: 2px solid var(--border-color, rgba(226, 232, 240, 0.6)) !important;
  border-radius: 0 0 var(--border-radius-md, 16px) var(--border-radius-md, 16px) !important;

  /* 装饰效果 */
  box-shadow:
      0 -1px 3px rgba(0, 0, 0, 0.05),
      inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
}

/* ==================================
   表单元素 - 统一的输入体验
   ================================== */
.message-form {
  display: grid !important;
  gap: 28px !important;
  width: 100% !important;
}

.form-group-with-label {
  display: flex !important;
  flex-direction: column !important;
  gap: 0 !important;
}

.form-label {
  /* 重置 */
  margin: 0 0 12px 0 !important;
  padding: 0 !important;

  /* 排版 */
  font-size: 15px !important;
  font-weight: 600 !important;
  color: var(--text-primary, #1e293b) !important;
  line-height: 1.4 !important;

  /* 视觉层次 */
  letter-spacing: 0.01em !important;
  text-transform: none !important;
}

.form-group-with-label .required {
  color: var(--danger-color, #ef4444) !important;
  font-weight: 700 !important;
  margin-left: 4px !important;
}

.form-control {
  /* 重置所有可能的全局样式 */
  appearance: none !important;
  -webkit-appearance: none !important;
  -moz-appearance: none !important;

  /* 尺寸和间距 */
  width: 100% !important;
  padding: 14px 18px !important;
  margin: 0 !important;

  /* 边框和背景 */
  border: 2px solid var(--border-color, #e2e8f0) !important;
  border-radius: var(--border-radius-sm, 10px) !important;
  background: var(--bg-primary, #ffffff) !important;

  /* 排版 */
  font-size: 15px !important;
  font-family: var(--font-family-base, 'Inter', sans-serif) !important;
  color: var(--text-primary, #1e293b) !important;
  line-height: 1.5 !important;

  /* 效果 */
  box-shadow:
      inset 0 1px 3px rgba(0, 0, 0, 0.06),
      0 1px 0 rgba(255, 255, 255, 0.1) !important;
  transition: all 0.2s ease !important;

  /* 重置 */
  outline: none !important;
  resize: vertical !important;
}

.form-control:focus {
  border-color: var(--accent-color, #4a6cf7) !important;
  box-shadow:
      0 0 0 4px var(--shadow-color, rgba(74, 108, 247, 0.15)),
      inset 0 1px 3px rgba(0, 0, 0, 0.06),
      0 2px 4px rgba(0, 0, 0, 0.1) !important;
  transform: translateY(-1px) !important;
}

.form-control:hover:not(:focus) {
  border-color: var(--accent-color, #4a6cf7) !important;
  box-shadow:
      inset 0 1px 3px rgba(0, 0, 0, 0.08),
      0 1px 2px rgba(0, 0, 0, 0.05) !important;
}

.form-control[multiple] {
  min-height: 140px !important;
  padding: 12px !important;
}

.form-control[multiple] option {
  padding: 10px 14px !important;
  margin: 3px 0 !important;
  border-radius: var(--border-radius-sm, 6px) !important;
  background: var(--bg-secondary, #f7f9fc) !important;
}

.form-text {
  font-size: 13px !important;
  color: var(--text-secondary, #64748b) !important;
  margin-top: 8px !important;
  font-style: italic !important;
  line-height: 1.4 !important;
}

.is-invalid {
  border-color: var(--danger-color, #ef4444) !important;
  box-shadow:
      0 0 0 4px rgba(239, 68, 68, 0.15),
      inset 0 1px 3px rgba(239, 68, 68, 0.1) !important;
}

.invalid-feedback {
  font-size: 14px !important;
  color: var(--danger-color, #ef4444) !important;
  margin-top: 8px !important;
  font-weight: 500 !important;
  display: flex !important;
  align-items: flex-start !important;
  gap: 6px !important;
  line-height: 1.4 !important;
}

.invalid-feedback::before {
  content: "⚠" !important;
  font-size: 16px !important;
  flex-shrink: 0 !important;
}

/* ==================================
   详情展示区域
   ================================== */
.detail-grid {
  display: grid !important;
  grid-template-columns: 1fr !important;
  gap: 24px !important;
  width: 100% !important;
}

.detail-item {
  display: grid !important;
  grid-template-columns: 120px 1fr !important;
  gap: 16px !important;
  align-items: flex-start !important;
  padding: 16px 0 !important;
  border-bottom: 1px solid var(--border-color, rgba(226, 232, 240, 0.5)) !important;
  font-size: 15px !important;
}

.detail-item:last-child {
  border-bottom: none !important;
}

.detail-label {
  color: var(--text-primary, #1e293b) !important;
  font-weight: 600 !important;
  font-size: 13px !important;
  text-transform: uppercase !important;
  letter-spacing: 0.5px !important;
  line-height: 1.4 !important;
}

.detail-value {
  color: var(--text-secondary, #64748b) !important;
  word-break: break-all !important;
  white-space: pre-wrap !important;
  line-height: 1.6 !important;
}

.full-width-item {
  grid-template-columns: 1fr !important;
  display: flex !important;
  flex-direction: column !important;
  gap: 12px !important;
}

.content-box {
  background: var(--bg-secondary, #f7f9fc) !important;
  border: 1px solid var(--border-color, #e2e8f0) !important;
  border-radius: var(--border-radius-sm, 10px) !important;
  padding: 20px !important;
  margin-top: 8px !important;
  white-space: pre-wrap !important;
  word-break: break-all !important;
  font-size: 14px !important;
  color: var(--text-secondary, #64748b) !important;
  line-height: 1.7 !important;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.05) !important;
}

/* ==================================
   按钮样式 - 精致的交互体验
   ================================== */
.modal-footer .btn {
  /* 重置 */
  appearance: none !important;
  -webkit-appearance: none !important;
  margin: 0 !important;
  text-decoration: none !important;

  /* 布局 */
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  gap: 10px !important;

  /* 尺寸 */
  padding: 14px 28px !important;
  min-width: 120px !important;
  height: auto !important;

  /* 边框 */
  border: 2px solid transparent !important;
  border-radius: var(--border-radius-sm, 10px) !important;

  /* 排版 */
  font-family: var(--font-family-base, 'Inter', sans-serif) !important;
  font-size: 15px !important;
  font-weight: 600 !important;
  text-align: center !important;
  line-height: 1.4 !important;

  /* 交互 */
  cursor: pointer !important;
  transition: all 0.2s ease !important;

  /* 阴影 */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1) !important;
  position: relative !important;
  overflow: hidden !important;
}

.modal-footer .btn:disabled {
  opacity: 0.6 !important;
  cursor: not-allowed !important;
  transform: none !important;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05) !important;
}

.modal-footer .btn:not(:disabled):hover {
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15) !important;
}

.modal-footer .btn:not(:disabled):active {
  transform: translateY(0) !important;
}

/* 按钮变体 */
.modal-footer .btn-primary {
  background: linear-gradient(135deg,
  var(--accent-color, #4a6cf7) 0%,
  var(--accent-color-hover, #3b57d6) 100%) !important;
  color: white !important;
  border-color: var(--accent-color, #4a6cf7) !important;
}

.modal-footer .btn-primary:not(:disabled):hover {
  background: linear-gradient(135deg,
  var(--accent-color-hover, #3b57d6) 0%,
  var(--accent-color, #4a6cf7) 100%) !important;
  box-shadow: 0 8px 25px var(--shadow-color, rgba(74, 108, 247, 0.4)) !important;
}

.modal-footer .btn-secondary {
  background: var(--bg-secondary, #f7f9fc) !important;
  color: var(--text-primary, #1e293b) !important;
  border-color: var(--border-color, #e2e8f0) !important;
}

.modal-footer .btn-secondary:not(:disabled):hover {
  background: var(--bg-hover, #eff4ff) !important;
  border-color: var(--accent-color, #4a6cf7) !important;
  color: var(--accent-color, #4a6cf7) !important;
}

.modal-footer .btn-outline {
  background: transparent !important;
  color: var(--text-secondary, #64748b) !important;
  border-color: var(--border-color, #e2e8f0) !important;
}

.modal-footer .btn-outline:not(:disabled):hover {
  background: var(--bg-hover, #eff4ff) !important;
  color: var(--accent-color, #4a6cf7) !important;
  border-color: var(--accent-color, #4a6cf7) !important;
}

/* ==================================
   动画优化
   ================================== */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity var(--transition-speed, 0.3s) cubic-bezier(0.34, 1.56, 0.64, 1) !important;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0 !important;
}

.modal-fade-enter-active .modal-container,
.modal-fade-leave-active .modal-container {
  transition: all var(--transition-speed, 0.3s) cubic-bezier(0.34, 1.56, 0.64, 1) !important;
}

.modal-fade-enter-from .modal-container,
.modal-fade-leave-to .modal-container {
  transform: scale(0.9) translateY(30px) !important;
  opacity: 0 !important;
}

/* ==================================
   加载状态
   ================================== */
.modal-footer .btn .spinner-sm {
  width: 16px !important;
  height: 16px !important;
  border: 2px solid currentColor !important;
  border-top-color: transparent !important;
  border-radius: 50% !important;
  animation: modal-spin 1s linear infinite !important;
}

@keyframes modal-spin {
  to {
    transform: rotate(360deg);
  }
}

/* ==================================
   响应式设计
   ================================== */
@media (max-width: 768px) {
  .modal-overlay {
    padding: 16px !important;
  }

  .modal-container {
    max-height: calc(100vh - 32px) !important;
  }

  .modal-header,
  .modal-body,
  .modal-footer {
    padding-left: 24px !important;
    padding-right: 24px !important;
  }

  .modal-footer {
    flex-direction: column !important;
    gap: 12px !important;
  }

  .modal-footer .btn {
    width: 100% !important;
    min-width: unset !important;
  }

  .detail-grid {
    gap: 20px !important;
  }

  .detail-item {
    grid-template-columns: 1fr !important;
    gap: 8px !important;
    padding: 12px 0 !important;
  }
}

@media (min-width: 769px) {
  .detail-grid {
    grid-template-columns: repeat(2, 1fr) !important;
    gap: 28px !important;
  }

  .full-width-item {
    grid-column: span 2 !important;
  }
}

/* ==================================
   主题特殊适配
   ================================== */
[data-theme="glass"] .modal-container {
  background: var(--bg-primary, rgba(30, 41, 59, 0.95)) !important;
  backdrop-filter: blur(20px) !important;
  border: 1px solid var(--border-color, rgba(148, 163, 184, 0.3)) !important;
}

[data-theme="tech"] .modal-container {
  border: 1px solid var(--accent-color, #00ffff) !important;
  box-shadow:
      0 0 30px var(--shadow-color, rgba(0, 255, 255, 0.3)),
      0 25px 50px rgba(0, 0, 0, 0.3) !important;
}

[data-theme="fresh"] .modal-container,
[data-theme="volcanic-orange"] .modal-container,
[data-theme="rose-gold"] .modal-container {
  box-shadow:
      0 25px 50px rgba(0, 0, 0, 0.15),
      0 10px 30px var(--shadow-color, rgba(5, 150, 105, 0.2)) !important;
}
</style>
