import { createApp, ref } from 'vue';
import NotificationMessage from '@/views/Admin/components/NotificationMessage.vue';

// 存储当前所有通知实例的响应式数组
const notifications = ref([]);
const GAP = 20; // 通知之间的垂直间距

export function useNotification() {
    const createNotification = (options) => {
        // 创建一个 div 容器
        const container = document.createElement('div');

        // 计算新通知的垂直偏移量
        let offset = GAP;
        notifications.value.forEach(vm => {
            offset += (vm.el.offsetHeight || 0) + GAP;
        });

        // 定义销毁函数
        const destroy = () => {
            // 从 DOM 中移除
            if (container.parentNode) {
                document.body.removeChild(container);
            }
            // 从数组中移除
            const index = notifications.value.findIndex(vm => vm.app === app);
            if (index !== -1) {
                notifications.value.splice(index, 1);
            }
            // 重新计算剩余通知的位置
            recalculatePositions();
        };

        // 创建 Vue 应用实例
        const app = createApp(NotificationMessage, {
            ...options,
            offset,
            onClose: destroy,
        });

        // 挂载到容器
        const vm = app.mount(container);
        document.body.appendChild(container);

        // 将实例信息存入数组
        notifications.value.push({ app, vm, el: vm.$el });
    };

    const recalculatePositions = () => {
        let offset = GAP;
        notifications.value.forEach(item => {
            item.vm.offset = offset; // 直接更新组件实例的 offset prop
            offset += item.el.offsetHeight + GAP;
        });
    };

    return {
        show(message, type = 'info', duration = 3000) {
            createNotification({ message, type, duration });
        },
        success(message, duration = 3000) {
            this.show(message, 'success', duration);
        },
        warning(message, duration = 3000) {
            this.show(message, 'warning', duration);
        },
        error(message, duration = 5000) { // 错误信息默认显示时间更长
            this.show(message, 'error', duration);
        },
        info(message, duration = 3000) {
            this.show(message, 'info', duration);
        },
    };
}
