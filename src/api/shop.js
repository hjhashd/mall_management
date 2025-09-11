// @/api/shop.js
import request from '@/utils/request'


/**
 * 获取卖家店铺统计信息
 * @param {Object} params - { sellerId }
 */
export function getShopStats(params) {
    return request({
        url: '/shop/stats',
        method: 'get',
        params // params can be { sellerId: 123 } or undefined
    })
}

/**
 * 获取卖家商品列表（带分页）
 * @param {Object} params - 查询参数 { page, size, sellerId }
 */
export function getSellerProducts(params) {
    return request({
        url: '/products/ForSeller', // 确保这个后羰接口也支持可选的 sellerId
        method: 'get',
        params
    })
}

/**
 * 获取指定或当前登录卖家的店铺基础信息
 * @param {Object} params - { sellerId }
 */
export function getSellerShop(params) {
    return request({
        url: '/shop/SellerShop',
        method: 'get',
        params
    })
}


/**
 * 获取指定或当前登录卖家的店铺设置信息
 * @param {Object} params - { sellerId }
 */
export function getShopSettings(params) {
    return request({
        url: '/shop/settings',
        method: 'get',
        params // 添加params参数支持
    })
}
/**
 * 更新店铺设置信息
 * @param {Object} data - 店铺设置的表单数据
 */
export function updateShopSettings(data) {
    return request({
        url: '/shop/settings',
        method: 'put',
        data
    })
}

/**
 * 上传店铺 Logo
 * @param {FormData} formData - 包含文件的 FormData 对象
 */
export function uploadShopLogo(formData) {
    return request({
        url: '/shop/uploadLogo',
        method: 'post',
        data: formData,
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}

/**
 * 上传店铺 Banner
 * @param {FormData} formData - 包含文件的 FormData 对象
 */
export function uploadShopBanner(formData) {
    return request({
        url: '/shop/uploadBanner',
        method: 'post',
        data: formData,
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}
