<template>
  <a-modal
      :visible="visible"
      :title="modalTitle"
      @cancel="handleCancel"
      :footer="null"
      centered
      width="600px"
  >
    <!-- 确保有通知数据时才渲染内容 -->
    <div v-if="notification && notification.content" class="notification-detail-content">

      <!-- ========================================================== -->
      <!-- ============ 【核心修改】为管理员仲裁创建专属视图 ============ -->
      <!-- ========================================================== -->
      <div v-if="notification.type === 'admin_judgment'" class="judgment-view">
        <a-result
            :status="judgmentStatus.status"
            :title="judgmentStatus.title"
            :sub-title="`涉及商品：${notification.content.productName || '未知'}`"
        >
          <template #extra>
            <a-button v-if="notification.content.link" type="primary" @click="handleNavigate">
              <LinkOutlined />
              查看售后详情
            </a-button>
          </template>
        </a-result>

        <a-steps direction="vertical" size="small" :current="2">
          <a-step title="您的申请" :description="`申请理由：${notification.content.reason || '未提供'}`" />
          <a-step title="平台裁决" :description="notification.content.result || '处理中'" />
          <a-step title="裁决理由" :description="notification.content.adminRemark || '请查看详情'" />
        </a-steps>

        <div class="refund-info" v-if="notification.content.refundAmount">
          <strong>涉及金额:</strong>
          <span>¥ {{ notification.content.refundAmount.toFixed(2) }}</span>
        </div>
      </div>

      <!-- ========================================================== -->
      <!-- ============ 为其他通知类型保留通用视图 ============ -->
      <!-- ========================================================== -->
      <div v-else class="generic-view">
        <div class="message-section">
          <p>{{ notification.content.message }}</p>
        </div>
        <a-descriptions bordered :column="1" size="small">
          <template v-for="(value, key) in notification.content" :key="key">
            <a-descriptions-item v-if="!['title', 'message', 'link'].includes(key)" :label="translateKey(key)">
              {{ formatValue(key, value) }}
            </a-descriptions-item>
          </template>
        </a-descriptions>
        <div class="actions-section" v-if="notification.content.link">
          <a-button type="primary" @click="handleNavigate" size="large">
            <LinkOutlined />
            前往处理
          </a-button>
        </div>
      </div>

    </div>
    <!-- 如果没有通知数据，则显示一个空状态 -->
    <div v-else>
      <a-empty description="没有可显示的通知内容" />
    </div>
  </a-modal>
</template>

<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';
// 移除所有按需导入，使用全局注册的组件
import { LinkOutlined } from '@ant-design/icons-vue';

const props = defineProps({
  visible: { type: Boolean, required: true },
  notification: { type: Object, default: null },
});

const emit = defineEmits(['close']);
const router = useRouter();

/**
 * 动态计算模态框的标题
 */
const modalTitle = computed(() => {
  if (!props.notification) return '平台售后通知详情';
  if (props.notification.type === 'admin_judgment') return '平台仲裁结果';
  return props.notification.content?.title || '平台售后通知详情';
});

/**
 * 【新增】根据仲裁结果，返回不同的状态和标题用于 a-result 组件
 */
const judgmentStatus = computed(() => {
  const resultText = props.notification?.content?.result || '';
  // 通过关键词判断结果是成功还是失败
  if (resultText.includes('同意') || resultText.includes('成功') || resultText.includes('支持')) {
    return { status: 'success', title: '售后申请已支持' };
  }
  if (resultText.includes('拒绝') || resultText.includes('失败') || resultText.includes('驳回')) {
    return { status: 'error', title: '售后申请被驳回' };
  }
  // 默认情况
  return { status: 'info', title: '平台已处理' };
});

/**
 * 扩展的字段名翻译字典
 */
const keyMap = {
  details: '详细信息',
  relatedOrderId: '相关订单号',
  timestamp: '时间',
  reason: '买家申请理由',
  result: '处理结果',
  adminRemark: '平台备注',
  applicant: '申请人',
  shippingCompany: '物流公司',
  trackingNumber: '运单号',
  productName: '商品名称',
  refundAmount: '退款金额',
  afterSaleId: '售后单号',
  orderItemId: '订单项ID',
};

const translateKey = (key) => {
  return keyMap[key] || key;
};

/**
 * 【新增】格式化显示的值，例如金额
 * @param {string} key - 字段名
 * @param {*} value - 字段值
 */
const formatValue = (key, value) => {
  if (key === 'refundAmount' && typeof value === 'number') {
    return `¥ ${value.toFixed(2)}`;
  }
  return value;
}

const handleCancel = () => {
  emit('close');
};

const handleNavigate = () => {
  if (props.notification?.content?.link) {
    router.push(props.notification.content.link);
    handleCancel();
  }
};
</script>

<style scoped>
.notification-detail-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 通用视图样式 */
.message-section p {
  font-size: 16px;
  line-height: 1.7;
  color: #333;
  margin: 0;
  padding: 10px;
  background-color: #f9f9f9;
  border-radius: 8px;
  border-left: 4px solid #1890ff;
}

.actions-section {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

/* 仲裁视图专属样式 */
.judgment-view {
  padding: 0 16px;
}

/* 覆盖 a-result 的一些默认间距，使其更紧凑 */
:deep(.ant-result) {
  padding: 16px 0;
}

:deep(.ant-steps) {
  margin-top: 16px;
  padding: 16px;
  background-color: #fafafa;
  border-radius: 8px;
}

.refund-info {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
  font-size: 16px;
  display: flex;
  justify-content: space-between;
}
.refund-info span {
  font-weight: bold;
  color: #faad14;
}
</style>
