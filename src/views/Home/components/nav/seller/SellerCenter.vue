<template>
  <HomeNavbar/>
  <div class="seller-center-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1><i class="fas fa-store"></i>我的店铺</h1>
      <div class="user-info">
        <span>卖家：{{ userStore.userInfo?.username || '未命名' }}</span>
        <span class="credit-score">信用分：<strong>{{ userStore.userInfo?.creditScore || 0 }}</strong></span>
      </div>
    </div>

    <!-- 认证状态提示 -->
    <CertificationAlert :status="certificationStatus" />

    <!-- 根据认证状态显示不同内容 -->
    <div v-if="isCertified">
      <!-- 店铺信息卡片 -->
      <ShopInfo
          :stats="shopStats"
          @analyze="handleAnalyze"
          @settings="handleSettings"
          @logistics="handleLogistics"
      />

      <!-- 商品管理区域 -->
      <ProductManagement
          :products="products"
          :current-page="pagination.page"
          :total-pages="Math.ceil(pagination.total / pagination.size)"
          @add-product="handleAddProduct"
          @edit-product="handleEditProduct"
          @delete-product="handleDeleteProduct"
          @search="handleSearch"
          @page-change="handlePageChange"
          @review-product="handleReviewProduct"
      />
    </div>
    <!-- 通知消息 -->
    <div class="notification" :class="[notification.type, { show: notification.show }]">
      {{ notification.message }}
    </div>
  </div>
</template>

<script>
import CertificationAlert from './CertificationAlert.vue'
import ShopInfo from './ShopInfo.vue'
import ProductManagement from './ProductManagement.vue'
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import {
  deleteProduct,searchProducts
} from '@/api/product.js'
import {  getCertificationStatus } from '@/api/sellerCertification.js'
import { getShopStats, getSellerProducts, } from '@/api/shop.js'
import { useUserStore } from '@/stores/userStore'

export default {
  setup() {
    const userStore = useUserStore()
    return { userStore }
  },

  name: 'SellerCenter',
  components: {
    HomeNavbar,
    CertificationAlert,
    ShopInfo,
    ProductManagement
  },
  data() {
    return {
      pagination: {
        page: 1,
        size: 10,
        total: 0
      },
      certificationStatus: 'not_certified',
      shopStats: [],
      products: [],
      showModal: false,
      isEditing: false,
      currentProduct: {
        id: null,
        name: '',
        price: '',
        category: '',
        condition: '',
        stock: 1,
        description: ''
      },
      notification: {
        show: false,
        message: '',
        type: ''
      },
      // 状态映射
      statusMap: {
        1: '上架中',
        2: '已下架',
        3: '已售罄',
        4: '审核中'
      },
    }
  },
  computed: {
    // 计算属性：判断是否已认证
    isCertified() {
      return this.certificationStatus === 'certified';
    }
  },
  methods: {
    // 跳转到认证页面
    goToCertification() {
      this.$router.push('/seller/certification');
    },

    // 获取店铺统计信息
    async fetchShopStats() {
      // 只有认证通过才获取数据
      if (!this.isCertified) return;

      try {
        const response = await getShopStats()
        this.shopStats = [
          {
            icon: 'fas fa-box-open',
            value: response.data.data.onSaleCount,
            label: '在售商品',
            color: 'var(--primary-color)'
          },
          {
            icon: 'fas fa-shopping-cart',
            value: response.data.data.monthlyOrders,
            label: '本月订单',
            color: '#3498db'
          },
          {
            icon: 'fas fa-star',
            value: response.data.data.rating || '暂无更多评分',
            label: '店铺评分',
            color: '#f39c12'
          },
          {
            icon: 'fas fa-eye',
            value: response.data.data.monthlyViews,
            label: '本月浏览',
            color: '#9b59b6'
          }
        ]
      } catch (error) {
        console.error('获取店铺数据失败:', error)
        this.showNotification('获取店铺数据失败', 'error')
      }
    },

    handleReviewProduct(productId) {
      this.$router.push(`/product-review/${productId}`)
    },

    // 获取商品列表（带分页）
    async fetchProducts() {
      // 只有认证通过才获取数据
      if (!this.isCertified) return;

      try {
        const params = {
          page: this.pagination.page,
          size: this.pagination.size
        }

        const response = await getSellerProducts(params)

        // 简化后的商品数据处理
        this.products = response.data.data.items.map(item => ({
          id: item.id,
          image: item.image || 'http://localhost:8080/uploads/products/example.png',
          name: item.name || '未命名商品',
          price: this.formatPrice(item.price),
          stock: item.stock || 0,
          status: item.statusText || '未知状态',
          statusClass: this.mapNumericStatusToClass(item.status)
        }))

        this.pagination.total = response.data.data.total || 0
      } catch (error) {
        console.error('获取商品列表失败:', error)
        this.showNotification('获取商品列表失败: ' + error.message, 'error')
      }
    },

    // 数字状态映射到CSS类（只用于样式）
    mapNumericStatusToClass(status) {
      const classMap = {
        4: 'status-pending',
        1: 'status-active',
        2: 'status-sold',
        3: 'status-inactive'
      }
      return classMap[status] || ''
    },

    // 获取认证状态
    async fetchCertificationStatus() {
      try {
        const response = await getCertificationStatus()
        if (response.data.data === null) {
          this.certificationStatus = 'not_certified'
        } else {
          const statusMap = {
            0: 'pending',
            1: 'certified',
            2: 'rejected'
          }
          this.certificationStatus = statusMap[response.data.data.status] || 'not_certified'
        }

        // 认证状态改变后重新获取数据
        if (this.isCertified) {
          await this.fetchShopStats()
          await this.fetchProducts()
        }
      } catch (error) {
        this.showNotification('获取认证状态失败', 'error')
      }
    },

    // 删除商品
    async handleDeleteProduct(productId) {
      if (!this.isCertified) return;

      if (!productId) {
        this.showNotification('商品ID无效，无法删除', 'error')
        return
      }

      if (!confirm('确定要删除这个商品吗？此操作不可撤销。')) return

      try {
        await deleteProduct(productId)
        await this.fetchProducts()
        this.showNotification('商品已删除！', 'success')
      } catch (error) {
        this.showNotification('删除商品失败: ' + error.message, 'error')
      }
    },

    handleAnalyze() {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }
      this.showNotification('即将跳转到数据分析页面...', 'success')
    },

    handleSettings() {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }
      this.showNotification('即将跳转到店铺设置页面...', 'success')
    },

    handleLogistics() {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }
      this.showNotification('即将跳转到物流设置页面...', 'success')
    },

    handleAddProduct() {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }

      this.$router.push({
        name: 'ProductReview',
        query: {mode: 'add'}
      });
    },

    handleEditProduct(product) {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }

      this.$router.push({
        name: 'ProductReview',
        params: {
          productId: product.id
        }
      });
    },

    // 数字 → 文本（直接查表）
    statusNumberToText(statusNumber) {
      return this.statusMap[statusNumber] || '未知状态';
    },

    // 文本 → 数字（反向查找）
    statusTextToNumber(statusText) {
      if (!statusText) return null;
      const entry = Object.entries(this.statusMap).find(([_, text]) => text === statusText);
      return entry ? parseInt(entry[0], 10) : null;
    },

    async handleSearch(searchParams) {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }

      const processedParams = {
        title: searchParams.query,
        status: searchParams.status,
        sellerId: searchParams.currentSellerId
      };

      if (processedParams.status) {
        if (typeof processedParams.status === 'string') {
          const statusNumber = this.statusTextToNumber(processedParams.status)
          if (statusNumber !== null) {
            processedParams.status = statusNumber
          } else {
            delete processedParams.status
          }
        }
      }

      try {
        const params = {
          page: this.pagination.page,
          pageSize: this.pagination.size,
          ...processedParams
        }

        const response = await searchProducts(params)

        this.products = response.data.data.items.map(item => ({
          id: item.id,
          image: item.image || 'http://localhost:8080/uploads/products/example.png',
          name: item.title || '未命名商品',
          price: this.formatPrice(item.price),
          stock: item.stock || 0,
          status: this.statusNumberToText(item.status) || '未知状态',
          statusClass: this.mapNumericStatusToClass(item.status || 0)
        }))

        this.pagination.total = response.data.data.total || 0
      } catch (error) {
        this.showNotification('搜索商品失败: ' + error.message, 'error')
      }
    },

    closeModal() {
      this.showModal = false
    },

    // 处理分页变化
    handlePageChange(page) {
      if (!this.isCertified) {
        this.showNotification('请先完成卖家认证', 'error');
        return;
      }

      this.pagination.page = page
      this.fetchProducts()
    },

    // 价格格式化
    formatPrice(price) {
      return Number(price).toLocaleString('zh-CN')
    },

    showNotification(message, type) {
      this.notification = {
        show: true,
        message,
        type
      }

      setTimeout(() => {
        this.notification.show = false
      }, 3000)
    }
  },

  async mounted() {
    await this.fetchCertificationStatus()
  }
}
</script>

