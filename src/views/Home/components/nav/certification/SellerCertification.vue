<template>
  <div>
    <HomeNavbar />

    <main class="certification-container">
      <div class="container">
        <h2 class="mb-4 fw-bold text-success">
          <i class="fas fa-store me-2"></i>商家认证申请
        </h2>

        <!-- 认证状态显示 -->
        <div v-if="certificationStatus" class="status-section mb-4">
          <div class="alert" :class="getStatusAlertClass()">
            <h6 class="alert-heading">
              <i :class="getStatusIcon()"></i>
              {{ getStatusText() }}
            </h6>
            <p class="mb-0">{{ getStatusDescription() }}</p>
            <div v-if="certificationStatus.status === 2" class="mt-2">
              <strong>拒绝原因：</strong>{{ certificationStatus.rejectReason }}
            </div>
          </div>
        </div>

        <!-- 认证表单 -->
        <div v-if="!certificationStatus || certificationStatus.status === 2" class="row justify-content-center">
          <div class="col-lg-8">
            <div class="certification-section">
              <div class="certification-header">
                <h5><i class="fas fa-info-circle me-2"></i>认证说明</h5>
                <p class="text-muted">
                  成为认证商家后，您可以发布商品、管理订单，享受更多平台权益。
                  请确保提供的营业执照真实有效，我们将在3-5个工作日内完成审核。
                </p>
              </div>

              <form  @submit.prevent="handleSubmitCertification" class="certification-form">
                <!-- 营业执照上传 -->
                <div class="form-group mb-4">
                  <label class="form-label fw-bold">
                    <i class="fas fa-file-image me-2"></i>营业执照
                    <span class="text-danger">*</span>
                  </label>
                  <div class="upload-area"
                       :class="{ 'has-file': businessLicenseFile, 'is-dragover': isDragOver }"
                       @drop="handleDrop"
                       @dragover.prevent="isDragOver = true"
                       @dragleave.prevent="isDragOver = false"
                       @click="triggerFileInput">
                    <div v-if="!businessLicenseFile" class="upload-placeholder">
                      <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                      <p class="mb-2">点击或拖拽上传营业执照</p>
                      <p class="text-muted small">支持 JPG、PNG、PDF 格式，文件大小不超过 5MB</p>
                    </div>
                    <div v-else class="file-preview">
                      <img v-if="isImageFile" :src="previewUrl" alt="营业执照预览" class="preview-image">
                      <div v-else class="file-info">
                        <i class="fas fa-file-pdf fa-2x text-danger"></i>
                        <p class="mb-0">{{ businessLicenseFile.name }}</p>
                      </div>
                      <button type="button" class="btn-remove" @click="removeFile">
                        <i class="fas fa-times"></i>
                      </button>
                    </div>
                  </div>
                  <input
                    ref="fileInput"
                    type="file"
                    accept=".jpg,.jpeg,.png,.pdf"
                    @change="handleFileSelect"
                    class="d-none">
                  <div v-if="fileError" class="text-danger small mt-2">
                    <i class="fas fa-exclamation-circle me-1"></i>{{ fileError }}
                  </div>
                </div>

                <!-- 商家信息 -->
                <div class="form-group mb-4">
                  <label class="form-label fw-bold">
                    <i class="fas fa-user me-2"></i>商家信息
                  </label>
                  <div class="row">
                    <div class="col-md-6">
                      <input
                        type="text"
                        v-model="businessName"
                        class="form-control"
                        placeholder="商家名称"
                        required>
                    </div>
                    <div class="col-md-6">
                      <input
                        type="text"
                        v-model="businessType"
                        class="form-control"
                        placeholder="经营类型（如：图书、数码、服装等）"
                        required>
                    </div>
                  </div>
                </div>

                <!-- 联系方式 -->
                <div class="form-group mb-4">
                  <label class="form-label fw-bold">
                    <i class="fas fa-phone me-2"></i>联系方式
                  </label>
                  <div class="row">
                    <div class="col-md-6">
                      <input
                        type="tel"
                        v-model="contactPhone"
                        class="form-control"
                        placeholder="联系电话"
                        required>
                    </div>
                    <div class="col-md-6">
                      <input
                        type="email"
                        v-model="contactEmail"
                        class="form-control"
                        placeholder="联系邮箱"
                        required>
                    </div>
                  </div>
                </div>

                <!-- 经营地址 -->
                <div class="form-group mb-4">
                  <label class="form-label fw-bold">
                    <i class="fas fa-map-marker-alt me-2"></i>经营地址
                  </label>
                  <textarea
                    v-model="businessAddress"
                    class="form-control"
                    rows="3"
                    placeholder="请填写详细的经营地址"
                    required></textarea>
                </div>

                <!-- 经营描述 -->
                <div class="form-group mb-4">
                  <label class="form-label fw-bold">
                    <i class="fas fa-edit me-2"></i>经营描述
                  </label>
                  <textarea
                    v-model="businessDescription"
                    class="form-control"
                    rows="4"
                    placeholder="请简要描述您的经营范围、特色商品等（选填）"></textarea>
                </div>

                <!-- 协议同意 -->
                <div class="form-group mb-4">
                  <div class="form-check">
                    <input
                      type="checkbox"
                      v-model="agreeToTerms"
                      class="form-check-input"
                      id="agreeTerms"
                      required>
                    <label class="form-check-label" for="agreeTerms">
                      我已阅读并同意
                      <a href="#" class="text-success">《商家入驻协议》</a>
                      和
                      <a href="#" class="text-success">《平台规则》</a>
                    </label>
                  </div>
                </div>

                <!-- 提交按钮 -->
                <div class="form-actions">
                  <button
                    type="submit"
                    class="btn btn-success btn-lg w-100"
                    :disabled="isSubmitting">
                    <i class="fas fa-paper-plane me-2"></i>
                    {{ isSubmitting ? '提交中...' : '提交认证申请' }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- 认证成功后的引导 -->
        <div v-if="certificationStatus && certificationStatus.status === 1" class="row justify-content-center">
          <div class="col-lg-8">
            <div class="success-section">
              <div class="text-center">
                <i class="fas fa-check-circle fa-5x text-success mb-4"></i>
                <h3 class="text-success mb-3">恭喜！认证成功</h3>
                <p class="text-muted mb-4">您已成为认证商家，现在可以享受更多平台权益</p>

                <div class="row">
                  <div class="col-md-4 mb-3">
                    <div class="feature-card">
                      <i class="fas fa-box fa-2x text-primary mb-2"></i>
                      <h6>发布商品</h6>
                      <p class="small text-muted">可以发布和管理您的商品</p>
                    </div>
                  </div>
                  <div class="col-md-4 mb-3">
                    <div class="feature-card">
                      <i class="fas fa-shopping-cart fa-2x text-primary mb-2"></i>
                      <h6>管理订单</h6>
                      <p class="small text-muted">处理客户订单和发货</p>
                    </div>
                  </div>
                  <div class="col-md-4 mb-3">
                    <div class="feature-card">
                      <i class="fas fa-chart-line fa-2x text-primary mb-2"></i>
                      <h6>数据分析</h6>
                      <p class="small text-muted">查看销售数据和统计</p>
                    </div>
                  </div>
                </div>

                <div class="mt-4">
                  <router-link to="/seller" class="btn btn-outline-success me-3">
                    <i class="fas fa-user me-2"></i>进入卖家中心
                  </router-link>
                  <router-link to="/" class="btn btn-outline-success me-3">
                    <i class="fas fa-home me-2"></i>返回首页
                  </router-link>
                </div>
              </div>
            </div>
          </div>
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

    <!-- 加载遮罩 -->
    <div v-if="isLoading" class="loading-overlay">
      <div class="loading-content">
        <div class="spinner-border text-success" role="status">
          <span class="visually-hidden">加载中...</span>
        </div>
        <p class="mt-3 text-white">正在加载认证信息...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { submitCertification, getCertificationStatus } from '@/api/sellerCertification';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";

// 响应式数据
const businessLicenseFile = ref(null);
const businessName = ref('');
const businessType = ref('');
const contactPhone = ref('');
const contactEmail = ref('');
const businessAddress = ref('');
const businessDescription = ref('');
const agreeToTerms = ref(false);
const isSubmitting = ref(false);
const isDragOver = ref(false);
const fileError = ref('');
const previewUrl = ref('');
const isLoading = ref(false);
const certificationStatus = ref(null);

// 提示框状态
const showToast = ref(false);
const toastMessage = ref('');
const toastType = ref('success');

// 路由
const router = useRouter();

// 文件输入引用
const fileInput = ref(null);

// 计算属性
const isImageFile = computed(() => {
  if (!businessLicenseFile.value) return false;
  const fileName = businessLicenseFile.value.name.toLowerCase();
  return fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.png');
});

// 生命周期
onMounted(async () => {
  await loadCertificationStatus();
});

// 加载认证状态
const loadCertificationStatus = async () => {
  try {
    isLoading.value = true;
    const response = await getCertificationStatus();
    if (response.data.success) {
      certificationStatus.value = response.data.data;
    }
  } catch (error) {
    console.error('加载认证状态失败:', error);
  } finally {
    isLoading.value = false;
  }
};

// 获取状态样式类
const getStatusAlertClass = () => {
  if (!certificationStatus.value) return '';
  switch (certificationStatus.value.status) {
    case 0: return 'alert-warning';
    case 1: return 'alert-success';
    case 2: return 'alert-danger';
    default: return 'alert-info';
  }
};

// 获取状态图标
const getStatusIcon = () => {
  if (!certificationStatus.value) return '';
  switch (certificationStatus.value.status) {
    case 0: return 'fas fa-clock text-warning';
    case 1: return 'fas fa-check-circle text-success';
    case 2: return 'fas fa-times-circle text-danger';
    default: return 'fas fa-info-circle text-info';
  }
};

// 获取状态文本
const getStatusText = () => {
  if (!certificationStatus.value) return '';
  switch (certificationStatus.value.status) {
    case 0: return '审核中';
    case 1: return '认证成功';
    case 2: return '认证被拒绝';
    default: return '未知状态';
  }
};

// 获取状态描述
const getStatusDescription = () => {
  if (!certificationStatus.value) return '';
  switch (certificationStatus.value.status) {
    case 0: return '您的认证申请正在审核中，我们将在3-5个工作日内完成审核，请耐心等待。';
    case 1: return '恭喜！您已成为认证商家，现在可以享受更多平台权益。';
    case 2: return '很抱歉，您的认证申请未通过审核。请根据拒绝原因修改后重新提交。';
    default: return '请查看您的认证状态。';
  }
};

// 触发文件选择
const triggerFileInput = () => {
  fileInput.value.click();
};

// 处理文件选择
const handleFileSelect = (event) => {
  const file = event.target.files[0];
  if (file) {
    validateAndSetFile(file);
  }
};

// 处理拖拽
const handleDrop = (event) => {
  event.preventDefault();
  isDragOver.value = false;

  const files = event.dataTransfer.files;
  if (files.length > 0) {
    validateAndSetFile(files[0]);
  }
};

// 验证并设置文件
const validateAndSetFile = (file) => {
  fileError.value = '';

  // 检查文件类型
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
  if (!allowedTypes.includes(file.type)) {
    fileError.value = '只支持 JPG、PNG、PDF 格式的文件';
    return;
  }

  // 检查文件大小（5MB）
  if (file.size > 5 * 1024 * 1024) {
    fileError.value = '文件大小不能超过 5MB';
    return;
  }

  businessLicenseFile.value = file;

  // 如果是图片文件，创建预览
  if (isImageFile.value) {
    const reader = new FileReader();
    reader.onload = (e) => {
      previewUrl.value = e.target.result;
    };
    reader.readAsDataURL(file);
  }
};

// 移除文件
const removeFile = () => {
  businessLicenseFile.value = null;
  previewUrl.value = '';
  fileError.value = '';
  if (fileInput.value) {
    fileInput.value.value = '';
  }
};

// 显示提示信息
const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message;
  toastType.value = type;
  showToast.value = true;
  setTimeout(() => {
    showToast.value = false;
  }, 3000);
};

