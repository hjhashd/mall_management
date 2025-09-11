<template>
  <div class="payment-records-container animate-fade-in">
    <!-- 头部 -->
    <div class="header-bar">
      <h1 class="page-title">支付记录</h1>
    </div>

    <!-- 筛选控件 -->
    <div class="filter-controls">
      <div class="search-bar">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="搜索订单号 / 交易号...">
      </div>
      <div class="filter-group">
        <select v-model="statusFilter">
          <option value="">所有状态</option>
          <option value="1">成功</option>
          <option value="2">失败</option>
          <option value="3">已退款</option>
          <option value="0">待支付</option>
        </select>
        <select v-model="methodFilter">
          <option value="">所有方式</option>
          <option value="alipay">支付宝</option>
          <option value="wechat">微信支付</option>
          <option value="balance">余额</option>
        </select>
        <button class="reset-btn" @click="resetFilters">重置筛选</button>
      </div>
    </div>

    <!-- 记录表格 -->
    <div class="records-table-wrapper">
      <table class="records-table">
        <thead>
        <tr>
          <th>支付ID</th>
          <th>订单号</th>
          <th>支付金额</th>
          <th>支付方式</th>
          <th>状态</th>
          <th>交易号</th>
          <th>创建时间</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="paginatedPayments.length === 0">
          <td colspan="8" class="empty-state">
            <i class="fas fa-search-dollar"></i>
            <p>没有找到匹配的支付记录</p>
          </td>
        </tr>
        <tr v-for="(payment, index) in paginatedPayments" :key="payment.payment_id" class="animate-slide-up" :style="{ '--delay': `${index * 0.05}s` }">
          <td data-label="支付ID">{{ payment.payment_id }}</td>
          <td data-label="订单号" class="order-id">{{ payment.order_id }}</td>
          <td data-label="支付金额" class="amount">¥{{ formatCurrency(payment.amount) }}</td>
          <td data-label="支付方式">
              <span class="method-badge">
                <i :class="getMethodInfo(payment.payment_method).icon"></i>
                {{ getMethodInfo(payment.payment_method).text }}
              </span>
          </td>
          <td data-label="状态">
              <span class="status-badge" :class="getStatusInfo(payment.payment_status).className">
                {{ getStatusInfo(payment.payment_status).text }}
              </span>
          </td>
          <td data-label="交易号" class="transaction-id">{{ payment.transaction_id || 'N/A' }}</td>
          <td data-label="创建时间">{{ formatDate(payment.created_at) }}</td>
          <td data-label="操作">
            <button class="details-btn" @click="openDetailsModal(payment)">查看详情</button>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

    <!-- 分页 -->
    <div v-if="totalPages > 1" class="pagination-controls">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1">
        <i class="fas fa-chevron-left"></i>
      </button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages">
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>

    <!-- 详情模态框 -->
    <div v-if="isDetailsModalOpen" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-content animate-fade-in">
        <button class="close-btn" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        <h2>支付详情 (ID: {{ selectedPayment.payment_id }})</h2>
        <div class="details-grid">
          <div class="detail-item"><label>订单号</label><p>{{ selectedPayment.order_id }}</p></div>
          <div class="detail-item"><label>支付金额</label><p>¥{{ formatCurrency(selectedPayment.amount) }}</p></div>
          <div class="detail-item"><label>支付方式</label><p>{{ getMethodInfo(selectedPayment.payment_method).text }}</p></div>
          <div class="detail-item"><label>支付状态</label><p>{{ getStatusInfo(selectedPayment.payment_status).text }}</p></div>
          <div class="detail-item full-width"><label>第三方交易号</label><p>{{ selectedPayment.transaction_id || '无' }}</p></div>
          <div class="detail-item"><label>创建时间</label><p>{{ formatDate(selectedPayment.created_at, true) }}</p></div>
          <div class="detail-item"><label>支付成功时间</label><p>{{ selectedPayment.paid_at ? formatDate(selectedPayment.paid_at, true) : '未支付' }}</p></div>
          <template v-if="selectedPayment.payment_status === 3">
            <div class="detail-item"><label>退款金额</label><p>¥{{ formatCurrency(selectedPayment.refund_amount) }}</p></div>
            <div class="detail-item"><label>退款时间</label><p>{{ formatDate(selectedPayment.refunded_at, true) }}</p></div>
            <div class="detail-item full-width"><label>退款交易号</label><p>{{ selectedPayment.refund_id }}</p></div>
          </template>
          <div class="detail-item full-width">
            <label>支付网关响应</label>
            <pre class="gateway-response">{{ selectedPayment.gateway_response || '无' }}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

