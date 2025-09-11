<template>
  <li class="category-node" :style="{ '--level': level }">
    <div class="node-content" :class="{ 'has-children': category.children && category.children.length }">
      <div class="node-info" @click="toggleExpand">
        <div class="expand-section">
          <i
              class="fas fa-chevron-right expand-icon"
              :class="{ 'is-expanded': isExpanded }"
              v-if="category.children && category.children.length"
          ></i>
          <div class="category-icon">
            <i class="fas fa-folder" v-if="category.children && category.children.length"></i>
            <i class="fas fa-tag" v-else></i>
          </div>
        </div>

        <div class="category-details">
          <!-- [!code --]
          <span class="category-name">{{ category.category_name }}</span>
          -->
          <!-- [!code ++] -->
          <!-- 修复：使用正确的驼峰命名 categoryName -->
          <span class="category-name">{{ category.categoryName }}</span>
          <div class="category-meta">
            <!-- [!code --]
            <span class="status-chip" :class="category.is_show ? 'status-active' : 'status-inactive'">
              <i :class="category.is_show ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
              {{ category.is_show ? '显示中' : '已隐藏' }}
            </span>
            -->
            <!-- [!code ++] -->
            <!-- 修复：使用正确的驼峰命名 isShow -->
            <span class="status-chip" :class="category.isShow ? 'status-active' : 'status-inactive'">
              <i :class="category.isShow ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
              {{ category.isShow ? '显示中' : '已隐藏' }}
            </span>
            <!-- [!code --]
            <span class="sort-chip">
              <i class="fas fa-sort-numeric-down"></i>
              {{ category.sort_order }}
            </span>
            -->
            <!-- [!code ++] -->
            <!-- 修复：使用正确的驼峰命名 sortOrder -->
            <span class="sort-chip">
              <i class="fas fa-sort-numeric-down"></i>
              {{ category.sortOrder }}
            </span>
          </div>
        </div>
      </div>

      <div class="node-actions">
        <button class="action-btn btn-edit" @click.stop="$emit('edit', category)" title="编辑分类">
          <i class="fas fa-edit"></i>
        </button>
        <button class="action-btn btn-add-child" @click.stop="$emit('addChild', category)" title="添加子分类">
          <i class="fas fa-plus"></i>
        </button>
        <!-- [!code --]
        <button class="action-btn btn-delete" @click.stop="$emit('delete', category.category_id)" title="删除分类">
        -->
        <!-- [!code ++] -->
        <!-- 修复：使用正确的驼峰命名 categoryId -->
        <button class="action-btn btn-delete" @click.stop="$emit('delete', category.categoryId)" title="删除分类">
          <i class="fas fa-trash"></i>
        </button>
      </div>
    </div>

    <transition name="expand" appear>
      <ul v-if="isExpanded && category.children && category.children.length" class="category-list sub-list">
        <!-- [!code --]
        <CategoryNode
            v-for="child in category.children"
            :key="child.category_id"
            :category="child"
            :level="level + 1"
            @edit="$emit('edit', child)"
            @delete="$emit('delete', child.category_id)"
            @add-child="$emit('addChild', child)"
        />
        -->
        <!-- [!code ++] -->
        <!-- 修复：在 key 和 delete 事件中，使用正确的驼峰命名 categoryId -->
        <CategoryNode
            v-for="child in category.children"
            :key="child.categoryId"
            :category="child"
            :level="level + 1"
            @edit="$emit('edit', child)"
            @delete="$emit('delete', child.categoryId)"
            @add-child="$emit('addChild', child)"
        />
      </ul>
    </transition>
  </li>
</template>

<script setup>
import { ref } from 'vue';
import CategoryNode from './CategoryNode.vue';

const props = defineProps({
  category: Object,
  level: Number
});

const emit = defineEmits(['edit', 'delete', 'addChild']);

const isExpanded = ref(true);

const toggleExpand = () => {
  if (props.category.children && props.category.children.length > 0) {
    isExpanded.value = !isExpanded.value;
  }
};
</script>

<style scoped>
.category-node {
  position: relative;
  margin-bottom: 0.5rem;
}

.node-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  margin-left: calc(var(--level) * 2rem);
  border-radius: var(--border-radius-sm, 8px);
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  position: relative;
  overflow: hidden;
}

.node-content::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: transparent;
  transition: all var(--transition-speed, 0.3s) ease;
}

