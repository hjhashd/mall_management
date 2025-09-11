<template>
  <div class="login-page">
    <div class="login-left-panel">
      <div class="pattern-overlay"></div>
      <div class="content">
        <h1 class="display-title">欢迎回来，<br>用户！</h1>
        <p class="subtitle">登录您的账户，继续探索精彩的知识世界。</p>
        <div class="illustration">
          <i class="fas fa-book-reader"></i>
        </div>
      </div>
    </div>

    <div class="login-right-panel">
      <div class="login-card">
        <div class="brand-header">
          <div class="brand-icon">
            <i class="fas fa-feather-alt"></i> </div>
          <h2 class="brand-title">知屿阅读</h2>
          <p class="tagline">畅享阅读，共享知识</p>
        </div>

        <form @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label for="username" class="form-label">用户名</label>
            <input
                id="username"
                v-model="username"
                type="text"
                class="form-control"
                placeholder="请输入您的用户名"
                required
            />
          </div>

          <div class="form-group">
            <label for="password" class="form-label">密码</label>
            <input
                id="password"
                v-model="password"
                type="password"
                class="form-control"
                placeholder="请输入您的密码"
                required
            />
          </div>

          <div class="form-options">
            <div class="remember-me">
              <input
                  id="remember"
                  type="checkbox"
                  v-model="rememberMe"
                  class="form-check-input"
              />
              <label for="remember" class="form-check-label">记住我</label>
            </div>
            <router-link to="/forgot-password" class="forgot-password-link">忘记密码？</router-link>
          </div>

          <button
              type="submit"
              :disabled="loading"
              class="btn-login-submit"
          >
            <span v-if="loading" class="spinner"></span>
            {{ loading ? '登录中...' : '立即登录' }}
          </button>

          <div class="register-link">
            <p>还没有账号？
              <router-link to="/register" class="link-text">免费注册</router-link>
            </p>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref} from 'vue'
import {useRouter} from 'vue-router'
import {useUserStore} from '@/stores/userStore' // 假设您已经配置了Pinia或Vuex用户存储

const username = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)

const router = useRouter()
const userStore = useUserStore()


const handleLogin = async () => {
  loading.value = true
  try {
    const success = await userStore.login(
        username.value,
        password.value,
        rememberMe.value
    )

    if (success) {
      await router.push('/')
    } else {
      alert('用户名或密码错误！')
    }
  } catch (error) {
    console.error('登录失败:', error);
    alert('登录失败，请重试或联系管理员。')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 调整整体页面背景色为非常浅的米白色 */
.login-page {
  display: flex;
  min-height: 100vh;
  background-color: #F8F7F4; /* 浅米白色 */
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  overflow: hidden;

  background-image: url('/xiedie.png'); /* 替换为你的图片路径 */
  background-size: cover; /* 覆盖整个区域 */
  background-position: center; /* 图片居中 */
  background-repeat: no-repeat; /* 不重复 */
  background-attachment: fixed; /* 背景图固定，不随滚动条滚动 */
}

/* 左侧面板：改为柔和的浅色调，文字更清晰 */
.login-left-panel {
  flex: 1.2;
 /* background-color: #E6EAEB; /* 柔和的浅蓝色调 */
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #3C4A57; /* 深灰蓝色，在浅背景上更清晰 */
  padding: 3rem;
  overflow: hidden;
  border-bottom-right-radius: 60px;
  border-top-right-radius: 60px;
}

/* 背景图案叠加：降低不透明度 */
.pattern-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0 20v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zM6 46v-4H4v4H0v2h4v4h2v-4h4v-2H6zm0-20v-4H4v4H0v2h4v4h2v-4h4v-2H6zM36 6v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zM6 16V12H4v4H0v2h4v4h2v-4h4v-2H6zm0-10V2H4v4H0v2h4v4h2v-4h4v-2H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
  opacity: 0.2; /* 降低不透明度 */
  z-index: 1;
}

.login-left-panel .content {
  position: relative;
  z-index: 2;
  text-align: center;
  max-width: 500px;
}

.display-title {
  font-size: 3.5rem;
  font-weight: 800;
  margin-bottom: 1.5rem;
  line-height: 1.2;
  color: #3C4A57; /* 调整标题颜色 */
  text-shadow: 0 4px 10px rgba(0, 0, 0, 0.08); /* 调整阴影使其更柔和 */
}

.subtitle {
  font-size: 1.3rem;
  line-height: 1.6;
  margin-bottom: 2rem;
  color: #5F6B75; /* 调整副标题颜色 */
  opacity: 1; /* 确保可见性 */
}

.illustration {
  font-size: 8rem;
  color: #B4C4CE; /* 调整插画颜色为柔和的蓝色 */
  margin-top: 3rem;
  animation: float 4s ease-in-out infinite;
}

@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
}


.login-right-panel {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem;
}

/* 登录卡片：更浅的背景和柔和的边框 */
.login-card {
  background-color: #FFFFFF; /* 纯白色卡片背景 */
  padding: 3rem 2.5rem;
  border-radius: 20px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.05); /* 更柔和的阴影 */
  width: 100%;
  max-width: 450px;
  border: 1px solid #EAEAEA; /* 非常浅的边框 */
}

