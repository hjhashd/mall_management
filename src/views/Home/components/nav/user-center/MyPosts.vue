<template>
  <div class="section">
    <h5>我的帖子</h5>
    <div class="empty">
      暂无帖子
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.section h5 {
  color: #3b4a30;
  font-weight: 700;
  border-bottom: 2px solid var(--primary-color);
  padding-bottom: 8px;
  margin-bottom: 16px;
}

.empty {
  border: 2px dashed var(--border-color);
  border-radius: 12px;
  padding: 40px 16px;
  text-align: center;
  color: #6b7a63;
  background: #fbfffb;
}
</style>
