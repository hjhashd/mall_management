// src/api/address.js
import request from '@/utils/request'

export function getUserAddresses() {
  return request({
    url: '/user/addresses',
    method: 'get'
  })
}

export function addUserAddress(addressData) {
  return request({
    url: '/user/addresses',
    method: 'post',
    data: addressData
  })
}

export function updateUserAddress(addressId, addressData) {
  return request({
    url: `/user/addresses/${addressId}`,
    method: 'put',
    data: addressData
  })
}

export function deleteUserAddress(addressId) {
  return request({
    url: `/user/addresses/${addressId}`,
    method: 'delete'
  })
}

export function setDefaultAddress(addressId) {
  return request({
    url: `/user/addresses/${addressId}/default`,
    method: 'put'
  })
}

export function getDefaultAddress() {
  return request({
    url: '/user/addresses/default',
    method: 'get'
  })
}

/**
 * [Admin] 获取所有用户的地址列表
 * @returns Promise
 */
export function getAllUserAddresses() {
  return request({
    url: '/user/addresses/admin/addresses',
    method: 'get'
  })
}

/**
 * [Admin] 更新指定ID的地址信息
 * @param {number} addressId - 地址ID
 * @param {object} addressData - 要更新的地址数据
 * @returns Promise
 */
export function updateUserAddressByAdmin(addressId, addressData) {
  return request({
    url: `/user/addresses/admin/${addressId}`,
    method: 'put',
    data: addressData
  })
}

/**
 * [Admin] 删除指定ID的地址
 * @param {number} addressId - 地址ID
 * @returns Promise
 */
export function deleteUserAddressByAdmin(addressId) {
  return request({
    url: `/user/addresses/admin/${addressId}`,
    method: 'delete'
  })
}
