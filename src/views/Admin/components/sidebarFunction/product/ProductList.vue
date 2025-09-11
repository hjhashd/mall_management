<template>
  <div class="product-management-container animate-fade-in">
    <!-- 统计卡片区域 -->
    <div class="stats-grid">
      <!-- 统计卡片可以基于总数动态计算或由后端专门提供接口 -->
      <div class="stat-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-icon icon-total"><i class="fas fa-boxes"></i></div>
        <div class="card-content">
          <p class="card-title">商品总数</p>
          <h2 class="card-value">{{ pagination.total }}</h2>
          <span class="card-trend"><i class="fas fa-database"></i> 全部商品</span>
        </div>
      </div>
      <!-- 其他统计卡片可以根据需要添加逻辑 -->
    </div>

    <!-- 头部：标题和操作区 -->
    <div class="header-bar">
      <h1 class="page-title">商品列表管理</h1>
      <div class="actions-group">
        <div class="search-box">
          <i class="fas fa-search search-icon"></i>
          <input type="text" v-model="searchQuery" @keyup.enter="handleSearch" placeholder="搜索商品标题、ID或卖家ID...">
        </div>
        <select v-model="selectedCategory" class="filter-select" @change="handleSearch">
          <option value="">全部分类</option>
          <option v-for="cat in categories" :key="cat.categoryId" :value="cat.categoryId">{{ cat.categoryName }}</option>
        </select>
        <select v-model="selectedStatus" class="filter-select" @change="handleSearch">
          <option value="">全部状态</option>
          <option v-for="(label, value) in statusMap" :key="value" :value="value">{{ label }}</option>
        </select>
        <button class="add-btn" @click="addProduct">
          <i class="fas fa-plus"></i> 添加商品
        </button>
      </div>
    </div>

    <!-- 商品列表表格 -->
    <div class="product-table-card">
      <table class="product-table">
        <thead>
        <tr>
          <th>商品信息</th>
          <th>价格/库存</th>
          <th>状态/成色</th>
          <th>分类/卖家</th>
          <th>数据</th>
          <th>发布时间</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="loading">
          <td colspan="7" class="empty-state"><p>加载中...</p></td>
        </tr>
        <tr v-else-if="products.length === 0">
          <td colspan="7" class="empty-state">
            <i class="fas fa-box-open"></i>
            <p>没有找到匹配的商品</p>
          </td>
        </tr>
        <tr v-for="product in products" :key="product.productId" class="product-row">
          <td>
            <div class="product-info-cell">
              <img :src="product.imageUrl || 'https://placehold.co/60x60/33364a/a0a0b0?text=IMG'" class="product-image" alt="Product Image">
              <div class="product-details">
                <span class="product-title" :title="product.title">{{ product.title }}</span>
                <span class="product-id">ID: {{ product.productId }}</span>
              </div>
            </div>
          </td>
          <td>
            <div class="price-stock-cell">
              <span class="price">¥ {{ product.price.toFixed(2) }}</span>
              <span class="original-price" v-if="product.originalPrice">¥ {{ product.originalPrice.toFixed(2) }}</span>
              <span class="stock">库存: {{ product.stock }}</span>
            </div>
          </td>
          <td>
            <div class="status-condition-cell">
              <span class="status-badge" :class="getStatusClass(product.status)">{{ getStatusText(product.status) }}</span>
              <span class="condition-badge">{{ getConditionText(product.condition) }}</span>
            </div>
          </td>
          <td>
            <div class="category-seller-cell">
              <span class="category-name">{{ getCategoryName(product.categoryId) }}</span>
              <span class="seller-id">卖家ID: {{ product.sellerId }}</span>
            </div>
          </td>
          <td>
            <div class="data-cell">
              <span><i class="fas fa-eye"></i> {{ product.viewCount }}</span>
              <span><i class="fas fa-heart"></i> {{ product.favoriteCount }}</span>
            </div>
          </td>
          <td>{{ formatDate(product.createdAt) }}</td>
          <td>
            <div class="action-buttons">
              <button class="action-btn btn-view" @click="viewProduct(product)" title="查看详情"><i class="fas fa-eye"></i></button>
              <button class="action-btn btn-edit" @click="editProduct(product)" title="编辑"><i class="fas fa-pencil-alt"></i></button>
              <button class="action-btn" :class="product.isRecommended ? 'btn-unrecommend' : 'btn-recommend'" @click="handleToggleRecommendation(product)" :title="product.isRecommended ? '取消推荐' : '设为推荐'">
                <i :class="product.isRecommended ? 'fas fa-times' : 'fas fa-thumbs-up'"></i>
              </button>
              <button class="action-btn btn-delete" @click="handleDeleteProduct(product)" title="删除"><i class="fas fa-trash-alt"></i></button>
            </div>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

    <!-- 分页控件 -->
    <div class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1"><i class="fas fa-chevron-left"></i></button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页 (共 {{ pagination.total }} 条)</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages"><i class="fas fa-chevron-right"></i></button>
    </div>

    <!-- 添加/编辑商品模态框 -->
    <div v-if="showEditModal" class="modal-overlay" @click="closeEditModal">
      <div class="modal-content edit-modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editForm.productId ? '编辑商品' : '添加新商品' }}</h3>
          <button class="modal-close" @click="closeEditModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveProduct" class="edit-form">
            <div class="form-grid">
              <div class="form-item full-width">
                <label>商品标题 *</label>
                <input type="text" v-model="editForm.title" required>
              </div>
              <div class="form-item full-width">
                <label>商品描述</label>
                <textarea v-model="editForm.description" rows="4"></textarea>
              </div>
              <div class="form-item">
                <label>商品分类 *</label>
                <select v-model="editForm.categoryId" required>
                  <option disabled value="">请选择分类</option>
                  <option v-for="cat in categories" :key="cat.categoryId" :value="cat.categoryId">{{ cat.categoryName }}</option>
                </select>
              </div>
              <div class="form-item">
                <label>商品状态 *</label>
                <select v-model="editForm.status" required>
                  <option v-for="(label, value) in statusMap" :key="value" :value="parseInt(value)">{{ label }}</option>
                </select>
              </div>
              <div class="form-item">
                <label>当前售价 *</label>
                <input type="number" step="0.01" v-model.number="editForm.price" required>
              </div>
              <div class="form-item">
                <label>原价</label>
                <input type="number" step="0.01" v-model.number="editForm.originalPrice">
              </div>
              <div class="form-item">
                <label>库存数量 *</label>
                <input type="number" v-model.number="editForm.stock" required>
              </div>
              <div class="form-item">
                <label>成色等级 *</label>
                <select v-model="editForm.condition" required>
                  <option v-for="(label, value) in conditionMap" :key="value" :value="parseInt(value)">{{ label }}</option>
                </select>
              </div>
              <div class="form-item full-width">
                <label>商品位置</label>
                <input type="text" v-model="editForm.location">
              </div>
              <div class="form-item full-width">
                <label class="checkbox-label">
                  <input type="checkbox" v-model="editForm.isRecommended">
                  <span class="checkmark"></span>
                  设为推荐商品
                </label>
              </div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn-cancel" @click="closeEditModal">取消</button>
              <button type="submit" class="btn-save">保存</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { getAdminProducts, createProduct, updateProduct, adminDeleteProduct, getCategories, toggleRecommendation } from '@/api/product';

