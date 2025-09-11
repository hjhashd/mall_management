<template>
  <aside
      class="sidebar"
      :class="{
      'is-collapsed': sidebarCollapsed,
      'is-fully-collapsed': sidebarFullyCollapsed
    }"
      @click.self="closeFloatingMenu"
  >
    <!-- Logo 区域 -->
    <div class="sidebar-header">
      <div class="logo">
        <i class="fas fa-rocket logo-icon"></i>
        <span class="logo-text">mini mall</span>
      </div>
    </div>

    <!-- 导航菜单 -->
    <div class="sidebar-menu">
      <!-- 主菜单 -->
      <ul class="menu-list">
        <li v-for="item in mainMenu" :key="item.key" class="menu-item">
          <a
              href="#"
              class="menu-link"
              :class="{ 'active': isMenuActive(item), 'has-children': item.children }"
              @click.prevent="handleMenuClick(item, $event)"
              :title="sidebarCollapsed ? item.label : ''"
          >
            <i :class="['menu-icon', item.icon]"></i>
            <span class="menu-label">{{ item.label }}</span>
            <i
                v-if="item.children && item.children.length && !sidebarCollapsed"
                class="fas fa-chevron-down menu-caret"
                :class="{ 'is-open': openMenu === item.key }"
            ></i>
          </a>
          <!-- 子菜单 (展开状态) -->
          <transition name="submenu">
            <ul v-if="openMenu === item.key && !sidebarCollapsed" class="submenu-list">
              <li v-for="child in item.children" :key="child.key">
                <a
                    href="#"
                    class="submenu-link"
                    :class="{ 'active': activeMenu === child.key }"
                    @click.prevent="handleFloatingMenuClick(child)"
                >
                  <span class="submenu-dot"></span>
                  <span class="submenu-label">{{ child.label }}</span>
                </a>
              </li>
            </ul>
          </transition>
        </li>
      </ul>

      <!-- 系统管理菜单 -->
      <div class="menu-divider"><span class="divider-text">System</span></div>
      <ul class="menu-list">
        <li v-for="item in systemMenu" :key="item.key" class="menu-item">
          <a
              href="#"
              class="menu-link"
              :class="{ 'active': activeMenu === item.key }"
              @click.prevent="handleFloatingMenuClick(item)"
              :title="sidebarCollapsed ? item.label : ''"
          >
            <i :class="['menu-icon', item.icon]"></i>
            <span class="menu-label">{{ item.label }}</span>
          </a>
        </li>
      </ul>
    </div>

    <!-- 底部折叠按钮 -->
    <div class="sidebar-footer">
      <button class="collapse-btn" @click="$emit('toggle-sidebar')" :title="sidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'">
        <i class="fas" :class="sidebarCollapsed && !sidebarFullyCollapsed ? 'fa-chevron-right' : 'fa-chevron-left'"></i>
        <span class="menu-label">Collapse Menu</span>
      </button>
    </div>

    <!-- 浮动子菜单 (收起状态) -->
    <transition
        name="floating-menu-anim"
        enter-active-class="animate__animated animate__fadeIn animate__faster"
        leave-active-class="animate__animated animate__fadeOut animate__faster"
    >
      <div
          v-if="showFloatingMenu"
          class="floating-menu"
          :style="{ top: floatingMenuPosition.top + 'px', left: floatingMenuPosition.left + 'px' }"
      >
        <div class="floating-menu-header">{{ floatingMenuTitle }}</div>
        <ul class="floating-menu-list">
          <li v-for="child in floatingMenuItems" :key="child.key">
            <a
                href="#"
                class="submenu-link"
                :class="{ 'active': activeMenu === child.key }"
                @click.prevent="handleFloatingMenuClick(child)"
            >
              <span class="submenu-dot"></span>
              <span class="submenu-label">{{ child.label }}</span>
            </a>
          </li>
        </ul>
      </div>
    </transition>
  </aside>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  sidebarCollapsed: { type: Boolean, required: true },
  sidebarFullyCollapsed: { type: Boolean, required: true },
  activeMenu: { type: String, required: true },
  openMenu: { type: String, required: true },
  mainMenu: { type: Array, required: true },
  systemMenu: { type: Array, required: true }
});

