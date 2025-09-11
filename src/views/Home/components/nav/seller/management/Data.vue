<template>
  <div class="data-analysis-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">数据分析</h2>
      <p class="page-description">查看店铺关键指标和业务趋势</p>
    </div>

    <!-- 统计卡片区域 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon sales">
          <DollarOutlined />
        </div>
        <div class="stat-content">
          <div class="stat-value">¥{{ formatNumber(salesData.totalSales) }}</div>
          <div class="stat-label">总销售额</div>
          <div class="stat-change positive">
            <ArrowUpOutlined />
            {{ salesData.salesGrowth }}%
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon orders">
          <ShoppingOutlined />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ formatNumber(salesData.totalOrders) }}</div>
          <div class="stat-label">总订单数</div>
          <div class="stat-change positive">
            <ArrowUpOutlined />
            {{ salesData.orderGrowth }}%
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon customers">
          <UserOutlined />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ formatNumber(salesData.totalCustomers) }}</div>
          <div class="stat-label">总客户数</div>
          <div class="stat-change positive">
            <ArrowUpOutlined />
            {{ salesData.customerGrowth }}%
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon conversion">
          <PercentageOutlined />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ salesData.conversionRate }}%</div>
          <div class="stat-label">转化率</div>
          <div class="stat-change negative">
            <ArrowDownOutlined />
            {{ salesData.conversionChange }}%
          </div>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <div class="charts-grid">
      <!-- 销售趋势图 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">销售趋势</h3>
          <a-select v-model:value="salesPeriod" style="width: 120px">
            <a-select-option value="7days">近7天</a-select-option>
            <a-select-option value="30days">近30天</a-select-option>
            <a-select-option value="3months">近3个月</a-select-option>
          </a-select>
        </div>
        <div ref="salesChart" class="chart-container"></div>
      </div>

      <!-- 商品销量排行 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">热销商品TOP10</h3>
        </div>
        <div ref="productsChart" class="chart-container"></div>
      </div>

      <!-- 客户来源分析 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">客户来源分析</h3>
        </div>
        <div ref="sourceChart" class="chart-container"></div>
      </div>

      <!-- 订单状态分布 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">订单状态分布</h3>
        </div>
        <div ref="orderStatusChart" class="chart-container"></div>
      </div>
    </div>

    <!-- 详细数据表格 -->
    <div class="data-table-section">
      <a-card title="详细数据报表" :bordered="false">
        <template #extra>
          <a-button type="primary" @click="exportData">
            <DownloadOutlined />
            导出数据
          </a-button>
        </template>
        
        <a-table 
          :columns="tableColumns" 
          :data-source="tableData" 
          :pagination="{ pageSize: 10 }"
          :loading="tableLoading"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'amount'">
              <span class="amount-cell">¥{{ formatNumber(record.amount) }}</span>
            </template>
            <template v-else-if="column.key === 'status'">
              <a-tag :color="getStatusColor(record.status)">
                {{ record.status }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'growth'">
              <span :class="['growth-cell', record.growth >= 0 ? 'positive' : 'negative']">
                <component :is="record.growth >= 0 ? ArrowUpOutlined : ArrowDownOutlined" />
                {{ Math.abs(record.growth) }}%
              </span>
            </template>
          </template>
        </a-table>
      </a-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue';
import * as echarts from 'echarts';
import {
  DollarOutlined,
  ShoppingOutlined,
  UserOutlined,
  PercentageOutlined,
  ArrowUpOutlined,
  ArrowDownOutlined,
  DownloadOutlined
} from '@ant-design/icons-vue';

// 响应式数据
const salesPeriod = ref('30days');
const tableLoading = ref(false);

// 图表引用
const salesChart = ref(null);
const productsChart = ref(null);
const sourceChart = ref(null);
const orderStatusChart = ref(null);

// 模拟数据
const salesData = ref({
  totalSales: 1234567.89,
  salesGrowth: 12.5,
  totalOrders: 8456,
  orderGrowth: 8.3,
  totalCustomers: 3421,
  customerGrowth: 15.7,
  conversionRate: 3.2,
  conversionChange: -0.5
});

// 表格列定义
const tableColumns = [
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '销售额', dataIndex: 'amount', key: 'amount' },
  { title: '订单数', dataIndex: 'orders', key: 'orders' },
  { title: '客户数', dataIndex: 'customers', key: 'customers' },
  { title: '增长率', dataIndex: 'growth', key: 'growth' },
  { title: '状态', dataIndex: 'status', key: 'status' }
];

// 表格数据
const tableData = ref([
  {
    key: '1',
    date: '2025-01-01',
    amount: 45678.90,
    orders: 234,
    customers: 156,
    growth: 12.5,
    status: '正常'
  },
  {
    key: '2',
    date: '2025-01-02',
    amount: 52341.67,
    orders: 267,
    customers: 189,
    growth: 15.8,
    status: '正常'
  },
  {
    key: '3',
    date: '2025-01-03',
    amount: 38765.43,
    orders: 198,
    customers: 134,
    growth: -8.2,
    status: '下降'
  }
]);

