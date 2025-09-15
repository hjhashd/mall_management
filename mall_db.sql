/*
 Navicat Premium Data Transfer

 Source Server         : demo
 Source Server Type    : MySQL
 Source Server Version : 80040
 Source Host           : localhost:3306
 Source Schema         : mall_db

 Target Server Type    : MySQL
 Target Server Version : 80040
 File Encoding         : 65001

 Date: 15/09/2025 09:18:34
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for after_sales
-- ----------------------------
DROP TABLE IF EXISTS `after_sales`;
CREATE TABLE `after_sales`  (
  `after_sale_id` int NOT NULL AUTO_INCREMENT COMMENT '售后记录ID',
  `order_item_id` int NOT NULL COMMENT '关联订单项ID',
  `type` tinyint NOT NULL COMMENT '售后类型：1-退货, 2-换货, 3-仅退款',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请原因',
  `status` tinyint NULL DEFAULT 0 COMMENT '处理状态：0-申请中, 1-卖家同意, 2-卖家拒绝, 3-处理中, 4-已完成, 5-待管理员处理, 6-管理员同意, 7-管理员拒绝',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `processed_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `refund_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '退款金额',
  `evidence_images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '凭证图片URL，多个用逗号分隔',
  `tracking_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货物流单号',
  `seller_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '卖家处理备注',
  `admin_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '平台管理员处理备注',
  PRIMARY KEY (`after_sale_id`) USING BTREE,
  INDEX `fk_after_sale_item`(`order_item_id` ASC) USING BTREE,
  CONSTRAINT `fk_after_sale_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`item_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '售后服务表，记录退货/退款流程' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of after_sales
-- ----------------------------
INSERT INTO `after_sales` VALUES (2, 14, 1, '书不够好', 6, '2025-08-26 11:10:33', '2025-08-26 15:22:12', '2025-08-26 15:22:12', 18.00, 'http://localhost:8080/uploads/after-sales-evidence/86c73fb3-279b-4d5a-b59c-acda8fb4ea9e.jpg', NULL, '哪里不好了，这么多年都是这样', '七天无条件退款');
INSERT INTO `after_sales` VALUES (3, 16, 3, '辣鸡游戏', 6, '2025-08-27 10:47:24', '2025-08-27 14:41:41', '2025-08-27 14:41:41', 45.00, 'http://localhost:8080/uploads/after-sales-evidence/a6e562c8-e9f3-4be1-a030-56568cdd9b5a.png', NULL, '虚假理由', '七天无条件退款');
INSERT INTO `after_sales` VALUES (5, 17, 3, '不好吃', 7, '2025-08-27 15:59:58', '2025-08-27 16:13:06', '2025-08-27 16:13:06', 32.00, NULL, NULL, '这不是用来吃的', '拼图不是食物，卖方有理');
INSERT INTO `after_sales` VALUES (6, 17, 1, '不好吃', 7, '2025-09-03 14:54:26', '2025-09-03 15:38:14', NULL, 32.00, 'http://localhost:8080/uploads/after-sales-evidence/9d45aaab-5478-44ca-9e9f-b604d8d8542c.png', NULL, '卡片不能吃的', '卖家有理');
INSERT INTO `after_sales` VALUES (7, 18, 1, 'dfhbg', 0, '2025-09-03 15:58:41', NULL, NULL, 45.00, NULL, NULL, NULL, NULL);
INSERT INTO `after_sales` VALUES (8, 19, 1, 'lj', 6, '2025-09-03 16:11:00', '2025-09-03 16:12:13', '2025-09-03 16:12:13', 45.00, NULL, NULL, '666', '七天无理由退款');
INSERT INTO `after_sales` VALUES (9, 20, 3, '不好吃', 6, '2025-09-03 16:39:14', '2025-09-03 16:42:31', '2025-09-03 16:42:31', 32.00, 'http://localhost:8080/uploads/after-sales-evidence/f8988a56-ba74-4813-8769-a07a1f9062bd.jpg', NULL, '不能吃的亲', '七天无理由退款');

-- ----------------------------
-- Table structure for ai_conversation
-- ----------------------------
DROP TABLE IF EXISTS `ai_conversation`;
CREATE TABLE `ai_conversation`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话ID',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户ID',
  `summary` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'AI生成的摘要',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_conversation_id`(`conversation_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI会话摘要表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_conversation
-- ----------------------------
INSERT INTO `ai_conversation` VALUES (2, 'web_1757760086505', '3', 'DeepSeek-V3功能介绍与R1调用咨询', '2025-09-13 18:41:32', '2025-09-13 18:43:11');
INSERT INTO `ai_conversation` VALUES (4, 'web_1757760380345', '3', 'DeepSeek-V3功能介绍与版本说明', '2025-09-13 18:46:24', '2025-09-13 18:52:16');

-- ----------------------------
-- Table structure for ai_record
-- ----------------------------
DROP TABLE IF EXISTS `ai_record`;
CREATE TABLE `ai_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL,
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_conversation`(`conversation_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_record
-- ----------------------------
INSERT INTO `ai_record` VALUES (24, '3', '你是谁', '我是DeepSeek-V3，一个由深度求索公司创造的智能助手！🤖💡我可以帮助你解答各种问题、提供建议、进行知识查询，甚至陪你聊天！无论是学习、工作还是日常生活中的疑问，尽管问我吧~✨有什么我可以帮你的吗？😊', 'deepseek-chat', '2025-09-13 18:41:32', 'web_1757760086505');
INSERT INTO `ai_record` VALUES (25, '3', '我可以调用r1吗', '关于“调用R1”，目前可能有不同的理解，如果您指的是以下两种情况，我可以为您提供相关信息：\n\n1. **如果是编程中的变量或函数**（例如在代码中调用名为 `r1` 的对象）：  \n   - 请提供更多上下文（例如编程语言、使用场景），我会帮您分析如何正确调用它。\n\n2. **如果您指的是“DeepSeek-V3 R1”**（例如某种模型或API）：  \n   - 目前深度求索（DeepSeek）已开源多个模型，但具体是否提供名为“R1”的调用接口或功能，建议访问[官方文档](https://deepseek.com)或GitHub页面获取最新信息。\n\n如果您有其他具体需求，欢迎补充说明，我会尽力协助！ 😊', 'deepseek-chat', '2025-09-13 18:43:07', 'web_1757760086505');
INSERT INTO `ai_record` VALUES (26, '3', '你是v3吗', '我是DeepSeek-V3，由深度求索公司开发。如果你有任何问题或需要帮助，随时问我！😊', 'deepseek-chat', '2025-09-13 18:46:24', 'web_1757760380345');
INSERT INTO `ai_record` VALUES (27, '3', '那v3.1呢', '目前，DeepSeek 最新的官方版本是 **DeepSeek-V3**，并没有正式发布过名为 **V3.1** 的版本。如果你看到相关的信息，可能是误解或者非官方的消息。  \n\n如果你对 DeepSeek 的版本更新感兴趣，可以关注 **深度求索的官方网站或官方社交媒体**，以获取最新的发布信息！😊 有什么我可以帮助你的吗？', 'deepseek-chat', '2025-09-13 18:46:59', 'web_1757760380345');
INSERT INTO `ai_record` VALUES (28, '3', '你可以查看图片吗', '目前，**DeepSeek-V3** 不支持查看或分析图片、视频等文件。我只能处理文本内容，帮助你解答问题、分析文档、提供建议等。  \n\n如果你有图片相关的问题（比如描述图片内容），可以尝试用文字描述给我，我会尽力帮你分析！😊', 'deepseek-chat', '2025-09-13 18:52:13', 'web_1757760380345');
INSERT INTO `ai_record` VALUES (29, '3', '随便给我一个表格？我要测试一下你的能力', '当然！这里有一个简单的示例表格，展示了一些虚构的学生成绩数据：\n\n| 学生姓名   | 学科       | 成绩 | 等级 | 备注         |\n|------------|------------|------|------|--------------|\n| 张三       | 数学       | 92   | A    | 表现优异       |\n| 李四       | 英语       | 85   | B+   | 稳步提升       |\n| 王五       | 物理       | 78   | C+   | 需加强练习     |\n| 赵六       | 化学       | 88   | A-   | 有潜力        |\n| 钱七       | 生物       | 95   | A+   | 几乎满分      |\n\n如果需要更复杂的数据分析、格式调整或特定类型的表格，可以告诉我你的需求！ 😊', 'deepseek-chat', '2025-09-13 18:53:00', 'web_1757760380345');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `cart_id` int NOT NULL AUTO_INCREMENT COMMENT '购物车记录ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '商品数量',
  `is_selected` tinyint(1) NULL DEFAULT 1 COMMENT '是否选中: 0-未选中, 1-已选中',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`cart_id`) USING BTREE,
  UNIQUE INDEX `uq_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE COMMENT '用户与商品的唯一组合',
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 42 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户购物车表（合并优化版）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (40, 1, 33, 1, 1, '2025-09-08 09:45:31', '2025-09-08 09:45:31');
INSERT INTO `cart` VALUES (41, 3, 6, 1, 1, '2025-09-12 15:12:13', '2025-09-12 15:12:13');

-- ----------------------------
-- Table structure for chat_messages
-- ----------------------------
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages`  (
  `message_id` int NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `chat_id` int NOT NULL COMMENT '关联会话ID',
  `sender_id` int NOT NULL COMMENT '发送者ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读：0-未读, 1-已读',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `message_type` tinyint NULL DEFAULT 1 COMMENT '消息类型：1-文本, 2-图片, 3-商品卡片',
  `attachment_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '附件URL',
  PRIMARY KEY (`message_id`) USING BTREE,
  INDEX `fk_message_chat`(`chat_id` ASC) USING BTREE,
  CONSTRAINT `fk_message_chat` FOREIGN KEY (`chat_id`) REFERENCES `user_chats` (`chat_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '聊天消息表，存储实时通信内容' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_messages
-- ----------------------------
INSERT INTO `chat_messages` VALUES (3, 2, 3, '你好啊', 1, '2025-08-10 15:59:10', 2, 'http://localhost:8080/uploads/chat/hello.png');
INSERT INTO `chat_messages` VALUES (4, 2, 3, '我是学生，商品可以便宜点吗', 1, '2025-08-20 16:08:51', 1, NULL);
INSERT INTO `chat_messages` VALUES (5, 2, 1, '可以的亲，我免费送你了', 1, '2025-08-20 16:12:09', 1, NULL);
INSERT INTO `chat_messages` VALUES (41, 2, 3, '谢谢', 0, '2025-08-27 00:38:13', 1, NULL);
INSERT INTO `chat_messages` VALUES (64, 10, 3, '你好', 1, '2025-08-27 14:44:01', 1, NULL);
INSERT INTO `chat_messages` VALUES (65, 10, 2, '你好', 1, '2025-08-27 14:45:03', 1, NULL);
INSERT INTO `chat_messages` VALUES (66, 10, 3, '商品还在吗', 1, '2025-08-27 14:45:25', 1, NULL);
INSERT INTO `chat_messages` VALUES (67, 10, 3, 'dd', 1, '2025-08-27 14:46:05', 1, NULL);
INSERT INTO `chat_messages` VALUES (68, 10, 3, '让人', 1, '2025-08-27 14:50:29', 1, NULL);
INSERT INTO `chat_messages` VALUES (69, 10, 3, '她她她', 1, '2025-08-27 14:59:44', 1, NULL);
INSERT INTO `chat_messages` VALUES (70, 10, 2, '222', 1, '2025-08-27 15:28:26', 1, NULL);
INSERT INTO `chat_messages` VALUES (71, 10, 2, '哈哈哈', 1, '2025-08-27 16:48:13', 1, NULL);
INSERT INTO `chat_messages` VALUES (72, 10, 3, '嘎嘎嘎', 1, '2025-08-27 17:10:02', 1, NULL);
INSERT INTO `chat_messages` VALUES (73, 10, 3, '哦？', 1, '2025-08-27 17:26:11', 1, NULL);
INSERT INTO `chat_messages` VALUES (74, 10, 3, '1', 1, '2025-08-27 22:38:44', 1, NULL);
INSERT INTO `chat_messages` VALUES (75, 10, 2, '111', 1, '2025-09-03 15:59:30', 1, NULL);
INSERT INTO `chat_messages` VALUES (76, 10, 3, '你好', 1, '2025-09-03 16:36:44', 1, NULL);

-- ----------------------------
-- Table structure for community_posts
-- ----------------------------
DROP TABLE IF EXISTS `community_posts`;
CREATE TABLE `community_posts`  (
  `post_id` int NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `user_id` int NOT NULL COMMENT '发帖用户ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子内容',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类：闲置攻略,鉴别技巧等',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览数',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `comment_count` int NULL DEFAULT 0 COMMENT '评论数',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-正常, 2-精华, 3-删除, 4-审核中',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发帖时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `featured_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图路径',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签，多个用逗号分隔',
  PRIMARY KEY (`post_id`) USING BTREE,
  INDEX `fk_post_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_post_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区帖子表，支持分类和标签' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of community_posts
-- ----------------------------
INSERT INTO `community_posts` VALUES (1, 1, '天然棉麻沙发求购攻略', '最近在寻找一款环保染色的天然棉麻沙发，预算在3000-4000元左右。希望找到性价比高、舒适度好的产品。有推荐的吗？', '家居生活', 156, 23, 8, 1, '2024-01-15 10:30:00', '2025-08-21 09:18:18', 'http://localhost:8080/uploads/community_posts/sofa.png', '沙发,环保,棉麻');
INSERT INTO `community_posts` VALUES (2, 2, '手工陶瓷茶具制作心得', '分享一下我制作手工陶瓷茶具的经验。从选土、拉坯到上釉、烧制，每一个环节都需要耐心和技巧。', '手工艺品', 89, 15, 3, 1, '2024-01-14 14:20:00', '2024-01-14 14:20:00', '/images/ceramic-tea-set.jpg', '陶瓷,手工,茶具');
INSERT INTO `community_posts` VALUES (3, 2, '有机蔬菜种植技巧', '在阳台种植有机蔬菜的一些小技巧分享。选择合适的土壤、控制浇水量、防治病虫害是关键。', '园艺绿植', 203, 31, 12, 2, '2024-01-13 09:15:00', '2024-01-13 09:15:00', '/images/organic-vegetables.jpg', '种植,有机,蔬菜');
INSERT INTO `community_posts` VALUES (4, 1, '天然植物染色T恤', '自己动手用天然植物染料制作的T恤，不仅环保还很有特色。分享制作过程和心得体会。', '天然服饰', 76, 18, 5, 1, '2024-01-12 16:45:00', '2024-01-12 16:45:00', '/images/natural-dye-tshirt.jpg', '服饰,植物染,手工');
INSERT INTO `community_posts` VALUES (5, 1, '古法红糖制作工艺', '介绍传统古法红糖的制作工艺，从甘蔗榨汁到熬制结晶，保留了更多的营养成分。', '美食分享', 134, 27, 7, 1, '2024-01-11 11:20:00', '2024-01-11 11:20:00', '/images/brown-sugar.jpg', '美食,传统,红糖');
INSERT INTO `community_posts` VALUES (6, 2, '竹制家具保养方法', '竹制家具的日常保养和维护方法，延长使用寿命的小窍门。', '家居生活', 67, 12, 4, 1, '2024-01-10 13:50:00', '2024-01-10 13:50:00', '/images/bamboo-furniture.jpg', '家具,竹制,保养');
INSERT INTO `community_posts` VALUES (7, 3, '多肉植物繁殖技巧', '分享几种多肉植物的繁殖方法：叶插、扦插、分株等，成活率很高的实用技巧。', '园艺绿植', 178, 35, 15, 1, '2024-01-09 15:30:00', '2024-01-09 15:30:00', '/images/succulent-propagation.jpg', '多肉,繁殖,园艺');
INSERT INTO `community_posts` VALUES (8, 1, '手工编织围巾教程', '详细的手工编织围巾教程，适合初学者。从起针到收针，每一步都有图解说明。', '手工艺品', 92, 20, 6, 1, '2024-01-08 18:10:00', '2024-01-08 18:10:00', '/images/knitting-scarf.jpg', '编织,手工,围巾');

-- ----------------------------
-- Table structure for content_moderations
-- ----------------------------
DROP TABLE IF EXISTS `content_moderations`;
CREATE TABLE `content_moderations`  (
  `moderation_id` bigint NOT NULL AUTO_INCREMENT COMMENT '审核记录ID',
  `content_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容类型：product, review, post, comment',
  `content_id` int NOT NULL COMMENT '内容ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容文本（用于敏感词检测）',
  `status` tinyint NULL DEFAULT 0 COMMENT '审核状态：0-待审核, 1-通过, 2-拒绝',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `moderator_id` int NULL DEFAULT NULL COMMENT '审核人ID（管理员）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `processed_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `ai_result` json NULL COMMENT 'AI审核结果（JSON格式）',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`moderation_id`) USING BTREE,
  INDEX `idx_content_type`(`content_type` ASC, `content_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '内容审核表，记录所有UGC内容的审核状态' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of content_moderations
-- ----------------------------
INSERT INTO `content_moderations` VALUES (1, 'product', 1, '二手iPhone 13 128G 蓝色 95新', 1, NULL, 3, '2025-08-01 09:19:14', '2025-07-28 11:00:00', NULL, NULL);
INSERT INTO `content_moderations` VALUES (2, 'product', 19, '百年孤独\n很好', 0, NULL, NULL, '2025-08-17 23:40:22', NULL, NULL, NULL);
INSERT INTO `content_moderations` VALUES (6, 'product', 24, '万年孤独\n很怀念', 0, NULL, NULL, '2025-08-18 09:56:53', NULL, NULL, '2025-09-03 16:19:06');
INSERT INTO `content_moderations` VALUES (8, 'product', 26, 'vivo\nvvvvvv', 0, NULL, NULL, '2025-09-01 16:14:11', NULL, NULL, '2025-09-01 16:14:11');
INSERT INTO `content_moderations` VALUES (9, 'product', 14, '大学生运动鞋\n阿迪达斯三叶草经典款运动鞋，42码，白色，九成新', 0, NULL, NULL, '2025-09-01 16:21:46', NULL, NULL, '2025-09-01 16:21:58');
INSERT INTO `content_moderations` VALUES (10, 'product', 27, '二手显示器\n24寸240HZ，分辨率1920*1080，刷新率240HZ，接口HDMI+DP，配件齐全，原包装，可以外接笔记本，IPS屏幕，便宜当二手处理的，有需要联系', 0, NULL, NULL, '2025-09-08 09:01:07', NULL, NULL, '2025-09-08 09:01:07');
INSERT INTO `content_moderations` VALUES (11, 'product', 28, '二手Redmi红米K30Pro骁龙865.6400万像素4摄游戏手机\n二手Redmi红米K30Pro骁龙865.6400万像素4摄游戏手机清仓便宜学生，退货包运费', 0, NULL, NULL, '2025-09-08 09:03:48', NULL, NULL, '2025-09-08 09:03:48');
INSERT INTO `content_moderations` VALUES (12, 'product', 29, '二手闲置九九新卡皮巴拉\n二手闲置九九新卡皮巴拉质量好，20厘米左右，搬家嫌麻烦就二手出了', 0, NULL, NULL, '2025-09-08 09:12:00', NULL, NULL, '2025-09-08 09:12:00');
INSERT INTO `content_moderations` VALUES (13, 'product', 30, '复古胶卷相机\n旧货旁轴相机胶卷机械 复古胶卷相机 收藏品红梅 ganguang 装饰品 ', 0, NULL, NULL, '2025-09-08 09:14:02', NULL, NULL, '2025-09-08 09:14:02');
INSERT INTO `content_moderations` VALUES (14, 'product', 31, '二手充电宝30000毫安\n处理二手充电宝30000毫安包邮移动电源不挑随机发货便宜随机发', 0, NULL, NULL, '2025-09-08 09:15:11', NULL, NULL, '2025-09-08 09:28:11');
INSERT INTO `content_moderations` VALUES (15, 'product', 32, '女小白鞋\n闲置二手【2双】女小白鞋板鞋运动鞋平底单鞋休闲鞋', 0, NULL, NULL, '2025-09-08 09:16:14', NULL, NULL, '2025-09-08 09:25:29');
INSERT INTO `content_moderations` VALUES (16, 'product', 33, '华强北s10顶配智能手表\n华强北s10顶配智能手表信息提醒蓝牙通话灵动岛心率监测运动手环', 0, NULL, NULL, '2025-09-08 09:17:52', NULL, NULL, '2025-09-08 09:17:52');
INSERT INTO `content_moderations` VALUES (17, 'product', 34, '二手篮球\n清仓二手七号橡胶篮球,高弹耐磨,室内室外均用篮球便宜', 0, NULL, NULL, '2025-09-08 09:19:09', NULL, NULL, '2025-09-08 09:28:25');
INSERT INTO `content_moderations` VALUES (18, 'product', 35, '小米吹风机\n【二手】小米吹风机H101米家便携负离子筒可折叠电吹风机速干护发退货包运费', 0, NULL, NULL, '2025-09-08 09:20:27', NULL, NULL, '2025-09-08 09:20:27');
INSERT INTO `content_moderations` VALUES (19, 'product', 13, '女士秋冬毛衣\n优衣库女士羊毛混纺毛衣，M码，米白色，保暖舒适', 0, NULL, NULL, '2025-09-13 19:30:26', NULL, NULL, '2025-09-13 19:30:26');

-- ----------------------------
-- Table structure for feedbacks
-- ----------------------------
DROP TABLE IF EXISTS `feedbacks`;
CREATE TABLE `feedbacks`  (
  `feedback_id` int NOT NULL AUTO_INCREMENT COMMENT '反馈记录ID',
  `user_id` int NOT NULL COMMENT '提交反馈的用户ID（关联users表）',
  `feedback_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈类型：suggestion-建议, complaint-投诉, bug-系统bug, other-其他',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈内容',
  `contact_way` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户预留联系方式（可选）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '处理状态：0-待处理, 1-处理中, 2-已解决, 3-无法解决',
  `handler_id` int NULL DEFAULT NULL COMMENT '处理人ID（管理员用户ID）',
  `reply_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '管理员回复内容',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `replied_at` datetime NULL DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`feedback_id`) USING BTREE,
  INDEX `fk_feedback_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_feedback_handler`(`handler_id` ASC) USING BTREE,
  INDEX `idx_feedback_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_feedback_handler` FOREIGN KEY (`handler_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户反馈表（支持管理员回复并通过messages表推送给用户）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of feedbacks
-- ----------------------------
INSERT INTO `feedbacks` VALUES (1, 1, 'suggestion', '希望增加商品对比功能', '13800138001', 0, NULL, NULL, '2025-08-01 09:19:14', NULL);

-- ----------------------------
-- Table structure for logistics_tracking
-- ----------------------------
DROP TABLE IF EXISTS `logistics_tracking`;
CREATE TABLE `logistics_tracking`  (
  `tracking_id` int NOT NULL AUTO_INCREMENT COMMENT '跟踪记录ID',
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联订单ID',
  `tracking_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物流单号',
  `shipping_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物流公司名称',
  `tracking_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物流状态',
  `tracking_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流描述',
  `tracking_time` datetime NOT NULL COMMENT '物流时间',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流位置',
  `operator` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作员',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`tracking_id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_tracking_number`(`tracking_number` ASC) USING BTREE,
  INDEX `idx_tracking_time`(`tracking_time` ASC) USING BTREE,
  CONSTRAINT `fk_tracking_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '物流跟踪表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of logistics_tracking
-- ----------------------------

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
  `message_id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `type` enum('system','user','marketing') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息类型',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `status` enum('draft','sent','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'draft' COMMENT '发送状态',
  `scheduled_time` datetime NULL DEFAULT NULL COMMENT '定时发送时间',
  `send_time` datetime NULL DEFAULT NULL COMMENT '实际发送时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of message
-- ----------------------------
INSERT INTO `message` VALUES (13, 'user', '嘎嘎嘎', '都是对的', 'sent', NULL, '2025-08-28 11:09:16', '2025-08-28 11:09:16', '2025-08-28 11:09:16');
INSERT INTO `message` VALUES (14, 'system', '各地纷纷', '收费方式', 'sent', NULL, '2025-08-28 11:22:48', '2025-08-28 11:22:47', '2025-08-28 11:22:47');
INSERT INTO `message` VALUES (15, 'system', '能不能发送消息试一下', '111888', 'sent', NULL, '2025-08-29 16:40:52', '2025-08-29 16:40:51', '2025-08-29 16:40:51');
INSERT INTO `message` VALUES (16, 'system', '测试水水水水', '宝宝v能不能计划', 'sent', NULL, '2025-09-03 16:21:11', '2025-09-03 16:21:10', '2025-09-03 16:21:10');
INSERT INTO `message` VALUES (17, 'system', '测试', '踩踩踩踩踩踩踩踩踩', 'sent', NULL, '2025-09-03 16:43:15', '2025-09-03 16:43:14', '2025-09-03 16:43:14');

-- ----------------------------
-- Table structure for message_recipient_group
-- ----------------------------
DROP TABLE IF EXISTS `message_recipient_group`;
CREATE TABLE `message_recipient_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `message_id` bigint NOT NULL,
  `group_type` enum('all','vip','normal') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '接收组类型',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `message_id`(`message_id` ASC) USING BTREE,
  CONSTRAINT `message_recipient_group_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `message` (`message_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息接收组' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of message_recipient_group
-- ----------------------------
INSERT INTO `message_recipient_group` VALUES (6, 13, 'all');
INSERT INTO `message_recipient_group` VALUES (8, 14, 'all');
INSERT INTO `message_recipient_group` VALUES (9, 15, 'all');
INSERT INTO `message_recipient_group` VALUES (10, 16, 'all');
INSERT INTO `message_recipient_group` VALUES (11, 17, 'all');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `notification_id` int NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` int NOT NULL COMMENT '接收通知的用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型 (e.g., ORDER_SHIPPED, NEW_MESSAGE, SYSTEM_ALERT)',
  `content` json NOT NULL COMMENT '通知内容 (JSON格式，存储具体信息)',
  `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`notification_id`) USING BTREE,
  INDEX `idx_user_id_is_read`(`user_id` ASC, `is_read` ASC) USING BTREE COMMENT '用于快速查询用户的未读消息'
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (3, 3, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 1756260734215abf48fe4 已发货！\", \"orderId\": \"1756260734215abf48fe4\", \"trackingNumber\": \"test9999999\", \"shippingCompany\": \"中通快递\"}', 1, NULL);
INSERT INTO `notifications` VALUES (4, 3, 'AFTER_SALE_PROCESSED', '{\"link\": \"/user/after-sales\", \"title\": \"售后申请已处理\", \"message\": \"您对商品“三国杀标准版桌游”的售后申请，商家已处理：已拒绝。\", \"afterSaleId\": 3}', 1, NULL);
INSERT INTO `notifications` VALUES (5, 3, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 1756280244212afdbdaf2 已发货！\", \"orderId\": \"1756280244212afdbdaf2\", \"trackingNumber\": \"yyy123456\", \"shippingCompany\": \"顺丰速运\"}', 1, NULL);
INSERT INTO `notifications` VALUES (6, 2, 'AFTER_SALE_APPLICATION', '{\"link\": \"/seller-order?category=after-sales\", \"title\": \"新的售后申请\", \"message\": \"买家对商品“儿童益智拼图1000片”发起了售后申请，请及时处理。\", \"afterSaleId\": 5, \"orderItemId\": 17}', 1, NULL);
INSERT INTO `notifications` VALUES (7, 3, 'AFTER_SALE_PROCESSED', '{\"link\": \"/orders\", \"title\": \"售后申请已处理\", \"message\": \"您对商品“儿童益智拼图1000片”的售后申请，商家已处理：已拒绝。\", \"afterSaleId\": 5}', 1, NULL);
INSERT INTO `notifications` VALUES (8, 3, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台拒绝退款\", \"adminRemark\": \"拼图不是食物，卖方有理\", \"afterSaleId\": 5, \"orderItemId\": 17, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (9, 2, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台拒绝退款\", \"adminRemark\": \"拼图不是食物，卖方有理\", \"afterSaleId\": 5, \"orderItemId\": 17, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (10, 3, 'ADMIN_MESSAGE_UPDATE', '{\"title\": \"后台消息更新\", \"status\": \"draft\", \"message\": \"消息 \\\"系统维护通知草稿\\\" 已成功存为草稿。\", \"messageId\": 8}', 1, NULL);
INSERT INTO `notifications` VALUES (11, 3, 'ADMIN_MESSAGE_UPDATE', '{\"title\": \"后台消息更新\", \"status\": \"draft\", \"message\": \"消息 \\\"系统维护通知草稿\\\" 已成功存为草稿。\", \"messageId\": 9}', 1, NULL);
INSERT INTO `notifications` VALUES (12, 3, 'ADMIN_MESSAGE_UPDATE', '{\"title\": \"后台消息更新\", \"status\": \"sent\", \"message\": \"消息 \\\"测试一下\\\" 已成功发送。\", \"messageId\": 10}', 1, NULL);
INSERT INTO `notifications` VALUES (13, 3, 'ADMIN_MESSAGE_UPDATE', '{\"title\": \"后台消息更新\", \"status\": \"draft\", \"message\": \"消息 \\\"地方\\\" 已成功存为草稿。\", \"messageId\": 12}', 1, NULL);
INSERT INTO `notifications` VALUES (17, 2, 'NEW_FOLLOWER', '{\"link\": \"/seller-dashboard/followers\", \"title\": \"您有新的粉丝\", \"message\": \"用户 “admin” 刚刚关注了您的店铺！\", \"followerId\": 3}', 1, NULL);
INSERT INTO `notifications` VALUES (18, 2, 'AFTER_SALE_APPLICATION', '{\"link\": \"/seller-order?category=after-sales\", \"title\": \"新的售后申请\", \"message\": \"买家对商品“儿童益智拼图1000片”发起了售后申请，请及时处理。\", \"afterSaleId\": 6, \"orderItemId\": 17}', 1, NULL);
INSERT INTO `notifications` VALUES (19, 3, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 1755331149437b554c58f 已发货！\", \"orderId\": \"1755331149437b554c58f\", \"trackingNumber\": \"54122445\", \"shippingCompany\": \"申通快递\"}', 1, NULL);
INSERT INTO `notifications` VALUES (20, 3, 'AFTER_SALE_PROCESSED', '{\"link\": \"/orders\", \"title\": \"售后申请已处理\", \"message\": \"您对商品“儿童益智拼图1000片”的售后申请，商家已处理：已拒绝。\", \"afterSaleId\": 6}', 1, NULL);
INSERT INTO `notifications` VALUES (21, 3, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台拒绝退款\", \"adminRemark\": \"卖家有理\", \"afterSaleId\": 6, \"orderItemId\": 17, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (22, 2, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台拒绝退款\", \"adminRemark\": \"卖家有理\", \"afterSaleId\": 6, \"orderItemId\": 17, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (23, 2, 'AFTER_SALE_APPLICATION', '{\"link\": \"/seller-order?category=after-sales\", \"title\": \"新的售后申请\", \"message\": \"买家对商品“三国杀标准版桌游”发起了售后申请，请及时处理。\", \"afterSaleId\": 7, \"orderItemId\": 18}', 1, NULL);
INSERT INTO `notifications` VALUES (24, 2, 'PENDING_SHIPMENT_REMINDER', '{\"link\": \"/seller-order?category=pending-shipment\", \"title\": \"您有新的待发货订单\", \"message\": \"您收到了一个新的订单，请尽快处理发货。订单号: 175688702137640125359\", \"orderId\": \"175688702137640125359\"}', 1, NULL);
INSERT INTO `notifications` VALUES (25, 3, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 175688702137640125359 已发货！\", \"orderId\": \"175688702137640125359\", \"trackingNumber\": \"1231521\", \"shippingCompany\": \"顺丰速运\"}', 1, NULL);
INSERT INTO `notifications` VALUES (26, 2, 'AFTER_SALE_APPLICATION', '{\"link\": \"/seller-order?category=after-sales\", \"title\": \"新的售后申请\", \"message\": \"买家对商品“三国杀标准版桌游”发起了售后申请，请及时处理。\", \"afterSaleId\": 8, \"orderItemId\": 19}', 1, NULL);
INSERT INTO `notifications` VALUES (27, 3, 'AFTER_SALE_PROCESSED', '{\"link\": \"/orders\", \"title\": \"售后申请已处理\", \"message\": \"您对商品“三国杀标准版桌游”的售后申请，商家已处理：已拒绝。\", \"afterSaleId\": 8}', 1, NULL);
INSERT INTO `notifications` VALUES (28, 3, 'ADMIN_JUDGMENT', '{\"reason\": \"lj\", \"result\": \"平台同意退款\", \"adminRemark\": \"七天无理由退款\", \"afterSaleId\": 8, \"orderItemId\": 19, \"productName\": \"三国杀标准版桌游\", \"refundAmount\": 45.0}', 1, NULL);
INSERT INTO `notifications` VALUES (29, 2, 'ADMIN_JUDGMENT', '{\"reason\": \"lj\", \"result\": \"平台同意退款\", \"adminRemark\": \"七天无理由退款\", \"afterSaleId\": 8, \"orderItemId\": 19, \"productName\": \"三国杀标准版桌游\", \"refundAmount\": 45.0}', 1, NULL);
INSERT INTO `notifications` VALUES (30, 2, 'NEW_FOLLOWER', '{\"link\": \"/seller-dashboard/followers\", \"title\": \"您有新的粉丝\", \"message\": \"用户 “admin” 刚刚关注了您的店铺！\", \"followerId\": 3}', 1, NULL);
INSERT INTO `notifications` VALUES (31, 2, 'PENDING_SHIPMENT_REMINDER', '{\"link\": \"/seller-order?category=pending-shipment\", \"title\": \"您有新的待发货订单\", \"message\": \"您收到了一个新的订单，请尽快处理发货。订单号: 175688865622770e2beef\", \"orderId\": \"175688865622770e2beef\"}', 1, NULL);
INSERT INTO `notifications` VALUES (32, 3, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 175688865622770e2beef 已发货！\", \"orderId\": \"175688865622770e2beef\", \"trackingNumber\": \"232121\", \"shippingCompany\": \"中通快递\"}', 1, NULL);
INSERT INTO `notifications` VALUES (33, 2, 'AFTER_SALE_APPLICATION', '{\"link\": \"/seller-order?category=after-sales\", \"title\": \"新的售后申请\", \"message\": \"买家对商品“儿童益智拼图1000片”发起了售后申请，请及时处理。\", \"afterSaleId\": 9, \"orderItemId\": 20}', 1, NULL);
INSERT INTO `notifications` VALUES (34, 3, 'AFTER_SALE_PROCESSED', '{\"link\": \"/orders\", \"title\": \"售后申请已处理\", \"message\": \"您对商品“儿童益智拼图1000片”的售后申请，商家已处理：已拒绝。\", \"afterSaleId\": 9}', 1, NULL);
INSERT INTO `notifications` VALUES (35, 3, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台同意退款\", \"adminRemark\": \"七天无理由退款\", \"afterSaleId\": 9, \"orderItemId\": 20, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (36, 2, 'ADMIN_JUDGMENT', '{\"reason\": \"不好吃\", \"result\": \"平台同意退款\", \"adminRemark\": \"七天无理由退款\", \"afterSaleId\": 9, \"orderItemId\": 20, \"productName\": \"儿童益智拼图1000片\", \"refundAmount\": 32.0}', 1, NULL);
INSERT INTO `notifications` VALUES (37, 2, 'NEW_FOLLOWER', '{\"link\": \"/seller-dashboard/followers\", \"title\": \"您有新的粉丝\", \"message\": \"用户 “admin” 刚刚关注了您的店铺！\", \"followerId\": 3}', 1, NULL);
INSERT INTO `notifications` VALUES (38, 2, 'NEW_FOLLOWER', '{\"link\": \"/seller-dashboard/followers\", \"title\": \"您有新的粉丝\", \"message\": \"用户 “admin” 刚刚关注了您的店铺！\", \"followerId\": 3}', 1, NULL);
INSERT INTO `notifications` VALUES (39, 2, 'PENDING_SHIPMENT_REMINDER', '{\"link\": \"/seller-order?category=pending-shipment\", \"title\": \"您有新的待发货订单\", \"message\": \"您收到了一个新的订单，请尽快处理发货。订单号: 1757295375221e0f939f6\", \"orderId\": \"1757295375221e0f939f6\"}', 1, NULL);
INSERT INTO `notifications` VALUES (40, 1, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 1757295375221e0f939f6 已发货！\", \"orderId\": \"1757295375221e0f939f6\", \"trackingNumber\": \"1231521\", \"shippingCompany\": \"中通快递\"}', 0, NULL);
INSERT INTO `notifications` VALUES (41, 2, 'PENDING_SHIPMENT_REMINDER', '{\"link\": \"/seller-order?category=pending-shipment\", \"title\": \"您有新的待发货订单\", \"message\": \"您收到了一个新的订单，请尽快处理发货。订单号: 1757295581115f3de238f\", \"orderId\": \"1757295581115f3de238f\"}', 1, NULL);
INSERT INTO `notifications` VALUES (42, 1, 'ORDER_SHIPPED', '{\"link\": \"/orders\", \"title\": \"订单已发货\", \"message\": \"您的订单 1757295581115f3de238f 已发货！\", \"orderId\": \"1757295581115f3de238f\", \"trackingNumber\": \"1111545454545\", \"shippingCompany\": \"顺丰速运\"}', 0, NULL);

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `item_id` int NOT NULL AUTO_INCREMENT COMMENT '订单项ID',
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联订单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称（下单时快照）',
  `product_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片（下单时快照）',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '购买数量',
  `unit_price` decimal(10, 2) NOT NULL COMMENT '成交单价',
  `total_price` decimal(10, 2) NOT NULL COMMENT '小计金额',
  `condition` tinyint NULL DEFAULT NULL COMMENT '商品成色（下单时快照）',
  `item_status` tinyint NULL DEFAULT 1 COMMENT '订单项状态：1-正常, 2-售后中, 3-已退款，4（卖家已拒绝）和 5（平台介入中）',
  `is_reviewed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已评价: 0-否, 1-是',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单商品项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (6, '1754988857930c2798c60', 1, '二手iPhone 13 128G 蓝色 95新', NULL, 1, 4500.00, 4500.00, 2, 1, 0, '2025-08-12 16:54:18');
INSERT INTO `order_items` VALUES (7, '1754991130151ce91c1f3', 2, '二手MacBook Air M1 256G 银色 9成新', NULL, 1, 6800.00, 6800.00, 3, 1, 1, '2025-08-12 17:32:10');
INSERT INTO `order_items` VALUES (8, 'TEST20241201001', 1, '测试商品', NULL, 1, 99.99, 99.99, NULL, 1, 1, '2025-08-14 17:34:12');
INSERT INTO `order_items` VALUES (9, '1755331149437b554c58f', 1, '二手iPhone 13 128G 蓝色 95新', NULL, 1, 4500.00, 4500.00, 2, 1, 0, '2025-08-16 15:59:09');
INSERT INTO `order_items` VALUES (10, '1755331149437b554c58f', 2, '二手MacBook Air M1 256G 银色 9成新', NULL, 1, 6800.00, 6800.00, 3, 1, 0, '2025-08-16 15:59:09');
INSERT INTO `order_items` VALUES (11, '1755767101131c3cf1bc1', 10, '三国杀标准版桌游', NULL, 1, 45.00, 45.00, 2, 1, 1, '2025-08-21 17:05:01');
INSERT INTO `order_items` VALUES (12, '1755767101131c3cf1bc1', 14, '大学生运动鞋', NULL, 1, 150.00, 150.00, 3, 1, 0, '2025-08-21 17:05:01');
INSERT INTO `order_items` VALUES (13, '175608865807525fb60d6', 8, '活着 余华著', 'http://localhost:8080/uploads/products/alive.png', 1, 18.00, 18.00, 4, 1, 1, '2025-08-25 10:24:18');
INSERT INTO `order_items` VALUES (14, '1756123209466736d9bfa', 8, '活着 余华著', 'http://localhost:8080/uploads/products/alive.png', 1, 18.00, 18.00, 4, 3, 0, '2025-08-25 20:00:09');
INSERT INTO `order_items` VALUES (15, '1756260734215abf48fe4', 14, '大学生运动鞋', 'http://localhost:8080/uploads/products/yundongxie.png', 1, 150.00, 150.00, 3, 1, 1, '2025-08-27 10:12:14');
INSERT INTO `order_items` VALUES (16, '1756260734215abf48fe4', 10, '三国杀标准版桌游', 'http://localhost:8080/uploads/products/threecountrykill.png', 1, 45.00, 45.00, 2, 3, 0, '2025-08-27 10:12:14');
INSERT INTO `order_items` VALUES (17, '1756280244212afdbdaf2', 11, '儿童益智拼图1000片', 'http://localhost:8080/uploads/products/xiaogou.png', 1, 32.00, 32.00, 3, 1, 1, '2025-08-27 15:37:24');
INSERT INTO `order_items` VALUES (18, '1756886250312f62489fc', 10, '三国杀标准版桌游', 'http://localhost:8080/uploads/products/threecountrykill.png', 1, 45.00, 45.00, 2, 2, 0, '2025-09-03 15:57:30');
INSERT INTO `order_items` VALUES (19, '175688702137640125359', 10, '三国杀标准版桌游', 'http://localhost:8080/uploads/products/threecountrykill.png', 1, 45.00, 45.00, 2, 3, 0, '2025-09-03 16:10:21');
INSERT INTO `order_items` VALUES (20, '175688865622770e2beef', 11, '儿童益智拼图1000片', 'http://localhost:8080/uploads/products/xiaogou.png', 1, 32.00, 32.00, 3, 3, 0, '2025-09-03 16:37:36');
INSERT INTO `order_items` VALUES (21, '1757295375221e0f939f6', 35, '小米吹风机', 'http://localhost:8080/uploads/products/6fe72a52-ce3c-4213-b9f2-da18c1804adc.jpg', 1, 55.00, 55.00, 2, 1, 1, '2025-09-08 09:36:15');
INSERT INTO `order_items` VALUES (22, '1757295581115f3de238f', 27, '二手显示器', 'http://localhost:8080/uploads/products/7c987e47-dacf-4bc4-b497-d4dc48395b21.jpg', 1, 339.00, 339.00, 4, 1, 1, '2025-09-08 09:39:41');
INSERT INTO `order_items` VALUES (23, '1757295581115f3de238f', 28, '二手Redmi红米K30Pro骁龙865.6400万像素4摄游戏手机', 'http://localhost:8080/uploads/products/5e5a2318-0be6-485a-9664-f7340641685d.jpg', 1, 319.00, 319.00, 1, 1, 1, '2025-09-08 09:39:41');
INSERT INTO `order_items` VALUES (24, '1757295581115f3de238f', 29, '二手闲置九九新卡皮巴拉', 'http://localhost:8080/uploads/products/e673fcca-064c-451c-85c4-9923e0498d11.jpg', 1, 8.80, 8.80, 4, 1, 1, '2025-09-08 09:39:41');
INSERT INTO `order_items` VALUES (25, '1757295581115f3de238f', 31, '二手充电宝30000毫安', 'http://localhost:8080/uploads/products/e696bec4-e61c-4030-bb0f-1f22deb696e8.jpg', 1, 29.90, 29.90, 3, 1, 1, '2025-09-08 09:39:41');
INSERT INTO `order_items` VALUES (26, '1757295581115f3de238f', 33, '华强北s10顶配智能手表', 'http://localhost:8080/uploads/products/38117c77-3c71-42a5-b360-60487b2feaff.jpg', 1, 38.00, 38.00, 1, 1, 1, '2025-09-08 09:39:41');
INSERT INTO `order_items` VALUES (27, '1757295581115f3de238f', 34, '二手篮球', 'http://localhost:8080/uploads/products/f44e5f4b-b6c3-4b8d-b3cf-067500118c3f.jpg', 1, 28.00, 28.00, 3, 1, 0, '2025-09-08 09:39:41');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号（时间戳+随机数）',
  `user_id` int NOT NULL COMMENT '买家用户ID',
  `seller_id` int NOT NULL COMMENT '卖家用户ID',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '订单状态：1-待付款, 2-待发货, 3-待收货, 4-已完成, 5-已取消, 6-退款中, 7-已退款',
  `shipping_address_id` int NULL DEFAULT NULL COMMENT '收货地址ID',
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式：wechat, alipay, balance',
  `transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方支付平台交易号',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人电话',
  `shipping_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货地址详情',
  `shipping_company` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流公司名称',
  `tracking_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流单号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订单创建时间',
  `paid_at` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `shipped_at` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `received_at` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancelled_at` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `user_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '买家备注',
  `logistics_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '待发货' COMMENT '物流状态',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '软删除标记：0-正常, 1-删除',
  PRIMARY KEY (`order_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_seller_id`(`seller_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_shipping_address_id`(`shipping_address_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES ('1754988857930c2798c60', 3, 2, 4500.00, 2, 1, 'balance', NULL, '六百六十六', '12345678911', '北京市 北京市 海淀区 故宫紫禁城', '顺丰速运', NULL, '2025-08-12 16:54:18', '2025-08-12 16:54:18', NULL, NULL, NULL, NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1754991130151ce91c1f3', 3, 2, 6800.00, 4, 1, 'wechat', NULL, '六百六十六', '12345678911', '北京市 北京市 海淀区 故宫紫禁城', '中通快递', NULL, '2025-08-12 17:32:10', '2025-08-12 17:32:10', NULL, NULL, NULL, NULL, '哈哈哈哈哈哈哈哈哈哈', '待发货', 0);
INSERT INTO `orders` VALUES ('1755331149437b554c58f', 3, 2, 11300.00, 3, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 东城区 其他区县 故宫紫禁城', '申通快递', '54122445', '2025-08-16 15:59:09', '2025-08-16 15:59:09', '2025-09-03 15:30:26', NULL, '2025-08-18 16:11:20', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1755767101131c3cf1bc1', 3, 2, 195.00, 4, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 东城区 其他区县 故宫紫禁城', '中通快递', NULL, '2025-08-21 17:05:01', '2025-08-21 17:05:01', NULL, NULL, '2025-08-29 16:39:09', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('175608865807525fb60d6', 3, 2, 18.00, 4, 10, 'balance', NULL, '烦烦烦', '13624548545', '广东省 广州市 天河区 风格的法规规范', '中通快递', NULL, '2025-08-25 10:24:18', '2025-08-25 10:24:18', NULL, NULL, '2025-08-25 10:24:33', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1756123209466736d9bfa', 3, 2, 18.00, 7, 10, 'balance', NULL, '烦烦烦', '13624548545', '广东省 广州市 天河区 风格的法规规范', '顺丰速运', 'test14252364', '2025-08-25 20:00:09', '2025-08-25 20:00:09', '2025-08-26 09:45:53', NULL, '2025-08-26 15:22:12', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1756260734215abf48fe4', 3, 2, 195.00, 7, 10, 'balance', NULL, '烦烦烦', '13624548545', '广东省 广州市 天河区 风格的法规规范', '中通快递', 'test9999999', '2025-08-27 10:12:14', '2025-08-27 10:12:14', '2025-08-27 10:28:28', NULL, '2025-08-27 14:41:41', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1756280244212afdbdaf2', 3, 2, 32.00, 4, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 市辖区 朝阳区 故宫紫禁城', '顺丰速运', 'yyy123456', '2025-08-27 15:37:24', '2025-08-27 15:37:24', '2025-08-27 15:38:19', NULL, '2025-08-27 15:39:45', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1756886250312f62489fc', 3, 2, 45.00, 2, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 市辖区 朝阳区 故宫紫禁城', '圆通快递', NULL, '2025-09-03 15:57:30', '2025-09-03 15:57:30', NULL, NULL, NULL, NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('175688702137640125359', 3, 2, 45.00, 7, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 市辖区 朝阳区 故宫紫禁城', '顺丰速运', '1231521', '2025-09-03 16:10:21', '2025-09-03 16:10:21', '2025-09-03 16:10:33', NULL, '2025-09-03 16:12:13', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('175688865622770e2beef', 3, 2, 32.00, 7, 1, 'balance', NULL, 'kkk', '13145256548', '北京市 市辖区 朝阳区 故宫紫禁城', '中通快递', '232121', '2025-09-03 16:37:36', '2025-09-03 16:37:36', '2025-09-03 16:38:16', NULL, '2025-09-03 16:42:31', NULL, '无', '待发货', 0);
INSERT INTO `orders` VALUES ('1757295375221e0f939f6', 1, 2, 55.00, 4, 6, 'balance', NULL, 'fsff ', '13456287954', '上海市 长宁区 其他区县 das', '中通快递', '1231521', '2025-09-08 09:36:15', '2025-09-08 09:36:15', '2025-09-08 09:36:56', NULL, '2025-09-08 09:37:28', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('1757295581115f3de238f', 1, 2, 762.70, 4, 6, 'wechat', NULL, 'fsff ', '13456287954', '上海市 长宁区 其他区县 das', '顺丰速运', '1111545454545', '2025-09-08 09:39:41', '2025-09-08 09:39:41', '2025-09-08 09:41:56', NULL, '2025-09-08 09:42:09', NULL, '', '待发货', 0);
INSERT INTO `orders` VALUES ('TEST20241201001', 3, 2, 99.99, 4, 10, NULL, NULL, '测试用户', '13800138000', '测试地址', NULL, NULL, '2025-08-14 17:34:12', NULL, NULL, NULL, NULL, NULL, NULL, '待发货', 0);

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `payment_id` int NOT NULL AUTO_INCREMENT COMMENT '支付记录ID',
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联订单ID',
  `amount` decimal(10, 2) NOT NULL COMMENT '支付金额',
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式',
  `payment_status` tinyint NULL DEFAULT 0 COMMENT '支付状态：0-待支付, 1-成功, 2-失败, 3-已退款',
  `transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方支付平台交易号',
  `gateway_response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '支付网关响应信息',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `paid_at` datetime NULL DEFAULT NULL COMMENT '支付成功时间',
  `refund_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退款交易号',
  `refunded_at` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `refund_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '退款金额',
  PRIMARY KEY (`payment_id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_payment_status`(`payment_status` ASC) USING BTREE,
  INDEX `idx_transaction_id`(`transaction_id` ASC) USING BTREE,
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payments
-- ----------------------------
INSERT INTO `payments` VALUES (1, '1754988857930c2798c60', 4500.00, 'balance', 1, NULL, NULL, '2025-08-12 16:54:18', '2025-08-12 16:54:18', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (2, '1754991130151ce91c1f3', 6800.00, 'wechat', 1, NULL, NULL, '2025-08-12 17:32:10', '2025-08-12 17:32:10', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (3, '1755331149437b554c58f', 11300.00, 'balance', 1, NULL, NULL, '2025-08-16 15:59:09', '2025-08-16 15:59:09', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (4, '1755767101131c3cf1bc1', 195.00, 'balance', 1, NULL, NULL, '2025-08-21 17:05:01', '2025-08-21 17:05:01', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (5, '175608865807525fb60d6', 18.00, 'balance', 1, NULL, NULL, '2025-08-25 10:24:18', '2025-08-25 10:24:18', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (6, '1756123209466736d9bfa', 18.00, 'balance', 1, NULL, NULL, '2025-08-25 20:00:09', '2025-08-25 20:00:09', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (7, '1756260734215abf48fe4', 195.00, 'balance', 1, NULL, NULL, '2025-08-27 10:12:14', '2025-08-27 10:12:14', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (8, '1756280244212afdbdaf2', 32.00, 'balance', 1, NULL, NULL, '2025-08-27 15:37:24', '2025-08-27 15:37:24', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (9, '1756886250312f62489fc', 45.00, 'balance', 1, NULL, NULL, '2025-09-03 15:57:30', '2025-09-03 15:57:30', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (10, '175688702137640125359', 45.00, 'balance', 1, NULL, NULL, '2025-09-03 16:10:21', '2025-09-03 16:10:21', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (11, '175688702137640125359', -45.00, 'REFUND_ADMIN', 3, 'REFUND_ADMIN_1756887133463', NULL, '2025-09-03 16:12:13', '2025-09-03 16:12:13', NULL, '2025-09-03 16:12:13', 45.00);
INSERT INTO `payments` VALUES (12, '175688865622770e2beef', 32.00, 'balance', 1, NULL, NULL, '2025-09-03 16:37:36', '2025-09-03 16:37:36', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (13, '175688865622770e2beef', -32.00, 'REFUND_ADMIN', 3, 'REFUND_ADMIN_1756888951389', NULL, '2025-09-03 16:42:31', '2025-09-03 16:42:31', NULL, '2025-09-03 16:42:31', 32.00);
INSERT INTO `payments` VALUES (14, '1757295375221e0f939f6', 55.00, 'balance', 1, NULL, NULL, '2025-09-08 09:36:15', '2025-09-08 09:36:15', NULL, NULL, NULL);
INSERT INTO `payments` VALUES (15, '1757295581115f3de238f', 762.70, 'wechat', 1, NULL, NULL, '2025-09-08 09:39:41', '2025-09-08 09:39:41', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for post_comments
-- ----------------------------
DROP TABLE IF EXISTS `post_comments`;
CREATE TABLE `post_comments`  (
  `comment_id` int NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `post_id` int NOT NULL COMMENT '关联帖子ID',
  `user_id` int NOT NULL COMMENT '评论用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `parent_comment_id` int NULL DEFAULT 0 COMMENT '父评论ID：0-顶级评论',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  `is_author` tinyint(1) NULL DEFAULT 0 COMMENT '是否作者回复：0-否, 1-是',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `fk_comment_post`(`post_id` ASC) USING BTREE,
  INDEX `fk_comment_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子评论表，支持多级回复' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of post_comments
-- ----------------------------
INSERT INTO `post_comments` VALUES (1, 1, 2, '推荐你看看XX品牌的棉麻沙发，我们家买的就是这个，舒适度很不错！', 0, 5, '2024-01-15 11:20:00', 0);
INSERT INTO `post_comments` VALUES (2, 1, 3, '这个预算可以考虑实木框架的，更加耐用。', 0, 3, '2024-01-15 12:15:00', 0);
INSERT INTO `post_comments` VALUES (3, 1, 1, '谢谢推荐！我去了解一下实木框架的。', 2, 2, '2024-01-15 13:30:00', 1);
INSERT INTO `post_comments` VALUES (4, 1, 2, '建议去实体店试坐一下，网上看着好看实际坐感可能不一样。', 0, 8, '2024-01-15 14:45:00', 0);
INSERT INTO `post_comments` VALUES (5, 2, 1, '你的陶瓷作品真的很精美！能分享一下拉坯的技巧吗？', 0, 4, '2024-01-14 15:30:00', 0);
INSERT INTO `post_comments` VALUES (6, 2, 2, '拉坯时手要稳，力度要均匀，转速也要控制好。多练习几次就熟练了。', 5, 3, '2024-01-14 16:20:00', 1);
INSERT INTO `post_comments` VALUES (7, 3, 1, '阳台种菜真的很有意思！你用的是什么土壤配比？', 0, 6, '2024-01-13 10:45:00', 0);
INSERT INTO `post_comments` VALUES (8, 3, 3, '我用的是腐叶土:园土:河沙=3:2:1的配比，效果不错。', 7, 4, '2024-01-13 11:30:00', 1);
INSERT INTO `post_comments` VALUES (9, 3, 1, '有机蔬菜吃起来确实不一样，营养也更丰富。', 0, 2, '2024-01-13 14:20:00', 0);
INSERT INTO `post_comments` VALUES (10, 4, 3, '植物染色的衣服颜色很自然，而且对皮肤友好。', 0, 7, '2024-01-12 17:30:00', 0);
INSERT INTO `post_comments` VALUES (11, 4, 1, '是的，而且每次洗完颜色都会有微妙的变化，很有意思。', 10, 3, '2024-01-12 18:45:00', 1);
INSERT INTO `post_comments` VALUES (12, 5, 2, '古法红糖确实比普通红糖香甜，营养价值也更高。', 0, 5, '2024-01-11 12:15:00', 0);
INSERT INTO `post_comments` VALUES (13, 5, 2, '我们家一直吃这种红糖，用来煮姜茶特别好。', 12, 2, '2024-01-11 13:30:00', 1);
INSERT INTO `post_comments` VALUES (14, 6, 1, '竹制家具要注意防潮，特别是在梅雨季节。', 0, 4, '2024-01-10 14:40:00', 0);
INSERT INTO `post_comments` VALUES (15, 6, 2, '对的，我一般会定期用干布擦拭，保持干燥。', 14, 3, '2024-01-10 15:20:00', 1);
INSERT INTO `post_comments` VALUES (16, 7, 1, '叶插的成功率真的很高！我试过几次都很成功。', 0, 6, '2024-01-09 16:15:00', 0);
INSERT INTO `post_comments` VALUES (17, 7, 3, '记得叶插时要等切口晾干后再插，这样不容易腐烂。', 16, 4, '2024-01-09 17:30:00', 1);
INSERT INTO `post_comments` VALUES (18, 7, 1, '多肉植物真的是懒人植物，很好养活。', 0, 3, '2024-01-09 18:45:00', 0);
INSERT INTO `post_comments` VALUES (19, 8, 3, '初学者建议从简单的平针开始学起。', 0, 5, '2024-01-08 19:20:00', 0);
INSERT INTO `post_comments` VALUES (20, 8, 3, '谢谢指导！我已经准备好毛线开始尝试了。', 19, 2, '2024-01-08 20:10:00', 1);

-- ----------------------------
-- Table structure for product_categories
-- ----------------------------
DROP TABLE IF EXISTS `product_categories`;
CREATE TABLE `product_categories`  (
  `category_id` int NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` int NOT NULL DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序权重（越大越靠前）',
  `is_show` tinyint(1) NULL DEFAULT 1 COMMENT '是否显示：0-隐藏, 1-显示',
  PRIMARY KEY (`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品分类表，支持多级分类和属性模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_categories
-- ----------------------------
INSERT INTO `product_categories` VALUES (1, 0, '电子产品', 1, 1);
INSERT INTO `product_categories` VALUES (4, 0, '图书教材', 3, 1);
INSERT INTO `product_categories` VALUES (7, 0, '玩具娱乐', NULL, 1);
INSERT INTO `product_categories` VALUES (9, 0, '服装鞋帽', NULL, 1);
INSERT INTO `product_categories` VALUES (13, 1, '手机', 0, 1);

-- ----------------------------
-- Table structure for product_favorites
-- ----------------------------
DROP TABLE IF EXISTS `product_favorites`;
CREATE TABLE `product_favorites`  (
  `favorite_id` int NOT NULL AUTO_INCREMENT COMMENT '收藏记录ID',
  `user_id` int NOT NULL COMMENT '收藏用户ID',
  `product_id` int NOT NULL COMMENT '被收藏商品ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `notify_on_price_drop` tinyint(1) NULL DEFAULT 0 COMMENT '降价通知：0-不通知, 1-通知',
  PRIMARY KEY (`favorite_id`) USING BTREE,
  INDEX `fk_favorite_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_favorite_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_favorite_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品收藏表，记录用户收藏行为' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_favorites
-- ----------------------------
INSERT INTO `product_favorites` VALUES (1, 1, 1, '2025-08-01 09:19:13', 1);
INSERT INTO `product_favorites` VALUES (18, 1, 5, '2025-08-05 10:00:00', 0);
INSERT INTO `product_favorites` VALUES (19, 2, 7, '2025-08-07 14:00:00', 1);
INSERT INTO `product_favorites` VALUES (20, 3, 12, '2025-08-12 10:00:00', 1);
INSERT INTO `product_favorites` VALUES (22, 2, 3, '2025-08-03 15:00:00', 1);
INSERT INTO `product_favorites` VALUES (24, 1, 13, '2025-08-13 12:00:00', 1);
INSERT INTO `product_favorites` VALUES (25, 2, 9, '2025-08-09 11:00:00', 0);
INSERT INTO `product_favorites` VALUES (34, 3, 7, '2025-08-21 10:27:52', 0);
INSERT INTO `product_favorites` VALUES (35, 3, 9, '2025-08-21 10:27:54', 0);
INSERT INTO `product_favorites` VALUES (36, 3, 2, '2025-08-21 10:27:58', 0);
INSERT INTO `product_favorites` VALUES (37, 3, 14, '2025-08-21 10:28:10', 0);
INSERT INTO `product_favorites` VALUES (38, 3, 13, '2025-08-21 10:28:19', 0);
INSERT INTO `product_favorites` VALUES (42, 3, 8, '2025-08-21 10:28:35', 0);
INSERT INTO `product_favorites` VALUES (43, 3, 6, '2025-08-21 10:28:45', 0);
INSERT INTO `product_favorites` VALUES (44, 3, 3, '2025-08-21 10:29:08', 0);
INSERT INTO `product_favorites` VALUES (45, 3, 5, '2025-08-21 10:29:16', 0);

-- ----------------------------
-- Table structure for product_images
-- ----------------------------
DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images`  (
  `image_id` int NOT NULL AUTO_INCREMENT COMMENT '图片ID',
  `product_id` int NOT NULL COMMENT '关联商品ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'http://localhost:8080/uploads/products/example.png' COMMENT '图片存储路径',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序序号（越小越靠前）',
  `is_main` tinyint(1) NULL DEFAULT 0 COMMENT '是否主图：0-否, 1-是',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `verification_status` tinyint NULL DEFAULT 0 COMMENT '图片审核状态：0-未审核, 1-通过, 2-拒绝',
  `rejection_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片被拒绝的原因',
  PRIMARY KEY (`image_id`) USING BTREE,
  INDEX `fk_image_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_image_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品图片表，支持多图排序和主图标识' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_images
-- ----------------------------
INSERT INTO `product_images` VALUES (1, 1, 'http://localhost:8080/uploads/products/example.png', 1, 1, '2025-08-01 09:19:13', 1, NULL);
INSERT INTO `product_images` VALUES (2, 1, 'http://localhost:8080/uploads/products/macbook.png', 2, 0, '2025-08-01 09:19:13', 1, NULL);
INSERT INTO `product_images` VALUES (3, 2, 'http://localhost:8080/uploads/products/macbook.png', 1, 1, '2025-08-01 09:19:13', 1, NULL);
INSERT INTO `product_images` VALUES (4, 3, 'http://localhost:8080/uploads/products/ipad_main.png', 1, 1, '2025-08-03 14:20:00', 1, NULL);
INSERT INTO `product_images` VALUES (5, 3, 'http://localhost:8080/uploads/products/ipad_detail1.png', 2, 0, '2025-08-03 14:20:00', 1, NULL);
INSERT INTO `product_images` VALUES (6, 4, 'http://localhost:8080/uploads/products/airpods_main.png', 1, 1, '2025-08-04 16:45:00', 1, NULL);
INSERT INTO `product_images` VALUES (7, 4, 'http://localhost:8080/uploads/products/airpods_case.jpg', 2, 0, '2025-08-04 16:45:00', 1, NULL);
INSERT INTO `product_images` VALUES (8, 5, 'http://localhost:8080/uploads/products/alive.png', 1, 1, '2025-08-05 09:15:00', 1, NULL);
INSERT INTO `product_images` VALUES (9, 5, '/products/math_book_back.jpg', 2, 0, '2025-08-05 09:15:00', 1, NULL);
INSERT INTO `product_images` VALUES (10, 6, 'http://localhost:8080/uploads/products/example.png', 1, 1, '2025-08-06 11:30:00', 1, NULL);
INSERT INTO `product_images` VALUES (11, 7, 'http://localhost:8080/uploads/products/example.png', 1, 1, '2025-08-07 13:20:00', 1, NULL);
INSERT INTO `product_images` VALUES (12, 8, 'http://localhost:8080/uploads/products/alive.png', 1, 1, '2025-08-08 15:40:00', 1, NULL);
INSERT INTO `product_images` VALUES (13, 9, 'http://localhost:8080/uploads/products/shidizai.png', 1, 1, '2025-08-09 10:00:00', 1, NULL);
INSERT INTO `product_images` VALUES (14, 9, '/products/lego_box.jpg', 2, 0, '2025-08-09 10:00:00', 1, NULL);
INSERT INTO `product_images` VALUES (15, 10, 'http://localhost:8080/uploads/products/threecountrykill.png', 1, 1, '2025-08-10 14:15:00', 1, NULL);
INSERT INTO `product_images` VALUES (16, 10, '/products/sanguosha_cards.jpg', 2, 0, '2025-08-10 14:15:00', 1, NULL);
INSERT INTO `product_images` VALUES (17, 11, 'http://localhost:8080/uploads/products/xiaogou.png', 1, 1, '2025-08-11 16:30:00', 1, NULL);
INSERT INTO `product_images` VALUES (18, 12, 'http://localhost:8080/uploads/products/nanshiweiyi.png', 1, 1, '2025-08-12 09:45:00', 1, NULL);
INSERT INTO `product_images` VALUES (19, 12, '/products/men_suit_model.jpg', 2, 0, '2025-08-12 09:45:00', 1, NULL);
INSERT INTO `product_images` VALUES (20, 13, 'http://localhost:8080/uploads/products/qiudongweiyi.png', 1, 1, '2025-08-13 11:20:00', 1, NULL);
INSERT INTO `product_images` VALUES (21, 13, '/products/women_sweater_detail.jpg', 2, 0, '2025-08-13 11:20:00', 1, NULL);
INSERT INTO `product_images` VALUES (22, 14, 'http://localhost:8080/uploads/products/yundongxie.png', 1, 1, '2025-08-14 13:35:00', 1, NULL);
INSERT INTO `product_images` VALUES (23, 14, '/products/shoes_side.jpg', 2, 0, '2025-08-14 13:35:00', 1, NULL);
INSERT INTO `product_images` VALUES (35, 27, 'http://localhost:8080/uploads/products/7c987e47-dacf-4bc4-b497-d4dc48395b21.jpg', 0, 1, '2025-09-08 09:01:07', 0, NULL);
INSERT INTO `product_images` VALUES (36, 28, 'http://localhost:8080/uploads/products/5e5a2318-0be6-485a-9664-f7340641685d.jpg', 0, 1, '2025-09-08 09:03:48', 0, NULL);
INSERT INTO `product_images` VALUES (37, 29, 'http://localhost:8080/uploads/products/e673fcca-064c-451c-85c4-9923e0498d11.jpg', 0, 1, '2025-09-08 09:12:00', 0, NULL);
INSERT INTO `product_images` VALUES (38, 30, 'http://localhost:8080/uploads/products/e9301737-faba-4384-8aba-f1dec523be02.jpg', 0, 1, '2025-09-08 09:14:02', 0, NULL);
INSERT INTO `product_images` VALUES (41, 33, 'http://localhost:8080/uploads/products/38117c77-3c71-42a5-b360-60487b2feaff.jpg', 0, 1, '2025-09-08 09:17:52', 0, NULL);
INSERT INTO `product_images` VALUES (43, 35, 'http://localhost:8080/uploads/products/6fe72a52-ce3c-4213-b9f2-da18c1804adc.jpg', 0, 1, '2025-09-08 09:20:27', 0, NULL);
INSERT INTO `product_images` VALUES (44, 32, 'http://localhost:8080/uploads/products/354665bd-f036-4f5a-850d-2e919390356c.jpg', 0, 1, '2025-09-08 09:25:29', 0, NULL);
INSERT INTO `product_images` VALUES (45, 31, 'http://localhost:8080/uploads/products/e696bec4-e61c-4030-bb0f-1f22deb696e8.jpg', 0, 1, '2025-09-08 09:28:11', 0, NULL);
INSERT INTO `product_images` VALUES (46, 34, 'http://localhost:8080/uploads/products/f44e5f4b-b6c3-4b8d-b3cf-067500118c3f.jpg', 0, 1, '2025-09-08 09:28:25', 0, NULL);

-- ----------------------------
-- Table structure for products
-- ----------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products`  (
  `product_id` int NOT NULL AUTO_INCREMENT COMMENT '商品唯一ID',
  `seller_id` int NOT NULL COMMENT '卖家用户ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品详细描述',
  `category_id` int NOT NULL COMMENT '商品分类ID',
  `price` decimal(10, 2) NOT NULL COMMENT '当前售价',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价（新品参考价）',
  `condition` tinyint NULL DEFAULT NULL COMMENT '成色等级：1-全新, 2-95新, 3-9成新, 4-8成新, 5-7成新及以下',
  `stock` int NOT NULL DEFAULT 1 COMMENT '库存数量（二手商品通常为1）',
  `status` tinyint NOT NULL DEFAULT 4 COMMENT '商品状态：1-上架,2-下架,3-售罄,4-审核中',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `favorite_count` int NULL DEFAULT 0 COMMENT '收藏量',
  `is_recommended` tinyint(1) NULL DEFAULT 0 COMMENT '是否推荐：0-否, 1-是',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品位置（用于同城交易）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `expire_at` datetime NULL DEFAULT NULL COMMENT '自动下架时间（30天未售出）',
  `custom_attributes` json NULL COMMENT '自定义属性（JSON格式）',
  PRIMARY KEY (`product_id`) USING BTREE,
  INDEX `fk_product_seller`(`seller_id` ASC) USING BTREE,
  INDEX `fk_product_category`(`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`category_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_product_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品核心信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of products
-- ----------------------------
INSERT INTO `products` VALUES (1, 2, '二手iPhone 13 128G 蓝色 95新', '无拆修，电池健康90%，原装配件齐全', 1, 4500.00, 5999.00, 2, 9, 1, 59, 1, 0, '深圳市南山区', '2025-08-06 09:19:10', '2025-09-12 15:12:49', '2025-08-30 00:00:00', '{\"brand\": \"Apple\", \"storage\": \"128G\", \"screen_size\": \"6.1英寸\"}');
INSERT INTO `products` VALUES (2, 2, '二手MacBook Air M1 256G 银色 9成新', '2021款，续航10小时，轻微使用痕迹', 1, 6800.00, 9499.00, 3, 8, 1, 123, 2, 0, '深圳市福田区', '2025-08-05 09:19:13', '2025-09-03 11:27:25', '2025-08-28 00:00:00', '{\"ram\": \"8G\", \"disk\": \"256G\", \"brand\": \"Apple\"}');
INSERT INTO `products` VALUES (3, 2, 'iPad Pro 2021 11英寸', 'iPad Pro 11英寸 128G 深空灰，95新，配件齐全，支持Apple Pencil', 1, 2200.00, 4299.00, 2, 10, 1, 76, 9, 0, '深圳市南山区科技园', '2025-08-03 14:20:00', '2025-09-03 12:27:17', '2025-09-03 14:20:00', NULL);
INSERT INTO `products` VALUES (4, 2, 'AirPods Pro 二代', 'AirPods Pro 第二代，支持主动降噪，充电盒完好，使用半年', 1, 850.00, 1899.00, 3, 10, 1, 45, 5, 0, '深圳市福田区华强北', '2025-08-04 16:45:00', '2025-09-03 12:27:14', '2025-09-04 16:45:00', NULL);
INSERT INTO `products` VALUES (5, 2, '高等数学同济第七版上下册', '高等数学教材上下册，同济大学第七版，考研必备，几乎全新', 4, 35.00, 65.00, 1, 10, 1, 125, 19, 1, '清华大学-图书馆', '2025-08-05 09:15:00', '2025-09-12 15:12:14', '2025-09-05 09:15:00', '{\"grade\": \"大学\", \"subject\": \"数学\"}');
INSERT INTO `products` VALUES (6, 3, 'Java从入门到精通', 'Java编程经典教材，第5版，附带光盘和练习题答案', 4, 28.00, 89.00, 2, 10, 1, 82, 12, 0, '华中科技大学-计算机学院', '2025-08-06 11:30:00', '2025-09-12 15:12:09', '2025-09-06 11:30:00', '{\"grade\": \"大学\", \"subject\": \"计算机\"}');
INSERT INTO `products` VALUES (7, 2, '三体全集 刘慈欣著', '科幻小说经典之作《三体》三部曲，精装版，豆瓣评分9.2', 4, 45.00, 98.00, 3, 10, 1, 99, 23, 1, '中山大学-北校区', '2025-08-07 13:20:00', '2025-09-12 15:17:12', '2025-09-07 13:20:00', '{\"genre\": \"科幻\", \"pages\": \"1000+\"}');
INSERT INTO `products` VALUES (8, 2, '活着 余华著', '茅盾文学奖获奖作品，精装版，品相良好', 4, 18.00, 35.00, 4, 9, 1, 96, 8, 0, '南京大学-鼓楼校区', '2025-08-08 15:40:00', '2025-09-03 16:44:02', '2025-09-08 15:40:00', '{\"genre\": \"文学\", \"pages\": \"191\"}');
INSERT INTO `products` VALUES (9, 3, '乐高经典创意史迪仔1500粒', '乐高经典系列创意积木盒，1500粒装，适合6岁以上儿童', 7, 180.00, 399.00, 1, 1, 1, 67, 4, 0, '厦门大学-幼儿园', '2025-08-09 10:00:00', '2025-09-02 23:58:13', '2025-09-09 10:00:00', '{\"skill\": \"创造力\", \"players\": \"1-多人\"}');
INSERT INTO `products` VALUES (10, 2, '三国杀标准版桌游', '三国杀标准版，经典策略卡牌游戏，适合3-10人游戏', 7, 45.00, 88.00, 2, 7, 1, 101, 8, 1, '四川大学-江安校区', '2025-08-10 14:15:00', '2025-09-03 16:10:47', '2025-09-10 14:15:00', '{\"skill\": \"策略思维\", \"players\": \"3-10人\"}');
INSERT INTO `products` VALUES (11, 2, '儿童益智拼图1000片', '迪士尼主题1000片拼图，培养专注力，适合8岁以上儿童', 7, 32.00, 68.00, 3, 9, 1, 94, 2, 0, '中南大学-南校区', '2025-08-11 16:30:00', '2025-09-03 16:38:37', '2025-09-11 16:30:00', '{\"skill\": \"专注力\", \"players\": \"1-2人\"}');
INSERT INTO `products` VALUES (12, 2, '男士运动卫衣套装', '耐克男士运动卫衣套装，L码，黑色，秋季新款，仅穿过几次', 9, 120.00, 399.00, 4, 10, 1, 80, 6, 0, '西安交通大学-曲江校区', '2025-08-12 09:45:00', '2025-09-03 16:12:49', '2025-09-12 09:45:00', '{\"color\": \"黑色\", \"style\": \"运动\"}');
INSERT INTO `products` VALUES (13, 3, '女士秋冬毛衣', '优衣库女士羊毛混纺毛衣，M码，米白色，保暖舒适', 9, 85.00, 199.00, 3, 10, 4, 105, 12, 1, '大连理工大学-西山宿舍', '2025-08-13 11:20:00', '2025-09-13 19:30:28', '2025-09-13 11:20:00', '{\"color\": \"米白\", \"style\": \"休闲\"}');
INSERT INTO `products` VALUES (14, 2, '大学生运动鞋', '阿迪达斯三叶草经典款运动鞋，42码，白色，九成新', 9, 150.00, 599.00, 3, 9, 1, 171, 15, 1, '华南理工大学-大学城', '2025-08-14 13:35:00', '2025-09-12 23:15:10', '2025-09-14 13:35:00', '{\"size\": \"42\", \"season\": \"四季\"}');
INSERT INTO `products` VALUES (27, 2, '二手显示器', '24寸240HZ，分辨率1920*1080，刷新率240HZ，接口HDMI+DP，配件齐全，原包装，可以外接笔记本，IPS屏幕，便宜当二手处理的，有需要联系', 1, 339.00, 500.00, 4, 0, 1, 6, 0, 0, '华南科技大学', '2025-09-08 09:01:07', '2025-09-08 09:47:55', NULL, NULL);
INSERT INTO `products` VALUES (28, 2, '二手Redmi红米K30Pro骁龙865.6400万像素4摄游戏手机', '二手Redmi红米K30Pro骁龙865.6400万像素4摄游戏手机清仓便宜学生，退货包运费', 13, 319.00, 699.00, 1, 0, 1, 9, 0, 0, '华东科技大学', '2025-09-08 09:03:48', '2025-09-13 19:31:05', NULL, NULL);
INSERT INTO `products` VALUES (29, 2, '二手闲置九九新卡皮巴拉', '二手闲置九九新卡皮巴拉质量好，20厘米左右，搬家嫌麻烦就二手出了', 7, 8.80, 30.00, 4, 0, 1, 7, 0, 0, '华北科技大学', '2025-09-08 09:12:00', '2025-09-12 23:15:01', NULL, NULL);
INSERT INTO `products` VALUES (30, 2, '复古胶卷相机', '旧货旁轴相机胶卷机械 复古胶卷相机 收藏品红梅 ganguang 装饰品 ', 1, 38.00, 127.00, 4, 1, 3, 1, 0, 0, '中山大学', '2025-09-08 09:14:02', '2025-09-12 15:12:53', NULL, NULL);
INSERT INTO `products` VALUES (31, 2, '二手充电宝30000毫安', '处理二手充电宝30000毫安包邮移动电源不挑随机发货便宜随机发', 1, 29.90, 100.00, 3, 1, 1, 8, 0, 0, '肇庆学院', '2025-09-08 09:15:11', '2025-09-08 09:47:04', NULL, NULL);
INSERT INTO `products` VALUES (32, 2, '女小白鞋', '闲置二手【2双】女小白鞋板鞋运动鞋平底单鞋休闲鞋', 9, 19.80, 58.80, 5, 2, 3, 4, 0, 0, '韶关学院', '2025-09-08 09:16:14', '2025-09-12 23:14:56', NULL, NULL);
INSERT INTO `products` VALUES (33, 2, '华强北s10顶配智能手表', '华强北s10顶配智能手表信息提醒蓝牙通话灵动岛心率监测运动手环', 1, 38.00, 79.00, 1, 9, 1, 13, 0, 0, '嘉应学院', '2025-09-08 09:17:52', '2025-09-13 19:30:55', NULL, NULL);
INSERT INTO `products` VALUES (34, 2, '二手篮球', '清仓二手七号橡胶篮球,高弹耐磨,室内室外均用篮球便宜', 7, 28.00, 75.00, 3, 0, 1, 7, 0, 0, '佛山大学', '2025-09-08 09:19:09', '2025-09-12 23:14:47', NULL, NULL);
INSERT INTO `products` VALUES (35, 2, '小米吹风机', '【二手】小米吹风机H101米家便携负离子筒可折叠电吹风机速干护发退货包运费', 1, 55.00, 105.00, 2, 0, 1, 12, 0, 0, '广州应用科技学院', '2025-09-08 09:20:27', '2025-09-12 23:14:53', NULL, NULL);

-- ----------------------------
-- Table structure for replies
-- ----------------------------
DROP TABLE IF EXISTS `replies`;
CREATE TABLE `replies`  (
  `reply_id` int NOT NULL AUTO_INCREMENT,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL,
  `review_id` int NOT NULL,
  `replied_to_user_id` int NULL DEFAULT NULL,
  `replied_to_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `is_append` tinyint(1) NULL DEFAULT 0 COMMENT '是否为用户追评：0-否, 1-是',
  `deleted` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`reply_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `review_id`(`review_id` ASC) USING BTREE,
  INDEX `replied_to_user_id`(`replied_to_user_id` ASC) USING BTREE,
  CONSTRAINT `replies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `replies_ibfk_2` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`review_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `replies_ibfk_4` FOREIGN KEY (`replied_to_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of replies
-- ----------------------------
INSERT INTO `replies` VALUES (1, '真的吗', '2025-08-15 20:19:29', 3, 1, 3, 'admin', 0, 0);
INSERT INTO `replies` VALUES (2, '感谢您的支持', '2025-09-02 00:04:53', 2, 9, 3, 'admin', 0, 0);
INSERT INTO `replies` VALUES (3, '再次感谢', '2025-09-02 15:00:04', 2, 4, 3, 'admin', 0, 0);
INSERT INTO `replies` VALUES (4, '感谢您的好评，欢迎回购', '2025-09-08 09:46:30', 2, 10, 1, 'user1', 0, 0);
INSERT INTO `replies` VALUES (5, '有点划痕而已，不至于吧', '2025-09-08 09:47:00', 2, 15, 1, 'user1', 0, 0);
INSERT INTO `replies` VALUES (6, '没事，能用的', '2025-09-08 09:47:12', 2, 14, 1, 'user1', 0, 0);
INSERT INTO `replies` VALUES (7, '感谢亲的购买，欢迎回购', '2025-09-08 09:47:34', 2, 12, 1, 'user1', 0, 0);
INSERT INTO `replies` VALUES (8, '你要替我好好照顾它', '2025-09-08 09:47:50', 2, 13, 1, 'user1', 0, 0);
INSERT INTO `replies` VALUES (9, ' 是吧，我觉得这牌子的显示器一直都很不错的', '2025-09-08 09:48:16', 2, 11, 1, 'user1', 0, 0);

-- ----------------------------
-- Table structure for reports
-- ----------------------------
DROP TABLE IF EXISTS `reports`;
CREATE TABLE `reports`  (
  `report_id` int NOT NULL AUTO_INCREMENT COMMENT '举报记录ID',
  `reporter_id` int NOT NULL COMMENT '举报人用户ID（关联users表）',
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '举报对象类型：user-用户, product-商品, post-帖子, comment-评论, chat-聊天',
  `target_id` int NOT NULL COMMENT '被举报对象ID（如商品ID、用户ID）',
  `reason` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '举报原因：fraud-欺诈, spam-垃圾信息, illegal-违法信息, other-其他',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '举报详情（用户填写）',
  `evidence_images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '证据图片URL，多个用逗号分隔',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '处理状态：0-待处理, 1-已核实, 2-不成立, 3-已处罚',
  `handler_id` int NULL DEFAULT NULL COMMENT '处理人ID（管理员用户ID）',
  `handle_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处理备注（管理员填写）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
  `handled_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
  PRIMARY KEY (`report_id`) USING BTREE,
  INDEX `fk_reporter`(`reporter_id` ASC) USING BTREE,
  INDEX `fk_handler`(`handler_id` ASC) USING BTREE,
  INDEX `idx_report_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_report_handler` FOREIGN KEY (`handler_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户举报表（支持管理员处理各类违规举报）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reports
-- ----------------------------
INSERT INTO `reports` VALUES (1, 1, 'comment', 1, 'spam', '该评论疑似广告刷屏', NULL, 0, NULL, NULL, '2025-08-01 09:19:14', NULL);

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews`  (
  `review_id` int NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `order_item_id` int NOT NULL COMMENT '关联订单项ID',
  `user_id` int NOT NULL COMMENT '评价用户ID',
  `rating` tinyint NOT NULL COMMENT '评分（1-5分）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评价内容',
  `image_urls` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价图片URL，多个用逗号分隔',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `seller_reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '卖家回复内容',
  `is_anonymous` tinyint(1) NULL DEFAULT 0 COMMENT '是否匿名：0-否, 1-是',
  `has_append` tinyint(1) NULL DEFAULT 0 COMMENT '是否存在用户追评：0-否, 1-是',
  `deleted` tinyint(1) NULL DEFAULT 0 COMMENT '删除状态：0-未删除，1-已删除',
  `product_id` int NOT NULL COMMENT '商品ID',
  PRIMARY KEY (`review_id`) USING BTREE,
  INDEX `fk_review_item`(`order_item_id` ASC) USING BTREE,
  INDEX `fk_review_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_review_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`item_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价表，支持多图评价和卖家回复' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of reviews
-- ----------------------------
INSERT INTO `reviews` VALUES (1, 7, 3, 5, '很不错', 'http://localhost:8080/uploads/review_images/c0a8f69f-66ad-48e7-b4e2-944b73d881ac.jpg', '2025-08-15 20:18:15', NULL, 0, 0, 1, 2);
INSERT INTO `reviews` VALUES (2, 8, 3, 5, '很好', '', '2025-08-25 09:17:51', NULL, 0, 0, 1, 1);
INSERT INTO `reviews` VALUES (4, 13, 3, 4, '很不错', '', '2025-08-25 16:10:48', '谢谢', 0, 0, 0, 8);
INSERT INTO `reviews` VALUES (6, 15, 3, 5, '真不错，样子好看还便宜', '', '2025-08-27 10:45:45', NULL, 0, 0, 0, 14);
INSERT INTO `reviews` VALUES (7, 17, 3, 5, '买了，孩子很喜欢吃', '', '2025-08-27 15:40:14', NULL, 0, 0, 0, 11);
INSERT INTO `reviews` VALUES (8, 7, 3, 5, '老板很帅', '', '2025-08-29 16:38:08', NULL, 0, 0, 1, 2);
INSERT INTO `reviews` VALUES (9, 11, 3, 5, '老板很帅啊', 'http://localhost:8080/uploads/review_images/55547d97-5676-4260-bd60-d8d7c45d256e.png', '2025-08-29 16:39:42', '谢谢', 0, 0, 0, 10);
INSERT INTO `reviews` VALUES (10, 21, 1, 5, '小米吹风机声音很小，冷风热风控制很方便', '', '2025-09-08 09:38:07', NULL, 0, 0, 0, 35);
INSERT INTO `reviews` VALUES (11, 22, 1, 5, '屏幕很大，看起来很清晰，没有什么质量问题', '', '2025-09-08 09:43:18', NULL, 0, 0, 0, 27);
INSERT INTO `reviews` VALUES (12, 23, 1, 5, '成色很好，没什么太明显划痕，价格也便宜，套上我的手机壳，简直舒服，已经替大家试过一台了，非常好，这是回购第二台，玩游戏不卡，配置也可以开很高，电池也大放心入手，商家也很耐心，服务态度非常好', '', '2025-09-08 09:44:22', NULL, 0, 0, 0, 28);
INSERT INTO `reviews` VALUES (13, 24, 1, 5, '玩偶很干净，没有异味，卖家也很有耐心，推荐购买\r\n', '', '2025-09-08 09:45:05', NULL, 0, 0, 0, 29);
INSERT INTO `reviews` VALUES (14, 25, 1, 3, '有点鼓包，效果有点差强人意', '', '2025-09-08 09:45:26', NULL, 0, 0, 0, 31);
INSERT INTO `reviews` VALUES (15, 26, 1, 2, '怎么实物跟效果差那么多，很不满意啊', '', '2025-09-08 09:46:00', NULL, 0, 0, 0, 33);

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `role_id` int NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称(admin, moderator, seller, buyer)',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色权限描述',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uq_role_name`(`role_name` ASC) USING BTREE COMMENT '角色名称唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统角色定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (1, 'ROLE_ADMIN', '系统管理员，拥有全部权限');
INSERT INTO `roles` VALUES (2, 'ROLE_MODERATOR', '内容审核员，负责审核UGC内容');
INSERT INTO `roles` VALUES (3, 'ROLE_SELLER', '商家用户，可发布商品啊');
INSERT INTO `roles` VALUES (4, 'ROLE_USER', '普通买家，可购买商品');

-- ----------------------------
-- Table structure for seller_certifications
-- ----------------------------
DROP TABLE IF EXISTS `seller_certifications`;
CREATE TABLE `seller_certifications`  (
  `certification_id` int NOT NULL AUTO_INCREMENT COMMENT '认证记录ID',
  `user_id` int NOT NULL COMMENT '申请认证的用户ID',
  `business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '营业执照存储路径（必传）',
  `business_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商家名称',
  `business_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '经营类型',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系邮箱',
  `business_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '经营地址',
  `business_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '经营描述',
  `status` tinyint NULL DEFAULT 0 COMMENT '认证状态：0-待审核, 1-已认证, 2-拒绝',
  `reviewed_by` int NULL DEFAULT NULL COMMENT '审核人ID（管理员用户ID）',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因（管理员填写）',
  PRIMARY KEY (`certification_id`) USING BTREE,
  INDEX `fk_certification_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_certification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家认证审核表（仅需营业执照，简化商家入驻）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of seller_certifications
-- ----------------------------
INSERT INTO `seller_certifications` VALUES (4, 3, 'http://localhost:8080/uploads/business_licenses/fd2f3bdf-d934-431d-bb54-801c8893bae9.jpg', '企鹅', '海货', '13524548565', 'qier@qq.com', '南极洲', '卖鱼干的', 1, NULL, NULL, '2025-08-21 11:29:56', NULL);
INSERT INTO `seller_certifications` VALUES (5, 2, 'http://localhost:8080/uploads/business_licenses/5556e998-5e85-4995-9113-2420280c88a5.png', '坎诺特', '百货', '13416524785', 'woqu_0716@outlook.com', '泰拉罗德岛', '懂得都得', 1, NULL, NULL, '2025-09-01 11:16:33', NULL);

-- ----------------------------
-- Table structure for sellers
-- ----------------------------
DROP TABLE IF EXISTS `sellers`;
CREATE TABLE `sellers`  (
  `seller_id` int NOT NULL COMMENT '卖家用户ID（关联 users.user_id）',
  `shop_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '店铺名称',
  `logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺Logo图片URL',
  `banner_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺横幅图片URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '店铺简介',
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺地址或所在地区',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系邮箱',
  `open_date` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开店时间',
  `total_sales` int NULL DEFAULT 0 COMMENT '总销量',
  `total_reviews` int NULL DEFAULT 0 COMMENT '总评价数',
  `average_rating` decimal(3, 2) NULL DEFAULT 0.00 COMMENT '平均评分',
  `avg_response_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '24小时内' COMMENT '平均响应时间描述',
  `shipment_rate` decimal(5, 2) NULL DEFAULT 100.00 COMMENT '发货速度评分（百分比）',
  `logistics_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '物流政策',
  `after_sale_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '售后服务政策',
  `guarantee_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '保障服务政策',
  `announcement` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '店铺公告',
  `business_hours` json NULL COMMENT '营业时间（JSON格式，例如 {\"周一\": \"9:00-18:00\"}）',
  `is_verified` tinyint(1) NULL DEFAULT 0 COMMENT '是否认证商家：0-否, 1-是',
  `follower_count` int NULL DEFAULT 0 COMMENT '关注人数',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`seller_id`) USING BTREE,
  CONSTRAINT `fk_seller_user` FOREIGN KEY (`seller_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '卖家店铺信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sellers
-- ----------------------------
INSERT INTO `sellers` VALUES (2, '坎诺特', 'http://localhost:8080/uploads/shop_logos/3f0e0f82-2024-4996-adfd-44d35fd4b55f.jpg', 'http://localhost:8080/uploads/shop_banners/64de0bc7-0b60-4898-b4a3-52fe1b0cfc95.png', '懂得都得', '泰拉罗德岛', '13416524785', 'woqu_0716@outlook.com', '2025-09-01 11:16:33', 10, 0, 0.00, '24小时内', 100.00, '平台统一物流政策：满99元包邮，默认使用平台合作快递，急速发货。', '平台统一售后政策：支持7天无理由退换货，品质问题商家承担运费。', '平台统一保障服务：正品保障，假一赔三，售后无忧。', '孩子们，猜猜100美元可以买点什么', '{}', 0, 0, '2025-09-01 11:16:33', '2025-09-08 09:39:41');
INSERT INTO `sellers` VALUES (3, '企鹅', 'http://localhost:8080/uploads/shop_logos/6375600e-0bd6-4ad1-abad-2fe4b57fbb92.jpg', 'http://localhost:8080/uploads/shop_banners/d49c1ab6-ecfe-4dca-926e-03bbbfd17d4c.jpg', '卖鱼干的', '南极洲', '13524548565', 'qier@qq.com', '2025-08-21 11:29:56', 0, 0, 0.00, '24小时内', 100.00, '平台统一物流政策：满99元包邮，默认使用平台合作快递，急速发货。', '平台统一售后政策：支持7天无理由退换货，品质问题商家承担运费。', '平台统一保障服务：正品保障，假一赔三，售后无忧。', '多多光临，恭喜发财', '{\"周一\": \"0：00-24：00\", \"周三\": \"0：00-24：00\"}', 1, 0, '2025-08-21 11:29:56', '2025-09-03 16:16:13');

-- ----------------------------
-- Table structure for shipping_companies
-- ----------------------------
DROP TABLE IF EXISTS `shipping_companies`;
CREATE TABLE `shipping_companies`  (
  `company_id` int NOT NULL AUTO_INCREMENT COMMENT '物流公司ID',
  `company_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物流公司名称',
  `company_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流公司代码',
  `logo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公司logo',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用：0-禁用, 1-启用',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序顺序',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`company_id`) USING BTREE,
  UNIQUE INDEX `uk_company_name`(`company_name` ASC) USING BTREE,
  INDEX `idx_is_active`(`is_active` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '物流公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of shipping_companies
-- ----------------------------
INSERT INTO `shipping_companies` VALUES (1, '顺丰速运', 'SF', NULL, 1, 1, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (2, '圆通快递', 'YTO', NULL, 1, 2, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (3, '中通快递', 'ZTO', NULL, 1, 3, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (4, '申通快递', 'STO', NULL, 1, 4, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (5, '韵达快递', 'YD', NULL, 1, 5, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (6, '京东物流', 'JD', NULL, 1, 6, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (7, 'EMS', 'EMS', NULL, 1, 7, '2025-08-12 15:52:11');
INSERT INTO `shipping_companies` VALUES (8, '其他', 'OTHER', NULL, 1, 99, '2025-08-12 15:52:11');

-- ----------------------------
-- Table structure for user_addresses
-- ----------------------------
DROP TABLE IF EXISTS `user_addresses`;
CREATE TABLE `user_addresses`  (
  `address_id` int NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '省份',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区县',
  `detail_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '详细地址',
  `postal_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮政编码',
  `is_default` tinyint(1) NULL DEFAULT 0 COMMENT '是否默认地址：0-否, 1-是',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '软删除标记：0-正常, 1-删除',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`address_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_default`(`is_default` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收货地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_addresses
-- ----------------------------
INSERT INTO `user_addresses` VALUES (1, 3, 'kkk', '13145256548', '北京市', '市辖区', '朝阳区', '故宫紫禁城', '554321', 1, 0, '2025-08-12 16:44:09', '2025-08-27 15:26:42');
INSERT INTO `user_addresses` VALUES (6, 1, 'fsff ', '13456287954', '上海市', '长宁区', '其他区县', 'das', 'sdff', 0, 0, '2025-08-13 16:21:17', '2025-08-24 17:30:46');
INSERT INTO `user_addresses` VALUES (8, 2, '换个风格', '13465425428', '上海市', '徐汇区', '其他区县', '规范化', '', 0, 0, '2025-08-18 16:24:48', '2025-08-24 17:30:43');
INSERT INTO `user_addresses` VALUES (9, 3, 'kjkasdf', '13247856547', '上海市', '徐汇区', '其他区县', 'dasddsa', '', 0, 0, '2025-08-18 16:33:57', '2025-08-24 17:04:43');
INSERT INTO `user_addresses` VALUES (10, 3, '烦烦烦', '13624548545', '广东省', '广州市', '天河区', '风格的法规规范', '124523', 0, 0, '2025-08-24 17:03:08', '2025-08-27 15:26:42');

-- ----------------------------
-- Table structure for user_chats
-- ----------------------------
DROP TABLE IF EXISTS `user_chats`;
CREATE TABLE `user_chats`  (
  `chat_id` int NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user1_id` int NOT NULL COMMENT '用户1 ID',
  `user2_id` int NOT NULL COMMENT '用户2 ID',
  `last_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '最后一条消息内容',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后消息时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '会话创建时间',
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联订单ID（交易相关会话）',
  `unread_count_user1` int NULL DEFAULT 0 COMMENT '用户1的未读消息数',
  `unread_count_user2` int NULL DEFAULT 0 COMMENT '用户2的未读消息数',
  PRIMARY KEY (`chat_id`) USING BTREE,
  INDEX `fk_chat_user1`(`user1_id` ASC) USING BTREE,
  INDEX `fk_chat_user2`(`user2_id` ASC) USING BTREE,
  CONSTRAINT `fk_chat_user1` FOREIGN KEY (`user1_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_chat_user2` FOREIGN KEY (`user2_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '聊天会话表，记录用户间的对话' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_chats
-- ----------------------------
INSERT INTO `user_chats` VALUES (2, 3, 1, '谢谢', '2025-08-27 00:38:13', '2025-08-10 15:58:18', NULL, 0, 1);
INSERT INTO `user_chats` VALUES (9, 2, 1, NULL, '2025-08-27 12:57:26', '2025-08-27 12:57:26', NULL, 0, 0);
INSERT INTO `user_chats` VALUES (10, 3, 2, '你好', '2025-09-03 16:36:44', '2025-08-27 14:43:44', NULL, 0, 0);

-- ----------------------------
-- Table structure for user_follows
-- ----------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows`  (
  `follow_id` int NOT NULL AUTO_INCREMENT COMMENT '关注关系ID',
  `follower_id` int NOT NULL COMMENT '关注者用户ID (关联 users.user_id)',
  `followed_id` int NOT NULL COMMENT '被关注者用户ID (关联 users.user_id)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
  PRIMARY KEY (`follow_id`) USING BTREE,
  UNIQUE INDEX `uk_follower_followed`(`follower_id` ASC, `followed_id` ASC) USING BTREE COMMENT '防止重复关注',
  INDEX `idx_follower`(`follower_id` ASC) USING BTREE,
  INDEX `idx_followed`(`followed_id` ASC) USING BTREE,
  CONSTRAINT `fk_follow_followed` FOREIGN KEY (`followed_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_follow_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户关注关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_follows
-- ----------------------------
INSERT INTO `user_follows` VALUES (2, 2, 3, '2025-09-02 17:10:55');
INSERT INTO `user_follows` VALUES (10, 3, 2, '2025-09-03 16:45:08');

-- ----------------------------
-- Table structure for user_message
-- ----------------------------
DROP TABLE IF EXISTS `user_message`;
CREATE TABLE `user_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `message_id` bigint NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=未读, 1=已读',
  `read_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `message_id`(`message_id` ASC) USING BTREE,
  CONSTRAINT `user_message_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `message` (`message_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户消息状态' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_message
-- ----------------------------
INSERT INTO `user_message` VALUES (11, 1, 13, 0, NULL);
INSERT INTO `user_message` VALUES (12, 2, 13, 1, '2025-08-28 12:13:23');
INSERT INTO `user_message` VALUES (13, 3, 13, 1, '2025-08-28 11:38:19');
INSERT INTO `user_message` VALUES (14, 1, 14, 0, NULL);
INSERT INTO `user_message` VALUES (15, 2, 14, 1, '2025-08-28 12:13:23');
INSERT INTO `user_message` VALUES (16, 3, 14, 1, '2025-08-28 11:38:19');
INSERT INTO `user_message` VALUES (17, 1, 15, 0, NULL);
INSERT INTO `user_message` VALUES (18, 2, 15, 1, '2025-08-29 16:41:37');
INSERT INTO `user_message` VALUES (19, 3, 15, 1, '2025-08-29 16:41:04');
INSERT INTO `user_message` VALUES (20, 1, 16, 0, NULL);
INSERT INTO `user_message` VALUES (21, 2, 16, 1, '2025-09-03 16:49:09');
INSERT INTO `user_message` VALUES (22, 3, 16, 1, '2025-09-03 16:22:19');
INSERT INTO `user_message` VALUES (23, 1, 17, 0, NULL);
INSERT INTO `user_message` VALUES (24, 2, 17, 1, '2025-09-03 16:43:19');
INSERT INTO `user_message` VALUES (25, 3, 17, 1, '2025-09-12 15:11:24');

-- ----------------------------
-- Table structure for user_roles
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles`  (
  `user_id` int NOT NULL COMMENT '用户ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE,
  INDEX `fk_user_role_role`(`role_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_roles
-- ----------------------------
INSERT INTO `user_roles` VALUES (3, 1);
INSERT INTO `user_roles` VALUES (1, 2);
INSERT INTO `user_roles` VALUES (2, 3);
INSERT INTO `user_roles` VALUES (3, 3);
INSERT INTO `user_roles` VALUES (1, 4);
INSERT INTO `user_roles` VALUES (5, 4);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识符',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名，用于登录和显示',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt加密后的密码',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱地址，用于登录和找回密码',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号，用于登录和找回密码',
  `avatar_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'http://localhost:8080/uploads/avatar/default.png' COMMENT '用户头像存储路径',
  `balance` decimal(19, 4) NULL DEFAULT 0.0000 COMMENT '用户钱包余额，用于平台内交易',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间',
  `last_login` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `enabled` tinyint(1) NULL DEFAULT 1 COMMENT '账户状态：0-禁用, 1-正常',
  `is_seller` tinyint(1) NULL DEFAULT 0 COMMENT '商家标识：0-普通用户, 1-商家',
  `credit_score` int NULL DEFAULT 100 COMMENT '信用评分(0-100分)，基于交易行为计算',
  `following_count` int NOT NULL DEFAULT 0 COMMENT '关注人数',
  `follower_count` int NOT NULL DEFAULT 0 COMMENT '粉丝人数',
  `last_updated` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后信息更新时间',
  `password_level` int NULL DEFAULT 1 COMMENT '密码强度等级：1-弱, 2-中, 3-强',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户核心信息表（移除身份证认证，简化注册流程）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'user1', '$2a$10$e.Clkipbo5Wiq.Re.Adst.UEmaxsP3uPExwPjhUROByh3Oaptql.m', 'user1@example.com', '13800138001', 'http://localhost:8080/uploads/avatar/user1.png', 445.0000, '2025-08-01 09:19:13', '2025-07-30 14:30:00', 1, 0, 100, 0, 0, '2025-09-08 09:36:15', 1);
INSERT INTO `users` VALUES (2, 'seller1', '$2a$10$Bf2DHYFfmA5dSYBM1eg0ROfK9yRmZJnUvy9ezJhElWugXJneKxvBq', 'seller1@example.com', '13900139001', 'http://localhost:8080/uploads/avatar/default.png', 32797.7000, '2025-08-01 09:19:13', '2025-07-30 10:15:00', 1, 1, 98, 1, 1, '2025-09-13 15:40:28', 4);
INSERT INTO `users` VALUES (3, 'admin', '$2a$10$3xR14Kwp1QImARxJk.GUSe/MnEX5ek0enmPrdPvt2tZnN6SgtW0u6', 'admin@example.com', '13700137001', 'http://localhost:8080/uploads/avatar/other.png', 36978.0000, '2025-08-01 09:19:13', '2025-07-30 09:00:00', 1, 0, 100, 1, 1, '2025-09-12 15:48:00', 4);
INSERT INTO `users` VALUES (5, 'user2', '$2a$10$jsTqYufZ8syo0BlxV97.C.pzLfgWBBBPINE8uLzXxBTqYhv07pAnG', '465443@outlook.com', NULL, 'http://localhost:8080/uploads/avatar/default.png', 0.0000, '2025-09-12 15:52:57', NULL, 1, NULL, NULL, 0, 0, '2025-09-12 15:52:57', 1);

SET FOREIGN_KEY_CHECKS = 1;
