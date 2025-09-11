import request from '@/utils/request'

// 获取购物车列表
export function getCartItems() {
    return request({
        url: '/cart/items',
        method: 'get'
    })
}

// 更新购物车商品数量
export function updateCartItemQuantity(cartItemId, quantity) {
    return request({
        url: `/cart/items/${cartItemId}/quantity`,
        method: 'put',
        data: {
            quantity: quantity
        }
    })
}

// 删除购物车商品
export function deleteCartItem(cartItemId) {
    return request({
        url: `/cart/items/${cartItemId}`,
        method: 'delete'
    })
}

// 清空购物车
export function clearCart() {
    return request({
        url: '/cart/clear',
        method: 'delete'
    })
}

// 获取购物车统计信息
export function getCartSummary() {
    return request({
        url: '/cart/summary',
        method: 'get'
    })
} 