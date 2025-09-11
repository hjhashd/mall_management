<template>
  <div class="complete-product-form">
    <HomeNavbar />

    <div class="form-container">
      <div class="form-header">
        <h1><i class="fas fa-edit"></i> 完善商品信息</h1>
        <p>请完善以下商品信息，完成后可提交审核</p>
      </div>

      <form @submit.prevent="submitCompleteProduct" class="product-form">
        <!-- 基本信息 -->
        <div class="form-section">
          <h2><i class="fas fa-info-circle"></i> 基本信息</h2>

          <div class="form-row">
            <div class="form-group">
              <label for="title">商品标题 *</label>
              <input
                  type="text"
                  id="title"
                  v-model="productData.title"
                  placeholder="请输入商品标题"
                  required
              >
            </div>

            <div class="form-group">
              <label for="category">商品分类 *</label>
              <select
                  id="category"
                  v-model="productData.categoryId"
                  required
              >
                <option value="">请选择分类</option>
                <option
                    v-for="category in categories"
                    :key="category.categoryId"
                    :value="category.categoryId"
                >
                  {{ category.categoryName }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="subCategory">子分类名称</label>
              <input
                  type="text"
                  id="subCategory"
                  v-model="productData.subCategory"
                  placeholder="请输入子分类名称（可选）"
              >
            </div>

            <div class="form-group">
              <label for="condition">商品成色 *</label>
              <select
                  id="condition"
                  v-model="productData.condition"
                  required
              >
                <option value="">请选择成色</option>
                <option value="1">全新</option>
                <option value="2">95新</option>
                <option value="3">9成新</option>
                <option value="4">8成新</option>
                <option value="5">7成新及以下</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="price">当前售价 *</label>
              <input
                  type="number"
                  id="price"
                  v-model="productData.price"
                  placeholder="请输入当前售价"
                  step="0.01"
                  min="0"
                  required
              >
            </div>

            <div class="form-group">
              <label for="originalPrice">原价（参考）</label>
              <input
                  type="number"
                  id="originalPrice"
                  v-model="productData.originalPrice"
                  placeholder="请输入原价"
                  step="0.01"
                  min="0"
              >
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="stock">库存数量 *</label>
              <input
                  type="number"
                  id="stock"
                  v-model="productData.stock"
                  placeholder="请输入库存数量"
                  min="1"
                  required
              >
            </div>

            <div class="form-group">
              <label for="location">商品位置 *</label>
              <input
                  type="text"
                  id="location"
                  v-model="productData.location"
                  placeholder="请输入商品位置"
                  required
              >
            </div>
          </div>
        </div>

        <!-- 商品描述 -->
        <div class="form-section">
          <h2><i class="fas fa-align-left"></i> 商品描述 *</h2>
          <div class="form-group">
            <textarea
                v-model="productData.description"
                placeholder="请详细描述商品信息，包括品牌、型号、使用情况、瑕疵等..."
                rows="6"
                required
            ></textarea>
          </div>
        </div>

        <!-- 商品图片上传 -->
        <div class="form-section">
          <h2><i class="fas fa-images"></i> 商品图片 *</h2>
          <div class="image-upload-section">
            <div class="upload-area" @click="triggerFileInput">
              <i class="fas fa-cloud-upload-alt"></i>
              <p>点击上传图片或拖拽图片到此处</p>
              <p class="upload-hint">支持JPG、PNG格式，最多5张图片</p>
              <input
                  type="file"
                  ref="fileInput"
                  @change="handleImageUpload"
                  multiple
                  accept="image/*"
                  style="display: none;"
              >
            </div>

            <div class="image-preview-container">
              <div
                  v-for="(image, index) in uploadedImages"
                  :key="index"
                  class="image-preview-item"
              >
                <img :src="image.url" :alt="`图片${index + 1}`">
                <div class="image-actions">
                  <button
                      type="button"
                      class="btn-set-main"
                      :class="{ active: image.isMain }"
                      @click="setMainImage(index)"
                      :disabled="image.isMain"
                  >
                    {{ image.isMain ? '主图' : '设为主图' }}
                  </button>
                  <button
                      type="button"
                      class="btn-remove-image"
                      @click="removeImage(index)"
                  >
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 自定义属性 -->
        <div class="form-section">
          <h2><i class="fas fa-list"></i> 自定义属性</h2>
          <div class="custom-attributes-section">
            <div
                v-for="(attr, index) in customAttributes"
                :key="index"
                class="attribute-row"
            >
              <div class="attribute-inputs">
                <input
                    type="text"
                    v-model="attr.key"
                    placeholder="属性名称（如：品牌）"
                >
                <input
                    type="text"
                    v-model="attr.value"
                    placeholder="属性值（如：苹果）"
                >
              </div>
              <button
                  type="button"
                  class="btn-remove-attr"
                  @click="removeAttribute(index)"
              >
                <i class="fas fa-minus"></i>
              </button>
            </div>

            <button
                type="button"
                class="btn-add-attr"
                @click="addAttribute"
            >
              <i class="fas fa-plus"></i> 添加属性
            </button>
          </div>
        </div>

        <!-- 提交按钮 -->
        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="goBack">
            <i class="fas fa-arrow-left"></i> 返回
          </button>
          <button
              type="submit"
              class="btn btn-primary"
              :disabled="!isFormValid"
          >
            <i class="fas fa-paper-plane"></i> 提交审核
          </button>
        </div>
      </form>
    </div>

    <!-- 通知消息 -->
    <div class="notification" :class="[notification.type, { show: notification.show }]">
      {{ notification.message }}
    </div>
  </div>
</template>

<script>
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
import {
  getCategories,
  submitProductReview,
  getProductDetail,
  updateSubmitProduct
} from '@/api/product.js'

export default {
  name: 'CompleteProductForm',
  components: {
    HomeNavbar
  },
  props: {
    productId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      categories: [], // 现在只存储一级分类
      productData: {
        title: '',
        categoryId: '', // 直接存储选中的一级分类ID
        condition: '',
        price: '',
        originalPrice: '',
        stock: 1,
        location: '',
        description: '',
        customAttributes: {}
      },
      uploadedImages: [],
      customAttributes: [
        {key: '', value: ''}
      ],
      notification: {
        show: false,
        message: '',
        type: ''
      }
    }
  },
  computed: {
    isFormValid() {
      return this.productData.title &&
          this.productData.categoryId && // 确保分类ID不为空
          this.productData.condition &&
          this.productData.price &&
          this.productData.location &&
          this.productData.description &&
          this.uploadedImages.length > 0
    }
  },
  async mounted() {
    await this.fetchCategories()
  },

  async created() {
    // 检查是否为编辑模式
    this.isEditMode = !!this.productId;

    if (this.isEditMode) {
      await this.loadProductData();
    }
  },

  methods: {
    // 加载商品数据
    async loadProductData() {
      try {
        const response = await getProductDetail(this.productId);
        const product = response.data.data;

        this.productData = {
          title: product.title || '',
          categoryId: product.category?.categoryId || '',
          condition: product.condition ? String(product.condition) : '', // 直接使用数字值
          price: product.currentPrice || '',
          originalPrice: product.originalPrice || '',
          stock: product.stock || 1,
          location: product.location || '',
          description: product.description || ''
        };

        // 填充自定义属性
        if (product.specs) {
          this.customAttributes = Object.entries(product.specs)
              .map(([key, value]) => ({key, value}));
        }

        // 填充图片
        if (product.images && Array.isArray(product.images)) {
          this.uploadedImages = product.images.map((img, index) => ({
            url: img.imageUrl || img.url,
            isMain: img.isMain || index === 0,
          }));
        }

      } catch (error) {
        this.showNotification('加载商品数据失败: ' + error.message, 'error');
      }
    },

    async fetchCategories() {
      try {
        const response = await getCategories()
        this.categories = response.data.data || []
      } catch (error) {
        this.showNotification('获取分类列表失败: ' + error.message, 'error')
      }
    },

    triggerFileInput() {
      this.$refs.fileInput.click()
    },

    setMainImage(index) {
      // 取消其他图片的主图状态
      this.uploadedImages.forEach((img, i) => {
        img.isMain = i === index
      })
    },

    removeImage(index) {
      this.uploadedImages.splice(index, 1)
      // 如果删除的是主图，设置第一张为新主图
      if (this.uploadedImages.length > 0 && !this.uploadedImages.some(img => img.isMain)) {
        this.uploadedImages[0].isMain = true
      }
    },

    addAttribute() {
      this.customAttributes.push({key: '', value: ''})
    },

    removeAttribute(index) {
      if (this.customAttributes.length > 1) {
        this.customAttributes.splice(index, 1)
      }
    },

    prepareCustomAttributes() {
      const attributes = {}
      this.customAttributes.forEach(attr => {
        if (attr.key && attr.value) {
          attributes[attr.key] = attr.value
        }
      })
      return attributes
    },

    async submitCompleteProduct() {
      // 验证必填字段
      if (!this.isFormValid) {
        this.showNotification('请填写所有必填字段', 'error')
        return
      }

      const formData = new FormData()

      // 添加商品数据
      formData.append('title', this.productData.title)
      formData.append('description', this.productData.description)
      formData.append('categoryId', String(this.productData.categoryId))
      formData.append('price', this.productData.price)
      formData.append('originalPrice', this.productData.originalPrice || '')
      formData.append('condition', this.productData.condition)
      formData.append('stock', this.productData.stock)
      formData.append('location', this.productData.location)

      // 添加自定义属性
      if (this.customAttributes) {
        formData.append('customAttributes', JSON.stringify(this.prepareCustomAttributes()))
      }

      // 添加图片文件
      const mainIndex = this.uploadedImages.findIndex(img => img.isMain)
      formData.append('mainImageIndex', mainIndex.toString())

      // 添加图片文件
      this.uploadedImages.forEach((image) => {
        if (image.file instanceof File) {
          formData.append('images', image.file)
        }
      })

      try {
        let response
        if (this.isEditMode) {
          // 编辑模式 - 调用 PUT 方法
          response = await updateSubmitProduct(this.productId, formData, {
            headers: {
              'Content-Type': 'multipart/form-data'
            }
          })
        } else {
          // 新增模式 - 调用 POST 方法
          response = await submitProductReview(formData, {
            headers: {
              'Content-Type': 'multipart/form-data'
            }
          })
        }

        if (response.data.success) {
          this.showNotification(this.isEditMode ? '商品更新成功！' : '商品已提交审核！', 'success')
          setTimeout(() => {
            this.$router.push('/seller')
          }, 1000)
        } else {
          this.showNotification('操作失败: ' + response.data.message, 'error')
        }
      } catch (error) {
        this.showNotification('操作失败: ' + error.message, 'error')
      }
    },

    handleImageUpload(event) {
      const files = Array.from(event.target.files)
      const maxImages = 5

      if (this.uploadedImages.length + files.length > maxImages) {
        this.showNotification(`最多只能上传${maxImages}张图片`, 'error')
        return
      }

      files.forEach(file => {
        if (!file.type.startsWith('image/')) {
          this.showNotification('请选择图片文件', 'error')
          return
        }

        this.uploadedImages.push({
          file: file,
          url: URL.createObjectURL(file),
          isMain: this.uploadedImages.length === 0
        })
      })
    },

    goBack() {
      this.$router.go(-1)
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
  }
}
</script>

<style scoped>
.complete-product-form {
  background-color: #f5f5f5;
  min-height: 100vh;
  padding-top: 80px;
}

.form-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.form-header {
  background: #fff;
  padding: 30px;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
  text-align: center;
  margin-bottom: 20px;
}

.form-header h1 {
  color: #3b4a30;
  margin-bottom: 10px;
  font-weight: 700;
}

.form-header h1 i {
  margin-right: 10px;
  color: var(--primary-color);
}

.form-header p {
  color: #666;
  font-size: 16px;
}

.product-form {
  background: #fff;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 12px var(--shadow-color);
  padding: 30px;
}

.form-section {
  margin-bottom: 30px;
}

.form-section h2 {
  color: #3b4a30;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border-color);
  font-weight: 700;
  display: flex;
  align-items: center;
}

.form-section h2 i {
  margin-right: 10px;
  color: var(--primary-color);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: 600;
  margin-bottom: 8px;
  color: #3b4a30;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 12px 15px;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s ease;
  background: #fff;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 120px;
}

/* 图片上传区域 */
.upload-area {
  border: 2px dashed var(--border-color);
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 20px;
  background: #fafafa;
}

.upload-area:hover {
  border-color: var(--primary-color);
  background-color: #f0f8f0;
}

.upload-area i {
  font-size: 48px;
  color: var(--primary-color);
  margin-bottom: 15px;
}

.upload-area p {
  margin: 10px 0;
  color: #666;
}

.upload-hint {
  font-size: 12px;
  color: #999;
}

.image-preview-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 15px;
}

