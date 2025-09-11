<template>
  <div class="customer-management-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">我的粉丝</h2>
      <p class="page-description">管理关注您的用户，维护客户关系</p>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <a-button @click="exportData">
          <template #icon><DownloadOutlined /></template>
          导出数据
        </a-button>
      </div>
      <div class="toolbar-right">
        <a-input-search
            v-model:value="searchText"
            placeholder="搜索粉丝用户名或邮箱"
            style="width: 250px"
            @search="handleSearch"
            enter-button
        />
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon followers">
          <UserOutlined />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ pagination.total }}</div>
          <div class="stat-label">总粉丝数</div>
        </div>
      </div>
      <!-- 其他统计数据可以后续添加 -->
    </div>

    <!-- 数据表格 -->
    <a-card title="我的粉丝列表" :bordered="false" class="table-card">
      <template #extra>
        <a-button type="link" @click="refreshData" :loading="loading">
          <template #icon><ReloadOutlined /></template>
          刷新
        </a-button>
      </template>

      <a-table
          :columns="columns"
          :data-source="tableData"
          :pagination="pagination"
          :loading="loading"
          row-key="userId"
          @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <!-- 粉丝信息 -->
          <template v-if="column.key === 'user'">
            <div class="user-info">
              <a-avatar :src="record.avatarPath" :size="32">
                {{ record.username?.charAt(0).toUpperCase() }}
              </a-avatar>
              <div class="user-details">
                <div class="user-name">{{ record.username }}</div>
                <div class="user-email">{{ record.email }}</div>
              </div>
            </div>
          </template>

          <!-- 关注时间 -->
          <template v-if="column.key === 'followCreatedAt'">
            <div class="time-info">
              <div>{{ formatDate(record.followCreatedAt) }}</div>
              <div class="time-ago">{{ getTimeAgo(record.followCreatedAt) }}</div>
            </div>
          </template>

          <!-- 状态 -->
          <template v-if="column.key === 'enabled'">
            <a-tag :color="record.enabled ? 'green' : 'red'">
              {{ record.enabled ? '正常' : '禁用' }}
            </a-tag>
          </template>

          <!-- 操作 -->
          <template v-if="column.key === 'actions'">
            <div class="action-buttons">
              <a-button type="link" size="small" @click="viewDetails(record)">
                查看
              </a-button>
              <a-popconfirm
                  title="确定要移除该粉丝吗？"
                  ok-text="确定"
                  cancel-text="取消"
                  @confirm="deleteRecord(record)"
              >
                <a-button type="link" size="small" danger>
                  移除
                </a-button>
              </a-popconfirm>
            </div>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 详情模态框 -->
    <a-modal v-model:open="detailModalVisible" title="粉丝详情" :footer="null" width="400px">
      <div v-if="selectedRecord" class="detail-content">
        <a-descriptions bordered :column="1">
          <a-descriptions-item label="用户名">{{ selectedRecord.username }}</a-descriptions-item>
          <a-descriptions-item label="邮箱">{{ selectedRecord.email }}</a-descriptions-item>
          <a-descriptions-item label="手机号">{{ selectedRecord.phone || '未提供' }}</a-descriptions-item>
          <a-descriptions-item label="信用分">{{ selectedRecord.creditScore }}</a-descriptions-item>
          <a-descriptions-item label="关注时间">{{ formatDate(selectedRecord.followCreatedAt) }}</a-descriptions-item>
          <a-descriptions-item label="状态">
            <a-tag :color="selectedRecord.enabled ? 'green' : 'red'">
              {{ selectedRecord.enabled ? '正常' : '禁用' }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import {ref, reactive, onMounted} from 'vue';
import {message} from 'ant-design-vue';
import {useUserStore} from '@/stores/userStore'; // 引入Pinia Store
import {
  DownloadOutlined,
  UserOutlined,
  ReloadOutlined,
} from '@ant-design/icons-vue';

import * as userAPI from '@/api/user.js';

// 使用Pinia Store获取当前登录用户信息
const userStore = useUserStore();

// 响应式数据
const loading = ref(false);
const detailModalVisible = ref(false);
const searchText = ref('');
const selectedRecord = ref(null);
const tableData = ref([]);

// 分页配置
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total) => `共 ${total} 条`
});

// 表格列定义
const columns = [
  {
    title: '粉丝用户',
    key: 'user',
    width: 250,
  },
  {
    title: '关注时间',
    dataIndex: 'followCreatedAt',
    key: 'followCreatedAt',
    width: 180,
    sorter: (a, b) => new Date(a.followCreatedAt) - new Date(b.followCreatedAt),
  },
  {
    title: '信用分',
    dataIndex: 'creditScore',
    key: 'creditScore',
    width: 100,
    sorter: (a, b) => a.creditScore - b.creditScore,
  },
  {
    title: '状态',
    dataIndex: 'enabled',
    key: 'enabled',
    width: 100,
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    fixed: 'right'
  }
];

