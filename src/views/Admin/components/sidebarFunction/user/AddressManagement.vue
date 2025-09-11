<template>
  <div class="address-management-container animate-fade-in">
    <div class="stats-grid">
      <div class="stat-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-icon icon-total">
          <i class="fas fa-map-marker-alt"></i>
        </div>
        <div class="card-content">
          <p class="card-title">总地址数</p>
          <h2 class="card-value">{{ allAddresses.length }}</h2>
          <span class="card-trend">
            <i class="fas fa-database"></i> 全部地址
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.2s;">
        <div class="card-icon icon-default">
          <i class="fas fa-star"></i>
        </div>
        <div class="card-content">
          <p class="card-title">默认地址总数</p>
          <h2 class="card-value">{{ defaultAddressCount }}</h2>
          <span class="card-trend positive">
            <i class="fas fa-check"></i> 已设默认
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.3s;">
        <div class="card-icon icon-province">
          <i class="fas fa-globe-asia"></i>
        </div>
        <div class="card-content">
          <p class="card-title">覆盖省份</p>
          <h2 class="card-value">{{ uniqueProvinces.length }}</h2>
          <span class="card-trend">
            <i class="fas fa-map"></i> 地域分布
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.4s;">
        <div class="card-icon icon-city">
          <i class="fas fa-city"></i>
        </div>
        <div class="card-content">
          <p class="card-title">覆盖城市</p>
          <h2 class="card-value">{{ uniqueCities.length }}</h2>
          <span class="card-trend">
            <i class="fas fa-building"></i> 城市数量
          </span>
        </div>
      </div>
    </div>

    <div class="header-bar">
      <h1 class="page-title">用户地址管理 (管理员)</h1>
      <div class="actions-group">
        <div class="search-box">
          <i class="fas fa-search search-icon"></i>
          <input type="text" v-model="searchQuery" placeholder="搜索用户、收货人、电话或地址...">
        </div>
        <div class="filter-box">
          <select v-model="selectedProvince" class="filter-select">
            <option value="">全部省份</option>
            <option v-for="province in uniqueProvinces" :key="province" :value="province">
              {{ province }}
            </option>
          </select>
        </div>
        <button class="refresh-btn" @click="refreshData" :disabled="isLoading">
          <i class="fas fa-sync-alt" :class="{ 'fa-spin': isLoading }"></i>
        </button>
      </div>
    </div>

    <div class="address-table-card">
      <table class="address-table">
        <thead>
        <tr>
          <th>收货人信息</th>
          <th>完整地址</th>
          <th>邮政编码</th>
          <th>状态</th>
          <th>关联用户</th>
          <th>创建时间</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="isLoading">
          <td colspan="7" class="empty-state">
            <i class="fas fa-spinner fa-spin"></i>
            <p>正在加载地址数据...</p>
          </td>
        </tr>
        <tr v-else-if="paginatedAddresses.length === 0">
          <td colspan="7" class="empty-state">
            <i class="fas fa-map-marked"></i>
            <p>没有找到匹配的收货地址</p>
          </td>
        </tr>
        <tr v-for="address in paginatedAddresses" :key="address.addressId" class="address-row">
          <td>
            <div class="receiver-info-cell">
              <div class="receiver-details">
                <span class="receiver-name">{{ address.receiverName }}</span>
                <span class="receiver-phone">{{ address.receiverPhone }}</span>
              </div>
            </div>
          </td>
          <td>
            <div class="address-detail-cell">
              <span class="address-text">{{ getFullAddress(address) }}</span>
            </div>
          </td>
          <td>
            <span class="postal-code">{{ address.postalCode || 'N/A' }}</span>
          </td>
          <td>
            <div class="status-wrapper">
              <span class="status-badge" :class="address.isDefault ? 'status-default' : 'status-normal'">
                {{ address.isDefault ? '默认地址' : '普通地址' }}
              </span>
            </div>
          </td>
          <td>
            <div class="user-info-cell">
              <span class="user-name">{{ address.userName || 'N/A' }}</span>
              <span class="user-id">ID: {{ address.userId }}</span>
            </div>
          </td>
          <td>{{ formatDate(address.createdAt) }}</td>
          <td>
            <div class="action-buttons">
              <button class="action-btn btn-view" @click="viewAddress(address)" title="查看详情">
                <i class="fas fa-eye"></i>
              </button>
              <button class="action-btn btn-edit" @click="openEditModal(address)" title="编辑地址">
                <i class="fas fa-pencil-alt"></i>
              </button>
              <button class="action-btn btn-delete" @click="confirmDelete(address)" title="删除地址">
                <i class="fas fa-trash-alt"></i>
              </button>
            </div>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1">
        <i class="fas fa-chevron-left"></i>
      </button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页 (共 {{ filteredAddresses.length }} 条)</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages">
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>

    <div v-if="showViewModal" class="modal-overlay" @click="closeViewModal">
      <div class="modal-content view-modal" @click.stop>
        <div class="modal-header">
          <h3>地址详情</h3>
          <button class="modal-close" @click="closeViewModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" v-if="selectedAddress">
          <div class="detail-grid">
            <div class="detail-item"><label>关联用户</label><span>{{ selectedAddress.userName }} (ID: {{ selectedAddress.userId }})</span></div>
            <div class="detail-item"><label>收货人姓名</label><span>{{ selectedAddress.receiverName }}</span></div>
            <div class="detail-item"><label>联系电话</label><span>{{ selectedAddress.receiverPhone }}</span></div>
            <div class="detail-item full-width"><label>收货地址</label><span>{{ getFullAddress(selectedAddress) }}</span></div>
            <div class="detail-item"><label>邮政编码</label><span>{{ selectedAddress.postalCode || 'N/A' }}</span></div>
            <div class="detail-item"><label>地址状态</label><span class="status-badge" :class="selectedAddress.isDefault ? 'status-default' : 'status-normal'">{{ selectedAddress.isDefault ? '默认地址' : '普通地址' }}</span></div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditModal" class="modal-overlay" @click="closeEditModal">
      <div class="modal-content edit-modal" @click.stop>
        <div class="modal-header">
          <h3>编辑地址</h3>
          <button class="modal-close" @click="closeEditModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveAddress" class="edit-form">
            <div class="form-grid">
              <div class="form-item"><label>收货人姓名 *</label><input type="text" v-model="editForm.receiverName" required></div>
              <div class="form-item"><label>联系电话 *</label><input type="tel" v-model="editForm.receiverPhone" required></div>
              <div class="form-item"><label>省份 *</label><select v-model="editForm.province" required><option value="">请选择省份</option><option v-for="p in provincesData" :key="p" :value="p">{{ p }}</option></select></div>
              <div class="form-item"><label>城市 *</label><select v-model="editForm.city" required><option value="">请选择城市</option><option v-for="c in getCities()" :key="c" :value="c">{{ c }}</option></select></div>
              <div class="form-item"><label>区县 *</label><select v-model="editForm.district" required><option value="">请选择区县</option><option v-for="d in getDistricts()" :key="d" :value="d">{{ d }}</option></select></div>
              <div class="form-item"><label>邮政编码</label><input type="text" v-model="editForm.postalCode"></div>
              <div class="form-item full-width"><label>详细地址 *</label><textarea v-model="editForm.detailAddress" rows="3" required></textarea></div>
              <div class="form-item full-width"><label class="checkbox-label"><input type="checkbox" v-model="editForm.isDefault"><span class="checkmark"></span>设为默认收货地址</label></div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn-cancel" @click="closeEditModal">取消</button>
              <button type="submit" class="btn-save">保存</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import {
  getAllUserAddresses,
  updateUserAddressByAdmin,
  deleteUserAddressByAdmin
} from '@/api/address.js';
// 1. 从你的 composables 目录导入 useNotification
import { useNotification } from '@/composables/useNotification.js';

