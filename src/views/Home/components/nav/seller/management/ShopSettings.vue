<template>
  <div class="shop-settings-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">店铺设置</h1>
      <a-button type="primary" size="large" @click="handleSave" :loading="saving || loadingData">
        保存更改
      </a-button>
    </div>

    <a-spin :spinning="loadingData" tip="正在加载店铺数据...">
      <!-- 表单内容 -->
      <a-form :model="formState" layout="vertical">
        <!-- 基本信息卡片 -->
        <a-card title="基本信息" class="setting-card">
          <a-row :gutter="24">
            <a-col :span="12">
              <a-form-item label="店铺名称" name="shopName" required>
                <a-input v-model:value="formState.shopName" placeholder="请输入您的店铺名称" />
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="店铺地址或所在地区" name="location">
                <a-input v-model:value="formState.location" placeholder="例如：广东省深圳市" />
              </a-form-item>
            </a-col>
          </a-row>
          <a-form-item label="店铺简介" name="description">
            <a-textarea v-model:value="formState.description" :rows="4" placeholder="向您的客户介绍一下店铺的特色" />
          </a-form-item>
          <a-form-item label="店铺公告" name="announcement">
            <a-textarea v-model:value="formState.announcement" :rows="3" placeholder="例如：本店活动，满199减20！" />
          </a-form-item>
        </a-card>

        <!-- 店铺展示卡片 -->
        <a-card title="店铺展示" class="setting-card">
          <a-row :gutter="24">
            <a-col :span="12">
              <a-form-item label="店铺Logo" name="logoUrl">
                <a-upload
                    name="logo"
                    list-type="picture-card"
                    class="avatar-uploader"
                    :show-upload-list="false"
                    :customRequest="handleLogoUpload"
                >
                  <img v-if="formState.logoUrl" :src="formState.logoUrl" alt="logo" style="width: 100%" />
                  <div v-else>
                    <loading-outlined v-if="logoLoading"></loading-outlined>
                    <plus-outlined v-else></plus-outlined>
                    <div class="ant-upload-text">上传Logo</div>
                  </div>
                </a-upload>
                <p class="upload-tip">推荐尺寸：1:1, 例如 200x200px</p>
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="店铺横幅 (Banner)" name="bannerUrl">
                <a-upload
                    name="banner"
                    list-type="picture-card"
                    class="banner-uploader"
                    :show-upload-list="false"
                    :customRequest="handleBannerUpload"
                >
                  <img v-if="formState.bannerUrl" :src="formState.bannerUrl" alt="banner" style="width: 100%" />
                  <div v-else>
                    <loading-outlined v-if="bannerLoading"></loading-outlined>
                    <plus-outlined v-else></plus-outlined>
                    <div class="ant-upload-text">上传横幅</div>
                  </div>
                </a-upload>
                <p class="upload-tip">推荐尺寸：3:1, 例如 1200x400px</p>
              </a-form-item>
            </a-col>
          </a-row>
        </a-card>

        <!-- 联系方式与营业时间 -->
        <a-card title="联系方式与营业时间" class="setting-card">
          <a-row :gutter="24">
            <a-col :span="12">
              <a-form-item label="联系电话" name="contactPhone">
                <a-input v-model:value="formState.contactPhone" placeholder="请输入客服电话" />
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="联系邮箱" name="contactEmail">
                <a-input v-model:value="formState.contactEmail" placeholder="请输入客服邮箱" />
              </a-form-item>
            </a-col>
          </a-row>
          <a-form-item label="营业时间">
            <!-- [OPTIMIZATION] Changed to multi-select for days -->
            <div v-for="(hour, index) in formState.businessHours" :key="index" class="business-hour-item">
              <a-select
                  v-model:value="hour.days"
                  mode="multiple"
                  placeholder="选择星期 (可多选)"
                  style="width: 220px"
                  :options="weekdaysOptions"
              >
              </a-select>
              <a-input v-model:value="hour.time" placeholder="例如: 9:00 - 18:00" style="margin: 0 8px; flex-grow: 1;" />
              <a-button type="dashed" danger @click="removeBusinessHour(index)">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </div>
            <a-button type="dashed" @click="addBusinessHour" style="width: 100%;">
              <template #icon><PlusOutlined /></template>
              添加时间段
            </a-button>
          </a-form-item>
        </a-card>

        <!-- 服务政策 -->
        <a-card title="服务政策" class="setting-card">
          <a-form-item label="物流政策" name="logisticsPolicy">
            <a-textarea v-model:value="formState.logisticsPolicy" :rows="3" />
          </a-form-item>
          <a-form-item label="售后服务政策" name="afterSalePolicy">
            <a-textarea v-model:value="formState.afterSalePolicy" :rows="3" />
          </a-form-item>
          <a-form-item label="保障服务政策" name="guaranteePolicy">
            <a-textarea v-model:value="formState.guaranteePolicy" :rows="3" />
          </a-form-item>
        </a-card>

      </a-form>
    </a-spin>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined, LoadingOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { getShopSettings, updateShopSettings, uploadShopLogo, uploadShopBanner } from '@/api/shop';

