<template>
  <div class="shop-info-section">
    <h2><i class="fas fa-store-alt"></i> 我的店铺</h2>

    <div class="shop-stats">
      <div class="stat-card" v-for="(stat, index) in stats" :key="index">
        <i :class="stat.icon + ' fa-2x'" :style="{ color: stat.color }"></i>
        <div class="value">{{ stat.value }}</div>
        <div class="label">{{ stat.label }}</div>
      </div>
    </div>

    <div class="shop-actions">
      <button class="btn btn-primary" @click="$emit('analyze')">
        <i class="fas fa-chart-line"></i> 店铺数据分析
      </button>
      <router-link to="/seller-layout" class="btn btn-outline" @click="$emit('settings')">
        <i class="fas fa-cog"></i> 店铺设置
      </router-link>
      <router-link to="/seller-order" class="btn btn-outline" @click="$emit('logistics')">
        <i class="fas fa-truck"></i> 物流设置
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ShopInfo',
  props: {
    stats: {
      type: Array,
      required: true
    }
  },
  emits: ['analyze', 'settings', 'logistics']
}
</script>

<style scoped>
.shop-info-section {
  background: #fff;
  border-radius: 16px;
  padding: 25px;
  margin-bottom: 30px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
}

.shop-info-section h2 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 10px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}

.shop-info-section h2 i {
  margin-right: 10px;
  color: var(--primary-color);
}

.shop-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 25px;
}

.stat-card {
  background: var(--secondary-color);
  border-radius: 12px;
  padding: 20px;
  text-align: center;
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-card .value {
  font-size: 32px;
  font-weight: 700;
  color: var(--primary-color);
  margin: 10px 0;
}

.stat-card .label {
  color: var(--text-muted-color);
  font-size: 14px;
}

.shop-actions {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

/* 注意：.btn 和 .btn-primary 的样式现在由父组件的全局样式提供 */
/* 这里只定义该组件特有的按钮样式 */
.btn-outline {
  background: transparent;
  border: 2px solid var(--primary-color);
  color: var(--primary-color);
}

.btn-outline:hover {
  background-color: var(--hover-color);
}
</style>
