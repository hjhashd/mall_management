<template>
  <div class="court-case-page-container">
    <!-- 案件主卡片 -->
    <div class="court-case-card">
      <!-- 1. 案件头部 -->
      <header class="court-case-header">
        <div class="court-case-title-section">
          <i class="fas fa-gavel court-case-title-icon"></i>
          <h1 class="court-case-title">{{ caseData.title }}</h1>
          <span :class="['court-case-status-badge', getStatusClass(caseData.status)]">
            {{ formatStatus(caseData.status) }}
          </span>
        </div>
        <div class="court-case-countdown">
          <i class="fas fa-clock"></i>
          <span>投票剩余时间: <strong>{{ timeLeft }}</strong></span>
        </div>
      </header>

      <!-- 2. 案件核心详情：原告 vs 被告 -->
      <div class="court-case-body">
        <div class="court-case-parties">
          <!-- 原告 (买家) -->
          <div class="court-party-panel">
            <div class="court-party-header">
              <i class="fas fa-user-shield"></i>
              <h2>原告 (买家)</h2>
            </div>
            <div class="court-party-content">
              <p class="court-party-statement">{{ caseData.case_details.buyer.statement }}</p>
              <h4 class="court-evidence-title">买家证据：</h4>
              <div class="court-evidence-gallery">
                <img
                    v-for="(img, index) in caseData.case_details.buyer.evidence"
                    :key="'buyer-img-' + index"
                    :src="img"
                    alt="Buyer Evidence"
                    @click="showImagePreview(img)"
                    class="court-evidence-thumbnail"
                    onerror="this.onerror=null;this.src='https://placehold.co/100x100/f8f9fa/e9ecef?text=Image+Error';"
                >
              </div>
            </div>
          </div>

          <!-- 分隔线 -->
          <div class="court-case-divider">VS</div>

          <!-- 被告 (卖家) -->
          <div class="court-party-panel">
            <div class="court-party-header">
              <i class="fas fa-store"></i>
              <h2>被告 (卖家)</h2>
            </div>
            <div class="court-party-content">
              <p class="court-party-statement">{{ caseData.case_details.seller.statement }}</p>
              <h4 class="court-evidence-title">卖家证据：</h4>
              <div class="court-evidence-gallery">
                <img
                    v-for="(img, index) in caseData.case_details.seller.evidence"
                    :key="'seller-img-' + index"
                    :src="img"
                    alt="Seller Evidence"
                    @click="showImagePreview(img)"
                    class="court-evidence-thumbnail"
                    onerror="this.onerror=null;this.src='https://placehold.co/100x100/f8f9fa/e9ecef?text=Image+Error';"
                >
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 3. 投票与结果区 -->
      <footer class="court-case-footer">
        <h3 class="court-footer-title">社区陪审团投票</h3>

        <!-- 投票进度条 -->
        <div class="court-vote-progress-bar">
          <div
              class="court-vote-progress-buyer"
              :style="{ width: buyerVotePercentage + '%' }"
              :title="`支持买家: ${buyerVotes}票 (${buyerVotePercentage}%)`"
          >
            <span v-if="buyerVotePercentage > 10">{{ buyerVotePercentage }}%</span>
          </div>
          <div
              class="court-vote-progress-seller"
              :style="{ width: sellerVotePercentage + '%' }"
              :title="`支持卖家: ${sellerVotes}票 (${sellerVotePercentage}%)`"
          >
            <span v-if="sellerVotePercentage > 10">{{ sellerVotePercentage }}%</span>
          </div>
        </div>
        <div class="court-vote-labels">
          <span>支持买家 ({{ buyerVotes }}票)</span>
          <span>支持卖家 ({{ sellerVotes }}票)</span>
        </div>

        <!-- 投票操作区 -->
        <div class="court-vote-actions" v-if="caseData.status === 0">
          <p v-if="!userVote" class="court-vote-prompt">请您根据双方提供的证据，投出公正的一票：</p>
          <p v-else class="court-vote-prompt">感谢您的投票！您的选择是：<strong>{{ userVote === 1 ? '支持买家' : '支持卖家' }}</strong></p>

          <div class="court-vote-buttons">
            <button
                @click="handleVote(1)"
                :class="['court-case-btn', 'court-btn-buyer', { 'selected': userVote === 1, 'disabled': userVote !== null }]"
                :disabled="userVote !== null"
            >
              <i class="fas fa-check"></i> 支持买家
            </button>
            <button
                @click="handleVote(2)"
                :class="['court-case-btn', 'court-btn-seller', { 'selected': userVote === 2, 'disabled': userVote !== null }]"
                :disabled="userVote !== null"
            >
              <i class="fas fa-check"></i> 支持卖家
            </button>
          </div>

          <div v-if="userVote" class="court-vote-reason">
            <textarea v-model="voteReason" placeholder="可以简单说明您的投票理由（选填）" class="court-reason-textarea"></textarea>
            <button @click="submitVote" class="court-case-btn court-btn-submit" :disabled="isSubmitting">
              <span v-if="isSubmitting" class="court-spinner-sm"></span>
              <span v-else>提交理由</span>
            </button>
          </div>
        </div>
        <div v-else class="court-vote-closed">
          <p>投票已于 {{ new Date(caseData.deadline).toLocaleString() }} 截止。</p>
          <p>最终结果：<strong>{{ caseData.result === 1 ? '支持买家' : '支持卖家' }}</strong></p>
        </div>
      </footer>
    </div>

    <!-- 图片预览模态框 -->
    <transition name="court-modal-fade">
      <div v-if="isPreviewVisible" class="court-image-preview-overlay" @click="closeImagePreview">
        <div class="court-image-preview-container" @click.stop>
          <img :src="previewImageUrl" alt="Evidence Preview" class="court-image-preview-content">
          <button @click="closeImagePreview" class="court-modal-close-btn">&times;</button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue';

