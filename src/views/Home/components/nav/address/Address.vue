
<template>
  <div class="address-manager">
    <div class="address-header">
      <h5><i class="fas fa-map-marker-alt me-2"></i>收货地址管理</h5>
      <button class="btn btn-success" @click="showAddAddressForm">
        <i class="fas fa-plus-circle me-1"></i>新增地址
      </button>
    </div>

    <!-- 地址列表 -->
    <div v-if="addresses.length > 0" class="address-list">
      <div v-for="address in addresses" :key="address.addressId" class="address-item">
        <div class="address-info">
          <div class="receiver-info">
            <span class="receiver-name">{{ address.receiverName }}</span>
            <span class="receiver-phone">{{ address.receiverPhone }}</span>
            <span v-if="address.isDefault" class="default-badge">默认</span>
          </div>
          <div class="address-detail">
            {{ address.province }} {{ address.city }} {{ address.district }} {{ address.detailAddress }}
          </div>
        </div>
        <div class="address-actions">
          <button class="btn btn-outline-primary btn-sm me-2" @click="editAddress(address)">
            编辑
          </button>
          <button class="btn btn-outline-danger btn-sm me-2" @click="deleteAddress(address.addressId)">
            删除
          </button>
          <button v-if="!address.isDefault"
                  class="btn btn-outline-success btn-sm"
                  @click="setDefaultAddress(address.addressId)">
            设为默认
          </button>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-else class="empty-state">
      <i class="fas fa-map-marker-alt fa-3x text-muted mb-3"></i>
      <p class="text-muted">您还没有添加收货地址</p>
    </div>

    <!-- 新增/编辑地址表单 -->
    <div v-if="showAddForm || editingAddress" class="address-form-overlay">
     <div class="address-form animated-modal">
       <div class="d-flex justify-content-between align-items-center mb-4">
          <h6 class="mb-0 modal-title">{{ editingAddress ? '编辑地址' : '新增地址' }}</h6>
          <button type="button" class="btn-close" @click="cancelForm"></button>
        </div>
        <form @submit.prevent="saveAddress">
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label">收货人姓名 *</label>
                <input type="text" class="form-control" v-model="addressForm.receiverName" required>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label">联系电话 *</label>
                <input type="tel" class="form-control" v-model="addressForm.receiverPhone" required>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-4">
              <div class="mb-3">
                <label class="form-label">省份 *</label>
                <select class="form-select" v-model="addressForm.province" required>
                  <option value="">请选择省份</option>
                  <option v-for="province in provinces" :key="province" :value="province">
                    {{ province }}
                  </option>
                </select>
              </div>
            </div>
            <div class="col-md-4">
              <div class="mb-3">
                <label class="form-label">城市 *</label>
                <select class="form-select" v-model="addressForm.city" required>
                  <option value="">请选择城市</option>
                  <option v-for="city in getCities()" :key="city" :value="city">
                    {{ city }}
                  </option>
                </select>
              </div>
            </div>
            <div class="col-md-4">
              <div class="mb-3">
                <label class="form-label">区县 *</label>
                <select class="form-select" v-model="addressForm.district" required>
                  <option value="">请选择区县</option>
                  <option v-for="district in getDistricts()" :key="district" :value="district">
                    {{ district }}
                  </option>
                </select>
              </div>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label">详细地址 *</label>
            <textarea class="form-control" rows="3" v-model="addressForm.detailAddress" required></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">邮政编码</label>
            <input type="text" class="form-control" v-model="addressForm.postalCode">
          </div>

          <div class="mb-3">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" v-model="addressForm.isDefault" id="isDefault">
              <label class="form-check-label" for="isDefault">
                设为默认收货地址
              </label>
            </div>
          </div>

         <div class="form-actions d-flex justify-content-end gap-2 mt-4">
            <button type="button" class="btn btn-outline-secondary px-4" @click="cancelForm">取消</button>
            <button type="submit" class="btn btn-success px-4" 
                    :disabled="!addressForm.receiverName || !addressForm.receiverPhone || !addressForm.province || !addressForm.city || !addressForm.district || !addressForm.detailAddress">
              保存
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { getUserAddresses, addUserAddress, updateUserAddress, deleteUserAddress, setDefaultAddress as apiSetDefault } from '@/api/address';

