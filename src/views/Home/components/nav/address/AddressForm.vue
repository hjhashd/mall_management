<!-- src/components/AddressForm.vue -->
<template>
  <div v-if="visible" class="address-form-overlay">
    <div class="address-form">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h6 class="mb-0">{{ isEditing ? '编辑地址' : '新增地址' }}</h6>
        <button type="button" class="btn-close" @click="$emit('cancel')"></button>
      </div>
      <form @submit.prevent="handleSubmit">
        <!-- 表单内容保持不变 -->
        <div class="row">
          <div class="col-md-6">
            <div class="mb-3">
              <label class="form-label">收货人姓名 *</label>
              <input type="text" class="form-control" v-model="form.receiverName" required>
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-3">
              <label class="form-label">联系电话 *</label>
              <input type="tel" class="form-control" v-model="form.receiverPhone" required>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">省份 *</label>
              <select class="form-select" v-model="form.province" required>
                <option value="">请选择省份</option>
                <option v-for="province in provinces" :key="province" :value="province">
                  {{ province }}
                </option>
              </select>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">城市 *</label>
              <select class="form-select" v-model="form.city" required>
                <option value="">请选择城市</option>
                <option v-for="city in getCities()" :key="city" :value="city">
                  {{ city }}
                </option>
              </select>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label">区县 *</label>
              <select class="form-select" v-model="form.district" required>
                <option value="">请选择区县</option>
                <option v-for="district in getDistricts()" :key="district" :value="district">
                  {{ district }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label">详细地址 *</label>
          <textarea class="form-control" rows="3" v-model="form.detailAddress" required></textarea>
        </div>

        <div class="mb-3">
          <label class="form-label">邮政编码</label>
          <input type="text" class="form-control" v-model="form.postalCode">
        </div>

        <div class="mb-3">
          <div class="form-check">
            <input class="form-check-input" type="checkbox" v-model="form.isDefault" id="isDefault">
            <label class="form-check-label" for="isDefault">设为默认收货地址</label>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary me-2" @click="$emit('cancel')">取消</button>
          <button type="submit" class="btn btn-success" :disabled="!isValid">保存</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  visible: Boolean,
  address: {
    type: Object,
    default: () => ({})
  },
  isEditing: Boolean
});

const emit = defineEmits(['save', 'cancel']);

// 省市数据（简化版）
const provinces = ['北京市', '上海市', '广东省', '江苏省', '浙江省', '山东省', '河南省', '四川省', '湖北省', '湖南省'];
const cities = {
  '北京市': ['东城区', '西城区', '朝阳区', '丰台区', '石景山区', '海淀区', '门头沟区', '房山区', '通州区', '顺义区', '昌平区', '大兴区', '怀柔区', '平谷区', '密云区', '延庆区'],
  '上海市': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区', '奉贤区', '崇明区'],
  '广东省': ['广州市', '深圳市', '珠海市', '汕头市', '佛山市', '韶关市', '湛江市', '肇庆市', '江门市', '茂名市', '惠州市', '梅州市', '汕尾市', '河源市', '阳江市', '清远市', '东莞市', '中山市', '潮州市', '揭阳市', '云浮市'],
  '江苏省': ['南京市', '无锡市', '徐州市', '常州市', '苏州市', '南通市', '连云港市', '淮安市', '盐城市', '扬州市', '镇江市', '泰州市', '宿迁市'],
  '浙江省': ['杭州市', '宁波市', '温州市', '嘉兴市', '湖州市', '绍兴市', '金华市', '衢州市', '舟山市', '台州市', '丽水市']
};

const districts = {
  '北京市': ['东城区', '西城区', '朝阳区', '丰台区', '石景山区', '海淀区', '门头沟区', '房山区', '通州区', '顺义区', '昌平区', '大兴区', '怀柔区', '平谷区', '密云区', '延庆区'],
  '上海市': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区', '奉贤区', '崇明区'],
  '广州市': ['越秀区', '荔湾区', '海珠区', '天河区', '白云区', '黄埔区', '番禺区', '花都区', '南沙区', '从化区', '增城区'],
  '深圳市': ['罗湖区', '福田区', '南山区', '宝安区', '龙岗区', '盐田区', '龙华区', '坪山区', '光明区', '大鹏新区'],
  '南京市': ['玄武区', '秦淮区', '建邺区', '鼓楼区', '浦口区', '栖霞区', '雨花台区', '江宁区', '六合区', '溧水区', '高淳区'],
  '杭州市': ['上城区', '下城区', '江干区', '拱墅区', '西湖区', '滨江区', '萧山区', '余杭区', '富阳区', '临安区', '桐庐县', '淳安县', '建德市']
};

const form = ref({
  receiverName: '',
  receiverPhone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  postalCode: '',
  isDefault: false
});

// 监听 address prop 变化
watch(() => props.address, (newVal) => {
  if (newVal && Object.keys(newVal).length > 0) {
    form.value = { ...newVal };
  } else {
    // 重置表单
    form.value = {
      receiverName: '',
      receiverPhone: '',
      province: '',
      city: '',
      district: '',
      detailAddress: '',
      postalCode: '',
      isDefault: false
    };
  }
}, { immediate: true });

const getCities = () => {
  if (!form.value.province) return [];
  return cities[form.value.province] || [];
};

const getDistricts = () => {
  if (!form.value.city) return [];
  return districts[form.value.city] || ['其他区县'];
};

const isValid = computed(() => {
  const f = form.value;
  return f.receiverName && f.receiverPhone && f.province && f.city && f.district && f.detailAddress;
});

const handleSubmit = () => {
  const phoneRegex = /^1[3-9]\d{9}$/;
  if (!phoneRegex.test(form.value.receiverPhone)) {
    alert('请输入正确的手机号格式！');
    return;
  }
  emit('save', { ...form.value });
};
</script>

<!-- 样式部分保持不变 -->
<style scoped>
.address-form-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
}

.address-form {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  width: 95%;
  max-width: 600px;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.btn-close {
  font-size: 1.2rem;
  opacity: 0.7;
}

.btn-close:hover {
  opacity: 1;
}

.form-actions {
  text-align: right;
  margin-top: 1.5rem;
}
</style>
