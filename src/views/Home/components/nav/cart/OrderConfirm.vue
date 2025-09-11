<template>
  <div>
    <HomeNavbar />

    <main class="order-container">
      <div class="container">
        <h2 class="mb-4 fw-bold text-success">
          <i class="fas fa-clipboard-check me-2"></i>确认订单
        </h2>

        <!-- 加载状态 -->
        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-success" role="status">
            <span class="visually-hidden">加载中...</span>
          </div>
          <p class="mt-3 text-muted">正在加载订单信息...</p>
        </div>

        <!-- 订单内容 -->
        <div v-else-if="cartItems.length > 0" class="row">
          <!-- 左侧：订单信息 -->
          <div class="col-lg-8">
            <!-- 收货地址 -->
            <div class="order-section">
              <h5><i class="fas fa-map-marker-alt me-2"></i>收货地址</h5>

              <!-- 地址模式切换 -->
              <div class="form-check form-switch mb-3">
                <input class="form-check-input" type="checkbox" id="useDefaultSwitch" v-model="useDefaultAddress" @change="applyDefaultAddress">
                <label class="form-check-label" for="useDefaultSwitch">{{ useDefaultAddress ? '使用默认地址' : '手动填写地址' }}</label>
              </div>

              <!-- 默认地址展示 -->
              <div v-if="useDefaultAddress" class="default-address-card">
                <div v-if="defaultAddress" class="d-flex justify-content-between align-items-start">
                  <div>
                    <div class="fw-semibold mb-1">
                      {{ defaultAddress.receiverName }}
                      <span class="text-muted ms-2">{{ defaultAddress.receiverPhone }}</span>
                      <span class="badge bg-success ms-2" v-if="defaultAddress.isDefault">默认</span>
                    </div>
                    <div class="text-muted small">
                      {{ formatFullAddress(defaultAddress) }}
                    </div>
                  </div>
                  <div class="btn-group">
                    <button class="btn btn-outline-primary btn-sm" @click="showAddressSelector = true">更换地址</button>
                    <button class="btn btn-outline-success btn-sm" @click="openCreateAddress">
                      <i class="fas fa-plus me-1"></i>新增地址
                    </button>
                  </div>
                </div>
                <div v-else class="text-muted">
                  没有默认地址，请先新增或选择一个地址。
                  <div class="mt-2">
                    <button class="btn btn-outline-primary btn-sm me-2" @click="showAddressSelector = true">选择地址</button>
                    <button class="btn btn-outline-success btn-sm" @click="openCreateAddress">
                      <i class="fas fa-plus me-1"></i>新增地址
                    </button>
                  </div>
                </div>
              </div>

              <!-- 手动填写地址 -->
              <div v-if="!useDefaultAddress">
                <div class="mb-3">
                  <input type="text"
                         v-model="address"
                         class="form-control"
                         placeholder="请输入详细收货地址"
                         required>
                </div>
                <div class="mb-3">
                  <input type="text"
                         v-model="receiver"
                         class="form-control"
                         placeholder="收货人姓名"
                         required>
                </div>
                <div class="mb-3">
                  <input type="tel"
                         v-model="phone"
                         class="form-control"
                         placeholder="联系电话"
                         required>
                </div>
              </div>

              <div class="mb-3">
                <label for="shipping_company" class="form-label">选择物流公司</label>
                <select class="form-select"
                        id="shipping_company"
                        v-model="shippingCompany"
                        required>
                  <option value="">请选择物流公司</option>
                  <option value="顺丰速运">顺丰速运</option>
                  <option value="圆通快递">圆通快递</option>
                  <option value="中通快递">中通快递</option>
                  <option value="申通快递">申通快递</option>
                  <option value="韵达快递">韵达快递</option>
                  <option value="京东物流">京东物流</option>
                  <option value="其他">其他</option>
                </select>
              </div>
            </div>

            <!-- 商品清单 -->
            <div class="order-section">
              <h5><i class="fas fa-shopping-bag me-2"></i>商品清单</h5>
              <div v-for="item in cartItems" :key="item.cartId" class="product-item">
                <img :src="getProductImage(item)" class="product-thumbnail">
                <div class="flex-grow-1">
                  <h6 class="mb-1">{{ getProductTitle(item) }}</h6>
                  <p class="text-muted small mb-1">{{ getProductAuthor(item) }}</p>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="text-muted">数量：{{ item.quantity }}</span>
                    <span class="text-success fw-bold">¥{{ (getProductPrice(item) * item.quantity).toFixed(2) }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 订单备注 -->
            <div class="order-section">
              <h5><i class="fas fa-comment-alt me-2"></i>订单备注</h5>
              <textarea class="form-control"
                        v-model="remark"
                        rows="3"
                        placeholder="请输入订单备注（选填）"></textarea>
            </div>
          </div>

          <!-- 右侧：支付信息 -->
          <div class="col-lg-4">
            <div class="order-section">
              <h5><i class="fas fa-credit-card me-2"></i>支付方式</h5>
              <div class="payment-method"
                   :class="{ 'selected': selectedPayment === 'alipay' }"
                   @click="selectPayment('alipay')">
                <i class="fab fa-alipay me-2 text-primary"></i>支付宝支付
              </div>
              <div class="payment-method"
                   :class="{ 'selected': selectedPayment === 'wechat' }"
                   @click="selectPayment('wechat')">
                <i class="fab fa-weixin me-2 text-success"></i>微信支付
              </div>
              <div class="payment-method"
                   :class="{ 'selected': selectedPayment === 'balance' }"
                   @click="selectPayment('balance')">
                <i class="fas fa-coins me-2 text-warning"></i>余额支付
                <span class="balance">（余额：¥{{ balance.toFixed(2) }}）</span>
              </div>
            </div>

            <div class="order-section">
              <h5><i class="fas fa-calculator me-2"></i>订单金额</h5>
              <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">商品总额</span>
                <span>¥{{ totalPrice }}</span>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">运费</span>
                <span>¥0.00</span>
              </div>
              <hr>
              <div class="d-flex justify-content-between mb-3">
                <span class="fw-bold">应付总额</span>
                <span class="text-success fw-bold h5 mb-0">¥{{ totalPrice }}</span>
              </div>
              <button class="btn btn-success w-100"
                      @click="submitOrder()"
                      :disabled="submitting">
                <i v-if="!submitting" class="fas fa-lock me-2"></i>
                <span v-if="submitting" class="spinner-border spinner-border-sm me-2" role="status"></span>
                {{ submitting ? '提交中...' : '提交订单' }}
              </button>
            </div>
          </div>
        </div>

        <!-- 空购物车提示 -->
        <div v-else class="text-center py-5">
          <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
          <h4 class="mb-3 text-secondary">购物车为空</h4>
          <a href="/cart" class="btn btn-success px-4 rounded-pill">
            <i class="fas fa-shopping-cart me-2"></i>返回购物车
          </a>
        </div>
      </div>
    </main>

    <!-- 提示框 -->
    <div id="simpleToast" class="toast align-items-center text-white border-0 position-fixed bottom-0 end-0 m-3"
         :style="{ background: toastType === 'success' ? '#28a745' : '#dc3545', display: showToast ? 'block' : 'none' }">
      <div class="d-flex">
        <div class="toast-body">
          <i :class="toastType === 'success' ? 'fas fa-check-circle me-2' : 'fas fa-exclamation-circle me-2'"></i>
          <span v-html="toastMessage"></span>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto"
                @click="showToast = false"></button>
      </div>
    </div>

    <!-- 地址选择弹层 -->
    <div v-if="showAddressSelector" class="address-overlay" @click.self="showAddressSelector = false">
      <div class="address-panel">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="mb-0">选择收货地址</h6>
          <button class="btn btn-sm btn-outline-secondary" @click="showAddressSelector = false">关闭</button>
        </div>

        <div v-if="addresses.length > 0">
          <div v-for="addr in addresses" :key="addr.addressId" class="address-item-selectable">
            <div class="d-flex justify-content-between">
              <div @click="chooseAddress(addr)" style="cursor: pointer; flex-grow: 1;">
                <div class="fw-semibold mb-1">
                  {{ addr.receiverName }} <span class="text-muted ms-2">{{ addr.receiverPhone }}</span>
                  <span class="badge bg-success ms-2" v-if="addr.isDefault">默认</span>
                </div>
                <div class="text-muted small">{{ formatFullAddress(addr) }}</div>
              </div>
              <div class="btn-group-vertical ml-2">
                <button class="btn btn-sm btn-outline-primary" @click.stop="editAddress(addr)">
                  <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-outline-danger" @click.stop="deleteAddress(addr.addressId)">
                  <i class="fas fa-trash"></i>
                </button>
                <button v-if="!addr.isDefault" class="btn btn-sm btn-outline-success" @click.stop="setDefault(addr.addressId)">
                  <i class="fas fa-star"></i>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div v-else>
          <p class="text-muted">暂无地址，请新增一个地址。</p>
          <button class="btn btn-success btn-sm" @click="openCreateAddress">
            新增收货地址
          </button>
        </div>
      </div>
    </div>

    <!-- 地址表单 - 支持新增和编辑 -->
    <AddressForm
        :visible="showCreateAddress"
        :address="addressToEdit"
        :is-editing="!!addressToEdit"
        @save="handleAddressSave"
        @cancel="closeAddressForm"
    ></AddressForm>
  </div>
</template>

<script setup>
import {ref, computed, onMounted, watch} from 'vue';
import {useRouter, useRoute} from 'vue-router';
import {useUserStore} from '@/stores/userStore';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import {submitOrder as apiSubmitOrder, getUserBalance} from '@/api/order';
import {
  getDefaultAddress as apiGetDefaultAddress,
  getUserAddresses as apiGetUserAddresses,
  addUserAddress,
  updateUserAddress,
  deleteUserAddress,
  setDefaultAddress
} from '@/api/address';
import AddressForm from '../address/AddressForm.vue';

// 控制是否显示新增地址表单
const showCreateAddress = ref(false);
// 添加响应式数据
const addressToEdit = ref(null);

// 路由和store
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();

// 响应式数据
const cartItems = ref([]);
const loading = ref(true);
const submitting = ref(false);
const balance = ref(0.00);

// 地址相关
const useDefaultAddress = ref(true);
const defaultAddress = ref(null);
const addresses = ref([]);
const selectedAddressId = ref(null);
const showAddressSelector = ref(false);

// 表单数据（手动）
const address = ref('');
const receiver = ref('');
const phone = ref('');
const remark = ref('');
const shippingCompany = ref('');
const selectedPayment = ref('');

// 提示框状态
const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success');

onMounted(async () => {
  await initializeOrder();
});

// 初始化订单数据
const initializeOrder = async () => {
  try {
    loading.value = true;

    if (route.state && route.state.cartItems) {
      cartItems.value = route.state.cartItems;
    } else {
      const storedCart = localStorage.getItem('checkoutCart');
      if (storedCart) {
        cartItems.value = JSON.parse(storedCart);
      }
    }

    if (userStore.isLoggedIn) {
      try {
        const balanceResponse = await getUserBalance();
        if (balanceResponse.data.success) {
          balance.value = balanceResponse.data.data || 0;
        }
      } catch (error) {
        console.warn('获取用户余额失败:', error);
        balance.value = userStore.userInfo?.balance || 0;
      }
    }

    await Promise.all([fetchDefaultAddress(), fetchAddresses()]);

    if (defaultAddress.value) {
      useDefaultAddress.value = true;
      selectedAddressId.value = defaultAddress.value.addressId;
    } else if (addresses.value.length > 0) {
      defaultAddress.value = addresses.value[0];
      selectedAddressId.value = addresses.value[0].addressId;
      useDefaultAddress.value = true;
    }

    if (cartItems.value.length === 0) {
      router.push('/cart');
    }

  } catch (error) {
    console.error('初始化订单失败:', error);
    showToastMessage('初始化订单失败，请稍后重试', 'error');
  } finally {
    loading.value = false;
  }
};

const fetchDefaultAddress = async () => {
  try {
    const res = await apiGetDefaultAddress();
    if (res.data?.success) {
      defaultAddress.value = res.data.data || null;
      if (defaultAddress.value) {
        selectedAddressId.value = defaultAddress.value.addressId;
      }
    }
  } catch (e) {
    console.warn('获取默认地址失败', e);
  }
};

const fetchAddresses = async () => {
  try {
    const res = await apiGetUserAddresses();
    if (res.data?.success) {
      addresses.value = res.data.data || [];
    }
  } catch (e) {
    console.warn('获取地址列表失败', e);
  }
};

const applyDefaultAddress = () => {
  if (useDefaultAddress.value && defaultAddress.value) {
    selectedAddressId.value = defaultAddress.value.addressId;
  } else {
    selectedAddressId.value = null;
  }
};

const handleAddressSave = async (addressData) => {
  try {
    let response;
    const isEditing = !!addressToEdit.value;

    if (isEditing) {
      response = await updateUserAddress(addressToEdit.value.addressId, addressData);
    } else {
      response = await addUserAddress(addressData);
    }

    // 检查响应
    if (response && response.data && response.data.success) {
      showToastMessage(isEditing ? '地址更新成功！' : '地址添加成功！', 'success');
      showCreateAddress.value = false;
      addressToEdit.value = null;

      // 重新获取地址列表来确保数据是最新的
      await Promise.all([fetchDefaultAddress(), fetchAddresses()]);

      // 如果设置了默认地址，更新默认地址显示
      if (addressData.isDefault) {
        const newDefault = addresses.value.find(addr => addr.isDefault) ||
            (addresses.value.length > 0 ? addresses.value[0] : null);
        if (newDefault) {
          defaultAddress.value = newDefault;
          selectedAddressId.value = newDefault.addressId;
        }
      }

      // 延迟显示地址选择模态框，让用户看到成功提示
        showAddressSelector.value = true;


      return;
    } else {
      throw new Error(response?.data?.message || '操作失败');
    }
  } catch (error) {
    console.error('保存地址失败:', error);
    const isEditing = !!addressToEdit.value;
    showToastMessage(isEditing ? `地址更新失败: ${error.message}` : `地址添加失败: ${error.message}`, 'error');

    // 失败时也重新显示地址选择模态框
    setTimeout(() => {
      showAddressSelector.value = true;
    }, 1000);
  }
};

const closeAddressForm = () => {
  showCreateAddress.value = false;
  addressToEdit.value = null;

  // 取消后显示地址选择模态框
  setTimeout(() => {
    showAddressSelector.value = true;
  }, 100);
};

const chooseAddress = (addr) => {
  defaultAddress.value = addr;
  selectedAddressId.value = addr.addressId;
  useDefaultAddress.value = true;
  showAddressSelector.value = false;
};

const editAddress = (addr) => {
  // 关闭地址选择弹层
  showAddressSelector.value = false;

  // 添加短暂延迟确保动画完成
  setTimeout(() => {
    addressToEdit.value = { ...addr };
    showCreateAddress.value = true;
  }, 50);
};

// 打开创建地址表单
const openCreateAddress = () => {
  // 关闭地址选择弹层
  showAddressSelector.value = false;

  setTimeout(() => {
    addressToEdit.value = null; // 清空编辑数据，表示新增
    showCreateAddress.value = true;
  }, 50);
};

// 处理新增地址
const handleNewAddress = async (newAddressData) => {
  try {
    // 验证手机号格式
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(newAddressData.receiverPhone)) {
      showToastMessage('请输入正确的手机号格式！', 'error');
      return;
    }

    const response = await addUserAddress(newAddressData);

    if (response.data?.success) {
      const newAddress = response.data.data;
      showToastMessage('地址添加成功！', 'success');
      showCreateAddress.value = false;

      // 重新获取地址列表
      await Promise.all([fetchDefaultAddress(), fetchAddresses()]);

      // 如果这是第一个地址或被设为默认，则更新默认地址
      if (newAddress.isDefault || (!defaultAddress.value && addresses.value.length === 1)) {
        defaultAddress.value = newAddress;
        selectedAddressId.value = newAddress.addressId;
        useDefaultAddress.value = true;
      }
    } else {
      showToastMessage('地址添加失败: ' + (response.data?.message || '未知错误'), 'error');
    }
  } catch (error) {
    console.error('添加地址失败:', error);
    showToastMessage('添加地址失败，请稍后重试', 'error');
  }
};