.image-preview-item {
  position: relative;
  border: 1px solid var(--border-color);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.image-preview-item img {
  width: 100%;
  height: 120px;
  object-fit: cover;
}

.image-actions {
  display: flex;
  padding: 8px;
  background: rgba(0, 0, 0, 0.7);
}

.btn-set-main {
  flex: 1;
  background: transparent;
  color: white;
  border: none;
  padding: 6px;
  font-size: 12px;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.btn-set-main:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
}

.btn-set-main.active {
  background: var(--primary-color);
  color: white;
}

.btn-remove-image {
  background: transparent;
  color: white;
  border: none;
  padding: 6px;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.btn-remove-image:hover {
  background: var(--danger-color);
}

/* 自定义属性 */
.custom-attributes-section {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.attribute-row {
  display: flex;
  gap: 10px;
  align-items: center;
}

.attribute-inputs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  flex: 1;
}

.attribute-inputs input {
  padding: 10px 15px;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.attribute-inputs input:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
}

.btn-remove-attr {
  background: var(--danger-color);
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.btn-remove-attr:hover {
  opacity: 0.9;
  transform: scale(1.05);
}

.btn-add-attr {
  background: var(--primary-color);
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 8px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  align-self: flex-start;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-add-attr:hover {
  opacity: 0.9;
  transform: scale(1.05);
}

/* 表单操作按钮 */
.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid var(--border-color);
}

.btn-secondary {
  background: var(--secondary-color);
  color: #3b4a30;
}

.btn-secondary:hover:not(:disabled) {
  background: #e0e0e0;
  transform: translateY(-2px);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .form-container {
    padding: 10px;
  }

  .product-form {
    padding: 20px;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .attribute-row {
    flex-direction: column;
    align-items: stretch;
  }

  .attribute-inputs {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
    gap: 10px;
  }

  .form-actions .btn {
    width: 100%;
    justify-content: center;
  }

  .complete-product-form {
    padding: 10px;
  }
}
</style>
