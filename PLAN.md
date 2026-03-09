Plan: 前端现有 UI 对接后端未接入 API
排除媒体和 UI 控制暴露后，还有 7 个后端 API 未接入。其中 5 个可直接对接到现有 UI，1 个需少量适配，1 个无 UI 对应。

可直接接入现有 UI ✅（5 个）
#	后端 API	对接到的现有 UI	当前数据源
1	POST /inventory/transactions	warehouse_chat_screen.dart 的存豆/取豆操作（_SelectorPanel 选色号+数量）	SharedPreferences 聊天记录
2	GET /inventory/brands	device_screen.dart 的 _DeviceSummaryCard（总豆子数、色号数）+ bean_preset_screen.dart 品牌列表	硬编码示例数据 / 硬编码 7 品牌
3	GET /inventory/brands/{brand_id}	device_screen.dart 品牌库存摘要	硬编码
4	GET /inventory/brands/{brand_id}/beads	device_screen.dart 缺色警告 _MissingColorChip（硬编码 H2/F7/F13）+ warehouse_chat_screen.dart 的 _StatsPanel 统计	硬编码 / 聊天消息解析
5	GET /settings/list	bean_preset_screen.dart 调色板选择（当前本地拼接 $brand-$count.json）	本地拼接
核心改动思路：把 SharedPreferences / 硬编码替换为后端 API 调用，UI 结构基本不变。

需少量适配 ⚠️（1 个）
#	后端 API	问题
6	GET /inventory/transactions/{transaction_id}	DeviceScreen 有使用记录列表 _UsageRecordCard，但后端只有单条查询，缺少 GET /inventory/transactions 列表端点。需要后端补一个列表接口，或前端本地维护 transaction_id 索引
无 UI 对应（1 个）
#	后端 API	说明
7	GET /health	无现有 UI，可启动时后台静默调用
个人资料对接补充
PUT /users/me 已对接。后端支持但前端缺少修改入口的字段：

phone — UI 不可编辑（仅登录用，合理）
password — 无修改密码 UI（后续可考虑加入"设置"页面）
其余 username、email、birthday、mbti、avatarMode 均已在 ProfileEditScreen 完整对接。

实施建议
Phase 1 — 豆仓数据层：新建 InventoryApiService，封装 5 个 inventory API，创建对应模型（Brand、Bead、InventoryTransaction）

Phase 2 — 替换数据源：DeviceScreen / WarehouseChatScreen / BeanPresetScreen 中将 SharedPreferences 替换为 API 调用

Phase 3 — Settings 动态化：BeanPresetScreen 从 /settings/list 获取可用配置