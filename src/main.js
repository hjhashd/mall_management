import { createApp } from 'vue'
import App from './App.vue'
import './assets/css/community-styles.css';
import './assets/css/order-styles.css';
import './assets/css/chat-styles.css';
import Antd from 'ant-design-vue'
import { message, notification } from 'ant-design-vue';
import 'ant-design-vue/dist/reset.css'
import { createPinia } from 'pinia'
import router from './router'
import ECharts from 'vue-echarts'
import * as echarts from 'echarts'
import 'font-awesome/css/font-awesome.min.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
// 导入图标
import '@ant-design/icons-vue';

const app = createApp(App)

// 配置 message 全局默认值
message.config({
    top: '60px', // 距离顶部位置
    duration: 2, // 默认显示时长（秒）
    maxCount: 3, // 最多同时显示的提示数
});

// 配置 notification 全局默认值
notification.config({
    placement: 'bottomRight',
    duration: 4,
});

app.component('v-chart', ECharts)
app.use(Antd) // 完整导入所有组件
const pinia = createPinia()
app.use(pinia)

app.use(router).mount('#app')
