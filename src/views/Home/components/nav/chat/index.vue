<template>
  <div class="chat-page">
    <HomeNavbar/>
    <ChatLayout />
  </div>

</template>

<script setup>
import ChatLayout from './ChatLayout.vue'
import HomeNavbar from "@/views/Home/components/HomeNavbar.vue";
</script>

<style scoped>
.chat-page { padding-top: 80px; }
</style>


