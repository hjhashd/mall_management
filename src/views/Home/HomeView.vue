<template>
  <div id="app">


    <HomeNavbar />
    <FloatingActionButton />
    <ExampleProduct/>

  </div>
</template>

<script setup>
import HomeNavbar from './components/HomeNavbar.vue';

import FloatingActionButton from './components/FloatingActionButton.vue';

import { useUserStore } from '@/stores/userStore';
import { computed, watch } from 'vue';
const userStore = useUserStore();


import { notification } from 'ant-design-vue';
import ExampleProduct from "@/views/Home/HomePage/ExampleProduct.vue";



// 计算用户名
const userName = computed(() => {
  return userStore.userInfo?.username || '用户';
});

// 监听登录成功状态
watch(() => userStore.loginSuccess, (newVal) => {
  if (newVal) {
    notification.success({
      message: '登录成功',
      description: `欢迎回来，${userName.value}`,
      duration: 3,
      placement: 'topRight',
      style: {
        borderRadius: '8px',
      }
    });

    // 重置登录状态
    setTimeout(() => {
      userStore.resetLoginSuccess();
    }, 3000);
  }
}, { immediate: true });
</script>