// --- 状态管理 ---
const payments = ref([]);
const searchQuery = ref('');
const statusFilter = ref('');
const methodFilter = ref('');
const pagination = ref({ currentPage: 1, pageSize: 10 });
const isDetailsModalOpen = ref(false);
const selectedPayment = ref(null);

// --- 模拟数据 ---
const generateMockPayments = () => {
  payments.value = [
    { payment_id: 1, order_id: '20250827002', amount: 158.50, payment_method: 'alipay', payment_status: 1, transaction_id: '20250827220014000114110000123456', gateway_response: '{ "code": "10000", "msg": "Success" }', created_at: '2025-08-27T10:05:00Z', paid_at: '2025-08-27T10:05:30Z' },
    { payment_id: 2, order_id: '20250826003', amount: 1280.00, payment_method: 'wechat', payment_status: 1, transaction_id: '4200000540202508263369012345', gateway_response: '{ "result_code": "SUCCESS" }', created_at: '2025-08-26T11:02:00Z', paid_at: '2025-08-26T11:02:15Z' },
    { payment_id: 3, order_id: '20250825004', amount: 899.00, payment_method: 'alipay', payment_status: 1, transaction_id: '20250825220014000114110000123789', gateway_response: '{ "code": "10000", "msg": "Success" }', created_at: '2025-08-25T09:00:00Z', paid_at: '2025-08-25T09:00:45Z' },
    { payment_id: 4, order_id: '20250828001', amount: 299.00, payment_method: 'wechat', payment_status: 0, transaction_id: null, gateway_response: null, created_at: '2025-08-28T14:30:00Z', paid_at: null },
    { payment_id: 5, order_id: '20250823006', amount: 99.00, payment_method: 'wechat', payment_status: 2, transaction_id: '4200000540202508233369012555', gateway_response: '{ "result_code": "FAIL", "err_code_des": "余额不足" }', created_at: '2025-08-23T15:00:00Z', paid_at: null },
    { payment_id: 6, order_id: '20250822007', amount: 199.00, payment_method: 'alipay', payment_status: 3, transaction_id: '20250822220014000114110000123999', gateway_response: '{ "code": "10000", "msg": "Success" }', created_at: '2025-08-22T10:00:00Z', paid_at: '2025-08-22T10:00:30Z', refund_id: '2025082411001001990000012345', refunded_at: '2025-08-24T16:00:00Z', refund_amount: 199.00 },
    ...Array.from({ length: 15 }, (_, i) => ({ payment_id: 7 + i, order_id: `2025082000${i+1}`, amount: (Math.random() * 500 + 50).toFixed(2), payment_method: ['alipay', 'wechat', 'balance'][i % 3], payment_status: [1, 1, 1, 2, 3, 0][i % 6], transaction_id: `T${Date.now()}${i}`, gateway_response: '{ "code": "10000", "msg": "Success" }', created_at: new Date(Date.now() - Math.random() * 1e10).toISOString(), paid_at: new Date().toISOString() })),
  ];
};

onMounted(generateMockPayments);

// --- 计算属性 ---
const filteredPayments = computed(() => {
  return payments.value.filter(p => {
    const searchMatch = searchQuery.value ?
        p.order_id.includes(searchQuery.value) || (p.transaction_id && p.transaction_id.includes(searchQuery.value)) : true;
    const statusMatch = statusFilter.value ? p.payment_status == statusFilter.value : true;
    const methodMatch = methodFilter.value ? p.payment_method === methodFilter.value : true;
    return searchMatch && statusMatch && methodMatch;
  });
});

