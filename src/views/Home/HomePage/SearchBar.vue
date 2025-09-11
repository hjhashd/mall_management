<script setup>
import { ref } from 'vue';

const emit = defineEmits(['search', 'recommend']);
const searchQuery = ref('');

const handleSearch = () => {
  emit('search', searchQuery.value);
};

const quickSearch = (term) => {
  searchQuery.value = term;
  handleSearch();
};

// 新增：触发推荐事件
const handleRecommend = () => {
  emit('recommend');
};
</script>

<template>
  <div class="search-bar-container">
    <div class="search-bar">
      <div class="search-icon"><i class="fas fa-search"></i></div>
      <input
          type="text"
          placeholder="搜索你想要的商品..."
          v-model="searchQuery"
          @keyup.enter="handleSearch"
          class="search-input"
      />
      <button @click="handleSearch" class="search-button">
        <span>搜索</span>
        <i class="fas fa-arrow-right"></i>
      </button>
    </div>
    <div class="bottom-actions">
      <div class="hot-searches">
        <span>热门:</span>
        <a href="#" @click.prevent="quickSearch('手机')">手机</a>
        <a href="#" @click.prevent="quickSearch('电脑')">电脑</a>
        <a href="#" @click.prevent="quickSearch('影视')">影视</a>
        <a href="#" @click.prevent="quickSearch('数码配件')">数码配件</a>
        <a href="#" @click.prevent="quickSearch('运动健身')">运动健身</a>
      </div>
      <!-- 新增AI推荐按钮 -->
      <button @click="handleRecommend" class="btn-ai-recommend">
        <i class="fas fa-wand-magic-sparkles"></i>
        <span>AI推荐</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.search-bar-container {
  background: #fff;
  border-radius: 16px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 10px 30px var(--shadow-color);
  transition: all 0.3s ease;
  position: relative; /* 添加相对定位 */
}
.search-bar-container:hover {
  box-shadow: 0 15px 35px rgba(92, 158, 83, 0.15);
}
.search-bar {
  display: flex;
  align-items: center;
  background-color: #fff;
  border-radius: 50px;
  overflow: hidden;
  border: 2px solid var(--primary-color);
  box-shadow: 0 4px 20px rgba(92, 158, 83, 0.1);
  transition: all 0.3s ease;
  height: 60px;
}
.search-bar:focus-within {
  box-shadow: 0 6px 25px rgba(92, 158, 83, 0.2);
  border-color: #46783a;
}
.search-icon {
  padding: 0 20px;
  color: var(--primary-color);
  font-size: 18px;
}
.search-input {
  border: none;
  padding: 0 15px;
  font-size: 16px;
  background: transparent;
  width: 100%;
  outline: none;
  height: 100%;
  color: #3b4a30;
}
.search-input::placeholder {
  color: #a8b8a0;
}
.search-button {
  background: var(--primary-color);
  color: #fff;
  border: none;
  padding: 0 25px;
  height: 100%;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 10px;
}
.search-button:hover {
  background: #46783a;
  padding-right: 30px;
}
.search-button i {
  transition: transform 0.3s ease;
}
.search-button:hover i {
  transform: translateX(5px);
}
.bottom-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
}
.hot-searches {
  font-size: 14px;
  color: var(--text-muted-color);
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}
.hot-searches span {
  font-weight: 500;
}
.hot-searches a {
  color: var(--text-muted-color);
  text-decoration: none;
  transition: all 0.2s ease;
  padding: 5px 10px;
  border-radius: 15px;
}
.hot-searches a:hover {
  color: var(--primary-color);
  background: rgba(92, 158, 83, 0.1);
}
.btn-ai-recommend {
  background: linear-gradient(45deg, #5c9e53, #46783a);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 8px 18px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}
.btn-ai-recommend:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(92, 158, 83, 0.3);
}
.btn-ai-recommend i {
  font-size: 16px;
}

@media (max-width: 768px) {
  .search-bar-container { padding: 15px; }
  .search-bar { flex-direction: column; height: auto; }
  .search-input { padding: 10px 15px; font-size: 14px; height: 50px; }
  .search-button { width: 100%; justify-content: center; height: 50px; }
  .bottom-actions { flex-direction: column; gap: 15px; align-items: flex-start; }
  .hot-searches { font-size: 12px; }
}
</style>