// --- 静态数据 ---
const statusMap = { 1: '上架', 2: '下架', 3: '售罄', 4: '审核中' };
const conditionMap = { 1: '全新', 2: '95新', 3: '9成新', 4: '8成新', 5: '7成新及以下' };

// --- 响应式状态管理 ---
const products = ref([]);
const categories = ref([]);
const loading = ref(true);

// 筛选条件
const searchQuery = ref('');
const selectedCategory = ref('');
const selectedStatus = ref('');

// 模态框
const showEditModal = ref(false);
const editForm = ref({});

// 分页
const pagination = ref({
  currentPage: 1,
  pageSize: 8,
  total: 0
});

// --- 计算属性 ---
const totalPages = computed(() => {
  if (pagination.value.total === 0) return 1;
  return Math.ceil(pagination.value.total / pagination.value.pageSize);
});

// --- API 调用和数据处理 ---
const fetchProducts = async () => {
  loading.value = true;
  try {
    const params = {
      page: pagination.value.currentPage,
      pageSize: pagination.value.pageSize,
      title: searchQuery.value,
      categoryId: selectedCategory.value,
      status: selectedStatus.value
    };
    const response = await getAdminProducts(params);
    if (response.data.success) {
      products.value = response.data.data.items;
      pagination.value.total = response.data.data.total;
    } else {
      console.error("获取商品失败:", response.data.message);
      // 在这里可以添加用户提示，例如使用 Element Plus 的 ElMessage
    }
  } catch (error) {
    console.error("API请求错误:", error);
  } finally {
    loading.value = false;
  }
};

