<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-panel logistics-panel">
      <div class="modal-header">
        <h5 class="modal-title"><i class="fas fa-shipping-fast text-success me-2"></i>物流跟踪</h5>
        <button type="button" class="btn-close" @click="$emit('close')"></button>
      </div>

      <div class="modal-body">
        <div class="logistics-info mb-4">
          <div><span class="text-muted">物流公司：</span><strong>{{ shippingCompany || '-' }}</strong></div>
          <div><span class="text-muted">运单号：</span><strong>{{ trackingNumber || '-' }}</strong></div>
        </div>

        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-success" role="status"></div>
          <div class="text-muted mt-2">正在加载物流轨迹...</div>
        </div>

        <div v-else-if="tracks.length > 0" class="timeline">
          <div
              v-for="(t, idx) in tracks"
              :key="idx"
              class="timeline-item"
              :class="{ 'latest': idx === 0 }"
          >
            <div class="dot-container">
              <div class="dot"></div>
            </div>
            <div class="content">
              <div class="desc">{{ t.desc }}</div>
              <div class="time">{{ formatTime(t.time) }}</div>
              <div class="site text-muted" v-if="t.site"><i class="fas fa-map-marker-alt me-1"></i>{{ t.site }}</div>
            </div>
          </div>
        </div>

        <div v-else class="text-center text-muted py-4">
          <i class="fas fa-info-circle fa-2x mb-2"></i>
          <p>暂无物流信息</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  orderId: { type: String, required: false },
  trackingNumber: { type: String, required: false },
  shippingCompany: { type: String, required: false }
})

const loading = ref(true)
const tracks = ref([])

onMounted(async () => {
  // 模拟加载物流信息（可替换为真实API）
  loading.value = true
  setTimeout(() => {
    tracks.value = mockTracks()
    loading.value = false
  }, 800)
})

const mockTracks = () => {
  const now = Date.now()
  return [
    { time: now - 1 * 60 * 60 * 1000, desc: '包裹已到达【本市分拨中心】', site: '本市分拨中心' },
    { time: now - 4 * 60 * 60 * 1000, desc: '【转运中心】已打包，准备发往下一站', site: 'XX 转运中心' },
    { time: now - 10 * 60 * 60 * 1000, desc: '【始发站】快件已揽收', site: '卖家揽件网点' },
    { time: now - 24 * 60 * 60 * 1000, desc: '订单已生成，等待快递员揽收', site: '' }
  ]
}

const formatTime = (t) => {
  const d = new Date(t)
  return d.toLocaleString('zh-CN')
}
</script>

<style scoped>
.logistics-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display:flex; align-items:center; justify-content:center; z-index:1050; }
.logistics-panel { background:#fff; width:92%; max-width:640px; border-radius:12px; padding:1rem 1.25rem; box-shadow:0 10px 30px rgba(0,0,0,0.2); }
.timeline { position: relative; padding-left: 18px; }
.timeline:before { content:''; position:absolute; left:9px; top:0; bottom:0; width:2px; background:#e5e5e5; }
.timeline-item { position: relative; padding: 8px 0 8px 8px; }
.timeline-item .dot { position:absolute; left:3px; top:12px; width:12px; height:12px; border-radius:50%; background:#28a745; }
.timeline-item .content { margin-left: 10px; }
.timeline-item .time { font-weight:600; margin-bottom: 2px; }
.timeline-item .desc { color:#333; }
</style>
