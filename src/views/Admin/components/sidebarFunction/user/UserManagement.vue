<template>
  <div class="user-management-container animate-fade-in">
    <!-- 用户统计卡片区域 -->
    <div class="stats-grid">
      <div class="stat-card animate-slide-up" style="--delay: 0.1s;">
        <div class="card-icon icon-total">
          <i class="fas fa-users"></i>
        </div>
        <div class="card-content">
          <p class="card-title">总用户数</p>
          <h2 class="card-value">{{ pagination.total }}</h2>
          <span class="card-trend">
            <i class="fas fa-database"></i> 全部用户
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.2s;">
        <div class="card-icon icon-active">
          <i class="fas fa-user-check"></i>
        </div>
        <div class="card-content">
          <p class="card-title">活跃用户</p>
          <h2 class="card-value">{{ stats.active }}</h2>
          <span class="card-trend positive">
            <i class="fas fa-arrow-up"></i> 正常状态
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.3s;">
        <div class="card-icon icon-inactive">
          <i class="fas fa-user-times"></i>
        </div>
        <div class="card-content">
          <p class="card-title">禁用用户</p>
          <h2 class="card-value">{{ stats.inactive }}</h2>
          <span class="card-trend negative">
            <i class="fas fa-ban"></i> 已禁用
          </span>
        </div>
      </div>
      <div class="stat-card animate-slide-up" style="--delay: 0.4s;">
        <div class="card-icon icon-seller">
          <i class="fas fa-store"></i>
        </div>
        <div class="card-content">
          <p class="card-title">商家用户</p>
          <h2 class="card-value">{{ stats.sellers }}</h2>
          <span class="card-trend">
            <i class="fas fa-shopping-bag"></i> 商家认证
          </span>
        </div>
      </div>
    </div>

    <!-- 头部：标题和操作区 -->
    <div class="header-bar">
      <h1 class="page-title">用户列表</h1>
      <div class="actions-group">
        <div class="search-box">
          <i class="fas fa-search search-icon"></i>
          <input type="text" v-model="searchQuery" placeholder="实时搜索用户名或邮箱...">
        </div>
        <button @click="openModal('add')" class="add-user-btn">
          <i class="fas fa-plus"></i>
          <span>添加用户</span>
        </button>
      </div>
    </div>

    <!-- 用户列表表格 -->
    <div class="user-table-card">
      <table class="user-table">
        <thead>
        <tr>
          <th>用户信息</th>
          <th>信用分</th>
          <th>角色</th>
          <th>状态</th>
          <th>注册时间</th>
          <th>最后登录</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="loading">
          <td colspan="7" class="empty-state">
            <i class="fas fa-spinner fa-spin"></i>
            <p>正在加载数据...</p>
          </td>
        </tr>
        <tr v-else-if="users.length === 0">
          <td colspan="7" class="empty-state">
            <i class="fas fa-ghost"></i>
            <p>没有找到匹配的用户</p>
          </td>
        </tr>
        <tr v-for="user in users" :key="user.userId" class="user-row">
          <!-- 用户信息 -->
          <td>
            <div class="user-info-cell">
              <img :src="user.avatarPath" alt="avatar" class="avatar" @error="onAvatarError">
              <div class="user-details">
                <span class="username">{{ user.username }}</span>
                <span class="email">{{ user.email }}</span>
              </div>
            </div>
          </td>
          <!-- 信用分 -->
          <td>
            <div class="credit-score-cell">
                <span class="score-value" :style="{ color: getCreditScoreColor(user.creditScore) }">
                  {{ user.creditScore }}
                </span>
              <div class="score-bar-bg">
                <div class="score-bar-fg" :style="{ width: user.creditScore + '%', backgroundColor: getCreditScoreColor(user.creditScore) }"></div>
              </div>
            </div>
          </td>
          <!-- 角色 -->
          <td>
              <span class="role-badge" :class="user.isSeller ? 'role-seller' : 'role-user'">
                {{ user.isSeller ? '商家' : '普通用户' }}
              </span>
          </td>
          <!-- 状态 -->
          <td>
            <div class="status-toggle-wrapper" @click="toggleUserStatus(user)">
              <div class="toggle-switch" :class="{ 'is-enabled': user.enabled }">
                <div class="toggle-handle"></div>
              </div>
              <span class="status-text" :class="{ 'is-enabled': user.enabled }">
                  {{ user.enabled ? '正常' : '禁用' }}
                </span>
            </div>
          </td>
          <!-- 注册时间 -->
          <td>{{ formatDate(user.createdAt) }}</td>
          <!-- 最后登录 -->
          <td>{{ formatDate(user.lastLogin) }}</td>
          <!-- 操作 -->
          <td>
            <div class="action-buttons">
              <button class="action-btn btn-edit" @click="openModal('edit', user)"><i class="fas fa-pencil-alt"></i></button>
              <button class="action-btn" :class="user.enabled ? 'btn-disable' : 'btn-enable'" @click="toggleUserStatus(user)">
                <i :class="user.enabled ? 'fas fa-lock' : 'fas fa-unlock'"></i>
              </button>
              <button class="action-btn btn-delete" @click="openConfirmModal(user)"><i class="fas fa-trash-alt"></i></button>
            </div>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

    <!-- 分页控件 -->
    <div class="pagination-controls" v-if="totalPages > 1">
      <button @click="changePage(pagination.currentPage - 1)" :disabled="pagination.currentPage <= 1">
        <i class="fas fa-chevron-left"></i>
      </button>
      <span>第 {{ pagination.currentPage }} / {{ totalPages }} 页</span>
      <button @click="changePage(pagination.currentPage + 1)" :disabled="pagination.currentPage >= totalPages">
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>

    <!-- 新增/编辑用户模态框 -->
    <transition name="modal-fade">
      <div v-if="isModalVisible" class="modal-overlay" @click.self="closeModal">
        <div class="modal-content animate-scale-up">
          <h2 class="modal-title">{{ modalMode === 'add' ? '添加新用户' : '编辑用户信息' }}</h2>
          <form @submit.prevent="handleFormSubmit">
            <div class="form-grid">
              <!-- 用户名 -->
              <div class="form-group">
                <label for="username">用户名</label>
                <div class="input-wrapper">
                  <i class="fas fa-user"></i>
                  <input id="username" type="text" v-model="editableUser.username" :disabled="modalMode === 'edit'" required>
                </div>
              </div>
              <!-- 邮箱 -->
              <div class="form-group">
                <label for="email">邮箱</label>
                <div class="input-wrapper">
                  <i class="fas fa-envelope"></i>
                  <input id="email" type="email" v-model="editableUser.email" required>
                </div>
              </div>
              <!-- 密码 (仅添加模式) -->
              <div class="form-group" v-if="modalMode === 'add'">
                <label for="password">密码</label>
                <div class="input-wrapper">
                  <i class="fas fa-key"></i>
                  <input id="password" type="password" v-model="editableUser.password" required>
                </div>
              </div>
              <!-- 手机号 -->
              <div class="form-group">
                <label for="phone">手机号</label>
                <div class="input-wrapper">
                  <i class="fas fa-phone"></i>
                  <input id="phone" type="text" v-model="editableUser.phone">
                </div>
              </div>
              <!-- 信用分 -->
              <div class="form-group">
                <label for="creditScore">信用分</label>
                <div class="input-wrapper">
                  <i class="fas fa-shield-alt"></i>
                  <input id="creditScore" type="number" v-model="editableUser.creditScore" min="0" max="100">
                </div>
              </div>
              <!-- 商家身份 -->
              <div class="form-group form-group-toggle">
                <label for="isSeller">商家身份</label>
                <div class="toggle-switch-form" :class="{ 'is-enabled': editableUser.isSeller }" @click="editableUser.isSeller = !editableUser.isSeller">
                  <div class="toggle-handle"></div>
                </div>
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="closeModal">取消</button>
              <button type="submit" class="btn-confirm" :disabled="isSubmitting">
                <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
                {{ modalMode === 'add' ? '创建' : '保存' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </transition>


    <!-- 新增：删除确认模态框 -->
    <transition name="modal-fade">
      <div v-if="isConfirmModalVisible" class="modal-overlay" @click.self="closeConfirmModal">
        <div class="modal-content confirm-modal animate-scale-up">
          <div class="confirm-icon">
            <i class="fas fa-exclamation-triangle"></i>
          </div>
          <h2 class="modal-title">确认删除</h2>
          <p class="confirm-text">
            您确定要删除用户 <strong>{{ userToDelete.username }}</strong> 吗？<br>此操作不可撤销。
          </p>
          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="closeConfirmModal">取消</button>
            <button type="button" class="btn-confirm-delete" @click="confirmDelete" :disabled="isSubmitting">
              <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
              确认删除
            </button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive, watch } from 'vue';
// 导入你的 API 请求函数
import { getUsers, updateUserStatus, createUser, updateUser,deleteUser } from '@/api/user';

// --- 状态管理 ---
const users = ref([]);
const searchQuery = ref('');
const loading = ref(true);
const isSubmitting = ref(false);
const pagination = reactive({
  currentPage: 1,
  pageSize: 8,
  total: 0,
});
const stats = reactive({
  active: 0,
  inactive: 0,
  sellers: 0,
});
// --- 新增：删除确认模态框状态 ---
const isConfirmModalVisible = ref(false);
const userToDelete = ref(null);

// --- 模态框状态 ---
const isModalVisible = ref(false);
const modalMode = ref('add'); // 'add' or 'edit'
const editableUser = ref({});
const defaultUserForm = {
  username: '',
  email: '',
  password: '',
  phone: '',
  isSeller: false,
  creditScore: 100,
};

// --- API 调用 ---
let searchTimeout = null;
watch(searchQuery, () => {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    pagination.currentPage = 1; // 搜索时回到第一页
    fetchUsers();
  }, 300); // 300ms 防抖
});