// 2. 创建 notification 实例，之后就可以在代码中使用了
const notification = useNotification();

// --- 状态管理 ---
const allAddresses = ref([]);
const searchQuery = ref('');
const selectedProvince = ref('');
const isLoading = ref(false);
const showViewModal = ref(false);
const showEditModal = ref(false);
const selectedAddress = ref(null);
const editForm = ref({});
const pagination = ref({ currentPage: 1, pageSize: 10 });

// --- 省市区数据 ---
const provincesData = ['北京市', '上海市', '广东省', '江苏省', '浙江省', '山东省', '河南省', '四川省', '湖北省', '湖南省'];
const citiesData = {
  '北京市': ['市辖区'], '上海市': ['市辖区'], '广东省': ['广州市', '深圳市', '珠海市', '佛山市', '东莞市', '中山市'],
  '江苏省': ['南京市', '苏州市', '无锡市', '常州市', '镇江市'], '浙江省': ['杭州市', '宁波市', '温州市', '嘉兴市', '湖州市']
};
const districtsData = {
  '市辖区': ['东城区', '西城区', '朝阳区', '海淀区', '浦东新区', '黄浦区'], '广州市': ['天河区', '越秀区', '海珠区', '白云区'],
  '深圳市': ['福田区', '南山区', '罗湖区', '宝安区'], '杭州市': ['西湖区', '上城区', '拱墅区']
};

