<template>
  <HomeNavbar />
  <div class="product-container">
    <!-- 装饰背景元素 -->
    <div class="decoration-bg">
      <div class="floating-circle circle-1"></div>
      <div class="floating-circle circle-2"></div>
      <div class="floating-circle circle-3"></div>
      <div class="wave-decoration"></div>
    </div>

    <!-- 侧边筛选栏 -->
    <SearchSidebar
        :categories="categories"
        :initial-filters="filters"
        @filter-applied="handleFilterApplied"
        @filters-reset="handleFiltersReset"
    />

    <!-- 主内容区 -->
    <SearchMain
        :products="products"
        @update:products="updateProducts"
        :total-products="totalProducts"
        :current-page="currentPage"
        :page-size="pageSize"
        :sort-type="filters.sort"
        @sort-changed="handleSortChanged"
        @page-changed="handlePageChanged"
        @reset-filters="handleFiltersReset"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue';
import SearchSidebar from './FilterSidebar.vue';
import SearchMain from './SearchMain.vue';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import {getCategories, searchProducts} from '@/api/product';

// 状态管理
const filters = reactive({
  title: '',
  category_id: '',
  priceMin: null,
  priceMax: null,
  condition: '',
  inStock: false,
  timeRange: null,
  sort: 'newest' // 默认排序类型
});

const products = ref([]); // 商品数据
const totalProducts = ref(0); // 总商品数
const currentPage = ref(1); // 当前页码
const pageSize = ref(12); // 每页数量
const loading = ref(false); // 加载状态
const error = ref(null); // 错误信息
const categories = ref([]); // 分类数据

// 获取商品数据
const fetchProducts = async () => {
  loading.value = true;
  error.value = null;

  try {
    const params = {
      ...filters,
      page: currentPage.value,
      pageSize: pageSize.value
    };

    // 清理空参数
    Object.keys(params).forEach(key => {
      if (params[key] === null || params[key] === '' || params[key] === false) {
        delete params[key];
      }
    });

    const response = await searchProducts(params);

    if (response.data && response.data.data) {
      products.value = response.data.data.items || [];
      totalProducts.value = response.data.data.total || 0;
    } else {
      products.value = [];
      totalProducts.value = 0;
    }
  } catch (err) {
    console.error('获取商品失败:', err);
    error.value = '加载商品失败，请稍后重试';
    products.value = [];
    totalProducts.value = 0;
  } finally {
    loading.value = false;
  }
};

// 获取分类数据
const fetchCategories = async () => {
  try {
    const response = await getCategories();

    // 使用正确的驼峰式字段名
    categories.value = (response.data.data || []).map(category => {
      // 处理图标显示
      const displayName = category.icon
          ? `${category.icon} ${category.categoryName}`
          : category.categoryName;

      return {
        id: category.categoryId, // 使用 categoryId
        name: displayName,       // 使用处理后的显示名称
        // 保留原始数据
        ...category
      };
    });

    // 调试：打印转换后数据
    console.log("转换后的分类数据:", categories.value);
  } catch (error) {
    console.error('获取分类失败:', error);
    categories.value = [
      {id: 1, name: '📱 手机数码'},
      {id: 2, name: '💻 电脑办公'},
      {id: 3, name: '📷 摄影摄像'},
      {id: 4, name: '🎮 游戏娱乐'},
      {id: 5, name: '🎧 音响配件'}
    ];
  }
};

// 更新商品列表
const updateProducts = (newProducts) => {
  products.value = newProducts
}

// 监听筛选条件变化
watch(filters, () => {
  currentPage.value = 1; // 筛选条件变化时重置到第一页
  fetchProducts();
}, { deep: true });

// 监听页码变化
watch(currentPage, () => {
  fetchProducts();
});

// 组件挂载时加载数据
onMounted(() => {
  fetchProducts();
  fetchCategories();
});

// 事件处理
const handleFilterApplied = (newFilters) => {
  Object.assign(filters, newFilters);
};

const handleFiltersReset = () => {
  Object.assign(filters, {
    title: '',
    category_id: '',
    priceMin: null,
    priceMax: null,
    condition: '',
    inStock: false,
    timeRange: null,
    sort: 'newest' // 重置排序类型
  });
  currentPage.value = 1; // 重置页码
};

const handleSortChanged = (sortType) => {
  filters.sort = sortType; // 更新排序类型
  currentPage.value = 1;   // 排序后回到第一页
};

const handlePageChanged = (newPage) => {
  currentPage.value = newPage;
};
</script>

<style scoped>
.product-container {
  display: flex;
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f0f4ff 100%);
  position: relative;
  overflow: hidden;
  padding-top: 75px; /* 导航栏高度 + 20px 间距 */
  box-sizing: border-box; /* 确保内边距包含在高度内 */
}

/* 装饰背景 */
.decoration-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

.floating-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  animation: float 8s ease-in-out infinite;
}

.circle-1 {
  top: 10%;
  left: 5%;
  width: 120px;
  height: 120px;
  animation-delay: 0s;
}

.circle-2 {
  top: 60%;
  right: 8%;
  width: 80px;
  height: 80px;
  animation-delay: 2s;
}

.circle-3 {
  bottom: 30%;
  left: 15%;
  width: 100px;
  height: 100px;
  animation-delay: 4s;
}

.wave-decoration {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 200px;
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 120'%3E%3Cpath d='M985.66,92.83C906.67,72,823.78,31,743.84,14.19c-82.26-17.34-168.06-16.33-250.45.39-57.84,11.73-114,31.07-172,41.86A600.21,600.21,0,0,1,0,27.35V120H1200V95.8C1132.19,118.92,1055.71,111.31,985.66,92.83Z' fill='%23ffffff' fill-opacity='0.1'/%3E%3C/svg%3E") no-repeat center;
  background-size: cover;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}

/* 响应式样式 */
@media (max-width: 768px) {
  .product-container {
    flex-direction: column;
  }
}
</style>
