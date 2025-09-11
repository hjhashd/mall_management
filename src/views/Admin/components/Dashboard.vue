<template>
  <div class="dashboard-container">
    <div class="welcome-header animate-fade-in">
      <h1>欢迎回来!</h1>
      <p>至高无上的Admin在此刻回到了他忠实的工作区</p>
    </div>

    <div class="stats-grid">
      <div class="stat-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-icon icon-sales">
          <i class="fas fa-dollar-sign"></i>
        </div>
        <div class="card-content">
          <p class="card-title">今日销售额</p>
          <h2 class="card-value" ref="salesValueRef">¥ 12,860</h2>
          <span class="card-trend positive">
            <i class="fas fa-arrow-up"></i> +15% vs 昨日
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.2s;">
        <div class="card-icon icon-users">
          <i class="fas fa-users"></i>
        </div>
        <div class="card-content">
          <p class="card-title">新增用户</p>
          <h2 class="card-value" ref="usersValueRef">321</h2>
          <span class="card-trend positive">
            <i class="fas fa-arrow-up"></i> +8% vs 昨日
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.3s;">
        <div class="card-icon icon-orders">
          <i class="fas fa-shopping-cart"></i>
        </div>
        <div class="card-content">
          <p class="card-title">今日订单</p>
          <h2 class="card-value" ref="ordersValueRef">56</h2>
          <span class="card-trend negative">
            <i class="fas fa-arrow-down"></i> -3% vs 昨日
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.4s;">
        <div class="card-icon icon-feedback">
          <i class="fas fa-comment-dots"></i>
        </div>
        <div class="card-content">
          <p class="card-title">待处理反馈</p>
          <h2 class="card-value" ref="feedbackValueRef">12</h2>
          <span class="card-trend">
            <i class="fas fa-minus"></i> 与昨日持平
          </span>
        </div>
      </div>
    </div>

    <div class="main-grid">
      <div class="chart-container main-chart animate-slide-up" style="--delay: 0.5s;">
        <div class="chart-header">
          <h3>销售与访问趋势</h3>
        </div>
        <v-chart class="chart" :option="lineChartOption" autoresize />
      </div>

      <div class="side-panel animate-slide-up" style="--delay: 0.6s;">
        <div class="chart-header">
          <h3>实时动态</h3>
        </div>
        <ul class="activity-feed">
          <li>
            <div class="feed-icon"><i class="fas fa-user-plus"></i></div>
            <div class="feed-content">
              <p>用户 "李*" 刚刚注册成功。</p>
              <span>1分钟前</span>
            </div>
          </li>
          <li>
            <div class="feed-icon"><i class="fas fa-shopping-bag"></i></div>
            <div class="feed-content">
              <p>来自上海的订单 #20250823001 已支付。</p>
              <span>3分钟前</span>
            </div>
          </li>
          <li>
            <div class="feed-icon"><i class="fas fa-star"></i></div>
            <div class="feed-content">
              <p>商品 "智能降噪耳机" 收到一条五星好评。</p>
              <span>15分钟前</span>
            </div>
          </li>
          <li>
            <div class="feed-icon"><i class="fas fa-box"></i></div>
            <div class="feed-content">
              <p>商家 "潮流前线" 上架了3件新商品。</p>
              <span>30分钟前</span>
            </div>
          </li>
        </ul>
      </div>

      <div class="chart-container small-chart animate-slide-up" style="--delay: 0.7s;">
        <div class="chart-header">
          <h3>热门产品分类</h3>
        </div>
        <v-chart class="chart" :option="barChartOption" autoresize />
      </div>

      <div class="chart-container small-chart animate-slide-up" style="--delay: 0.8s;">
        <div class="chart-header">
          <h3>用户设备分布</h3>
        </div>
        <v-chart class="chart" :option="pieChartOption" autoresize />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart, PieChart, BarChart } from 'echarts/charts';
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
} from 'echarts/components';
import VChart from 'vue-echarts';
import * as echarts from 'echarts/core';

// ECharts 按需引入
use([
  CanvasRenderer, LineChart, PieChart, BarChart,
  TitleComponent, TooltipComponent, LegendComponent, GridComponent,
]);

// --- 动态数字动画 ---
const salesValueRef = ref(null);
const usersValueRef = ref(null);
const ordersValueRef = ref(null);
const feedbackValueRef = ref(null);