const fetchUsers = async () => {
  loading.value = true;
  try {
    const params = {
      page: pagination.currentPage,
      pageSize: pagination.pageSize,
      query: searchQuery.value,
    };
    const response = await getUsers(params);
    if (response.data.success) {
      users.value = response.data.data.items;
      pagination.total = response.data.data.totalItems;
      // 简单计算统计数据
      recalculateStats(users.value);
    } else {
      console.error("获取用户失败:", response.message);
      // 在这里可以添加UI提示，例如使用Element Plus的Message组件
    }
  } catch (error) {
    console.error("API请求错误:", error);
  } finally {
    loading.value = false;
  }
};

const confirmDelete = async () => {
  if (!userToDelete.value) return;
  isSubmitting.value = true;
  try {
    const response = await deleteUser(userToDelete.value.userId);
    if (response.data.success) {
      closeConfirmModal();
      fetchUsers(); // 刷新列表
      // 在这里可以调用你的成功通知组件
    } else {
      console.error("删除失败:", response.data.message);
      // 在这里可以调用你的失败通知组件
    }
  } catch (error) {
    console.error("删除API请求错误:", error);
  } finally {
    isSubmitting.value = false;
  }
};

// 切换用户状态
const toggleUserStatus = async (user) => {
  const newStatus = !user.enabled;
  try {
    const response = await updateUserStatus(user.userId, newStatus);
    if (response.data.success) {
      user.enabled = newStatus; // 本地更新UI
      recalculateStats(users.value); // 重新计算统计数据
      // 可以在这里显示一个成功的提示
    } else {
      console.error("更新状态失败:", response.data.message);
    }
  } catch (error) {
    console.error("更新状态API请求错误:", error);
  }
};

