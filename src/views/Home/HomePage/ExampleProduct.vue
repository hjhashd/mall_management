<script setup>
import {ref, reactive, onMounted, watch, computed} from 'vue';
import {searchProducts, getCategories, getRecommendations} from '@/api/product';
import {addToCart as apiAddToCart, toggleFavorite as apiToggleFavorite} from '@/api/product';
import {message} from 'ant-design-vue';
import {useCartStore} from '@/stores/cartStore';

// 导入子组件
import LeftSidebar from './LeftSidebar.vue';
import RightSidebar from './RightSidebar.vue';
import SearchBar from './SearchBar.vue';
import ProductGrid from './ProductGrid.vue';

const cartStore = useCartStore();

// 筛选响应式对象
const filters = reactive({
  title: '',
  categoryId: '',
  priceMin: null,
  priceMax: null,
  condition: '',
  inStock: false,
  sort: 'newest' // 默认排序方式
});

// ✅ 新增：排序选项列表，用于生成UI和显示文本
const sortOptions = ref([
  {value: 'newest', text: '最新发布'},
  {value: 'popular', text: '热门浏览'},
  {value: 'favorite_desc', text: '收藏最多'},
  {value: 'price_asc', text: '价格升序'},
  {value: 'price_desc', text: '价格降序'},
  {value: 'discount_desc', text: '折扣最高'},
]);

// 组件状态
const products = ref([]);
const totalProducts = ref(0);
const currentPage = ref(1);
const pageSize = ref(12);
const categories = ref([]);
const activeCategory = ref(0);
const searchQuery = ref('');
const leftSidebarCollapsed = ref(false);
const rightSidebarCollapsed = ref(false);
const currentMode = ref('search'); // 'search' 或 'recommend'

// 计算总页数
const totalPages = computed(() => Math.ceil(totalProducts.value / pageSize.value));

// 获取商品列表
const fetchProducts = async () => {
  try {
    let response;
    const baseParams = {
      page: currentPage.value,
      pageSize: pageSize.value
    };

    if (currentMode.value === 'recommend') {
      response = await getRecommendations(baseParams);
    } else {
      const searchParams = {
        ...filters,
        ...baseParams,
        // [!code focus]
        // [!COMMENT] 将状态过滤移至API请求，确保分页准确性
        statusText: '上架'
      };
      if (searchQuery.value) {
        searchParams.title = searchQuery.value;
      }
      Object.keys(searchParams).forEach(key => {
        if (searchParams[key] === null || searchParams[key] === '' || searchParams[key] === false) {
          delete searchParams[key];
        }
      });
      response = await searchProducts(searchParams);
    }

    if (response.data && response.data.data) {
      products.value = response.data.data.items || [];
      totalProducts.value = response.data.data.total || 0;
    } else {
      products.value = [];
      totalProducts.value = 0;
    }
  } catch (err) {
    console.error('获取商品失败:', err);
    products.value = [];
    totalProducts.value = 0;
    message.error('获取商品列表失败，请稍后重试');
  }
};

// 获取分类列表
const fetchCategories = async () => {
  try {
    const response = await getCategories();
    categories.value = [{categoryName: '全部商品', categoryId: 0, icon: 'fas fa-th'}, ...(response.data.data || [])];
  } catch (error) {
    console.error('获取分类失败:', error);
    message.error('获取分类失败，请稍后重试');
  }
};

// 监听筛选条件和搜索查询的变化
watch([filters, searchQuery], () => {
  currentPage.value = 1;
  currentMode.value = 'search';
  fetchProducts();
}, {deep: true});

// 监听当前页码变化
watch(currentPage, () => {
  fetchProducts();
});

onMounted(() => {
  fetchProducts();
  fetchCategories();
});

const handleCategoryChange = (categoryId) => {
  activeCategory.value = categoryId;
  filters.categoryId = categoryId === 0 ? '' : categoryId;
};

const handlePageChange = (newPage) => {
  if (newPage >= 1 && newPage <= totalPages.value) {
    currentPage.value = newPage;
  }
};

const handleSearch = (query) => {
  searchQuery.value = query;
  filters.sort = 'newest';
};

