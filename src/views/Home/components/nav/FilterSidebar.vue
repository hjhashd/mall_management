<template>
  <div class="sidebar" :class="{ 'sidebar-collapsed': isCollapsed }">
    <button class="toggle-btn" @click="isCollapsed = !isCollapsed">
      <i class="fas fa-sliders-h" v-if="!isCollapsed"></i>
      <i class="fas fa-bars" v-else></i>
      <span v-if="!isCollapsed">收起筛选</span>
    </button>
    <div class="filter-section" v-if="!isCollapsed">
      <div class="filter-header">
        <h3><i class="fas fa-filter"></i>商品筛选</h3>
        <p>找到你心仪的商品</p>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-search"></i>关键词搜索</label>
        <div class="input-wrapper">
          <input v-model="filters.title" placeholder="输入商品标题...">
          <i class="fas fa-search input-icon"></i>
        </div>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-tag"></i>价格范围</label>
        <div class="range-inputs">
          <div class="input-wrapper">
            <input type="number" v-model.number="filters.priceMin" placeholder="最低价">
            <span class="currency">¥</span>
          </div>
          <div class="range-divider">~</div>
          <div class="input-wrapper">
            <input type="number" v-model.number="filters.priceMax" placeholder="最高价">
            <span class="currency">¥</span>
          </div>
        </div>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-list"></i>商品分类</label>
        <div class="select-wrapper">
          <select v-model="filters.category_id">
            <option value="">全部分类</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
          <i class="fas fa-chevron-down select-icon"></i>
        </div>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-star"></i>成色等级</label>
        <div class="condition-options">
          <label class="condition-item" v-for="condition in conditionOptions" :key="condition.value">
            <input type="radio" :value="condition.value" v-model="filters.condition" name="condition">
            <span class="condition-radio"></span>
            <span class="condition-text">{{ condition.label }}</span>
          </label>
        </div>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-box"></i>库存状态</label>
        <label class="checkbox-wrapper">
          <input type="checkbox" v-model="filters.inStock">
          <span class="checkbox-custom"></span>
          <span class="checkbox-text">仅显示有货商品</span>
        </label>
      </div>
      <div class="filter-group">
        <label><i class="fas fa-clock"></i>发布时间</label>
        <div class="time-chips">
          <button
              v-for="time in timeOptions"
              :key="time.value"
              :class="{ active: filters.timeRange === time.value }"
              @click="filters.timeRange = time.value"
              class="time-chip"
          >
            {{ time.label }}
          </button>
        </div>
      </div>
      <div class="filter-actions">
        <button class="apply-btn" @click="applyFilters">
          <i class="fas fa-check"></i>
          应用筛选
        </button>
        <button class="reset-btn" @click="resetFilters">
          <i class="fas fa-redo"></i>
          重置
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive} from 'vue';

// 接收父组件传递的属性
const props = defineProps({
  categories: {
    type: Array,
    required: true
  },
  initialFilters: {
    type: Object,
    default: () => ({
      title: '',
      category_id: '',
      priceMin: null,
      priceMax: null,
      condition: '',
      inStock: false,
      timeRange: '7'
    })
  }
});

// 定义 emits
const emit = defineEmits(['filter-applied', 'filters-reset']);

// 状态管理
const isCollapsed = ref(false);
const filters = reactive({ ...props.initialFilters });

// 选项数据
const conditionOptions = [
  { value: '', label: '全部' },
  { value: '1', label: '全新' },
  { value: '2', label: '95新' },
  { value: '3', label: '9成新' },
  { value: '4', label: '8成新' }
];

const timeOptions = [
  { value: '7', label: '最近7天' },
  { value: '30', label: '最近30天' },
  { value: '90', label: '最近3个月' },
  { value: null, label: '全部' }
];

// 方法
const applyFilters = () => {
  emit('filter-applied', { ...filters });
};

const resetFilters = () => {
  Object.assign(filters, {
    title: '',
    category_id: '',
    priceMin: null,
    priceMax: null,
    condition: '',
    inStock: false,
    timeRange: null,
  });
  emit('filters-reset');
};
</script>

<style scoped>
/* 侧边栏相关样式 */
.sidebar {
  width: 320px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  padding: 1.5rem;
  border-radius: 0 24px 24px 0;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: sticky;
  top: 20px;
  align-self: flex-start;
  max-height: calc(100vh - 40px);
  overflow-y: auto;
  z-index: 10;
  margin: 20px 0 20px 20px;
}

