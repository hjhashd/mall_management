<template>
  <div class="monitor-container">
    <!-- 头部标题 -->
    <div class="monitor-header animate-fade-in">
      <h1>系统实时监控</h1>
      <p>在这里，一切尽在掌握</p>
    </div>

    <!-- 核心指标网格 -->
    <div class="core-metrics-grid">
      <!-- CPU 使用率 -->
      <div class="metric-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-header">
          <h3>CPU 使用率</h3>
          <span class="status-indicator online"></span>
        </div>
        <div class="card-body">
          <v-chart class="gauge-chart" :option="cpuGaugeOption" autoresize />
          <div class="chart-label">
            <p>逻辑核心: <strong>{{ cpuCores }}</strong></p>
          </div>
        </div>
      </div>

      <!-- 内存占用 -->
      <div class="metric-card animate-slide-up" style="--delay: 0.2s;">
        <div class="card-header">
          <h3>内存占用</h3>
          <span class="status-indicator warning"></span>
        </div>
        <div class="card-body">
          <v-chart class="gauge-chart" :option="memoryGaugeOption" autoresize />
          <div class="chart-label">
            <p>已用: <strong>{{ memoryUsed.toFixed(2) }} GB</strong> / 总计: <strong>{{ memoryTotal }} GB</strong></p>
          </div>
        </div>
      </div>

      <!-- 服务器状态 -->
      <div class="server-status-card animate-slide-up" style="--delay: 0.3s;">
        <div class="card-header">
          <h3>服务器状态</h3>
        </div>
        <div class="card-body">
          <div class="status-light-container">
            <div class="status-light" :class="serverStatus.class"></div>
            <p class="status-text">{{ serverStatus.text }}</p>
          </div>
          <div class="server-info">
            <p><i class="fas fa-server"></i> IP: <strong>192.168.1.101</strong></p>
            <p><i class="fas fa-clock"></i> 运行时间: <strong>{{ uptime }}</strong></p>
          </div>
        </div>
      </div>
    </div>

    <!-- 实时流量与日志 -->
    <div class="main-grid">
      <!-- 实时网络流量 -->
      <div class="chart-container animate-slide-up" style="--delay: 0.4s;">
        <div class="chart-header">
          <h3>实时网络流量 (Mbps)</h3>
        </div>
        <v-chart class="chart" :option="networkChartOption" autoresize />
      </div>

      <!-- 系统日志 -->
      <div class="log-container animate-slide-up" style="--delay: 0.5s;">
        <div class="chart-header">
          <h3>系统实时日志</h3>
        </div>
        <ul class="log-feed" ref="logFeedRef">
          <li v-for="(log, index) in logs" :key="index" :class="`log-${log.type}`">
            <span class="log-time">{{ log.time }}</span>
            <span class="log-message">{{ log.message }}</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { GaugeChart, LineChart } from 'echarts/charts';
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
  CanvasRenderer, GaugeChart, LineChart,
  TitleComponent, TooltipComponent, LegendComponent, GridComponent,
]);

// --- 状态定义 ---
const cpuUsage = ref(0);
const memoryUsed = ref(0);
const memoryTotal = 16;
const cpuCores = 8;
const serverStatus = ref({ text: '运行流畅', class: 'online' });
const uptime = ref('0天 0小时 0分钟');
const logs = ref([]);
const logFeedRef = ref(null);

let intervalId = null;

// --- ECharts 配置 ---

// CPU 仪表盘配置
const cpuGaugeOption = ref({
  series: [{
    type: 'gauge',
    startAngle: 180,
    endAngle: 0,
    min: 0,
    max: 100,
    splitNumber: 10,
    progress: { show: true, width: 18 },
    axisLine: { lineStyle: { width: 18 } },
    axisTick: { distance: -25, length: 5, lineStyle: { color: '#999' } },
    splitLine: { distance: -30, length: 12, lineStyle: { color: '#999' } },
    axisLabel: { distance: 5, color: '#999', fontSize: 12 },
    anchor: { show: true, showAbove: true, size: 20, itemStyle: { borderWidth: 5 } },
    pointer: { icon: 'path://M2.9,0.7L2.9,0.7c1.4,0,2.6,1.2,2.6,2.6v115c0,1.4-1.2,2.6-2.6,2.6l0,0c-1.4,0-2.6-1.2-2.6-2.6V3.3C0.3,1.9,1.4,0.7,2.9,0.7z', width: 8, length: '60%', offsetCenter: [0, '-10%'] },
    detail: { valueAnimation: true, fontSize: 30, color: 'inherit', formatter: '{value}%' },
    data: [{ value: 0 }],
    title: { show: false },
    itemStyle: {
      color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
        { offset: 0, color: '#58D68D' },
        { offset: 0.5, color: '#F4D03F' },
        { offset: 1, color: '#E74C3C' }
      ])
    }
  }]
});

