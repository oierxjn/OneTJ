# OneTJ 后端数据收集器规范（V1）

## 1. 背景与目标

本规范用于约定 OneTJ 客户端向“用户指定的可信任服务端（endpoint）”发送数据时的通信协议和数据格式。  
目标是让后端实现方在不依赖客户端源码的情况下，按统一规则完成接收、校验、响应和排障。

本规范为 **V1**，字段命名与当前客户端实现保持一致，避免新旧后端不兼容。

## 2. 范围

### 2.1 范围内

- 请求方式与请求体格式（HTTP + JSON）
- 字段定义与约束
- 响应 JSON 结构
- HTTP 状态码使用约定
- 失败处理与重试建议
- 限流策略建议
- 隐私与日志要求
- 生产/测试环境的传输规则

### 2.2 范围外

- 鉴权机制（如 HMAC、Bearer Token）
- 服务端数据库表结构与内部实现

## 3. 术语与约定

- `客户端`：OneTJ 应用。
- `服务端`：接收上报数据的 HTTP 服务。
- `endpoint`：数据接收地址，形如 `https://example.com/path`。
- `可信任 endpoint`：由用户明确配置并确认要发送的目标地址。
- `生产环境`：真实用户数据上报场景。
- `测试环境`：联调、开发或验收场景。

## 4. Endpoint 与传输规则

### 4.1 协议规则

- 生产环境：**仅允许 HTTPS**。
- 测试环境：允许 HTTP（仅用于测试，不可用于生产）。

### 4.2 方法与头

- 方法：`POST`
- 请求头：
  - `Content-Type: application/json; charset=utf-8`
  - `Accept: application/json`

## 5. 请求规范（V1）

### 5.1 请求体字段

请求体必须为 JSON 对象，字段如下：

| 字段名 | 类型 | 必填 | 说明 | 示例 |
| --- | --- | --- | --- | --- |
| `hashId` | string | 是（客户端固定发送） | `userid` 的 SHA-256 不可逆哈希（小写十六进制） | `0952d090ec4262c37f2d256bcb980faf051b6d736680cb2357165f0dc42225b3` |
| `userid` | string | 否（由客户端策略决定） | 用户 ID | `2333333` |
| `username` | string | 否（由客户端策略决定） | 用户姓名 | `张三` |
| `client_version` | string | 否（由客户端策略决定） | 客户端版本（版本号+构建号） | `1.2.3+45` |
| `device_brand` | string | 否（由客户端策略决定） | 设备品牌 | `HUAWEI` |
| `device_model` | string | 否（由客户端策略决定） | 设备型号 | `Pura 70` |
| `dept_name` | string | 否（由客户端策略决定） | 院系名称 | `计算机科学与技术学院` |
| `school_name` | string | 否（由客户端策略决定） | 学校名称 | `同济大学` |
| `gender` | string | 否（由客户端策略决定） | 性别文本 | `男` |
| `platform` | string | 否（由客户端策略决定） | 平台标识 | `android` |

### 5.2 字段约束

- 字段名区分大小写，必须严格按上表使用（包含 `hashId`）。
- 所有字段类型必须为字符串。
- 客户端可按用户策略发送字段子集；但请求体至少包含 `hashId`，不会是空对象 `{}`。
- 服务端应允许字段缺失，并按“存在字段即校验”的原则处理。
- 若字段存在，建议执行 `trim` 后校验非空。
- `platform` 建议值：`android`、`ios`、`ohos`、`windows`、`macos`、`linux`、`web`。

### 5.3 请求示例

```http
POST /collector/v1/events HTTP/1.1
Content-Type: application/json; charset=utf-8
Accept: application/json
```

```json
{
  "hashId": "0952d090ec4262c37f2d256bcb980faf051b6d736680cb2357165f0dc42225b3",
  "userid": "2333333",
  "username": "张三",
  "client_version": "1.2.3+45",
  "device_brand": "HUAWEI",
  "device_model": "Pura 70",
  "dept_name": "计算机科学与技术学院",
  "school_name": "同济大学",
  "gender": "男",
  "platform": "ohos"
}
```

## 6. 响应规范

服务端应返回 JSON 响应，客户端可据此做日志和问题定位。

### 6.1 成功响应

- 推荐状态码：`200` / `201` / `202`
- 响应体：