const setDefault = async (addressId) => {
  try {
    const res = await setDefaultAddress(addressId);
    if (res.data?.success) {
      showToastMessage('默认地址设置成功', 'success');
      await fetchAddresses();

      const newDefault = addresses.value.find(addr => addr.addressId === addressId);
      if (newDefault) {
        defaultAddress.value = newDefault;
        selectedAddressId.value = newDefault.addressId;
      }
    }
  } catch (error) {
    console.error('设置默认地址失败:', error);
    showToastMessage('设置失败，请重试', 'error');
  }
};

const deleteAddress = async (addressId) => {
  if (confirm('确定删除这个地址吗？')) {
    try {
      const res = await deleteUserAddress(addressId);
      if (res.data?.success) {
        showToastMessage('地址已删除', 'success');
        await fetchAddresses();

        if (selectedAddressId.value === addressId) {
          if (addresses.value.length > 0) {
            const newDefault = addresses.value.find(a => a.isDefault) || addresses.value[0];
            defaultAddress.value = newDefault;
            selectedAddressId.value = newDefault.addressId;
          } else {
            defaultAddress.value = null;
            selectedAddressId.value = null;
            useDefaultAddress.value = false;
          }
        }
      }
    } catch (error) {
      console.error('删除地址失败:', error);
      showToastMessage('删除失败，请重试', 'error');
    }
  }
};