// 提交认证申请
const handleSubmitCertification = async () => {
  // 验证必填字段
  if (!businessLicenseFile.value) {
    showToastMessage('请上传营业执照', 'error');
    return;
  }

  if (!businessName.value || !businessType.value || !contactPhone.value ||
      !contactEmail.value || !businessAddress.value) {
    showToastMessage('请填写完整的必填信息', 'error');
    return;
  }

  if (!agreeToTerms.value) {
    showToastMessage('请同意相关协议', 'error');
    return;
  }

  isSubmitting.value = true;

  try {
    const formData = new FormData();
    formData.append('businessLicense', businessLicenseFile.value);
    formData.append('businessName', businessName.value);
    formData.append('businessType', businessType.value);
    formData.append('contactPhone', contactPhone.value);
    formData.append('contactEmail', contactEmail.value);
    formData.append('businessAddress', businessAddress.value);
    formData.append('businessDescription', businessDescription.value);

// 调用API
    const response = await submitCertification(formData);

    if (response.data.success) {
      showToastMessage('认证申请提交成功！我们将在3-5个工作日内完成审核。', 'success');

      // 重新加载认证状态
      await loadCertificationStatus();

      // 清空表单
      resetForm();

    } else {
      showToastMessage(response.data.message || '提交失败，请稍后重试', 'error');
    }

  } catch (error) {
    console.error('提交认证失败:', error);
    showToastMessage('提交失败，请稍后重试', 'error');
  } finally {
    isSubmitting.value = false;
  }
};

