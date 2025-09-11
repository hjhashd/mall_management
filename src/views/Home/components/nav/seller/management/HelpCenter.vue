<template>
  <div class="help-center-container">
    <!-- 顶部欢迎和搜索区域 -->
    <div class="help-header">
      <div class="header-content">
        <h1>您好，我们能为您提供什么帮助？</h1>
        <p>在这里查找建议、操作方法和常见问题的答案。</p>
        <a-input-search
            v-model:value="searchTerm"
            placeholder="例如：如何上传商品？"
            size="large"
            class="search-input"
            enter-button
        />
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="help-content">
      <!-- 如果没有搜索结果 -->
      <a-empty v-if="filteredFaqs.length === 0 && searchTerm" description="未找到相关问题，请尝试其他关键词。"/>

      <!-- 常见问题列表 -->
      <div v-else class="faq-list">
        <h2>常见问题</h2>
        <a-collapse v-model:activeKey="activeKey" accordion>
          <a-collapse-panel v-for="faq in filteredFaqs" :key="faq.id" :header="faq.question">
            <div class="faq-answer" v-html="faq.answer"></div>
          </a-collapse-panel>
        </a-collapse>
      </div>

      <!-- 联系我们卡片 -->
      <div class="contact-card">
        <div class="contact-content">
          <QuestionCircleOutlined class="contact-icon" />
          <div class="contact-text">
            <h3>没有找到您想要的答案？</h3>
            <p>我们的支持团队随时准备为您提供帮助。</p>
          </div>
          <a-button type="primary" size="large">联系客服</a-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { QuestionCircleOutlined } from '@ant-design/icons-vue';

// 搜索词
const searchTerm = ref('');

// Collapse 组件的 active key
const activeKey = ref([]);

// 模拟的常见问题数据
const faqs = ref([
  {
    id: 1,
    question: '如何注册成为卖家？',
    answer: '要注册成为卖家，请访问我们的主页，点击“卖家入驻”按钮，然后按照屏幕上的指示完成注册流程。您需要提供一些基本信息，例如店铺名称、联系方式和营业执照。'
  },
  {
    id: 2,
    question: '如何发布新商品？',
    answer: '登录到您的卖家中心，导航至“商品管理”页面，然后点击“添加新商品”按钮。您需要填写商品的详细信息，包括标题、描述、价格、库存和图片。'
  },
  {
    id: 3,
    question: '如何处理订单？',
    answer: '当您收到新订单时，您会在“订单管理”页面看到它。点击订单查看详情，然后您可以进行确认、打包、发货等操作。请确保及时更新订单状态，以便买家了解最新进展。'
  },
  {
    id: 4,
    question: '支持哪些支付方式？',
    answer: '我们平台支持多种主流支付方式，包括信用卡、借记卡、支付宝和微信支付。所有交易都经过加密处理，以确保安全。'
  },
  {
    id: 5,
    question: '如何处理退款请求？',
    answer: '买家可以在订单详情页面提交退款请求。您将在卖家中心收到通知。请根据平台的退款政策与买家沟通并处理请求。您可以在“订单管理”中找到相关的退款操作选项。'
  },
  {
    id: 6,
    question: '如何查看销售数据报告？',
    answer: '在卖家中心的“数据分析”板块，您可以查看详细的销售报告、流量分析和客户洞察。这些数据可以帮助您优化经营策略。'
  }
]);

// 根据搜索词过滤问题
const filteredFaqs = computed(() => {
  if (!searchTerm.value.trim()) {
    return faqs.value;
  }
  const lowerCaseSearch = searchTerm.value.toLowerCase();
  return faqs.value.filter(
      faq =>
          faq.question.toLowerCase().includes(lowerCaseSearch) ||
          faq.answer.toLowerCase().includes(lowerCaseSearch)
  );
});

</script>

<style scoped>
.help-center-container {
  background-color: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.help-header {
  padding: 48px 24px;
  background: linear-gradient(135deg, #1890ff 0%, #364d79 100%);
  color: white;
  text-align: center;
}

.header-content h1 {
  font-size: 28px;
  font-weight: 600;
  margin-bottom: 8px;
  color: white;
}

.header-content p {
  font-size: 16px;
  margin-bottom: 24px;
  opacity: 0.9;
}

.search-input {
  max-width: 600px;
  margin: 0 auto;
}

.help-content {
  padding: 32px 24px;
}

.faq-list h2 {
  font-size: 22px;
  font-weight: 600;
  margin-bottom: 24px;
  color: #333;
}

.ant-collapse {
  background-color: #fff;
  border: 1px solid #d9d9d9;
  border-radius: 8px;
}
.ant-collapse-item {
  border-bottom: 1px solid #d9d9d9;
}
.ant-collapse-item:last-child {
  border-bottom: none;
}

.faq-answer {
  color: #555;
  line-height: 1.7;
  padding: 0 16px 16px;
}

.contact-card {
  margin-top: 48px;
  background-color: #f0f5ff;
  border: 1px solid #adc6ff;
  border-radius: 8px;
  padding: 24px;
}

.contact-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.contact-icon {
  font-size: 28px;
  color: #1890ff;
}

.contact-text {
  flex-grow: 1;
}

.contact-text h3 {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 4px;
  color: #333;
}

.contact-text p {
  margin-bottom: 0;
  color: #555;
}

</style>