watch(addresses, (newAddresses) => {
  if (defaultAddress.value) {
    const updatedAddr = newAddresses.find(a => a.addressId === defaultAddress.value.addressId);
    if (updatedAddr) {
      defaultAddress.value = updatedAddr;
    }
  }
});

const formatFullAddress = (addr) => {
  if (!addr) return '';
  return `${addr.province || ''} ${addr.city || ''} ${addr.district || ''} ${addr.detailAddress || ''}`.trim();
};

const getProductImage = (item) => {
  if (item.images && item.images.length > 0) {
    return item.images[0].imageUrl;
  }
  if (item.book && item.book.coverImage) {
    return item.book.coverImage;
  }
  return 'https://via.placeholder.com/100x120?text=商品';
};

const getProductTitle = (item) => {
  return item.title || item.book?.title || '未知商品';
};


  const getProductAuthor = (item) => {
    // 优先显示description，如果没有则显示conditionText，再没有就显示brand，最后显示'未知'
    return item.description || item.conditionText || item.brand || '未知';
  };


const getProductPrice = (item) => {
  return item.price || item.currentPrice || item.book?.price || 0;
};

const totalPrice = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (getProductPrice(item) * item.quantity), 0).toFixed(2);
});

const selectPayment = (method) => {
  selectedPayment.value = method;
};

