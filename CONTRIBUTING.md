# 贡献指南

欢迎参与本项目的开发！本指南将帮助您了解项目的开发流程和规范，确保团队协作高效顺畅。

## 1. 项目介绍

### 1.1 项目概述

这是一个基于 Flutter 框架开发的跨平台应用，主要功能包括：
- 学生个人信息展示

### 1.2 技术栈

- **框架**：Flutter
- **语言**：Dart

## 2. 开发环境搭建

### 2.1 安装必要工具

推荐使用 FVM 管理 Flutter 版本。  

下载本项目需要的 Flutter 鸿蒙版本：

```bash
git clone -b oh-3.27.4-dev https://gitcode.com/openharmony-tpc/flutter_flutter.git
```

将其放入 FVM 的版本文件夹中。使用 `fvm list` 查看是否已经添加，再用 `fvm use <版本名>` 切换到该版本。

运行 `fvm flutter doctor` 检查环境是否配置正确。

一般来说，你还需要下载鸿蒙的 [Command Line Tools](https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos)，将${Command Line Tools解压路径}\command-line-tools\bin目录配置到系统或者用户的PATH变量中。  

构建中遇到问题，请及时联系项目维护者（已经快忘记怎么配了）

**安装依赖**：
```bash
fvm flutter pub get
```

**生成序列化代码**：

*一般来说仓库已经构建完成，可以跳过这一步*。
```bash
dart run build_runner build
```

### 2.1.1 local_packages 拉取流程

项目包含 `local_packages` 目录，用于存放特殊处理的 Flutter 插件（如 `flutter_inappwebview`）。这些插件需要单独构建和测试。

默认情况下，你拉取了这个项目，`local_packages` 已经构建完成，你可以直接使用，跳过这个章节。

#### 2.1.1.1 flutter_inappwebview

`flutter_inappwebview` 是一个 Flutter 插件，用于在应用内嵌入 WebView。

**拉取**：
```bash
cd local_packages
git clone -b br_v6.1.5_ohos https://gitcode.com/openharmony-sig/flutter_inappwebview.git
```
即拉取 `br_v6.1.5_ohos` 分支的代码到 `local_packages`。

确认代码是 `br_v6.1.5_ohos` 分支的代码后，删去 `flutter_inappwebview` 目录下的 `.git` 目录，避免与主项目的 `.git` 冲突。由主项目的 `.git` 管理。

**构建**：
pubspec.yaml 中添加依赖：
```yaml
dependencies:
  flutter_inappwebview:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview
```
并且需要覆盖依赖：
```yaml
dependency_overrides:
  flutter_inappwebview_platform_interface:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_platform_interface
  flutter_inappwebview_android:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_android
  flutter_inappwebview_ios:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_ios
  flutter_inappwebview_macos:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_macos
  flutter_inappwebview_web:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_web
  flutter_inappwebview_ohos:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_ohos
  flutter_inappwebview_windows:
    path: ./local_packages/flutter_inappwebview/flutter_inappwebview_windows
```

**使用**：
在 `pubspec.yaml` 中添加依赖后，运行 `fvm flutter pub get` 来获取插件。  
确认插件添加成功后，即可在项目中使用 `flutter_inappwebview` 插件：

```dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
```



### 2.2 开发工具

推荐使用以下工具：
- **IDE**：VS Code
- **插件**：
  - Flutter 插件
  - Dart 插件

## 3. 代码规范

### 3.1 Dart 代码规范

