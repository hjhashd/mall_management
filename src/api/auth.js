import request from '@/utils/request'

export const login = (username, password, rememberMe) => {
    return request.post('/auth/login', {
        username,
        password,
        rememberMe
    })
}

export const register = (userData) => {
    return request.post('/auth/register', userData)
}

// 其他 API 也可以使用
export const getUserInfo = () => {
    return request.get('/user/info')
}