// 内存仪表盘配置
const memoryGaugeOption = ref({
  ...cpuGaugeOption.value, // 复用大部分配置
  series: [{
    ...cpuGaugeOption.value.series[0],
    data: [{ value: 0 }],
    itemStyle: {
      color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
        { offset: 0, color: '#5DADE2' },
        { offset: 0.7, color: '#85C1E9' },
        { offset: 1, color: '#AED6F1' }
      ])
    }
  }]
});

// 网络流量图配置
const networkChartOption = ref({
  tooltip: { trigger: 'axis' },
  legend: { data: ['上传', '下载'], textStyle: { color: '#ccc' } },
  grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: Array.from({ length: 20 }, (_, i) => i),
    axisLine: { lineStyle: { color: 'rgba(255,255,255,0.2)' } },
    axisLabel: { color: '#ccc' },
  },
  yAxis: {
    type: 'value',
    axisLabel: { color: '#ccc' },
    splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } },
  },
  series: [
    {
      name: '上传', type: 'line', smooth: true,
      showSymbol: false,
      itemStyle: { color: '#9f78ff' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(159, 120, 255, 0.5)' },
          { offset: 1, color: 'rgba(159, 120, 255, 0)' }
        ])
      },
      data: [],
    },
    {
      name: '下载', type: 'line', smooth: true,
      showSymbol: false,
      itemStyle: { color: '#56d3f3' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(86, 211, 243, 0.5)' },
          { offset: 1, color: 'rgba(86, 211, 243, 0)' }
        ])
      },
      data: [],
    },
  ],
});


// --- 数据模拟 ---
const updateData = () => {
  // 更新 CPU
  cpuUsage.value = parseFloat((Math.random() * 80 + 10).toFixed(2));
  cpuGaugeOption.value.series[0].data[0].value = cpuUsage.value;

  // 更新内存
  memoryUsed.value = Math.random() * (memoryTotal - 4) + 4;
  const memoryPercentage = (memoryUsed.value / memoryTotal) * 100;
  memoryGaugeOption.value.series[0].data[0].value = parseFloat(memoryPercentage.toFixed(2));

  // 更新服务器状态
  const randStatus = Math.random();
  if (randStatus > 0.95) {
    serverStatus.value = { text: '高负载警告', class: 'warning' };
  } else if (randStatus < 0.02) {
    serverStatus.value = { text: '连接中断', class: 'offline' };
  } else {
    serverStatus.value = { text: '运行流畅', class: 'online' };
  }

  // 更新网络图数据
  const uploadData = networkChartOption.value.series[0].data;
  const downloadData = networkChartOption.value.series[1].data;
  uploadData.shift();
  downloadData.shift();
  uploadData.push(parseFloat((Math.random() * 30 + 5).toFixed(2)));
  downloadData.push(parseFloat((Math.random() * 80 + 20).toFixed(2)));

  // 更新日志
  const logTypes = ['info', 'warning', 'error'];
  const logMessages = [
    'User authentication successful for user "admin".',
    'API endpoint /api/v1/data processed successfully.',
    'Database connection pool health check passed.',
    'High CPU usage detected: 92%.',
    'Failed to connect to external service "payment-gateway".',
    'Invalid token provided for API request.'
  ];
  if (logs.value.length > 50) {
    logs.value.shift();
  }
  const newLog = {
    time: new Date().toLocaleTimeString(),
    type: logTypes[Math.floor(Math.random() * logTypes.length)],
    message: logMessages[Math.floor(Math.random() * logMessages.length)]
  };
  logs.value.push(newLog);

  // 滚动日志到底部
  nextTick(() => {
    if (logFeedRef.value) {
      logFeedRef.value.scrollTop = logFeedRef.value.scrollHeight;
    }
  });
};

// --- 生命周期钩子 ---
onMounted(() => {
  // 初始化网络图数据
  networkChartOption.value.series[0].data = Array.from({ length: 20 }, () => parseFloat((Math.random() * 30).toFixed(2)));
  networkChartOption.value.series[1].data = Array.from({ length: 20 }, () => parseFloat((Math.random() * 80).toFixed(2)));

  // 初始运行时间
  let seconds = 0;
  const updateUptime = () => {
    seconds++;
    const d = Math.floor(seconds / (3600 * 24));
    const h = Math.floor(seconds % (3600 * 24) / 3600);
    const m = Math.floor(seconds % 3600 / 60);
    uptime.value = `${d}天 ${h}小时 ${m}分钟`;
  };
  updateUptime();

  // 设置定时器
  intervalId = setInterval(() => {
    updateData();
    updateUptime();
  }, 2000);
});