// 接收props
const props = defineProps({
  editAddress: {
    type: Object,
    default: null
  },
  showForm: {
    type: Boolean,
    default: false
  }
});

// 响应式数据
const addresses = ref([]);
const showAddForm = ref(props.showForm);
const editingAddress = ref(props.editAddress);
const addressForm = ref({
  receiverName: '',
  receiverPhone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  postalCode: '',
  isDefault: false
});

// 省市数据（简化版，实际项目中可以从API获取）
const provinces = ['北京市', '上海市', '广东省', '江苏省', '浙江省', '山东省', '河南省', '四川省', '湖北省', '湖南省'];
const cities = {
  '北京市': ['东城区', '西城区', '朝阳区', '丰台区', '石景山区', '海淀区', '门头沟区', '房山区', '通州区', '顺义区', '昌平区', '大兴区', '怀柔区', '平谷区', '密云区', '延庆区'],
  '上海市': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区', '奉贤区', '崇明区'],
  '广东省': ['广州市', '深圳市', '珠海市', '汕头市', '佛山市', '韶关市', '湛江市', '肇庆市', '江门市', '茂名市', '惠州市', '梅州市', '汕尾市', '河源市', '阳江市', '清远市', '东莞市', '中山市', '潮州市', '揭阳市', '云浮市'],
  '江苏省': ['南京市', '无锡市', '徐州市', '常州市', '苏州市', '南通市', '连云港市', '淮安市', '盐城市', '扬州市', '镇江市', '泰州市', '宿迁市'],
  '浙江省': ['杭州市', '宁波市', '温州市', '嘉兴市', '湖州市', '绍兴市', '金华市', '衢州市', '舟山市', '台州市', '丽水市']
};

onMounted(async () => {
  await fetchAddresses();
});

// 获取地址列表
const fetchAddresses = async () => {
  try {
    const response = await getUserAddresses();
    if (response.data.success) {
      addresses.value = response.data.data || [];
    }
  } catch (error) {
    console.error('获取地址列表失败:', error);
  }
};

const showAddAddressForm = () => {
  editingAddress.value = null;
  addressForm.value = {
    receiverName: '',
    receiverPhone: '',
    province: '',
    city: '',
    district: '',
    detailAddress: '',
    postalCode: '',
    isDefault: false
  };
  showAddForm.value = true;
  emit('update:showForm', true);
};

// 获取城市列表
const getCities = () => {
  if (!addressForm.value.province) return [];
  return cities[addressForm.value.province] || [];
};

// 获取区县列表
const getDistricts = () => {
  if (!addressForm.value.city) return [];
  // 这里可以根据城市返回对应的区县列表
  const districts = {
    '北京市': ['东城区', '西城区', '朝阳区', '丰台区', '石景山区', '海淀区', '门头沟区', '房山区', '通州区', '顺义区', '昌平区', '大兴区', '怀柔区', '平谷区', '密云区', '延庆区'],
    '上海市': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区', '奉贤区', '崇明区'],
    '广州市': ['越秀区', '荔湾区', '海珠区', '天河区', '白云区', '黄埔区', '番禺区', '花都区', '南沙区', '从化区', '增城区'],
    '深圳市': ['罗湖区', '福田区', '南山区', '宝安区', '龙岗区', '盐田区', '龙华区', '坪山区', '光明区', '大鹏新区'],
    '南京市': ['玄武区', '秦淮区', '建邺区', '鼓楼区', '浦口区', '栖霞区', '雨花台区', '江宁区', '六合区', '溧水区', '高淳区'],
    '杭州市': ['上城区', '下城区', '江干区', '拱墅区', '西湖区', '滨江区', '萧山区', '余杭区', '富阳区', '临安区', '桐庐县', '淳安县', '建德市']
  };
  return districts[addressForm.value.city] || ['其他区县'];
};

