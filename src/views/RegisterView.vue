<template>
  <div class="container-fluid min-vh-100 d-flex">
    <!-- 左侧背景图 -->
    <div class="d-none d-lg-flex col-lg-6 bg-primary text-white align-items-center justify-content-center p-5">
      <div class="text-center">
        <h1 class="display-5 fw-bold mb-3">加入我们</h1>
        <p class="lead">创建您的账户，开启全新体验。</p>
      </div>
    </div>

    <!-- 右侧注册表单 -->
    <div class="col-12 col-lg-6 d-flex align-items-center justify-content-center p-4 p-lg-5">
      <div class="w-100" style="max-width: 400px;">
        <!-- Logo -->
        <div class="text-center mb-4">
          <div class="d-inline-flex align-items-center justify-content-center bg-primary rounded-circle mb-3" style="width: 64px; height: 64px;">
            <span class="text-white fs-3 fw-bold">A</span>
          </div>
          <h2 class="h4 fw-semibold text-dark">Admin Framework</h2>
          <p class="text-muted">创建新账户</p>
        </div>

        <!-- 注册表单 -->
        <form @submit.prevent="handleRegister" class="bg-white p-4 rounded shadow-sm border">
          <div class="mb-3">
            <label class="form-label">用户名</label>
            <input
                v-model="username"
                type="text"
                class="form-control"
                placeholder="请输入用户名"
                required
            />
          </div>

          <div class="mb-3">
            <label class="form-label">邮箱</label>
            <input
                v-model="email"
                type="email"
                class="form-control"
                placeholder="请输入邮箱地址"
                required
            />
          </div>

          <div class="mb-3">
            <label class="form-label">密码</label>
            <input
                v-model="password"
                type="password"
                class="form-control"
                placeholder="请输入密码"
                required
            />
          </div>

          <div class="mb-3">
            <label class="form-label">确认密码</label>
            <input
                v-model="confirmPassword"
                type="password"
                class="form-control"
                placeholder="请再次输入密码"
                required
            />
          </div>

          <button
              type="submit"
              :disabled="loading"
              class="btn btn-primary w-100 d-flex align-items-center justify-content-center"
          >
            <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
            {{ loading ? '注册中...' : '注 册' }}
          </button>

          <!-- 登录跳转 -->
          <div class="mt-3 text-center">
            <p class="text-muted small">
              已有账号？
              <router-link to="/login" class="text-primary text-decoration-none fw-medium">立即登录</router-link>
            </p>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'

const username = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)

const router = useRouter()
const userStore = useUserStore()

const handleRegister = async () => {
  if (password.value !== confirmPassword.value) {
    alert('两次输入的密码不一致')
    return
  }

  loading.value = true

  try {
    const result = await userStore.register({
      username: username.value,
      email: email.value,
      password: password.value
    })

    if (result.success) {
      alert('注册成功，请登录')
      await router.push('/login')
    } else {
      alert(result.message) // 显示具体的错误信息，比如"用户名已存在"
    }
  } catch (error) {
    alert('注册过程中出现错误')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.min-vh-100 {
  min-height: 100vh;
}
</style>
