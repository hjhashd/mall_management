import request from '@/utils/request'

export function searchProducts(params) {
    return request({
        url: '/products/search',
        method: 'get',
        params
    })
}

export function getCategories() {   //这个方法只要顶级分类
    return request({
        url: 'products/categories',
        method: 'get'
    })
}

export function getCategoriesTree() {
    return request({
        url: 'products/categoriesTree',
        method: 'get'
    })
}

// 创建分类
export function createCategory(data) {
    return request({
        url: '/products/categories',
        method: 'post',
        data
    });
}

// 更新分类
export function updateCategory(id, data) {
    return request({
        url: `/products/categories/${id}`,
        method: 'put',
        data
    });
}

// 删除分类
export function deleteCategory(id) {
    return request({
        url: `/products/categories/${id}`,
        method: 'delete'
    });
}

// 获取商品详情
export function getProductDetail(productId) {
    return request({
        url: `/products/${productId}`,
        method: 'get'
    })
}

// 收藏/取消收藏商品
export function toggleFavorite(productId) {
    return request({
        url: `/products/${productId}/favorite`,
        method: 'post'
    })
}

// 新增：获取当前用户的收藏列表（分页/排序）
export function getUserFavorites(params) {
    return request({
        url: '/products/favorites',
        method: 'get',
        params
    })
}

// 加入购物车
export function addToCart(productId, quantity = 1) {
    return request({
        url: `/cart/${productId}/add-to-cart`,
        method: 'post',
        data: {
            quantity: quantity  // ✅ 明确指定参数名
        }
    })
}

// 删除商品
export function deleteProduct(productId) {
    return request({
        url: `/products/${productId}`,
        method: 'delete'
    })
}

// 提交新增商品审核
export function submitProductReview(formData) {
    return request({
        url: '/products/submit-product-review',
        method: 'post',
        data: formData,
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}

// 更新商品信息
export function updateSubmitProduct(productId, formData) {
    return request({
        url: `/products/update-product/${productId}`,
        method: 'put',
        data: formData,
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}



// --- 后台管理接口 ---
/**
 * 获取后台商品列表（分页、筛选）
 * @param {object} params - 查询参数，例如 { page, pageSize, title, categoryId, status }
 */
export function getAdminProducts(params) {
    return request({
        url: '/admin/products',
        method: 'get',
        params
    });
}

/**
 * 创建一个新商品
 * @param {object} data - 商品数据
 */
export function createProduct(data) {
    return request({
        url: '/admin/products',
        method: 'post',
        data
    });
}

/**
 * 更新一个商品
 * @param {number} id - 商品ID
 * @param {object} data - 要更新的商品数据
 */
export function updateProduct(id, data) {
    return request({
        url: `/admin/products/${id}`,
        method: 'put',
        data
    });
}

/**
 * 删除一个商品
 * @param {number} id - 商品ID
 */
export function adminDeleteProduct(id) {
    return request({
        url: `/admin/products/${id}`,
        method: 'delete'
    });
}

/**
 * 推荐/取消推荐商品
 * @param {number} id - 商品ID
 * @param {boolean} isRecommended - 是否推荐
 */
export function toggleRecommendation(id, isRecommended) {
    // 这个操作可以复用更新接口
    return updateProduct(id, { is_recommended: isRecommended });
}



/**
 * 获取待审核的图片列表
 * @param {object} params - 查询参数, e.g., { status: 0, page: 1, size: 12 }
 */
export function getReviewImages(params) {
    return request({
        url: '/admin/images/review-list',
        method: 'get',
        params
    })
}

/**
 * 提交图片审核结果 (支持批量)
 * @param {Array<object>} reviews - 审核对象数组, e.g., [{ imageId: 1, status: 2, reason: '不清晰' }]
 */
export function reviewImages(reviews) {
    return request({
        url: '/admin/images/review',
        method: 'post',
        data: {
            reviews // 后端需要一个根对象，所以包装一下
        }
    })
}

/**
 * "看了又看" - 获取相似商品
 * @param {number} productId 当前正在浏览的商品ID
 */
export function getSimilarProducts(productId) {
    return request({
        url: `/products/${productId}/similar`,
        method: 'get'
        // 参数已移除
    });
}

/**
 * "购物车配套推荐" - 获取推荐商品
 */
export function getCartRecommendations() {
    return request({
        url: '/products/cart/recommendations',
        method: 'get'
        // 参数已移除
    });
}

/**
 * "猜你喜欢" - 获取推荐商品
 */
export function getRecommendations() {
    return request({
        url: '/products/recommendations',
        method: 'get'
        // 参数已移除
    });
}
