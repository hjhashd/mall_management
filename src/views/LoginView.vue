<template>
  <!-- 
    UI 来自“二手商城”版本，逻辑来自“知屿阅读”版本。
    所有 class 依然通过 CSS Modules 绑定，确保样式隔离。
  -->
  <div :class="$style['login-page']">
    <div :class="$style['login-container']">
      <!-- 左侧品牌展示面板 -->
      <div :class="$style['login-left-panel']">
        <div :class="$style.content">
          <h1 :class="$style['display-title']">欢迎来到二手商城</h1>
          <p :class="$style.subtitle">品质生活从这里开始</p>
          <div :class="$style['product-card']">
            <div :class="$style['product-image-placeholder']">
              <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg>
              <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"></circle><polyline points="12 9 12 12 13.5 13.5"></polyline><path d="M16.51 17.35l-.35 3.83a2 2 0 0 1-2 1.82H9.83a2 2 0 0 1-2-1.82l-.35-3.83m.01-10.7l.35-3.83A2 2 0 0 1 9.83 1h4.35a2 2 0 0 1 2 1.82l.35 3.83"></path></svg>
            </div>
            <div :class="$style['product-info']">
              <h3 :class="$style['product-title']">Phones & Accessories</h3>
              <p :class="$style['product-desc']">The guarantee is generic</p>
              <button :class="$style['shop-now-btn']">SHOP NOW</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧登录表单面板 -->
      <div :class="$style['login-right-panel']">
        <div :class="$style['login-card']">
          <div :class="$style['form-header']">
            <h2 :class="$style['form-title']">欢迎登录-二手商城</h2>
            <p :class="$style['form-subtitle']">请输入您的账号信息</p>
          </div>

          <form @submit.prevent="handleLogin" :class="$style['login-form']">
            
            <div v-if="errorMessage" :class="$style['error-message']">
              {{ errorMessage }}
            </div>

            <div :class="$style['form-group']">
              <i class="fas fa-user" :class="$style['form-icon']"></i>
              <input
                id="username"
                v-model="username"
                type="text"
                :class="$style['form-control']"
                placeholder="请输入账号"
                required
              />
            </div>

            <div :class="$style['form-group']">
              <i class="fas fa-lock" :class="$style['form-icon']"></i>
              <input
                id="password"
                v-model="password"
                type="password"
                :class="$style['form-control']"
                placeholder="请输入密码"
                required
              />
            </div>

            <div :class="$style['form-options']">
              <div :class="$style['remember-me']">
                <input
                  id="remember"
                  type="checkbox"
                  v-model="rememberMe"
                  :class="$style['form-check-input']"
                />
                <label for="remember" :class="$style['form-check-label']">记住我</label>
              </div>
              <!-- 使用 router-link 替换 a 标签以实现路由跳转 -->
              <router-link to="/forgot-password" :class="$style['forgot-password-link']">忘记密码？</router-link>
            </div>

            <button
              type="submit"
              :disabled="loading"
              :class="$style['btn-login-submit']"
            >
              <span v-if="loading" :class="$style.spinner"></span>
              {{ loading ? '登录中...' : '登录' }}
            </button>

            <div :class="$style['register-link']">
              <p>还没有账号？
                <!-- 使用 router-link 替换 a 标签以实现路由跳转 -->
                <router-link to="/register" :class="$style['link-text']">立即注册</router-link>
              </p>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useUserStore } from '@/stores/userStore'; // 确保您的项目中已正确配置 Pinia 和用户 store

const username = ref('');
const password = ref('');
const rememberMe = ref(false);
const loading = ref(false);
const errorMessage = ref(''); // 用于显示错误信息, 替代 alert

const router = useRouter();
const userStore = useUserStore();

// 这是来自“知屿阅读”的真实登录逻辑
const handleLogin = async () => {
  loading.value = true;
  errorMessage.value = ''; // 开始登录时清空错误信息

  try {
    const success = await userStore.login(
      username.value,
      password.value,
      rememberMe.value
    );

    if (success) {
      await router.push('/'); // 登录成功，跳转到首页
    } else {
      // 登录失败，设置错误信息以在UI中显示
      errorMessage.value = '用户名或密码错误！';
    }
  } catch (error) {
    console.error('登录失败:', error);
    // 发生异常，设置错误信息
    errorMessage.value = '登录失败，请重试或联系管理员。';
  } finally {
    loading.value = false;
  }
};
</script>

