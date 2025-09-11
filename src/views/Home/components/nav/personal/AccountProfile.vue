<template>
  <div class="section">
    <h5>账户设置</h5>

    <!-- 消息提示 -->
    <div class="alert alert-success" role="alert" v-if="showSuccessAlert">个人信息已更新</div>
    <div class="alert alert-danger" role="alert" v-if="showErrorAlert">两次密码输入不一致</div>

    <div class="card-grid">
      <!-- 头像卡片 -->
      <div class="card">
        <div class="card-body">
          <form @submit.prevent="updateAvatar">
            <div class="avatar-container">
              <img v-if="userInfo?.avatarPath" :src="userInfo.avatarPath" alt="用户头像" class="avatar-image" />
              <span v-else>{{ userInfo.username.slice(0, 1) }}</span>
              <div class="avatar-overlay">
                <i class="bi bi-camera text-white"></i>
              </div>
              <input type="file" accept="image/*" class="position-absolute top-0 start-0 w-100 h-100 opacity-0 cursor-pointer" @change="handleAvatarChange" />
            </div>
            <button type="submit" class="btn-update"><i class="bi bi-upload me-1"></i> 更新头像</button>
          </form>
          <h4 class="username">{{ userInfo.username }}</h4>
          <p class="role">{{ userInfo.userRole }}</p>
          <button class="btn-export" @click="exportUserData"><i class="bi bi-download me-2"></i> 导出个人数据</button>
        </div>
      </div>
      <!-- 账户安全卡片 -->
      <div class="card">
        <div class="card-body">
          <h6 class="card-title">
            <i class="bi bi-shield-lock me-2"></i>
            账户安全
          </h6>
          <div class="security-item">
            <div>
              <label>密码强度</label>
              <div class="text-success">{{ userInfo.passwordLevel }}</div>
            </div>
            <div class="status-icon success">
              <i class="bi bi-check-lg"></i>
            </div>
          </div>
          <div class="security-item">
            <div>
              <label>双重认证</label>
              <div class="text-muted">未启用</div>
            </div>
            <div class="toggle-switch">
              <input type="checkbox" v-model="twoFactorAuth" />
              <span class="slider"></span>
            </div>
          </div>
          <div class="security-item">
            <div>
              <label>登录设备</label>
              <div>{{ securityInfo.devices }}台设备</div>
            </div>
            <button class="btn-manage" @click="manageDevices">管理</button>
          </div>
          <div class="security-item">
            <div>
              <label>最近登录</label>
              <div>{{ userInfo.lastLogin }}</div>
            </div>
            <i class="bi bi-info-circle"></i>
          </div>
          <div class="warning-box">
            <h6 class="d-flex align-items-center mb-2">
              <i class="bi bi-exclamation-triangle me-2"></i>
              安全提示
            </h6>
            <p class="mb-0">您的账户已安全使用728天，请定期更新密码以保障账户安全。</p>
          </div>
        </div>
      </div>

      <!-- 密码设置卡片 -->
      <div class="card">
        <div class="card-body">
          <h6 class="card-title">
            <i class="bi bi-lock me-2"></i>
            密码设置
          </h6>
          <form @submit.prevent="updatePassword">
            <div class="form-group">
              <label>当前密码</label>
              <div class="password-input">
                <input :type="currentPasswordVisible ? 'text' : 'password'" v-model="currentPassword" placeholder="输入当前密码" />
                <button type="button" class="toggle-password" @click="toggleCurrentPasswordVisibility">
                  <i :class="currentPasswordVisible ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
                </button>
              </div>
            </div>

            <div class="form-group">
              <label>新密码</label>
              <div class="password-input">
                <input :type="newPasswordVisible ? 'text' : 'password'" v-model="newPassword" placeholder="输入新密码" />
                <button type="button" class="toggle-password" @click="toggleNewPasswordVisibility">
                  <i :class="newPasswordVisible ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
                </button>
              </div>
              <div class="form-text">密码至少8个字符，包含字母和数字</div>
            </div>

            <div class="form-group">
              <label>确认新密码</label>
              <div class="password-input">
                <input :type="confirmPasswordVisible ? 'text' : 'password'" v-model="confirmPassword" placeholder="再次输入新密码" />
                <button type="button" class="toggle-password" @click="toggleConfirmPasswordVisibility">
                  <i :class="confirmPasswordVisible ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
                </button>
              </div>
            </div>

            <div class="text-right">
              <button type="submit" class="btn-save">更新密码</button>
            </div>
          </form>
        </div>
      </div>

      <!-- 高级设置卡片 -->
      <div class="card">
        <div class="card-body">
          <h6 class="card-title">
            <i class="bi bi-sliders me-2"></i>
            高级设置
          </h6>

          <div class="setting-group">
            <h6 class="setting-title">
              <i class="bi bi-envelope me-2"></i>
              邮件通知设置
            </h6>
            <div class="setting-options">
              <div class="option">
                <input type="checkbox" v-model="notificationSettings.system" />
                <label>系统通知</label>
              </div>
              <div class="option">
                <input type="checkbox" v-model="notificationSettings.security" />
                <label>安全警报</label>
              </div>
              <div class="option">
                <input type="checkbox" v-model="notificationSettings.promotion" />
                <label>产品推广</label>
              </div>
            </div>
          </div>

          <div class="setting-group">
            <h6 class="setting-title">
              <i class="bi bi-trash me-2"></i>
              账户删除
            </h6>
            <p class="warning-text">删除您的账户将永久移除所有个人数据，此操作不可撤销。</p>
            <button class="btn-delete" @click="openDeleteModal">
              <i class="bi bi-trash me-1"></i>
              删除我的账户
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 删除账户确认模态框 -->
    <div class="modal" id="deleteModal" tabindex="-1" aria-hidden="true" v-if="showDeleteModal">
      <div class="modal-overlay" @click.self="closeDeleteModal"></div>
      <div class="modal-content">
        <div class="modal-header">
          <h5>确认删除账户</h5>
          <button type="button" class="close" @click="closeDeleteModal">&times;</button>
        </div>
        <div class="modal-body">
          <p>您确定要永久删除您的账户吗？此操作不可撤销，所有个人数据将被永久移除。</p>
          <p class="warning-text">警告：删除账户后将无法恢复任何数据。</p>
          <div class="confirmation">
            <input type="checkbox" v-model="confirmDelete" />
            <label> 我理解此操作的后果，并确认删除我的账户 </label>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-cancel" @click="closeDeleteModal">取消</button>
          <button type="button" class="btn-confirm-delete" @click="deleteAccount" :disabled="!confirmDelete">永久删除账户</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getUserAccountInfo, updateUserAvatar } from '@/api/user'

