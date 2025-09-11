// 请确保 '@/utils/request' 路径正确
import request from '@/utils/request';

/**
 * 获取社区帖子列表
 * @param {object} params - 筛选参数
 * @param {string} [params.category] - 分类
 * @param {string} [params.keyword] - 关键词
 * @param {number} [params.minLikes] - 最低点赞数
 * @returns {Promise<object>}
 */
export function getCommunityPosts(params) {
    return request({
        url: '/community/posts',
        method: 'get',
        params,
    });
}

/**
 * 获取帖子评论
 * @param {number} postId - 帖子ID
 * @returns {Promise<object>}
 */
export function getPostComments(postId) {
    return request({
        url: `/community/posts/${postId}/comments`,
        method: 'get',
    });
}

/**
 * 发布新帖子
 * @param {object} data - 帖子数据
 * @returns {Promise<object>}
 */
export function createNewPost(data) {
    return request({
        url: '/community/posts',
        method: 'post',
        data,
        // 如果需要上传文件，需要设置正确的headers，后端需要支持文件上传
        headers: { 'Content-Type': 'multipart/form-data' },
    });
}

/**
 * 发表评论
 * @param {number} postId - 帖子ID
 * @param {object} data - 评论数据
 * @returns {Promise<object>}
 */
export function addPostComment(postId, data) {
    return request({
        url: `/community/posts/${postId}/comments`,
        method: 'post',
        data,
    });
}