// 编辑地址
const editAddress = (address) => {
  editingAddress.value = address;
  addressForm.value = { ...address };
  showAddForm.value = true;
  emit('update:showForm', true);
};

// 监听外部showForm变化
watch(() => props.showForm, (newValue) => {
  showAddForm.value = newValue;
});

// 监听外部editAddress变化
watch(() => props.editAddress, (newValue) => {
  if (newValue) {
    editingAddress.value = newValue;
    addressForm.value = { ...newValue };
    showAddForm.value = true;
  }
});

// 保存地址
const saveAddress = async () => {
  try {
    // 表单验证
    if (!addressForm.value.receiverName || !addressForm.value.receiverPhone ||
        !addressForm.value.province || !addressForm.value.city ||
        !addressForm.value.district || !addressForm.value.detailAddress) {
      alert('请填写所有必填项！');
      return;
    }

    // 验证手机号格式
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(addressForm.value.receiverPhone)) {
      alert('请输入正确的手机号格式！');
      return;
    }

    let response;
    if (editingAddress.value) {
      response = await updateUserAddress(editingAddress.value.addressId, addressForm.value);
    } else {
      response = await addUserAddress(addressForm.value);
    }

    if (response.data?.success) {
      const savedAddress = response.data.data;
      await fetchAddresses();
      cancelForm();

      // 触发成功事件
      emit('success', savedAddress);
    }
  } catch (error) {
    console.error('保存失败:', error);
    alert('保存失败，请稍后重试');
  }
};

// 删除地址
const deleteAddress = async (addressId) => {
  if (!confirm('确定删除这个地址吗？')) return;

  try {
    const response = await deleteUserAddress(addressId);
    if (response.data?.success) {
      await fetchAddresses();
      emit('success', null); // 触发刷新
    }
  } catch (error) {
    console.error('删除失败:', error);
    alert('删除失败，请稍后重试');
  }
};

// 设为默认地址
const setDefaultAddress = async (addressId) => {
  try {
    const response = await apiSetDefault(addressId);
    if (response.data?.success) {
      await fetchAddresses();
      emit('success', null); // 触发刷新
    }
  } catch (error) {
    console.error('设置失败:', error);
    alert('设置默认地址失败');
  }
};

// 取消表单
const cancelForm = () => {
  showAddForm.value = false;
  editingAddress.value = null;
  addressForm.value = {
    receiverName: '',
    receiverPhone: '',
    province: '',
    city: '',
    district: '',
    detailAddress: '',
    postalCode: '',
    isDefault: false
  };
  emit('update:showForm', false);
  emit('update:editAddress', null);
  // 触发取消事件
  emit('cancel');
};

// 定义组件的事件
const emit = defineEmits(['success', 'cancel']);
</script>

<style scoped>
.address-manager {
  padding: 1rem;
}

.address-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color, #e9ecef);
}

.address-header h5 {
  margin: 0;
  color: #333;
  font-weight: 600;
}

.address-list {
  display: grid;
  gap: 1rem;
}