// --- API 调用 ---
const fetchAddresses = async () => {
  isLoading.value = true;
  try {
    const response = await getAllUserAddresses();
    // 根据你的代码，你的数据在 response.data.data 中
    allAddresses.value = response.data.data || [];
  } catch (error) {
    console.error("获取所有地址列表失败:", error);
    // 使用通知组件显示错误
    notification.error('获取地址列表失败: ' + (error.response?.data?.message || error.message));
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchAddresses);

const refreshData = async () => {
  await fetchAddresses();
  notification.success('数据已刷新');
};

// --- 计算属性 ---
const filteredAddresses = computed(() => {
  let filtered = allAddresses.value;
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(address =>
        (address.userName && address.userName.toLowerCase().includes(query)) ||
        address.receiverName.toLowerCase().includes(query) ||
        address.receiverPhone.includes(query) ||
        getFullAddress(address).toLowerCase().includes(query)
    );
  }
  if (selectedProvince.value) {
    filtered = filtered.filter(address => address.province === selectedProvince.value);
  }
  return filtered;
});

const paginatedAddresses = computed(() => {
  const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
  return filteredAddresses.value.slice(start, start + pagination.value.pageSize);
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredAddresses.value.length / pagination.value.pageSize)));
const defaultAddressCount = computed(() => allAddresses.value.filter(a => a.isDefault).length);
const uniqueProvinces = computed(() => [...new Set(allAddresses.value.map(a => a.province))]);
const uniqueCities = computed(() => [...new Set(allAddresses.value.map(a => a.city))]);

// --- 方法 ---
const getFullAddress = (address) => `${address.province || ''} ${address.city || ''} ${address.district || ''} ${address.detailAddress || ''}`.trim();
const formatDate = (dateString) => dateString ? new Date(dateString).toLocaleString('zh-CN') : 'N/A';
const changePage = (page) => { if (page > 0 && page <= totalPages.value) pagination.value.currentPage = page; };

// --- 模态框与表单操作 ---
const openEditModal = (address) => { editForm.value = { ...address }; showEditModal.value = true; };
const viewAddress = (address) => { selectedAddress.value = address; showViewModal.value = true; };
const closeEditModal = () => { showEditModal.value = false; };
const closeViewModal = () => { showViewModal.value = false; };

const saveAddress = async () => {
  try {
    await updateUserAddressByAdmin(editForm.value.addressId, editForm.value);
    // 使用通知组件显示成功
    notification.success('地址更新成功！');
    closeEditModal();
    await fetchAddresses();
  } catch (error) {
    console.error("更新地址失败:", error);
    // 使用通知组件显示错误
    notification.error('操作失败: ' + (error.response?.data?.message || error.message));
  }
};

const confirmDelete = async (address) => {
  if (confirm(`确定要删除用户 "${address.userName}" 的这条地址吗？`)) {
    try {
      await deleteUserAddressByAdmin(address.addressId);
      notification.success('地址删除成功！');
      await fetchAddresses();
    } catch (error) {
      console.error("删除地址失败:", error);
      // 使用通知组件显示错误
      notification.error('删除失败: ' + (error.response?.data?.message || error.message));
    }
  }
};

// --- 省市区联动 ---
const getCities = () => citiesData[editForm.value.province] || [];
const getDistricts = () => districtsData[editForm.value.city] || [];
</script>


