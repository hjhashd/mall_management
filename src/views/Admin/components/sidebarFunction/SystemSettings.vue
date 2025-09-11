<template>
  <div class="settings-container">
    <!-- 通知容器 -->
    <div class="notification-container">
      <transition-group name="notification-fade">
        <div v-for="notification in notifications" :key="notification.id" :class="['notification', `notification-${notification.type}`]">
          <i :class="notification.icon" class="notification-icon"></i>
          <p>{{ notification.message }}</p>
        </div>
      </transition-group>
    </div>

    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <i class="fas fa-cog"></i>
          系统设置
        </h1>
        <p class="page-subtitle">管理系统的核心配置、安全策略和集成选项</p>
      </div>
    </div>

    <!-- 主体布局 -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>正在加载系统配置...</p>
    </div>
    <div v-else class="settings-layout">
      <!-- 左侧导航 -->
      <div class="settings-nav">
        <button
            v-for="tab in tabs"
            :key="tab.id"
            :class="['nav-item', { active: activeTab === tab.id }]"
            @click="activeTab = tab.id"
        >
          <i :class="tab.icon"></i>
          <span>{{ tab.name }}</span>
        </button>
      </div>

      <!-- 右侧内容区 -->
      <div class="settings-content">
        <transition name="fade-transform" mode="out-in">
          <div :key="activeTab">
            <!-- 通用设置 -->
            <div v-if="activeTab === 'general'" class="settings-card">
              <h2 class="card-title">通用设置</h2>
              <div class="form-group">
                <label for="siteName">网站名称</label>
                <input type="text" id="siteName" v-model="settings.general.siteName" placeholder="例如：酷猿商城">
                <p class="form-hint">将显示在浏览器标签页和系统邮件中。</p>
              </div>
              <div class="form-group">
                <label>网站 Logo</label>
                <div class="logo-uploader">
                  <img :src="settings.general.logoUrl || 'https://placehold.co/120x40/f0f0f0/333?text=Logo'" alt="Current Logo" class="logo-preview">
                  <button class="btn btn-outline btn-sm">上传新 Logo</button>
                </div>
              </div>
              <div class="form-group">
                <label for="copyright">版权信息</label>
                <input type="text" id="copyright" v-model="settings.general.copyright" placeholder="© 2025 Your Company. All Rights Reserved.">
              </div>
              <div class="form-group inline-group">
                <label for="maintenanceMode">维护模式</label>
                <div class="toggle-switch">
                  <input type="checkbox" id="maintenanceMode" v-model="settings.general.maintenanceMode">
                  <label for="maintenanceMode"></label>
                </div>
                <p class="form-hint">开启后，普通用户将无法访问网站前台。</p>
              </div>
            </div>

            <!-- 安全设置 -->
            <div v-if="activeTab === 'security'" class="settings-card">
              <h2 class="card-title">安全设置</h2>
              <div class="form-group">
                <label for="sessionTimeout">会话超时时长 (分钟)</label>
                <input type="number" id="sessionTimeout" v-model.number="settings.security.sessionTimeout" min="5">
                <p class="form-hint">用户无操作超过此时长后将自动登出。</p>
              </div>
              <div class="form-group">
                <label for="loginAttempts">最大登录尝试次数</label>
                <input type="number" id="loginAttempts" v-model.number="settings.security.loginAttempts" min="3">
                <p class="form-hint">超过此次数后，账户将被临时锁定。</p>
              </div>
              <div class="form-group inline-group">
                <label for="enable2FA">启用两步验证 (2FA)</label>
                <div class="toggle-switch">
                  <input type="checkbox" id="enable2FA" v-model="settings.security.enable2FA">
                  <label for="enable2FA"></label>
                </div>
                <p class="form-hint">强烈建议为管理员账户开启以增强安全性。</p>
              </div>
            </div>

            <!-- 通知设置 -->
            <div v-if="activeTab === 'notifications'" class="settings-card">
              <h2 class="card-title">通知设置</h2>
              <p class="card-description">配置系统如何发送邮件通知。请确保 SMTP 信息正确无误。</p>
              <div class="form-grid">
                <div class="form-group">
                  <label for="smtpHost">SMTP 主机</label>
                  <input type="text" id="smtpHost" v-model="settings.notifications.smtpHost" placeholder="smtp.example.com">
                </div>
                <div class="form-group">
                  <label for="smtpPort">端口</label>
                  <input type="number" id="smtpPort" v-model.number="settings.notifications.smtpPort" placeholder="465">
                </div>
                <div class="form-group">
                  <label for="smtpUser">用户名</label>
                  <input type="text" id="smtpUser" v-model="settings.notifications.smtpUser" placeholder="your_email@example.com">
                </div>
                <div class="form-group">
                  <label for="smtpPass">密码/授权码</label>
                  <input type="password" id="smtpPass" v-model="settings.notifications.smtpPass" placeholder="••••••••••••••••">
                </div>
              </div>
              <div class="form-group">
                <label for="adminEmail">接收通知的管理员邮箱</label>
                <input type="email" id="adminEmail" v-model="settings.notifications.adminEmail" placeholder="admin@example.com">
              </div>
              <button class="btn btn-outline" @click="sendTestEmail" :disabled="isSendingTestEmail">
                <i :class="isSendingTestEmail ? 'fas fa-spinner fa-spin' : 'fas fa-paper-plane'"></i>
                {{ isSendingTestEmail ? '发送中...' : '发送测试邮件' }}
              </button>
            </div>
            <!-- API 设置 -->
            <div v-if="activeTab === 'api'" class="settings-card">
              <h2 class="card-title">API 与集成</h2>
              <div class="form-group">
                <label for="paymentGatewayKey">支付网关 API Key</label>
                <input type="text" id="paymentGatewayKey" v-model="settings.api.paymentGatewayKey" placeholder="pk_live_...">
              </div>
              <div class="form-group">
                <label for="mapServiceKey">地图服务 API Key</label>
                <input type="text" id="mapServiceKey" v-model="settings.api.mapServiceKey" placeholder="AIzaSy...">
              </div>
              <div class="form-group">
                <label for="storageServiceEndpoint">对象存储 Endpoint</label>
                <input type="text" id="storageServiceEndpoint" v-model="settings.api.storageServiceEndpoint" placeholder="oss-cn-hangzhou.aliyuncs.com">
                <p class="form-hint">用于存储用户上传的图片、文件等。</p>
              </div>
            </div>

            <!-- 保存按钮 -->
            <div class="card-footer">
              <button class="btn btn-primary" @click="saveSettings" :disabled="isSaving">
                <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-save'"></i>
                {{ isSaving ? '保存中...' : '保存更改' }}
              </button>
            </div>
          </div>
        </transition>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// --- 模拟 API ---