const handleRecommend = () => {
  searchQuery.value = '';
  Object.assign(filters, {
    title: '', categoryId: '', priceMin: null, priceMax: null,
    condition: '', inStock: false, sort: 'newest'
  });
  activeCategory.value = 0;

  currentPage.value = 1;
  currentMode.value = 'recommend';
  fetchProducts();
};

const handleAddToCart = async (product) => {
  try {
    await apiAddToCart(product.id, 1);
    message.success(`已将 ${product.title} 加入购物车！`);
    cartStore.fetchCartSummary();
  } catch (error) {
    message.error('加入购物车失败，请稍后重试');
  }
};

const handleToggleFavorite = async (productId) => {
  const product = products.value.find(p => p.id === productId);
  if (!product) return;
  try {
    await apiToggleFavorite(productId);
    product.isFavorite = !product.isFavorite;
    message.info(product.isFavorite ? '收藏成功！' : '已取消收藏！');
  } catch (error) {
    message.error('操作失败，请稍后重试');
  }
};
</script>

<template>
  <div class="product-list-page">
    <div class="app-layout">
      <div class="page-container">
        <LeftSidebar
            :categories="categories"
            :active-category="activeCategory"
            v-model:collapsed="leftSidebarCollapsed"
            @update:activeCategory="handleCategoryChange"
        />

        <main class="main-content"
              :style="{ marginLeft: leftSidebarCollapsed ? '40px' : '250px', marginRight: rightSidebarCollapsed ? '40px' : '250px' }">

          <SearchBar @search="handleSearch" @recommend="handleRecommend"/>

          <div class="filter-toolbar">
            <div class="total-products-info">
              共找到 <span>{{ totalProducts }}</span> 件相关商品
            </div>
            <div class="sort-selector">
              <label for="sort-by">排序方式：</label>
              <select id="sort-by" v-model="filters.sort" class="sort-dropdown">
                <option v-for="option in sortOptions" :key="option.value" :value="option.value">
                  {{ option.text }}
                </option>
              </select>
            </div>
          </div>

          <ProductGrid
              :products="products"
              :current-page="currentPage"
              :total-pages="totalPages"
              :left-sidebar-collapsed="leftSidebarCollapsed"
              :right-sidebar-collapsed="rightSidebarCollapsed"
              :sort-mode="filters.sort"
              :display-mode="currentMode"
              @change-page="handlePageChange"
              @add-to-cart="handleAddToCart"
              @toggle-favorite="handleToggleFavorite"
          />
        </main>

        <RightSidebar v-model:collapsed="rightSidebarCollapsed"/>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 主组件只保留布局和全局样式变量 */
.product-list-page {
  --primary-color: #5c9e53;
  --secondary-color: #f7faf5;
  --hover-color: #e6f0e6;
  --text-muted-color: #6b7a63;
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
}

.app-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  padding-top: 60px; /* 假设有全局 header */
  background-color: var(--secondary-color);
}

.page-container {
  display: flex;
  flex: 1;
  width: 100%;
  max-width: 100%;
  margin: 0 auto;
  padding-top: 20px;
  gap: 0;
}

.main-content {
  flex: 1;
  padding: 20px;
  transition: all 0.3s ease;
}

.filter-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 15px 20px;
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 15px var(--shadow-color);
  border: 1px solid var(--border-color);
}

.total-products-info {
  font-size: 14px;
  color: var(--text-muted-color);
}

.total-products-info span {
  font-weight: 600;
  color: var(--primary-color);
}

.sort-selector {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: var(--text-muted-color);
}

.sort-dropdown {
  padding: 8px 12px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
  background-color: #fff;
  font-size: 14px;
  cursor: pointer;
  transition: border-color 0.2s;
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%236b7a63' viewBox='0 0 16 16'%3E%3Cpath fill-rule='evenodd' d='M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}

.sort-dropdown:hover, .sort-dropdown:focus {
  border-color: var(--primary-color);
  outline: none;
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 40px !important;
    padding: 15px;
  }

  .filter-toolbar {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}
</style>