onMounted(() => {
  fetchUsers();
});

// --- 计算属性 ---
const totalPages = computed(() => {
  return Math.ceil(pagination.total / pagination.pageSize);
});

// --- 模态框逻辑 ---
const openModal = (mode, user = null) => {
  modalMode.value = mode;
  if (mode === 'add') {
    editableUser.value = { ...defaultUserForm };
  } else {
    // 创建一个副本进行编辑，避免直接修改列表中的数据
    editableUser.value = {
      userId: user.userId,
      username: user.username,
      email: user.email,
      phone: user.phone,
      isSeller: user.isSeller,
      creditScore: user.creditScore,
    };
  }
  isModalVisible.value = true;
};

const closeModal = () => { isModalVisible.value = false; };

const openConfirmModal = (user) => {
  userToDelete.value = user;
  isConfirmModalVisible.value = true;
};

const closeConfirmModal = () => {
  isConfirmModalVisible.value = false;
  userToDelete.value = null;
};

const handleFormSubmit = async () => {
  isSubmitting.value = true;
  try {
    let response;
    if (modalMode.value === 'add') {
      response = await createUser(editableUser.value);
    } else {
      response = await updateUser(editableUser.value.userId, editableUser.value);
    }

    if (response.data.success) {
      closeModal();
      fetchUsers(); // 刷新列表
      // 在这里可以调用你的通知组件
    } else {
      console.error("操作失败:", response.data.message);
    }
  } catch (error) {
    console.error("API请求错误:", error);
  } finally {
    isSubmitting.value = false;
  }
};

