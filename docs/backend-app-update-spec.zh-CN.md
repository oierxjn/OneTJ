# OneTJ 后端自动更新服务规范（V1）

## 1. 目标

- 为 OneTJ 客户端（V1：`windows`、`android`）提供统一更新检查接口。
- 客户端默认启动后自动检查（24 小时节流），并支持 About 页手动检查。
- V1 为可选更新，不做强更拦截，不做灰度，仅 `stable` 单渠道。

## 2. Endpoint

- 方法：`GET`
- 路径：`/updater/v1/check`
- 协议：生产环境仅 HTTPS

请求 Query 参数：

| 参数 | 类型 | 必填 | 说明 | 示例 |
| --- | --- | --- | --- | --- |
| `platform` | string | 是 | 平台标识 | `windows` / `android` |
| `arch` | string | 否 | 架构标识（Windows 推荐） | `x64` |
| `current_version` | string | 是 | 客户端语义版本号 | `2.2.4` |
| `current_build` | string | 是 | 客户端构建号 | `11` |

## 3. 响应结构

统一响应：

```json
{
  "status": "ok",
  "code": "SUCCESS",
  "message": "accepted",
  "request_id": "d77f8399-1f68-4d1f-95e7-4f6a7d2d67a0",
  "data": {}
}
```

`data` 字段定义：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `has_update` | bool | 是 | 是否有更新 |
| `latest_version` | string | `has_update=true` 时必填 | 最新语义版本 |
| `latest_build` | int | `has_update=true` 时必填 | 最新构建号 |
| `release_notes` | string | 否 | 更新说明（纯文本） |
| `published_at` | string | 否 | 发布时间（ISO-8601） |
| `mandatory` | bool | 否 | 是否强更（V1 固定 `false`） |
| `download_url` | string | `has_update=true` 时必填 | 更新包下载地址 |
| `sha256` | string | `has_update=true` 时必填 | 更新包 SHA-256（小写十六进制） |
| `file_size` | int | 否 | 文件字节数 |
| `min_supported_version` | string | 否 | 最低兼容版本（V1 可空） |

有更新示例：

```json
{
  "status": "ok",
  "code": "SUCCESS",
  "message": "accepted",
  "request_id": "f8a7f8b0-a309-4fdd-8b14-a2bdce47c39b",
  "data": {
    "has_update": true,
    "latest_version": "2.3.0",
    "latest_build": 12,
    "release_notes": "1. 新增自动更新\\n2. 修复登录状态问题",
    "published_at": "2026-03-20T08:00:00Z",
    "mandatory": false,
    "download_url": "https://download.example.com/OneTJSetup_2.3.0_12.exe",
    "sha256": "4f1f2d5a3e8c2f2b4e8aa56d32298f81f7fd46f0614b7fbf9360dbf6abf35f0f",
    "file_size": 48235776,
    "min_supported_version": "2.0.0"
  }
}
```

无更新示例：

```json
{
  "status": "ok",
  "code": "SUCCESS",
  "message": "accepted",
  "request_id": "a4dd5f8f-16f2-45d5-bfc9-825f9dd44f9c",
  "data": {
    "has_update": false
  }
}
```

## 4. 版本比较规则

- 先比较 `current_version` 与服务端版本（语义版本：`major.minor.patch`）。
- 若语义版本相等，再比较 `current_build` 与 `latest_build`。
- 仅当服务端更高时返回 `has_update=true`。

## 5. 文件发布与校验要求

- Windows：发布全量安装包（`*.exe`）。
- Android：发布 APK（`*.apk`）。
- 每个发布文件必须提供对应 `sha256`，客户端下载完成后先校验再安装。
- 下载 URL 必须为 HTTPS，且建议短时效签名链接或受控下载域名。

## 6. 状态码与错误码

- `200`：请求成功（有/无更新均为成功）
- `400`：参数缺失或格式错误
- `429`：频率过高
- `5xx`：服务端异常

业务错误码建议：

- `SUCCESS`
- `BAD_REQUEST`
- `RATE_LIMITED`
- `SERVER_ERROR`

## 7. 观测与日志

服务端最少记录：

- `request_id`
- `platform`
- `arch`
- `current_version`
- `current_build`
- `has_update`
- 响应状态码与耗时

要求：

- 禁止记录敏感凭据。
- `request_id` 必须返回给客户端，便于联调排障。
