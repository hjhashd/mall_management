<template>
  <transition
      name="notification-fade"
      @enter="onEnter"
      @leave="onLeave"
  >
    <div v-if="visible" :class="['notification-wrapper', typeClass]" :style="positionStyle">
      <div class="notification-icon">
        <i :class="iconClass"></i>
      </div>
      <div class="notification-content">
        <p class="notification-title">{{ title }}</p>
        <p class="notification-message">{{ message }}</p>
      </div>
      <div class="notification-close" @click="close">
        <i class="fas fa-times"></i>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, onMounted, computed, onUnmounted } from 'vue';

const props = defineProps({
  message: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: 'info', // success, warning, error, info
  },
  duration: {
    type: Number,
    default: 3000,
  },
  onClose: {
    type: Function,
    default: () => {},
  },
  offset: {
    type: Number,
    default: 20,
  }
});

const visible = ref(false);
let timer = null;

onMounted(() => {
  visible.value = true;
  if (props.duration > 0) {
    timer = setTimeout(() => {
      close();
    }, props.duration);
  }
});

onUnmounted(() => {
  clearTimeout(timer);
});

const close = () => {
  visible.value = false;
};

const typeClass = computed(() => `is-${props.type}`);

const iconClass = computed(() => {
  switch (props.type) {
    case 'success':
      return 'fas fa-check-circle';
    case 'warning':
      return 'fas fa-exclamation-triangle';
    case 'error':
      return 'fas fa-times-circle';
    default:
      return 'fas fa-info-circle';
  }
});

const title = computed(() => {
  switch (props.type) {
    case 'success':
      return '成功';
    case 'warning':
      return '警告';
    case 'error':
      return '错误';
    default:
      return '提示';
  }
});

const positionStyle = computed(() => ({
  top: `${props.offset}px`,
}));

// Transition hooks
const onEnter = (el) => {
  // This function is called when the transition begins
};

const onLeave = (el, done) => {
  // When the leave transition ends, call the parent's onClose
  el.addEventListener('transitionend', () => {
    props.onClose();
  }, { once: true });
  done(); // done is not a function here, but we call onClose after transition
};

</script>

<style scoped>
.notification-wrapper {
  position: fixed;
  right: 20px;
  width: 330px;
  padding: 14px 26px 14px 13px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  background-color: #fff;
  z-index: 9999;
  transition: opacity 0.3s, transform 0.3s, top 0.4s;
  border-left: 5px solid;
}

/* Types */
.notification-wrapper.is-success { border-color: #67c23a; }
.notification-wrapper.is-success .notification-icon { color: #67c23a; }
.notification-wrapper.is-warning { border-color: #e6a23c; }
.notification-wrapper.is-warning .notification-icon { color: #e6a23c; }
.notification-wrapper.is-error { border-color: #f56c6c; }
.notification-wrapper.is-error .notification-icon { color: #f56c6c; }
.notification-wrapper.is-info { border-color: #909399; }
.notification-wrapper.is-info .notification-icon { color: #909399; }

.notification-icon {
  font-size: 24px;
  margin-right: 12px;
}

.notification-content {
  flex-grow: 1;
}

.notification-title {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
  margin: 0;
}

.notification-message {
  font-size: 14px;
  color: #606266;
  margin: 5px 0 0 0;
  line-height: 1.4;
}

.notification-close {
  position: absolute;
  top: 12px;
  right: 12px;
  cursor: pointer;
  color: #909399;
  font-size: 16px;
}
.notification-close:hover {
  color: #606266;
}

/* Transition styles */
.notification-fade-enter-from,
.notification-fade-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>