.brand-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

/* 品牌图标：改为柔和的蓝绿色渐变 */
.brand-icon {
  width: 70px;
  height: 70px;
  background: linear-gradient(135deg, #6CCECB, #A8D8D0); /* 柔和的蓝绿色渐变 */
  border-radius: 18px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1rem;
  font-size: 2.2rem;
  color: white;
  box-shadow: 0 6px 20px rgba(108, 206, 203, 0.3); /* 调整阴影颜色 */
}

.brand-title {
  font-size: 2.2rem;
  font-weight: 700;
  color: #3C4A57; /* 深灰蓝色标题 */
  margin-bottom: 0.5rem;
}

.tagline {
  font-size: 1rem;
  color: #7B8B9B; /* 柔和的灰蓝色 */
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  margin-bottom: 0.5rem;
}

.form-label {
  display: block;
  font-size: 0.95rem;
  color: #5F6B75; /* 柔和的深色文本 */
  margin-bottom: 0.6rem;
  font-weight: 600;
}

/* 输入框：更浅的边框和背景 */
.form-control {
  width: 100%;
  padding: 1rem 1.2rem;
  border: 2px solid #E0E0E0; /* 柔和的边框 */
  border-radius: 12px;
  font-size: 1rem;
  color: #3C4A57;
  background-color: #FDFDFD; /* 接近白色的输入框背景 */
  transition: all 0.3s ease;
}

.form-control:focus {
  border-color: #6CCECB; /* 焦点时的蓝绿色边框 */
  outline: none;
  box-shadow: 0 0 0 4px rgba(108, 206, 203, 0.1); /* 调整阴影颜色 */
}

.form-control::placeholder {
  color: #B0B0B0; /* 柔和的占位符颜色 */
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.5rem;
  margin-bottom: 1rem;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

/* 复选框：改为蓝绿色 */
.form-check-input {
  appearance: none;
  width: 1.25rem;
  height: 1.25rem;
  border: 2px solid #E0E0E0;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
}

.form-check-input:checked {
  background-color: #6CCECB;
  border-color: #6CCECB;
}

.form-check-input:checked::after {
  content: '\2713'; /* Unicode checkmark */
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 0.9rem;
  font-weight: bold;
}

.form-check-label {
  color: #5F6B75;
  font-size: 0.95rem;
  cursor: pointer;
}

/* 忘记密码链接：改为蓝绿色 */
.forgot-password-link {
  color: #6CCECB; /* 蓝绿色链接 */
  text-decoration: none;
  font-size: 0.95rem;
  transition: color 0.2s ease;
}

.forgot-password-link:hover {
  color: #54B2AE; /* 稍微深一点的蓝绿色 */
  text-decoration: underline;
}

/* 登录按钮：改为柔和的蓝绿色渐变 */
.btn-login-submit {
  width: 100%;
  padding: 1.2rem;
  background: linear-gradient(135deg, #6CCECB, #A8D8D0); /* 按钮背景渐变 */
  color: white;
  border: none;
  border-radius: 14px;
  font-size: 1.15rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 6px 20px rgba(108, 206, 203, 0.25); /* 更柔和的阴影 */
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
}

.btn-login-submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(108, 206, 203, 0.35);
}

.btn-login-submit:disabled {
  background: linear-gradient(135deg, #B5E0DE, #DDECEB); /* 禁用时的柔和渐变 */
  cursor: not-allowed;
  box-shadow: none;
  transform: none;
}

.spinner {
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.register-link {
  text-align: center;
  margin-top: 2rem;
  font-size: 0.95rem;
  color: #7B8B9B;
}

/* 注册链接：改为蓝绿色 */
.link-text {
  color: #6CCECB;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s ease;
}

.link-text:hover {
  color: #54B2AE;
  text-decoration: underline;
}

/* 响应式调整保持不变 */
@media (max-width: 992px) {
  .login-page {
    flex-direction: column;
  }

  .login-left-panel {
    min-height: 250px;
    border-radius: 0 0 40px 40px;
    padding: 2rem;
    flex: none;
  }

  .display-title {
    font-size: 2.5rem;
  }

  .subtitle {
    font-size: 1rem;
    margin-bottom: 1.5rem;
  }

  .illustration {
    font-size: 6rem;
    margin-top: 1.5rem;
  }

  .login-right-panel {
    padding: 2rem;
    flex: 1;
  }

  .login-card {
    padding: 2rem 1.5rem;
    border-radius: 16px;
  }

  .brand-title {
    font-size: 1.8rem;
  }
}

@media (max-width: 576px) {
  .login-page {
    padding: 1rem;
  }

  .login-left-panel {
    padding: 1.5rem;
    min-height: 200px;
  }

  .display-title {
    font-size: 2rem;
  }

  .subtitle {
    font-size: 0.9rem;
  }

  .illustration {
    font-size: 5rem;
  }

  .login-right-panel {
    padding: 1rem;
  }

  .login-card {
    padding: 1.8rem 1.2rem;
  }

  .form-options {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.8rem;
  }
}
</style>
