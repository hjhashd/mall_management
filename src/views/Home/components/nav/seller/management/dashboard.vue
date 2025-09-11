<template>
  <div class="dashboard-container">
    <a-space direction="vertical" :size="24" style="width: 100%">
      <!-- 统计卡片 -->
      <a-row :gutter="[24, 24]">
        <a-col v-for="stat in stats" :key="stat.title" :xs="24" :sm="12" :xl="6">
          <a-card :bordered="false" class="statistic-card">
            <a-statistic
                :title="stat.title"
                :value="stat.value"
                :precision="stat.precision"
                :prefix="stat.prefix"
            >
              <template #formatter="{ value }">
                <span>{{ stat.prefix }}{{ value.toLocaleString() }}</span>
              </template>
            </a-statistic>
            <div class="statistic-footer">
              <a-tag :color="stat.change > 0 ? 'green' : 'red'">
                <template #icon>
                  <arrow-up-outlined v-if="stat.change > 0" />
                  <arrow-down-outlined v-else />
                </template>
                {{ Math.abs(stat.change) }}%
              </a-tag>
              <span class="footer-text">vs 昨日</span>
            </div>
            <div class="statistic-icon" :style="{ backgroundColor: stat.iconBgColor }">
              <component :is="stat.icon" :style="{ color: stat.iconColor }" />
            </div>
          </a-card>
        </a-col>
      </a-row>

      <!-- 图表和排行榜 -->
      <a-row :gutter="[24, 24]">
        <!-- 销售总览图表 -->
        <a-col :xs="24" :lg="16">
          <a-card :bordered="false" title="销售总览">
            <template #extra>
              <a-radio-group v-model:value="chartInterval" size="small">
                <a-radio-button value="week">周</a-radio-button>
                <a-radio-button value="month">月</a-radio-button>
                <a-radio-button value="year">年</a-radio-button>
              </a-radio-group>
            </template>
            <v-chart class="chart" :option="chartOption" autoresize />
          </a-card>
        </a-col>

        <!-- 商品销售排行 -->
        <a-col :xs="24" :lg="8">
          <a-card :bordered="false" title="商品销售排行">
            <a-list :data-source="topProducts">
              <template #renderItem="{ item }">
                <a-list-item>
                  <a-list-item-meta>
                    <template #avatar>
                      <a-avatar :src="item.image" shape="square" :size="48" />
                    </template>
                    <template #title>{{ item.name }}</template>
                    <template #description>销量: {{ item.sales }}</template>
                  </a-list-item-meta>
                  <div class="product-revenue">¥{{ item.revenue.toLocaleString() }}</div>
                </a-list-item>
              </template>
            </a-list>
          </a-card>
        </a-col>
      </a-row>

      <!-- 最近订单表格 -->
      <a-row>
        <a-col :span="24">
          <a-card :bordered="false" title="最近订单">
            <template #extra><a href="#">查看全部</a></template>
            <a-table :columns="orderColumns" :data-source="recentOrders" :pagination="false">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'status'">
                  <a-tag :color="getStatusColor(record.status)">{{ record.status }}</a-tag>
                </template>
                <template v-if="column.key === 'amount'">
                  <span>¥{{ record.amount.toLocaleString() }}</span>
                </template>
                <template v-if="column.key === 'action'">
                  <a href="#">查看详情</a>
                </template>
              </template>
            </a-table>
          </a-card>
        </a-col>
      </a-row>
    </a-space>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import {
  ArrowUpOutlined,
  ArrowDownOutlined,
  DollarOutlined,
  ShoppingCartOutlined,
  UserOutlined,
  CreditCardOutlined
} from '@ant-design/icons-vue';

// --- ECharts 按需引入 ---
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart } from 'echarts/charts';
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
} from 'echarts/components';
import VChart from 'vue-echarts';

use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
]);

// --- 响应式数据 ---
const chartInterval = ref('month');

// --- 模拟数据 ---

// 1. 统计卡片数据
const stats = ref([
  { title: '今日销售额', value: 12860, precision: 2, prefix: '¥', change: 12.5, icon: DollarOutlined, iconColor: '#4f46e5', iconBgColor: '#eef2ff' },
  { title: '今日订单数', value: 352, precision: 0, prefix: '', change: 8.2, icon: ShoppingCartOutlined, iconColor: '#0ea5e9', iconBgColor: '#f0f9ff' },
  { title: '新增客户', value: 86, precision: 0, prefix: '', change: -2.1, icon: UserOutlined, iconColor: '#10b981', iconBgColor: '#f0fdf4' },
  { title: '待处理订单', value: 18, precision: 0, prefix: '', change: 5.9, icon: CreditCardOutlined, iconColor: '#f97316', iconBgColor: '#fff7ed' }
]);