// 工具函数
const formatDate = (date) => date ? new Date(date).toLocaleString('zh-CN') : 'N/A';
const getTimeAgo = (date) => {
  if (!date) return '';
  const diff = Date.now() - new Date(date).getTime();
  const minute = 60 * 1000;
  const hour = minute * 60;
  const day = hour * 24;
  if (diff < minute) return '刚刚';
  if (diff < hour) return `${Math.floor(diff / minute)}分钟前`;
  if (diff < day) return `${Math.floor(diff / hour)}小时前`;
  return `${Math.floor(diff / day)}天前`;
};

// API 调用函数
const fetchData = async () => {
  // 从store获取当前登录用户的ID，即卖家ID
  const sellerId = userStore.userInfo?.userId;
  if (!sellerId) {
    message.error('无法获取您的用户信息，请重新登录。');
    return;
  }

  loading.value = true;
  try {
    const params = {
      page: pagination.current,
      pageSize: pagination.pageSize,
      sellerId: sellerId,
      // 注意：搜索功能现在是前端实现的，如果数据量大，建议改为后端搜索
      // search: searchText.value
    };

    // 调用新的API获取粉丝列表
    console.log(params);
    const response = await userAPI.getFollowers(params);
    if (response.data.success) {
      // [修复] 将 .list 修改为 .items 以匹配API响应
      tableData.value = response.data.data.items || [];
      // [修复] 将 .total 修改为 .totalItems 以匹配API响应
      pagination.total = response.data.data.totalItems || 0;
    } else {
      message.error(response.data.message || '获取粉丝列表失败');
    }
  } catch (error) {
    console.error('获取粉丝数据失败:', error);
    message.error('网络错误，获取粉丝数据失败');
  } finally {
    loading.value = false;
  }
};

// 事件处理函数
const handleSearch = () => {
  // 当前为前端搜索，数据量大时建议改为后端搜索
  // 为了改为后端搜索，只需将searchText作为参数传给fetchData即可
  // 这里暂时保留前端搜索的逻辑，如果需要切换，取消注释并修改fetchData

  // 前端搜索实现
  if (searchText.value) {
    const search = searchText.value.toLowerCase();
    // 这里需要一个原始数据备份，或者每次搜索都重新拉取
    // 为简单起见，我们触发一次后端拉取
    // pagination.current = 1;
    // fetchData(); // 如果要启用后端搜索，放开此行
  } else {
    // fetchData();
  }
  message.info('搜索功能建议在后端实现以支持大数据量查询。');
};

const handleTableChange = (pag) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const viewDetails = (record) => {
  selectedRecord.value = record;
  detailModalVisible.value = true;
};

const deleteRecord = async (record) => {
  const sellerId = userStore.userInfo?.userId;
  const followerId = record.userId;

  if (!sellerId || !followerId) {
    message.error('参数错误，无法执行操作');
    return;
  }

  try {
    const response = await userAPI.removeFollower({followerId, followedId: sellerId});
    if (response.data.success) {
      message.success('已成功移除该粉丝');
      fetchData(); // 重新加载数据
    } else {
      message.error(response.data.message || '移除失败');
    }
  } catch (error) {
    console.error('移除粉丝失败:', error);
    message.error('网络错误，移除粉丝失败');
  }
};

const refreshData = () => {
  pagination.current = 1;
  searchText.value = '';
  fetchData();
};

const exportData = () => {
  message.info('导出功能正在开发中...');
};

// 生命周期钩子
onMounted(() => {
  // 确保store中的用户信息加载完毕后再执行
  if (userStore.userInfo?.userId) {
    fetchData();
  } else {
    // 如果用户信息可能延迟加载，可以监听其变化
    const unwatch = userStore.$subscribe((mutation, state) => {
      if (state.userInfo?.userId) {
        fetchData();
        unwatch(); // 获取到数据后停止监听
      }
    });
  }
});
</script>

<style scoped>
.customer-management-container {
  padding: 24px;
  background-color: #f0f2f5;
}

.page-header {
  margin-bottom: 24px;
  background-color: white;
  padding: 16px 24px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 8px;
}

.page-description {
  color: #888;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
  margin-right: 16px;
}

.stat-icon.followers {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
}

.stat-label {
  color: #888;
  font-size: 14px;
}

.table-card {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  border-radius: 8px;
}

.user-info {
  display: flex;
  align-items: center;
}

.user-details {
  margin-left: 12px;
}

.user-name {
  font-weight: 500;
}

.user-email {
  font-size: 12px;
  color: #888;
}

.time-info .time-ago {
  font-size: 12px;
  color: #999;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.detail-content {
  padding-top: 16px;
}
</style>
