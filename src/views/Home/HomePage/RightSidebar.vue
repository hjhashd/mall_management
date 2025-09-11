<script setup>
// 使用 defineProps 接收 props，以便在 script 中访问
const props = defineProps({
  collapsed: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:collapsed']);

// 点击时，发送当前状态取反后的值
const toggleSidebar = () => {
  emit('update:collapsed', !props.collapsed);
};
</script>

<template>
  <aside class="right-sidebar" :class="{ 'collapsed': collapsed }">
    <div class="sidebar-toggle" @click="toggleSidebar">
      <i :class="collapsed ? 'fas fa-angle-double-left' : 'fas fa-angle-double-right'"></i>
    </div>
    <div class="sidebar-content" v-show="!collapsed">
      <div class="sidebar-block actions">
        <router-link to="/seller-layout" custom v-slot="{ navigate }">
          <button @click="navigate" class="btn btn-sell">我要卖</button>
        </router-link>
        <router-link to="/search"  class="btn btn-buy">我要买</router-link>
        <router-link to="/community" class="btn btn-request">求购专区</router-link>
      </div>
      <div class="sidebar-block info">
        <div class="info-card">我们致力于<br>帮助同学</div>
        <div class="info-card empty">闲置物品回收了<br>拜拜了主人</div>
        <router-link to="/seller-certification" class="info-card ad">
          <i class="fas fa-store fa-3x"></i>
          <p>认证成为卖家</p>
        </router-link>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.right-sidebar {
  height: 100vh;
  position: fixed;
  top: 0;
  right: 0;
  width: 250px;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-left: 1px solid var(--border-color);
  z-index: 100;
  transition: all 0.3s ease;
  padding-top: 60px; /* 假设有全局 header */
}
.right-sidebar.collapsed {
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
.actions {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 20px;
}
.btn {
  width: 100%;
  padding: 15px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  color: #fff;
  transition: all 0.3s;
  text-align: center;
  text-decoration: none;
  display: block;
}
.btn-sell { background: #f55; }
.btn-sell:hover { background: #e44; }
.btn-buy { background: #50e3c2; }
.btn-buy:hover { background: #41c4a5; }
.btn-request { background: #eee; color: #666; border: 1px dashed #ccc; }
.info-card {
  background-color: #f7faf5;
  border-radius: 8px;
  padding: 15px;
  font-size: 12px;
  line-height: 1.5;
  color: var(--text-muted-color);
  border: 1px solid var(--border-color);
  margin-bottom: 15px;
}
.info-card.ad {
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: all 0.2s ease;
  text-decoration: none;
}
.info-card.ad:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}
@media (max-width: 1200px) {
  .right-sidebar { width: 220px; }
}
@media (max-width: 992px) {
  .right-sidebar { display: none; }
}
</style>
