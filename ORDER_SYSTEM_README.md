# 订单确认系统

## 功能概述

这是一个完整的订单确认和支付系统，包含以下主要功能：

1. **购物车管理** - 查看、修改、删除购物车商品
2. **订单确认** - 填写收货信息、选择支付方式
3. **订单提交** - 调用后端API创建订单
4. **订单列表** - 查看所有订单状态

## 系统架构

### 前端组件

- `CartPage.vue` - 购物车页面
- `OrderConfirm.vue` - 订单确认页面
- `OrderList.vue` - 订单列表页面
- `CartItem.vue` - 购物车商品项组件
- `CartSummary.vue` - 购物车摘要组件

### 后端API

- `POST /api/order/checkout` - 提交订单
- `GET /api/user/balance` - 获取用户余额
- `GET /api/order/list` - 获取订单列表
- `GET /api/cart/items` - 获取购物车商品

## 数据库表结构

### orders 表
```sql
CREATE TABLE `orders` (
  `order_id` varchar(64) NOT NULL COMMENT '订单号',
  `user_id` int NOT NULL COMMENT '买家用户ID',
  `seller_id` int NOT NULL COMMENT '卖家用户ID',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `status` tinyint NOT NULL COMMENT '订单状态：1-待付款, 2-待发货, 3-待收货, 4-已完成, 5-已取消, 6-退款中, 7-已退款',
  `payment_method` varchar(50) COMMENT '支付方式：wechat, alipay, balance',
  `shipping_address_id` int COMMENT '收货地址ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '订单创建时间',
  `paid_at` datetime COMMENT '支付时间',
  `shipped_at` datetime COMMENT '发货时间',
  `received_at` datetime COMMENT '收货时间',
  `completed_at` datetime COMMENT '完成时间',
  `user_remark` text COMMENT '买家备注',
  `shipping_company` varchar(50) COMMENT '物流公司名称',
  `tracking_number` varchar(50) COMMENT '物流单号',
  `logistics_status` varchar(20) DEFAULT '已发货' COMMENT '物流状态',
  `is_deleted` tinyint(1) DEFAULT 0 COMMENT '软删除标记'
);
```

### order_items 表
```sql
CREATE TABLE `order_items` (
  `item_id` int NOT NULL AUTO_INCREMENT COMMENT '订单项ID',
  `order_id` varchar(64) NOT NULL COMMENT '关联订单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '购买数量',
  `price` decimal(10, 2) NOT NULL COMMENT '成交单价',
  `condition` tinyint COMMENT '商品成色（下单时快照）',
  `item_status` tinyint DEFAULT 1 COMMENT '订单项状态：1-正常, 2-售后中, 3-已退款'
);
```

## 使用流程

### 1. 购物车到订单确认

1. 用户在购物车页面点击"立即结算"
2. 系统将购物车数据存储到localStorage作为备用
3. 跳转到订单确认页面，传递购物车数据
4. 订单确认页面从路由state或localStorage获取购物车数据

### 2. 订单确认流程

1. 用户填写收货地址、收货人、联系电话
2. 选择物流公司
3. 选择支付方式（支付宝、微信、余额支付）
4. 填写订单备注（可选）
5. 点击"提交订单"按钮

### 3. 订单提交

1. 前端验证必填信息
2. 检查余额是否足够（如果选择余额支付）
3. 调用后端API提交订单
4. 显示提交结果
5. 成功后跳转到订单列表页面

## 支付方式

### 余额支付
- 系统会检查用户余额是否足够
- 余额不足时提示用户选择其他支付方式

### 第三方支付
- 支付宝支付
- 微信支付
- 这些支付方式需要后端集成相应的支付SDK

## 错误处理

### 前端验证
- 收货信息完整性验证
- 物流公司选择验证
- 支付方式选择验证
- 余额充足性验证

### 后端错误
- 库存不足
- 余额不足
- 网络错误
- 系统错误

## 状态管理

### 订单状态
- 1: 待付款
- 2: 待发货
- 3: 待收货
- 4: 已完成
- 5: 已取消
- 6: 退款中
- 7: 已退款

### 组件状态
- `loading` - 加载状态
- `submitting` - 提交状态
- `showToast` - 提示框显示状态

## 样式系统

### 颜色变量
```css
:root {
  --primary-color: #5c9e53;      /* 主色调 - 绿色 */
  --secondary-color: #f7faf5;    /* 背景色 - 淡灰绿 */
  --hover-color: #e6f0e6;        /* 悬浮色 - 淡绿 */
  --text-muted-color: #6b7a63;   /* 文字色 - 灰绿 */
  --border-color: #d7e3d7;       /* 边框色 - 淡绿 */
  --shadow-color: rgba(92, 158, 83, 0.15); /* 阴影色 */
}
```

### 响应式设计
- 支持移动端和桌面端
- 使用Bootstrap栅格系统
- 移动端优化布局

## 开发注意事项

### 1. 数据传递
- 购物车数据通过路由state传递
- 使用localStorage作为备用存储
- 确保数据结构的兼容性

### 2. 错误处理
- 所有API调用都要有错误处理
- 用户友好的错误提示
- 网络错误的优雅降级

### 3. 用户体验
- 加载状态的显示
- 提交状态的反馈
- 成功/失败的明确提示

### 4. 安全性
- 用户身份验证
- 数据验证
- XSS防护

## 扩展功能

### 可能的改进
1. 地址管理功能
2. 优惠券系统
3. 积分系统
4. 订单跟踪
5. 售后服务
6. 评价系统

### 技术优化
1. 状态管理优化
2. 性能优化
3. 缓存策略
4. 离线支持

## 测试建议

### 功能测试
1. 购物车到订单确认的完整流程
2. 各种支付方式的选择
3. 错误情况的处理
4. 边界条件的验证

### 兼容性测试
1. 不同浏览器的兼容性
2. 移动端和桌面端的适配
3. 不同屏幕尺寸的响应式

### 性能测试
1. 页面加载速度
2. API响应时间
3. 内存使用情况

## 部署说明

### 环境要求
- Node.js 16+
- Vue 3
- Pinia
- Bootstrap 5
- Font Awesome

### 构建命令
```bash
npm install
npm run build
```

### 部署注意事项
1. 确保API接口的正确配置
2. 检查跨域设置
3. 配置正确的环境变量
4. 测试支付功能的集成 