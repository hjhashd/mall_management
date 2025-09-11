<template>
  <div class="role-management-container">
    <!-- 【新增】通知/Toast 容器 -->
    <div class="notification-container">
      <transition-group name="notification-fade">
        <div v-for="notification in notifications" :key="notification.id" :class="['notification', `notification-${notification.type}`]">
          <i :class="notification.icon" class="notification-icon"></i>
          <p>{{ notification.message }}</p>
          <button @click="removeNotification(notification.id)" class="notification-close-btn">&times;</button>
        </div>
      </transition-group>
    </div>

    <!-- 头部：标题和搜索 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <i class="fas fa-user-shield"></i>
          角色权限管理
        </h1>
        <p class="page-subtitle">分配和管理系统用户的角色与权限</p>
      </div>
      <div class="header-actions">
        <div class="search-control">
          <i class="fas fa-search search-icon"></i>
          <input type="text" v-model="searchQuery" placeholder="按用户名或邮箱搜索..." @keyup.enter="fetchData" class="search-input">
        </div>
      </div>
    </div>

    <!-- 主体内容区 -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>正在加载用户和角色数据...</p>
    </div>

    <div v-else class="main-layout">
      <!-- 左侧：用户列表 -->
      <div class="users-panel">
        <h2 class="panel-title">
          <i class="fas fa-users"></i> 用户列表
        </h2>
        <div v-if="paginatedUsers.length === 0" class="empty-state">
          <div class="empty-icon"><i class="fas fa-user-slash"></i></div>
          <h3>未找到用户</h3>
          <p>没有匹配当前搜索条件的用户</p>
        </div>
        <div v-else class="users-list">
          <div
              v-for="(user, index) in paginatedUsers"
              :key="user.userId"
              class="user-card"
              :style="{ '--animation-delay': `${index * 0.05}s` }"
          >
            <div class="user-card-header">
              <div class="user-avatar">
                <img :src="user.avatarPath" alt="avatar" @error="setDefaultAvatar"/>
              </div>
              <div class="user-info">
                <h4 class="username">{{ user.username }}</h4>
                <p class="email">{{ user.email }}</p>
              </div>
              <button class="btn btn-primary btn-edit-roles" @click="openEditModal(user)">
                <i class="fas fa-edit"></i>
                <span>编辑角色</span>
              </button>
            </div>
            <div class="user-card-body">
              <h5 class="roles-title">当前角色</h5>
              <div class="roles-list">
                <span v-if="!user.roles || user.roles.length === 0" class="no-roles">暂无角色</span>
                <span
                    v-for="role in user.roles"
                    :key="role.roleId"
                    class="role-badge"
                    :class="getRoleClass(role.roleName)"
                >
                  {{ role.roleName?.replace('ROLE_', '') || role.roleName }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- 用户列表分页 -->
        <div v-if="totalPages > 1" class="pagination-wrapper">
          <div class="pagination">
            <button
                class="pagination-btn"
                @click="changePage(pagination.currentPage - 1)"
                :disabled="pagination.currentPage <= 1"
            >
              <i class="fas fa-chevron-left"></i>
            </button>
            <div class="pagination-info">
              第 {{ pagination.currentPage }} / {{ totalPages }} 页
            </div>
            <button
                class="pagination-btn"
                @click="changePage(pagination.currentPage + 1)"
                :disabled="pagination.currentPage >= totalPages"
            >
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- 右侧：角色列表 -->
      <div class="roles-panel">
        <h2 class="panel-title">
          <i class="fas fa-tags"></i> 角色池
        </h2>
        <div class="roles-list-description">
          <p>这里是系统中所有可用的角色。您可以将这些角色分配给左侧的用户。</p>
        </div>
        <div class="available-roles-list">
          <div
              v-for="role in allRoles"
              :key="role.roleId"
              class="role-definition-card"
          >
            <div class="role-card-content">
              <div class="role-card-icon" :class="getRoleClass(role.roleName)">
                <i class="fas fa-tag"></i>
              </div>
              <div class="role-card-info">
                <h4 class="role-name">{{ role.roleName?.replace('ROLE_', '') || role.roleName }}</h4>
                <p class="role-description">{{ role.description || '暂无描述' }}</p>
              </div>
            </div>
            <div class="role-card-actions">
              <button class="btn btn-outline btn-sm" @click="openRoleModal(role)"><i class="fas fa-pencil-alt"></i></button>
              <button class="btn btn-danger-outline btn-sm" @click="handleDeleteRole(role.roleId, role.roleName)"><i class="fas fa-trash"></i></button>
            </div>
          </div>
          <button class="btn add-role-btn" @click="openRoleModal()">
            <i class="fas fa-plus"></i> 新增角色
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑用户角色模态框 -->
    <div v-if="isEditModalOpen" class="modal-overlay" @click.self="closeEditModal">
      <div class="modal-container">
        <div class="modal-header">
          <h2>
            <i class="fas fa-user-cog"></i>
            编辑角色 - <span class="modal-username">{{ selectedUser?.username || '未知用户' }}</span>
          </h2>
          <button class="modal-close" @click="closeEditModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <p class="modal-instructions">请为用户选择一个或多个角色：</p>
          <div class="role-selection-list">
            <label
                v-for="role in allRoles"
                :key="role.roleId"
                class="role-selection-item"
                :class="{ 'selected': userRolesInModal.has(role.roleId) }"
            >
              <input
                  type="checkbox"
                  :checked="userRolesInModal.has(role.roleId)"
                  @change="toggleRoleInModal(role.roleId)"
              >
              <div class="role-info">
                <span class="role-badge" :class="getRoleClass(role.roleName)">{{ role.roleName?.replace('ROLE_', '') || role.roleName }}</span>
                <span class="role-description-modal">{{ role.description || '暂无描述' }}</span>
              </div>
              <div class="checkbox-indicator">
                <i class="fas fa-check"></i>
              </div>
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline" @click="closeEditModal">取消</button>
          <button class="btn btn-primary" @click="saveUserRoles" :disabled="isSaving">
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-save'"></i>
            {{ isSaving ? '保存中...' : '保存更改' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 新增/编辑角色模态框 -->
    <div v-if="isRoleModalOpen" class="modal-overlay" @click.self="closeRoleModal">
      <div class="modal-container">
        <div class="modal-header">
          <h2>
            <i class="fas fa-tag"></i>
            {{ isEditingRole ? '编辑角色' : '新增角色' }}
          </h2>
          <button class="modal-close" @click="closeRoleModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleSaveRole">
            <div class="form-group">
              <label for="roleName">角色名称 (不含 ROLE_ 前缀)</label>
              <input type="text" id="roleName" v-model="currentRole.roleName" required>
            </div>
            <div class="form-group">
              <label for="roleDescription">角色描述</label>
              <textarea id="roleDescription" v-model="currentRole.description" rows="3"></textarea>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline" @click="closeRoleModal">取消</button>
          <button class="btn btn-primary" @click="handleSaveRole" :disabled="isSaving">
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-save'"></i>
            {{ isSaving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 【新增】通用确认模态框 -->
    <div v-if="isConfirmModalOpen" class="modal-overlay" @click.self="closeConfirmModal">
      <div class="modal-container confirmation-modal">
        <div class="modal-header">
          <h2 class="confirmation-title">
            <i class="fas fa-exclamation-triangle"></i> {{ confirmModalConfig.title }}
          </h2>
          <button class="modal-close" @click="closeConfirmModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <p v-html="confirmModalConfig.message"></p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline" @click="closeConfirmModal">取消</button>
          <button class="btn btn-danger" @click="executeConfirmAction">确认</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { getUsersWithRoles, getAllRoles, updateUserRoles, createRole, updateRole, deleteRole } from '@/api/user';

// --- 状态管理 ---
const allUsers = ref([]);
const allRoles = ref([]);
const isLoading = ref(true);
const isSaving = ref(false);
const searchQuery = ref('');
const pagination = ref({ currentPage: 1, pageSize: 5, total: 0 });
const isEditModalOpen = ref(false);
const selectedUser = ref(null);
const userRolesInModal = ref(new Set());

// --- 角色池模态框状态 ---
const isRoleModalOpen = ref(false);
const isEditingRole = ref(false);
const currentRole = ref({ roleId: null, roleName: '', description: '' });

// --- 【新增】通知状态 ---
const notifications = ref([]);
let notificationIdCounter = 0;

// --- 【新增】确认模态框状态 ---
const isConfirmModalOpen = ref(false);
const confirmModalConfig = ref({ title: '', message: '', onConfirm: null });


// --- 数据获取 ---
const fetchData = async () => {
  isLoading.value = true;
  try {
    const [userResponse, roleResponse] = await Promise.all([
      getUsersWithRoles({ page: pagination.value.currentPage, pageSize: pagination.value.pageSize, query: searchQuery.value }),
      getAllRoles(),
    ]);

    if (userResponse.data?.success) {
      allUsers.value = userResponse.data.data.items || [];
      pagination.value.total = userResponse.data.data?.totalItems || 0;
    } else {
      showNotification(`获取用户列表失败: ${userResponse.data?.message || '未知错误'}`, 'error');
    }

    if (roleResponse.data?.success) {
      allRoles.value = roleResponse.data.data || [];
    } else {
      showNotification(`获取角色列表失败: ${roleResponse.data?.message || '未知错误'}`, 'error');
    }
  } catch (error) {
    console.error("请求数据时出错:", error);
    showNotification("请求数据时出错，请检查网络或联系管理员。", 'error');
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchData);

// --- 计算属性 ---
const totalPages = computed(() => Math.ceil(pagination.value.total / pagination.value.pageSize));
const paginatedUsers = computed(() => allUsers.value);

// --- 【新增】通知方法 ---
const showNotification = (message, type = 'success', duration = 3500) => {
  const icons = {
    success: 'fas fa-check-circle',
    error: 'fas fa-exclamation-circle',
    info: 'fas fa-info-circle',
  };
  const id = notificationIdCounter++;
  notifications.value.push({ id, message, type, icon: icons[type] || icons.info });
  setTimeout(() => removeNotification(id), duration);
};

const removeNotification = (id) => {
  const index = notifications.value.findIndex(n => n.id === id);
  if (index !== -1) notifications.value.splice(index, 1);
};

// --- 【新增】确认模态框方法 ---
const openConfirmModal = (title, message, onConfirm) => {
  confirmModalConfig.value = { title, message, onConfirm };
  isConfirmModalOpen.value = true;
};
const closeConfirmModal = () => isConfirmModalOpen.value = false;
const executeConfirmAction = async () => {
  if (confirmModalConfig.value.onConfirm) {
    await confirmModalConfig.value.onConfirm();
  }
  closeConfirmModal();
};

// --- 通用方法 ---
const changePage = (page) => {
  if (page > 0 && page <= totalPages.value) {
    pagination.value.currentPage = page;
    fetchData();
  }
};

watch(searchQuery, () => {
  pagination.value.currentPage = 1;
  fetchData();
});

const getRoleClass = (roleName) => {
  const cleanRoleName = roleName?.toLowerCase().replace('role_', '') || '';
  const mapping = { admin: 'role-admin', moderator: 'role-moderator', seller: 'role-seller', user: 'role-buyer' };
  return mapping[cleanRoleName] || 'role-default';
};

const setDefaultAvatar = (event) => {
  event.target.src = 'https://placehold.co/100x100/cccccc/FFFFFF?text=?';
};

// --- 用户角色模态框逻辑 ---
const openEditModal = (user) => {
  selectedUser.value = { ...user };
  userRolesInModal.value = new Set(user.roles ? user.roles.map(r => r.roleId) : []);
  isEditModalOpen.value = true;
};
const closeEditModal = () => isEditModalOpen.value = false;
const toggleRoleInModal = (roleId) => {
  const newSet = new Set(userRolesInModal.value);
  if (newSet.has(roleId)) newSet.delete(roleId); else newSet.add(roleId);
  userRolesInModal.value = newSet;
};
const saveUserRoles = async () => {
  if (!selectedUser.value) return;
  isSaving.value = true;
  try {
    const response = await updateUserRoles(selectedUser.value.userId, Array.from(userRolesInModal.value));
    if (response.data?.success) {
      showNotification(response.data.message || '角色更新成功！');
      closeEditModal();
      await fetchData();
    } else {
      showNotification(response.data?.message || '更新失败', 'error');
    }
  } catch (error) {
    showNotification(error.response?.data?.message || "更新失败，请稍后重试。", 'error');
  } finally {
    isSaving.value = false;
  }
};

// --- 角色池 (Role Pool) 逻辑 ---
const openRoleModal = (role = null) => {
  if (role) {
    isEditingRole.value = true;
    currentRole.value = { ...role, roleName: role.roleName.replace('ROLE_', '') };
  } else {
    isEditingRole.value = false;
    currentRole.value = { roleId: null, roleName: '', description: '' };
  }
  isRoleModalOpen.value = true;
};
const closeRoleModal = () => isRoleModalOpen.value = false;

const handleSaveRole = async () => {
  if (!currentRole.value.roleName.trim()) {
    showNotification('角色名称不能为空', 'error');
    return;
  }
  isSaving.value = true;
  try {
    const roleData = {
      roleName: currentRole.value.roleName,
      description: currentRole.value.description
    };
    const response = isEditingRole.value
        ? await updateRole(currentRole.value.roleId, roleData)
        : await createRole(roleData);

    if (response.data?.success) {
      showNotification(response.data.message || '操作成功！');
      closeRoleModal();
      await fetchData();
    } else {
      showNotification(response.data?.message || '操作失败', 'error');
    }
  } catch (error) {
    showNotification(error.response?.data?.message || "操作失败，请稍后重试。", 'error');
  } finally {
    isSaving.value = false;
  }
};

const handleDeleteRole = (roleId, roleName) => {
  const cleanRoleName = roleName?.replace('ROLE_', '');
  openConfirmModal(
      '确认删除',
      `确定要删除角色 <strong>${cleanRoleName}</strong> 吗？<br>此操作不可逆！如果角色正在被使用，删除将失败。`,
      async () => {
        try {
          const response = await deleteRole(roleId);
          if (response.data?.success) {
            showNotification(response.data.message || '删除成功！');
            await fetchData();
          } else {
            showNotification(response.data?.message || '删除失败', 'error');
          }
        } catch (error) {
          showNotification(error.response?.data?.message || "删除失败，请稍后重试。", 'error');
        }
      }
  );
};
</script>

<style scoped>
/* --- 新增样式 --- */
.notification-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 2000;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.notification {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 18px;
  border-radius: var(--border-radius-sm);
  color: white;
  min-width: 300px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  animation: slideInRight 0.4s ease-out;
}
.notification-success { background-color: var(--success-color); }
.notification-error { background-color: var(--danger-color); }
.notification-info { background-color: var(--info-color); }
.notification-icon { font-size: 1.2rem; }
.notification p { margin: 0; flex-grow: 1; }
.notification-close-btn {
  background: none;
  border: none;
  color: white;
  opacity: 0.7;
  font-size: 1.2rem;
  cursor: pointer;
  transition: opacity 0.2s;
}
.notification-close-btn:hover { opacity: 1; }
.notification-fade-enter-active, .notification-fade-leave-active {
  transition: all 0.5s ease;
}
.notification-fade-enter-from, .notification-fade-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.confirmation-modal .modal-header .confirmation-title { color: var(--danger-color); }
.confirmation-modal .modal-header i { margin-right: 10px; }
.btn-danger { background: var(--danger-color); color: white; border-color: var(--danger-color); }
.btn-danger:hover:not(:disabled) { background: #c82333; border-color: #bd2130; transform: translateY(-1px); }

.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: var(--text-secondary); }
.form-group input, .form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid var(--border-color);
  border-radius: var(--border-radius-sm);
  background-color: var(--bg-secondary);
  transition: all 0.3s ease;
}
.form-group input:focus, .form-group textarea:focus {
  outline: none;
  border-color: var(--accent-color);
  background-color: var(--bg-primary);
  box-shadow: 0 0 0 3px var(--shadow-color);
}

/* --- 原有样式 --- */
:root {
  --accent-color: #4a6cf7;
  --accent-color-hover: #3b57d6;
  --danger-color: #ef4444;
  --success-color: #2ecc71;
  --warning-color: #f39c12;
  --info-color: #3498db;
  --text-primary: #1e293b;
  --text-secondary: #64748b;
  --border-color: #e2e8f0;
  --bg-primary: #ffffff;
  --bg-secondary: #f7f9fc;
  --bg-hover: #eff4ff;
  --border-radius-sm: 0.5rem;
  --border-radius-md: 0.75rem;
  --shadow-color: rgba(74, 108, 247, 0.1);
}
.role-management-container {
  padding: 0;
  font-family: 'Inter', sans-serif;
  color: var(--text-primary);
  animation: fadeIn 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
@keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1.5rem; margin-bottom: 2rem; padding: 1.5rem 0; border-bottom: 1px solid var(--border-color); }
.page-title { display: flex; align-items: center; gap: 0.75rem; margin: 0 0 0.5rem 0; font-size: 2rem; font-weight: 700; }
.page-title i { color: var(--accent-color); font-size: 1.75rem; }
.page-subtitle { margin: 0; color: var(--text-secondary); }
.search-control { position: relative; min-width: 300px; }
.search-icon { position: absolute; top: 50%; left: 1rem; transform: translateY(-50%); color: var(--text-secondary); }
.search-input { width: 100%; background-color: var(--bg-secondary); border: 2px solid var(--border-color); border-radius: var(--border-radius-md); padding: 0.75rem 1rem 0.75rem 3rem; font-size: 0.9rem; font-weight: 500; color: var(--text-primary); transition: all 0.3s ease; }
.search-input:focus { outline: none; border-color: var(--accent-color); background-color: var(--bg-primary); box-shadow: 0 0 0 3px rgba(74, 108, 247, 0.1); }
.loading-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 4rem; text-align: center; color: var(--text-secondary); }
.spinner { width: 50px; height: 50px; border: 5px solid rgba(74, 108, 247, 0.2); border-top-color: var(--accent-color); border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 1rem; }
@keyframes spin { to { transform: rotate(360deg); } }
.empty-state { text-align: center; padding: 2rem; background: var(--bg-secondary); border-radius: var(--border-radius-md); border: 2px dashed var(--border-color); margin-top: 1rem; }
.empty-icon { font-size: 3rem; color: var(--text-secondary); opacity: 0.5; margin-bottom: 1rem; }
.empty-state h3 { margin: 0 0 0.5rem; color: var(--text-primary); }
.empty-state p { margin: 0; color: var(--text-secondary); font-size: 0.9rem; }
.main-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; }
.panel-title { display: flex; align-items: center; gap: 0.75rem; font-size: 1.5rem; margin: 0 0 1rem 0; padding-bottom: 1rem; border-bottom: 1px solid var(--border-color); }
.panel-title i { color: var(--accent-color); }
.users-panel { background: var(--bg-primary); padding: 1.5rem; border-radius: var(--border-radius-md); border: 1px solid var(--border-color); }
.user-card { background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--border-radius-md); margin-bottom: 1rem; transition: all 0.3s ease; overflow: hidden; animation: slideUp 0.5s ease-out both; animation-delay: var(--animation-delay, 0s); }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.user-card:hover { transform: translateY(-2px); box-shadow: 0 8px 25px var(--shadow-color); border-color: var(--accent-color); }
.user-card-header { display: flex; align-items: center; gap: 1rem; padding: 1rem; background: var(--bg-secondary); }
.user-avatar { width: 50px; height: 50px; border-radius: 50%; overflow: hidden; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.user-avatar img { width: 100%; height: 100%; object-fit: cover; }
.user-info { flex: 1; }
.username { margin: 0; font-size: 1.1rem; color: var(--text-primary); }
.email { margin: 0; font-size: 0.85rem; color: var(--text-secondary); }
.user-card-body { padding: 1rem; }
.roles-title { margin: 0 0 0.75rem; font-size: 0.8rem; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px;}
.roles-list { display: flex; flex-wrap: wrap; gap: 0.5rem; }
.no-roles { font-style: italic; color: var(--text-secondary); font-size: 0.9rem; }
.role-badge { padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.8rem; font-weight: 600; color: white; text-transform: capitalize; }
.role-admin { background-color: #8e44ad; }
.role-moderator { background-color: #f39c12; }
.role-seller { background-color: #2ecc71; }
.role-buyer { background-color: #3498db; }
.role-default { background-color: #95a5a6; }
.roles-panel { background: var(--bg-secondary); padding: 1.5rem; border-radius: var(--border-radius-md); border: 1px solid var(--border-color); }
.roles-list-description { margin: -1rem 0 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--border-color); font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6; }
.role-definition-card { background: var(--bg-primary); border-radius: var(--border-radius-sm); margin-bottom: 1rem; padding: 1rem; display: flex; justify-content: space-between; align-items: center; border: 1px solid var(--border-color); transition: all 0.2s ease-in-out; }
.role-definition-card:hover { transform: scale(1.02); box-shadow: 0 4px 15px var(--shadow-color); }
.role-card-content { display: flex; align-items: center; gap: 1rem; }
.role-card-icon { width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; color: white; border-radius: var(--border-radius-sm); font-size: 1.2rem; }
.role-name { font-size: 1.1rem; margin: 0 0 0.25rem; text-transform: capitalize; }
.role-description { font-size: 0.85rem; color: var(--text-secondary); margin: 0; }
.role-card-actions { display: flex; gap: 0.5rem; }
.add-role-btn {
  width: 100%;
  margin-top: 1rem;
  background-color: var(--accent-color);
  border-color: var(--accent-color);
  color: white;
}
.add-role-btn:hover:not(:disabled) {
  background-color: var(--success-color);
  border-color: var(--success-color);
  transform: translateY(-1px);
}
.btn { display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.625rem 1.25rem; border: 2px solid transparent; border-radius: var(--border-radius-sm); font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.3s ease; white-space: nowrap; }
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-primary { background: var(--accent-color); color: white; border-color: var(--accent-color); }
.btn-primary:hover:not(:disabled) { background: var(--accent-color-hover); border-color: var(--accent-color-hover); transform: translateY(-1px); }
.btn-outline { background: transparent; color: var(--text-secondary); border-color: var(--border-color); }
.btn-outline:hover { color: var(--accent-color); border-color: var(--accent-color); background: var(--bg-hover); }
.btn-danger-outline { background: transparent; color: var(--danger-color); border-color: var(--danger-color); }
.btn-danger-outline:hover { background: var(--danger-color); color: white; }
.btn-success { background: var(--success-color); color: white; border-color: var(--success-color); }
.btn-success:hover { background: #27ae60; border-color: #27ae60; }
.btn-sm { padding: 0.4rem 0.8rem; font-size: 0.8rem; }
.btn-edit-roles span { display: block; }
.pagination-wrapper { display: flex; justify-content: center; margin-top: 2rem; }
.pagination { display: flex; align-items: center; gap: 1rem; }
.pagination-btn { width: 40px; height: 40px; background: var(--bg-primary); border: 2px solid var(--border-color); border-radius: var(--border-radius-sm); cursor: pointer; transition: all 0.3s ease; }
.pagination-btn:hover:not(:disabled) { background: var(--accent-color); border-color: var(--accent-color); color: white; }
.pagination-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.pagination-info { font-weight: 600; }
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1400; animation: modalFadeIn 0.3s ease-out; }
@keyframes modalFadeIn { from { opacity: 0; } to { opacity: 1; } }
.modal-container { background: var(--bg-primary); border-radius: var(--border-radius-md); box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); width: 100%; max-width: 600px; overflow: hidden; animation: modalSlideIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1); }
@keyframes modalSlideIn { from { opacity: 0; transform: scale(0.9); } to { opacity: 1; transform: scale(1); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 1.5rem 2rem; border-bottom: 1px solid var(--border-color); background: var(--bg-secondary); }
.modal-header h2 { display: flex; align-items: center; gap: 0.75rem; margin: 0; font-size: 1.5rem; }
.modal-header .modal-username { color: var(--accent-color); }
.modal-close { background: transparent; border: none; font-size: 1.5rem; cursor: pointer; color: var(--text-secondary); transition: all 0.3s ease; }
.modal-close:hover { color: var(--danger-color); transform: rotate(90deg); }
.modal-body { padding: 2rem; max-height: 60vh; overflow-y: auto; }
.modal-instructions { margin: 0 0 1.5rem; color: var(--text-secondary); }
.role-selection-list { display: flex; flex-direction: column; gap: 0.75rem; }
.role-selection-item { display: flex; align-items: center; gap: 1rem; padding: 1rem; border: 2px solid var(--border-color); border-radius: var(--border-radius-sm); cursor: pointer; transition: all 0.2s ease-in-out; }
.role-selection-item:hover { border-color: var(--accent-color); background: var(--bg-hover); }
.role-selection-item.selected { border-color: var(--accent-color); background-color: var(--bg-hover); box-shadow: 0 0 0 2px var(--accent-color); }
.role-selection-item input[type="checkbox"] { display: none; }
.role-selection-item .role-info { flex-grow: 1; }
.role-description-modal { font-size: 0.85rem; color: var(--text-secondary); display: block; margin-top: 0.25rem; }
.checkbox-indicator { width: 24px; height: 24px; border: 2px solid var(--border-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease-in-out; }
.checkbox-indicator i { color: white; font-size: 0.8rem; transform: scale(0); transition: transform 0.2s ease-in-out; }
.role-selection-item.selected .checkbox-indicator { background-color: var(--accent-color); border-color: var(--accent-color); }
.role-selection-item.selected .checkbox-indicator i { transform: scale(1); }
.modal-footer { display: flex; justify-content: flex-end; align-items: center; gap: 1rem; padding: 1.5rem 2rem; border-top: 1px solid var(--border-color); background: var(--bg-secondary); }
@media (max-width: 992px) { .main-layout { grid-template-columns: 1fr; } .roles-panel { margin-top: 2rem; } }
@media (max-width: 768px) { .page-header { flex-direction: column; align-items: stretch; } .search-control { min-width: unset; width: 100%; } .btn-edit-roles span { display: none; } .btn-edit-roles { width: 40px; height: 40px; padding: 0; } .modal-container { max-width: calc(100vw - 2rem); } .modal-body, .modal-header, .modal-footer { padding: 1.25rem; } }
</style>


