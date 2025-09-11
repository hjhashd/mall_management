import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/userStore'
import HomeView from '../views/Home/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import RegisterView from '../views/RegisterView.vue'
import AdminView from '../views/Admin/AdminView.vue'
import ProductReviewsPage from '../views/Home/components/ProductDetail/review/ProductReviewsPage.vue'

const routes = [
    {
        path: '/',
        name: 'Home',
        component: HomeView
    },
    {
        path: '/chat',
        name: 'Chat',
        component: () => import('@/views/Home/components/nav/chat/ChatLayout.vue'),
    },
    {
        path: '/login',
        name: 'Login',
        component: LoginView,
        meta: { requiresGuest: true }
    },
    {
        path: '/admin',
        name: 'Admin',
        component: AdminView,
        meta: { requiresAuth: true, requiresAdmin: true } // 添加管理员权限要求
    },
    {
        path: '/register',
        name: 'Register',
        component: RegisterView,
        meta: { requiresGuest: true }
    },
    {
        path: '/search',
        name: 'Search',
        component: () => import('../views/Home/components/nav/search.vue'),
    },
    {
        path: '/account',
        name: 'Account',
        component: () => import('../views/Home/components/nav/personal/AccountProfile.vue'),
    },
    {
        path: '/user-center',
        name: 'UserCenter',
        component: () => import('@/views/Home/components/nav/user-center/UserCenter.vue'),
    },
    {
        path: '/communityHub',
        name: 'CommunityHub',
        component: () => import('../views/Home/components/nav/community/CommunityHub.vue'),
    },
    {
        path: '/community',
        name: 'Community',
        component: () => import('../views/Home/components/nav/community/List.vue'),
    },
    {
        path: '/court',
        name: 'CommunityCourt',
        component: () => import('../views/Home/components/nav/community/CampusCourt.vue'),
    },
    {
        path: '/product/:id',
        name: 'ProductDetail',
        component: () => import('@/views/Home/components/ProductDetail/detail.vue'),
    },
    {
        path: '/store/:sellerId?',
        name: 'Store',
        component: () => import('@/views/Home/components/ProductDetail/Store.vue'),
        props: true
    },

    {
        path: '/product/:productId/reviews',
        name: 'ProductReviews',
        component: ProductReviewsPage,
        props: true
    },
    {
        path: '/favorite',
        name: 'Favorite',
        component: () => import('@/views/Home/components/nav/favorites/Favorites.vue'),
    },
    {
        path: '/cart',
        name: 'Cart',
        component: () => import('@/views/Home/components/nav/cart/CartPage.vue'),
    },
    {
        path: '/order-confirm',
        name: 'Order-confirm',
        component: () => import('@/views/Home/components/nav/cart/OrderConfirm.vue'),
    },
    {
        path: '/orders',
        name: 'Orders',
        component: () => import('@/views/Home/components/nav/orders/OrderList.vue'),
    },
    {
        path: '/order/:orderId',
        name: 'OrderDetail',
        component: () => import('@/views/Home/components/nav/orders/OrderDetail.vue'),
        props: true,
    },
    {
        path: '/address',
        name: 'Address',
        component: () => import('@/views/Home/components/nav/address/Address.vue'),
    },
    {
        path: '/seller-certification',
        name: 'SellerCertification',
        component: () => import('@/views/Home/components/nav/certification/SellerCertification.vue'),
    },
    {
        path: '/ai-assistant',
        name: 'AIAssistant',
        component: () => import('@/views/Home/components/AIAssistant/AIAssistantChat.vue'),
    },
    {
        path: '/seller',
        name: 'Seller',
        component: () => import('@/views/Home/components/nav/seller/SellerCenter.vue'),
    },
    {
        path: '/seller-order',
        redirect: '/seller-layout?activeMenu=SellerOrderManagement'
    },
    {
        path: '/seller-layout',
        name: 'SellerLayout',
        component: () => import('@/views/Home/components/nav/seller/management/SellerLayout.vue'),
    },
    {
        path: '/product-review/:productId?',
        name: 'ProductReview',
        component: () => import('@/views/Home/components/nav/seller/Review.vue'),
        props: true
    },
    {
        path: '/refund/:orderItemId', // 使用 orderItemId 作为参数
        name: 'RefundApplication',
        component: () => import('@/views/Home/components/nav/orders/RefundApplication.vue'),
        meta: { requiresAuth: true }
    },

]

const router = createRouter({
    history: createWebHistory(),
    routes,
    scrollBehavior() {
        return { top: 0 }
    }
})

router.beforeEach(async (to, from, next) => {
    const userStore = useUserStore()

    // 恢复存储状态
    if (!userStore.hydrated) {
        userStore.restoreFromStorage()
    }

    const isLoggedIn = userStore.isLoggedIn
    const isAdmin = userStore.isAdmin

    // 需要认证且未登录 → 跳转登录页
    if (to.meta.requiresAuth && !isLoggedIn) {
        next({ name: 'Login', query: { from: to.fullPath } })
        return
    }

    // 需要管理员权限但不是管理员 → 跳转首页
    if (to.meta.requiresAdmin && !isAdmin) {
        next({ name: 'Home' })
        return
    }

    // 需要游客状态但已登录 → 跳转首页
    if (to.meta.requiresGuest && isLoggedIn) {
        next({ name: 'Home' })
        return
    }

    // 其他情况放行
    next()
})


export default router