const mockApi = {
  getSettings: () => new Promise(resolve => setTimeout(() => resolve({
    data: {
      success: true,
      data: {
        general: { siteName: '酷猿商城', logoUrl: null, copyright: '© 2025 Cool Ape Inc.', maintenanceMode: false },
        security: { sessionTimeout: 30, loginAttempts: 5, enable2FA: true },
        notifications: { smtpHost: 'smtp.mailtrap.io', smtpPort: 2525, smtpUser: 'user123', smtpPass: 'pass123', adminEmail: 'admin@coolape.com' },
        api: { paymentGatewayKey: 'pk_test_123xyz', mapServiceKey: 'AIzaSy_abc', storageServiceEndpoint: 'oss-cn-beijing.aliyuncs.com' }
      }
    }
  }), 800)),
  saveSettings: (settings) => new Promise(resolve => setTimeout(() => {
    console.log('Saving settings:', settings);
    resolve({ data: { success: true, message: '系统设置已成功更新！' } });
  }, 1000)),
  sendTestEmail: () => new Promise(resolve => setTimeout(() => {
    resolve({data: { success: true, message: '测试邮件已发送，请检查收件箱。'}});
  }, 1500))
};

// --- 状态管理 ---
const isLoading = ref(true);
const isSaving = ref(false);
const isSendingTestEmail = ref(false);
const activeTab = ref('general');
const notifications = ref([]);
let notificationIdCounter = 0;
const settings = ref({
  general: {},
  security: {},
  notifications: {},
  api: {}
});

const tabs = ref([
  { id: 'general', name: '通用设置', icon: 'fas fa-sliders-h' },
  { id: 'security', name: '安全设置', icon: 'fas fa-shield-alt' },
  { id: 'notifications', name: '通知设置', icon: 'fas fa-envelope' },
  { id: 'api', name: 'API 与集成', icon: 'fas fa-code-branch' },
]);