const loadingData = ref(true);
const saving = ref(false);
const logoLoading = ref(false);
const bannerLoading = ref(false);

const weekdaysOptions = [
  { value: '周一', label: '周一' },
  { value: '周二', label: '周二' },
  { value: '周三', label: '周三' },
  { value: '周四', label: '周四' },
  { value: '周五', label: '周五' },
  { value: '周六', label: '周六' },
  { value: '周日', label: '周日' },
];

const formState = reactive({
  shopName: '',
  logoUrl: '',
  bannerUrl: '',
  description: '',
  location: '',
  contactPhone: '',
  contactEmail: '',
  logisticsPolicy: '',
  afterSalePolicy: '',
  guaranteePolicy: '',
  announcement: '',
  // [OPTIMIZATION] Changed data structure to support multi-day selection
  businessHours: [], // e.g., [{ days: ['周一', '周二'], time: '09:00-18:00' }]
});

onMounted(() => {
  fetchShopSettings();
});

const fetchShopSettings = async () => {
  loadingData.value = true;
  try {
    const res = await getShopSettings();
    // Corrected: Access the nested data structure, e.g., res.data.success and res.data.data
    if (res.data.success && res.data.data) {
      const backendData = res.data.data;

      // [OPTIMIZATION] Group days by time from backend data
      const hoursMap = backendData.businessHours || {};
      const groupedByTime = Object.entries(hoursMap).reduce((acc, [day, time]) => {
        if (!acc[time]) {
          acc[time] = [];
        }
        acc[time].push(day);
        return acc;
      }, {});

      const businessHoursArray = Object.entries(groupedByTime).map(([time, days]) => ({ days, time }));

      Object.assign(formState, { ...backendData, businessHours: businessHoursArray });
      message.success('店铺数据加载成功！');
    } else {
      message.error(res.data.message || '获取店铺信息失败');
    }
  } catch (error) {
    console.error('获取店铺设置失败:', error);
    message.error('网络错误，获取店铺设置失败');
  } finally {
    loadingData.value = false;
  }
};

const handleSave = async () => {
  saving.value = true;
  try {
    // [OPTIMIZATION] Expand the grouped days back into a flat map for the backend
    const businessHoursMap = formState.businessHours.reduce((acc, curr) => {
      if (curr.days && curr.days.length > 0 && curr.time) {
        curr.days.forEach(day => {
          acc[day] = curr.time;
        });
      }
      return acc;
    }, {});

    const payload = { ...formState, businessHours: businessHoursMap };

    const res = await updateShopSettings(payload);
    // Corrected: Access the nested data structure
    if (res.data.success) {
      message.success('店铺信息已成功保存！');
    } else {
      message.error(res.data.message || '保存失败');
    }
  } catch (error) {
    console.error('保存店铺设置失败:', error);
    message.error('网络错误，保存店铺设置失败');
  } finally {
    saving.value = false;
  }
};

// --- Business Hours Logic ---
const addBusinessHour = () => {
  formState.businessHours.push({ days: [], time: '' });
};

const removeBusinessHour = (index) => {
  formState.businessHours.splice(index, 1);
};

// --- Image Upload Logic ---
const handleLogoUpload = async ({ file }) => {
  logoLoading.value = true;
  const formData = new FormData();
  formData.append('file', file);

  try {
    const res = await uploadShopLogo(formData);
    // Corrected: Access the nested data structure
    if (res.data.success) {
      formState.logoUrl = res.data.data;
      message.success('Logo 上传成功');
    } else {
      message.error(res.data.message || 'Logo 上传失败');
    }
  } catch (error) {
    message.error('Logo 上传失败: 网络错误');
  } finally {
    logoLoading.value = false;
  }
};

const handleBannerUpload = async ({ file }) => {
  bannerLoading.value = true;
  const formData = new FormData();
  formData.append('file', file);

  try {
    const res = await uploadShopBanner(formData);
    // Corrected: Access the nested data structure
    if (res.data.success) {
      formState.bannerUrl = res.data.data;
      message.success('Banner 上传成功');
    } else {
      message.error(res.data.message || 'Banner 上传失败');
    }
  } catch (error) {
    message.error('Banner 上传失败: 网络错误');
  } finally {
    bannerLoading.value = false;
  }
};
</script>

<style scoped>
.shop-settings-container {
  max-width: 1000px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}

.setting-card {
  margin-bottom: 24px;
  border-radius: 8px;
}

.avatar-uploader > .ant-upload,
.banner-uploader > .ant-upload {
  width: 128px;
  height: 128px;
}

.banner-uploader > .ant-upload {
  width: 256px;
  height: 85px; /* 3:1 ratio */
}

.ant-upload-select-picture-card i {
  font-size: 32px;
  color: #999;
}

.ant-upload-select-picture-card .ant-upload-text {
  margin-top: 8px;
  color: #666;
}

.upload-tip {
  color: #999;
  font-size: 12px;
  line-height: 1.5;
  margin-top: 8px;
}

.business-hour-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}
</style>

