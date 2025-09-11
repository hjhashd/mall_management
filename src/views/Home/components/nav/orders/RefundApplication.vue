<template>
  <div>
    <HomeNavbar />

    <main class="order-module__page-container">
      <div class="container">
        <h2 class="mb-4 fw-bold" style="color: var(--order-text-color);">
          <i class="fas fa-undo-alt me-2" style="color: var(--order-primary-color);"></i>申请售后
        </h2>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border" style="color: var(--order-primary-color);" role="status">
            <span class="visually-hidden">加载中...</span>
          </div>
          <p class="mt-3" style="color: var(--order-text-muted-color);">正在加载商品信息...</p>
        </div>

        <div v-else-if="orderItem" class="order-module__card">
          <!-- 商品信息头部 -->
          <div class="refund-product-header">
            <img :src="orderItem.productImage || defaultImage" class="product-image" :alt="orderItem.productName">
            <div class="product-details">
              <h6 class="mb-1">{{ orderItem.productName }}</h6>
              <p class="text-muted small mb-0">单价: ¥{{ orderItem.unitPrice.toFixed(2) }} | 数量: {{ orderItem.quantity }}</p>
              <p class="fw-bold mb-0" style="color: #d9534f;">小计: ¥{{ orderItem.totalPrice.toFixed(2) }}</p>
            </div>
          </div>

          <hr class="my-4">

          <form @submit.prevent="handleSubmit">
            <!-- ... 其他表单部分保持不变 ... -->
            <div class="mb-4">
              <label class="form-label fw-bold">售后类型</label>
              <div class="d-flex gap-3">
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="type_refund_only" value="3" v-model="form.type">
                  <label class="form-check-label" for="type_refund_only">仅退款</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="type_return_refund" value="1" v-model="form.type">
                  <label class="form-check-label" for="type_return_refund">退货退款</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="type_exchange" value="2" v-model="form.type">
                  <label class="form-check-label" for="type_exchange">换货</label>
                </div>
              </div>
            </div>
            <div class="mb-4" v-if="form.type === '1' || form.type === '3'">
              <label for="refundAmount" class="form-label fw-bold">退款金额</label>
              <div class="input-group">
                <span class="input-group-text">¥</span>
                <input type="number" class="form-control" id="refundAmount" v-model.number="form.refundAmount"
                       :max="orderItem.totalPrice" min="0.01" step="0.01" required>
              </div>
              <div class="form-text mt-2">最多可退 ¥{{ orderItem.totalPrice.toFixed(2) }}</div>
            </div>
            <div class="mb-4">
              <label for="reason" class="form-label fw-bold">申请原因</label>
              <textarea class="form-control" id="reason" rows="4" v-model.trim="form.reason"
                        placeholder="请详细描述您遇到的问题..." required></textarea>
            </div>

            <!-- 上传凭证 -->
            <div class="mb-4">
              <label for="evidence" class="form-label fw-bold">上传凭证 <span class="text-muted small">(最多5张)</span></label>
              <input type="file" ref="fileInput" class="form-control" id="evidence" @change="handleFileChange" multiple accept="image/*">

              <!-- !! 修改点：应用从 AfterSaleManagement.vue 复刻过来的样式 !! -->
              <div class="evidence-gallery mt-3" v-if="previews.length > 0">
                <div
                    v-for="(src, index) in previews"
                    :key="index"
                    class="evidence-thumbnail-wrapper"
                >
                  <img
                      :src="src"
                      alt="图片凭证预览"
                      class="evidence-thumbnail"
                      @click="showImage(src)"
                  >
                  <button type="button" class="btn-remove" @click.stop="removeImage(index)">
                    &times;
                  </button>
                </div>
              </div>
            </div>

            <div class="d-grid mt-5">
              <button type="submit" class="btn btn-submit-custom" :disabled="isSubmitting">
                <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-2"></span>
                {{ isSubmitting ? '提交中...' : '提交申请' }}
              </button>
            </div>
          </form>
        </div>

        <div v-else class="text-center text-muted py-5">
          <h4>无法加载商品信息</h4>
          <p>请检查订单项是否存在或返回重试。</p>
        </div>
      </div>
    </main>

    <!-- 图片查看器 Modal -->
    <div class="image-viewer-overlay" :class="{ 'open': isImageViewerOpen }" @click="isImageViewerOpen = false">
      <div class="viewer-content-wrapper">
        <img :src="viewerImageUrl" class="image-viewer-content" alt="图片预览" @click.stop>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import { getOrderItemDetail, submitAfterSaleApplication } from '@/api/order';

const route = useRoute();
const router = useRouter();
const loading = ref(true);
const isSubmitting = ref(false);
const orderItem = ref(null);
const defaultImage = 'https://placehold.co/100x100/e9ecef/6c757d?text=Image';
const fileInput = ref(null);

// !! 新增：图片查看器相关的状态
const isImageViewerOpen = ref(false);
const viewerImageUrl = ref('');

const form = reactive({
  type: '1',
  reason: '',
  refundAmount: 0,
});

