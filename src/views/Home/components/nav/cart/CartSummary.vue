<template>
  <div class="summary-card sticky-top">
    <h5 class="mb-3 fw-semibold">订单摘要</h5>
    <div class="d-flex justify-content-between mb-2">
      <span class="text-muted">商品总数</span>
      <span class="fw-medium">{{ totalQuantity }}件</span>
    </div>
    <div class="d-flex justify-content-between mb-4">
      <span class="text-muted">总金额</span>
      <span class="price-tag h4">
        ¥{{ totalPrice }}
      </span>
    </div>
    <button class="btn btn-success w-100 py-2 rounded-pill fw-semibold"
            @click="$emit('handle-payment')"
            :disabled="loading">
      <i v-if="!loading" class="fas fa-wallet me-2"></i>
      <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status"></span>
      {{ loading ? '处理中...' : '立即结算' }}
    </button>
    <div class="mt-3 text-center small text-muted">
      支持支付宝、微信支付等多种支付方式
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  totalQuantity: {
    type: Number,
    required: true,
    default: 0
  },
  totalPrice: {
    type: String,
    required: true,
    default: '0.00'
  },
  loading: {
    type: Boolean,
    default: false
  }
});

defineEmits(['handle-payment']);
</script>

<style scoped>
/* 复用原有的样式 */
:root {
  --primary-color: #5c9e53; /* 柔和绿色 */
  --secondary-color: #f7faf5; /* 更浅的淡灰绿背景 */
  --hover-color: #e6f0e6; /* 悬浮背景淡绿 */
  --text-muted-color: #6b7a63; /* 柔和的文字灰绿 */
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
}

.summary-card {
  background: #fff;
  border-radius: 16px;
  padding: 2rem 2.5rem;
  border: 1px solid var(--border-color);
  box-shadow: 0 5px 15px var(--shadow-color);
  position: sticky;
  top: 100px;
}

.summary-card h5 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 0.5rem;
  margin-bottom: 1.5rem;
  user-select: none;
}

.summary-card .text-muted {
  color: var(--text-muted-color);
  user-select: none;
}

.summary-card .fw-medium {
  font-weight: 600;
}

.btn-success {
  background-color: var(--primary-color);
  border: none;
  font-weight: 600;
  font-size: 1.1rem;
  padding: 0.65rem 0;
  border-radius: 50px;
  box-shadow: 0 6px 14px rgba(92, 158, 83, 0.35);
  transition: background-color 0.3s ease, box-shadow 0.3s ease;
}

.btn-success:hover,
.btn-success:focus {
  background-color: #46783a;
  box-shadow: 0 10px 25px rgba(70, 120, 58, 0.5);
  outline: none;
}

.price-tag {
  color: var(--primary-color);
  font-weight: 700;
  font-size: 1.35rem;
  user-select: none;
}

/* 小屏幕适配 */
@media (max-width: 768px) {
  .summary-card {
    padding: 1.5rem 1.8rem;
  }

  .btn-success {
    font-size: 1rem;
    padding: 0.6rem 0;
  }
}
</style>
