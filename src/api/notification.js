import request from '@/utils/request';

export function getUnreadNotifications() {
    return request({ url: '/notifications/unread', method: 'get' });
}
export function markNotificationAsRead(notificationId) {
    return request({ url: `/notifications/${notificationId}/read`, method: 'post' });
}
export function markAllNotificationsAsRead() {
    return request({ url: '/notifications/read-all', method: 'post' });
}