const animateValue = (ref, start, end, duration) => {
  if (!ref.value) return; // 增加保护
  let startTimestamp = null;
  const step = (timestamp) => {
    if (!startTimestamp) startTimestamp = timestamp;
    const progress = Math.min((timestamp - startTimestamp) / duration, 1);
    const value = Math.floor(progress * (end - start) + start).toLocaleString();
    if (ref.value) { // 再次检查
      ref.value.innerText = value;
    }
    if (progress < 1) {
      window.requestAnimationFrame(step);
    }
  };
  window.requestAnimationFrame(step);
};
onMounted(() => {
  // 触发数字滚动动画
  animateValue(salesValueRef, 0, 12860, 1500);
  animateValue(usersValueRef, 0, 321, 1500);
  animateValue(ordersValueRef, 0, 56, 1500);
  animateValue(feedbackValueRef, 0, 12, 1500);
});


// --- ECharts 配置 ---
const lineChartOption = ref({
  tooltip: {trigger: 'axis'},
  legend: {data: ['销售额', '访问量'], textStyle: {color: '#ccc'}},
  grid: {left: '3%', right: '4%', bottom: '3%', containLabel: true},
  xAxis: {
    type: 'category', boundaryGap: false,
    data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    axisLine: {lineStyle: {color: 'rgba(255,255,255,0.2)'}},
    axisLabel: {color: '#ccc'},
  },
  yAxis: {
    type: 'value',
    axisLabel: {color: '#ccc'},
    splitLine: {lineStyle: {color: 'rgba(255,255,255,0.1)'}},
  },
  series: [
    {
      name: '销售额', type: 'line', smooth: true,
      itemStyle: {color: '#9f78ff'},
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          {offset: 0, color: 'rgba(159, 120, 255, 0.5)'},
          {offset: 1, color: 'rgba(159, 120, 255, 0)'}
        ])
      },
      data: [120, 132, 101, 134, 90, 230, 210],
    },
    {
      name: '访问量', type: 'line', smooth: true,
      itemStyle: {color: '#56d3f3'},
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          {offset: 0, color: 'rgba(86, 211, 243, 0.5)'},
          {offset: 1, color: 'rgba(86, 211, 243, 0)'}
        ])
      },
      data: [220, 182, 191, 234, 290, 330, 310],
    },
  ],
});

const pieChartOption = ref({
  tooltip: {trigger: 'item'},
  legend: {
    orient: 'vertical', left: 'left',
    textStyle: {color: '#ccc'},
  },
  series: [{
    name: '设备分布', type: 'pie', radius: ['50%', '70%'],
    avoidLabelOverlap: false,
    label: {show: false, position: 'center'},
    emphasis: {label: {show: true, fontSize: '20', fontWeight: 'bold'}},
    data: [
      {value: 1048, name: 'PC端', itemStyle: {color: '#9f78ff'}},
      {value: 735, name: '移动端', itemStyle: {color: '#56d3f3'}},
      {value: 580, name: '平板', itemStyle: {color: '#ffc76c'}},
    ],
  }],
});

const barChartOption = ref({
  tooltip: {trigger: 'axis', axisPointer: {type: 'shadow'}},
  grid: {left: '3%', right: '4%', bottom: '3%', containLabel: true},
  xAxis: {
    type: 'value', boundaryGap: [0, 0.01],
    axisLabel: {color: '#ccc'},
    splitLine: {show: false},
  },
  yAxis: {
    type: 'category',
    data: ['电子产品', '服装', '家居', '美妆'],
    axisLabel: {color: '#ccc'},
  },
  series: [{
    name: '销售量', type: 'bar',
    data: [182, 234, 290, 340],
    itemStyle: {
      color: 'rgba(159, 120, 255, 0.8)',
      borderRadius: 5,
    },
  }],
});
</script>

<style scoped>
/* 整体背景和字体 */
.dashboard-container {
  padding: 0;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary);
}

