import { defineStore } from 'pinia'
import { login as apiLogin, register as apiRegister } from '@/api/auth'

export const useUserStore = defineStore('user', {
    state: () => ({
        token: null,
        userInfo: null,
        hydrated: false,
        loginSuccess: false
    }),

    getters: {
        isLoggedIn: (state) => !!state.token,
        isAdmin: (state) => {
            // 检查用户是否有管理员角色
            return state.userInfo?.roles?.includes('ROLE_ADMIN') || false
        },
        userRoles: (state) => {
            return state.userInfo?.roles || []
        },
        isSeller: (state) => {
            return state.userInfo?.roles?.includes('ROLE_SELLER') || false
        }
    },

    actions: {
        async login(username, password, rememberMe = false) {
            try {
                const response = await apiLogin(username, password, rememberMe)

                this.token = response.data.token

                // 存储完整用户信息
                this.userInfo = response.data.user; // 接收后端返回的完整用户对象

                if (rememberMe) {
                    localStorage.setItem('authToken', this.token)
                    localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
                } else {
                    sessionStorage.setItem('authToken', this.token)
                    sessionStorage.setItem('userInfo', JSON.stringify(this.userInfo))
                }

                this.hydrated = true
                this.loginSuccess = true;
                return true
            } catch (error) {
                console.error('Login failed:', error)
                return false
            }
        },

        async register(userData) {
            try {
                const response = await apiRegister(userData)

                if (response.data.success) {
                    return { success: true, message: response.data.message || '注册成功' }
                }
                return { success: false, message: response.data.message || '注册失败' }
            } catch (error) {
                console.error('Register failed:', error)
                if (error.response && error.response.data && error.response.data.message) {
                    return { success: false, message: error.response.data.message }
                }
                return { success: false, message: '网络错误，请稍后重试' }
            }
        },

        resetLoginSuccess() {
            this.loginSuccess = false;
        },

        logout() {
            this.token = null
            this.userInfo = null
            this.hydrated = false
            localStorage.removeItem('authToken')
            sessionStorage.removeItem('authToken')
            localStorage.removeItem('userInfo')
            sessionStorage.removeItem('userInfo')
        },

        restoreFromStorage() {
            const token = localStorage.getItem('authToken') || sessionStorage.getItem('authToken')
            const userInfo = localStorage.getItem('userInfo') || sessionStorage.getItem('userInfo')

            if (token) this.token = token;
            if (userInfo) {
                try {
                    // 直接解析完整用户对象
                    this.userInfo = JSON.parse(userInfo);
                } catch (error) {
                    console.error('Failed to parse userInfo:', error)
                }
            }
            this.hydrated = true;
        }
    }
})