// --- 生命周期 ---
onMounted(async () => {
  const response = await mockApi.getSettings();
  if (response.data.success) {
    settings.value = response.data.data;
  } else {
    showNotification('加载配置失败', 'error');
  }
  isLoading.value = false;
});

// --- 方法 ---
const saveSettings = async () => {
  isSaving.value = true;
  try {
    const response = await mockApi.saveSettings(settings.value);
    if (response.data.success) {
      showNotification(response.data.message);
    } else {
      showNotification(response.data.message || '保存失败', 'error');
    }
  } catch (e) {
    showNotification('发生未知错误', 'error');
  } finally {
    isSaving.value = false;
  }
};

const sendTestEmail = async () => {
  isSendingTestEmail.value = true;
  try {
    const response = await mockApi.sendTestEmail();
    if (response.data.success) {
      showNotification(response.data.message, 'info');
    } else {
      showNotification(response.data.message || '发送失败', 'error');
    }
  } catch (e) {
    showNotification('发送失败，请检查网络和 SMTP 配置', 'error');
  } finally {
    isSendingTestEmail.value = false;
  }
}

const showNotification = (message, type = 'success', duration = 3000) => {
  const icons = {
    success: 'fas fa-check-circle',
    error: 'fas fa-exclamation-circle',
    info: 'fas fa-info-circle',
  };
  const id = notificationIdCounter++;
  notifications.value.push({ id, message, type, icon: icons[type] || icons.info });
  setTimeout(() => {
    const index = notifications.value.findIndex(n => n.id === id);
    if (index !== -1) notifications.value.splice(index, 1);
  }, duration);
};

</script>

<style scoped>
/* --- 变量和基础样式 --- */
:root {
  --accent-color: #4a6cf7;
  --text-primary: #1e293b;
  --text-secondary: #64748b;
  --border-color: #e2e8f0;
  --bg-primary: #ffffff;
  --bg-secondary: #f7f9fc;
  --bg-hover: #eff4ff;
  --danger-color: #ef4444;
  --success-color: #28a745;
  --info-color: #3498db;
  --border-radius-sm: 0.5rem;
  --border-radius-md: 0.75rem;
  --shadow-color: rgba(74, 108, 247, 0.1);
}

.settings-container {
  padding: 0;
  font-family: 'Inter', sans-serif;
  color: var(--text-primary);
  animation: fadeIn 0.6s ease-out;
}
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

/* --- 头部 --- */
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--border-color); }
.page-title { display: flex; align-items: center; gap: 0.75rem; margin: 0 0 0.5rem 0; font-size: 2rem; font-weight: 700; }
.page-title i { color: var(--accent-color); }
.page-subtitle { margin: 0; color: var(--text-secondary); }

/* --- 布局 --- */
.settings-layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 2rem;
  align-items: flex-start;
}
.settings-nav {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  position: sticky;
  top: 20px;
}
.nav-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.85rem 1.25rem;
  border: none;
  background: transparent;
  border-radius: var(--border-radius-sm);
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--text-secondary);
  cursor: pointer;
  text-align: left;
  transition: all 0.2s ease-in-out;
}
.nav-item i { width: 20px; text-align: center; }
.nav-item:hover { background-color: var(--bg-hover); color: var(--accent-color); }
.nav-item.active { background-color: var(--accent-color); color: white; box-shadow: 0 4px 12px var(--shadow-color); }
.settings-content { min-height: 400px; }

/* --- 卡片样式 --- */
.settings-card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-md);
  overflow: hidden;
}
.card-title {
  font-size: 1.25rem;
  margin: 0;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--border-color);
}
.card-description {
  padding: 0 2rem;
  margin-top: -1rem;
  margin-bottom: 1rem;
  color: var(--text-secondary);
}
.settings-card .form-group, .settings-card .form-grid {
  padding: 0 2rem;
}
.card-footer {
  display: flex;
  justify-content: flex-end;
  padding: 1.5rem 2rem;
  border-top: 1px solid var(--border-color);
  background-color: var(--bg-secondary);
  margin-top: 1rem;
  border-radius: 0 0 var(--border-radius-md) var(--border-radius-md);
}

