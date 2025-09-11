<template>
  <div class="section">
    <h5>基本信息</h5>
    <div class="card">
      <div class="row">
        <div class="field">
          <label>用户名</label>
          <div class="value">{{ mock.username }}</div>
        </div>
        <div class="field">
          <label>邮箱</label>
          <div class="value">{{ mock.email }}</div>
        </div>
      </div>
      <div class="row">
        <div class="field">
          <label>手机号</label>
          <div class="value">{{ mock.phone }}</div>
        </div>
        <div class="field">
          <label>注册时间</label>
          <div class="value">{{ mock.registeredAt }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { getUserBasicInfo } from '@/api/user'

const mock = reactive({
  username: '未登录',
  email: 'example@mail.com',
  phone: '—',
  registeredAt: '—'
})

const initUserBasicInfo = async () => {
  const response = await getUserBasicInfo()
  if (response.data && response.data.data) {
    Object.assign(mock, response.data.data)
  }
}

onMounted(() => {
  initUserBasicInfo()
})
</script>

<style scoped>
.section h5 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 8px;
  margin-bottom: 16px;
}

.card {
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 16px;
  background: #fbfffb;
}

.row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.field {
  border: 1px dashed var(--border-color);
  border-radius: 10px;
  padding: 12px;
}

.field label {
  color: #6b7a63;
  font-size: 12px;
}

.value {
  margin-top: 4px;
  font-weight: 600;
  color: #3b4a30;
}

@media (max-width: 768px) {
  .row {
    grid-template-columns: 1fr;
  }
}
</style>
