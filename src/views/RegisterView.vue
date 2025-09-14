<template>
  <!-- 
    UI 风格与登录页面保持一致，并使用 CSS Modules 进行样式隔离。
  -->
  <div :class="$style['login-page']">
    <div :class="$style['login-container']">
      <!-- 左侧品牌展示面板 -->
      <div :class="$style['login-left-panel']">
        <div :class="$style.content">
          <h1 :class="$style['display-title']">加入我们，<br>发现更多可能</h1>
          <p :class="$style.subtitle">创建一个账户，开启你的品质生活之旅。</p>
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

      <!-- 右侧注册表单面板 -->
      <div :class="$style['login-right-panel']">
        <div :class="$style['login-card']">
          <div :class="$style['form-header']">
            <h2 :class="$style['form-title']">创建新账户</h2>
            <p :class="$style['form-subtitle']">只需几步，即可完成注册</p>
          </div>

          <form @submit.prevent="handleRegister" :class="$style['login-form']">
            
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
                placeholder="请输入用户名"
                required
              />
            </div>
            
            <div :class="$style['form-group']">
              <i class="fas fa-envelope" :class="$style['form-icon']"></i>
              <input
                id="email"
                v-model="email"
                type="email"
                :class="$style['form-control']"
                placeholder="请输入邮箱地址"
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
            
            <div :class="$style['form-group']">
              <i class="fas fa-check-circle" :class="$style['form-icon']"></i>
              <input
                id="confirmPassword"
                v-model="confirmPassword"
                type="password"
                :class="$style['form-control']"
                placeholder="请再次输入密码"
                required
              />
            </div>

            <button
              type="submit"
              :disabled="loading"
              :class="$style['btn-login-submit']"
            >
              <span v-if="loading" :class="$style.spinner"></span>
              {{ loading ? '注册中...' : '立即注册' }}
            </button>

            <div :class="$style['register-link']">
              <p>已有账号？
                <router-link to="/login" :class="$style['link-text']">立即登录</router-link>
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
import { useUserStore } from '@/stores/userStore';

const username = ref('');
const email = ref('');
const password = ref('');
const confirmPassword = ref('');
const loading = ref(false);
const errorMessage = ref(''); // 用于显示错误信息, 替代 alert

const router = useRouter();
const userStore = useUserStore();

const handleRegister = async () => {
  errorMessage.value = ''; // 开始时清空错误信息

  if (password.value !== confirmPassword.value) {
    errorMessage.value = '两次输入的密码不一致';
    return;
  }

  loading.value = true;

  try {
    const result = await userStore.register({
      username: username.value,
      email: email.value,
      password: password.value,
    });

    if (result.success) {
      // 注册成功后可以给一个提示，然后跳转
      // 实际项目中可能会自动登录，这里我们跳转到登录页
      alert('注册成功，请登录'); // 简单提示，也可以换成更复杂的UI组件
      await router.push('/login');
    } else {
      errorMessage.value = result.message; // 显示具体的错误信息，比如"用户名已存在"
    }
  } catch (error) {
    console.error("注册失败:", error);
    errorMessage.value = '注册过程中出现未知错误，请稍后重试。';
  } finally {
    loading.value = false;
  }
};
</script>

<!-- 
  这部分样式与 login.vue 完全相同，以确保视觉统一。
  通过 CSS Modules，两个文件的样式虽然内容一样，但作用域是完全独立的。
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
    display: none;
  }
  .login-right-panel {
    padding: 2rem;
  }
  .login-page {
    padding: 1rem;
  }
}
</style>