export default {
  name: 'AccountProfile',
  data() {
    return {
      // 状态提示
      showSuccessAlert: false,
      showErrorAlert: false,
      showDeleteModal: false,

      // 用户信息
      userInfo: {
        username: '管理员',
        userRole: '超级管理员'
      },
      avatarFile: null,
      // 安全信息
      twoFactorAuth: false,
      securityInfo: {
        devices: 3,
        lastLogin: '今天 09:24, 来自北京'
      },

      // 密码设置
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      currentPasswordVisible: false,
      newPasswordVisible: false,
      confirmPasswordVisible: false,

      // 通知设置
      notificationSettings: {
        system: true,
        security: true,
        promotion: false
      },

      // 账户删除
      confirmDelete: false
    }
  },
  mounted() {
    this.getUserAccountInfoFn()
  },
  methods: {
    // 获取用户基础设置
    async getUserAccountInfoFn() {
      const res = await getUserAccountInfo()
      this.userInfo = res.data.data
      if (this.userInfo.username === 'admin') this.userInfo.userRole = '超级管理员'
    },
    // 头像处理
    handleAvatarChange(e) {
      const file = e.target.files[0]
      if (file) {
        this.avatarFile = file // 存储要提交的文件
        console.log(file)

        const reader = new FileReader()
        reader.onload = event => {
          this.userInfo.avatarPath = event.target.result // 预览图像
        }
        reader.readAsDataURL(file)
      }
    },
    async updateAvatar() {
      if (!this.avatarFile) {
        this.showErrorAlert = true
        setTimeout(() => {
          this.showErrorAlert = false
        }, 3000)
        return
      }

      try {
        const formData = new FormData()
        formData.append('avatar', this.avatarFile)
        const res = await updateUserAvatar(formData)
        if (res.data.success) {
          this.userInfo.avatarPath = res.data.data.avatarPath // 使用来自服务器的新角色路径进行更新
          this.showSuccessAlert = true
          setTimeout(() => {
            this.showSuccessAlert = false
          }, 3000)
        } else {
          this.showErrorAlert = true
          setTimeout(() => {
            this.showErrorAlert = false
          }, 3000)
        }
      } catch (error) {
        this.showErrorAlert = true
        setTimeout(() => {
          this.showErrorAlert = false
        }, 3000)
      }
    },
    // 导出用户数据
    exportUserData() {
      alert('正在导出个人数据...')
    },

    // 安全相关
    manageDevices() {
      alert('管理登录设备')
    },

    // 密码显示切换
    toggleCurrentPasswordVisibility() {
      this.currentPasswordVisible = !this.currentPasswordVisible
    },
    toggleNewPasswordVisibility() {
      this.newPasswordVisible = !this.newPasswordVisible
    },
    toggleConfirmPasswordVisibility() {
      this.confirmPasswordVisible = !this.confirmPasswordVisible
    },

    // 更新密码
    updatePassword() {
      if (this.newPassword !== this.confirmPassword) {
        this.showErrorAlert = true
        setTimeout(() => {
          this.showErrorAlert = false
        }, 3000)
        return
      }

      // 模拟密码更新成功
      this.currentPassword = ''
      this.newPassword = ''
      this.confirmPassword = ''
      this.showSuccessAlert = true
      setTimeout(() => {
        this.showSuccessAlert = false
      }, 3000)
    },

    // 账户删除
    openDeleteModal() {
      this.confirmDelete = false
      this.showDeleteModal = true
    },
    closeDeleteModal() {
      this.showDeleteModal = false
    },
    deleteAccount() {
      alert('账户已永久删除')
      this.closeDeleteModal()
    }
  }
}
</script>