// --- 方法 ---
const recalculateStats = (allUsers) => {
  // 注意：这里的统计只基于当前页的数据。如果需要全局统计，需要后端额外提供接口。
  // 为了演示，我们暂时基于当前页数据。
  stats.active = allUsers.filter(u => u.enabled).length;
  stats.inactive = allUsers.filter(u => !u.enabled).length;
  stats.sellers = allUsers.filter(u => u.isSeller).length;
};

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '暂无登录记录';
  const date = new Date(dateString);
  return date.toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
};

// 根据信用分获取颜色
const getCreditScoreColor = (score) => {
  if (score >= 90) return '#2ecc71'; // 优秀
  if (score >= 70) return '#3498db'; // 良好
  if (score >= 60) return '#f39c12'; // 中等
  return '#e74c3c'; // 较差
};

// 更改页面
const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.currentPage = page;
    fetchUsers();
  }
};

// 头像加载失败时的后备方案
const onAvatarError = (event) => {
  event.target.src = 'https://placehold.co/100x100/cccccc/ffffff?text=Error';
};

</script>

<style scoped>
/* 整体容器和动画 */
.user-management-container {
  padding: 0;
  background: transparent;
  font-family: var(--font-family-base, 'Inter', sans-serif);
  color: var(--text-primary);
}
.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 头部栏 */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
}
.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff) 0%, var(--accent-color-hover, #7c3aed) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.actions-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* 搜索框 */
.search-box {
  position: relative;
}
.search-box input {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  color: var(--text-primary, #fff);
  width: 250px;
  transition: all var(--transition-speed, 0.3s) ease;
}
.search-box input:focus {
  outline: none;
  border-color: var(--accent-color, #9f78ff);
  box-shadow: 0 0 10px rgba(159, 120, 255, 0.3);
}
.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary, #a0a0b0);
}

/* 添加用户按钮 */
.add-user-btn {
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all var(--transition-speed, 0.3s) ease;
}
.add-user-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(124, 58, 237, 0.4);
}

/* 表格卡片 */
.user-table-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  overflow-x: auto;
}