const totalPages = computed(() => Math.ceil(filteredPayments.value.length / pagination.value.pageSize));

const paginatedPayments = computed(() => {
  const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
  const end = start + pagination.value.pageSize;
  return filteredPayments.value.slice(start, end);
});

// --- 方法 ---
const resetFilters = () => {
  searchQuery.value = '';
  statusFilter.value = '';
  methodFilter.value = '';
  pagination.value.currentPage = 1;
};

const getStatusInfo = (status) => {
  const statuses = {
    0: { text: '待支付', className: 'status-pending' },
    1: { text: '成功', className: 'status-completed' },
    2: { text: '失败', className: 'status-failed' },
    3: { text: '已退款', className: 'status-refunded' },
  };
  return statuses[status] || { text: '未知', className: 'status-unknown' };
};

const getMethodInfo = (method) => {
  const methods = {
    alipay: { text: '支付宝', icon: 'fab fa-alipay' },
    wechat: { text: '微信支付', icon: 'fab fa-weixin' },
    balance: { text: '余额', icon: 'fas fa-wallet' },
  };
  return methods[method] || { text: '其他', icon: 'fas fa-credit-card' };
};

const formatDate = (dateString, full = false) => {
  if (!dateString) return 'N/A';
  const options = full
      ? { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }
      : { year: 'numeric', month: '2-digit', day: '2-digit' };
  return new Date(dateString).toLocaleString('zh-CN', options);
};

const formatCurrency = (amount) => (amount ? parseFloat(amount).toFixed(2) : '0.00');

const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
  }
};

const openDetailsModal = (payment) => {
  selectedPayment.value = payment;
  isDetailsModalOpen.value = true;
};
const closeDetailsModal = () => isDetailsModalOpen.value = false;
</script>

<style scoped>
/* 基础动画和布局 */
.payment-records-container { font-family: var(--font-family-base); }
.animate-fade-in { animation: fadeIn 0.5s ease-out forwards; }
.animate-slide-up { opacity: 0; animation: slideUp 0.4s ease-out forwards; animation-delay: var(--delay, 0s); }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }

/* 头部 */
.header-bar { margin-bottom: 1.5rem; }
.page-title { font-size: 2rem; font-weight: 700; color: var(--text-primary); }

/* 筛选控件 */
.filter-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  padding: 1.5rem;
  background-color: var(--bg-primary);
  border-radius: var(--border-radius-md);
  border: 1px solid var(--border-color);
  margin-bottom: 2rem;
}
.search-bar {
  flex: 1 1 300px;
  position: relative;
}
.search-bar i {
  position: absolute;
  top: 50%;
  left: 1rem;
  transform: translateY(-50%);
  color: var(--text-secondary);
}
.search-bar input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
  background-color: var(--bg-secondary);
  color: var(--text-primary);
  transition: all 0.3s ease;
}
.search-bar input:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px var(--shadow-color);
}
.filter-group {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}
.filter-group select {
  padding: 0.75rem 1rem;
  border-radius: var(--border-radius-sm);
  border: 1px solid var(--border-color);
  background-color: var(--bg-secondary);
  color: var(--text-primary);
  cursor: pointer;
}
.reset-btn {
  padding: 0.75rem 1.5rem;
  border: 1px solid var(--border-color);
  background: var(--bg-primary);
  color: var(--text-secondary);
  border-radius: var(--border-radius-sm);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}
.reset-btn:hover {
  color: var(--accent-color);
  border-color: var(--accent-color);
}

/* 表格 */
.records-table-wrapper {
  overflow-x: auto;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-md);
}
.records-table {
  width: 100%;
  border-collapse: collapse;
  color: var(--text-primary);
}
.records-table th, .records-table td {
  padding: 1rem 1.25rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}