const fetchCategories = async () => {
  try {
    const response = await getCategories();
    if (response.data.success) {
      categories.value = response.data.data;
    }
  } catch (error) {
    console.error("获取分类失败:", error);
  }
};

// --- 生命周期钩子 ---
onMounted(() => {
  fetchProducts();
  fetchCategories();
});

// --- 监听筛选条件变化 ---
watch([searchQuery, selectedCategory, selectedStatus], () => {
  pagination.value.currentPage = 1; // 筛选条件变化时回到第一页
  fetchProducts();
});

// --- 事件处理方法 ---
const handleSearch = () => {
  pagination.value.currentPage = 1;
  fetchProducts();
}

const addProduct = () => {
  editForm.value = {
    title: '',
    description: '',
    categoryId: '',
    status: 4, // 默认审核中
    price: 0,
    originalPrice: 0,
    stock: 1,
    condition: 1, // 默认全新
    location: '',
    isRecommended: false,
  };
  showEditModal.value = true;
};

const editProduct = (product) => {
  // 创建一个深拷贝以避免直接修改列表中的数据
  editForm.value = { ...product };
  showEditModal.value = true;
};

const saveProduct = async () => {
  try {
    let response;
    if (editForm.value.productId) { // 编辑
      response = await updateProduct(editForm.value.productId, editForm.value);
    } else { // 新增
      response = await createProduct(editForm.value);
    }

    if (response.data.success) {
      // alert(editForm.value.productId ? '更新成功' : '添加成功');
      closeEditModal();
      fetchProducts(); // 刷新列表
    } else {
      alert('操作失败: ' + response.data.message);
    }
  } catch (error) {
    console.error("保存商品失败:", error);
    alert('操作失败，请查看控制台');
  }
};

const handleDeleteProduct = async (product) => {
  if (confirm(`确定要删除商品 "${product.title}" 吗？`)) {
    try {
      const response = await adminDeleteProduct(product.productId);
      if (response.data.success) {
        // alert('删除成功');
        // 如果当前页是最后一页且只有一条数据，删除后应跳转到前一页
        if (products.value.length === 1 && pagination.value.currentPage > 1) {
          pagination.value.currentPage--;
        }
        fetchProducts(); // 刷新列表
      } else {
        alert('删除失败: ' + response.data.message);
      }
    } catch (error) {
      console.error("删除商品失败:", error);
      alert('删除失败，请查看控制台');
    }
  }
};

const handleToggleRecommendation = async (product) => {
  try {
    const newRecommendationStatus = !product.isRecommended;
    const response = await toggleRecommendation(product.productId, newRecommendationStatus);
    if(response.data.success){
      // 直接更新前端状态，避免重新请求整个列表，优化体验
      product.isRecommended = newRecommendationStatus;
    } else {
      alert('操作失败: ' + response.data.message);
    }
  } catch (error) {
    console.error("推荐操作失败:", error);
    alert('操作失败，请查看控制台');
  }
};


const closeEditModal = () => {
  showEditModal.value = false;
  editForm.value = {};
};

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
    fetchProducts();
  }
};

// --- 格式化和辅助方法 ---
const getCategoryName = (id) => categories.value.find(c => c.categoryId === id)?.categoryName || '未知分类';
const getStatusText = (status) => statusMap[status] || '未知';
const getConditionText = (condition) => conditionMap[condition] || '未知';

const getStatusClass = (status) => ({
  1: 'status-on-shelf', 2: 'status-off-shelf', 3: 'status-sold-out', 4: 'status-pending'
}[status]);

const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN') + ' ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
};

const viewProduct = (product) => {
  alert(`查看商品详情 (ID: ${product.productId}):\n标题: ${product.title}`);
};