const filesToUpload = ref([]);
const previews = ref([]);

onMounted(async () => {
  const orderItemId = route.params.orderItemId;
  if (!orderItemId) {
    loading.value = false;
    return;
  }
  try {
    const res = await getOrderItemDetail(orderItemId);
    if (res.data.success) {
      orderItem.value = res.data.data;
      form.refundAmount = orderItem.value.totalPrice;
    } else {
      console.error(res.data.message);
    }
  } catch (error) {
    console.error("加载订单项失败:", error);
  } finally {
    loading.value = false;
  }
});

const handleFileChange = (event) => {
  const files = Array.from(event.target.files);
  if (files.length + filesToUpload.value.length > 5) {
    alert('最多只能上传5张图片');
    return;
  }
  filesToUpload.value.push(...files);
  files.forEach(file => {
    const reader = new FileReader();
    reader.onload = (e) => previews.value.push(e.target.result);
    reader.readAsDataURL(file);
  });
  event.target.value = '';
};

const removeImage = (index) => {
  filesToUpload.value.splice(index, 1);
  previews.value.splice(index, 1);
};

// !! 新增：点击图片预览的方法
const showImage = (url) => {
  viewerImageUrl.value = url;
  isImageViewerOpen.value = true;
};


const handleSubmit = async () => {
  isSubmitting.value = true;
  try {
    const formData = new FormData();
    formData.append('order_item_id', orderItem.value.itemId);
    formData.append('type', form.type);
    formData.append('reason', form.reason);

    if (form.type === '1' || form.type === '3') {
      formData.append('refund_amount', form.refundAmount);
    }

    if (filesToUpload.value.length > 0) {
      filesToUpload.value.forEach(file => {
        formData.append('evidence_images', file);
      });
    }

    const res = await submitAfterSaleApplication(formData);

    if (res.data.success) {
      alert('售后申请提交成功！');
      router.push('/orders');
    } else {
      alert('提交失败: ' + res.data.message);
    }
  } catch (error) {
    console.error("提交售后申请失败:", error);
    alert('提交过程中发生网络错误，请重试。');
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<style scoped>
/* 引入 Font Awesome 图标库 */
@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css');

/* --- 商品和表单基础样式 (保持不变) --- */
.refund-product-header { display: flex; align-items: center; gap: 1rem; }
.product-image { width: 80px; height: 80px; object-fit: cover; border-radius: 12px; border: 1px solid var(--order-border-color); }
.product-details h6 { font-weight: 600; color: var(--order-text-color); }
.form-label { color: var(--order-text-color); margin-bottom: 0.75rem; }
.form-control, .input-group-text { border-color: var(--order-border-color); border-radius: 8px; }
.form-control:focus { border-color: var(--order-primary-color); box-shadow: 0 0 0 3px var(--order-shadow-color); }
.form-check-input:checked { background-color: var(--order-primary-color); border-color: var(--order-primary-color); }

/* --- !! 核心修改：从 AfterSaleManagement.vue 复刻并优化的图片预览样式 !! --- */
.evidence-gallery {
  display: flex;
  gap: 0.75rem; /* 图片间距 */
  flex-wrap: wrap;
}

.evidence-thumbnail-wrapper {
  position: relative; /* 为删除按钮定位 */
}

.evidence-thumbnail {
  width: 80px; /* 统一尺寸 */
  height: 80px;
  border-radius: 8px; /* 圆角 */
  object-fit: cover;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  border: 1px solid var(--order-border-color);
}

.evidence-thumbnail:hover {
  transform: scale(1.08); /* 悬浮放大效果 */
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.btn-remove {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 20px;
  height: 20px;
  background-color: #dc3545; /* 红色背景 */
  color: white;
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  line-height: 20px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  opacity: 0; /* 默认隐藏 */
  transform: scale(0.8);
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.evidence-thumbnail-wrapper:hover .btn-remove {
  opacity: 1; /* 悬浮在包装器上时显示按钮 */
  transform: scale(1);
}

/* --- 图片查看器 Modal 样式 --- */
.image-viewer-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1200;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s ease, visibility 0.3s ease;
  backdrop-filter: blur(5px);
}
.image-viewer-overlay.open {
  opacity: 1;
  visibility: visible;
}
.viewer-content-wrapper {
  position: relative;
  animation: zoomIn 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}
.image-viewer-content {
  max-width: 90vw;
  max-height: 85vh;
  object-fit: contain;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.4);
}
@keyframes zoomIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

/* --- 提交按钮样式 (保持不变) --- */
.btn-submit-custom {
  background: var(--order-primary-color);
  color: white;
  font-weight: 600;
  padding: 0.8rem 1.5rem;
  border-radius: 50px;
  border: none;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px -2px rgba(92, 158, 83, 0.4);
}
.btn-submit-custom:hover:not(:disabled) {
  background: #4a8c40;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px -2px rgba(92, 158, 83, 0.6);
}
.btn-submit-custom:disabled {
  background-color: #a5d6a7;
  cursor: not-allowed;
}
</style>
