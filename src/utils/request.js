import axios from 'axios'
import { useUserStore } from '@/stores/userStore'

// 创建 axios 实例
const request = axios.create({
    baseURL: '/api', // 基础URL
    timeout: 10000,  // 超时时间
})

// 请求拦截器
request.interceptors.request.use(
    (config) => {
        // 获取最新的 token（从 store 中）
        const userStore = useUserStore()
        if (userStore.token) {
            config.headers.Authorization = `Bearer ${userStore.token}`
        }
        return config
    },
    (error) => {
        return Promise.reject(error)
    }
)


export default request