// 2. 顶级销售商品数据
const topProducts = ref([
  { id: 1, name: '舒适棉质T恤', sales: 1250, revenue: 87500, image: 'https://placehold.co/100x100/f1f5f9/475569?text=T-Shirt' },
  { id: 2, name: '经典牛仔裤', sales: 980, revenue: 294000, image: 'https://placehold.co/100x100/e2e8f0/475569?text=Jeans' },
  { id: 3, name: '运动跑鞋', sales: 750, revenue: 450000, image: 'https://placehold.co/100x100/dbeafe/475569?text=Shoes' },
  { id: 4, name: '时尚双肩包', sales: 550, revenue: 192500, image: 'https://placehold.co/100x100/e0e7ff/475569?text=Bag' }
]);

// 3. 最近订单数据
const recentOrders = ref([
  { key: '1', id: '#10524', customer: '王伟', status: '已发货', amount: 350.00, date: '2023-10-28' },
  { key: '2', id: '#10523', customer: '李静', status: '待付款', amount: 128.50, date: '2023-10-28' },
  { key: '3', id: '#10522', customer: '张磊', status: '已完成', amount: 899.90, date: '2023-10-27' },
  { key: '4', id: '#10521', customer: '陈芳', status: '已退款', amount: 45.00, date: '2023-10-27' },
  { key: '5', id: '#10520', customer: '刘洋', status: '已完成', amount: 1200.00, date: '2023-10-26' },
]);

// Ant Design Table 列定义
const orderColumns = [
  { title: '订单号', dataIndex: 'id', key: 'id' },
  { title: '客户', dataIndex: 'customer', key: 'customer' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '金额', dataIndex: 'amount', key: 'amount' },
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '操作', key: 'action', align: 'center' },
];

// --- ECharts 配置 ---
const chartOption = computed(() => ({
  grid: { top: 20, right: 20, bottom: 40, left: 50 },
  xAxis: {
    type: 'category',
    data: ['一月', '二月', '三月', '四月', '五月', '六月', '七月'],
    axisLine: { lineStyle: { color: '#cccccc' } },
    axisLabel: { color: '#666666' }
  },
  yAxis: {
    type: 'value',
    axisLabel: {
      color: '#666666',
      formatter: '¥{value}'
    },
    splitLine: { lineStyle: { type: 'dashed' } }
  },
  tooltip: {
    trigger: 'axis',
    formatter: '销售额: ¥{c0}'
  },
  series: [
    {
      data: [6500, 5900, 8000, 8100, 5600, 9500, 12000],
      type: 'line',
      smooth: true,
      symbol: 'none',
      lineStyle: { color: '#4f46e5', width: 2 },
      areaStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [{
            offset: 0, color: 'rgba(79, 70, 229, 0.4)'
          }, {
            offset: 1, color: 'rgba(79, 70, 229, 0)'
          }]
        }
      }
    }
  ]
}));

// --- 方法 ---

// 根据订单状态返回不同的 antd 标签颜色
const getStatusColor = (status) => {
  const statusMap = {
    '已完成': 'success',
    '已发货': 'processing',
    '待付款': 'warning',
    '已退款': 'default',
  };
  return statusMap[status] || 'default';
};

</script>

<style scoped>
.dashboard-container {
  /* background-color: #f0f2f5; */ /* 如果父组件有背景色，可以移除 */
}

.statistic-card {
  position: relative;
  overflow: hidden;
}

.ant-statistic-title {
  color: #8c8c8c;
}

.ant-statistic-content {
  font-size: 28px;
}

.statistic-footer {
  margin-top: 12px;
  display: flex;
  align-items: center;
}
.footer-text {
  margin-left: 8px;
  color: #8c8c8c;
  font-size: 12px;
}

.statistic-icon {
  position: absolute;
  top: 24px;
  right: 24px;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.chart {
  height: 350px;
  width: 100%;
}
.product-revenue {
  font-weight: 500;
}
</style>

