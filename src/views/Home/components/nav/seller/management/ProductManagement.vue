<template>
  <div>
    <a-card :bordered="false" class="product-management-card">
      <a-row justify="space-between" align="middle" class="header-row">
        <a-col :span="16">
          <a-space :size="16">
            <a-input-search
                v-model:value="searchParams.query"
                placeholder="输入商品名称搜索"
                style="width: 250px"
                enter-button
                @search="handleSearch"
            />
            <a-select
                v-model:value="searchParams.status"
                placeholder="筛选商品状态"
                style="width: 150px"
                allow-clear
                @change="handleSearch"
            >
              <a-select-option :value="1">上架中</a-select-option>
              <a-select-option :value="2">已下架</a-select-option>
              <a-select-option :value="3">已售罄</a-select-option>
              <a-select-option :value="4">审核中</a-select-option>
            </a-select>
          </a-space>
        </a-col>

        <a-col :span="8" style="text-align: right">
          <a-button type="primary" @click="handleAddProduct">
            <template #icon><PlusOutlined /></template>
            添加商品
          </a-button>
        </a-col>
      </a-row>

      <a-table
          :columns="columns"
          :data-source="products"
          :pagination="pagination"
          :loading="loading"
          row-key="id"
          class="product-table"
          @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'productInfo'">
            <a-space>
              <a-avatar :size="60" shape="square" :src="record.image" />
              <div class="product-details">
                <span class="product-name">{{ record.name }}</span>
                <span class="product-id">ID: {{ record.id }}</span>
              </div>
            </a-space>
          </template>

          <template v-if="column.key === 'price'">
            <span class="price">¥{{ record.price }}</span>
          </template>

          <template v-if="column.key === 'status'">
            <a-tag :color="getStatus(record.status).color">
              {{ getStatus(record.status).text }}
            </a-tag>
          </template>

          <template v-if="column.key === 'action'">
            <a-space>
              <a-button type="link" @click="handleEditProduct(record)">编辑</a-button>
              <a-popconfirm
                  title="确定要删除这个商品吗?"
                  ok-text="确认删除"
                  cancel-text="取消"
                  @confirm="handleDeleteProduct(record.id)"
              >
                <a-button type="link" danger>删除</a-button>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useUserStore } from '@/stores/userStore';
import {searchProducts, deleteProduct } from '@/api/product';
import { getSellerProducts } from '@/api/shop.js'
import { message } from 'ant-design-vue';
import { PlusOutlined } from '@ant-design/icons-vue';

// --- 状态和依赖 ---
// const router = useRouter(); // 移除
const userStore = useUserStore();
const products = ref([]);
const loading = ref(false);

// ===============================================================
// 开始: 核心修改
// 1. 定义要触发的事件
// ===============================================================
const emit = defineEmits(['addProduct', 'editProduct']);

// 搜索参数
const searchParams = reactive({
  query: '',
  status: null,
});

// 分页配置
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showTotal: (total) => `共 ${total} 条`,
});

// 表格列定义
const columns = [
  { title: '商品信息', key: 'productInfo', width: '35%' },
  { title: '价格', dataIndex: 'price', key: 'price', align: 'center' },
  { title: '库存', dataIndex: 'stock', key: 'stock', align: 'center' },
  { title: '状态', dataIndex: 'status', key: 'status', align: 'center' },
  { title: '操作', key: 'action', align: 'center', fixed: 'right', width: 150 },
];

const fetchProducts = async () => {
  loading.value = true;
  try {
    let response;
    const isSearchActive = searchParams.query || searchParams.status != null;

    const baseParams = {
      page: pagination.current,
      pageSize: pagination.pageSize,
      sellerId: userStore.userInfo?.userId,
    };

    if (isSearchActive) {
      response = await searchProducts({
        ...baseParams,
        title: searchParams.query || null,
        status: searchParams.status,
      });
    } else {
      response = await getSellerProducts(baseParams);
    }

    const responseData = response.data.data;
    products.value = responseData.items.map(item => ({
      id: item.id,
      image: item.image || 'https://placehold.co/100x100/E2E8F0/475569?text=IMG',
      name: item.title || item.name || '未命名商品',
      price: formatPrice(item.price),
      stock: item.stock ?? 0,
      status: item.status,
    }));
    pagination.total = responseData.total || 0;
  } catch (error) {
    message.error('获取商品列表失败: ' + error.message);
  } finally {
    loading.value = false;
  }
};

// 搜索处理
const handleSearch = () => {
  pagination.current = 1;
  fetchProducts();
};

// 表格变化处理
const handleTableChange = (pager) => {
  pagination.current = pager.current;
  pagination.pageSize = pager.pageSize;
  fetchProducts();
};

// 删除商品
const handleDeleteProduct = async (productId) => {
  try {
    await deleteProduct(productId);
    message.success('商品已删除！');
    fetchProducts();
  } catch (error) {
    message.error('删除商品失败: ' + error.message);
  }
};

// ===============================================================
// 2. 修改导航操作，用 emit 代替 router.push
// ===============================================================
const handleAddProduct = () => {
  emit('addProduct');
};

const handleEditProduct = (product) => {
  emit('editProduct', product.id);
};
// ===============================================================
// 结束: 核心修改
// ===============================================================

// --- 辅助函数 ---
const formatPrice = (price) => {
  return Number(price).toLocaleString('zh-CN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
};

const getStatus = (status) => {
  const statusMap = {
    1: {text: '上架中', color: 'green'},
    2: {text: '已下架', color: 'volcano'},
    3: {text: '已售罄', color: 'red'},
    4: {text: '审核中', color: 'gold'},
  };
  return statusMap[status] || {text: '未知', color: 'default'};
};

onMounted(() => {
  fetchProducts();
});
</script>

<style scoped>
.product-management-card {
  border-radius: 8px;
}
.header-row {
  margin-bottom: 24px;
}
.product-table {
  margin-top: 16px;
}
.product-details {
  display: flex;
  flex-direction: column;
}
.product-name {
  font-weight: 500;
  color: #333;
}
.product-id {
  font-size: 12px;
  color: #999;
}
.price {
  font-weight: 600;
  color: #fa541c;
}
:deep(.ant-table) {
  overflow-x: auto;
}
</style>