const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;
  setTimeout(() => {
    showToast.value = false;
  }, 3000);
};

const submitOrder = async () => {
  if (!shippingCompany.value) {
    showToastMessage('请选择物流公司', 'error');
    return;
  }

  if (!selectedPayment.value) {
    showToastMessage('请选择支付方式', 'error');
    return;
  }

  if (useDefaultAddress.value) {
    if (!selectedAddressId.value) {
      showToastMessage('请选择默认地址', 'error');
      return;
    }
  } else {
    if (!address.value || !receiver.value || !phone.value) {
      showToastMessage('请填写完整的收货信息', 'error');
      return;
    }
  }

  if (selectedPayment.value === 'balance' && parseFloat(balance.value) < parseFloat(totalPrice.value)) {
    showToastMessage('余额不足，请选择其他支付方式', 'error');
    return;
  }

  try {
    submitting.value = true;

    const orderData = {
      paymentMethod: selectedPayment.value,
      addressId: useDefaultAddress.value ? selectedAddressId.value : undefined,
      address: useDefaultAddress.value ? undefined : address.value,
      receiver: useDefaultAddress.value ? undefined : receiver.value,
      phone: useDefaultAddress.value ? undefined : phone.value,
      remark: remark.value,
      shippingCompany: shippingCompany.value
    };

    const response = await apiSubmitOrder(orderData);

    if (response.data.success) {
      showToastMessage('订单提交成功！', 'success');
      localStorage.removeItem('checkoutCart');
      setTimeout(() => {
        router.push('/orders');
      }, 2000);
    } else {
      showToastMessage('订单提交失败: ' + response.data.message, 'error');
    }
  } catch (error) {
    console.error('提交订单失败:', error);
    let errorMessage = '提交订单失败，请稍后重试';

    if (error.response && error.response.data && error.response.data.message) {
      errorMessage = error.response.data.message;
    }

    showToastMessage(errorMessage, 'error');
  } finally {
    submitting.value = false;
  }
};

