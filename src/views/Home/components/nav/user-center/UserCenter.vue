<template>
  <HomeNavbar />
  <div class="user-center-page">


    <div class="user-center-container">
      <div class="user-center-wrapper">
        <aside class="user-center-sidebar">
          <div class="sidebar-header">个人中心</div>
          <ul class="sidebar-menu">
            <li :class="{ active: activeKey === 'basic' }" @click="setActive('basic')">基本信息</li>
            <li :class="{ active: activeKey === 'address' }" @click="setActive('address')">收货地址</li>
            <li :class="{ active: activeKey === 'orders' }" @click="setActive('orders')">我的订单</li>
            <li :class="{ active: activeKey === 'favorites' }" @click="setActive('favorites')">我的收藏</li>
            <li :class="{ active: activeKey === 'posts' }" @click="setActive('posts')">我的帖子</li>
            <li :class="{ active: activeKey === 'settings' }" @click="setActive('settings')">账户设置</li>
          </ul>
        </aside>

        <section class="user-center-content">
          <component :is="activeComponent" />
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import HomeNavbar from '@/views/Home/components/HomeNavbar.vue'

// 内嵌功能页
import Address from '@/views/Home/components/nav/address/Address.vue'
import OrderList from '@/views/Home/components/nav/orders/OrderList.vue'
import Favorites from '@/views/Home/components/nav/favorites/Favorites.vue'
import AccountProfile from '@/views/Home/components/nav/personal/AccountProfile.vue'

// 本页简单子组件
import BasicInfo from './BasicInfo.vue'
import MyPosts from './MyPosts.vue'

const activeKey = ref('basic')
const setActive = (key) => {
  activeKey.value = key
}

const componentMap = {
  basic: BasicInfo,
  address: Address,
  orders: OrderList,
  favorites: Favorites,
  posts: MyPosts,
  settings: AccountProfile,
}

const activeComponent = computed(() => componentMap[activeKey.value] || BasicInfo)
</script>

<style>
:root {
  --primary-color: #5c9e53;
  --secondary-color: #f7faf5;
  --hover-color: #e6f0e6;
  --text-muted-color: #6b7a63;
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
  --sidebar-width: 260px;
  --header-height: 80px;
}

.user-center-page {
  background: var(--secondary-color);
  min-height: 100vh;
  padding-top: 30px;
}

.user-center-container {
  padding-top: var(--header-height);
  padding-bottom: 24px;
  display: flex;
  min-height: calc(100vh - var(--header-height));
}

.user-center-wrapper {
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
  display: flex;
  gap: 24px;
  padding: 0 24px;
}

.user-center-sidebar {
  background: #fff;
  border: 1px solid var(--border-color);
  border-radius: 16px;
  box-shadow: 0 6px 20px var(--shadow-color);
  padding: 24px 0;
  width: var(--sidebar-width);
  min-width: var(--sidebar-width);
  height: calc(100vh - var(--header-height) - 48px);
  position: sticky;
  top: 24px;
  align-self: flex-start;
  transition: all 0.3s ease;
}

.sidebar-header {
  color: #3b4a30;
  font-weight: 700;
  font-size: 1.25rem;
  padding: 0 24px 16px;
  margin-bottom: 16px;
  border-bottom: 2px solid var(--border-color);
  position: relative;
}

.sidebar-header::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 24px;
  width: 40px;
  height: 2px;
  background: var(--primary-color);
  border-radius: 2px;
}

.sidebar-menu {
  list-style: none;
  padding: 0;
  margin: 0;
}

.sidebar-menu li {
  cursor: pointer;
  padding: 14px 24px;
  color: #3b4a30;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-left: 4px solid transparent;
  position: relative;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 12px;
}

.sidebar-menu li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background: var(--primary-color);
  opacity: 0;
  transition: opacity 0.3s ease;
  border-radius: 0 8px 8px 0;
  z-index: -1;
}

.sidebar-menu li:hover {
  background: transparent;
  color: var(--primary-color);
  transform: translateX(4px);
}

.sidebar-menu li:hover::before {
  opacity: 0.08;
}

.sidebar-menu li.active {
  background: var(--hover-color);
  border-left-color: var(--primary-color);
  font-weight: 600;
  color: var(--primary-color);
}

.sidebar-menu li.active::after {
  content: '';
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 6px;
  height: 6px;
  background: var(--primary-color);
  border-radius: 50%;
}

.sidebar-menu li.active:hover {
  transform: none;
}

/* 图标样式 */
.sidebar-menu li[data-key="basic"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f007';
  font-weight: 900;
}

.sidebar-menu li[data-key="address"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f3c5';
  font-weight: 900;
}

.sidebar-menu li[data-key="orders"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f291';
  font-weight: 900;
}

.sidebar-menu li[data-key="favorites"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f004';
  font-weight: 900;
}

.sidebar-menu li[data-key="posts"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f0f6';
  font-weight: 900;
}

.sidebar-menu li[data-key="settings"]::before {
  font-family: 'Font Awesome 5 Free';
  content: '\f013';
  font-weight: 900;
}

.user-center-content {
  background: #fff;
  border: 1px solid var(--border-color);
  border-radius: 16px;
  box-shadow: 0 6px 20px var(--shadow-color);
  padding: 28px;
  flex: 1;
  min-height: 60vh;
  transition: all 0.3s ease;
}

.user-center-content:hover {
  box-shadow: 0 8px 25px var(--shadow-color);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .user-center-wrapper {
    max-width: 100%;
    padding: 0 16px;
  }

  :root {
    --sidebar-width: 220px;
  }
}

@media (max-width: 992px) {
  .user-center-wrapper {
    flex-direction: column;
  }

  .user-center-sidebar {
    width: 100%;
    min-width: auto;
    height: auto;
    position: relative;
    top: 0;
    border-radius: 12px;
  }

  .sidebar-menu {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    padding: 16px;
  }

  .sidebar-menu li {
    padding: 12px 16px;
    border-radius: 8px;
    border-left: none;
    justify-content: center;
    text-align: center;
  }

  .sidebar-menu li:hover {
    transform: translateY(-2px);
  }

  .sidebar-menu li::before {
    display: none;
  }

  .user-center-content {
    border-radius: 12px;
    padding: 20px;
  }
}

@media (max-width: 576px) {
  .sidebar-menu {
    grid-template-columns: 1fr;
  }

  .user-center-container {
    padding-top: 70px;
  }

  :root {
    --header-height: 70px;
  }

  .user-center-sidebar {
    padding: 16px 0;
  }

  .sidebar-header {
    padding: 0 16px 12px;
    font-size: 1.1rem;
  }

  .user-center-content {
    padding: 16px;
  }
}

/* 滚动条样式优化 */
.user-center-sidebar::-webkit-scrollbar {
  width: 6px;
}

.user-center-sidebar::-webkit-scrollbar-track {
  background: transparent;
}

.user-center-sidebar::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 3px;
}

.user-center-sidebar::-webkit-scrollbar-thumb:hover {
  background: var(--text-muted-color);
}

/* 加载动画 */
.user-center-content {
  animation: fadeIn 0.4s ease-out;
}

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

/* 悬停阴影效果 */
.user-center-sidebar:hover {
  box-shadow: 0 8px 25px var(--shadow-color);
}
</style>