<style scoped>
/* 整体容器和动画 */
.address-management-container {
  padding: 2rem;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");
  color: var(--text-primary);
}

.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-slide-up {
  opacity: 0;
  transform: translateY(20px);
  animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards var(--delay, 0s);
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 统计卡片样式 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.1));
  border-color: var(--accent-color);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.stat-card:hover::before {
  left: 100%;
}

.card-icon {
  font-size: 2rem;
  padding: 1rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
}

.icon-total {
  background: linear-gradient(135deg, rgba(159, 120, 255, 0.2), rgba(124, 58, 237, 0.1));
  color: var(--accent-color, #9f78ff);
  border: 1px solid rgba(159, 120, 255, 0.3);
}

.icon-default {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.1));
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.icon-province {
  background: linear-gradient(135deg, rgba(46, 204, 113, 0.2), rgba(39, 174, 96, 0.1));
  color: #2ecc71;
  border: 1px solid rgba(46, 204, 113, 0.3);
}

.icon-city {
  background: linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(14, 165, 233, 0.1));
  color: #38bdf8;
  border: 1px solid rgba(56, 189, 248, 0.3);
}

.card-content {
  flex: 1;
}

.card-title {
  font-size: 0.875rem;
  color: var(--text-secondary);
  margin: 0 0 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.card-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 0.5rem;
  line-height: 1.2;
}

.card-trend {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: var(--text-secondary);
}

.card-trend.positive {
  color: #10b981;
}

.card-trend i {
  font-size: 0.75rem;
}

/* 头部栏 */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
}

.actions-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.search-box {
  position: relative;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
}

.search-box input, .filter-select {
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.6rem 1rem 0.6rem 2.5rem;
  color: var(--text-primary);
  font-size: 0.9rem;
  transition: all var(--transition-speed, 0.3s) ease;
  width: 250px;
}
.search-box input:focus, .filter-select:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(159, 120, 255, 0.2);
}

.filter-select {
  padding-left: 1rem;
  width: 150px;
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%23a0a0b0' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
}

.refresh-btn {
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  color: var(--text-secondary);
  border-radius: var(--border-radius-sm, 8px);
  width: 40px;
  height: 40px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
}
.refresh-btn:hover {
  color: var(--accent-color);
  border-color: var(--accent-color);
  transform: rotate(90deg);
}

/* 表格卡片 */
.address-table-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  overflow-x: auto;
}

.address-table {
  width: 100%;
  border-collapse: collapse;
  white-space: nowrap;
}

.address-table th, .address-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}