.address-item {
  border: 1px solid var(--border-color, #e9ecef);
  border-radius: 12px;
  padding: 1.5rem;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
  position: relative;
  overflow: hidden;
}

.address-item:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.address-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: var(--primary-color, #007bff);
  border-radius: 12px 0 0 12px;
}

.address-info {
  margin-bottom: 1.25rem;
}

.receiver-info {
  margin-bottom: 0.75rem;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.receiver-name {
  font-weight: 600;
  font-size: 1.1rem;
  color: #333;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.receiver-name::before {
  content: '\f007';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  font-size: 0.9rem;
  color: var(--primary-color, #007bff);
}

.receiver-phone {
  color: var(--text-muted-color, #6c757d);
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.receiver-phone::before {
  content: '\f095';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  font-size: 0.8rem;
}

.default-badge {
  background: var(--primary-color, #007bff);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.default-badge::before {
  content: '\f005';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  font-size: 0.7rem;
}

.address-detail {
  color: var(--text-muted-color, #6c757d);
  line-height: 1.6;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 3px solid var(--primary-color, #007bff);
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.address-detail::before {
  content: '\f3c5';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  font-size: 0.9rem;
  color: var(--primary-color, #007bff);
  flex-shrink: 0;
  margin-top: 2px;
}

.address-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  padding-top: 1rem;
  border-top: 1px solid #e9ecef;
}

.address-actions .btn {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.address-actions .btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.address-actions .btn-outline-primary {
  border-color: #007bff;
  color: #007bff;
}

.address-actions .btn-outline-primary:hover {
  background: #007bff;
  color: white;
}

.address-actions .btn-outline-danger {
  border-color: #dc3545;
  color: #dc3545;
}

.address-actions .btn-outline-danger:hover {
  background: #dc3545;
  color: white;
}

.address-actions .btn-outline-success {
  border-color: #28a745;
  color: #28a745;
}

.address-actions .btn-outline-success:hover {
  background: #28a745;
  color: white;
}

.address-form-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
}

.address-form {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  width: 95%;
  max-width: 600px;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.address-form .btn-close {
  font-size: 1.2rem;
  opacity: 0.7;
}

.address-form .btn-close:hover {
  opacity: 1;
}

.form-actions {
  text-align: right;
  margin-top: 1.5rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--text-muted-color, #6c757d);
  background: #f8f9fa;
  border-radius: 12px;
  margin: 1rem 0;
}

.empty-state i {
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-state p {
  margin: 0;
  font-size: 1.1rem;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .address-item {
    padding: 1rem;
  }

  .receiver-info {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .address-actions {
    flex-direction: column;
  }

  .address-actions .btn {
    width: 100%;
    text-align: center;
  }

  .address-form {
    margin: 1rem;
    width: calc(100% - 2rem);
  }
}

/* 加载状态动画 */
.address-item {
  animation: fadeInUp 0.3s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 默认地址特殊样式 */
.address-item.default-address {
  border-color: var(--primary-color, #007bff);
  background: linear-gradient(135deg, rgba(0, 123, 255, 0.05) 0%, rgba(0, 123, 255, 0.02) 100%);
}

.address-item.default-address::before {
  background: linear-gradient(to bottom, #007bff, #0056b3);
}

/* 新增/优化的样式 */
.address-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color, #e9ecef);
}

.address-header .btn-success {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-weight: 500;
  box-shadow: 0 2px 6px rgba(40, 167, 69, 0.3);
  transition: all 0.3s ease;
}

.address-header .btn-success:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
}

.address-form-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease-out;
}

.address-form.animated-modal {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  width: 95%;
  max-width: 650px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25);
  animation: slideIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-title {
  font-weight: 600;
  color: #333;
  font-size: 1.25rem;
}

.form-control, .form-select {
  border-radius: 10px;
  padding: 0.75rem;
  border: 2px solid #e9ecef;
  transition: all 0.3s ease;
}

.form-control:focus, .form-select:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.25rem rgba(0, 123, 255, 0.15);
}

.btn-close {
  font-size: 1.5rem;
  opacity: 0.7;
  transition: all 0.2s ease;
  padding: 0.5rem;
  border-radius: 50%;
}

.btn-close:hover {
  opacity: 1;
  background: #f8f9fa;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-50px) scale(0.9);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* 响应式优化 */
@media (max-width: 768px) {
  .address-form.animated-modal {
    padding: 1.5rem;
    margin: 1rem;
    width: calc(100% - 2rem);
  }
  
  .modal-title {
    font-size: 1.1rem;
  }
}
</style>