// --- Mock Data ---
// 模拟从API获取的案件数据，结构与你的数据库表设计保持一致
const caseData = reactive({
  judgment_id: 101,
  after_sale_id: 202,
  title: '关于一部二手手机屏幕划痕的纠纷',
  case_details: {
    buyer: {
      statement: '卖家描述手机为99新，无任何划痕。但我收到后发现屏幕右上角有一道明显划痕，影响观感。要求退货退款。',
      evidence: [
        'https://images.unsplash.com/photo-1581888224339-a6a4a799a2ba?q=80&w=800',
        'https://images.unsplash.com/photo-1614377288428-964b4f0c2a5c?q=80&w=800',
        'https://images.unsplash.com/photo-1592189352137-b84a48b0e5d8?q=80&w=800'
      ]
    },
    seller: {
      statement: '手机发货前已拍照确认完好，所谓的划痕非常轻微，属于正常使用痕迹，不影响任何功能。买家过于挑剔，不同意全额退款，最多补偿20元。',
      evidence: [
        'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=800',
        'https://images.unsplash.com/photo-1605234933992-d3122972ee63?q=80&w=800'
      ]
    }
  },
  status: 0, // 0-仲裁中, 1-仲裁结束
  deadline: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(), // 截止时间设为2天后
  result: null, // 1-支持买家, 2-支持卖家
});

// --- Component State ---
const timeLeft = ref('');
const buyerVotes = ref(128); // 模拟初始票数
const sellerVotes = ref(89); // 模拟初始票数
const userVote = ref(null); // 用户投票选项: null, 1, 2
const voteReason = ref('');
const isSubmitting = ref(false);
const isPreviewVisible = ref(false);
const previewImageUrl = ref('');

let timer = null;

// --- Computed Properties ---
const totalVotes = computed(() => buyerVotes.value + sellerVotes.value);
const buyerVotePercentage = computed(() => {
  if (totalVotes.value === 0) return 50;
  return Math.round((buyerVotes.value / totalVotes.value) * 100);
});
const sellerVotePercentage = computed(() => 100 - buyerVotePercentage.value);

// --- Methods ---
const formatStatus = (status) => {
  return status === 0 ? '仲裁中' : '已结束';
};

const getStatusClass = (status) => {
  return status === 0 ? 'status-ongoing' : 'status-finished';
};