const emit = defineEmits(['menu-click', 'toggle-sidebar']);

// --- 浮动菜单逻辑 (来自您的原代码) ---
const showFloatingMenu = ref(false);
const floatingMenuItems = ref([]);
const floatingMenuTitle = ref('');
const floatingMenuPosition = ref({ top: 0, left: 0 });

const handleMenuClick = (item, event) => {
  // 如果侧边栏是收起状态 (is-collapsed) 且有子菜单
  if (props.sidebarCollapsed && !props.sidebarFullyCollapsed && item.children?.length) {
    const rect = event.currentTarget.getBoundingClientRect();
    floatingMenuPosition.value = {
      top: rect.top,
      left: rect.right + 10
    };

    // 如果点击的正是当前显示的浮动菜单，则关闭它
    if (showFloatingMenu.value && floatingMenuItems.value === item.children) {
      showFloatingMenu.value = false;
    } else {
      floatingMenuItems.value = item.children;
      floatingMenuTitle.value = item.label;
      showFloatingMenu.value = true;
    }
    return;
  }
  // 否则，执行默认的父组件点击事件
  emit('menu-click', item);
};

const handleFloatingMenuClick = (child) => {
  emit('menu-click', child);
  showFloatingMenu.value = false;
};

const closeFloatingMenu = () => {
  showFloatingMenu.value = false;
};

onMounted(() => window.addEventListener('resize', closeFloatingMenu));
onUnmounted(() => window.removeEventListener('resize', closeFloatingMenu));
// --- 浮动菜单逻辑结束 ---

const isMenuActive = (item) => {
  if (item.key === props.activeMenu) return true;
  if (item.children) {
    return item.children.some(child => child.key === props.activeMenu);
  }
  return false;
};
</script>

<style scoped>
/* --- 基础样式 (来自新设计) --- */
.sidebar {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  width: var(--sidebar-width-open);
  height: 100vh;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-color);
  transition: all var(--transition-speed) ease;
  z-index: 100;
  position: sticky;
  top: 0;
}
.sidebar.is-collapsed {
  width: var(--sidebar-width-collapsed);
}
.sidebar.is-fully-collapsed {
  width: 0;
  transform: translateX(-100%);
  padding: 0;
  border: none;
}

/* Logo */
.sidebar-header {
  display: flex; align-items: center; height: var(--navbar-height);
  padding: 0 1.5rem; border-bottom: 1px solid var(--border-color); flex-shrink: 0;
}
.logo { display: flex; align-items: center; gap: 0.75rem; overflow: hidden; white-space: nowrap; }
.logo-icon { font-size: 1.5rem; color: var(--accent-color); flex-shrink: 0; }
.logo-text { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); opacity: 1; transition: opacity 0.2s ease; }
.is-collapsed .logo-text { opacity: 0; }
.is-collapsed .logo { justify-content: center; width: 100%; }
.is-collapsed .sidebar-header { padding: 0; }

