import request from '@/utils/request'

// 提交订单
export function submitOrder(orderData) {
    return request({
        url: '/order/checkout',
        method: 'post',
        data: orderData
    })
}

// 获取用户余额
export function getUserBalance() {
    return request({
        url: '/user/balance',
        method: 'get'
    })
}

// 获取订单列表
export function getOrderList() {
    return request({
        url: '/order/list', // 后端接口是 /api/order/list, request 工具通常会处理 /api 前缀
        method: 'get'
    })
}

// 获取订单详情
export function getOrderDetail(orderId) {
    return request({
        url: `/order/${orderId}`,
        method: 'get'
    })
}

// 确认收货
export function confirmReceive(orderId) {
    return request({
        url: `/order/${orderId}/confirm-receive`,
        method: 'post'
    })
}

// 模拟：查询物流（如后端未实现可不调用）
export function getOrderTracking(orderId) {
    return request({
        url: `/order/${orderId}/tracking`,
        method: 'get'
    })
}

/**
 * 修改说明:
 * - 将原函数 `cancelOrderService` 的 URL 从 `/cancel-order` 修正为 `/cancel`，以匹配 OrderController 中的定义。
 * @PostMapping("/order/{orderId}/cancel")
 */
export function cancelOrder(orderId) {
    return request({
        url: `/order/${orderId}/cancel`,
        method: 'post'
    })
}


// 获取订单项详情
export function getOrderItemDetail(orderItemId) {
    return request({
        url: `/order/item/${orderItemId}`,
        method: 'get'
    })
}

// 提交售后申请
export function submitAfterSaleApplication(formData) {
    return request({
        url: '/after-sales/apply',
        method: 'post',
        data: formData, // 直接发送 FormData
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}

/**
 * 获取当前登录卖家的订单列表
 * @returns {Promise<AxiosResponse<any>>}
 */
export function getSellerOrderList() {
    return request({
        url: '/seller/orders',
        method: 'get'
    })
}

/**
 * 卖家发货
 * @param {string} orderId - 订单ID
 * @param {object} shipmentData - 发货信息，包含 shippingCompany 和 trackingNumber
 * @returns {Promise<AxiosResponse<any>>}
 */
export function shipOrder(orderId, shipmentData) {
    return request({
        url: `/seller/orders/${orderId}/ship`,
        method: 'post',
        data: shipmentData
    })
}

/**
 * 获取卖家的售后申请列表
 * @returns {Promise<AxiosResponse<any>>}
 */
export function getSellerAfterSaleList() {
    return request({
        url: '/seller/after-sales',
        method: 'get'
    })
}

/**
 * 卖家处理售后申请
 * @param {number} afterSaleId - 售后ID
 * @param {string} action - 'approve' 或 'reject'
 * @param {string} sellerRemark - 卖家处理备注
 * @returns {Promise<AxiosResponse<any>>}
 */
export function processAfterSaleApplication(afterSaleId, action, sellerRemark) {
    return request({
        url: `/seller/after-sales/${afterSaleId}/process`,
        method: 'post',
        data: {
            action,
            seller_remark: sellerRemark
        }
    })
}

/**
 * 用户对被拒绝的售后申请提起申诉
 * @param {number} afterSaleId 售后ID
 * @returns {Promise<AxiosResponse<any>>}
 */
export function appealAfterSale(afterSaleId) {
    return request({
        url: `/user/after-sales/${afterSaleId}/appeal`,
        method: 'post'
    })
}

/**
 * 获取管理员售后申请列表（支持状态筛选）
 * @param {number|null} status - 状态码，null 表示获取所有
 * @returns {Promise<AxiosResponse<any>>}
 */
export function getAdminAfterSaleList(status = null) {
    let url = '/admin/after-sales';
    if (status !== null) {
        url += `?status=${status}`;
    }
    return request({
        url: url,
        method: 'get'
    });
}

/**
 * 管理员对售后申请进行仲裁
 * @param {number} afterSaleId - 售后ID
 * @param {string} action - 'approve' 或 'reject'
 * @param {string} adminRemark - 管理员备注
 * @returns {Promise<AxiosResponse<any>>}
 */
export function judgeAfterSaleApplication(afterSaleId, action, adminRemark) {
    return request({
        url: `/admin/after-sales/${afterSaleId}/judge`,
        method: 'post',
        data: {
            action,
            admin_remark: adminRemark
        }
    })
}
