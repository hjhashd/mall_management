import request from '@/utils/request'

// 更新用户头像
export function updateUserAvatar(formData) {
    return request({
        url: '/user/update-avatar',
        method: 'post',
        headers: {
            'Content-Type': 'multipart/form-data'
        },
        data: formData
    })
}

// 获取用户账户设置信息
export function getUserAccountInfo() {
    return request({
        url: '/user/account-info',
        method: 'get'
    })
}

// 获取基础信息
export function getUserBasicInfo() {
    return request({
        url: '/user/basic-info',
        method: 'get'
    })
}

/**
 * 获取用户列表
 * @param {object} params - 查询参数 { page, pageSize, query }
 */
export function getUsers(params) {
    return request({
        url: '/admin/users',
        method: 'get',
        params
    })
}

// 获取带角色的用户列表
export function getUsersWithRoles(params) {
    return request({
        url: '/admin/users-with-roles',
        method: 'get',
        params
    })
}

// 更新用户状态
export function updateUserStatus(userId, enabled) {
    return request({
        url: `/admin/users/${userId}/status`,
        method: 'post',
        data: { enabled }
    })
}

// 创建新用户
export function createUser(data) {
    return request({
        url: '/admin/users',
        method: 'post',
        data
    })
}

// 更新用户信息
export function updateUser(userId, data) {
    return request({
        url: `/admin/users/${userId}`,
        method: 'put',
        data
    })
}

// 删除用户
export function deleteUser(userId) {
    return request({
        url: `/admin/users/${userId}`,
        method: 'delete'
    })
}

// ===============================================
// 角色管理 API
// ===============================================

// 获取所有角色
export function getAllRoles() {
    return request({
        url: '/admin/roles',
        method: 'get'
    })
}

// 更新用户角色
export function updateUserRoles(userId, roleIds) {
    return request({
        url: `/admin/users/${userId}/roles`,
        method: 'put',
        data: { roleIds } // 按照后端的格式传递数据
    })
}

// 创建新角色
export function createRole(roleData) {
    return request({
        url: '/admin/roles',
        method: 'post',
        data: roleData
    })
}

// 更新角色信息
export function updateRole(roleId, roleData) {
    return request({
        url: `/admin/roles/${roleId}`,
        method: 'put',
        data: roleData
    })
}

// 删除角色
export function deleteRole(roleId) {
    return request({
        url: `/admin/roles/${roleId}`,
        method: 'delete'
    })
}


// ===============================================
// 【新增】关注管理 API
// ===============================================

/**
 * 根据卖家ID获取其关注者列表（粉丝列表）
 * @param {object} params - 查询参数 { page, pageSize, sellerId }
 */
export function getFollowers(params) {
    return request({
        url: '/follows/followers',
        method: 'get',
        params
    })
}

/**
 * (卖家)移除粉丝
 * @param {object} params - { followerId, followedId }
 */
export function removeFollower(params) {
    return request({
        url: '/follows/unfollow',
        method: 'delete',
        params
    })
}

// 关注用户
export const followUser = (followerId, followedId) => {
    return request({
        method: 'POST',
        url: '/follows/follow',
        params: { followerId, followedId }
    });
};

// 取消关注用户
export const unfollowUser = (followerId, followedId) => {
    return request({
        method: 'DELETE',
        url: '/follows/unfollow',
        params: { followerId, followedId }
    });
};

// 检查关注状态
export const checkFollowStatus = (followerId, followedId) => {
    return request({
        method: 'GET',
        url: '/follows/status',
        params: { followerId, followedId }
    });
};
