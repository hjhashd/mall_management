<template>
  <div class="filter-sidebar" :class="{ 'is-collapsed': isCollapsed }">
    <div class="sidebar-header" @click="toggleCollapse">
      <h2><i class="fas fa-filter"></i> 筛选内容</h2>
      <i class="fas toggle-icon" :class="isCollapsed ? 'fa-chevron-right' : 'fa-chevron-left'"></i>
    </div>

    <div class="sidebar-content" v-if="!isCollapsed">
      <div class="form-group">
        <label for="filter-category" class="form-label">按分类筛选</label>
        <select id="filter-category" class="form-control" v-model="filterConditions.category" @change="emitFilterChange">
          <option value="">所有分类</option>
          <option value="智能硬件">智能硬件</option>
          <option value="数码影音">数码影音</option>
          <option value="设计软件">设计软件</option>
          <option value="极客外设">极客外设</option>
          <option value="生活科技">生活科技</option>
        </select>
      </div>

      <div class="form-group">
        <label for="filter-keyword" class="form-label">关键词搜索</label>
        <input
            type="text"
            id="filter-keyword"
            class="form-control"
            placeholder="搜索标题或内容"
            v-model="filterConditions.keyword"
            @input="emitFilterChange"
        />
      </div>

      <div class="form-group">
        <label class="form-label">按点赞数</label>
        <div class="radio-group">
          <input type="radio" id="likes-all" value="" v-model="filterConditions.minLikes" @change="emitFilterChange" checked />
          <label for="likes-all">所有</label>
          <input type="radio" id="likes-10" value="10" v-model="filterConditions.minLikes" @change="emitFilterChange" />
          <label for="likes-10">10+</label>
          <input type="radio" id="likes-50" value="50" v-model="filterConditions.minLikes" @change="emitFilterChange" />
          <label for="likes-50">50+</label>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['update-filters', 'update-collapse']);

const isCollapsed = ref(false);

const filterConditions = ref({
  category: '',
  keyword: '',
  minLikes: '',
});

const emitFilterChange = () => {
  emit('update-filters', filterConditions.value);
};

const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
  emit('update-collapse', isCollapsed.value);
};
</script>

<style scoped>
.filter-sidebar {
  width: var(--sidebar-width);
  background: var(--color-surface);
  border-radius: var(--radius-large);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--color-border);
  position: sticky;
  top: 40px;
  align-self: flex-start;
  transition: all var(--transition-slow);
  overflow: hidden;
  flex-shrink: 0;
}

.filter-sidebar.is-collapsed {
  width: 0;
  padding: var(--spacing-base) 0;
  border-color: transparent;
  background: transparent;
  box-shadow: none;
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  margin-bottom: var(--spacing-large);
}

.sidebar-header h2 {
  color: var(--color-text-primary);
  font-weight: 600;
  font-size: 1.2rem;
  display: flex;
  align-items: center;
  gap: 12px;
  white-space: nowrap;
}

.sidebar-header h2 i {
  color: var(--color-primary);
}

.toggle-icon {
  color: var(--color-text-secondary);
  transition: var(--transition-medium);
}

.sidebar-content {
  opacity: 1;
  transition: opacity var(--transition-medium) ease;
}

.filter-sidebar.is-collapsed .sidebar-content {
  opacity: 0;
}

/* Form elements are styled globally */
.radio-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.radio-group input[type="radio"] {
  display: none;
}

.radio-group label {
  background: var(--color-primary-light);
  padding: 8px 16px;
  border-radius: var(--radius-small);
  cursor: pointer;
  transition: var(--transition-medium);
  color: var(--color-primary);
  font-weight: 500;
  border: 1px solid transparent;
  text-align: center;
}

.radio-group label:hover {
  border-color: var(--color-primary);
  background: var(--color-surface);
}

.radio-group input[type="radio"]:checked + label {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px rgba(94, 106, 210, 0.3);
}

@media (max-width: 991px) {
  .filter-sidebar {
    width: 100%;
    position: static;
  }
}
</style>