onUnmounted(() => {
  clearInterval(intervalId);
});
</script>

<style scoped>
/* 整体布局和动画 */
.monitor-container {
  padding: 0;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary);
}

.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

.animate-slide-up {
  opacity: 0;
  animation: slideUp 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  animation-delay: var(--delay, 0s);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px) scale(0.95); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

/* 头部 */
.monitor-header {
  margin-bottom: 2rem;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.monitor-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--text-primary, #fff);
  margin: 0 0 0.5rem 0;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff) 0%, var(--accent-color-hover, #7c3aed) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.monitor-header p {
  font-size: 1.1rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0;
}

/* 网格布局 */
.core-metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.main-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1.5rem;
}

@media (max-width: 992px) {
  .main-grid {
    grid-template-columns: 1fr;
  }
}

/* 通用卡片样式 */
.metric-card, .server-status-card, .chart-container, .log-container {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  position: relative;
  overflow: hidden;
}

.metric-card:hover, .server-status-card:hover, .chart-container:hover, .log-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15));
  border-color: var(--accent-color, #9f78ff);
}

/* 卡片头部 */
.card-header, .chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.card-header h3, .chart-header h3 {
  color: var(--text-primary, #fff);
  font-size: 1.25rem;
  margin: 0;
  font-weight: 600;
}

/* 仪表盘图表 */
.gauge-chart {
  width: 100%;
  height: 200px;
}

.chart-label {
  text-align: center;
  color: var(--text-secondary, #a0a0b0);
  margin-top: -20px;
}

.chart-label strong {
  color: var(--text-primary, #fff);
  font-weight: 600;
}

/* 服务器状态卡片 */
.server-status-card .card-body {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 248px; /* 与仪表盘卡片高度对齐 */
}

.status-light-container {
  text-align: center;
  margin-bottom: 2rem;
}

.status-light {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto 1rem;
  position: relative;
  background-color: #333;
}

.status-light::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  height: 100%;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.status-light.online { background-color: #2ecc71; box-shadow: 0 0 25px #2ecc71; }
.status-light.online::before { background-color: #2ecc71; }
.status-light.warning { background-color: #f39c12; box-shadow: 0 0 25px #f39c12; }
.status-light.warning::before { background-color: #f39c12; }
.status-light.offline { background-color: #e74c3c; box-shadow: 0 0 25px #e74c3c; }
.status-light.offline::before { background-color: #e74c3c; }

@keyframes pulse {
  0% { transform: translate(-50%, -50%) scale(0.9); opacity: 0.7; }
  70% { transform: translate(-50%, -50%) scale(1.5); opacity: 0; }
  100% { transform: translate(-50%, -50%) scale(0.9); opacity: 0; }
}

.status-text {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--text-primary, #fff);
}

.server-info {
  width: 100%;
  font-size: 0.9rem;
  color: var(--text-secondary, #a0a0b0);
}

.server-info p {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0.5rem 0;
}

.server-info i {
  color: var(--accent-color, #9f78ff);
}

/* 网络流量图 */
.chart-container .chart {
  width: 100%;
  height: 350px;
}

/* 日志模块 */
.log-container {
  height: 426px; /* 与流量图高度对齐 */
}
.log-feed {
  list-style: none;
  padding: 0;
  margin: 0;
  height: 320px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--accent-color, #9f78ff) transparent;
}

.log-feed::-webkit-scrollbar { width: 4px; }
.log-feed::-webkit-scrollbar-track { background: transparent; }
.log-feed::-webkit-scrollbar-thumb { background: var(--accent-color, #9f78ff); border-radius: 2px; }

.log-feed li {
  display: flex;
  gap: 1rem;
  padding: 0.5rem 0.75rem;
  border-radius: var(--border-radius-sm, 8px);
  margin-bottom: 0.5rem;
  font-size: 0.85rem;
  font-family: 'Courier New', Courier, monospace;
  animation: log-entry 0.5s ease forwards;
}

@keyframes log-entry {
  from { opacity: 0; transform: translateX(-10px); }
  to { opacity: 1; transform: translateX(0); }
}

.log-time {
  color: var(--text-secondary, #a0a0b0);
}

.log-info .log-message { color: #5dade2; }
.log-warning .log-message { color: #f39c12; }
.log-error .log-message { color: #e74c3c; }
</style>