/* 表格样式 */
.user-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}
.user-table th {
  padding: 1rem 1.5rem;
  color: var(--text-secondary, #a0a0b0);
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.8rem;
  border-bottom: 2px solid var(--border-color, rgba(255, 255, 255, 0.1));
}
.user-table td {
  padding: 1rem 1.5rem;
  color: var(--text-primary, #e0e0e0);
  vertical-align: middle;
}
.user-row {
  transition: background-color var(--transition-speed, 0.3s) ease;
  border-bottom: 1px solid var(--border-color, rgba(255, 255, 255, 0.05));
}
.user-row:last-child {
  border-bottom: none;
}
.user-row:hover {
  background-color: var(--bg-hover, rgba(255, 255, 255, 0.03));
}

/* 表格单元格特定样式 */
.user-info-cell { display: flex; align-items: center; gap: 1rem; }
.avatar { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color, rgba(255, 255, 255, 0.1)); }
.user-details { display: flex; flex-direction: column; }
.username { font-weight: 600; color: var(--text-primary, #fff); }
.email { font-size: 0.85rem; color: var(--text-secondary, #a0a0b0); }

.credit-score-cell { display: flex; align-items: center; gap: 0.75rem; }
.score-value { font-weight: 700; font-size: 1.1rem; }
.score-bar-bg { width: 80px; height: 6px; background: rgba(255, 255, 255, 0.1); border-radius: 3px; }
.score-bar-fg { height: 100%; border-radius: 3px; }

.role-badge { padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
.role-user { background-color: rgba(52, 152, 219, 0.2); color: #3498db; }
.role-seller { background-color: rgba(46, 204, 113, 0.2); color: #2ecc71; }

/* 状态切换开关 */
.status-toggle-wrapper { display: flex; align-items: center; gap: 0.75rem; cursor: pointer; }
.toggle-switch {
  width: 44px;
  height: 24px;
  background-color: rgba(120, 120, 120, 0.8); /* 从原来的 rgba(255, 255, 255, 0.2) 改为更明显的灰色 */
  border-radius: 12px;
  position: relative;
  transition: background-color 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3); /* 添加内阴影增加立体感 */
}
.toggle-handle {
  width: 20px; height: 20px; background-color: white; border-radius: 50%;
  position: absolute; top: 2px; left: 2px; transition: transform 0.3s ease;
}
.toggle-switch.is-enabled { background-color: var(--accent-color, #9f78ff); }
.toggle-switch.is-enabled .toggle-handle { transform: translateX(20px); }
.status-text { font-weight: 500; color: var(--text-secondary, #a0a0b0); transition: color 0.3s ease; }
.status-text.is-enabled { color: var(--text-primary, #fff); }

/* 操作按钮 */
.action-buttons { display: flex; gap: 0.5rem; }
.action-btn {
  width: 36px; height: 36px; border: none; border-radius: 50%;
  background: rgba(255, 255, 255, 0.08); color: var(--text-secondary, #a0a0b0);
  cursor: pointer; transition: all 0.3s ease; font-size: 0.9rem;
}
.action-btn:hover { color: white; transform: translateY(-2px); }
.btn-edit:hover { background-color: #3498db; box-shadow: 0 0 10px #3498db; }
.btn-disable:hover { background-color: #f39c12; box-shadow: 0 0 10px #f39c12; }
.btn-enable:hover { background-color: #2ecc71; box-shadow: 0 0 10px #2ecc71; }
.btn-delete:hover { background-color: #e74c3c; box-shadow: 0 0 10px #e74c3c; }

/* 空状态 */
.empty-state { text-align: center; padding: 4rem 0; }
.empty-state .fa-ghost { font-size: 3rem; color: var(--text-secondary, #a0a0b0); }
.empty-state p { margin-top: 1rem; font-size: 1.1rem; color: var(--text-secondary, #a0a0b0); }

/* 分页 */
.pagination-controls {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 1.5rem;
  gap: 1rem;
  color: var(--text-secondary);
}
.pagination-controls button {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  color: var(--text-primary);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
}
.pagination-controls button:hover:not(:disabled) {
  background-color: var(--accent-color, #9f78ff);
  border-color: var(--accent-color, #9f78ff);
}
.pagination-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 新增：统计卡片样式 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: var(--bg-primary, rgba(40, 42, 60, 0.5));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 1.5rem;
  backdrop-filter: var(--backdrop-filter, blur(10px));
  box-shadow: 0 4px 20px var(--shadow-color, rgba(0, 0, 0, 0.1));
  transition: all var(--transition-speed, 0.3s) ease;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px var(--shadow-color, rgba(0, 0, 0, 0.15));
  border-color: var(--accent-color, #9f78ff);
}

/* 卡片微光效果 */
.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.stat-card:hover::before {
  left: 100%;
}

.card-icon {
  font-size: 2rem;
  padding: 1rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
}

.icon-total {
  background: linear-gradient(135deg, rgba(159, 120, 255, 0.2), rgba(124, 58, 237, 0.1));
  color: var(--accent-color, #9f78ff);
  border: 1px solid rgba(159, 120, 255, 0.3);
}

.icon-active {
  background: linear-gradient(135deg, rgba(46, 204, 113, 0.2), rgba(39, 174, 96, 0.1));
  color: #2ecc71;
  border: 1px solid rgba(46, 204, 113, 0.3);
}

.icon-inactive {
  background: linear-gradient(135deg, rgba(231, 76, 60, 0.2), rgba(192, 57, 43, 0.1));
  color: #e74c3c;
  border: 1px solid rgba(231, 76, 60, 0.3);
}

.icon-seller {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.1));
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.card-content {
  flex: 1;
}

.card-title {
  font-size: 0.875rem;
  color: var(--text-secondary, #a0a0b0);
  margin: 0 0 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.card-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary, #fff);
  margin: 0 0 0.5rem;
  line-height: 1.2;
  background: linear-gradient(135deg, var(--text-primary, #fff) 0%, var(--accent-color, #9f78ff) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.card-trend {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: var(--text-secondary, #a0a0b0);
}

.card-trend.positive {
  color: #10b981;
}

.card-trend.negative {
  color: var(--danger-color, #ef4444);
}

.card-trend i {
  font-size: 0.75rem;
}

/* 新增：动画效果 */
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.animate-slide-up {
  opacity: 0;
  animation: slideUp 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  animation-delay: var(--delay, 0s);
}

/* --- 新增：模态框样式 --- */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
}

.modal-content {
  background: var(--bg-primary, rgba(40, 42, 60, 0.8));
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-md, 16px);
  padding: 2.5rem;
  width: 90%;
  max-width: 600px;
  box-shadow: 0 10px 30px var(--shadow-color, rgba(0, 0, 0, 0.2));
}

.modal-title {
  font-size: 1.8rem;
  font-weight: 700;
  margin: 0 0 2rem 0;
  text-align: center;
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), #fff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 0.5rem;
  color: var(--text-secondary, #a0a0b0);
  font-weight: 500;
  font-size: 0.9rem;
}

.input-wrapper {
  position: relative;
}

.input-wrapper i {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
}

.form-group input {
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid var(--border-color, rgba(255, 255, 255, 0.1));
  border-radius: var(--border-radius-sm, 8px);
  padding: 0.8rem 1rem 0.8rem 2.8rem;
  color: var(--text-primary, #fff);
  width: 100%;
  transition: all 0.3s ease;
}

.form-group input:focus {
  outline: none;
  border-color: var(--accent-color, #9f78ff);
  box-shadow: 0 0 10px rgba(159, 120, 255, 0.3);
}

.form-group input:disabled {
  background-color: rgba(0, 0, 0, 0.3);
  cursor: not-allowed;
}

.form-group-toggle {
  grid-column: 1 / -1; /* 让它横跨两列 */
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  background: rgba(0, 0, 0, 0.2);
  padding: 0.8rem 1.2rem;
  border-radius: var(--border-radius-sm, 8px);
}

.toggle-switch-form {
  width: 44px; height: 24px; background-color: rgba(120, 120, 120, 0.8);
  border-radius: 12px; position: relative; transition: background-color 0.3s ease;
  cursor: pointer;
}
.toggle-switch-form .toggle-handle {
  width: 20px; height: 20px; background-color: white; border-radius: 50%;
  position: absolute; top: 2px; left: 2px; transition: transform 0.3s ease;
}
.toggle-switch-form.is-enabled { background-color: var(--accent-color, #9f78ff); }
.toggle-switch-form.is-enabled .toggle-handle { transform: translateX(20px); }


.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2.5rem;
}

.modal-actions button {
  padding: 0.75rem 1.8rem;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-cancel {
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
}
.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.2);
}

.btn-confirm {
  background: linear-gradient(135deg, var(--accent-color, #9f78ff), var(--accent-color-hover, #7c3aed));
  color: white;
}
.btn-confirm:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(124, 58, 237, 0.4);
}
.btn-confirm:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.btn-confirm .fa-spinner {
  margin-right: 0.5rem;
}


/* --- 模态框过渡动画 --- */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.animate-scale-up {
  animation: scaleUp 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
@keyframes scaleUp {
  from { transform: scale(0.9) translateY(20px); opacity: 0; }
  to { transform: scale(1) translateY(0); opacity: 1; }
}

/* --- 新增：删除确认模态框的特定样式 --- */
.confirm-modal {
  max-width: 420px;
  text-align: center;
  padding-top: 2rem;
}

.confirm-icon {
  font-size: 3rem;
  color: #e74c3c; /* 危险红色 */
  margin-bottom: 1.5rem;
  animation: pulse-warning 1.5s infinite;
}

@keyframes pulse-warning {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

.confirm-text {
  color: var(--text-secondary, #a0a0b0);
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 2.5rem;
}

.confirm-text strong {
  color: var(--text-primary, #fff);
  font-weight: 600;
}

.btn-confirm-delete {
  padding: 0.75rem 1.8rem;
  border: none;
  border-radius: var(--border-radius-sm, 8px);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #e74c3c;
  color: white;
}

.btn-confirm-delete:hover {
  background: #c0392b;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(231, 76, 60, 0.4);
}

.btn-confirm-delete:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-confirm-delete .fa-spinner {
  margin-right: 0.5rem;
}
</style>
