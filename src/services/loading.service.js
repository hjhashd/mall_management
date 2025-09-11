// src/services/loading.service.js
import { ref } from 'vue'

// 创建响应式状态
const isLoading = ref(true)
const loadingMessage = ref('应用加载中')
const loadingProgress = ref(0) // 添加进度状态

// 导出服务方法
export const useLoading = () => {
    const showLoading = (message = '加载中') => {
        isLoading.value = true
        loadingMessage.value = message
        loadingProgress.value = 0
    }

    // 添加进度更新方法
    const updateProgress = (progress) => {
        loadingProgress.value = Math.min(100, Math.max(0, progress))
    }

    const updateMessage = (message) => {
        loadingMessage.value = message
    }

    const hideLoading = () => {
        isLoading.value = false
    }

    return {
        isLoading,
        loadingMessage,
        loadingProgress, // 导出进度状态
        showLoading,
        hideLoading,
        updateProgress, // 导出进度更新方法
        updateMessage
    }
}
