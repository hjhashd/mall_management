<template>
  <div>
    <HomeNavbar />

    <main class="order-module__page-container">
      <div class="container">
        <div class="d-flex align-items-center mb-4">
          <a href="#" @click.prevent="router.back()" class="btn btn-light me-3 rounded-circle" style="width: 40px; height: 40px; line-height: 26px;"><i class="fas fa-arrow-left"></i></a>
          <h2 class="mb-0 fw-bold text-success">
            订单详情
          </h2>
        </div>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-success" role="status" style="width: 3rem; height: 3rem;">
            <span class="visually-hidden">加载中...</span>
          </div>
          <p class="mt-3 text-muted">正在加载订单详情...</p>
        </div>

        <div v-else-if="order" class="row g-4">
          <div class="col-lg-8">
            <div class="order-module__card mb-4">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <span class="text-muted">订单号：</span>
                  <span class="fw-semibold user-select-all">{{ order.orderId }}</span>
                </div>
                <span class="order-module__status-badge" :class="getStatusClass(order.status)">
                  {{ getStatusText(order.status) }}
                </span>
              </div>
              <hr>
              <div class="text-muted small">下单时间：{{ formatDate(order.createdAt) }}</div>
              <div v-if="order.paymentTime" class="text-muted small">支付时间：{{ formatDate(order.paymentTime) }}</div>
            </div>

            <div class="order-module__card mb-4">
              <h5><i class="fas fa-map-marker-alt"></i>收货信息</h5>
              <p class="mb-1"><strong>收货人：</strong>{{ order.receiverName || '-' }}</p>
              <p class="mb-1"><strong>联系电话：</strong>{{ order.receiverPhone || '-' }}</p>
              <p class="text-muted mb-0"><strong>收货地址：</strong>{{ order.shippingAddress || '-' }}</p>
            </div>

            <div class="order-module__card mb-4">
              <h5><i class="fas fa-shopping-bag"></i>商品清单 ({{ order.items.length }})</h5>
              <div v-for="item in order.items" :key="item.itemId" class="order-module__detail-item">
                <router-link :to="`/product/${item.productId}`">
                  <img :src="item.productImage || 'https://placehold.co/80x80/e2e8f0/e2e8f0?text=...'" class="order-module__detail-thumbnail" :alt="item.productName">
                </router-link>
                <div class="item-info">
                  <router-link :to="`/product/${item.productId}`" class="text-decoration-none text-dark">
                    <h6>{{ item.productName }}</h6>
                  </router-link>
                  <p class="text-muted small mb-0">单价: ¥{{ (item.unitPrice || 0).toFixed(2) }}</p>
                </div>
                <div class="item-price-quantity">
                  <div class="price">¥{{ (item.totalPrice || item.unitPrice * item.quantity).toFixed(2) }}</div>
                  <div class="text-muted small">x {{ item.quantity }}</div>
                </div>
              </div>
            </div>
            <div v-if="order.userRemark" class="order-module__card mb-4">
              <h5><i class="fas fa-comment-alt"></i>买家备注</h5>
              <p class="text-muted mb-0">{{ order.userRemark }}</p>
            </div>
          </div>

          <div class="col-lg-4">
            <div class="order-module__card mb-4">
              <h5><i class="fas fa-calculator"></i>订单金额</h5>
              <div class="order-module__amount-summary">
                <div class="summary-row">
                  <span>商品总额</span>
                  <span>¥{{ order.totalAmount.toFixed(2) }}</span>
                </div>
                <div class="summary-row">
                  <span>运费</span>
                  <span>+ ¥0.00</span>
                </div>
                <div class="summary-row summary-total">
                  <span class="total-label">应付总额</span>
                  <span class="total-value">¥{{ order.totalAmount.toFixed(2) }}</span>
                </div>
              </div>
            </div>

            <div class="order-module__card">
              <h5><i class="fas fa-truck"></i>物流与操作</h5>
              <div class="mb-3">
                <div class="text-muted small mb-1"><strong>物流公司：</strong>{{ order.shippingCompany || '暂无信息' }}</div>
                <div class="text-muted small"><strong>运单号：</strong>{{ order.trackingNumber || '暂无信息' }}</div>
              </div>
              <div class="d-grid gap-2 order-detail-actions">
                <button class="btn btn-outline-primary" :disabled="!order.trackingNumber" @click="openLogistics">
                  <i class="fas fa-route me-1"></i>查看物流
                </button>
                <button v-if="order.status === 3" class="btn btn-success" @click="onConfirmReceive" :disabled="confirming">
                  <span v-if="confirming" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                  <i v-else class="fas fa-check-circle me-1"></i>
                  {{ confirming ? '处理中...' : '确认收货' }}
                </button>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-5">
        </div>
      </div>
    </main>

    <LogisticsModal v-if="showLogistics" :order-id="order?.orderId" :tracking-number="order?.trackingNumber" :shipping-company="order?.shippingCompany" @close="showLogistics=false" />
  </div>
