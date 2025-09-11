<template>
  <nav class="admin-navbar">
    <!-- 左侧区域 -->
    <div class="navbar-left">
      <!-- 侧边栏切换按钮 (现在控制彻底收起) -->
      <button
          @click="$emit('toggle-sidebar-completely')"
          class="action-btn"
          :class="{ 'active': sidebarFullyCollapsed }"
          title="Toggle Sidebar"
      >
        <i class="fas fa-bars"></i>
      </button>

      <!-- 面包屑导航 -->
      <nav aria-label="breadcrumb" class="breadcrumb-nav">
        <ol class="breadcrumb-list">
          <li class="breadcrumb-item"><a href="#">Dashboard</a></li>
          <li class="breadcrumb-item active">{{ activeMenuLabel }}</li>
        </ol>
      </nav>
    </div>

    <!-- 右侧功能区 -->
    <div class="navbar-right">
      <!-- 搜索框 -->
      <div class="search-form">
        <i class="fas fa-search search-icon"></i>
        <input type="text" class="search-input" placeholder="Search...">
      </div>

      <!-- 功能按钮 -->
      <button class="action-btn" title="Notifications">
        <i class="fas fa-bell"></i>
        <span class="notification-badge">5</span>
      </button>
      <button class="action-btn" title="Language">
        <i class="fas fa-globe"></i>
      </button>

      <!--主题设置按钮 -->
      <button class="action-btn" title="主题设置" @click.stop="$emit('toggle-theme-panel')">
        <i class="fas fa-palette"></i>
      </button>

      <!-- 用户菜单按钮 -->
      <button class="user-btn" @click.stop="userMenuOpen = !userMenuOpen">
        <div class="user-avatar">
          <img v-if="userStore.userInfo?.avatarPath"
               :src="userStore.userInfo.avatarPath"
               :alt="userStore.userInfo?.username || '用户头像'"
               class="avatar-image"
               @error="showDefaultAvatar = true">
          <i v-else class="fas fa-user"></i>
          <span class="status-indicator"></span>
        </div>
        <span class="user-name d-none d-md-inline">{{ userStore.userInfo?.username || '用户' }}</span>
        <i class="fas fa-chevron-down user-caret" :class="{ 'is-open': userMenuOpen }"></i>
      </button>
    </div>

    <!-- 用户菜单模态框 -->
    <teleport to="body">
      <div v-if="userMenuOpen" class="user-menu-modal" @click="userMenuOpen = false">
        <div class="user-menu-content" @click.stop>
          <div class="user-menu-header">
            <div class="user-avatar large">
              <img v-if="userStore.userInfo?.avatarPath"
                   :src="userStore.userInfo.avatarPath"
                   :alt="userStore.userInfo?.username || '用户头像'"
                   class="avatar-image"
                   @error="showDefaultAvatar = true">
              <i v-else class="fas fa-user"></i>
            </div>
            <div class="user-info">
              <h6 class="user-info-name">{{ userStore.userInfo?.username || '用户' }}</h6>
              <p class="user-info-role">Administrator</p>
            </div>
            <button class="close-btn" @click="userMenuOpen = false">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="user-menu-body">
            <a class="menu-item" href="#" @click="userMenuOpen = false">
              <i class="fas fa-user-circle"></i>
              <span>个人资料</span>
            </a>
            <a class="menu-item" href="#" @click="userMenuOpen = false">
              <i class="fas fa-cog"></i>
              <span>系统设置</span>
            </a>
            <div class="menu-divider"></div>
            <router-link class="menu-item danger" to="/">
              <i class="fas fa-sign-out-alt"></i>
              <span>返回首页</span>
            </router-link>
            <a class="menu-item danger" href="#" @click.prevent="handleLogout">
              <i class="fas fa-sign-out-alt"></i>
              <span>退出登录</span>
            </a>
          </div>
        </div>
      </div>
    </teleport>
  </nav>
</template>

<script setup>
import { ref } from 'vue'
import { useUserStore } from '@/stores/userStore'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

defineProps({
  activeTheme: {
    type: String,
    default: 'default'
  },
  activeMenuLabel: { type: String, required: true },
  sidebarFullyCollapsed: { type: Boolean, required: true }
});

defineEmits(['toggle-sidebar-completely', 'toggle-theme-panel']);

const userMenuOpen = ref(false);

const handleLogout = () => {
  userStore.logout()
  userMenuOpen.value = false;
  // 跳转到首页
  router.push('/')
};

// vClickOutside is not needed for the teleported modal,
// as the modal background click handles closing.
</script>

