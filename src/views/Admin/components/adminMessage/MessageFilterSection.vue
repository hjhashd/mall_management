<template>
  <div class="filter-section-container">
    <!-- 顶部操作栏 -->
    <div class="action-bar-card">
      <div class="action-bar-header">
        <h2 class="action-bar-title">
          <i class="fas fa-envelope"></i>
          <span>消息管理</span>
        </h2>
        <div class="action-buttons">
          <button class="btn btn-primary" @click="$emit('open-send-message')">
            <i class="fas fa-plus"></i>
            <span>发送新消息</span>
          </button>
          <button class="btn btn-secondary" @click="$emit('refresh-messages')">
            <i class="fas fa-sync-alt"></i>
            <span>刷新</span>
          </button>
        </div>
      </div>
    </div>

    <!-- 筛选条件 -->
    <div class="filter-card">
      <div class="filter-card-header">
        <h5 class="filter-card-title">
          <i class="fas fa-filter"></i>
          <span>筛选条件</span>
        </h5>
      </div>
      <div class="filter-form">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">消息类型</label>
            <select
                class="form-control"
                :value="filterForm.type"
                @change="$emit('update-filter-form', 'type', $event.target.value)"
            >
              <option value="">全部类型</option>
              <option value="system">系统通知</option>
              <option value="user">用户消息</option>
              <option value="marketing">营销推广</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">发送状态</label>
            <select
                class="form-control"
                :value="filterForm.status"
                @change="$emit('update-filter-form', 'status', $event.target.value)"
            >
              <option value="">全部状态</option>
              <option value="sent">已发送</option>
              <option value="draft">草稿</option>
              <option value="failed">发送失败</option>
            </select>
          </div>
          <div class="form-group form-group-wide">
            <label class="form-label">时间范围</label>
            <div class="date-range-input">
              <input
                  type="date"
                  class="form-control"
                  :value="filterForm.startDate"
                  @change="$emit('update-filter-form', 'startDate', $event.target.value)"
                  placeholder="开始日期"
              />
              <span class="date-separator">至</span>
              <input
                  type="date"
                  class="form-control"
                  :value="filterForm.endDate"
                  @change="$emit('update-filter-form', 'endDate', $event.target.value)"
                  placeholder="结束日期"
              />
            </div>
          </div>
          <div class="form-group form-actions">
            <button type="button" class="btn btn-primary" @click="$emit('search-messages')">
              <i class="fas fa-search"></i>
              <span>搜索</span>
            </button>
            <button type="button" class="btn btn-outline" @click="$emit('reset-filter')">
              <i class="fas fa-undo"></i>
              <span>重置</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  filterForm: {
    type: Object,
    required: true,
  },
});

defineEmits([
  'open-send-message',
  'refresh-messages',
  'search-messages',
  'reset-filter',
  'update-filter-form'
]);
</script>

<!-- 已移除所有 style 标签 -->
