<template>
  <!--
    The main row container.
    - It uses flexbox for alignment.
    - The 'self' class triggers the layout reversal.
    - The contextmenu event is bound here, only active for self-messages.
  -->
  <div
      class="chat-row"
      :class="{ self: isSelf }"
      @contextmenu.prevent="isSelf && showContextMenu($event)"
  >
    <!--
      Avatar Container.
      The HTML order is always Avatar -> Bubble.
      CSS (`flex-direction: row-reverse`) will handle flipping the visual order for self-messages.
      This is a robust, CSS-driven approach.
    -->
    <div class="avatar-container">
      <div
          class="avatar"
          :style="{
          backgroundImage: avatarUrl ? `url(${avatarUrl})` : 'none',
        }"
      >
        <span v-if="!avatarUrl" class="initial">{{ initial }}</span>
      </div>
    </div>

    <!-- Bubble Container -->
    <div class="bubble-container">
      <div class="bubble" :class="bubbleClass">
        <!-- Image Message -->
        <template v-if="message.messageType === 2 && message.attachmentUrl">
          <img :src="message.attachmentUrl" alt="image" class="image" />
          <div v-if="message.content" class="text image-caption">
            {{ message.content }}
          </div>
        </template>

        <!-- Card Message (Placeholder) -->
        <template v-else-if="message.messageType === 3">
          <div class="card">
            <div class="thumb"></div>
            <div class="card-info">
              <div class="title">商品卡片</div>
              <div class="desc">点击查看详情</div>
            </div>
          </div>
        </template>

        <!-- Standard Text Message -->
        <template v-else>
          <div class="text">{{ message.content }}</div>
        </template>

        <!-- MODIFICATION: Meta info (time, read status) has been removed from here -->
      </div>
    </div>

    <!--
      Context Menu for Deletion.
      It's positioned based on the right-click coordinates.
      This provides a clean and modern way to handle actions.
    -->
    <div
        v-if="contextMenu.visible"
        class="context-menu"
        :style="{ top: contextMenu.y + 'px', left: contextMenu.x + 'px' }"
    >
      <button @click="requestDelete">
        <i class="fas fa-trash-alt"></i> 删除
      </button>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
        v-if="showDeleteConfirm"
        class="modal-overlay"
        @click.self="showDeleteConfirm = false"
    >
      <div class="modal-content">
        <p>确定要删除这条消息吗？</p>
        <div class="modal-actions">
          <button class="btn-cancel" @click="showDeleteConfirm = false">
            取消
          </button>
          <button class="btn-confirm" @click="handleDelete">删除</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from "vue";
import { useUserStore } from "@/stores/userStore";

const userStore = useUserStore();
const props = defineProps({
  message: { type: Object, required: true },
  isSelf: { type: Boolean, default: false },
  currentUserAvatar: { type: String, default: "" },
});

const emit = defineEmits(["delete-message"]);

const showDeleteConfirm = ref(false);
const contextMenu = ref({ visible: false, x: 0, y: 0 });

// --- Computed Properties ---

// Determines which avatar to show based on whether it's a self-message
const avatarUrl = computed(() => {
  return props.isSelf ? props.currentUserAvatar : props.message.senderAvatar;
});

// Generates a fallback initial from the sender's name
const initial = computed(() => {
  const name = props.isSelf
      ? userStore.userInfo?.name || "我"
      : props.message.senderName;
  return name ? name.charAt(0).toUpperCase() : "?";
});

// Assigns CSS class for bubble styling
const bubbleClass = computed(() => (props.isSelf ? "mine" : "theirs"));

// MODIFICATION: timeText and readText computed properties are removed as they are no longer displayed here.

// --- Methods ---

// Emits the delete event to the parent component
function handleDelete() {
  emit("delete-message", props.message.messageId);
  showDeleteConfirm.value = false;
}

// Shows the context menu at the cursor's position
function showContextMenu(event) {
  contextMenu.value = {
    visible: true,
    x: event.clientX,
    y: event.clientY,
  };
}

// Hides the context menu
function hideContextMenu() {
  contextMenu.value = false;
}

// Triggers the delete confirmation modal from the context menu
function requestDelete() {
  hideContextMenu();
  showDeleteConfirm.value = true;
}

// --- Lifecycle Hooks ---

// Add a global click listener to close the context menu when clicking away
onMounted(() => {
  window.addEventListener("click", hideContextMenu);
});

// Clean up the global listener when the component is destroyed
onBeforeUnmount(() => {
  window.removeEventListener("click", hideContextMenu);
});
</script>

<style scoped>
/* IMPORTANT: All styles are now self-contained and use hard-coded values.
  This component will no longer be affected by global CSS variables or stylesheets.
*/

.chat-row {
  display: flex;
  align-items: flex-end;
  margin-bottom: 16px;
  gap: 12px;
  animation: fadeInUp 0.3s ease-out forwards;
}

/* This is the "foolproof" method for layout reversal.
  It reverses the order of flex items, moving the avatar to the right.
*/
.chat-row.self {
  flex-direction: row-reverse;
}

.avatar-container {
  flex-shrink: 0;
  width: 42px;
  height: 42px;
}

.avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background-color: #f0f0f0;
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #555;
  font-weight: bold;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
}

.initial {
  font-size: 16px;
}

.bubble-container {
  max-width: 70%;
}

.bubble {
  padding: 12px 16px;
  border-radius: 18px;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
  animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
  opacity: 0;
  transform: scale(0.95);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.bubble:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

/* Hard-coded style for self-message bubble (WeChat Green) */
.bubble.mine {
  background-color: #a0e75a;
  color: #000000;
  border-bottom-right-radius: 6px;
}

/* Hard-coded style for peer's message bubble (White) */
.bubble.theirs {
  background-color: #ffffff;
  color: #000000;
  border: 1px solid #eef2f7;
  border-bottom-left-radius: 6px;
}

.text {
  white-space: pre-wrap;
  line-height: 1.6;
  font-size: 15px;
  word-wrap: break-word;
}

.image {
  max-width: 240px;
  border-radius: 14px;
  display: block;
  cursor: pointer;
}

/* MODIFICATION: The .meta class is removed as it's no longer in the template */

/* Context Menu Styles */
.context-menu {
  position: fixed;
  z-index: 1001;
  background: #ffffff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 6px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  animation: fadeIn 0.1s ease;
}

.context-menu button {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  padding: 8px 12px;
  border: none;
  background: none;
  text-align: left;
  cursor: pointer;
  border-radius: 6px;
  color: #333;
  transition: background-color 0.2s ease, color 0.2s ease;
  font-size: 14px;
}

.context-menu button:hover {
  background-color: #f5f5f5;
  color: #d93025; /* Red color for delete action on hover */
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: white;
  padding: 24px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}
.modal-content p {
  margin: 0 0 20px;
  font-size: 16px;
}
.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}
.modal-actions button {
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: 600;
}
.btn-cancel {
  background-color: #e4e6eb;
  color: #050505;
}
.btn-confirm {
  background-color: #d93025;
  color: white;
}

/* Animations */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
@keyframes popIn {
  to {
    opacity: 1;
    transform: scale(1);
  }
}
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
</style>