/* 欢迎语 */
.welcome-header {
  margin-bottom: 2rem;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.welcome-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--text-primary, #fff);
  margin: 0 0 0.5rem 0;
  background: var(--accent-color, #9f78ff);
  background: linear-gradient(135deg, var(--accent-color, #9f78ff) 0%, var(--accent-color-hover, #7c3aed) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.welcome-header p {
  font-size: 1.1rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0;
  opacity: 0.9;
}

/* 布局网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.main-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 1.5rem;
}

.main-chart {
  grid-column: 1 / 9;
}

.side-panel {
  grid-column: 9 / 13;
  grid-row: 1 / 3;
}

.small-chart {
  grid-column: 1 / 9;
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .main-chart {
    grid-column: 1 / 13;
  }

  .side-panel {
    grid-column: 1 / 13;
    grid-row: 2;
  }

  .small-chart:nth-of-type(3) {
    grid-column: 1 / 7;
    grid-row: 3;
  }

  .small-chart:nth-of-type(4) {
    grid-column: 7 / 13;
    grid-row: 3;
  }
}

@media (max-width: 768px) {
  .small-chart:nth-of-type(3) {
    grid-column: 1 / 13;
    grid-row: 3;
  }

  .small-chart:nth-of-type(4) {
    grid-column: 1 / 13;
    grid-row: 4;
  }
}


/* 卡片样式 - 适配主题系统 */
.stat-card, .chart-container, .side-panel {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  -webkit-backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  position: relative;
  overflow: hidden;
}

.stat-card:hover, .chart-container:hover, .side-panel:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15));
  border-color: var(--accent-color, #9f78ff);
}

/* 卡片内部微光效果 */
.stat-card::before, .chart-container::before, .side-panel::before {
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

.stat-card:hover::before, .chart-container:hover::before, .side-panel:hover::before {
  left: 100%;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.card-icon {
  font-size: 2rem;
  padding: 1rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
}

.icon-sales {
  background: linear-gradient(135deg, rgba(159, 120, 255, 0.2), rgba(124, 58, 237, 0.1));
  color: var(--accent-color, #9f78ff);
  border: 1px solid rgba(159, 120, 255, 0.3);
}

.icon-users {
  background: linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(14, 165, 233, 0.1));
  color: #38bdf8;
  border: 1px solid rgba(56, 189, 248, 0.3);
}

.icon-orders {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.1));
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.icon-feedback {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(220, 38, 38, 0.1));
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
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
  background: linear-gradient(135deg, var(--text-primary, #fff) 0%, var(--accent-color, #9f78ff) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.card-trend {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.card-trend.positive {
  color: #10b981;
}

.card-trend.negative {
  color: var(--danger-color, #ef4444);
}

.card-trend i {
  font-size: 0.75rem;
}

/* 图表容器 */
.chart-header {
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.chart-header h3 {
  color: var(--text-primary, #fff);
  font-size: 1.25rem;
  margin: 0;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.chart-header h3::before {
  content: '';
  width: 4px;
  height: 20px;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  border-radius: 2px;
}

.chart {
  width: 100%;
  height: 300px;
  border-radius: var(--border-radius-sm, 8px);
  overflow: hidden;
}

.main-chart .chart {
  height: 380px;
}

/* 实时动态模块 */
.activity-feed {
  list-style: none;
  padding: 0;
  margin: 0;
  height: 380px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--accent-color, #9f78ff) transparent;
}

.activity-feed::-webkit-scrollbar {
  width: 4px;
}

.activity-feed::-webkit-scrollbar-track {
  background: transparent;
}

.activity-feed::-webkit-scrollbar-thumb {
  background: var(--accent-color, #9f78ff);
  border-radius: 2px;
}

.activity-feed li {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  border-radius: var(--border-radius-sm, 8px);
  background: var(--bg-hover, rgba(255, 255, 255, 0.02));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.05));
  transition: all var(--transition-speed, 0.3s) ease;
}

.activity-feed li:hover {
  background: var(--bg-hover, rgba(255, 255, 255, 0.05));
  transform: translateX(4px);
}

.feed-icon {
  flex-shrink: 0;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
  font-size: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.feed-content {
  flex: 1;
  min-width: 0;
}

.feed-content p {
  margin: 0 0 0.25rem;
  font-size: 0.9rem;
  color: var(--text-primary, #e0e0e0);
  line-height: 1.4;
  font-weight: 500;
}

.feed-content span {
  font-size: 0.8rem;
  color: var(--text-secondary, #a0a0b0);
  font-weight: 400;
}


/* 动效增强 */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
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

/* 数值动画增强 */
.card-value {
  transition: all 0.3s ease;
}

.card-value:hover {
  transform: scale(1.05);
}

/* 主题适配增强 */
@media (prefers-reduced-motion: reduce) {
  .animate-fade-in,
  .animate-slide-up,
  .stat-card,
  .chart-container,
  .side-panel,
  .activity-feed li {
    animation: none;
    transition: none;
  }
}

/* 暗色主题优化 */
[data-theme="glass"] .dashboard-container,
[data-theme="tech"] .dashboard-container {
  --chart-grid-color: rgba(255, 255, 255, 0.1);
  --chart-text-color: rgba(255, 255, 255, 0.8);
}

/* 亮色主题优化 */
[data-theme="default"] .dashboard-container,
[data-theme="fresh"] .dashboard-container,
[data-theme="google"] .dashboard-container {
  --chart-grid-color: rgba(0, 0, 0, 0.1);
  --chart-text-color: rgba(0, 0, 0, 0.8);
}
</style>
