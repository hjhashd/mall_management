<template>
  <div class="pagination">
    <!-- 上一页 -->
    <button 
      @click="handlePageChange(currentPage - 1)"
      :disabled="currentPage === 1"
      class="page-btn prev-btn">
      <i class="fas fa-chevron-left"></i>
      <span>上一页</span>
    </button>

    <!-- 页码 -->
    <div class="page-numbers">
      <!-- 第一页 -->
      <button 
        v-if="showFirstPage"
        @click="handlePageChange(1)"
        class="page-btn">
        1
      </button>

      <!-- 省略号 -->
      <span v-if="showFirstEllipsis" class="ellipsis">...</span>

      <!-- 中间页码 -->
      <button 
        v-for="page in visiblePages" 
        :key="page"
        @click="handlePageChange(page)"
        :class="['page-btn', { active: page === currentPage }]">
        {{ page }}
      </button>

      <!-- 省略号 -->
      <span v-if="showLastEllipsis" class="ellipsis">...</span>

      <!-- 最后一页 -->
      <button 
        v-if="showLastPage"
        @click="handlePageChange(totalPages)"
        class="page-btn">
        {{ totalPages }}
      </button>
    </div>

    <!-- 下一页 -->
    <button 
      @click="handlePageChange(currentPage + 1)"
      :disabled="currentPage === totalPages"
      class="page-btn next-btn">
      <span>下一页</span>
      <i class="fas fa-chevron-right"></i>
    </button>

    <!-- 页面信息 -->
    <div class="page-info">
      <span>第 {{ currentPage }} 页，共 {{ totalPages }} 页</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    required: true
  },
  totalPages: {
    type: Number,
    required: true
  },
  maxVisiblePages: {
    type: Number,
    default: 5
  }
})

const emit = defineEmits(['page-change'])

// 计算属性
const showFirstPage = computed(() => {
  return props.currentPage > Math.ceil(props.maxVisiblePages / 2) + 1
})

const showLastPage = computed(() => {
  return props.currentPage < props.totalPages - Math.floor(props.maxVisiblePages / 2)
})

const showFirstEllipsis = computed(() => {
  return props.currentPage > Math.ceil(props.maxVisiblePages / 2) + 2
})

const showLastEllipsis = computed(() => {
  return props.currentPage < props.totalPages - Math.floor(props.maxVisiblePages / 2) - 1
})

const visiblePages = computed(() => {
  const pages = []
  const halfVisible = Math.floor(props.maxVisiblePages / 2)
  
  let start = Math.max(1, props.currentPage - halfVisible)
  let end = Math.min(props.totalPages, props.currentPage + halfVisible)
  
  // 调整起始和结束位置，确保显示足够的页码
  if (end - start + 1 < props.maxVisiblePages) {
    if (start === 1) {
      end = Math.min(props.totalPages, start + props.maxVisiblePages - 1)
    } else {
      start = Math.max(1, end - props.maxVisiblePages + 1)
    }
  }
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  
  return pages
})

// 方法
const handlePageChange = (page) => {
  if (page >= 1 && page <= props.totalPages && page !== props.currentPage) {
    emit('page-change', page)
  }
}
</script>

<style scoped>
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.page-numbers {
  display: flex;
  align-items: center;
  gap: 8px;
}

.page-btn {
  min-width: 40px;
  height: 40px;
  border: 1px solid #dee2e6;
  background: white;
  color: #495057;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  padding: 0 12px;
}

.page-btn:hover:not(:disabled) {
  border-color: #007bff;
  color: #007bff;
  background: #f8f9fa;
}

.page-btn.active {
  background: #007bff;
  border-color: #007bff;
  color: white;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.prev-btn, .next-btn {
  gap: 8px;
  padding: 0 16px;
}

.prev-btn span, .next-btn span {
  display: none;
}

@media (min-width: 768px) {
  .prev-btn span, .next-btn span {
    display: inline;
  }
}

.ellipsis {
  color: #6c757d;
  font-size: 14px;
  padding: 0 8px;
}

.page-info {
  color: #6c757d;
  font-size: 14px;
  margin-left: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .pagination {
    flex-direction: column;
    gap: 12px;
  }
  
  .page-info {
    margin-left: 0;
    order: -1;
  }
  
  .page-btn {
    min-width: 36px;
    height: 36px;
    font-size: 13px;
  }
  
  .prev-btn, .next-btn {
    padding: 0 12px;
  }
}

@media (max-width: 480px) {
  .page-numbers {
    gap: 4px;
  }
  
  .page-btn {
    min-width: 32px;
    height: 32px;
    font-size: 12px;
  }
  
  .ellipsis {
    padding: 0 4px;
  }
}
</style> 