/* --- 表单元素 --- */
.form-group { margin: 1.5rem 0; padding: 0 2rem; }
.form-group:first-child { margin-top: 1.5rem; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; padding: 0 2rem; }
.form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: var(--text-secondary); }
.form-group input[type="text"],
.form-group input[type="number"],
.form-group input[type="email"],
.form-group input[type="password"] {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  background-color: var(--bg-secondary);
  transition: all 0.2s ease;
}
.form-group input:focus {
  outline: none;
  border-color: var(--accent-color);
  background-color: var(--bg-primary);
  box-shadow: 0 0 0 3px var(--shadow-color);
}
.form-hint { font-size: 0.85rem; color: var(--text-secondary); margin-top: 0.5rem; }
.inline-group { display: flex; align-items: center; gap: 1rem; }
.inline-group label { margin-bottom: 0; }
.inline-group .form-hint { margin-top: 0; }

/* Toggle Switch */
.toggle-switch { position: relative; display: inline-block; width: 50px; height: 28px; }
.toggle-switch input { opacity: 0; width: 0; height: 0; }
.toggle-switch label { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; border-radius: 28px; transition: .4s; }
.toggle-switch label:before { position: absolute; content: ""; height: 20px; width: 20px; left: 4px; bottom: 4px; background-color: white; border-radius: 50%; transition: .4s; }
.toggle-switch input:checked + label { background-color: var(--success-color); }
.toggle-switch input:checked + label:before { transform: translateX(22px); }

/* Logo Uploader */
.logo-uploader { display: flex; align-items: center; gap: 1rem; }
.logo-preview { height: 40px; border-radius: var(--border-radius-sm); border: 1px solid var(--border-color); }

/* --- 按钮 --- */
.btn { display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.625rem 1.25rem; border: 2px solid transparent; border-radius: var(--border-radius-sm); font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.3s ease; }
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-primary { background: var(--accent-color); color: white; border-color: var(--accent-color); }
.btn-primary:hover:not(:disabled) { background: #3b57d6; border-color: #3b57d6; transform: translateY(-1px); }
.btn-outline { background: transparent; color: var(--text-secondary); border-color: var(--border-color); }
.btn-outline:hover { color: var(--accent-color); border-color: var(--accent-color); background: var(--bg-hover); }
.btn-sm { padding: 0.4rem 0.8rem; font-size: 0.8rem; }

/* --- 过渡动画 --- */
.fade-transform-enter-active, .fade-transform-leave-active { transition: all 0.3s ease-out; }
.fade-transform-enter-from { opacity: 0; transform: translateX(20px); }
.fade-transform-leave-to { opacity: 0; transform: translateX(-20px); }

/* --- 加载状态 --- */
.loading-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 4rem; text-align: center; color: var(--text-secondary); }
.spinner { width: 50px; height: 50px; border: 5px solid rgba(74, 108, 247, 0.2); border-top-color: var(--accent-color); border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 1rem; }
@keyframes spin { to { transform: rotate(360deg); } }

/* --- 通知 --- */
.notification-container { position: fixed; top: 20px; right: 20px; z-index: 2000; display: flex; flex-direction: column; gap: 10px; }
.notification { display: flex; align-items: center; gap: 10px; padding: 12px 18px; border-radius: var(--border-radius-sm); color: white; min-width: 300px; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2); animation: slideInRight 0.4s ease-out; }
.notification-success { background-color: var(--success-color); }
.notification-error { background-color: var(--danger-color); }
.notification-info { background-color: var(--info-color); }
.notification-icon { font-size: 1.2rem; }
.notification p { margin: 0; flex-grow: 1; }
.notification-fade-enter-active, .notification-fade-leave-active { transition: all 0.5s ease; }
.notification-fade-enter-from, .notification-fade-leave-to { opacity: 0; transform: translateX(30px); }
@keyframes slideInRight { from { transform: translateX(100%); } to { transform: translateX(0); } }

/* 响应式 */
@media (max-width: 992px) {
  .settings-layout { grid-template-columns: 1fr; }
  .settings-nav { flex-direction: row; position: static; overflow-x: auto; margin-bottom: 1.5rem; }
  .nav-item { flex-shrink: 0; }
}
</style>
