<template>
  <div class="loading-overlay">
    <!-- 动态背景形状 -->
    <div class="background-shapes">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
    </div>

    <!-- 加载内容盒子 -->
    <div class="loading-box">
      <div class="spinner-container">
        <!-- 可爱的呼吸云朵 SVG -->
        <svg class="cute-cloud" viewBox="0 0 100 60" xmlns="http://www.w3.org/2000/svg">
          <path d="M73.2,34.2c-1.4-7.4-7.9-13-15.7-13c-0.8,0-1.6,0.1-2.4,0.2c-2.3-6.2-8.3-10.4-15.2-10.4c-9.1,0-16.5,7.4-16.5,16.5c0,0.5,0,1,0.1,1.5c-4.4-0.1-8.1,3.5-8.1,7.9c0,4.4,3.6,8,8,8h44.6C72,52.8,77,47.8,77,41.5C77,38,75.5,35,73.2,34.2z" fill="#FFFFFF"/>
          <circle class="eye left-eye" cx="45" cy="32" r="2.5" fill="#4A6CF7"/>
          <circle class="eye right-eye" cx="55" cy="32" r="2.5" fill="#4A6CF7"/>
          <path class="mouth" d="M48 38 Q 50 40 52 38" stroke="#4A6CF7" stroke-width="1.5" fill="none" stroke-linecap="round" />
        </svg>
        <!-- 主加载环 -->
        <div class="spinner"></div>
      </div>
      <p class="loading-message">{{ message }}</p>
      <!-- 跳动的小点 -->
      <div class="dots">
        <span class="dot dot-1"></span>
        <span class="dot dot-2"></span>
        <span class="dot dot-3"></span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  message: {
    type: String,
    default: '正在加载中'
  }
});
</script>

<style scoped>
/* 定义主题颜色变量，与你的项目保持一致 */
:root {
  --accent-color: #4a6cf7;
  --bg-secondary: #f7f9fc;
  --text-primary: #1e293b;
  --text-secondary: #64748b;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  /* 使用柔和的背景色和毛玻璃效果 */
  background-color: rgba(247, 249, 252, 0.9);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  font-family: 'Inter', sans-serif;
  transition: opacity 0.3s ease;
}

.loading-box {
  text-align: center;
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

/* 旋转加载器容器 */
.spinner-container {
  position: relative;
  width: 120px;
  height: 120px;
  margin: 0 auto 1rem;
}

.spinner {
  width: 100%;
  height: 100%;
  border: 6px solid rgba(74, 108, 247, 0.15);
  border-top-color: var(--accent-color, #4a6cf7);
  border-radius: 50%;
  animation: spin 1.2s cubic-bezier(0.6, 0.2, 0.4, 0.8) infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 可爱的云朵SVG */
.cute-cloud {
  position: absolute;
  width: 80px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: gentle-breath 3s ease-in-out infinite;
}

.cute-cloud .eye {
  animation: blink 4s ease-in-out infinite;
  transform-origin: center;
}

.cute-cloud .right-eye {
  animation-delay: 0.2s;
}

@keyframes gentle-breath {
  0%, 100% { transform: translate(-50%, -50%) scale(1); }
  50% { transform: translate(-50%, -52%) scale(1.05); }
}

@keyframes blink {
  0%, 90%, 100% { transform: scaleY(1); }
  95% { transform: scaleY(0.1); }
}


/* 加载信息文本 */
.loading-message {
  font-size: 1.1rem;
  font-weight: 500;
  color: var(--text-primary, #1e293b);
  margin: 0 0 1rem;
}

/* 跳动的小点 */
.dots {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.dot {
  width: 10px;
  height: 10px;
  background-color: var(--accent-color, #4a6cf7);
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.dot-1 { animation-delay: -0.32s; }
.dot-2 { animation-delay: -0.16s; }
.dot-3 { animation-delay: 0s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1.0); }
}

/* 动态背景形状 */
.background-shapes {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  z-index: -1;
}

.shape {
  position: absolute;
  border-radius: 50%;
  background: rgba(74, 108, 247, 0.08);
  animation: drift 20s infinite linear alternate;
}

.shape-1 {
  width: 250px;
  height: 250px;
  top: -50px;
  left: -50px;
}

.shape-2 {
  width: 180px;
  height: 180px;
  bottom: -20px;
  right: -60px;
  animation-duration: 25s;
}

.shape-3 {
  width: 120px;
  height: 120px;
  bottom: 30%;
  left: 10%;
  animation-duration: 15s;
}

@keyframes drift {
  from {
    transform: translateY(0px) rotate(0deg);
  }
  to {
    transform: translateY(40px) rotate(90deg);
  }
}
</style>