<style scoped>
.section h5 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 8px;
  margin-bottom: 16px;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.card {
  border: 1px solid var(--border-color);
  border-radius: 12px;
  background: #fbfffb;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.card-body {
  padding: 20px;
}

.card-title {
  display: flex;
  align-items: center;
  color: #3b4a30;
  font-weight: 600;
  margin-bottom: 16px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border-color);
}

.card-title i {
  font-size: 1.2rem;
  margin-right: 8px;
}

/* 头像区域 */
.avatar-container {
  position: relative;
  width: 100px;
  height: 100px;
  margin: 0 auto 15px;
  border-radius: 50%;
  background-color: #e9f5e9;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  color: #5c9e53;
  overflow: hidden;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.avatar-container:hover .avatar-overlay {
  opacity: 1;
}

.username {
  text-align: center;
  font-size: 1.25rem;
  color: #3b4a30;
  margin: 10px 0 5px;
}

.role {
  text-align: center;
  color: #6b7a63;
  font-size: 0.9rem;
  margin-bottom: 15px;
}

/* 按钮样式 */
.btn-update,
.btn-export,
.btn-save,
.btn-delete {
  display: block;
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
  text-align: center;
  margin: 10px 0;
}

.btn-update {
  background-color: var(--primary-color);
  color: white;
}

.btn-update:hover {
  background-color: #4d8a45;
}

.btn-export {
  background-color: #e9f5e9;
  color: #5c9e53;
  border: 1px solid var(--border-color);
}

.btn-export:hover {
  background-color: #d7e3d7;
}

.btn-save {
  background-color: var(--primary-color);
  color: white;
  padding: 8px 15px;
  width: auto;
  margin-left: auto;
}

.btn-save:hover {
  background-color: #4d8a45;
}

.btn-delete {
  background-color: #fff8f8;
  color: #e74c3c;
  border: 1px solid #ffd1d1;
  margin-top: 15px;
}

.btn-delete:hover {
  background-color: #ffecec;
}

/* 安全项目 */
.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid var(--border-color);
}