// 工具函数
const formatNumber = (num) => {
  if (num >= 10000) {
    return (num / 10000).toFixed(1) + '万';
  }
  return num.toLocaleString();
};

const getStatusColor = (status) => {
  const colors = {
    '正常': 'green',
    '下降': 'red',
    '异常': 'orange'
  };
  return colors[status] || 'blue';
};

// 初始化销售趋势图
const initSalesChart = () => {
  if (!salesChart.value) return;
  
  const chart = echarts.init(salesChart.value);
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross',
        label: {
          backgroundColor: '#6a7985'
        }
      }
    },
    legend: {
      data: ['销售额', '订单数']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: [
      {
        type: 'category',
        boundaryGap: false,
        data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
      }
    ],
    yAxis: [
      {
        type: 'value',
        name: '销售额(元)',
        position: 'left'
      },
      {
        type: 'value',
        name: '订单数',
        position: 'right'
      }
    ],
    series: [
      {
        name: '销售额',
        type: 'line',
        smooth: true,
        itemStyle: { color: '#1890ff' },
        data: [12000, 15000, 13200, 18500, 22000, 25600, 19800]
      },
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        itemStyle: { color: '#52c41a' },
        data: [45, 67, 52, 78, 89, 95, 76]
      }
    ]
  };
  chart.setOption(option);
};

// 初始化商品销量图
const initProductsChart = () => {
  if (!productsChart.value) return;
  
  const chart = echarts.init(productsChart.value);
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value'
    },
    yAxis: {
      type: 'category',
      data: ['商品J', '商品I', '商品H', '商品G', '商品F', '商品E', '商品D', '商品C', '商品B', '商品A']
    },
    series: [
      {
        type: 'bar',
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        },
        data: [120, 145, 160, 180, 195, 220, 245, 280, 320, 380]
      }
    ]
  };
  chart.setOption(option);
};

// 初始化客户来源图
const initSourceChart = () => {
  if (!sourceChart.value) return;
  
  const chart = echarts.init(sourceChart.value);
  const option = {
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        type: 'pie',
        radius: '70%',
        data: [
          { value: 35, name: '直接访问' },
          { value: 25, name: '搜索引擎' },
          { value: 20, name: '社交媒体' },
          { value: 12, name: '广告推广' },
          { value: 8, name: '其他' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  };
  chart.setOption(option);
};

// 初始化订单状态图
const initOrderStatusChart = () => {
  if (!orderStatusChart.value) return;
  
  const chart = echarts.init(orderStatusChart.value);
  const option = {
    tooltip: {
      trigger: 'item'
    },
    series: [
      {
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '20',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: [
          { value: 45, name: '已完成', itemStyle: { color: '#52c41a' } },
          { value: 25, name: '进行中', itemStyle: { color: '#1890ff' } },
          { value: 20, name: '待发货', itemStyle: { color: '#faad14' } },
          { value: 10, name: '已取消', itemStyle: { color: '#ff4d4f' } }
        ]
      }
    ]
  };
  chart.setOption(option);
};

// 导出数据
const exportData = () => {
  // 这里可以实现导出功能
  console.log('导出数据功能待实现');
};

// 初始化所有图表
const initAllCharts = async () => {
  await nextTick();
  initSalesChart();
  initProductsChart();
  initSourceChart();
  initOrderStatusChart();
};

// 监听销售周期变化
watch(salesPeriod, () => {
  initSalesChart();
});

onMounted(() => {
  initAllCharts();
});
</script>

<style scoped>
.data-analysis-container {
  padding: 24px;
  background: #f0f2f5;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.page-description {
  margin: 0;
  color: #666;
  font-size: 14px;
}

/* 统计卡片网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 64px;
  height: 64px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: white;
}

.stat-icon.sales { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.stat-icon.orders { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
.stat-icon.customers { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.stat-icon.conversion { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #333;
  line-height: 1.2;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin: 4px 0;
}

.stat-change {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: 12px;
}

.stat-change.positive {
  color: #52c41a;
  background: #f6ffed;
}

.stat-change.negative {
  color: #ff4d4f;
  background: #fff1f0;
}

/* 图表网格 */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.chart-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.chart-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.chart-container {
  width: 100%;
  height: 300px;
  padding: 20px;
}

/* 数据表格部分 */
.data-table-section {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.amount-cell {
  font-weight: 600;
  color: #1890ff;
}

.growth-cell {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
}

.growth-cell.positive {
  color: #52c41a;
}

.growth-cell.negative {
  color: #ff4d4f;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .data-analysis-container {
    padding: 16px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .charts-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .chart-container {
    height: 250px;
  }
}
</style>