.node-content:hover {
  background: var(--bg-hover, rgba(255, 255, 255, 0.08));
  border-color: var(--accent-color, #9f78ff);
  transform: translateX(4px);
  box-shadow: 0 4px 12px var(--shadow-color, rgba(0, 0, 0, 0.1));
}

.node-content:hover::before {
  background: linear-gradient(180deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
}

.node-content:hover .node-actions {
  opacity: 1;
  transform: translateX(0);
}

.node-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  cursor: pointer;
  flex-grow: 1;
  min-width: 0;
}

.expand-section {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-shrink: 0;
}

.expand-icon {
  font-size: 0.75rem;
  color: var(--text-secondary, #a0a0b0);
  transition: all var(--transition-speed, 0.3s) ease;
  width: 12px;
  text-align: center;
}

.expand-icon.is-expanded {
  transform: rotate(90deg);
  color: var(--accent-color, #9f78ff);
}

.category-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  flex-shrink: 0;
}

.category-details {
  flex: 1;
  min-width: 0;
}

.category-name {
  font-weight: 600;
  color: var(--text-primary, #fff);
  font-size: 0.95rem;
  display: block;
  margin-bottom: 0.25rem;
}

.category-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.status-chip,
.sort-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.75rem;
  border-radius: var(--border-radius-sm, 6px);
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.status-chip.status-active {
  background: rgba(16, 185, 129, 0.2);
  color: #6ee7b7;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.status-chip.status-inactive {
  background: rgba(107, 114, 128, 0.2);
  color: #d1d5db;
  border: 1px solid rgba(107, 114, 128, 0.3);
}

.sort-chip {
  background: rgba(59, 130, 246, 0.2);
  color: #93c5fd;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.node-actions {
  display: flex;
  gap: 0.5rem;
  opacity: 0;
  transform: translateX(10px);
  transition: all var(--transition-speed, 0.3s) ease;
  flex-shrink: 0;
}

.action-btn {
  width: 32px;
  height: 32px;
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.2));
  border-radius: 50%;
  background: var(--bg-primary, rgba(255, 255, 255, 0.05));
  color: var(--text-secondary, #a0a0b0);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  transition: all var(--transition-speed, 0.3s) ease;
  position: relative;
  overflow: hidden;
}

.action-btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  transition: all var(--transition-speed, 0.3s) ease;
  transform: translate(-50%, -50%);
}

.action-btn:hover::before {
  width: 100%;
  height: 100%;
}

.action-btn:hover {
  color: white;
  border-color: transparent;
  transform: scale(1.1);
}

.btn-edit:hover::before {
  background: #3b82f6;
}

.btn-edit:hover {
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}

.btn-add-child:hover::before {
  background: #10b981;
}

.btn-add-child:hover {
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

.btn-delete:hover::before {
  background: #ef4444;
}

.btn-delete:hover {
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
}

/* 子列表样式 */
.sub-list {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0 0 0;
  position: relative;
}

.sub-list::before {
  content: '';
  position: absolute;
  left: calc(var(--level) * 2rem + 1.25rem + 16px);
  top: 0;
  bottom: 0;
  width: 1px;
  background: var(--border-color, rgba(255, 255, 255, 0.1));
}

/* 展开/收起动画 */
.expand-enter-active,
.expand-leave-active {
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  overflow: hidden;
}

.expand-enter-from,
.expand-leave-to {
  opacity: 0;
  max-height: 0;
  transform: translateY(-10px);
}

.expand-enter-to,
.expand-leave-from {
  opacity: 1;
  max-height: 1000px;
  transform: translateY(0);
}

/* 响应式适配 */
@media (max-width: 768px) {
  .node-content {
    padding: 0.875rem 1rem;
    margin-left: calc(var(--level) * 1.5rem);
  }

  .category-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .action-btn {
    width: 28px;
    height: 28px;
    font-size: 0.7rem;
  }

  .sub-list::before {
    left: calc(var(--level) * 1.5rem + 1rem + 16px);
  }
}

@media (max-width: 480px) {
  .node-content {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }

  .node-info {
    order: 1;
  }

  .node-actions {
    order: 2;
    opacity: 1;
    transform: none;
    justify-content: center;
  }
}

/* 主题适配 */
[data-theme="glass"] .category-node,
[data-theme="tech"] .category-node {
  --node-bg: rgba(255, 255, 255, 0.05);
  --node-border: rgba(255, 255, 255, 0.1);
  --node-hover-bg: rgba(255, 255, 255, 0.08);
}

[data-theme="default"] .category-node,
[data-theme="fresh"] .category-node,
[data-theme="google"] .category-node {
  --node-bg: rgba(0, 0, 0, 0.02);
  --node-border: rgba(0, 0, 0, 0.05);
  --node-hover-bg: rgba(0, 0, 0, 0.04);
}
</style>