// 重置表单
const resetForm = () => {
  businessLicenseFile.value = null;
  businessName.value = '';
  businessType.value = '';
  contactPhone.value = '';
  contactEmail.value = '';
  businessAddress.value = '';
  businessDescription.value = '';
  agreeToTerms.value = false;
  previewUrl.value = '';
  fileError.value = '';
  if (fileInput.value) {
    fileInput.value.value = '';
  }
};
</script>

<style scoped>
:root {
  --primary-color: #5c9e53;
  --secondary-color: #f7faf5;
  --hover-color: #e6f0e6;
  --text-muted-color: #6b7a63;
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
}

.certification-container {
  background: var(--secondary-color);
  min-height: 70vh;
  padding: 3rem 0 2rem 0;
  padding-top: 70px;
}

.certification-section {
  background: #fff;
  border-radius: 16px;
  padding: 2rem;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
}

.certification-header {
  background: linear-gradient(135deg, #def4d3 0%, #c8e9b8 100%);
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  border-left: 4px solid var(--primary-color);
}

.certification-header h5 {
  color: #3b4a30;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.certification-header p {
  margin-bottom: 0;
  line-height: 1.6;
}

/* 状态显示区域 */
.status-section .alert {
  border-radius: 12px;
  border: none;
  padding: 1.5rem;
}

.status-section .alert-warning {
  background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
  color: #856404;
}

.status-section .alert-success {
  background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
  color: #155724;
}

.status-section .alert-danger {
  background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
  color: #721c24;
}

/* 成功区域 */
.success-section {
  background: #fff;
  border-radius: 16px;
  padding: 3rem 2rem;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
  text-align: center;
}

.feature-card {
  padding: 1.5rem;
  border-radius: 12px;
  background: #f8f9fa;
  border: 1px solid var(--border-color);
  transition: all 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(92, 158, 83, 0.15);
}

.form-label {
  color: #3b4a30;
  font-weight: 600;
  margin-bottom: 0.8rem;
}

.form-control {
  border: 2px solid var(--border-color);
  border-radius: 12px;
  padding: 0.8rem 1rem;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  background-color: #fafbfa;
}

.form-control:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 0.2rem rgba(92, 158, 83, 0.25);
  background-color: #fff;
}

