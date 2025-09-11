<script setup>
// 使用 defineProps 接收 props，以便在 script 中访问
const props = defineProps({
  categories: {
    type: Array,
    default: () => []
  },
  activeCategory: {
    type: Number,
    default: 0
  },
  collapsed: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:activeCategory', 'update:collapsed']);

const setActiveCategory = (categoryId) => {
  emit('update:activeCategory', categoryId);
};

// 点击时，发送当前状态取反后的值
const toggleSidebar = () => {
  emit('update:collapsed', !props.collapsed);
};

const getCategoryIcon = (categoryId) => {
  const icons = {
    1: 'fas fa-mobile-alt', 2: 'fas fa-laptop', 3: 'fas fa-film',
    4: 'fas fa-microchip', 5: 'fas fa-dumbbell', 6: 'fas fa-tshirt',
    7: 'fas fa-palette', 8: 'fas fa-book', 9: 'fas fa-bus',
    10: 'fas fa-user-tie'
  };
  return icons[categoryId] || 'fas fa-th';
};
</script>

<template>
  <aside class="left-sidebar" :class="{ 'collapsed': collapsed }">
    <div class="sidebar-toggle" @click="toggleSidebar">
      <i :class="collapsed ? 'fas fa-angle-double-right' : 'fas fa-angle-double-left'"></i>
    </div>
    <div class="sidebar-content" v-show="!collapsed">
      <div class="sidebar-block categories">
        <h3>全部商品</h3>
        <ul>
          <li v-for="category in categories"
              :key="category.categoryId"
              :class="{ 'active': activeCategory === category.categoryId }"
              @click="setActiveCategory(category.categoryId)">
            <i :class="getCategoryIcon(category.categoryId)"></i>
            <span>{{ category.categoryName }}</span>
          </li>
        </ul>
      </div>
      <div class="sidebar-block recommendation">
        <h4>推荐阅读</h4>
        <ul>
          <li><a href="#">校园二手市场布局与商品规则</a></li>
          <li><a href="#">校园二手市场账号注册规则</a></li>
          <li><a href="#">关于校园二手市场平台</a></li>
        </ul>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.left-sidebar {
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  width: 250px;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-right: 1px solid var(--border-color);
  z-index: 100;
  transition: all 0.3s ease;
  padding-top: 60px; /* 假设有全局 header */
}
.left-sidebar.collapsed {
  width: 40px;
}
.sidebar-toggle {
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--primary-color);
  color: white;
  cursor: pointer;
  transition: background-color 0.2s;
}
.sidebar-toggle:hover {
  background: #46783a;
}
.sidebar-content {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}
.categories h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: #3b4a30;
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 10px;
  margin: 0 0 10px 0;
}
.categories ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.categories li {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--text-muted-color);
  font-size: 14px;
}
.categories li:hover {
  background-color: var(--hover-color);
  color: var(--primary-color);
}
.categories li.active {
  background-color: var(--hover-color);
  color: var(--primary-color);
  font-weight: 500;
}
.categories li i {
  margin-right: 15px;
  width: 20px;
  text-align: center;
}
.recommendation h4 {
  font-size: 1rem;
  font-weight: 600;
  color: #3b4a30;
  margin: 20px 0 10px 0;
}
.recommendation ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.recommendation li {
  font-size: 13px;
  margin-bottom: 8px;
}
.recommendation a {
  color: var(--text-muted-color);
  text-decoration: none;
}
.recommendation a:hover {
  color: var(--primary-color);
}
@media (max-width: 1200px) {
  .left-sidebar { width: 220px; }
}
@media (max-width: 768px) {
  .left-sidebar { width: 40px; }
  .left-sidebar:not(.collapsed) { width: 200px; }
}
</style>