<!-- 
  使用 <style module> 替代 <style scoped> 
  这是来自“二手商城”的样式，并已模块化。
-->
<style module>
/* 引入 Font Awesome 图标库 */
@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css');

/* 页面容器 */
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background-color: #E0E7FF;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  padding: 2rem;
}

/* 登录卡片主容器 */
.login-container {
  display: flex;
  width: 100%;
  max-width: 960px;
  background-color: #FFFFFF;
  border-radius: 1.5rem;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* 左侧面板 */
.login-left-panel {
  flex: 1;
  background-image: linear-gradient(135deg, #6B7280, #4B5563);
  color: #F9FAFB;
  padding: 3rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-top-left-radius: 1.5rem;
  border-bottom-left-radius: 1.5rem;
}

.content {
  max-width: 320px;
}

.display-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.75rem;
}

.subtitle {
  font-size: 1rem;
  opacity: 0.8;
  margin-bottom: 2rem;
}

/* 产品展示卡 */
.product-card {
    background-color: #374151;
    border-radius: 1rem;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

.product-image-placeholder {
    color: #9CA3AF;
    display: flex;
    align-items: center;
    justify-content: center;
}

.product-info {
    flex: 1;
}

.product-title {
    font-size: 1.1rem;
    font-weight: 600;
    margin: 0 0 0.25rem 0;
}

.product-desc {
    font-size: 0.8rem;
    opacity: 0.7;
    margin: 0 0 1rem 0;
}

.shop-now-btn {
    background-color: #3B82F6;
    color: white;
    border: none;
    border-radius: 0.5rem;
    padding: 0.5rem 1rem;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.shop-now-btn:hover {
    background-color: #2563EB;
}


/* 右侧面板 */
.login-right-panel {
  flex: 1;
  padding: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-card {
  width: 100%;
  max-width: 360px;
}

.form-header {
  margin-bottom: 2rem;
  text-align: left;
}

.form-title {
  font-size: 1.75rem;
  font-weight: 700;
  color: #1F2937;
  margin-bottom: 0.5rem;
}

.form-subtitle {
  font-size: 0.95rem;
  color: #6B7280;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

/* 错误信息提示框 */
.error-message {
    background-color: #FEE2E2;
    color: #B91C1C;
    padding: 0.75rem 1rem;
    border-radius: 0.5rem;
    font-size: 0.9rem;
    text-align: center;
    margin-bottom: 1rem;
}

/* 表单组 */
.form-group {
  position: relative;
}

.form-icon {
    position: absolute;
    top: 50%;
    left: 1rem;
    transform: translateY(-50%);
    color: #6B7280;
    font-size: 1.1rem;
}

.form-control {
  width: 100%;
  padding: 0.9rem 1rem 0.9rem 3rem;
  border: 1px solid #D1D5DB;
  border-radius: 0.75rem;
  font-size: 1rem;
  color: #1F2937;
  background-color: #F3F4F6;
  transition: all 0.3s ease;
}

.form-control:focus {
  outline: none;
  border-color: #3B82F6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}

.form-control::placeholder {
  color: #9CA3AF;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.9rem;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-check-input {
    width: 1.1rem;
    height: 1.1rem;
    cursor: pointer;
}

.form-check-label {
  color: #6B7280;
  cursor: pointer;
}

.forgot-password-link {
  color: #3B82F6;
  text-decoration: none;
}
.forgot-password-link:hover {
  text-decoration: underline;
}

/* 登录按钮 */
.btn-login-submit {
  width: 100%;
  padding: 0.9rem;
  background-color: #3B82F6;
  color: white;
  border: none;
  border-radius: 0.75rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
}

.btn-login-submit:hover {
  background-color: #2563EB;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
}

.btn-login-submit:disabled {
  background-color: #93C5FD;
  cursor: not-allowed;
  box-shadow: none;
}

.spinner {
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}


.register-link {
  text-align: center;
  font-size: 0.9rem;
  color: #6B7280;
  margin-top: 1rem;
}

.link-text {
  color: #3B82F6;
  text-decoration: none;
  font-weight: 600;
}

.link-text:hover {
  text-decoration: underline;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .login-container {
    flex-direction: column;
  }
  .login-left-panel {
    display: none; /* 在小屏幕上隐藏左侧面板以简化布局 */
  }
  .login-right-panel {
    padding: 2rem;
  }
  .login-page {
    padding: 1rem;
  }
}
</style>

