<template>
  <GlobalLoading v-if="isLoading" />
  <div
      v-else
      class="admin-layout admin-scope fade-in"
      :class="[
      themeScopeClass,
      { 'sidebar-fully-collapsed': sidebarFullyCollapsed }
    ]"
      :data-theme="activeTheme"
  >
    <!-- 侧边栏 -->
    <Sidebar
        :sidebar-collapsed="sidebarCollapsed"
        :sidebar-fully-collapsed="sidebarFullyCollapsed"
        :active-menu="activeMenu"
        :open-menu="openMenu"
        :main-menu="mainMenu"
        :system-menu="systemMenu"
        @menu-click="handleMenuClick"
        @toggle-sidebar="toggleSidebar"
    />

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 顶部导航栏 -->
      <Navbar
          :active-menu-label="activeMenuLabel"
          :sidebar-fully-collapsed="sidebarFullyCollapsed"
          :active-theme="activeTheme"  @toggle-sidebar-completely="toggleSidebarCompletely"
          @toggle-theme-panel="toggleThemePanel"
      />

      <!-- 标签页导航栏 -->
      <TabsBar />

      <!-- 页面视图 -->
      <main class="page-content">
        <Dashboard
            v-if="activeMenu === 'analysis'"
            :active-theme="activeTheme"
        />
        <RealTimeMonitor v-if="activeMenu === 'monitor'" />
        <UserManagement v-if="activeMenu === 'user-list'" />
        <AddressManagement v-if="activeMenu === 'user-address'" />
        <SellerCertificationAdmin v-if="activeMenu === 'seller-cert'" />
        <CategoryManagement v-if="activeMenu === 'category'" />
        <ProductList v-if="activeMenu === 'product-list'" />
        <ImageVerification v-if="activeMenu === 'product-images'" />
        <OrderManagement v-if="activeMenu === 'order-list'" />
        <PaymentRecords v-if="activeMenu === 'payment'" />
        <ReviewManagement v-if="activeMenu === 'review'" />
        <RoleManagement v-if="activeMenu === 'role'" />
        <AfterSaleManagement v-if="activeMenu === 'after-sale'" />
        <ContentModeration v-if="activeMenu === 'moderations'" />
        <MessageManagement v-if="activeMenu === 'notice'" />
        <SystemSettings v-if="activeMenu === 'system'" />
      </main>
    </div>


    <ThemeSettings
        :is-open="isThemePanelOpen"
        :active-theme="activeTheme"
        :active-scope="activeScope"
        @close="isThemePanelOpen = false"
        @set-theme="setTheme"
        @set-scope="setScope"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { storeToRefs } from 'pinia';
import { useTabStore } from '@/stores/tabStore';
import Sidebar from './components/Sidebar.vue';
import Navbar from './components/AdminNavbar.vue';
import TabsBar from './components/TabsBar.vue';
import GlobalLoading from './components/GlobalLoading.vue';
import UserManagement from './components/sidebarFunction/user/UserManagement.vue';
import RoleManagement from './components/sidebarFunction/RoleManagement.vue';
import MessageManagement from "@/views/Admin/components/adminMessage/MessageManagement.vue";
import { useLoading } from '@/services/loading.service';
import Dashboard from './components/Dashboard.vue';
import ThemeSettings from './components/ThemeSettings.vue';
import './assets/admin-styles.css';
import RealTimeMonitor from "@/views/Admin/components/RealTimeMonitor.vue";
import SellerCertificationAdmin from "@/views/Admin/components/sidebarFunction/seller-certification/SellerCertificationAdmin.vue";
import CategoryManagement from "@/views/Admin/components/sidebarFunction/product/CategoryManagement.vue";
import AddressManagement from "@/views/Admin/components/sidebarFunction/user/AddressManagement.vue";
import ProductList from "@/views/Admin/components/sidebarFunction/product/ProductList.vue";
import ImageVerification from "@/views/Admin/components/sidebarFunction/product/ImageVerification.vue";
import AfterSaleManagement from "@/views/Admin/components/sidebarFunction/afterSales/AfterSaleManagement.vue";
import OrderManagement from "@/views/Admin/components/sidebarFunction/order/OrderManagement.vue";
import PaymentRecords from "@/views/Admin/components/sidebarFunction/order/PaymentRecords.vue";
import ReviewManagement from "@/views/Admin/components/sidebarFunction/review/ReviewManagement.vue";
import ContentModeration from "@/views/Admin/components/sidebarFunction/moderations/ContentModeration.vue";
import SystemSettings from "@/views/Admin/components/sidebarFunction/SystemSettings.vue";

