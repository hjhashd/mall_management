import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useTabStore = defineStore('tabs', () => {
    const tabs = ref([])
    const activeTab = ref(null)

    // 首页标签（不可关闭）
    const initHomeTab = () => {
        const homeTab = {
            key: 'dashboard',
            label: '仪表盘',
            icon: 'fas fa-tachometer-alt',
            closable: false
        }

        if (!tabs.value.some(tab => tab.key === homeTab.key)) {
            tabs.value.push(homeTab)
            activeTab.value = homeTab.key
        }
    }

    // 添加标签页
    const addTab = (menuItem) => {
        // 避免重复打开
        const existingTab = tabs.value.find(tab => tab.key === menuItem.key)
        if (existingTab) {
            activeTab.value = menuItem.key
            return
        }

        // 添加新标签页
        tabs.value.push({
            key: menuItem.key,
            label: menuItem.label,
            icon: menuItem.icon,
            closable: menuItem.key !== 'dashboard' // 首页不可关闭
        })

        activeTab.value = menuItem.key
    }

    // 关闭标签页
    const closeTab = (key) => {
        const index = tabs.value.findIndex(tab => tab.key === key)
        if (index === -1) return

        // 处理关闭当前激活标签的情况
        if (activeTab.value === key) {
            // 优先激活前一个标签，否则激活后一个
            if (index > 0) {
                activeTab.value = tabs.value[index - 1].key
            } else if (tabs.value.length > 1) {
                activeTab.value = tabs.value[index + 1].key
            }
        }

        tabs.value.splice(index, 1)

        // 确保至少有一个标签页
        if (tabs.value.length === 0) {
            initHomeTab()
        }
    }

    // 切换标签页
    const switchTab = (key) => {
        activeTab.value = key
    }

    return {
        tabs,
        activeTab,
        initHomeTab,
        addTab,
        closeTab,
        switchTab
    }
})
