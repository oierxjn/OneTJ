# OneTJ 应用图标流水线

本文说明如何从唯一母版 `assets/icon/origin.png` 重新生成全平台应用图标，以及验证产物是否正确。

## 1. 总览

母版只有一份：`assets/icon/origin.png`（正方形、带透明通道，当前约 1254×1254）。所有平台图标都由它派生，任何下游文件都不要手工修改。

生成分两步，由两个工具分别负责，互不重叠：

| 步骤 | 命令 | 产物 |
| --- | --- | --- |
| 1 | `fvm dart run flutter_launcher_icons` | Android 传统图标 `mipmap-*/launcher_icon.png` |
| 2 | `python scripts/build_app_icons.py` | 其余全部（Android 自适应图标、iOS、macOS、Web、Windows、HarmonyOS、应用内 logo） |

两步写入的路径不冲突，顺序任意；但必须**两步都执行**，否则会留下一个平台没更新的图标。

替换母版后的完整流程：

```bash
# 1. 覆盖母版
cp <新图标> assets/icon/origin.png

# 2. 先出 Android 传统图标（读取 pubspec.yaml 里的 flutter_launcher_icons 配置）
fvm dart run flutter_launcher_icons

# 3. 再出全平台图标
python scripts/build_app_icons.py
```

`scripts/build_app_icons.py` 在开头就 `os.chdir` 到仓库根目录，因此在任意目录下执行都可以，无需先 `cd`。

## 2. 环境要求

脚本依赖 Python 3 与两个第三方库：

```bash
python -m pip install pillow numpy
```

本仓库验证过的版本：Python 3.12、Pillow 12.x、numpy 2.x。

脚本本身不联网，也不依赖 Flutter SDK；只有第 1 步的 `flutter_launcher_icons` 需要 `fvm`。

## 3. 各平台产物与处理方式

脚本运行时按平台分组打印，输出大致如下：

```
master : assets/icon/origin.png (1254, 1254)
field  : #025BAA (badge border, used to flatten opaque platforms)
flutter / installer
  asset assets/icon/logo.png 256px (90391 B)
  ico  assets/icon/logo.ico (145857 B) sizes=[16, 24, 32, 48, 64, 128, 256]
       -> windows/runner/resources/logo.ico
ios / macos
  ios/Runner/Assets.xcassets/AppIcon.appiconset: 19 icons
  macos/Runner/Assets.xcassets/AppIcon.appiconset: 10 icons
web
  web: 5 icons
android
  adaptive: 5 foreground layers + android/app/src/main/res/mipmap-anydpi-v26/launcher_icon.xml
ohos
  ohos: ohos/entry/src/main/resources/base/media/logo.jpg + layered back/foreground

done. android legacy mipmaps are produced by: fvm dart run flutter_launcher_icons
```

注意 `field` 行打印的是徽标**边框色**，用于拍平 iOS/macOS/Web/HarmonyOS；Android 自适应图标的背景色另取自徽标**内部底色**（当前 `#0158A4`，见 `values/colors.xml`），两者数值接近但不相同。中间各行的图标数量会随 asset catalog 的声明变化，以上仅为当前仓库的实际输出。

### 3.1 Flutter / 安装包

- `assets/icon/logo.png` —— 应用内使用（关于页）的 256px 资源，对应 `pubspec.yaml` 的 `assets:` 条目。
- `assets/icon/logo.ico` —— 多尺寸 `.ico`，并复制一份到 `windows/runner/resources/logo.ico`（由 `Runner.rc` 引用）。

### 3.2 Android：传统图标 + 自适应图标

Android 同时需要两套图标，缺一不可：

- **传统图标**（API 24–25）：`mipmap-*/launcher_icon.png`，由 `flutter_launcher_icons` 生成。项目的 `minSdkVersion` 为 24，低于自适应图标要求的 API 26，所以这套不能删。
- **自适应图标**（API 26+）：由脚本生成，共三类文件：
  - `drawable-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher_foreground.png` —— 前景层，已把母版的底色按颜色距离抠掉，只留白色山形与青色元素；
  - `mipmap-anydpi-v26/launcher_icon.xml` —— 声明背景色 + 前景层；
  - `values/colors.xml` 中的 `ic_launcher_background` —— 从母版实测的品牌色。

**为什么必须自己做自适应图标。** Android 8+ 若找不到自适应图标，会走传统图标回退：把整张徽标缩小、塞进系统自绘的白色圆角底板里，四周留下大片空白，观感与设计稿不符。补上自适应图标后，系统改为「品牌色背景 + 前景层」合成，再由 launcher 的遮罩（圆形/圆角方形/squircle）裁切背景色，图形不再被白色底板包住。