.form-select {
  border: 2px solid var(--border-color);
  border-radius: 12px;
  padding: 0.8rem 1rem;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  background-color: #fafbfa;
}

.form-select:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 0.2rem rgba(92, 158, 83, 0.25);
  background-color: #fff;
}

/* 文件上传区域 */
.upload-area {
  border: 2px dashed var(--border-color);
  border-radius: 12px;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background-color: #fafbfa;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-area:hover {
  border-color: var(--primary-color);
  background-color: var(--hover-color);
}

.upload-area.has-file {
  border-color: var(--primary-color);
  background-color: var(--hover-color);
}

.upload-area.is-dragover {
  border-color: var(--primary-color);
  background-color: var(--hover-color);
  transform: scale(1.02);
}

.upload-placeholder {
  color: var(--text-muted-color);
}

.upload-placeholder i {
  color: #a1ad89;
}

.file-preview {
  position: relative;
  width: 100%;
  height: 100%;
}

.preview-image {
  max-width: 100%;
  max-height: 180px;
  border-radius: 8px;
  object-fit: contain;
}

.file-info {
  text-align: center;
  color: var(--text-muted-color);
}

.btn-remove {
  position: absolute;
  top: -10px;
  right: -10px;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #dc3545;
  color: white;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-remove:hover {
  background: #c82333;
  transform: scale(1.1);
}

/* 表单复选框 */
.form-check-input {
  width: 1.2em;
  height: 1.2em;
  border: 2px solid var(--border-color);
  border-radius: 6px;
}

.form-check-input:checked {
  background-color: var(--primary-color);
  border-color: var(--primary-color);
}

.form-check-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 0.2rem rgba(92, 158, 83, 0.25);
}

.form-check-label {
  color: var(--text-muted-color);
  line-height: 1.5;
}

.form-check-label a {
  text-decoration: none;
  font-weight: 600;
}

.form-check-label a:hover {
  text-decoration: underline;
}

/* 提交按钮 */
.form-actions {
  margin-top: 2rem;
}

.btn-success {
  background: linear-gradient(135deg, var(--primary-color) 0%, #46783a 100%);
  border: none;
  font-weight: 600;
  padding: 1rem 2rem;
  border-radius: 50px;
  box-shadow: 0 6px 14px rgba(92, 158, 83, 0.35);
  transition: all 0.3s ease;
}

.btn-success:hover:not(:disabled) {
  background: linear-gradient(135deg, #46783a 0%, #3a5f2f 100%);
  transform: translateY(-2px);
  box-shadow: 0 10px 25px rgba(70, 120, 58, 0.5);
}

.btn-success:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

/* 加载遮罩 */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.loading-content {
  text-align: center;
  color: white;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .certification-section {
    padding: 1.5rem;
  }

  .upload-area {
    padding: 1.5rem;
    min-height: 150px;
  }

  .certification-header {
    padding: 1rem;
  }

  .success-section {
    padding: 2rem 1rem;
  }
}
</style>
