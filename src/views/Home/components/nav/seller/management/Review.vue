<template>
  <a-card :bordered="false" class="review-form-card">
    <!-- 页面头部 -->
    <div class="page-header">
      <a-button @click="goBack">
        <template #icon><ArrowLeftOutlined /></template>
        返回列表
      </a-button>
      <div class="header-title-container">
        <h2 class="header-title">{{ isEditMode ? '编辑商品' : '添加新商品' }}</h2>
        <p class="header-subtitle">请仔细填写商品信息，带 * 为必填项</p>
      </div>
    </div>

    <!-- 表单主体 -->
    <a-form
        ref="formRef"
        :model="productData"
        :rules="formRules"
        layout="vertical"
        @finish="submitCompleteProduct"
    >
      <!-- 基本信息 -->
      <a-card title="基本信息" :bordered="false" class="form-section-card">
        <a-row :gutter="24">
          <a-col :xs="24" :md="12">
            <a-form-item label="商品标题" name="title">
              <a-input v-model:value="productData.title" placeholder="请输入商品标题" />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="12">
            <a-form-item label="商品分类" name="categoryId">
              <a-select v-model:value="productData.categoryId" placeholder="请选择分类">
                <a-select-option
                    v-for="category in categories"
                    :key="category.categoryId"
                    :value="category.categoryId"
                >
                  {{ category.categoryName }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="12">
            <a-form-item label="当前售价 (元)" name="price">
              <a-input-number v-model:value="productData.price" style="width: 100%" :min="0" :precision="2" placeholder="请输入当前售价" />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="12">
            <a-form-item label="原价 (元)" name="originalPrice">
              <a-input-number v-model:value="productData.originalPrice" style="width: 100%" :min="0" :precision="2" placeholder="请输入原价（可选）" />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="12">
            <a-form-item label="商品成色" name="condition">
              <a-select v-model:value="productData.condition" placeholder="请选择成色">
                <a-select-option value="1">全新</a-select-option>
                <a-select-option value="2">95新</a-select-option>
                <a-select-option value="3">9成新</a-select-option>
                <a-select-option value="4">8成新</a-select-option>
                <a-select-option value="5">7成新及以下</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="12">
            <a-form-item label="库存数量" name="stock">
              <a-input-number v-model:value="productData.stock" style="width: 100%" :min="1" placeholder="请输入库存数量" />
            </a-form-item>
          </a-col>
          <a-col :xs="24">
            <a-form-item label="商品位置" name="location">
              <a-input v-model:value="productData.location" placeholder="请输入商品所在地区" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-card>

      <!-- 商品描述 -->
      <a-card title="商品描述" :bordered="false" class="form-section-card">
        <a-form-item name="description">
          <a-textarea v-model:value="productData.description" placeholder="请详细描述商品信息，例如品牌、型号、购买年份、瑕疵等..." :rows="6" />
        </a-form-item>
      </a-card>

      <!-- 商品图片 -->
      <a-card title="商品图片" :bordered="false" class="form-section-card">
        <a-form-item name="images">
          <a-upload
              v-model:file-list="fileList"
              list-type="picture-card"
              :before-upload="() => false"
              @preview="handlePreview"
              @change="handleFileChange"
          >
            <div v-if="fileList.length < 5">
              <PlusOutlined />
              <div style="margin-top: 8px">上传图片</div>
            </div>
          </a-upload>
          <p class="upload-hint">最多上传5张图片，拖动可排序，第一张将作为主图。</p>
        </a-form-item>
      </a-card>

      <!-- =============================================================== -->
      <!-- 开始: 添加自定义属性 -->
      <!-- =============================================================== -->
      <a-card title="自定义属性 (商品规格)" :bordered="false" class="form-section-card">
        <a-space v-for="(attr, index) in customAttributes" :key="index" class="attribute-row" align="baseline">
          <a-input v-model:value="attr.key" placeholder="属性名 (如: 品牌)" />
          <a-input v-model:value="attr.value" placeholder="属性值 (如: 苹果)" />
          <MinusCircleOutlined class="dynamic-delete-button" @click="removeAttribute(index)" />
        </a-space>
        <a-button type="dashed" style="width: 100%; margin-top: 16px" @click="addAttribute">
          <PlusOutlined /> 添加属性
        </a-button>
      </a-card>
      <!-- =============================================================== -->
      <!-- 结束: 添加自定义属性 -->
      <!-- =============================================================== -->

      <!-- 提交区域 -->
      <div class="form-actions">
        <a-space>
          <a-button @click="goBack">取消</a-button>
          <a-button type="primary" html-type="submit" :loading="isSubmitting">
            {{ isEditMode ? '保存修改' : '提交审核' }}
          </a-button>
        </a-space>
      </div>
    </a-form>

    <a-modal :open="previewVisible" :title="previewTitle" :footer="null" @cancel="handleCancel">
      <img alt="example" style="width: 100%" :src="previewImage" />
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, reactive, watch, computed, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { ArrowLeftOutlined, PlusOutlined, MinusCircleOutlined } from '@ant-design/icons-vue';
import {
  getCategories,
  submitProductReview,
  getProductDetail,
  updateSubmitProduct
} from '@/api/product.js';

// --- Props and Emits ---
const props = defineProps({
  productId: {
    type: String,
    default: null
  }
});
const emit = defineEmits(['backToList']);

// --- Component State ---
const formRef = ref();
const isEditMode = computed(() => !!props.productId);
const isSubmitting = ref(false);
const categories = ref([]);
const productData = reactive({
  title: '',
  categoryId: null,
  condition: null,
  price: null,
  originalPrice: null,
  stock: 1,
  location: '',
  description: '',
});
// ===============================================================
// 1. 添加自定义属性的状态
// ===============================================================
const customAttributes = ref([{ key: '', value: '' }]);

// --- Form Rules ---
const formRules = {
  title: [{ required: true, message: '请输入商品标题', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择商品分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入当前售价', trigger: 'blur', type: 'number' }],
  condition: [{ required: true, message: '请选择商品成色', trigger: 'change' }],
  stock: [{ required: true, message: '请输入库存数量', trigger: 'blur', type: 'number' }],
  location: [{ required: true, message: '请输入商品位置', trigger: 'blur' }],
  description: [{ required: true, message: '请输入商品描述', trigger: 'blur' }],
  images: [{
    required: true,
    message: '请至少上传一张图片',
    validator: () => fileList.value.length > 0 ? Promise.resolve() : Promise.reject('请至少上传一张图片')
  }],
};

// --- Image Upload State & Logic ---
const fileList = ref([]);
const previewVisible = ref(false);
const previewImage = ref('');
const previewTitle = ref('');
const getBase64 = (file) =>
    new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
    });
const handleCancel = () => { previewVisible.value = false; };
const handlePreview = async (file) => {
  if (!file.url && !file.preview) {
    file.preview = await getBase64(file.originFileObj);
  }
  previewImage.value = file.url || file.preview;
  previewVisible.value = true;
  previewTitle.value = file.name || file.url.substring(file.url.lastIndexOf('/') + 1);
};
const handleFileChange = ({ fileList: newFileList }) => {
  fileList.value = newFileList.slice(-5);
};

// ===============================================================
// 2. 添加/删除自定义属性的方法
// ===============================================================
const addAttribute = () => {
  customAttributes.value.push({ key: '', value: '' });
};
const removeAttribute = (index) => {
  customAttributes.value.splice(index, 1);
};

// --- Core Logic ---
const goBack = () => {
  emit('backToList');
};

const resetForm = () => {
  formRef.value?.resetFields();
  Object.assign(productData, {
    title: '', categoryId: null, condition: null, price: null,
    originalPrice: null, stock: 1, location: '', description: '',
  });
  fileList.value = [];
  customAttributes.value = [{ key: '', value: '' }]; // 重置自定义属性
};

const loadProductData = async (id) => {
  try {
    const response = await getProductDetail(id);
    const product = response.data.data;

    Object.assign(productData, {
      title: product.title || '',
      categoryId: product.category?.categoryId || null,
      condition: product.condition ? String(product.condition) : null,
      price: product.currentPrice || null,
      originalPrice: product.originalPrice || null,
      stock: product.stock || 1,
      location: product.location || '',
      description: product.description || '',
    });

    if (product.images?.length) {
      fileList.value = product.images.map((img, index) => ({
        uid: -index, name: `image_${index}.png`, status: 'done', url: img.imageUrl || img.url,
      }));
    }

    // 3. 加载自定义属性
    if (product.specs && Object.keys(product.specs).length > 0) {
      customAttributes.value = Object.entries(product.specs).map(([key, value]) => ({ key, value }));
    } else {
      customAttributes.value = [{ key: '', value: '' }];
    }

  } catch (error) {
    message.error('加载商品数据失败: ' + error.message);
  }
};

const submitCompleteProduct = async () => {
  isSubmitting.value = true;
  const formData = new FormData();

  Object.entries(productData).forEach(([key, value]) => {
    if (value !== null && value !== '') formData.append(key, value);
  });

  // 4. 准备并添加自定义属性到 FormData
  const preparedAttributes = customAttributes.value
      .filter(attr => attr.key.trim() && attr.value.trim())
      .reduce((obj, attr) => {
        obj[attr.key.trim()] = attr.value.trim();
        return obj;
      }, {});
  formData.append('customAttributes', JSON.stringify(preparedAttributes));

  const uploadedImageUrls = [];
  fileList.value.forEach(file => {
    if (file.originFileObj) formData.append('images', file.originFileObj);
    else if(file.url) uploadedImageUrls.push(file.url);
  });
  formData.append('existingImages', JSON.stringify(uploadedImageUrls));
  formData.append('mainImageIndex', '0');

  try {
    let response;
    if (isEditMode.value) {
      response = await updateSubmitProduct(props.productId, formData);
    } else {
      response = await submitProductReview(formData);
    }
    if (response.data.success) {
      message.success(isEditMode.value ? '商品更新成功！' : '商品已提交审核！');
      emit('backToList');
    } else {
      message.error('操作失败: ' + response.data.message);
    }
  } catch (error) {
    message.error('操作出现异常: ' + (error.response?.data?.message || error.message));
  } finally {
    isSubmitting.value = false;
  }
};

// --- Lifecycle ---
onMounted(async () => {
  try {
    const response = await getCategories();
    categories.value = response.data.data || [];
  } catch (error) { message.error('获取分类列表失败'); }
});

watch(() => props.productId, (newId) => {
  resetForm();
  if (newId) loadProductData(newId);
}, { immediate: true });
</script>

<style scoped>
.review-form-card {
  background-color: #ffffff;
}
.page-header {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 24px;
  padding: 4px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 16px;
}
.header-title-container {
  flex-grow: 1;
}
.header-title {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  line-height: 1.2;
}
.header-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 4px 0 0;
}

.form-section-card {
  margin-bottom: 24px;
  border: 1px solid #f0f0f0;
  border-radius: 8px !important;
}
.form-section-card :deep(.ant-card-head) {
  background-color: #fafafa;
  border-bottom: 1px solid #f0f0f0;
  font-weight: 600;
}
.form-section-card :deep(.ant-card-body) {
  padding-top: 24px;
}

.upload-hint {
  color: #999;
  font-size: 12px;
  margin-top: 8px;
}

.attribute-row {
  display: flex;
  width: 100%;
  gap: 8px;
  margin-bottom: 8px;
}
.dynamic-delete-button {
  cursor: pointer;
  position: relative;
  top: 4px;
  font-size: 24px;
  color: #999;
  transition: all 0.3s;
}
.dynamic-delete-button:hover {
  color: #777;
}

.form-actions {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
  text-align: right;
  background-color: #fff;
  position: sticky;
  bottom: 0;
  padding-right: 24px;
  margin-right: -24px;
  margin-left: -24px;
  margin-bottom: -24px;
}
</style>