.records-table thead {
  background-color: var(--bg-secondary);
}
.records-table th {
  font-weight: 600;
  font-size: 0.85rem;
  color: var(--text-secondary);
  text-transform: uppercase;
}
.records-table tbody tr {
  transition: background-color 0.2s ease;
}
.records-table tbody tr:hover {
  background-color: var(--bg-hover);
}
.records-table tbody tr:last-child td {
  border-bottom: none;
}
.order-id, .transaction-id {
  font-family: monospace;
  font-size: 0.9rem;
  max-width: 150px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.amount {
  font-weight: 600;
  color: var(--accent-color);
}
.method-badge { display: inline-flex; align-items: center; gap: 0.5rem; }
.method-badge .fa-alipay { color: #00A1E9; }
.method-badge .fa-weixin { color: #2DC100; }
.status-badge { padding: 0.3rem 0.8rem; border-radius: 999px; font-size: 0.8rem; font-weight: 600; }
.status-completed { background-color: rgba(46, 204, 113, 0.1); color: #2ecc71; }
.status-failed { background-color: rgba(231, 76, 60, 0.1); color: #e74c3c; }
.status-refunded { background-color: rgba(149, 165, 166, 0.1); color: #95a5a6; }
.status-pending { background-color: rgba(243, 156, 18, 0.1); color: #f39c12; }

.details-btn {
  background: transparent;
  border: none;
  color: var(--accent-color);
  font-weight: 600;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: var(--border-radius-sm);
}
.details-btn:hover { background-color: var(--bg-hover); }

/* 空状态和分页 */
.empty-state { text-align: center; padding: 4rem 0; }
.empty-state i { font-size: 3rem; color: var(--text-secondary); opacity: 0.7; }
.empty-state p { margin-top: 1rem; font-size: 1.1rem; color: var(--text-secondary); }
.pagination-controls { display: flex; justify-content: flex-end; align-items: center; margin-top: 2rem; gap: 0.75rem; color: var(--text-secondary); }
.pagination-controls button { background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); width: 38px; height: 38px; border-radius: var(--border-radius-sm); cursor: pointer; transition: all 0.3s ease; }
.pagination-controls button:hover:not(:disabled) { background-color: var(--accent-color); border-color: var(--accent-color); color: white; }
.pagination-controls button:disabled { opacity: 0.5; cursor: not-allowed; }

/* 模态框 */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.7); backdrop-filter: blur(5px); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: var(--bg-primary); color: var(--text-primary); padding: 2.5rem; border-radius: var(--border-radius-md); border: 1px solid var(--border-color); width: 90%; max-width: 800px; position: relative; }
.modal-content h2 { margin-top: 0; margin-bottom: 2rem; }
.close-btn { position: absolute; top: 1rem; right: 1rem; background: none; border: none; color: var(--text-secondary); font-size: 1.5rem; cursor: pointer; }
.details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; }
.detail-item.full-width { grid-column: 1 / -1; }
.detail-item label { color: var(--text-secondary); display: block; margin-bottom: 0.5rem; font-weight: 500; }
.detail-item p { margin: 0; background: var(--bg-secondary); padding: 0.75rem; border-radius: var(--border-radius-sm); word-wrap: break-word; }
.gateway-response { background: var(--bg-secondary); padding: 1rem; border-radius: var(--border-radius-sm); white-space: pre-wrap; word-break: break-all; max-height: 150px; overflow-y: auto; font-family: monospace; }

/* 响应式表格 */
@media (max-width: 768px) {
  .records-table thead { display: none; }
  .records-table tr { display: block; margin-bottom: 1rem; border: 1px solid var(--border-color); border-radius: var(--border-radius-md); }
  .records-table td { display: flex; justify-content: space-between; align-items: center; padding: 0.75rem 1rem; border-bottom: 1px solid var(--border-color); }
  .records-table td:last-child { border-bottom: none; }
  .records-table td::before { content: attr(data-label); font-weight: 600; color: var(--text-secondary); }
  .order-id, .transaction-id { max-width: none; white-space: normal; }
}
</style>