</template>

<script setup>
import {ref, onMounted, computed} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import HomeNavbar from '@/views/Home/components/HomeNavbar.vue'
import LogisticsModal from './LogisticsModal.vue'
import {getOrderDetail, confirmReceive as apiConfirmReceive} from '@/api/order'

// 注意：这里不需要再 import css，因为已在 main.js 全局引入

const route = useRoute()
const router = useRouter()
const order = ref(null)
const loading = ref(true)
const confirming = ref(false)
const showLogistics = ref(false)

onMounted(async () => {
  await fetchDetail()
})

const fetchDetail = async () => {
  try {
    loading.value = true
    const orderId = route.params.orderId
    const res = await getOrderDetail(orderId)
    if (res.data?.success) {
      order.value = normalizeOrder(res.data.data)
      // For testing purposes
      if (import.meta.env.DEV && order.value) {
        order.value.trackingNumber = order.value.trackingNumber || 'SF1234567890';
        order.value.shippingCompany = order.value.shippingCompany || '顺丰速运';
      }
    }
  } finally {
    loading.value = false
  }
}

const normalizeOrder = (o) => {
  if (!o) return o
  const totalAmount = parseFloat(o.totalAmount) || 0;
  if (Array.isArray(o.items)) {
    o.items = o.items.map(it => ({
      ...it,
      unitPrice: parseFloat(it.unitPrice != null ? it.unitPrice : it.price || 0),
      totalPrice: parseFloat(it.totalPrice || (it.unitPrice * it.quantity))
    }))
  }
  return {...o, totalAmount};
}

const getStatusClass = (status) => {
  const map = {
    1: 'order-module__status-badge--pending',   // 待付款
    2: 'order-module__status-badge--shipped',   // 待发货
    3: 'order-module__status-badge--shipped',   // 待收货
    4: 'order-module__status-badge--completed', // 已完成
    5: 'order-module__status-badge--cancelled', // 已取消
    6: 'order-module__status-badge--pending',   // 退款中
    7: 'order-module__status-badge--cancelled', // 已退款
  };
  return map[status] || 'order-module__status-badge--cancelled';
};

const getStatusText = (status) => {
  const map = {
    1: '待付款',
    2: '待发货', // <-- 已修正逻辑
    3: '待收货',
    4: '已完成',
    5: '已取消',
    6: '退款中',
    7: '已退款'
  }
  return map[status] || '未知状态'
}

const formatDate = (d) => {
  if (!d) return '-'
  return new Date(d).toLocaleString('zh-CN', {hour12: false})
}

const openLogistics = () => {
  if (order.value?.trackingNumber) {
    showLogistics.value = true
  }
}

const onConfirmReceive = async () => {
  if (!order.value) return
  if (!confirm('请确认您已收到所有商品，操作后订单将完成。')) return
  try {
    confirming.value = true
    const res = await apiConfirmReceive(order.value.orderId)
    if (res.data?.success) {
      await fetchDetail()
      alert('确认收货成功')
    } else {
      alert(res.data?.message || '操作失败，请重试');
    }
  } finally {
    confirming.value = false
  }
}
</script>
