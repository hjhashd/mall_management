<template>
  <div class="category-management-container">
    <!-- 页面标题区域 -->
    <div class="page-header animate-fade-in">
      <div class="header-content">
        <h1>分类管理</h1>
        <p>管理商品分类层级结构和显示状态</p>
      </div>
      <div class="header-actions">
        <button class="action-btn primary" @click="openAddModal()">
          <i class="fas fa-plus"></i>添加顶级分类
        </button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid animate-slide-up" style="--delay: 0.1s;">
      <div class="stat-card" style="--delay: 0.1s;">
        <div class="card-icon icon-primary"><i class="fas fa-sitemap"></i></div>
        <div class="card-content">
          <p class="card-title">总分类数</p>
          <h2 class="card-value">{{ stats.total }}</h2>
        </div>
      </div>
      <div class="stat-card" style="--delay: 0.2s;">
        <div class="card-icon icon-success"><i class="fas fa-eye"></i></div>
        <div class="card-content">
          <p class="card-title">显示中</p>
          <h2 class="card-value">{{ stats.visible }}</h2>
        </div>
      </div>
      <div class="stat-card" style="--delay: 0.3s;">
        <div class="card-icon icon-warning"><i class="fas fa-eye-slash"></i></div>
        <div class="card-content">
          <p class="card-title">已隐藏</p>
          <h2 class="card-value">{{ stats.hidden }}</h2>
        </div>
      </div>
      <div class="stat-card" style="--delay: 0.4s;">
        <div class="card-icon icon-info"><i class="fas fa-layer-group"></i></div>
        <div class="card-content">
          <p class="card-title">顶级分类</p>
          <h2 class="card-value">{{ categories.length }}</h2>
        </div>
      </div>
    </div>

    <!-- 分类树容器 -->
    <div class="tree-container animate-slide-up" style="--delay: 0.5s;">
      <div class="tree-header">
        <h3>分类层级结构</h3>
        <div class="tree-actions">
          <button class="tree-action-btn" @click="fetchCategories" title="刷新">
            <i class="fas fa-sync-alt"></i>
          </button>
        </div>
      </div>

      <div class="tree-content">
        <ul class="category-list">
          <li v-if="loading" class="no-data"><p>加载中...</p></li>
          <li v-else-if="categories.length === 0" class="no-data">
            <div class="empty-state">
              <i class="fas fa-folder-open"></i>
              <p>暂无分类数据</p>
              <button class="action-btn primary small" @click="openAddModal()">
                <i class="fas fa-plus"></i>创建第一个分类
              </button>
            </div>
          </li>
          <CategoryNode
              v-for="(category, index) in categories"
              :key="category.categoryId"
              :category="category"
              :level="0"
              @edit="openEditModal"
              @delete="confirmDelete"
              @add-child="openAddModal"
              class="animate-slide-up"
              :style="`--delay: ${0.6 + index * 0.05}s`"
          />
        </ul>
      </div>
    </div>

    <!-- 添加/编辑弹窗 -->
    <div v-if="isModalOpen" class="modal-overlay animate-fade-in" @click.self="closeModal">
      <div class="modal-content animate-scale-up">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? '编辑分类' : '添加分类' }}</h2>
          <button class="modal-close" @click="closeModal"><i class="fas fa-times"></i></button>
        </div>

        <form @submit.prevent="handleSubmit" class="modal-form">
          <div class="form-group">
            <label for="categoryName"><i class="fas fa-tag"></i>分类名称</label>
            <input id="categoryName" v-model="currentCategory.categoryName" type="text" placeholder="请输入分类名称" required class="form-input">
          </div>

          <div class="form-group">
            <label for="parentId"><i class="fas fa-sitemap"></i>父级分类</label>
            <select id="parentId" v-model="currentCategory.parentId" :disabled="isSubCategory" class="form-select">
              <option :value="0">无 (顶级分类)</option>
              <option v-for="cat in flatCategories" :key="cat.categoryId" :value="cat.categoryId">
                {{ '—'.repeat(cat.level || 0) + ' ' + cat.categoryName }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label for="sortOrder"><i class="fas fa-sort-numeric-down"></i>排序权重</label>
            <input id="sortOrder" v-model.number="currentCategory.sortOrder" type="number" placeholder="数值越大排序越靠前" class="form-input">
          </div>

          <div class="form-group form-group-switch">
            <label for="isShow" class="switch-label"><i class="fas fa-eye"></i>是否显示</label>
            <label class="modern-switch">
              <input id="isShow" v-model="currentCategory.isShow" type="checkbox">
              <span class="switch-slider"></span>
            </label>
          </div>

          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="closeModal"><i class="fas fa-times"></i>取消</button>
            <button type="submit" class="btn-confirm" :disabled="submitting">
              <i :class="submitting ? 'fas fa-spinner fa-spin' : 'fas fa-check'"></i>{{ isEditing ? '更新' : '创建' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import CategoryNode from './CategoryNode.vue';
// 导入API函数
// [!code --]
// import { getCategories, createCategory, updateCategory, deleteCategory } from '@/api/product.js';
// [!code ++]
import { getCategoriesTree, createCategory, updateCategory, deleteCategory } from '@/api/product.js';

const categories = ref([]);
const loading = ref(true);
const submitting = ref(false);
const isModalOpen = ref(false);
const isEditing = ref(false);
const isSubCategory = ref(false);
const currentCategory = reactive({
  categoryId: null,
  parentId: 0,
  categoryName: '',
  sortOrder: 0,
  isShow: true,
});

// --- 数据获取与处理 ---
const fetchCategories = async () => {
  loading.value = true;
  try {
    // [!code --]
    // const response = await getCategories();
    // [!code ++]
    // 修复：调用正确的获取树形分类的API
    const response = await getCategoriesTree();
    if (response.data.success) {
      categories.value = response.data.data;
    } else {
      // 在这里处理错误，例如弹窗提示
      console.error("获取分类失败:", response.data.message);
      categories.value = [];
    }
  } catch (error) {
    console.error("API请求错误:", error);
    categories.value = [];
  } finally {
    loading.value = false;
  }
};

// 将树形结构扁平化，用于下拉列表
const flattenTree = (nodes, level = 0) => {
  let result = [];
  for (const node of nodes) {
    result.push({ ...node, level });
    if (node.children && node.children.length > 0) {
      result = result.concat(flattenTree(node.children, level + 1));
    }
  }
  return result;
};

const flatCategories = computed(() => flattenTree(categories.value));

// 统计数据
const stats = computed(() => {
  const flatList = flatCategories.value;
  return {
    total: flatList.length,
    // 修复：确保 c.isShow 是布尔值进行判断，避免 null 或 0 导致的问题
    visible: flatList.filter(c => c.isShow === true || c.isShow === 1).length,
    hidden: flatList.filter(c => c.isShow === false || c.isShow === 0 || c.isShow === null).length,
  };
});

onMounted(() => {
  fetchCategories();
});

// --- 方法 ---
const resetCurrentCategory = () => {
  currentCategory.categoryId = null;
  currentCategory.parentId = 0;
  currentCategory.categoryName = '';
  currentCategory.sortOrder = 0;
  currentCategory.isShow = true;
};

const openAddModal = (parentCategory = null) => {
  resetCurrentCategory();
  isEditing.value = false;
  if (parentCategory && parentCategory.categoryId) {
    currentCategory.parentId = parentCategory.categoryId;
    isSubCategory.value = true;
  } else {
    isSubCategory.value = false;
  }
  isModalOpen.value = true;
};

const openEditModal = (category) => {
  isEditing.value = true;
  isSubCategory.value = !!category.parentId;
  // 从category对象中拷贝属性到currentCategory
  Object.assign(currentCategory, {
    categoryId: category.categoryId,
    parentId: category.parentId || 0,
    categoryName: category.categoryName,
    sortOrder: category.sortOrder,
    // 修复：将传入的值强制转换为布尔型，确保开关组件状态正确
    isShow: !!category.isShow,
  });
  isModalOpen.value = true;
};

const closeModal = () => {
  isModalOpen.value = false;
};

const handleSubmit = async () => {
  submitting.value = true;
  try {
    let response;
    // 准备提交的数据
    const payload = { ...currentCategory };

    if (isEditing.value) {
      response = await updateCategory(payload.categoryId, payload);
    } else {
      response = await createCategory(payload);
    }

    if (response.data.success) {
      // 成功后刷新列表并关闭弹窗
      fetchCategories();
      closeModal();
      // 在这里可以添加一个成功提示
    } else {
      // 处理API返回的错误
      console.error("操作失败:", response.data.message);
    }
  } catch (error) {
    console.error("API请求错误:", error);
  } finally {
    submitting.value = false;
  }
};

const confirmDelete = async (categoryId) => {
  // 建议使用UI库的Modal组件代替 window.confirm
  if (window.confirm('确定要删除这个分类吗？其所有子分类也会被删除。')) {
    try {
      const response = await deleteCategory(categoryId);
      if (response.data.success) {
        fetchCategories(); // 刷新列表
      } else {
        console.error("删除失败:", response.data.message);
      }
    } catch (error) {
      console.error("API请求错误:", error);
    }
  }
};
</script>


<style scoped>
/* 整体容器 */
.category-management-container {
  padding: 0;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary);
}

/* 页面标题区域 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  padding: 1.5rem 0;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.header-content h1 {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary, #fff);
  margin: 0 0 0.5rem 0;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff) 0%, var(--accent-color-hover, #7c3aed) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-content p {
  font-size: 1rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0;
  opacity: 0.9;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  font-weight: 500;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
  position: relative;
  overflow: hidden;
}

.action-btn.primary {
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
  box-shadow: 0 4px 12px var(--shadow-color, rgba(159, 120, 255, 0.3));
}

.action-btn.secondary {
  background: var(--bg-primary, rgba(255, 255, 255, 0.1));
  color: var(--text-primary, #fff);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.2));
}

.action-btn.small {
  padding: 0.5rem 1rem;
  font-size: 0.8rem;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px var(--shadow-color, rgba(0, 0, 0, 0.15));
}

/* 统计卡片网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  -webkit-backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15));
  border-color: var(--accent-color, #9f78ff);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.stat-card:hover::before {
  left: 100%;
}

.card-icon {
  font-size: 1.5rem;
  padding: 1rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  color: white;
}

.card-icon.icon-primary {
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
}

.card-icon.icon-success {
  background: linear-gradient(135deg, #10b981, #059669);
}

.card-icon.icon-warning {
  background: linear-gradient(135deg, #f59e0b, #d97706);
}

.card-icon.icon-info {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
}

.card-title {
  font-size: 0.875rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0 0 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.card-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary, #fff);
  margin: 0 0 0.5rem;
  line-height: 1.2;
}

.card-trend {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.card-trend.positive { color: #10b981; }
.card-trend.negative { color: #ef4444; }
.card-trend.neutral { color: var(--text-secondary, #a0a0b0); }

/* 分类树容器 */
.tree-container {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  backdrop-filter: var(--backdrop-filter, blur(10px));
  -webkit-backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  overflow: hidden;
  margin-bottom: 2rem;
}

.tree-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.tree-header h3 {
  color: var(--text-primary, #fff);
  font-size: 1.125rem;
  margin: 0;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tree-header h3::before {
  content: '';
  width: 4px;
  height: 20px;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  border-radius: 2px;
}

.tree-actions {
  display: flex;
  gap: 0.5rem;
}

.tree-action-btn {
  width: 36px;
  height: 36px;
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.2));
  border-radius: var(--border-radius-sm, 6px);
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  color: var(--text-secondary, #a0a0b0);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
}

.tree-action-btn:hover {
  background: var(--accent-color, #9f78ff);
  color: white;
  border-color: var(--accent-color, #9f78ff);
  transform: scale(1.05);
}

.tree-content {
  padding: 1.5rem;
}

.category-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.no-data {
  text-align: center;
  padding: 3rem 2rem;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  color: var(--text-secondary, #a0a0b0);
}

.empty-state i {
  font-size: 3rem;
  opacity: 0.5;
}

.empty-state p {
  font-size: 1.125rem;
  margin: 0;
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1400;
  padding: 1rem;
}

.modal-content {
  background: var(--bg-primary, #fff);
  border-radius: var(--border-radius-md, 16px);
  width: 100%;
  max-width: 500px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary, #333);
  margin: 0;
}

.modal-close {
  width: 32px;
  height: 32px;
  border: none;
  background: var(--bg-secondary, rgba(0, 0, 0, 0.05));
  border-radius: 50%;
  color: var(--text-secondary, #666);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-speed, 0.3s) ease;
}

.modal-close:hover {
  background: var(--danger-color, #ef4444);
  color: white;
  transform: scale(1.1);
}

.modal-form {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  font-weight: 500;
  color: var(--text-primary, #333);
  font-size: 0.875rem;
}

.form-input,
.form-select {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 1px solid var(--border-color, #e0e0e0);
  border-radius: var(--border-radius-sm, 8px);
  font-size: 0.875rem;
  background: var(--bg-secondary, #f8f9fa);
  color: var(--text-primary, #333);
  transition: all var(--transition-speed, 0.3s) ease;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: var(--accent-color, #9f78ff);
  box-shadow: 0 0 0 3px var(--shadow-color, rgba(159, 120, 255, 0.1));
  background: var(--bg-primary, #fff);
}

.form-input::placeholder {
  color: var(--text-secondary, rgba(0, 0, 0, 0.4));
}

.form-group-switch {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 2rem;
}

.switch-label {
  margin-bottom: 0 !important;
}

/* 现代化开关样式 */
.modern-switch {
  position: relative;
  display: inline-block;
  width: 52px;
  height: 28px;
}

.modern-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.switch-slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--border-color, #ccc);
  transition: 0.3s;
  border-radius: 28px;
}

.switch-slider:before {
  position: absolute;
  content: "";
  height: 22px;
  width: 22px;
  left: 3px;
  bottom: 3px;
  background: white;
  transition: 0.3s;
  border-radius: 50%;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

input:checked + .switch-slider {
  background: var(--accent-color, #9f78ff);
}

input:checked + .switch-slider:before {
  transform: translateX(24px);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.btn-cancel,
.btn-confirm {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
}

.btn-cancel {
  background: var(--bg-secondary, #e5e7eb);
  color: var(--text-secondary, #4b5563);
  border: 1px solid var(--border-color, #d1d5db);
}

.btn-cancel:hover {
  background: var(--border-color, #d1d5db);
  transform: translateY(-1px);
}

.btn-confirm {
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
  box-shadow: 0 4px 12px var(--shadow-color, rgba(159, 120, 255, 0.3));
}

.btn-confirm:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px var(--shadow-color, rgba(159, 120, 255, 0.4));
}

/* 动画效果 */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.animate-slide-up {
  opacity: 0;
  animation: slideUp 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  animation-delay: var(--delay, 0s);
}

@keyframes scaleUp {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.animate-scale-up {
  animation: scaleUp 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .header-actions {
    justify-content: stretch;
  }

  .action-btn {
    flex: 1;
    justify-content: center;
  }

  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .modal-content {
    margin: 1rem;
    max-width: calc(100vw - 2rem);
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .header-content h1 {
    font-size: 1.5rem;
  }

  .card-value {
    font-size: 1.5rem;
  }
}

/* 主题适配优化 */
@media (prefers-reduced-motion: reduce) {
  .animate-fade-in,
  .animate-slide-up,
  .animate-scale-up,
  .stat-card,
  .tree-action-btn,
  .action-btn {
    animation: none;
    transition: none;
  }
}

/* 深色主题优化 */
[data-theme="glass"] .category-management-container,
[data-theme="tech"] .category-management-container {
  --form-bg: rgba(255, 255, 255, 0.05);
  --form-border: rgba(255, 255, 255, 0.2);
}

/* 浅色主题优化 */
[data-theme="default"] .category-management-container,
[data-theme="fresh"] .category-management-container,
[data-theme="google"] .category-management-container {
  --form-bg: rgba(0, 0, 0, 0.02);
  --form-border: rgba(0, 0, 0, 0.1);
}
</style>
