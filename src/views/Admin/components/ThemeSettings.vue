<template>
  <div class="theme-settings-panel" :class="{ 'is-open': isOpen }">
    <div class="panel-header">
      <h4>主题设置</h4>
      <button class="close-btn" @click="$emit('close')">&times;</button>
    </div>
    <div class="panel-body">
      <!-- 主题选择 -->
      <div>
        <h5 class="setting-title">主题风格</h5>
        <p class="description">选择一个您喜欢的主题风格。</p>
        <div class="theme-options">
          <div
              v-for="theme in themes"
              :key="theme.id"
              class="theme-card"
              :class="{ 'active': activeTheme === theme.id }"
              @click="$emit('set-theme', theme.id)"
          >
            <div class="theme-preview" :style="{ background: theme.preview.bg, color: theme.preview.accent }">
              <div class="preview-sidebar" :style="{ backgroundColor: theme.preview.sidebar }"></div>
              <div class="preview-content">
                <div class="preview-navbar" :style="{ borderColor: theme.preview.accent }"></div>
                <div class="preview-block"></div>
                <div class="preview-block small"></div>
              </div>
            </div>
            <span class="theme-name">{{ theme.name }}</span>
          </div>
        </div>
      </div>

      <!-- 新增：应用范围设置 -->
      <div class="scope-settings">
        <h5 class="setting-title">应用范围</h5>
        <p class="description">选择主题在哪些区域生效。</p>
        <div class="scope-options">
          <label
              v-for="scope in scopes"
              :key="scope.id"
              class="scope-label"
              :class="{ 'active': activeScope === scope.id }"
          >
            <input
                type="radio"
                name="theme-scope"
                :value="scope.id"
                :checked="activeScope === scope.id"
                @change="$emit('set-scope', scope.id)"
            >
            <i :class="['scope-icon', scope.icon]"></i>
            <span class="scope-name">{{ scope.name }}</span>
          </label>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

defineProps({
  isOpen: { type: Boolean, default: false },
  activeTheme: { type: String, required: true },
  activeScope: { type: String, required: true }
});

defineEmits(['close', 'set-theme', 'set-scope']);

const themes = ref([
  { id: 'default', name: '简洁风', preview: { bg: '#f7f9fc', sidebar: '#ffffff', accent: '#4a6cf7' } },
  { id: 'glass', name: '毛玻璃', preview: { bg: 'rgba(100, 100, 150, 0.1)', sidebar: 'rgba(255, 255, 255, 0.1)', accent: '#60a5fa' } },
  { id: 'tech', name: '科技感', preview: { bg: '#0f172a', sidebar: '#1e293b', accent: '#00ffff' } },
  { id: 'fresh', name: '清新风', preview: { bg: '#f0f9ff', sidebar: '#ffffff', accent: '#34d399' } },
  { id: 'volcanic-orange', name: '火山橙', preview: { bg: '#f8fafc', sidebar: '#ffffff', accent: '#F56510' } },
  { id: 'rose-gold', name: '烟粉', preview: { bg: '#f7f2f3', sidebar: '#fdfafb', accent: '#c08497' } },
]);

const scopes = ref([
  { id: 'sidebar', name: '仅侧边栏', icon: 'fas fa-columns' },
  { id: 'navbar', name: '仅导航栏', icon: 'fas fa-credit-card' },
  { id: 'layout', name: '侧边栏与导航栏', icon: 'fas fa-layer-group' },
  { id: 'global', name: '全局应用', icon: 'fas fa-globe-asia' },
]);
</script>

<style scoped>
/* ... 原有样式 ... */
.panel-body {
  padding: 1.5rem;
  overflow-y: auto;
  flex-grow: 1;
}
.setting-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}
.description {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 1.5rem;
  line-height: 1.6;
}
.scope-settings {
  margin-top: 2.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border-color);
}
.scope-options {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.scope-label {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
  border-radius: var(--border-radius-md);
  border: 1px solid var(--border-color);
  cursor: pointer;
  transition: all 0.2s ease;
}
.scope-label:hover {
  background-color: var(--bg-hover);
  border-color: var(--accent-color);
}
.scope-label.active {
  background-color: var(--bg-hover);
  border-color: var(--accent-color);
  color: var(--accent-color);
  font-weight: 500;
}
.scope-label input[type="radio"] {
  display: none;
}
.scope-icon {
  width: 24px;
  text-align: center;
  margin-right: 0.75rem;
  font-size: 1rem;
}
.scope-name {
  font-size: 0.9rem;
}
/* ... 样式保持不变 ... */
.theme-settings-panel {
  position: fixed;
  top: 0;
  right: 0;
  width: 320px;
  height: 100%;
  background-color: var(--bg-primary);
  border-left: 1px solid var(--border-color);
  box-shadow: -5px 0 25px rgba(0,0,0,0.1);
  transform: translateX(100%);
  transition: transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  z-index: 1100;
  display: flex;
  flex-direction: column;
}

.theme-settings-panel.is-open {
  transform: translateX(0);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--border-color);
  flex-shrink: 0;
}

.panel-header h4 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--text-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.75rem;
  color: var(--text-secondary);
  cursor: pointer;
  line-height: 1;
}

.panel-body {
  padding: 1.5rem;
  overflow-y: auto;
  flex-grow: 1;
}

.description {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 2rem;
  line-height: 1.6;
}

.theme-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.theme-card {
  cursor: pointer;
  border: 2px solid transparent;
  border-radius: var(--border-radius-md);
  padding: 4px;
  transition: all 0.2s ease;
}

.theme-card.active {
  border-color: var(--accent-color);
}

.theme-preview {
  height: 80px;
  border-radius: var(--border-radius-sm);
  padding: 8px;
  display: flex;
  overflow: hidden;
  border: 1px solid var(--border-color);
}

.preview-sidebar {
  width: 30%;
  height: 100%;
  border-radius: 4px;
  flex-shrink: 0;
}

.preview-content {
  width: 70%;
  padding-left: 8px;
}

.preview-navbar {
  height: 15%;
  width: 100%;
  border-bottom: 2px solid;
  margin-bottom: 8px;
}

.preview-block {
  height: 30%;
  width: 80%;
  background-color: var(--border-color);
  border-radius: 4px;
  margin-bottom: 8px;
}
.preview-block.small {
  width: 50%;
  height: 15%;
}

.theme-name {
  display: block;
  text-align: center;
  margin-top: 0.75rem;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--text-primary);
}
</style>
