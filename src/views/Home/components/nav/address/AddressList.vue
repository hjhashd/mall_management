<template>
  <div class="address-list">
    <div v-if="addresses.length > 0">
      <div v-for="address in addresses" :key="address.addressId" class="address-item">
        <div class="address-info">
          <div class="receiver-info">
            <span class="receiver-name">{{ address.receiverName }}</span>
            <span class="receiver-phone">{{ address.receiverPhone }}</span>
            <span v-if="address.isDefault" class="default-badge">默认</span>
          </div>
          <div class="address-detail">
            {{ address.province }} {{ address.city }} {{ address.district }} {{ address.detailAddress }}
          </div>
        </div>
        <div class="address-actions">
          <button class="btn btn-outline-primary btn-sm me-2" @click="$emit('edit', address)">
            编辑
          </button>
          <button class="btn btn-outline-danger btn-sm me-2" @click="$emit('delete', address.addressId)">
            删除
          </button>
          <button v-if="!address.isDefault"
                  class="btn btn-outline-success btn-sm"
                  @click="$emit('set-default', address.addressId)">
            设为默认
          </button>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-else class="empty-state">
      <i class="fas fa-map-marker-alt fa-3x text-muted mb-3"></i>
      <p class="text-muted">您还没有添加收货地址</p>
    </div>
  </div>
</template>

<script setup>
defineProps({
  addresses: {
    type: Array,
    required: true
  }
});

defineEmits(['edit', 'delete', 'set-default']);
</script>

<style scoped>
/* 这里保留原样式中的相关部分 */
.address-item {
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  background: white;
}

.receiver-name {
  font-weight: 600;
  margin-right: 1rem;
}

.receiver-phone {
  color: var(--text-muted-color);
  margin-right: 1rem;
}

.default-badge {
  background: var(--primary-color);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
}

.address-detail {
  color: var(--text-muted-color);
  line-height: 1.5;
}

.address-actions {
  display: flex;
  gap: 0.5rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--text-muted-color);
}
</style>