<style scoped>
/* --- Existing Styles (No changes needed here) --- */
.admin-navbar { display: flex; align-items: center; justify-content: space-between; height: var(--navbar-height); padding: 0 1.5rem; background-color: var(--bg-primary); border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 1200; }
.navbar-left { display: flex; align-items: center; gap: 1rem; }
.breadcrumb-list { display: flex; align-items: center; list-style: none; padding: 0; margin: 0; }
.breadcrumb-item { display: flex; align-items: center; font-size: 0.95rem; color: var(--text-secondary); }
.breadcrumb-item a { color: var(--text-secondary); text-decoration: none; transition: color 0.2s ease; }
.breadcrumb-item a:hover { color: var(--accent-color); }
.breadcrumb-item.active { color: var(--text-primary); font-weight: 500; }
.breadcrumb-item + .breadcrumb-item::before { content: '\f054'; font-family: 'Font Awesome 5 Free'; font-weight: 900; font-size: 0.6rem; margin: 0 0.75rem; color: var(--text-secondary); opacity: 0.5; }
.navbar-right { display: flex; align-items: center; gap: 0.75rem; }
.search-form { position: relative; display: none; }
@media (min-width: 992px) { .search-form { display: block; } }
.search-input { width: 220px; height: 42px; border-radius: var(--border-radius-sm); border: 1px solid var(--border-color); background-color: var(--bg-secondary); padding: 0 1rem 0 2.5rem; color: var(--text-primary); transition: all 0.2s ease; }
.search-input:focus { outline: none; border-color: var(--accent-color); box-shadow: 0 0 0 3px var(--shadow-color); }
.search-icon { position: absolute; left: 0.85rem; top: 50%; transform: translateY(-50%); color: var(--text-secondary); }
.action-btn { display: flex; align-items: center; justify-content: center; width: 42px; height: 42px; border-radius: var(--border-radius-sm); background: transparent; border: none; color: var(--text-secondary); font-size: 1.1rem; cursor: pointer; position: relative; transition: all 0.2s ease; }
.action-btn:hover { background-color: var(--bg-hover); color: var(--accent-color); }
.action-btn.active { background-color: var(--bg-hover); color: var(--accent-color); }
.notification-badge { position: absolute; top: 6px; right: 6px; min-width: 18px; height: 18px; border-radius: 9px; background-color: #ef4444; color: white; font-size: 0.7rem; font-weight: 600; display: flex; align-items: center; justify-content: center; padding: 0 4px; border: 2px solid var(--bg-primary); }
.user-btn { display: flex; align-items: center; gap: 0.75rem; background: transparent; border: none; padding: 5px 10px; border-radius: var(--border-radius-md); cursor: pointer; transition: background-color 0.2s ease; }
.user-btn:hover { background-color: var(--bg-hover); }
.user-avatar { position: relative; width: 40px; height: 40px; border-radius: 50%; background-color: var(--accent-color); color: white; display: flex; align-items: center; justify-content: center; overflow: hidden; }
.avatar-image { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.status-indicator { position: absolute; bottom: 0; right: 0; width: 12px; height: 12px; border-radius: 50%; background-color: #22c55e; border: 2px solid var(--bg-primary); }
.user-name { font-weight: 500; color: var(--text-primary); }
.user-caret { color: var(--text-secondary); transition: transform 0.3s ease; }
.user-caret.is-open { transform: rotate(180deg); }

/* --- START: ADDED STYLES FOR USER MENU --- */
/* This is the full-screen overlay */
.user-menu-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.4); /* Semi-transparent background */
  display: flex;
  justify-content: flex-end; /* Align the menu panel to the right */
  z-index: 1300; /* Make sure it's on top of everything */
}

/* This is the white panel that slides in */
.user-menu-content {
  width: 320px;
  height: 100%;
  background-color: var(--bg-primary);
  box-shadow: -5px 0 25px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  animation: slideInFromRight 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}

@keyframes slideInFromRight {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}

.user-menu-header {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid var(--border-color);
  flex-shrink: 0;
  position: relative;
}

.user-menu-header .user-avatar.large {
  width: 50px;
  height: 50px;
  font-size: 1.5rem;
  margin-right: 1rem;
}

.user-info-name {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0;
  color: var(--text-primary);
}

.user-info-role {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin: 0;
}

.close-btn {
  position: absolute;
  top: 0.75rem;
  right: 1rem;
  background: none;
  border: none;
  font-size: 1.75rem;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0.5rem;
  line-height: 1;
}

.user-menu-body {
  padding: 1rem;
  flex-grow: 1;
  overflow-y: auto;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.85rem 1rem;
  border-radius: var(--border-radius-md);
  text-decoration: none;
  color: var(--text-secondary);
  font-size: 0.95rem;
  transition: all 0.2s ease;
  cursor: pointer;
}

.menu-item i {
  width: 20px;
  text-align: center;
  font-size: 1.1rem;
}

.menu-item:hover {
  background-color: var(--bg-hover);
  color: var(--accent-color);
}

.menu-item.danger:hover {
  color: #ef4444;
  background-color: rgba(239, 68, 68, 0.1);
}

.menu-divider {
  height: 1px;
  margin: 0.75rem 1rem;
  background-color: var(--border-color);
}
/* --- END: ADDED STYLES FOR USER MENU --- */
</style>