</script>

<style scoped>
/* 样式保持不变，这里省略以减少篇幅 */
/* 继承自 AddressManagement 的基础样式，并做商品化调整 */
:root {
  --bg-primary: rgba(40, 42, 60, 0.5);
  --bg-secondary: rgba(255, 255, 255, 0.05);
  --bg-hover: rgba(255, 255, 255, 0.03);
  --bg-modal: #2a2c3d;
  --border-color: rgba(255, 255, 255, 0.1);
  --text-primary: #f0f0f5;
  --text-secondary: #a0a0b0;
  --accent-color: #9f78ff;
  --shadow-color: rgba(0, 0, 0, 0.1);
  --border-radius-sm: 8px;
  --border-radius-md: 16px;
  --transition-speed: 0.3s;
  --backdrop-filter: blur(10px);
}

.product-management-container {
  padding: 2rem;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary);
}

.animate-fade-in { animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.animate-slide-up { animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards var(--delay, 0s); }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

/* 统计卡片 */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
.stat-card { 
  background: var(--bg-primary, rgba(255, 255, 255, 0.9)); 
  border: 1px solid var(--border-color, #e2e8f0); 
  border-radius: var(--border-radius-md, 16px); 
  padding: 1.5rem; 
  backdrop-filter: var(--backdrop-filter, none); 
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1)); 
  transition: all var(--transition-speed, 0.3s) ease; 
  display: flex; 
  align-items: center; 
  gap: 1.5rem; 
}
.stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15)); border-color: var(--accent-color, #4a6cf7); }
.card-icon { font-size: 2rem; padding: 1rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; width: 60px; height: 60px; }
.icon-total { background: linear-gradient(135deg, rgba(159, 120, 255, 0.2), rgba(124, 58, 237, 0.1)); color: var(--accent-color, #9f78ff); border: 1px solid rgba(159, 120, 255, 0.3); }
.icon-on-shelf { background: linear-gradient(135deg, rgba(46, 204, 113, 0.2), rgba(39, 174, 96, 0.1)); color: #2ecc71; border: 1px solid rgba(46, 204, 113, 0.3); }
.icon-stock { background: linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(14, 165, 233, 0.1)); color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.3); }
.icon-pending { background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.1)); color: #fbbf24; border: 1px solid rgba(251, 191, 36, 0.3); }
.card-content { flex: 1; }
.card-title { font-size: 0.875rem; color: var(--text-secondary, #64748b); margin: 0 0 0.75rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; }
.card-value { font-size: 2rem; font-weight: 700; color: var(--text-primary, #1e293b); margin: 0 0 0.5rem; line-height: 1.2; }
.card-trend { font-size: 0.875rem; display: flex; align-items: center; gap: 0.25rem; color: var(--text-secondary, #64748b); }
.card-trend.positive { color: #10b981; }
.card-trend.pending { color: #fbbf24; }

/* 头部栏 */
.header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem; }
.page-title { font-size: 1.75rem; font-weight: 700; color: var(--text-primary, #1e293b); margin: 0; }
.actions-group { display: flex; align-items: center; gap: 1rem; }
.search-box { position: relative; }
.search-icon { position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--text-secondary, #64748b); }
.search-box input, .filter-select { 
  background: var(--bg-secondary, #f7f9fc); 
  border: 1px solid var(--border-color, #e2e8f0); 
  border-radius: var(--border-radius-sm, 8px); 
  padding: 0.6rem 1rem 0.6rem 2.5rem; 
  color: var(--text-primary, #1e293b); 
  font-size: 0.9rem; 
  transition: all var(--transition-speed, 0.3s) ease; 
}
.search-box input { width: 250px; }
.search-box input:focus, .filter-select:focus { 
  outline: none; 
  border-color: var(--accent-color, #4a6cf7); 
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.2); 
}
.filter-select { 
  padding-left: 1rem; 
  width: 150px; 
  appearance: none; 
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%23a0a0b0' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e"); 
  background-position: right 0.5rem center; 
  background-repeat: no-repeat; 
  background-size: 1.5em 1.5em; 
}
.add-btn { 
  background-color: var(--accent-color, #4a6cf7); 
  color: #fff; 
  padding: 0.6rem 1.2rem; 
  border-radius: var(--border-radius-sm, 8px); 
  border: none; 
  font-weight: 600; 
  cursor: pointer; 
  transition: all var(--transition-speed, 0.3s) ease; 
  display: flex; 
  align-items: center; 
  gap: 0.5rem; 
}
.add-btn:hover { 
  background-color: var(--accent-color-hover, #3b57d6); 
  box-shadow: 0 4px 15px var(--shadow-color, rgba(74, 108, 247, 0.3)); 
  transform: translateY(-2px); 
}

/* 表格 */
.product-table-card { 
  background: var(--bg-primary, rgba(255, 255, 255, 0.9)); 
  border: 1px solid var(--border-color, #e2e8f0); 
  border-radius: var(--border-radius-md, 16px); 
  padding: 1rem; 
  backdrop-filter: var(--backdrop-filter, none); 
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1)); 
  overflow-x: auto; 
}
.product-table { width: 100%; border-collapse: collapse; white-space: nowrap; }
.product-table th, .product-table td { padding: 1rem; text-align: left; border-bottom: 1px solid var(--border-color, #e2e8f0); }
.product-table thead th { font-size: 0.8rem; font-weight: 600; color: var(--text-secondary, #64748b); text-transform: uppercase; letter-spacing: 0.05em; }
.product-row:hover { background-color: var(--bg-hover, #eff4ff); }
.product-row td { font-size: 0.9rem; color: var(--text-primary, #1e293b); vertical-align: middle; }

/* 表格单元格特定样式 */
.product-info-cell { display: flex; align-items: center; gap: 1rem; }
.product-image { width: 50px; height: 50px; border-radius: var(--border-radius-sm, 8px); object-fit: cover; }
.product-details { display: flex; flex-direction: column; white-space: normal; max-width: 250px; }
.product-title { font-weight: 600; color: var(--text-primary, #1e293b); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis; }
.product-id { font-size: 0.8rem; color: var(--text-secondary, #64748b); }
.price-stock-cell, .status-condition-cell, .category-seller-cell, .data-cell { display: flex; flex-direction: column; gap: 0.25rem; }
.price { font-weight: 600; color: #2ecc71; }
.original-price { text-decoration: line-through; color: var(--text-secondary, #64748b); font-size: 0.8rem; }
.stock { font-size: 0.85rem; }
.status-badge, .condition-badge { padding: 0.25rem 0.6rem; border-radius: 999px; font-size: 0.75rem; font-weight: 600; text-align: center; }
.condition-badge { background-color: var(--bg-hover, rgba(160, 160, 176, 0.15)); color: var(--text-secondary, #64748b); border: 1px solid var(--border-color, rgba(160, 160, 176, 0.3)); }
.status-on-shelf { background-color: rgba(46, 204, 113, 0.15); color: #2ecc71; }
.status-off-shelf { background-color: rgba(239, 68, 68, 0.15); color: #ef4444; }
.status-sold-out { background-color: var(--bg-hover, rgba(160, 160, 176, 0.15)); color: var(--text-secondary, #64748b); }
.status-pending { background-color: rgba(251, 191, 36, 0.15); color: #fbbf24; }
.data-cell span { display: flex; align-items: center; gap: 0.5rem; color: var(--text-secondary, #64748b); font-size: 0.85rem; }

/* 操作按钮 */
.action-buttons { display: flex; gap: 0.5rem; }
.action-btn { 
  width: 32px; 
  height: 32px; 
  border-radius: 6px; 
  border: none; 
  background-color: var(--bg-hover, rgba(255, 255, 255, 0.08)); 
  color: var(--text-secondary, #64748b); 
  cursor: pointer; 
  transition: all var(--transition-speed, 0.3s) ease; 
  display: flex; 
  align-items: center; 
  justify-content: center; 
}
.action-btn:hover { transform: translateY(-2px); color: #fff; }
.btn-view:hover { background-color: #38bdf8; }
.btn-edit:hover { background-color: #10b981; }
.btn-recommend:hover { background-color: #fbbf24; }
.btn-unrecommend { color: #fbbf24; }
.btn-unrecommend:hover { background-color: #f87171; }
.btn-delete:hover { background-color: #ef4444; }

/* 空状态和分页 */
.empty-state { text-align: center; padding: 4rem 0; color: var(--text-secondary, #64748b); }
.empty-state i { font-size: 3rem; margin-bottom: 1rem; }
.pagination-controls { display: flex; justify-content: center; align-items: center; margin-top: 1.5rem; gap: 1rem; color: var(--text-secondary, #64748b); }
.pagination-controls button { 
  background: var(--bg-secondary, #f7f9fc); 
  border: 1px solid var(--border-color, #e2e8f0); 
  color: var(--text-secondary, #64748b); 
  border-radius: var(--border-radius-sm, 8px); 
  width: 36px; 
  height: 36px; 
  cursor: pointer; 
  transition: all var(--transition-speed, 0.3s) ease; 
}
.pagination-controls button:hover:not(:disabled) { 
  background-color: var(--accent-color, #4a6cf7); 
  color: #fff; 
  border-color: var(--accent-color, #4a6cf7); 
}
.pagination-controls button:disabled { opacity: 0.5; cursor: not-allowed; }

/* 模态框 - 完全使用 CSS 变量重写，确保主题一致性 */
.modal-overlay { 
  position: fixed !important; 
  top: 0 !important; 
  left: 0 !important; 
  width: 100% !important; 
  height: 100% !important; 
  background-color: rgba(0, 0, 0, 0.4) !important; 
  backdrop-filter: blur(5px) !important; 
  display: flex !important; 
  justify-content: center !important; 
  align-items: center !important; 
  z-index: 1000 !important; 
  animation: fadeIn 0.3s ease !important; 
  padding: 20px !important;
  box-sizing: border-box !important;
}

.modal-content { 
  background: var(--bg-primary, #ffffff) !important; 
  border-radius: var(--border-radius-md, 16px) !important; 
  border: 1px solid var(--border-color, #e2e8f0) !important; 
  box-shadow: 0 20px 40px var(--shadow-color, rgba(0, 0, 0, 0.2)) !important; 
  width: 90% !important; 
  max-width: 800px !important; 
  max-height: calc(100vh - 40px) !important;
  animation: slideInUp 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94) !important; 
  backdrop-filter: var(--backdrop-filter, none) !important;
  margin: 0 !important;
  overflow: hidden !important;
}

@keyframes slideInUp { 
  from { transform: translateY(30px) scale(0.98); opacity: 0; } 
  to { transform: translateY(0) scale(1); opacity: 1; } 
}

.modal-header { 
  padding: 1.5rem !important; 
  display: flex !important; 
  justify-content: space-between !important; 
  align-items: center !important; 
  border-bottom: 1px solid var(--border-color, #e2e8f0) !important; 
  background: var(--bg-primary, #ffffff) !important;
}

.modal-header h3 { 
  margin: 0 !important; 
  font-size: 1.25rem !important; 
  color: var(--text-primary, #1e293b) !important;
  font-weight: 600 !important;
}

.modal-close { 
  background: none !important; 
  border: none !important; 
  font-size: 1.5rem !important; 
  color: var(--text-secondary, #64748b) !important; 
  cursor: pointer !important; 
  transition: color 0.3s, transform 0.3s !important; 
  padding: 0.5rem !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  border-radius: 6px !important;
}

.modal-close:hover { 
  color: var(--accent-color, #4a6cf7) !important; 
  transform: rotate(90deg) !important; 
  background: var(--bg-hover, #eff4ff) !important;
}

.modal-body { 
  padding: 1.5rem !important; 
  max-height: 70vh !important; 
  overflow-y: auto !important; 
  background: var(--bg-primary, #ffffff) !important;
}

.edit-form { 
  display: flex !important; 
  flex-direction: column !important; 
  gap: 1.5rem !important; 
}

.form-grid { 
  display: grid !important; 
  grid-template-columns: repeat(2, 1fr) !important; 
  gap: 1rem !important; 
}

.form-item { 
  display: flex !important; 
  flex-direction: column !important; 
}

.form-item.full-width { 
  grid-column: 1 / -1 !important; 
}

.form-item label { 
  margin-bottom: 0.5rem !important; 
  font-size: 0.9rem !important; 
  color: var(--text-secondary, #64748b) !important; 
  font-weight: 500 !important;
}

.form-item input, .form-item select, .form-item textarea { 
  width: 100% !important; 
  box-sizing: border-box !important; 
  background: var(--bg-secondary, #f7f9fc) !important; 
  border: 1px solid var(--border-color, #e2e8f0) !important; 
  border-radius: var(--border-radius-sm, 8px) !important; 
  padding: 0.75rem !important; 
  color: var(--text-primary, #1e293b) !important; 
  font-size: 0.9rem !important; 
  transition: all var(--transition-speed, 0.3s) ease !important; 
  font-family: inherit !important;
}

.form-item input:focus, .form-item select:focus, .form-item textarea:focus { 
  outline: none !important; 
  border-color: var(--accent-color, #4a6cf7) !important; 
  box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.2) !important; 
}

.checkbox-label { 
  display: flex !important; 
  align-items: center !important; 
  cursor: pointer !important; 
  font-size: 0.9rem !important; 
  color: var(--text-primary, #1e293b) !important; 
}

.checkbox-label input { 
  position: absolute !important; 
  opacity: 0 !important; 
}

.checkmark { 
  height: 20px !important; 
  width: 20px !important; 
  background-color: var(--bg-secondary, #f7f9fc) !important; 
  border: 1px solid var(--border-color, #e2e8f0) !important; 
  border-radius: 4px !important; 
  margin-right: 12px !important; 
  position: relative !important; 
  transition: all 0.2s ease !important; 
}

.checkbox-label:hover .checkmark { 
  border-color: var(--accent-color, #4a6cf7) !important; 
}

.checkbox-label input:checked ~ .checkmark { 
  background-color: var(--accent-color, #4a6cf7) !important; 
  border-color: var(--accent-color, #4a6cf7) !important; 
}

.checkmark:after { 
  content: "" !important; 
  position: absolute !important; 
  display: none !important; 
  left: 6px !important; 
  top: 2px !important; 
  width: 5px !important; 
  height: 10px !important; 
  border: solid white !important; 
  border-width: 0 2px 2px 0 !important; 
  transform: rotate(45deg) !important; 
}

.checkbox-label input:checked ~ .checkmark:after { 
  display: block !important; 
}

.form-actions { 
  display: flex !important; 
  justify-content: flex-end !important; 
  gap: 1rem !important; 
  padding-top: 1rem !important; 
  border-top: 1px solid var(--border-color, #e2e8f0) !important; 
}

.btn-cancel, .btn-save { 
  padding: 0.75rem 1.5rem !important; 
  border-radius: var(--border-radius-sm, 8px) !important; 
  border: none !important; 
  font-size: 0.9rem !important; 
  font-weight: 600 !important; 
  cursor: pointer !important; 
  transition: all var(--transition-speed, 0.3s) ease !important; 
  display: inline-flex !important;
  align-items: center !important;
  white-space: nowrap !important;
}

.btn-cancel { 
  background: var(--bg-secondary, #f7f9fc) !important; 
  color: var(--text-primary, #1e293b) !important; 
  border: 1px solid var(--border-color, #e2e8f0) !important; 
}

.btn-cancel:hover { 
  background-color: var(--bg-hover, #eff4ff) !important; 
  border-color: var(--accent-color, #4a6cf7) !important;
}

.btn-save { 
  background-color: var(--accent-color, #4a6cf7) !important; 
  color: #fff !important; 
}

.btn-save:hover { 
  background-color: var(--accent-color-hover, #3b57d6) !important; 
  box-shadow: 0 4px 15px var(--shadow-color, rgba(74, 108, 247, 0.3)) !important;
}

/* 响应式 */
@media (max-width: 768px) {
  .product-management-container { padding: 1rem; }
  .header-bar, .actions-group { flex-direction: column; align-items: stretch; }
  .search-box input, .filter-select { width: 100%; box-sizing: border-box; }
  .modal-content { width: 95% !important; max-height: 90vh !important; }
  .form-grid { grid-template-columns: 1fr !important; }
  .form-item.full-width { grid-column: auto !important; }
  .form-actions { 
    flex-direction: column !important;
  }
  .btn-cancel, .btn-save {
    width: 100% !important;
    justify-content: center !important;
  }
}
</style>