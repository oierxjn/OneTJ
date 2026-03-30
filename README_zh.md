<div align="center">

[![OneTJ Logo](assets/icon/logo.jpg)](https://github.com/oierxjn/OneTJ)
# OneTJ（一统同济）

[中文](README_zh.md) | [English](README.md)

`OneTJ` 是一个基于 Flutter 开发的同济大学第三方客户端，当前重点覆盖统一认证登录、首页信息展示、课表、成绩与实用工具等学生常用功能。

原仓库：[FlowerBlackG/OneTJ](https://github.com/FlowerBlackG/OneTJ)

</div>

## 项目状态

项目仍在持续开发中，部分功能已经可以稳定使用，部分功能仍会继续迭代。


## 当前功能

- 基于 WebView 的同济统一认证登录流程
- 首页仪表盘：学生信息与当前学期校历概览
- 课表查看
- 成绩模块
- 工具页入口，包括物理实验相关页面
- 设置、关于页、开发者选项、日志查看
- 基于 Hive 和 shared preferences 的本地持久化
- 中英文双语支持

## 技术栈

- Flutter / Dart
- Material 3
- `go_router`
- Hive
- `flutter_inappwebview`

## 平台与依赖说明

- 本仓库的 Flutter 命令统一使用 `fvm flutter`。
- 项目依赖本地 OpenHarmony 分支的 `flutter_inappwebview`，目录位于
  `local_packages/flutter_inappwebview`。
- `pubspec.yaml` 通过 `dependency_overrides` 固定了
  `flutter_inappwebview_*` 各子包来源。
- HarmonyOS 相关依赖，例如 `path_provider`、`device_info_plus`、
  `image_picker`、`open_filex`、`flutter_math_fork`，均使用了兼容分支。

## 快速开始

1. 确保本机已安装 FVM，并准备好项目所需的 Flutter SDK。
2. 确保工作区内存在 `local_packages/flutter_inappwebview`。
3. 安装依赖：

```bash
fvm flutter pub get
```

4. 如果需要重新生成序列化代码，执行：

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

5. 运行项目：

```bash
fvm flutter run
```

## 项目结构

- `lib/app/`：应用启动、依赖注入、常量、生命周期、路由
- `lib/features/`：功能模块，如 launcher、login、dashboard、timetable、grades、tools、settings、about、app update
- `lib/models/`：共享数据模型与序列化相关文件
- `lib/repo/`：缓存与持久化仓库
- `lib/services/`：接口封装与应用服务
- `lib/l10n/`：国际化资源
- `assets/`：应用静态资源
- `local_packages/`：本地插件 fork 与覆盖依赖
- `docs/`：补充文档

## 应用流程

1. 应用启动时初始化依赖与生命周期服务。
2. Launcher 检查本地缓存的认证状态。
3. 如果需要登录，则进入基于 WebView 的认证流程。
4. 登录后进入主界面，包含首页、课表、工具、设置四个主标签。
5. 各功能模块按需拉取并缓存学生相关数据。

## 开发注意事项

- 不要修改 `windows/flutter/ephemeral/` 下的生成文件。
- 不要手动编辑 `*.g.dart`，请通过 `build_runner` 重新生成。
- 如果终端里中文显示异常，不要据此修改原文内容。

更多协作约定见 [CONTRIBUTING.md](CONTRIBUTING.md)。

![Repo Status](https://raw.githubusercontent.com/oierxjn/OneTJ/refs/heads/metrics-renders/metrics.svg)

![Code Churn](https://raw.githubusercontent.com/oierxjn/OneTJ/refs/heads/metrics-renders/daily-churn.svg)