watch(selectedAddressId, (newId) => {
  if (newId && useDefaultAddress.value) {
    const selectedAddr = addresses.value.find(addr => addr.addressId === newId);
    if (selectedAddr) {
      address.value = formatFullAddress(selectedAddr);
      receiver.value = selectedAddr.receiverName;
      phone.value = selectedAddr.receiverPhone;
    }
  }
});
</script>

<style>
:root {
  --primary-color: #5c9e53;
  --secondary-color: #f7faf5;
  --hover-color: #e6f0e6;
  --text-muted-color: #6b7a63;
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
}

.order-container {
  background: var(--secondary-color);
  min-height: 70vh;
  padding: 3rem 0 2rem 0;
  padding-top: 80px;
}

.order-section {
  background: #fff;
  border-radius: 16px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
}

.order-section h5 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 0.5rem;
  margin-bottom: 1.5rem;
}

.product-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.product-item:last-child {
  border-bottom: none;
}

.product-thumbnail {
  width: 80px;
  height: 100px;
  object-fit: contain;
  border-radius: 8px;
  margin-right: 1rem;
}

.payment-method {
  border: 2px solid var(--border-color);
  border-radius: 12px;
  padding: 1rem;
  margin-bottom: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.payment-method:hover {
  border-color: var(--primary-color);
  background: var(--hover-color);
}

.payment-method.selected {
  border-color: var(--primary-color);
  background: var(--hover-color);
}

.btn-success {
  background-color: var(--primary-color);
  border: none;
  font-weight: 600;
  padding: 0.8rem 2rem;
  border-radius: 50px;
  box-shadow: 0 6px 14px rgba(92, 158, 83, 0.35);
}

.btn-success:hover:not(:disabled) {
  background-color: #46783a;
  box-shadow: 0 10px 25px rgba(70, 120, 58, 0.5);
}

.btn-success:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.balance {
  font-size: 0.9rem;
  color: #a1ad89;
}

/* 默认地址卡片 */
.default-address-card {
  border: 1px dashed var(--border-color);
  border-radius: 12px;
  padding: 1rem;
  margin-bottom: 1rem;
  background: #fbfffb;
}

/* 地址选择弹层 */
.address-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.address-panel {
  background: #fff;
  width: 92%;
  max-width: 640px;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.address-item-selectable {
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 0.75rem 1rem;
  margin-bottom: 0.75rem;
  cursor: pointer;
}

.address-item-selectable:hover {
  background: var(--hover-color);
}

/* 加载动画样式 */
.spinner-border {
  width: 3rem;
  height: 3rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .order-container {
    padding: 2rem 0 1rem 0;
    padding-top: 60px;
  }

  .container {
    padding: 0 15px;
  }

  .order-section {
    padding: 1.5rem;
  }
}

.address-overlay {
  z-index: 1050; /* 保持原值 */
}

.address-form-overlay {
  z-index: 1100; /* 高于地址选择弹层 */
}
</style>