const updateCountdown = () => {
  const now = new Date();
  const deadline = new Date(caseData.deadline);
  const diff = deadline - now;

  if (diff <= 0) {
    timeLeft.value = '00:00:00';
    caseData.status = 1; // 模拟截止
    if(!caseData.result) {
      caseData.result = buyerVotes.value > sellerVotes.value ? 1 : 2;
    }
    clearInterval(timer);
    return;
  }

  const hours = Math.floor(diff / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  timeLeft.value = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

const handleVote = (option) => {
  if (userVote.value !== null) return;
  userVote.value = option;

  // 模拟投票后票数增加的即时反馈
  if (option === 1) {
    buyerVotes.value++;
  } else {
    sellerVotes.value++;
  }

  // TODO: 在这里调用API，将投票信息发送到后端
  // await api.submitVote({ judgment_id: caseData.judgment_id, vote_option: option });
  console.log(`User voted for: ${option === 1 ? 'Buyer' : 'Seller'}`);
};

const submitVote = async () => {
  if(!voteReason.value.trim()) {
    alert("请输入您的投票理由。"); // 实际项目中建议替换为更友好的提示组件
    return;
  }
  isSubmitting.value = true;
  console.log(`Submitting reason for vote ${userVote.value}: ${voteReason.value}`);

  // 模拟API调用
  await new Promise(resolve => setTimeout(resolve, 1000));

  // TODO: 调用API，提交投票理由
  // await api.submitVoteReason({ judgment_id: caseData.judgment_id, reason: voteReason.value });

  alert("理由提交成功！"); // 实际项目中建议替换为更友好的提示组件
  isSubmitting.value = false;
};

const showImagePreview = (url) => {
  previewImageUrl.value = url;
  isPreviewVisible.value = true;
};

const closeImagePreview = () => {
  isPreviewVisible.value = false;
  previewImageUrl.value = '';
};

// --- Lifecycle Hooks ---
onMounted(() => {
  updateCountdown();
  timer = setInterval(updateCountdown, 1000);
});

onUnmounted(() => {
  clearInterval(timer);
});
</script>

<style>
/* * ===================================================================
 * Campus Court Case Component Styles
 * -------------------------------------------------------------------
 * 使用 'court-case-' 或 'court-' 前缀确保样式隔离，避免全局冲突
 * 样式灵感来源于 MessageManagement.vue，但为本组件定制
 * ===================================================================
 */

/* --- 1. 基础与变量定义 (模仿 MessageManagement) --- */
:root {
  --court-font-family-base: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
  --court-bg-primary: #ffffff;
  --court-bg-secondary: #f8f9fa;
  --court-bg-hover: #f1f3f5;
  --court-border-color: #e9ecef;
  --court-text-primary: #212529;
  --court-text-secondary: #6c757d;
  --court-accent-color: #007bff;
  --court-accent-color-hover: #0056b3;
  --court-success-color: #28a745;
  --court-danger-color: #dc3545;
  --court-warning-color: #ffc107;
  --court-shadow-color: rgba(0, 0, 0, 0.05);
  --court-border-radius-sm: 0.25rem;
  --court-border-radius-md: 0.5rem;
}

.court-case-page-container {
  font-family: var(--court-font-family-base);
  background-color: var(--court-bg-secondary);
  padding: 24px;
}

.court-case-card {
  background: var(--court-bg-primary);
  border: 1px solid var(--court-border-color);
  border-radius: var(--court-border-radius-md);
  box-shadow: 0 4px 20px var(--court-shadow-color);
  transition: all 0.3s ease;
  max-width: 1000px;
  margin: 0 auto;
}
.court-case-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 32px var(--court-shadow-color);
}

/* --- 2. 案件头部 --- */
.court-case-header {
  padding: 24px 32px;
  border-bottom: 1px solid var(--court-border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}
.court-case-title-section {
  display: flex;
  align-items: center;
  gap: 16px;
}
.court-case-title-icon {
  color: var(--court-accent-color);
  font-size: 28px;
}
.court-case-title {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
  color: var(--court-text-primary);
}
.court-case-status-badge {
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 500;
  color: #fff;
}
.status-ongoing { background-color: var(--court-success-color); }
.status-finished { background-color: var(--court-text-secondary); }

.court-case-countdown {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--court-text-secondary);
  background: var(--court-bg-secondary);
  padding: 8px 16px;
  border-radius: var(--court-border-radius-md);
}
.court-case-countdown strong {
  color: var(--court-danger-color);
  font-weight: 600;
}

/* --- 3. 案件主体 (双方陈述) --- */
.court-case-body {
  padding: 32px;
}
.court-case-parties {
  display: flex;
  gap: 32px;
  align-items: stretch;
}
.court-party-panel {
  flex: 1;
  background: var(--court-bg-secondary);
  border: 1px solid var(--court-border-color);
  border-radius: var(--court-border-radius-md);
  padding: 24px;
}
.court-party-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--court-border-color);
}
.court-party-header i {
  font-size: 20px;
  color: var(--court-accent-color);
}
.court-party-header h2 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  color: var(--court-text-primary);
}
.court-party-statement {
  font-size: 14px;
  line-height: 1.6;
  color: var(--court-text-secondary);
  min-height: 80px;
}
.court-evidence-title {
  font-size: 14px;
  font-weight: 500;
  margin-top: 24px;
  margin-bottom: 12px;
  color: var(--court-text-primary);
}
.court-evidence-gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}
.court-evidence-thumbnail {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: var(--court-border-radius-sm);
  border: 1px solid var(--court-border-color);
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.court-evidence-thumbnail:hover {
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.court-case-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  color: var(--court-accent-color);
}

/* --- 4. 底部投票区 --- */
.court-case-footer {
  padding: 24px 32px;
  background: var(--court-bg-secondary);
  border-top: 1px solid var(--court-border-color);
  border-radius: 0 0 var(--court-border-radius-md) var(--court-border-radius-md);
  text-align: center;
}
.court-footer-title {
  font-size: 18px;
  font-weight: 600;
  margin-top: 0;
  margin-bottom: 24px;
  color: var(--court-text-primary);
}
.court-vote-progress-bar {
  display: flex;
  height: 24px;
  border-radius: 12px;
  overflow: hidden;
  background: var(--court-border-color);
  margin-bottom: 8px;
}
.court-vote-progress-buyer {
  background-color: var(--court-success-color);
  transition: width 0.5s ease;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}
.court-vote-progress-seller {
  background-color: var(--court-danger-color);
  transition: width 0.5s ease;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}
.court-vote-labels {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--court-text-secondary);
  padding: 0 8px;
  margin-bottom: 24px;
}
.court-vote-actions {
  margin-top: 24px;
}
.court-vote-prompt {
  margin-bottom: 16px;
  color: var(--court-text-secondary);
  font-size: 14px;
}
.court-vote-buttons {
  display: flex;
  justify-content: center;
  gap: 24px;
}
.court-case-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 24px;
  border: 1px solid transparent;
  border-radius: var(--court-border-radius-sm);
  font-weight: 500;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  min-width: 150px;
}
.court-btn-buyer {
  background-color: var(--court-success-color);
  color: white;
}
.court-btn-buyer:hover:not(.disabled) {
  background-color: #218838;
}
.court-btn-seller {
  background-color: var(--court-danger-color);
  color: white;
}
.court-btn-seller:hover:not(.disabled) {
  background-color: #c82333;
}
.court-case-btn.selected {
  transform: scale(1.05);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.3);
}
.court-case-btn.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.court-vote-reason {
  margin-top: 24px;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: center;
}
.court-reason-textarea {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid var(--court-border-color);
  border-radius: var(--court-border-radius-sm);
  font-size: 14px;
  background: var(--court-bg-primary);
  color: var(--court-text-primary);
  min-height: 80px;
  resize: vertical;
}
.court-btn-submit {
  background-color: var(--court-accent-color);
  color: white;
  width: 120px;
}
.court-btn-submit:hover:not(:disabled) {
  background-color: var(--court-accent-color-hover);
}
.court-vote-closed {
  margin-top: 24px;
  padding: 16px;
  background-color: var(--court-bg-hover);
  border-radius: var(--court-border-radius-sm);
  color: var(--court-text-secondary);
}