- 遵循 [Dart 官方代码风格指南](https://dart.dev/guides/language/effective-dart/style)
- 使用 `dart format` 格式化代码：
  ```bash
  fvm dart format .
  ```

- 使用 `dart analyze` 检查代码质量：
  ```bash
  fvm dart analyze
  ```

### 3.2 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | 大驼峰命名法 | `LoginViewModel` |
| 方法名 | 小驼峰命名法 | `handleLogin` |
| 变量名 | 小驼峰命名法 | `isLoading` |
| 常量名 | 大写下划线命名法 | `API_BASE_URL` |
| 私有成员 | 下划线前缀 | `_privateField` |
| 文件名 | 小写下划线分隔 | `login_view_model.dart` |

### 3.3 架构规范

项目采用 MVVM 架构：

- **Model**：数据模型和业务逻辑
- **ViewModel**：连接 Model 和 View 的中间层
- **View**：UI 组件

文件结构：
```
lib/
├── features/          # 功能模块
│   ├── login/        # 登录模块
│   │   ├── views/    # UI 组件
│   │   ├── view_models/  # 视图模型
│   │   └── models/   # 数据模型
│   └── ...
├── models/           # 全局数据模型
├── services/         # 服务层
├── repo/             # 数据仓库
└── utils/            # 工具类
```

## 4. 提交规范

### 4.1 提交消息格式

使用以下格式提交代码：
```
<类型>: <描述>

[可选的详细描述]

[关联的 Issue 编号] #<issue-number>
```

### 4.2 提交类型

| 类型 | 说明 |
|------|------|
| Feat | 新功能 |
| Fix | 修复 bug |
| Docs | 文档更新 |
| Style | 代码风格调整 |
| Refactor | 代码重构 |
| Test | 测试相关 |
| Chore | 构建过程或辅助工具的变动 |
| Perf/Optimize | 性能优化 |

### 4.3 示例

```
Feat: 添加登录页面

- 实现登录表单 UI
- 添加表单验证逻辑
- 集成身份认证服务

#123
```

## 5. 分支管理

### 5.1 分支命名规范

| 分支类型 | 命名格式 | 示例 |
|----------|----------|------|
| 主分支 | main | main |
| 开发分支 | develop | develop |
| 功能分支 | feature/<功能名> | feature/login-page |
| 修复分支 | fix/<bug描述> | fix/auth-state-mismatch |
| 热修复分支 | hotfix/<bug描述> | hotfix/crash-on-startup |

### 5.2 分支流程

1. **主分支 (main)**：仅包含稳定发布的代码
2. **开发分支 (develop)**：包含最新开发代码，所有功能分支都从 develop 分支创建
3. **功能分支**：开发新功能时创建，完成后合并回 develop 分支
4. **修复分支**：修复 bug 时创建，完成后合并回 develop 分支
5. **发布分支**：准备发布时创建，用于最终测试和准备发布
6. **热修复分支**：修复已发布版本的紧急 bug，直接从 main 分支创建，修复后合并回 main 和 develop 分支

## 6. 测试规范

### 6.1 单元测试

- 为核心业务逻辑编写单元测试
- 测试文件与被测试文件同名，后缀为 `_test.dart`
- 运行单元测试：
  ```bash
  fvm flutter test
  ```

### 6.2 集成测试

- 为关键流程编写集成测试
- 测试文件位于 `test/integration_test/` 目录下
- 运行集成测试：
  ```bash
  fvm flutter test integration_test/
  ```

### 6.3 UI 测试

- 为重要 UI 组件编写测试
- 使用 Flutter 测试框架进行 UI 测试

## 7. 开发流程

1. **创建 Issue**：在 GitHub 上创建 Issue，描述要开发的功能或修复的 bug
2. **分配任务**：将 Issue 分配给相关开发人员
3. **创建分支**：从 develop 分支创建功能分支或修复分支
4. **开发实现**：按照规范开发代码，编写测试
5. **代码审查**：提交 Pull Request，等待团队成员审查
6. **合并代码**：审查通过后，将分支合并回 develop 分支
7. **关闭 Issue**：将相关 Issue 标记为已完成

## 8. 代码审查

### 8.1 审查要点

- 代码是否符合规范
- 功能是否实现完整
- 是否包含足够的测试
- 是否存在性能问题
- 是否存在安全隐患

### 8.2 审查流程

1. 提交 Pull Request 时，自动触发 CI 检查
2. 至少需要 1 名团队成员审查通过
3. 审查过程中，作者需要及时回应审查意见
4. 所有审查意见解决后，才能合并代码

## 9. 常见问题

### 9.1 依赖冲突

如果遇到依赖冲突，可以尝试以下方法：

```bash
# 清除缓存
fvm flutter pub cache repair

# 更新依赖
fvm flutter pub upgrade
```

### 9.2 构建失败

- 检查是否安装了正确的 Flutter 版本
- 检查是否运行了 `build_runner build` 生成序列化代码
- 检查是否有未解决的编译错误

### 9.3 测试失败

- 检查测试环境是否正确配置
- 检查测试用例是否符合预期
- 检查是否有环境依赖问题

## 10. 联系方式

- **GitHub Issues**：[Issues](https://github.com/oierxjn/OneTJ/issues)
- **邮件**：[2553759@tongji.edu.cn](mailto:2553759@tongji.edu.cn)

## 11. 注意事项

- 开发过程中请尽量遵循本指南的规范
- 遇到协作问题及时沟通，不要独自钻研
- 定期更新本地代码，使用 `git pull --rebase` 避免冲突
- 尊重他人的代码，不要随意修改
- 保持代码简洁，避免冗余
- 适当添加注释，解释复杂逻辑

感谢您的贡献！
