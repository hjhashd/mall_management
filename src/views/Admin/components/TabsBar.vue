<template>
  <div class="tabs-bar">
    <div class="tabs-container">
      <div
          v-for="tab in tabs"
          :key="tab.key"
          class="tab-item"
          :class="{ 'active': activeTab === tab.key }"
          @click="switchTab(tab.key)"
      >
        <i v-if="tab.icon" :class="['tab-icon', tab.icon]"></i>
        <span class="tab-label">{{ tab.label }}</span>
        <button
            v-if="tab.closable"
            class="close-btn"
            @click.stop="closeTab(tab.key)"
            title="Close Tab"
        >
          <i class="fas fa-times"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useTabStore } from '@/stores/tabStore';
import { storeToRefs } from 'pinia';

const tabStore = useTabStore();
const { tabs, activeTab } = storeToRefs(tabStore);
const { switchTab, closeTab } = tabStore;
</script>

<style scoped>
.tabs-bar {
  flex-shrink: 0;
  height: 45px;
  background-color: var(--bg-primary);
  border-bottom: 1px solid var(--border-color);
  padding: 0 1rem;
  box-shadow: 0 2px 5px rgba(0,0,0,0.02);
}

.tabs-container {
  display: flex;
  align-items: center;
  height: 100%;
  overflow-x: auto;
  -ms-overflow-style: none;  /* IE and Edge */
  scrollbar-width: none;  /* Firefox */
}

.tabs-container::-webkit-scrollbar {
  display: none; /* Chrome, Safari, Opera */
}

.tab-item {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 0 1.25rem;
  margin-right: 0.5rem;
  cursor: pointer;
  white-space: nowrap;
  font-size: 0.9rem;
  color: var(--text-secondary);
  border-bottom: 2px solid transparent;
  transition: all 0.2s ease-in-out;
  position: relative;
}

.tab-item:hover {
  background-color: var(--bg-hover);
  color: var(--text-primary);
}

.tab-item.active {
  color: var(--accent-color);
  font-weight: 600;
  border-bottom-color: var(--accent-color);
}

.tab-icon {
  margin-right: 0.5rem;
}

.close-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  margin-left: 0.75rem;
  border-radius: 50%;
  background: transparent;
  border: none;
  color: var(--text-secondary);
  opacity: 0.5;
  transition: all 0.2s ease;
  cursor: pointer;
}

.tab-item:hover .close-btn {
  opacity: 1;
  color: var(--text-primary);
}

.close-btn:hover {
  background-color: var(--border-color);
  color: var(--text-primary);
}

.tab-item.active .close-btn {
  opacity: 1;
}

.close-btn i {
  font-size: 0.8rem;
}
</style>
