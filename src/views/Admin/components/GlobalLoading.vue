<!-- src/components/GlobalLoading.vue -->
<template>
  <LoadingAnimation
      v-if="isLoading"
      :message="loadingMessage"
      :progress="loadingProgress"
  />
</template>

<script setup>
import { useLoading } from '@/services/loading.service'
import LoadingAnimation from './LoadingAnimation.vue'

const { isLoading, loadingMessage, loadingProgress } = useLoading()
</script>