.security-item:last-child {
  border-bottom: none;
}

.security-item label {
  color: #6b7a63;
  font-size: 0.9rem;
}

.security-item div:first-child div {
  color: #3b4a30;
  font-weight: 500;
  margin-top: 3px;
}

.status-icon {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.status-icon.success {
  background-color: #e6f4ea;
  color: #198754;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 45px;
  height: 24px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: 0.4s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: '';
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--primary-color);
}

input:checked + .slider:before {
  transform: translateX(21px);
}

.btn-manage {
  background: none;
  border: none;
  color: var(--primary-color);
  cursor: pointer;
  font-size: 0.9rem;
  padding: 5px;
}

.btn-manage:hover {
  text-decoration: underline;
}

/* 警告框 */
.warning-box {
  background-color: #fff8f8;
  border-left: 4px solid #e74c3c;
  border-radius: 0 4px 4px 0;
  padding: 12px;
  margin-top: 16px;
}

.warning-box h6 {
  color: #e74c3c;
  font-weight: 600;
}

.warning-box p {
  color: #e74c3c;
  font-size: 0.9rem;
  margin-bottom: 0;
}

/* 表单组 */
.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  color: #6b7a63;
  font-size: 0.9rem;
}

.password-input {
  position: relative;
}

.password-input input {
  width: 100%;
  padding: 10px 40px 10px 12px;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  background: #fff;
}

.toggle-password {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #6b7a63;
  cursor: pointer;
}

.form-text {
  color: #6b7a63;
  font-size: 0.8rem;
  margin-top: 5px;
}

/* 设置组 */
.setting-group {
  margin-bottom: 20px;
}

.setting-title {
  display: flex;
  align-items: center;
  color: #3b4a30;
  font-weight: 600;
  margin-bottom: 12px;
}

.setting-title i {
  margin-right: 8px;
}

.setting-options {
  padding-left: 10px;
}

.option {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.option input {
  margin-right: 8px;
}

.option label {
  color: #3b4a30;
  font-size: 0.95rem;
}

.warning-text {
  color: #e74c3c;
  font-size: 0.9rem;
  margin-bottom: 15px;
}

/* 模态框 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-content {
  position: relative;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 500px;
  z-index: 10;
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h5 {
  margin: 0;
  color: #3b4a30;
}

.close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7a63;
}

.modal-body {
  padding: 20px;
}

.modal-body p {
  color: #3b4a30;
  margin-bottom: 10px;
}

.confirmation {
  display: flex;
  align-items: center;
  margin-top: 15px;
}

.confirmation input {
  margin-right: 10px;
}

.confirmation label {
  color: #3b4a30;
}

.modal-footer {
  padding: 15px 20px;
  border-top: 1px solid var(--border-color);
  display: flex;
  justify-content: flex-end;
}

.btn-cancel {
  background: #f0f0f0;
  color: #3b4a30;
  border: none;
  padding: 8px 15px;
  border-radius: 6px;
  margin-right: 10px;
  cursor: pointer;
}

.btn-cancel:hover {
  background: #e0e0e0;
}

.btn-confirm-delete {
  background: #e74c3c;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 6px;
  cursor: pointer;
}

.btn-confirm-delete:hover {
  background: #c0392b;
}

.btn-confirm-delete:disabled {
  background: #f5b7b1;
  cursor: not-allowed;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>