```json
{
  "status": "ok",
  "code": "SUCCESS",
  "message": "accepted",
  "request_id": "2f5b5a8a-37f7-4f09-8ad7-7e1f0d67bd2b"
}
```

字段说明：

- `status`：固定 `ok`
- `code`：业务成功码，固定 `SUCCESS`
- `message`：可读描述
- `request_id`：请求追踪 ID（建议返回）

### 6.2 失败响应

- 推荐状态码：`4xx` / `5xx`
- 响应体：

```json
{
  "status": "error",
  "code": "BAD_REQUEST",
  "message": "missing required field: userid",
  "request_id": "33f5c0fd-c901-4264-a6bb-81e4e06f1a0f"
}
```

字段说明：

- `status`：固定 `error`
- `code`：机器可读错误码（见 7.2）
- `message`：错误详情
- `request_id`：请求追踪 ID（建议返回）

## 7. 状态码与错误码规范

### 7.1 HTTP 状态码约定

- `2xx`：接收成功
- `400`：请求体格式错误或字段缺失/非法
- `401`：未授权（预留）
- `403`：禁止访问（预留）
- `409`：请求冲突（可选）
- `413`：请求体过大
- `415`：`Content-Type` 不支持
- `429`：请求过于频繁（限流）
- `5xx`：服务端内部错误

### 7.2 业务错误码建议

- `SUCCESS`
- `BAD_REQUEST`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `CONFLICT`
- `PAYLOAD_TOO_LARGE`
- `UNSUPPORTED_MEDIA_TYPE`
- `RATE_LIMITED`
- `SERVER_ERROR`

## 8. 客户端判定与重试建议

### 8.1 成功判定

- 第一层：HTTP 状态码是 `2xx`。
- 第二层：若响应体含 `status`，应为 `ok`；否则视为失败并记录异常日志。

### 8.2 重试策略（建议）

- 可重试：网络错误、超时、`429`、`5xx`
- 不可重试：大多数 `4xx`（除 `429`）
- 建议指数退避：例如 1s、2s、4s，最多 3 次

## 9. 限流建议

由于 `date` 由服务端维护，客户端允许重复发送请求（例如用户一天内多次打开应用属于正常行为）。

服务端应重点防止短时间高频请求，建议采用限流：

- 建议按 `IP` 维度限流。
- 建议采用固定窗口或滑动窗口策略（例如 60 秒内不超过 15 次）。
- 超限时返回 `429`，并在响应体中返回：
  - `status = error`
  - `code = RATE_LIMITED`
  - `message` 说明限流原因
- 可选返回 `Retry-After` 响应头，提示客户端退避重试时间。

## 10. 隐私与日志要求

- 服务端日志不应明文打印完整 `userid`、`username`。
- 建议日志使用脱敏形式（如部分掩码）。
- `hashId` 为不可逆哈希，可用于排障关联
- 响应体中不回传任何新增敏感信息。
- 客户端日志建议仅记录字段存在性、平台、状态码和 `request_id`。

## 11. 兼容性说明

- 本规范 V1 与当前客户端字段兼容：
  - 传输方式不变（`POST + application/json`）
  - 新增固定字段 `hashId`，其余字段保持原有语义
  - 类型不变（字符串）
- 服务端应采用“向后兼容”策略：允许字段子集并忽略未来新增的可选字段。

## 12. 最小实现检查清单（服务端）

- [ ] 仅接受 `POST`
- [ ] 校验 `Content-Type` 为 JSON
- [ ] 按“存在字段即校验”处理字段类型（字符串）
- [ ] 返回统一 JSON 响应结构（含 `status/code/message`）
- [ ] 失败场景返回匹配的 HTTP 状态码
- [ ] 返回 `request_id` 便于排障
- [ ] 对短时间高频请求进行限流并返回 `429`
- [ ] 生产环境仅开放 HTTPS
- [ ] 对敏感字段日志脱敏

## 13. 附录：curl 联调示例

```bash
curl -X POST "https://example.com/collector/v1/events" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Accept: application/json" \
  -d '{
    "hashId":"0952d090ec4262c37f2d256bcb980faf051b6d736680cb2357165f0dc42225b3",
    "userid":"2333333",
    "username":"张三",
    "client_version":"1.2.3+45",
    "device_brand":"HUAWEI",
    "device_model":"Pura 70",
    "dept_name":"计算机科学与技术学院",
    "school_name":"同济大学",
    "gender":"男",
    "platform":"ohos"
  }'
```
