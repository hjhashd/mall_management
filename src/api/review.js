import request from '@/utils/request'

// 获取商品评价列表
export function getProductReviews(productId, params = {}) {
  return request({
    url: `/products/${productId}/reviews`,
    method: 'get',
    params: {
      page: params.page || 1,
      size: params.size || 10,
      rating: params.rating,
      sort: params.sort || 'created_at',
      order: params.order || 'desc'
    }
  })
}

/**
 * 【新增】获取所有评价 (用于管理后台)
 * @param {object} params 查询参数
 */
export function getAllReviews(params = {}) {
  return request({
    url: '/reviews/all', // 对应后端新增的接口
    method: 'get',
    params: params
  })
}

/**
 * @/api/review.js
 * 获取指定或当前登录卖家的评价列表
 * @param {Object} params - { sellerId }
 */
export function getSellerReviews(params) {
  return request({
    url: '/shop/seller', // 后端Controller对应的路径
    method: 'get',
    params
  })
}

/**
 * 【新增】添加卖家回复
 * @param {number} reviewId 评价ID
 * @param {string} sellerReply 回复内容
 */
export function addSellerReply(reviewId, sellerReply) {
  return request({
    url: `/reviews/${reviewId}/seller-reply`,
    method: 'post',
    params: {
      sellerReply
    }
  })
}

// 获取商品评分统计
export function getProductRatingSummary(productId) {
  return request({
    url: `/products/${productId}/rating-summary`,
    method: 'get'
  })
}

// 提交商品评价
export function submitReview(formData) {
  return request({
    url: '/reviews',
    method: 'post',
    data: formData,  // 直接发送 FormData
    headers: {
      'Content-Type': 'multipart/form-data'  // 重要：设置正确的内容类型
    }
  })
}

// 提交回复
export function submitReply(data) {
  return request({
    url: '/replies',
    method: 'post',
    data: {
      reviewId: data.reviewId,           // 改为驼峰命名
      content: data.content,
      repliedToUserId: data.repliedToUserId,
      repliedToUsername: data.repliedToUsername,
      isAppend: data.isAppend || false
    }
  })
}

// 删除评价
export function deleteReview(reviewId) {
  return request({
    url: `/reviews/${reviewId}`,
    method: 'delete'
  })
}

// 删除回复
export function deleteReply(replyId) {
  return request({
    url: `/replies/${replyId}`,
    method: 'delete'
  })
}

// 获取评价详情
export function getReviewDetail(reviewId) {
  return request({
    url: `/reviews/${reviewId}`,
    method: 'get'
  })
}

// 获取回复列表
export function getReplies(reviewId, params = {}) {
  return request({
    url: `/reviews/${reviewId}/replies`,
    method: 'get',
    params: {
      page: params.page || 1,
      size: params.size || 20
    }
  })
}

// 上传评价图片
export function uploadReviewImage(file) {
  const formData = new FormData()
  formData.append('image', file)

  return request({
    url: '/upload/review-image',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 批量上传评价图片
export function uploadReviewImages(files) {
  const formData = new FormData()
  files.forEach((file, index) => {
    formData.append(`images[${index}]`, file)
  })

  return request({
    url: '/upload/review-images',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 获取用户评价列表
export function getUserReviews(userId, params = {}) {
  return request({
    url: `/users/${userId}/reviews`,
    method: 'get',
    params: {
      page: params.page || 1,
      size: params.size || 10,
      status: params.status
    }
  })
}

// 获取待评价订单（修改支持商品过滤）
export function getPendingReviews(params = {}) {
  return request({
    url: '/reviews/pending',
    method: 'get',
    params: {
      page: params.page || 1,
      size: params.size || 10,
      productId: params.productId // 添加商品ID参数
    }
  })
}

// 评价点赞
export function likeReview(reviewId) {
  return request({
    url: `/reviews/${reviewId}/like`,
    method: 'post'
  })
}

// 取消评价点赞
export function unlikeReview(reviewId) {
  return request({
    url: `/reviews/${reviewId}/unlike`,
    method: 'post'
  })
}

// 举报评价
export function reportReview(reviewId, reason) {
  return request({
    url: `/reviews/${reviewId}/report`,
    method: 'post',
    data: {
      reason: reason
    }
  })
}

// 获取评价标签统计
export function getReviewTags(productId) {
  return request({
    url: `/products/${productId}/review-tags`,
    method: 'get'
  })
}

// 根据标签筛选评价
export function getReviewsByTag(productId, tag, params = {}) {
  return request({
    url: `/products/${productId}/reviews/tag/${tag}`,
    method: 'get',
    params: {
      page: params.page || 1,
      size: params.size || 10
    }
  })
}