const { isLoading, hideLoading } = useLoading();

// ===== 状态管理 (移除了 darkMode) =====
const sidebarCollapsed = ref(false);
const sidebarFullyCollapsed = ref(false); // 恢复此状态
const activeMenu = ref('analysis');
const openMenu = ref('dashboard');

// 新增：主题相关状态
const isThemePanelOpen = ref(false);
const activeTheme = ref('default');
const activeScope = ref('sidebar'); // 默认只应用到侧边栏

// ===== 菜单数据 (使用您原来的数据) =====
const mainMenu = ref([
  {
    key: 'dashboard',
    label: '控制台',
    icon: 'fas fa-tachometer-alt',
    children: [
      { key: 'analysis', label: '数据分析', icon: 'fas fa-chart-line' },
      { key: 'monitor', label: '实时监控', icon: 'fas fa-chart-bar' }
    ]
  },
  {
    key: 'user',
    label: '用户管理',
    icon: 'fas fa-users',
    children: [
      { key: 'user-list', label: '用户列表', icon: 'fas fa-user' },
      { key: 'user-address', label: '收货地址', icon: 'fas fa-map-marker' }
    ]
  },
  {
    key: 'seller',
    label: '商家管理',
    icon: 'fas fa-store',
    children: [
      { key: 'seller-cert', label: '商家认证', icon: 'fas fa-id-card' }
    ]
  },
  {
    key: 'product',
    label: '商品管理',
    icon: 'fas fa-box',
    children: [
      { key: 'category', label: '分类管理', icon: 'fas fa-tags' },
      { key: 'product-list', label: '商品列表', icon: 'fas fa-list' },
      { key: 'product-images', label: '图片审核', icon: 'fas fa-image' }
    ]
  },
  {
    key: 'order',
    label: '订单管理',
    icon: 'fas fa-shopping-cart',
    children: [
      { key: 'order-list', label: '订单列表', icon: 'fas fa-file-invoice' },
      { key: 'payment', label: '支付记录', icon: 'fas fa-credit-card' }
    ]
  }
]);

const systemMenu = ref([
  { key: 'review', label: '评价管理', icon: 'fas fa-star' },
  { key: 'after-sale', label: '售后服务', icon: 'fas fa-headset' },
  { key: 'community', label: '社区管理', icon: 'fas fa-comments' },
  { key: 'notice', label: '通知管理', icon: 'fas fa-check-circle' },
  { key: 'report', label: '举报管理', icon: 'fas fa-exclamation-triangle' },
  { key: 'moderations', label: '事务待办', icon: 'fas fa-tasks' },
  { key: 'role', label: '角色权限', icon: 'fas fa-user-tag' },
  { key: 'system', label: '系统设置', icon: 'fas fa-cog' }
]);

// ===== 计算属性 =====
const activeMenuLabel = computed(() => {
  const findLabel = (menu) => {
    for (const item of menu) {
      if (item.key === activeMenu.value) return item.label;
      if (item.children) {
        const childLabel = findLabel(item.children);
        if (childLabel) return childLabel;
      }
    }
    return null;
  };
  return findLabel(mainMenu.value) || findLabel(systemMenu.value) || 'Dashboard';
});

// 根据 activeScope 计算出要应用到根元素的类名
const themeScopeClass = computed(() => `theme-scope-${activeScope.value}`);

