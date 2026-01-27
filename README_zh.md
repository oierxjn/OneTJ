<div align="center">

[![OneTJ Logo](assets/icon/logo.jpg)](https://github.com/oierxjn/OneTJ)
# OneTJ（一统同济）

[中文](README_zh.md) | [English](README.md)

`一统同济` 是一款面向同济大学学生服务的第三方客户端。它为学生提供简洁、专注的使用体验，支持查看学生个人信息与校历相关内容。

原仓库：[FlowerBlackG/OneTJ](https://github.com/FlowerBlackG/OneTJ)

本项目的多数功能仍在持续开发中，可能存在不稳定性；欢迎各位反馈问题与建议。
<div>


## 功能特性
- 获取并展示学生个人信息
- 查看当前学期校历概览（含周数、学期名称）
- 基于 Hive 实现本地缓存，提升应用启动速度并支持离线读取数据

## 技术栈
- Flutter（Dart）

## 项目结构
- `lib/app/`：应用级常量定义、异常处理
- `lib/features/`：功能模块（启动页、登录、首页）
- `lib/models/`：通用数据模型（API 响应数据、本地数据模型）
- `lib/repo/`：本地仓库与缓存逻辑（令牌、学生信息、校历）
- `lib/services/`：API/服务层（封装同济相关接口 TongjiApi）
- `lib/l10n/`：国际化资源文件
- `assets/`：应用使用的静态资源

## 快速开始（开发）

项目目前并未完成所有功能的开发，所以没有提供 release 版本用于直接运行。

见 [CONTRIBUTING.md](CONTRIBUTING.md)

## 应用运行流程
1. 启动页初始化存储模块，并检查缓存的令牌有效性；
2. 若存在有效访问令牌，直接跳转至首页；
3. 若无有效令牌，则打开登录 WebView，通过授权码换取令牌；
4. 首页加载并展示学生个人信息与当前学期校历。