/* 菜单 */
.sidebar-menu {
  flex-grow: 1;
  overflow-y: auto;
  padding: 1rem 0;
  /* 添加了和主题一致的滚动条样式 */
  scrollbar-width: thin;
  scrollbar-color: var(--accent-color, #4a6cf7) transparent;
}
.sidebar-menu::-webkit-scrollbar {
  width: 6px;
}
.sidebar-menu::-webkit-scrollbar-track {
  background: transparent;
}
.sidebar-menu::-webkit-scrollbar-thumb {
  background: var(--accent-color, #4a6cf7);
  border-radius: 3px;
  opacity: 0.5;
}
.sidebar-menu::-webkit-scrollbar-thumb:hover {
  opacity: 0.8;
}

.menu-list { list-style: none; padding: 0 1rem; margin: 0; }
.menu-link { display: flex; align-items: center; padding: 0.75rem 1rem; border-radius: var(--border-radius-sm); margin-bottom: 0.25rem; color: var(--text-secondary); text-decoration: none; transition: all var(--transition-speed) ease; white-space: nowrap; position: relative; }
.menu-link:hover, .menu-link.active { background-color: var(--bg-hover); color: var(--accent-color); font-weight: 500; }
.menu-link.active::before { content: ''; position: absolute; left: -1rem; top: 0; height: 100%; width: 4px; background-color: var(--accent-color); border-top-right-radius: 4px; border-bottom-right-radius: 4px; }
.is-collapsed .menu-link.active::before { left: 0; }
.menu-icon { font-size: 1.1rem; width: 24px; text-align: center; margin-right: 1rem; transition: margin var(--transition-speed) ease; }
.is-collapsed .menu-icon { margin-right: 0; }
.menu-label { flex-grow: 1; opacity: 1; transition: opacity 0.2s ease; }
.is-collapsed .menu-label { opacity: 0; width: 0; }
.menu-caret { font-size: 0.75rem; transition: transform var(--transition-speed) ease, opacity 0.2s ease; }
.menu-caret.is-open { transform: rotate(180deg); }
.is-collapsed .menu-caret { opacity: 0; }

/* 子菜单 */
.submenu-list { list-style: none; padding-left: 2.75rem; margin-top: 0.5rem; overflow: hidden; }
.submenu-link { display: flex; align-items: center; padding: 0.6rem 0; color: var(--text-secondary); text-decoration: none; font-size: 0.9rem; transition: color 0.2s ease; width: 100%; border-radius: var(--border-radius-sm); }
.submenu-link:hover, .submenu-link.active { color: var(--accent-color); font-weight: 500; }
.floating-menu .submenu-link:hover { background-color: var(--bg-hover); }
.floating-menu .submenu-link { padding: 0.6rem 1rem; }
.submenu-dot { width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; margin-right: 0.75rem; opacity: 0.5; transition: all 0.2s ease; }
.submenu-link.active .submenu-dot { opacity: 1; transform: scale(1.2); }
.submenu-enter-active, .submenu-leave-active { transition: all 0.3s ease-in-out; max-height: 200px; }
.submenu-enter-from, .submenu-leave-to { opacity: 0; transform: translateY(-10px); max-height: 0; }

/* 分隔线 */
.menu-divider { padding: 1.5rem 2rem 0.5rem; white-space: nowrap; overflow: hidden; }
.divider-text { font-size: 0.75rem; text-transform: uppercase; color: var(--text-secondary); font-weight: 600; opacity: 1; transition: opacity 0.2s ease; }
.is-collapsed .divider-text { opacity: 0; }

/* 底部 */
.sidebar-footer { padding: 1rem; border-top: 1px solid var(--border-color); }
.collapse-btn { width: 100%; background: transparent; border: none; color: var(--text-secondary); display: flex; align-items: center; padding: 0.75rem 1rem; border-radius: var(--border-radius-sm); cursor: pointer; transition: all 0.2s ease; }
.collapse-btn:hover { background-color: var(--bg-hover); color: var(--accent-color); }
.is-collapsed .collapse-btn { justify-content: center; }

/* --- 浮动菜单样式 (新设计) --- */
.floating-menu {
  position: fixed;
  z-index: 1030;
  min-width: 200px;
  background-color: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-md);
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
  padding: 0.5rem;
}
.floating-menu-header {
  padding: 0.75rem 1rem;
  font-weight: 600;
  color: var(--text-primary);
  border-bottom: 1px solid var(--border-color);
  margin-bottom: 0.5rem;
}
.floating-menu-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
</style>