<!-- ============================================= -->
<!--           ↓↓↓ 全局共享样式 ↓↓↓             -->
<!-- (这个 style 标签没有 scoped 属性) -->
<!-- ============================================= -->
<style>
:root {
  --primary-color: #5c9e53;
  --secondary-color: #f7faf5;
  --hover-color: #e6f0e6;
  --text-muted-color: #6b7a63;
  --border-color: #d7e3d7;
  --shadow-color: rgba(92, 158, 83, 0.15);
  --danger-color: #e74c3c;
  --warning-color: #f39c12;
  --info-color: #3498db;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
  background-color: #f8f9fa;
  color: #333;
  line-height: 1.6;
}

/* --- 通用组件样式 --- */
.btn {
  padding: 10px 20px;
  border-radius: 50px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.btn i {
  margin-right: 8px;
}

.btn-primary {
  background-color: var(--primary-color);
  color: white;
  box-shadow: 0 4px 14px rgba(92, 158, 83, 0.35);
}

.btn-primary:hover {
  background-color: #46783a;
  box-shadow: 0 6px 20px rgba(70, 120, 58, 0.4);
}

.status-badge {
  display: inline-block;
  padding: 5px 12px;
  border-radius: 50px;
  font-size: 12px;
  font-weight: 600;
}

.status-active {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-pending {
  background-color: #fff8e1;
  color: #f57f17;
}

.status-sold {
  background-color: #ffebee;
  color: #c62828;
}

.status-inactive {
  background-color: #f5f5f5;
  color: #9e9e9e;
}

.notification {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 15px 25px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  z-index: 1100;
  opacity: 0;
  transform: translateY(-20px);
  transition: all 0.3s ease;
}

.notification.show {
  opacity: 1;
  transform: translateY(0);
}

.notification.success {
  background-color: var(--primary-color);
}

.notification.error {
  background-color: var(--danger-color);
}
</style>

<!-- ============================================= -->
<!--         ↓↓↓ SellerCenter 私有样式 ↓↓↓         -->
<!--   (这个 style 标签有 scoped 属性)   -->
<!-- ============================================= -->
<style scoped>
.seller-center-container {
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 80px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 15px;
  border-bottom: 2px solid var(--border-color);
}

.page-header h1 {
  color: #3b4a30;
  font-weight: 700;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.credit-score {
  background-color: var(--hover-color);
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 14px;
}
</style>