**为什么脚本做而不是 Android Studio 的 Image Asset 向导。** 向导只能手工调缩放和位移，无法从母版自动抠底，也无法在母版更换或 CI 环境下复现；脚本按颜色距离（阈值 `KEY_LO=24`、`KEY_HI=56`，针对实测底色 `#0158A4`）自动生成前景层，并可一键重跑。

前景层内缩到画布的 0.70（`ANDROID_FOREGROUND_SAFE`）。自适应图标画布为 108×108dp，但只有中央 66dp 在任何遮罩形状下都保证可见；圆形遮罩保留画布内接正方形，即 1/√2 ≈ 0.707，故 0.70 可安全通过所有 launcher 遮罩。

### 3.3 iOS / macOS

脚本解析两个 appiconset 的 `Contents.json`，按其中声明的文件名与像素尺寸逐个原地重写。因此脚本**不会**写入目录里没有声明的文件，也不会产生孤立文件（`flutter_launcher_icons` 的 iOS 生成器会，所以这里不用它）。

产物是拍平到徽标自身边框色上的整版方块。iOS 会自行套 squircle 遮罩，且 App Store 图标不允许带透明通道，整版方块可同时避免「双重圆角」和校验失败。

### 3.4 Web

`web/favicon.png`、`web/icons/Icon-192.png`、`Icon-512.png` 为整版方块；`Icon-maskable-192.png`、`Icon-maskable-512.png` 为可遮罩图标，图形内缩到 80%（`WEB_MASKABLE`），避免被 launcher 遮罩裁到。

### 3.5 HarmonyOS

- `ohos/entry/src/main/resources/base/media/logo.jpg` —— 启动窗口图标；
- `ohos/AppScope/resources/base/media/{background,foreground}.png` —— 分层图标的后景（纯品牌色）与前景（图形内缩到 0.72，`OHOS_FOREGROUND_SAFE`）。

## 4. 验证

脚本正常运行不代表产物进了安装包，建议按需验证。

### 4.1 检查资源确实打进 APK

Release 构建会混淆资源名，按文件名搜索会落空，需用 `aapt2` 查资源表：

```bash
AAPT2=$(ls $ANDROID_HOME/build-tools/*/aapt2.exe | tail -1)
"$AAPT2" dump resources build/app/outputs/flutter-apk/app-release.apk \
  | grep -E "ic_launcher_background|ic_launcher_foreground"
```

应当能看到 `color/ic_launcher_background` 以及 5 个密度的 `drawable/ic_launcher_foreground`。

### 4.2 在模拟器上确认实际渲染

模拟器是最直观的验证方式（Android Studio 的 Device Manager，或命令行）：

```bash
emulator -avd <AVD 名称> -no-snapshot &
adb wait-for-device
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS \
  -d package:<applicationId>
adb exec-out screencap -p > appinfo.png
```

注意 AVD 的 `/data` 分区要放得下 release 包（约 71.5MB 的通用包），否则会报 `Requested internal only, but not enough space`。

## 5. 调参位置

改动设计时通常只需要改这几处（均在 `scripts/build_app_icons.py` 顶部）：

| 常量 | 作用 |
| --- | --- |
| `MASTER` | 母版路径 |
| `ANDROID_FOREGROUND_SAFE` | Android 前景图形内缩比例，默认 0.70 |
| `OHOS_FOREGROUND_SAFE` | HarmonyOS 前景内缩比例，默认 0.72 |
| `KEY_LO` / `KEY_HI` | 抠底的软阈值；换配色母版时主要调这里 |
| `ANDROID_FOREGROUND_DIRS` | 前景层输出的密度与像素尺寸 |

底色默认由母版实测得到（`measure_interior_field`，取蓝色像素簇的中位数），一般无需手填；若母版配色变化导致抠底异常，才需要改 `KEY_LO` / `KEY_HI`。

## 6. 常见问题

**抠底后图形被削掉一块，或残留半透明底色。** 母版底色与 `KEY_LO`/`KEY_HI` 不匹配。先看脚本打印的 `field` 是否等于母版实际底色，再据此调整阈值。

**图形在圆形遮罩下显得偏小。** 检查 `ANDROID_FOREGROUND_SAFE`，以及母版中图形本身是否留有过多内边距——脚本只按比例内缩，不会裁剪母版留白。

**重跑后需要重新签名吗？** 不需要。本流水线只改写图标资源，不触碰签名配置。
