# Flutter 前端与后端对接审计问题清单（当前）

## 1) 已确认漏洞/风险

### [高] 明文传输风险（HTTP + Android 明文流量放行）
- 位置：
  - `pixelpad/lib/features/make/data/make_api.dart`
  - `pixelpad/lib/features/profile/data/user_repository.dart`
  - `pixelpad/lib/features/device/data/inventory_api_service.dart`
  - `pixelpad/android/app/src/main/AndroidManifest.xml` (`android:usesCleartextTraffic="true"`)
- 说明：默认后端地址为 `http://127.0.0.1:8080`，且 Android 允许明文流量，存在中间人窃听/篡改风险。

### [高] 聊天记录明文落盘
- 位置：`pixelpad/lib/features/device/data/warehouse_chat_storage.dart`
- 说明：聊天记录 JSON 明文写入 `SharedPreferences`，设备被调试/备份恢复时存在泄露面。

### [中] 会话过期策略与后端 token 生命周期不一致
- 位置：`pixelpad/lib/features/profile/data/user_repository.dart`
- 说明：本地过期判断使用固定 `_sessionTtl=7天`，未按 `expires_in` 精确过期，可能导致体验问题（被动 401 后清会话）。

### [中] 多处对接失败被静默降级，降低可观测性
- 位置：
  - `pixelpad/lib/features/make/presentation/screens/bean_preset_screen.dart`
  - `pixelpad/lib/features/device/presentation/screens/device_screen.dart`
  - `pixelpad/lib/features/device/presentation/screens/warehouse_chat_screen.dart`
- 说明：多处 `catch` 后直接 fallback，无明确用户提示，造成“看似可用但数据可能非实时”的漏斗。

## 2) 已确认漏斗点（影响用户流程）

1. 图片处理链路（创建会话/像素优化/去背景/映射）任一环节失败会中断；历史上错误提示偏泛化。  
2. 仓库页库存/记录同步失败时会回退本地数据；若提示不足，用户难区分“实时数据”与“回退数据”。  
3. 注册页存在协议勾选 UI，但此前未在提交时强校验，易产生流程与合规风险。

## 3) 本轮已完成的用户体验改进（报错提示）

### 登录/注册提示细化
- 文件：
  - `pixelpad/lib/features/auth/presentation/screens/phone_login_screen.dart`
  - `pixelpad/lib/features/auth/presentation/screens/register_guide_screen.dart`
- 改进：
  - 根据状态码区分提示（401/403、409、429、5xx 等）
  - 区分超时与网络连接失败
  - 注册时强制校验勾选《用户协议》《隐私政策》

### 图片处理链路提示细化
- 文件：`pixelpad/lib/features/make/presentation/screens/make_screen.dart`
- 改进：
  - 按步骤输出更具体失败原因（创建会话/像素优化/背景移除/颜色映射）
  - 解析状态码并提示登录失效、请求频繁、图片过大、服务繁忙等
  - 避免直接把异常对象原样暴露给用户

### 预设页回退状态显式化
- 文件：`pixelpad/lib/features/make/presentation/screens/bean_preset_screen.dart`
- 改进：
  - 在线配置拉取失败时，页面显示“已使用本地预设”提示，避免静默降级

### 仓库/设备页同步失败提示显式化
- 文件：
  - `pixelpad/lib/features/device/presentation/screens/device_screen.dart`
  - `pixelpad/lib/features/device/presentation/screens/warehouse_chat_screen.dart`
- 改进：
  - 设备页新增同步状态横幅（登录失效/超时/限流/服务异常/回退本地）
  - 仓库聊天在未选择入库/出库时给出引导提示
  - 入库/出库失败提示按错误类型细化
  - 统计刷新失败时给出一次性回退提示，减少用户困惑

## 4) 后续建议（按优先级）

1. **P0**：生产构建禁用 HTTP，强制 HTTPS；Android release 关闭 cleartext。  
2. **P1**：聊天记录改为加密存储（或最小化落盘策略）。  
3. **P1**：统一网络错误模型（状态码->可读文案）并收敛重复逻辑。  
4. **P2**：会话有效期与后端 `expires_in` 对齐，减少被动掉线。  
