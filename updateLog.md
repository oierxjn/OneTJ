2.3.0 (12)
---
Version: 2.3.0
Build Time: 2026.03.21-02:58

### Update Log:
+ 新增应用自动更新功能，支持 Windows/Android 版本检测、下载与安装流程
+ 新增启动页自定义壁纸与壁纸编辑器，支持内置壁纸、本地文件选择与预览
+ 优化仪表盘加载动画与课表周数显示表现
* 修复设置变更后首页即将到来的课程未重新规划的问题
* 修复即将到来的课程在时间到达后未及时切换状态的问题
* 优化壁纸路径解析、缓存与预览错误处理，提升启动页稳定性

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.2.4 (11)
---
Version: 2.2.4
Build Time: 2026.03.13-16:00

### Update Log:
* 重构缓存仓库体系，统一课程表、学生信息、成绩与校历缓存实现
+ 新增课程表/学生信息/本科生成绩仓库测试用例，提升数据层稳定性
+ 新增课程表“上次同步时间”显示，并优化学期键解析与缓存读取性能
+ 新增即将到来的课程“进行中”状态标识，修复课程状态判断逻辑
* 修复设置页闪烁、跨周校历拉取延迟与课程表缓存元数据读取问题
* 修复 OHOS 设备信息获取并优化相关依赖版本

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.2.3 (10)
---
Version: 2.2.3
Build Time: 2026.03.07-00:24

### Update Log:
+ 新增应用内文件日志记录能力，并重构日志模块命名与结构
+ 新增旧版本 Hive 数据清理功能，补充设置页清理入口并修复状态刷新问题
+ 新增用户信息收集策略、学生信息缓存与开发者调试上传能力
+ 新增课程详情底部弹窗与设置页卡片状态可视化，优化界面分区布局
* 修复切换用户后不上传数据、上传请求头缺失与上传中状态残留问题
* 优化 Windows 卸载清理用户数据与日志的安装配置

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.2.2 (9)
---
Version: 2.2.2
Build Time: 2026.03.04-10:21

### Update Log:
+ 新增关于页，补充应用信息、贡献者、鸣谢、QQ群二维码与复制功能
+ 新增 Hive 数据迁移功能，改善版本升级后的本地数据兼容性
* 优化仪表盘卡片布局与样式表现
* 调整 WebView 存储路径，修复潜在权限问题
* 新增跨平台应用版本更新脚本，并补充 Windows 路径相关构建配置

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.2.1 (8)
---
Version: 2.2.1
Build Time: 2026.03.03-00:51

### Update Log:
+ 新增首页“即将到来的课程”显示策略配置（本周 / 今日 / 按数量）
+ 优化并修复设置页课程数量编辑体验，支持数量变化实时回显
+ 修复切换显示模式后因隐藏输入项导致的保存失败问题
+ 修复 DashboardUpcomingMode 非法值回退逻辑，默认值行为与全局配置保持一致
+ 优化仪表盘课程卡片与时间徽章布局，并改进即将到来课程计算逻辑
+ 优化课表时间轴展示，增加时间标签起止时间并补充动画/组件拆分

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.2.0 (7)
---
Version: 2.2.0
Build Time: 2026.03.02-09:36

### Update Log:
+ 新增课程时间段配置与校验逻辑
+ 设置页支持时间槽编辑、异常处理与开发者模式
+ 新增应用日志系统，并提供日志查看能力
+ 修复默认时间槽结束分钟数问题并优化构建配置

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.1.0 (6)
---
Version: 2.1.0
Build Time: 2026.02.11-12:37

### Update Log:
+ 新增成绩查询功能（含本科生成绩模型、接口与缓存）
+ 新增工具页入口并接入成绩相关视图
+ 重构设置页状态管理，补充最大周数与重置设置能力
+ 优化课表滚动同步及错误处理，提升交互稳定性

### Contributors:
[oierxjn](https://github.com/oierxjn)

2.0.0 (5)
---
Version: 2.0.0
Build Time: 2026.02.05-00:58

### Update Log:
+ 完成跨平台重构，统一 Android/Windows/OpenHarmony 基础能力
+ 实现登录与鉴权流程（OAuth、Token 存储与刷新）
+ 新增首页与课程表模块，支持教学周展示和“跳转到今天”
+ 完成设置、路由与本地化重构，优化多语言与导航结构
+ 增强异常处理、缓存持久化与网络解析稳定性
+ 新增 Windows 安装包配置及应用图标资源

### Contributors:
[oierxjn](https://github.com/oierxjn)

1.1.0 (4)
---
Version: 1.1.0
Build Time: 2026.01.28-13:05

### Update Log:
+ 新增绩点查询功能
- 删除通知详情中的其他应用打开按钮

### Contributors:
[oierxjn](https://github.com/oierxjn)

1.0.1 (3)
---
Version: 1.0.1
Build Time: 2025.12.28-21:05

### Update Log:
* 优化UI设计
* 大规模重构兼容

### Contributors:
[oierxjn](https://github.com/oierxjn)  
[streetartist](https://github.com/streetartist)

1.0.0 (2)
---
Version: 1.0.0  
Build Time: 2025.12.26-0:32

### Update Log:
+ 隐私政策页面

### Contributors:
[oierxjn](https://github.com/oierxjn)

0.0.1 (1)
---
Version: 0.0.1  
Build Time: 2025.12.25-20:41

### Update Log:
+ 单日课表
+ 物理实验计算

### Contributors:
[oierxjn](https://github.com/oierxjn)
