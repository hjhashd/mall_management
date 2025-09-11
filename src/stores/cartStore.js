import { defineStore } from 'pinia';
import { getCartSummary, getCartItems } from '@/api/cart'; // 确保导入 getCartItems

export const useCartStore = defineStore('cart', {
    state: () => ({
        totalQuantity: 0,
        totalPrice: 0,
        itemCount: 0,
        initialized: false,
        items: [], // 新增 items 数组来存储购物车商品
    }),
    actions: {
        // 获取购物车统计数据
        async fetchCartSummary() {
            try {
                const response = await getCartSummary();
                if (response.data.success) {
                    const { totalQuantity, totalPrice, itemCount } = response.data.data;
                    this.totalQuantity = totalQuantity;
                    this.totalPrice = parseFloat(totalPrice);
                    this.itemCount = itemCount;
                    this.initialized = true;
                }
            } catch (error) {
                console.error('获取购物车统计失败:', error);
            }
        },

        // 新增：获取购物车商品列表
        async fetchCartItems() {
            try {
                const response = await getCartItems();
                if (response.data.success) {
                    this.items = response.data.data;
                }
            } catch (error) {
                console.error('获取购物车商品失败:', error);
            }
        },

        // 新增：获取特定商品的数量
        getItemQuantity(productId) {
            if (!this.items.length) return 0;
            const item = this.items.find(item => item.productId === productId);
            return item ? item.quantity : 0;
        },

        // 更新购物车统计（添加商品时调用）
        updateCartSummary(quantity, price) {
            this.totalQuantity += quantity;
            this.totalPrice += price * quantity;
            this.itemCount += 1;
        },

        // 减少购物车统计（删除商品时调用）
        decreaseCartSummary(quantity, price) {
            this.totalQuantity -= quantity;
            this.totalPrice -= price * quantity;
            this.itemCount -= 1;
        }
    },
});