.sidebar-collapsed {
  width: 80px;
  padding: 1.5rem 1rem;
}

.toggle-btn {
  width: 100%;
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  color: white;
  border: none;
  padding: 0.875rem 1rem;
  border-radius: 16px;
  cursor: pointer;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.3);
}

.toggle-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

.filter-section {
  overflow: hidden;
}

.filter-header {
  text-align: center;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(99, 102, 241, 0.1));
  border-radius: 20px;
  border: 1px solid rgba(59, 130, 246, 0.1);
}

.filter-header h3 {
  color: #1e293b;
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.filter-header p {
  color: #64748b;
  margin: 0;
  font-size: 0.9rem;
}

.filter-group {
  margin-bottom: 1.5rem;
}

.filter-group label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  font-weight: 500;
  color: #374151;
  font-size: 0.9rem;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.8);
}

.input-wrapper input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  background: white;
}

.input-icon {
  position: absolute;
  right: 1rem;
  color: #9ca3af;
}

.currency {
  position: absolute;
  left: 1rem;
  color: #6b7280;
  font-weight: 500;
}

.range-inputs {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.range-inputs .input-wrapper {
  flex: 1;
}

.range-divider {
  color: #9ca3af;
  font-weight: 500;
}

.select-wrapper {
  position: relative;
}

.select-wrapper select {
  width: 100%;
  padding: 0.875rem 2.5rem 0.875rem 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 0.9rem;
  background: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  appearance: none;
  transition: all 0.3s ease;
}

.select-wrapper select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  background: white;
}

.select-icon {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #9ca3af;
  pointer-events: none;
}

.condition-options {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.condition-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: background 0.2s ease;
}

.condition-item:hover {
  background: rgba(59, 130, 246, 0.05);
}

.condition-item input[type="radio"] {
  display: none;
}

.condition-radio {
  width: 18px;
  height: 18px;
  border: 2px solid #d1d5db;
  border-radius: 50%;
  position: relative;
  transition: all 0.2s ease;
}

.condition-item input[type="radio"]:checked + .condition-radio {
  border-color: #3b82f6;
  background: #3b82f6;
}

.condition-item input[type="radio"]:checked + .condition-radio::after {
  content: '';
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.condition-text {
  color: #374151;
  font-size: 0.9rem;
}

.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: background 0.2s ease;
}

.checkbox-wrapper:hover {
  background: rgba(59, 130, 246, 0.05);
}

.checkbox-wrapper input[type="checkbox"] {
  display: none;
}

.checkbox-custom {
  width: 18px;
  height: 18px;
  border: 2px solid #d1d5db;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.checkbox-wrapper input[type="checkbox"]:checked + .checkbox-custom {
  border-color: #3b82f6;
  background: #3b82f6;
}

.checkbox-wrapper input[type="checkbox"]:checked + .checkbox-custom::after {
  content: '✓';
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.checkbox-text {
  color: #374151;
  font-size: 0.9rem;
}

.time-chips {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem;
}

.time-chip {
  padding: 0.5rem 0.75rem;
  border: 2px solid #e2e8f0;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.85rem;
  color: #374151;
}

.time-chip:hover {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.05);
}

.time-chip.active {
  border-color: #3b82f6;
  background: #3b82f6;
  color: white;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}

.filter-actions {
  display: flex;
  gap: 0.75rem;
  margin-top: 1rem;
}

.apply-btn, .reset-btn {
  flex: 1;
  padding: 0.875rem;
  border-radius: 12px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.apply-btn {
  background: linear-gradient(135deg, #10b981, #34d399);
  color: white;
  border: none;
  box-shadow: 0 4px 16px rgba(16, 185, 129, 0.2);
}

.apply-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
}

.reset-btn {
  background: rgba(255, 255, 255, 0.8);
  border: 2px solid #e2e8f0;
  color: #64748b;
}

.reset-btn:hover {
  background: white;
  border-color: #cbd5e1;
}

/* 响应式样式 */
@media (max-width: 1024px) {
  .sidebar {
    width: 260px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    width: 100%;
    position: static;
    margin: 0;
    border-radius: 0 0 24px 24px;
    max-height: none;
  }
}
</style>