// ===== 标签页 =====
const tabStore = useTabStore();
watch(storeToRefs(tabStore).activeTab, (newTab) => {
  if (newTab) activeMenu.value = newTab;
});

// ===== 生命周期 =====
onMounted(() => {
  // 移除了 darkMode 的检查
  // 新增：加载保存的主题和作用域
  const savedTheme = localStorage.getItem('adminTheme') || 'default';
  const savedScope = localStorage.getItem('adminThemeScope') || 'sidebar';
  setTheme(savedTheme);
  setScope(savedScope);

  setTimeout(() => hideLoading(), 500);
});

// ===== 方法 =====
const handleMenuClick = (item) => {
  if (item.children?.length) {
    if (!sidebarCollapsed.value) {
      openMenu.value = openMenu.value === item.key ? '' : item.key;
    }
    // 在收起状态下，点击事件由 Sidebar 组件内部处理（弹出浮动菜单）
    return;
  }
  tabStore.addTab(item);
  activeMenu.value = item.key;
};

// 切换普通收起/展开
const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value;
  if (sidebarCollapsed.value) {
    sidebarFullyCollapsed.value = false;
  }
};

// 切换彻底收起/展开
const toggleSidebarCompletely = () => {
  sidebarFullyCollapsed.value = !sidebarFullyCollapsed.value;
  if (sidebarFullyCollapsed.value) {
    sidebarCollapsed.value = true;
  } else {
    sidebarCollapsed.value = false;
  }
};

// 新增：主题相关方法
const toggleThemePanel = () => {
  isThemePanelOpen.value = !isThemePanelOpen.value;
};

const setTheme = (themeName) => {
  activeTheme.value = themeName;
  document.documentElement.setAttribute('data-theme', themeName);
  localStorage.setItem('adminTheme', themeName);
};

const setScope = (scopeName) => {
  activeScope.value = scopeName;
  localStorage.setItem('adminThemeScope', scopeName);
};
</script>

<style scoped>
.page-content {
  flex-grow: 1;
  overflow-y: auto;
  padding: 1.5rem;
  background: var(--bg-secondary, #f7f9fc);
  /* 优化滚动条样式 */
  scrollbar-width: thin;
  scrollbar-color: var(--accent-color, #4a6cf7) transparent;
}

.page-content::-webkit-scrollbar {
  width: 6px;
}

.page-content::-webkit-scrollbar-track {
  background: transparent;
}

.page-content::-webkit-scrollbar-thumb {
  background: var(--accent-color, #4a6cf7);
  border-radius: 3px;
  opacity: 0.5;
}

.page-content::-webkit-scrollbar-thumb:hover {
  opacity: 0.8;
}

.admin-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
  background-color: var(--bg-secondary, #f7f9fc);
  font-family: var(--font-family-base, 'Inter', sans-serif);
  transition: all var(--transition-speed, 0.3s) ease;
}

.main-content {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: margin-left var(--transition-speed, 0.3s) ease;
  position: relative;
}

/* 为不同主题优化背景 */
.admin-layout[data-theme="glass"] {
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
}

.admin-layout[data-theme="tech"] {
  background: linear-gradient(135deg, #131a2b 0%, #0a0f1c 100%);
}

.admin-layout[data-theme="fresh"] {
  background: radial-gradient(circle at 10% 20%, rgba(236, 253, 245, 0.8) 0%, rgba(255, 255, 255, 0.9) 90%);
}

/* 当侧边栏彻底收起时，主内容区占据全部宽度 */
.admin-layout.sidebar-fully-collapsed .main-content {
  margin-left: 0;
}

/* 增强页面过渡动画 */
.fade-in {
  animation: fadeInLayout 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes fadeInLayout {
  from {
    opacity: 0;
    transform: scale(0.98);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

/* 响应式优化 */
@media (max-width: 768px) {
  .page-content {
    padding: 1rem;
  }
}

@media (max-width: 480px) {
  .page-content {
    padding: 0.75rem;
  }
}
</style>