/* --- 5. 图片预览模态框 --- */
.court-image-preview-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  backdrop-filter: blur(5px);
}
.court-image-preview-container {
  position: relative;
  max-width: 80vw;
  max-height: 80vh;
}
.court-image-preview-content {
  max-width: 100%;
  max-height: 100%;
  border-radius: var(--court-border-radius-md);
}
.court-modal-close-btn {
  position: absolute;
  top: -15px;
  right: -15px;
  width: 30px;
  height: 30px;
  background: white;
  border: none;
  border-radius: 50%;
  font-size: 20px;
  line-height: 30px;
  text-align: center;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
}
.court-modal-fade-enter-active, .court-modal-fade-leave-active {
  transition: opacity 0.3s ease;
}
.court-modal-fade-enter-from, .court-modal-fade-leave-to {
  opacity: 0;
}

/* --- 6. 通用工具类 --- */
.court-spinner-sm {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: court-spin 1s linear infinite;
}
@keyframes court-spin {
  to { transform: rotate(360deg); }
}

/* --- 7. 响应式设计 --- */
@media (max-width: 768px) {
  .court-case-header {
    flex-direction: column;
    align-items: flex-start;
  }
  .court-case-parties {
    flex-direction: column;
  }
  .court-case-divider {
    margin: 16px 0;
  }
}
</style>