.address-table thead th {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.address-row {
  transition: background-color var(--transition-speed, 0.3s) ease;
}

.address-row:hover {
  background-color: var(--bg-hover, rgba(255, 255, 255, 0.03));
}

.address-row td {
  font-size: 0.9rem;
  color: var(--text-primary);
  vertical-align: middle;
}

/* 表格单元格内容样式 */
.receiver-info-cell, .user-info-cell {
  display: flex;
  flex-direction: column;
}

.receiver-name, .user-name {
  font-weight: 600;
  color: var(--text-primary);
}

.receiver-phone, .user-id {
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.address-text {
  max-width: 300px;
  white-space: normal;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.status-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

.status-default {
  background-color: rgba(251, 191, 36, 0.15);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.status-normal {
  background-color: rgba(160, 160, 176, 0.15);
  color: var(--text-secondary);
  border: 1px solid rgba(160, 160, 176, 0.3);
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border: none;
  background-color: rgba(255, 255, 255, 0.08);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn:hover {
  transform: translateY(-2px);
  color: #fff;
}

.btn-view:hover { background-color: #38bdf8; }
.btn-edit:hover { background-color: #10b981; }
.btn-set:hover { background-color: #fbbf24; }
.btn-unset:hover { background-color: #f87171; }
.btn-delete:hover { background-color: #ef4444; }

.btn-unset { color: #fbbf24; }

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 4rem 0;
  color: var(--text-secondary);
}
.empty-state i {
  font-size: 3rem;
  margin-bottom: 1rem;
}
.empty-state p {
  font-size: 1.1rem;
  font-weight: 500;
}

/* 分页 */
.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 1.5rem;
  gap: 1rem;
  color: var(--text-secondary);
}
.pagination-controls button {
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  color: var(--text-secondary);
  border-radius: var(--border-radius-sm, 8px);
  width: 36px;
  height: 36px;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
}
.pagination-controls button:hover:not(:disabled) {
  background-color: var(--accent-color);
  color: #fff;
  border-color: var(--accent-color);
}
.pagination-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 模态框样式 - 关键修复部分 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(5px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  /* 使用继承的主题变量而不是固定值 */
  background: var(--bg-primary, #2a2c3d);
  border-radius: var(--border-radius-md, 16px);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  box-shadow: 0 10px 30px var(--shadow-color, rgba(0, 0, 0, 0.2));
  width: 90%;
  max-width: 700px;
  animation: slideInUp 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  /* 添加背景过滤器以适应主题 */
  backdrop-filter: var(--backdrop-filter, none);
}

@keyframes slideInUp {
  from { transform: translateY(30px) scale(0.98); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}

.modal-header {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}
.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--text-primary);
}
.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--text-secondary);
  cursor: pointer;
  transition: color 0.3s, transform 0.3s;
}
.modal-close:hover {
  color: var(--accent-color);
  transform: rotate(90deg);
}

.modal-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

/* 查看详情模态框 */
.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}
.detail-item {
  display: flex;
  flex-direction: column;
}
.detail-item label {
  font-size: 0.8rem;
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
}
.detail-item span {
  font-size: 1rem;
  color: var(--text-primary);
}
.detail-item.full-width {
  grid-column: 1 / -1;
}

/* 编辑模态框表单 */
.edit-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}
.form-item {
  display: flex;
  flex-direction: column;
}
.form-item.full-width {
  grid-column: 1 / -1;
}
.form-item label {
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  color: var(--text-secondary);
}
.form-item input,
.form-item select,
.form-item textarea {
  width: 100%;
  box-sizing: border-box;
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.75rem;
  color: var(--text-primary);
  font-size: 0.9rem;
  transition: all var(--transition-speed, 0.3s) ease;
}
.form-item input:focus,
.form-item select:focus,
.form-item textarea:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(159, 120, 255, 0.2);
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
  font-size: 0.9rem;
  color: var(--text-primary);
}
.checkbox-label input {
  position: absolute;
  opacity: 0;
  cursor: pointer;
  height: 0;
  width: 0;
}
.checkmark {
  height: 20px;
  width: 20px;
  background-color: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: 4px;
  margin-right: 12px;
  position: relative;
  transition: all 0.2s ease;
}
.checkbox-label:hover .checkmark {
  border-color: var(--accent-color);
}
.checkbox-label input:checked ~ .checkmark {
  background-color: var(--accent-color);
  border-color: var(--accent-color);
}
.checkmark:after {
  content: "";
  position: absolute;
  display: none;
  left: 6px;
  top: 2px;
  width: 5px;
  height: 10px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}
.checkbox-label input:checked ~ .checkmark:after {
  display: block;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}
.btn-cancel, .btn-save {
  padding: 0.75rem 1.5rem;
  border-radius: var(--border-radius-sm, 8px);
  border: none;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-speed, 0.3s) ease;
}
.btn-cancel {
  background: var(--bg-secondary, rgba(255, 255, 255, 0.05));
  color: var(--text-primary);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}
.btn-cancel:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
.btn-save {
  background-color: var(--accent-color);
  color: #fff;
}
.btn-save:hover {
  background-color: var(--accent-color-hover, #8b5cf6);
}

/* 响应式设计 */
@media (max-width: 992px) {
  .address-management-container {
    padding: 1.5rem;
  }
}

@media (max-width: 768px) {
  .address-management-container {
    padding: 1rem;
  }
  .header-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  .actions-group {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }
  .search-box input, .filter-select {
    width: 100%;
    box-sizing: border-box;
  }
  .modal-content {
    width: 95%;
    max-height: 90vh;
  }
  .detail-grid, .form-grid {
    grid-template-columns: 1fr;
  }
  .detail-item.full-width, .form-item.full-width {
    grid-column: auto;
  }
}
</style>
