<template>
  <div class="products-section">
    <div class="section-header">
      <h2><i class="fas fa-boxes"></i> 商品管理</h2>
      <div class="search-bar">
        <input
            type="text"
            placeholder="搜索商品..."
            v-model="searchQuery"
        >
        <button class="btn btn-search" @click="handleSearch">
          <i class="fas fa-search"></i> 搜索
        </button>
        <select v-model="statusFilter" @change="handleSearch">
          <option :value="null">所有状态</option>
          <option :value="1">上架中</option>
          <option :value="2">已下架</option>
          <option :value="3">已售罄</option>
          <option :value="4">审核中</option>
        </select>
        <div class="layout-buttons">
          <button
              class="layout-btn"
              :class="{ active: layout === 'table' }"
              @click="setLayout('table')"
          >
            <i class="fas fa-list"></i>
          </button>
          <button
              class="layout-btn"
              :class="{ active: layout === 'card' }"
              @click="setLayout('card')"
          >
            <i class="fas fa-th-large"></i>
          </button>
        </div>
        <button class="btn btn-primary" @click="$emit('add-product')">
          <i class="fas fa-plus"></i> 添加商品
        </button>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-if="!products || products.length === 0" class="empty-state">
      <i class="fas fa-box-open"></i>
      <p>暂无商品，点击“添加商品”开始创建</p>
    </div>

    <!-- 表格布局 -->
    <table v-else-if="layout === 'table'" class="products-table">
      <thead>
      <tr>
        <th>商品</th>
        <th>名称</th>
        <th>价格</th>
        <th>库存</th>
        <th>状态</th>
        <th>操作</th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="product in products" :key="product.id">
        <td>
          <img :src="product.image" :alt="product.name" class="product-thumbnail">
        </td>
        <td>{{ product.name }}</td>
        <td>¥{{ product.price }}</td>
        <td>{{ product.stock }}</td>
        <td>
          <span class="status-badge" :class="product.statusClass">
            {{ product.status }}
          </span>
        </td>
        <td>
          <!-- 在子组件的按钮区域添加审核按钮 -->
          <div class="action-buttons">
            <button class="action-btn edit-btn" @click="$emit('edit-product', product)">
              <i class="fas fa-edit"></i>
            </button>
            <button class="action-btn delete-btn" @click="$emit('delete-product', product.id)">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </td>
      </tr>
      </tbody>
    </table>

    <!-- 卡片布局 -->
    <div v-else-if="layout === 'card'" class="products-grid">
      <div v-for="product in products" :key="product.id" class="product-card">
        <img :src="product.image" :alt="product.name" class="card-thumbnail">
        <div class="card-content">
          <h3>{{ product.name }}</h3>
          <p>¥{{ product.price }}</p>
          <p>库存: {{ product.stock }}</p>
          <span class="status-badge" :class="product.statusClass">{{ product.status }}</span>
        </div>
        <div class="card-actions">
          <button class="action-btn edit-btn" @click="$emit('edit-product', product)">
            <i class="fas fa-edit"></i>
          </button>
          <button class="action-btn delete-btn" @click="$emit('delete-product', product.id)">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination" v-if="totalPages && totalPages > 0">
      <button
          v-for="page in totalPages"
          :key="page"
          :class="{ active: currentPage === page }"
          @click="$emit('page-change', page)"
      >
        {{ page }}
      </button>
    </div>
  </div>
</template>

<script>
import { useUserStore } from '@/stores/userStore'
export default {
  name: 'ProductManagement',
  props: {
    products: Array,
    currentPage: {
      type: Number,
      default: 1
    },
    totalPages: {
      type: Number,
      default: 1
    }
  },
  data() {
    return {
      searchQuery: '',
      statusFilter: null,
      layout: 'table',
      sellerId: null,
    }
  },
  emits: ['add-product', 'edit-product', 'delete-product', 'search', 'page-change'],
  methods: {
    handleSearch() {
      const userStore = useUserStore(); // 调用函数获取 store 实例
      this.$emit('search', {
        query: this.searchQuery,
        status: this.statusFilter,
        currentSellerId: userStore.userInfo?.userId, // 安全访问 userId
      })
    },

    setLayout(layout) {
      this.layout = layout
    },
  }
}
</script>

<style scoped>
.products-section {
  background: #fff;
  border-radius: 16px;
  padding: 25px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.section-header h2 {
  color: #3b4a30;
  font-weight: 700;
  display: flex;
  align-items: center;
}

.section-header h2 i {
  margin-right: 10px;
  color: var(--primary-color);
}

.search-bar {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}

.search-bar input,
.search-bar select {
  padding: 10px 15px;
  border: 1px solid var(--border-color);
  border-radius: 50px;
}

.search-bar input {
  min-width: 250px;
}

.search-bar .btn-search {
  padding: 10px 15px;
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 50px;
  cursor: pointer;
}

.layout-buttons {
  display: flex;
  gap: 5px;
}

.layout-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 1px solid var(--border-color);
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.layout-btn.active {
  background-color: var(--primary-color);
  color: white;
}

.products-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.products-table th {
  background-color: var(--secondary-color);
  color: #3b4a30;
  text-align: left;
  padding: 12px 15px;
  font-weight: 600;
}

.products-table td {
  padding: 12px 15px;
  border-bottom: 1px solid var(--border-color);
}

.products-table tr:hover {
  background-color: var(--hover-color);
}

.product-thumbnail {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 8px;
}

/* 卡片布局样式 */
.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.product-card {
  border: 1px solid var(--border-color);
  border-radius: 10px;
  overflow: hidden;
  text-align: center;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
  transition: box-shadow 0.2s;
}

.product-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-thumbnail {
  width: 100%;
  height: 140px;
  object-fit: cover;
}

.card-content {
  padding: 10px;
}

.card-content h3 {
  margin: 8px 0 5px;
  font-size: 16px;
}

.card-content p {
  margin: 4px 0;
  font-size: 14px;
  color: #666;
}

.action-buttons, .card-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.edit-btn { background-color: var(--info-color); color: white; }
.delete-btn { background-color: var(--danger-color); color: white; }

.action-btn:hover {
  opacity: 0.9;
  transform: scale(1.1);
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
  gap: 8px;
}

.pagination button {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 1px solid var(--border-color);
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.pagination button.active {
  background-color: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #999;
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 10px;
  color: #ccc;
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .search-bar {
    width: 100%;
  }

  .products-table {
    display: block;
    overflow-x: auto;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }
}
</style>
