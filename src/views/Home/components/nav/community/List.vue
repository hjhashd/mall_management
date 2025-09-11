<template>
  <HomeNavbar />
  <div class="page-wrapper">
    <!-- 动态背景辉光效果 -->
    <div class="glow-background"></div>
    <TechShowcase />
  </div>
</template>

<script setup>
import TechShowcase from './TechShowcase.vue';
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
</script>

<style scoped>
.page-wrapper {
  position: relative;
  min-height: 100vh;
  width: 100%;
  background-color: var(--color-background);
  overflow: hidden; /* 隐藏辉光溢出部分 */
}

/*
 * 动态辉光背景:
 * - 一个绝对定位的伪元素，置于内容底层。
 * - 使用径向渐变创造出两个柔和的光源。
 * - 通过 CSS 动画让它缓慢旋转和移动，增加页面的呼吸感和艺术感。
 * - 滤镜和透明度让效果非常微妙，不会干扰主体内容。
 */
.glow-background {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background-image: radial-gradient(circle at 25% 25%, hsla(210, 100%, 85%, 0.3), transparent 35%),
  radial-gradient(circle at 75% 75%, hsla(280, 100%, 85%, 0.2), transparent 35%);
  filter: blur(100px);
  animation: rotateGlow 25s cubic-bezier(0.5, 0, 0.5, 1) infinite;
  z-index: 0;
}

@keyframes rotateGlow {
  0% { transform: rotate(0deg) scale(1); }
  50% { transform: rotate(180deg) scale(1.1); }
  100% { transform: rotate(360deg) scale(1); }
}

/* 确保内容在辉光之上 */
:deep(.community-container) {
  position: relative;
  z-index: 1;
}
</style>
