<template>
  <div class="certification-alert" v-if="shouldShowAlert">
    <i :class="iconClass"></i>
    <div class="content">
      {{ message }}
      <a v-if="showLink" :href="linkUrl">{{ linkText }}</a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CertificationAlert',
  props: {
    status: {
      type: String,
      default: 'not_certified'
    }
  },
  computed: {
    shouldShowAlert() {
      return this.status !== 'certified'
    },
    iconClass() {
      switch (this.status) {
        case 'pending':
          return 'fas fa-hourglass-half'
        case 'rejected':
          return 'fas fa-exclamation-circle'
        default:
          return 'fas fa-info-circle'
      }
    },
    message() {
      switch (this.status) {
        case 'pending':
          return '您的商家认证正在审核中，请耐心等待。您也可以'
        case 'rejected':
          return '您的商家认证已被拒绝，请'
        default:
          return '您尚未进行商家认证，'
      }
    },
    showLink() {
      return true
    },
    linkText() {
      return '查看认证进度'
    },
    linkUrl() {
      return '/seller-certification'
    }
  }
}
</script>

<style scoped>
.certification-alert {
  background-color: #fff3cd;
  border-left: 5px solid var(--warning-color);
  padding: 15px 20px;
  margin-bottom: 30px;
  border-radius: 0 8px 8px 0;
  display: flex;
  align-items: center;
}

.certification-alert i {
  color: var(--warning-color);
  font-size: 24px;
  margin-right: 15px;
}

.certification-alert .content {
  flex: 1;
}

.certification-alert a {
  color: var(--primary-color);
  text-decoration: none;
  font-weight: 600;
  margin-left: 5px;
}

.certification-alert a:hover {
  text-decoration: underline;
}
</style>
