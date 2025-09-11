import request from '@/utils/request'

/**
 * 提交商家认证申请
 */
export const submitCertification = (formData) => {
    return request.post('/seller-certifications/submit', formData)
}

/**
 * 获取当前用户的认证状态
 */
export const getCertificationStatus = () => {
    return request.get('/seller-certifications/status')
}

/**
 * 管理员审核商家认证
 */
export const reviewCertification = (certificationId, status, rejectReason) => {
    return request.post(`/seller-certifications/${certificationId}/review`, {
        status,
        reject_reason: rejectReason
    })
}

/**
 * 管理员获取认证申请列表
 */
export const getCertificationList = (page = 1, size = 10, status = null) => {
    const params = { page, size }
    if (status !== null) {
        params.status = status
    }
    return request.get('/seller-certifications/admin/list', { params })
}