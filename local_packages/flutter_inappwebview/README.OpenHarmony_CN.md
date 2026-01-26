> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>flutter_inappwebview</code> </h1>
</p>

本项目基于 [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  flutter_inappwebview:
    git:
      url: "https://gitcode.com/openharmony-sig/flutter_inappwebview.git"
      path: "flutter_inappwebview"  

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](/flutter_inappwebview/example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;


## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### InAppWebView API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| key                 | Flutter框架基础标识符              | Key      | /     | Key    | yes         |
| controllerFromPlatform | 从平台获取WebView控制器的回调  | function | PlatformInAppWebViewController controller | void | yes         |
| windowId            | 窗口ID标识符                    | int      | /     | int    | no           |
| initialUrlRequest   | 要加载的初始URLRequest           | WebUri   | /     | WebUri | yes          |
| initialFile         | 要加载的初始本地文件路径         | String   | /     | String | yes          |
| initialData         | 要加载的初始HTML数据             | InAppWebViewInitialData | / | InAppWebViewInitialData | yes          |
| onWebViewCreated    | WebView创建事件回调              | function | InAppWebViewController controller | void | yes          |
| onLoadStart         | URL加载开始事件回调              | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onLoadStop          | URL加载完成事件回调              | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onReceivedError     | 加载错误接收回调                 | function | InAppWebViewController controller, WebUri? url, WebResourceError error | void | yes          |
| onReceivedHttpError | HTTP错误接收回调                 | function | InAppWebViewController controller, WebUri? url, WebResourceResponse response | void | yes          |
| shouldOverrideUrlLoading | URL加载拦截回调              | function | InAppWebViewController controller, NavigationAction navigationAction | Future<NavigationActionPolicy?> | yes          |
| onConsoleMessage    | 控制台消息回调                 | function | InAppWebViewController controller, ConsoleMessage consoleMessage | void | yes          |
| onProgressChanged   | 加载进度变化回调               | function | InAppWebViewController controller, int progress | void | yes          |
| onPermissionRequest | 权限请求回调（摄像头/定位等）  | function | InAppWebViewController controller, PermissionRequest permissionRequest | void | yes          |
| onSafeBrowsingHit   | 安全浏览拦截回调               | function | InAppWebViewController controller, WebUri? url, SafeBrowsingThreatType threatType | void | no           |
| onZoomScaleChanged  | 缩放比例变化回调               | function | InAppWebViewController controller, double scale | void | yes          |
| gestureRecognizers  | 手势识别器集合                | Set<Factory<OneSequenceGestureRecognizer>> | / | Set<Factory<OneSequenceGestureRecognizer>> | yes          |
| keepAlive           | 是否保持WebView存活             | InAppWebViewKeepAlive | / | InAppWebViewKeepAlive | no           |
| onJsAlert           | JavaScript警报对话框回调        | function | InAppWebViewController controller, JsAlertRequest jsAlertRequest | void | yes          |
| onJsConfirm         | JavaScript确认对话框回调        | function | InAppWebViewController controller, JsConfirmRequest jsConfirmRequest | void | yes          |
| onJsPrompt          | JavaScript提示对话框回调         | function | InAppWebViewController controller, JsPromptRequest jsPromptRequest | void | yes          |
| onLoadResource      | 资源加载完成回调              | function | InAppWebViewController controller, WebResourceResponse response | void | no           |
| onDownloadStartRequest | 文件下载开始回调             | function | InAppWebViewController controller, DownloadStartRequest request | void | no           |
| onCreateWindow      | 窗口创建请求回调              | function | InAppWebViewController controller, CreateWindowRequest request | void | no           |
| onCloseWindow       | 窗口关闭请求回调              | function | InAppWebViewController controller | void | no           |
| onFormResubmission  | 表单重新提交请求              | function | InAppWebViewController controller, FormResubmissionAction action | void | no           |
| onNavigationResponse| 导航响应处理                  | function | InAppWebViewController controller, NavigationResponseAction action | void | no           |
| onContentSizeChanged| 内容大小变化回调              | function | InAppWebViewController controller, Size contentSize | void | no           |
| onOverScrolled      | 超出滚动边界回调              | function | InAppWebViewController controller, int scrollX, bool clampedX, int scrollY, bool clampedY | void | yes          |
| onEnterFullscreen   | 进入全屏模式回调              | function | InAppWebViewController controller | void | no           |
| onExitFullscreen    | 退出全屏模式回调              | function | InAppWebViewController controller | void | no           |
| onPrintRequest      | 打印请求回调                  | function | InAppWebViewController controller | void | no           |
| onGeolocationPermissionsShowPrompt | 地理位置权限请求 | function | InAppWebViewController controller, String origin, bool allow | void | yes          |
| shouldInterceptRequest | 请求拦截                   | function | InAppWebViewController controller, WebResourceRequest request | Future<WebResourceResponse?> | yes          |
| shouldInterceptAjaxRequest | AJAX请求拦截            | function | InAppWebViewController controller, AjaxRequest request | Future<AjaxRequestPolicy?> | yes          |
| onRenderProcessGone | 渲染进程崩溃回调           | function | InAppWebViewController controller, RenderProcessGoneDetail detail | void | no           |
| onRenderProcessResponsive | 渲染进程恢复回调       | function | InAppWebViewController controller | void | no           |
| ohosParams          | OHOS特定配置参数            | OhosInAppWebViewWidgetCreationParams | / | OhosInAppWebViewWidgetCreationParams | yes          |
| useHybridComposition | 是否使用混合渲染模式        | bool | / | bool | yes          |

---

### InAppWebViewSettings API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| javaScriptEnabled | 是否启用JavaScript执行 | bool | bool | void | yes          |
| mediaPlaybackRequiresUserGesture | 媒体播放是否需要用户手势 | bool | bool | void | yes          |
| domStorageEnabled | 是否启用DOM存储（localStorage/sessionStorage） | bool | bool | void | yes          |
| userAgent | 自定义User-Agent字符串 | String | String | void | yes          |
| applicationNameForUserAgent | 附加到User-Agent的应用名称 | String | String | void | yes          |
| javaScriptCanOpenWindowsAutomatically | JavaScript是否可以自动打开新窗口 | bool | bool | void | no           |
| useShouldOverrideUrlLoading | 是否通过shouldOverrideUrlLoading拦截URL加载 | bool | bool | void | yes          |
| useOnLoadResource | 是否监控资源加载事件 | bool | bool | void | yes          |
| useOnDownloadStart | 是否处理下载开始事件 | bool | bool | void | yes          |
| clearCache | 加载前是否清除缓存 | bool | bool | void | no           |
| verticalScrollBarEnabled | 是否启用垂直滚动条 | bool | bool | void | yes          |
| horizontalScrollBarEnabled | 是否启用水平滚动条 | bool | bool | void | yes          |
| supportZoom | 是否支持缩放控制 | bool | bool | void | no           |
| allowFileAccess | 是否允许文件访问 | bool | bool | void | yes          |
| allowFileAccessFromFileURLs | 是否允许从file:// URL访问文件 | bool | bool | void | no           |
| allowUniversalAccessFromFileURLs | 是否允许从file:// URL进行通用访问 | bool | bool | void | no           |
| blockNetworkImage | 是否阻止网络图片加载 | bool | bool | void | no           |
| blockNetworkLoads | 是否阻止所有网络请求 | bool | bool | void | no           |
| contentBlockers | 应用于WebView的内容阻止规则列表 | List | List<String> | void | yes          |
| preferredContentMode | 首选内容渲染模式（例如desktop，mobile） | enum | ContentMode | void | no           |
| minimumFontSize | 显示网页内容的最小字体大小 | int | int | void | no           |
| minimumLogicalFontSize | 网页内容的最小逻辑字体大小 | int | int | void | no           |
| layoutAlgorithm | HTML渲染使用的布局算法 | enum | LayoutAlgorithm | void | no           |
| mixedContentMode | 控制混合HTTP/HTTPS内容的加载策略 | enum | MixedContentMode | void | yes          |
| geolocationEnabled | 是否启用地理位置权限 | bool | bool | void | yes          |
| databaseEnabled | 是否启用数据库存储 | bool | bool | void | no           |
| appCacheEnabled | 是否启用应用程序缓存 | bool | bool | void | no           |
| appCachePath | 存储应用程序缓存数据的路径 | String | String | void | no           |
| textZoom | 页面文本缩放比例（默认100） | int | int | void | yes          |
| enableNativeEmbedMode | 启用WebView的原生嵌入模式 | bool | bool | void | yes          |
| onlineImageAccess | 控制是否可以访问在线图像资源 | bool | bool | void | no           |
| blockNetwork | 是否阻止所有网络请求 | bool | bool | void | no           |
| darkMode | 设置WebView的暗色模式行为 | enum | WebDarkMode | void | yes          |
| fileAccess | 是否启用文件访问权限 | bool | bool | void | yes          |
| domStorageAccess | 是否启用DOM存储访问 | bool | bool | void | yes          |
| multiWindowAccess | 是否允许多窗口访问 | bool | bool | void | yes          |
| initialScale | WebView的初始缩放比例（0表示默认） | int | int | void | yes          |
| needInitialFocus | WebView是否需要初始焦点 | bool | bool | void | no           |
| forceDark | 强制WebView内容使用暗色主题 | enum | WebDarkMode | void | yes          |
| hardwareAcceleration | 是否启用硬件加速 | bool | bool | void | no           |
| supportMultipleWindows | 是否支持多个窗口 | bool | bool | void | yes          |
| setGeolocationEnabled | 启用/禁用地理位置支持 | function | bool | void | no           |
| setTextZoom | 设置页面文本缩放比例（百分比值） | function | int | void | yes          |
| setJavaScriptEnabled | 启用/禁用JavaScript执行 | function | bool | void | yes          |
| setDomStorageEnabled | 启用/禁用DOM存储 | function | bool | void | yes          |
| setSupportZoom | 启用/禁用缩放控制 | function | bool | void | no           |
| setMixedContentMode | 设置混合内容（HTTP/HTTPS）处理方式 | function | MixedContentMode | void | no           |
| setAllowFileAccess | 启用/禁用文件系统访问 | function | bool | void | yes          |
| setDatabaseEnabled | 启用/禁用数据库存储 | function | bool | void | no           |
| setMinimumFontSize | 设置网页内容的最小字体大小 | function | int | void | no           |
| setLayoutAlgorithm | 设置HTML渲染的布局算法 | function | LayoutAlgorithm | void | no           |

---

### HeadlessInAppWebView API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| run                 | 以无头模式运行WebView              | function | /     | Future<void> | no           |
| getSize             | 获取无头WebView的尺寸              | function | /     | Future<Size?> | no           |
| setSize             | 设置无头WebView的尺寸              | function | Size size | Future<void> | no           |
| dispose             | 处置无头WebView                   | function | /     | Future<void> | no           |
| initialSize         | 初始尺寸设置                      | Size     | Size  | Size   | no           |
| initialUrlRequest   | 要加载的初始URLRequest             | WebUri   | URLRequest? | URLRequest? | yes          |
| initialFile         | 要加载的初始本地文件路径          | String   | String? | String? | yes          |
| initialData         | 要加载的初始HTML数据              | InAppWebViewInitialData | InAppWebViewInitialData? | InAppWebViewInitialData? | yes          |
| onWebViewCreated    | WebView创建事件回调               | function | InAppWebViewController controller | void | yes          |
| onLoadStart         | URL加载开始事件回调               | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onLoadStop          | URL加载完成事件回调               | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onReceivedError     | 加载错误接收回调                  | function | InAppWebViewController controller, WebUri? url, WebResourceError error | void | yes          |
| onConsoleMessage    | 控制台消息回调                    | function | InAppWebViewController controller, ConsoleMessage consoleMessage | void | yes          |
| shouldOverrideUrlLoading | URL加载拦截回调                | function | InAppWebViewController controller, NavigationAction navigationAction | Future<NavigationActionPolicy?> | yes          |
| onJsAlert           | JavaScript警报对话框回调           | function | InAppWebViewController controller, JsAlertRequest jsAlertRequest | void | yes          |
| onJsConfirm         | JavaScript确认对话框回调           | function | InAppWebViewController controller, JsConfirmRequest jsConfirmRequest | void | yes          |
| onPermissionRequest | 权限请求回调（摄像头/定位等）    | function | InAppWebViewController controller, PermissionRequest permissionRequest | void | yes          |
| onDownloadStartRequest | 文件下载开始回调                | function | InAppWebViewController controller, DownloadStartRequest request | void | no           |
| onContentSizeChanged| 内容大小变化回调                 | function | InAppWebViewController controller, Size contentSize | void | no           |
| onRenderProcessGone | 渲染进程崩溃回调                | function | InAppWebViewController controller, RenderProcessGoneDetail detail | void | no           |

---

### InAppWebViewController API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| getUrl | 获取当前页面的URL | function | / | Future<WebUri?> | yes          |
| getTitle | 获取当前页面的标题 | function | / | Future<String?> | yes          |
| getProgress | 获取当前页面的加载进度（0-100） | function | / | Future<int?> | yes          |
| loadUrl | 在WebView中加载指定的URL | function | URLRequest urlRequest, WebUri? allowingReadAccessTo | Future<void> | yes          |
| reload | 重新加载WebView | function | / | Future<void> | yes          |
| goBack | 在WebView的历史记录中向后导航 | function | / | Future<void> | partially    |
| setSettings | 使用新设置配置WebView | function | InAppWebViewSettings settings | Future<void> | partially    |
| getSettings | 获取当前的WebView配置 | function | / | Future<InAppWebViewSettings?> | yes          |
| evaluateJavascript | 执行JavaScript表达式并返回结果 | function | String source, ContentWorld? contentWorld | Future<dynamic> | yes          |
| loadData | 将HTML数据加载到WebView中 | function | String data, String mimeType = "text/html", String encoding = "utf8", WebUri? baseUrl, WebUri? historyUrl, WebUri? allowingReadAccessTo | Future<void> | yes          |
| postUrl | 使用POST请求加载指定的URL | function | WebUri url, Uint8List postData | Future<void> | yes          |
| getOriginalUrl | 获取当前页面的原始请求URL | function | / | Future<WebUri?> | yes          |
| getScrollX | 获取水平滚动位置 | function | / | Future<int?> | yes          |
| getScrollY | 获取垂直滚动位置 | function | / | Future<int?> | yes          |
| scrollTo | 滚动到指定坐标 | function | int x, int y, bool animated = false | Future<void> | yes          |
| scrollBy | 按指定的增量值滚动 | function | int x, int y, bool animated = false | Future<void> | yes          |
| canGoBack | 检查是否可以向后导航 | function | / | Future<bool> | yes          |
| canGoForward | 检查是否可以向前导航 | function | / | Future<bool> | yes    |
| goForward | 在WebView历史记录中向前导航 | function | / | Future<void> | no           |
| pauseTimers | 暂停WebView中的所有定时器 | function | / | Future<void> | no           |
| resumeTimers | 恢复WebView中的所有定时器 | function | / | Future<void> | no           |
| clearCache | 清除缓存 | function | / | Future<void> | no           |
| zoomBy | 按指定比例缩放 | function | double zoomFactor, bool animated = false | Future<void> | no           |
| getZoomScale | 获取当前缩放比例 | function | / | Future<double?> | no           |
| getCertificate | 获取SSL证书信息 | function | / | Future<SslCertificate?> | no           |
| createPdf | 创建PDF文档 | function | PDFConfiguration? pdfConfiguration | Future<Uint8List?> | no           |
| printCurrentPage | 打印当前页面 | function | PrintJobSettings? settings | Future<PrintJobController?> | no           |
| addJavaScriptHandler | 添加JavaScript消息处理程序 | function | String handlerName, JavaScriptHandlerCallback callback | void | yes          |
| removeJavaScriptHandler | 移除JavaScript消息处理程序 | function | String handlerName | JavaScriptHandlerCallback? | yes          |
| hasJavaScriptHandler | 检查指定的处理程序是否存在 | function | String handlerName | bool | yes          |
| canScrollVertically | 检查是否可以垂直滚动 | function | / | Future<bool> | yes          |
| canScrollHorizontally | 检查是否可以水平滚动 | function | / | Future<bool> | yes          |
| getHitTestResult | 获取触摸的HTML元素的命中测试结果 | function | / | Future<InAppWebViewHitTestResult?> | no           |
| getSelectedText | 获取WebView中的选定文本 | function | / | Future<String?> | no           |
| getContentHeight | 获取页面内容高度 | function | / | Future<int?> | yes          |
| getContentWidth | 获取页面内容宽度 | function | / | Future<int?> | yes          |
| pause | 暂停WebView | function | / | Future<void> | yes          |
| resume | 恢复WebView | function | / | Future<void> | yes          |
| pageDown | 向下滚动页面 | function | bool bottom | Future<bool> | yes          |
| pageUp | 向上滚动页面 | function | bool top | Future<bool> | yes          |
| setAllMediaPlaybackSuspended | 设置媒体播放状态 | function | bool suspended | Future<void> | no           |
| isInFullscreen | 检查是否处于全屏模式 | function | / | Future<bool> | no           |
| getDefaultUserAgent | 获取默认的User-Agent | static function | / | Future<String> | yes          |
| clearAllCache | 清除所有缓存 | static function | bool includeDiskFiles = true | Future<void> | yes          |

---

### WebStorage API 

| Name         | Description                         | Type     | Input | Output | ohos Support |
|--------------|-------------------------------------|----------|-------|--------|--------------|
| localStorage | 表示 `window.localStorage`          | Object   | /     | LocalStorage | yes          |
| sessionStorage | 表示 `window.sessionStorage`      | Object   | /     | SessionStorage | yes          |
| length       | 返回存储项的数量                  | function | /     | Future<int?> | yes         |
| setItem      | 添加/更新一个存储项               | function | String key, dynamic value | Future<void> | yes          |
| getItem      | 获取一个存储项                    | function | String key | Future<dynamic> | yes          |
| removeItem   | 移除一个存储项                    | function | String key | Future<void> | yes          |
| clear        | 清除所有存储项                    | function | /     | Future<void> | yes          |
| key          | 获取指定索引处的键名              | function | int index | Future<String> | yes    |

---

### WebStorageManager API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| getOrigins          | 获取特定来源的存储使用情况         | function | / | Future<List<WebStorageOrigin>> | yes |
| deleteAllData       | 删除所有存储数据                   | function | / | Future<void> | yes |
| deleteOrigin        | 删除特定来源的存储数据             | function | String origin | Future<void> | yes |
| getQuotaForOrigin   | 获取特定来源的存储配额             | function | String origin | Future<int> | yes |
| getUsageForOrigin   | 获取特定来源的存储使用量           | function | String origin | Future<int> | yes |
| fetchDataRecords    | 获取网站数据记录                   | function | Set<WebsiteDataType> dataTypes | Future<List<WebsiteDataRecord>> | no |
| removeDataFor       | 删除指定的网站数据记录             | function | Set<WebsiteDataType> dataTypes, List<WebsiteDataRecord> dataRecords | Future<void> | no |
| removeDataModifiedSince | 删除在指定时间后修改的数据记录  | function | Set<WebsiteDataType> dataTypes, DateTime date | Future<void> | no |

---

### PrintJobController API 

| Name         | Description                     | Type     | Input                      | Output               | ohos Support |
|--------------|---------------------------------|----------|----------------------------|----------------------|--------------|
| cancel       | 取消正在进行的打印任务         | function | /                          | Future<void>         | yes           |
| restart      | 重启已取消的打印任务           | function | /                          | Future<void>         | yes           |
| dismiss      | 关闭打印界面                    | function | bool animated = true       | Future<void>         | yes           |
| getInfo      | 获取打印任务信息                | function | /                          | Future<PrintJobInfo?>| yes           |
| dispose      | 释放资源                        | function | /                          | void                 | yes           |
| id           | 打印任务的唯一标识符            | String   | /                          | String               | yes           |
| onComplete   | 打印完成回调                   | function | PrintJobCompletionHandler? | void                 | yes           |

---

### FindInteractionController API 

| Name                  | Description                   | Type     | Input                          | Output               | ohos Support |
|-----------------------|-------------------------------|----------|--------------------------------|----------------------|--------------|
| findAll               | 查找所有匹配项                | function | String? find                   | Future<void>         | yes          |
| findNext              | 查找下一个匹配项              | function | bool forward = true            | Future<void>         | yes          |
| clearMatches          | 清除所有匹配高亮             | function | /                              | Future<void>         | yes          |
| setSearchText         | 设置搜索文本值                | function | String? searchText             | Future<void>         | yes          |
| getSearchText         | 获取当前搜索文本              | function | /                              | Future<String?>       | yes          |
| isFindNavigatorVisible| 检查查找导航器是否可见       | function | /                              | Future<bool?>        | no           |
| presentFindNavigator  | 显示查找导航器                | function | /                              | Future<void>         | no           |
| dismissFindNavigator  | 隐藏查找导航器                | function | /                              | Future<void>         | no           |
| onFindResultReceived  | 查找结果回调                  | function | void Function(controller, int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)? | void | yes          |

---

### ProxyController API 

| Name         | Description                  | Type     | Input                      | Output               | ohos Support |
|--------------|------------------------------|----------|----------------------------|----------------------|--------------|
| setProxyOverride     | 设置网络代理配置             | function | ProxySettings settings     | Future<void>         | yes           |
| clearProxyOverride   | 清除网络代理配置             | function | /                          | Future<void>         | yes           |

---

### PullToRefreshController API 

| Name                  | Description                        | Type     | Input                     | Output               | ohos Support |
|-----------------------|------------------------------------|----------|---------------------------|----------------------|--------------|
| setEnabled            | 启用/禁用下拉刷新功能            | function | bool enabled              | Future<void>         | yes          |
| beginRefreshing       | 手动开始刷新动画                 | function | /                         | Future<void>         | yes          |
| endRefreshing         | 结束刷新动画                     | function | /                         | Future<void>         | yes          |
| isEnabled             | 检查刷新功能是否启用             | function | /                         | Future<bool>         | yes          |
| isRefreshing          | 检查是否正在刷新                 | function | /                         | Future<bool>         | yes          |
| setColor              | 设置刷新指示器颜色               | function | Color color               | Future<void>         | no           |
| setBackgroundColor    | 设置刷新背景颜色                 | function | Color color               | Future<void>         | no           |
| setDistanceToTriggerSync | 设置触发刷新的距离             | function | int distanceToTriggerSync | Future<void>         | no           |
| setSlingshotDistance  | 设置弹性回弹距离（iOS 特有）    | function | int slingshotDistance     | Future<void>         | no           |
| setIndicatorSize      | 设置指示器大小（Android 特有）   | function | PullToRefreshSize size    | Future<void>         | no           |
| setStyledTitle        | 设置刷新标题（iOS 特有）        | function | AttributedString attributedTitle | Future<void> | no           |

---

### WebViewAssetLoader API 

| Name                  | Description                        | Type     | Input                     | Output               | ohos Support |
|-----------------------|------------------------------------|----------|---------------------------|----------------------|--------------|
| handle                | 处理指定路径的资源请求           | function | String path               | Future<WebResourceResponse?> | yes |
| path                  | 资源路径匹配规则                 | String   | /                         | String               | yes          |
| type                  | 路径处理器类型                   | String   | /                         | String               | yes          |
| AssetsPathHandler     | 资源文件处理器                   | Object   | String path               | AssetsPathHandler    | yes          |
| ResourcesPathHandler  | 资源文件处理器                   | Object   | String path               | ResourcesPathHandler | yes    |
| InternalStoragePathHandler | 内部存储处理器                | Object   | String path, String directory | InternalStoragePathHandler | no |
| CustomPathHandler     | 自定义路径处理器                 | Object   | String path               | CustomPathHandler    | yes    |

---

### ContentBlocker API 

| Name                  | Description                        | Type     | Input                     | Output               | ohos Support |
|-----------------------|------------------------------------|----------|---------------------------|----------------------|--------------|
| ContentBlocker        | 内容阻止规则容器                 | Object   | ContentBlockerTrigger trigger, ContentBlockerAction action | ContentBlocker | yes |
| trigger               | 触发规则定义                     | ContentBlockerTrigger | / | ContentBlockerTrigger | yes |
| action                | 触发后的执行操作                 | ContentBlockerAction | / | ContentBlockerAction | yes |
| urlFilter             | URL 匹配正则表达式              | String   | String urlFilter          | String               | yes          |
| urlFilterIsCaseSensitive | URL 匹配是否区分大小写         | bool     | bool urlFilterIsCaseSensitive = false | bool | yes |
| resourceType          | 资源类型过滤列表                | List<ContentBlockerTriggerResourceType> | List<ContentBlockerTriggerResourceType> resourceType = const [] | List<ContentBlockerTriggerResourceType> | no |
| ifDomain              | 生效规则的域名列表              | List<String> | List<String> ifDomain = const [] | List<String> | yes |
| unlessDomain          | 排除的域名列表                  | List<String> | List<String> unlessDomain = const [] | List<String> | yes |
| loadType              | 加载类型过滤                     | List<ContentBlockerTriggerLoadType> | List<ContentBlockerTriggerLoadType> loadType = const [] | List<ContentBlockerTriggerLoadType> | no |
| ifFrameUrl            | iframe URL 匹配规则              | List<String> | List<String> ifFrameUrl = const [] | List<String> | no |
| unlessTopUrl          | 排除的主文档URL                | List<String> | List<String> unlessTopUrl = const [] | List<String> | yes |
| type                  | 操作类型 (block/display-none等) | enum     | ContentBlockerActionType type | ContentBlockerActionType | yes |
| selector              | CSS选择器 (仅 display-none)     | String   | String? selector          | String?              | no           |

---

### InAppWebViewKeepAlive API 

| Name                 | Description                        | Type     | Input | Output | ohos Support |
|----------------------|------------------------------------|----------|-------|--------|--------------|
| InAppWebViewKeepAlive | 创建 WebView 常驻实例            | constructor | / | InAppWebViewKeepAlive | yes |
| id                   | 获取/设置常驻实例的 ID           | String   | / | String | yes |
| javaScriptHandlersMap | JavaScript 处理器映射表          | Map<String, JavaScriptHandlerCallback> | Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap | / | yes |
| userScripts          | 用户脚本集合                     | Map<UserScriptInjectionTime, List<UserScript>> | Map<UserScriptInjectionTime, List<UserScript>> userScripts | / | yes |
| webMessageListenerObjNames | Web 消息监听器对象名称       | Set<String> | Set<String> webMessageListenerObjNames | / | yes |
| injectedScriptsFromURL | 通过 URL 注入的脚本属性         | Map<String, ScriptHtmlTagAttributes> | Map<String, ScriptHtmlTagAttributes> injectedScriptsFromURL | / | yes |
| webMessageChannels   | Web 消息通道集合                 | Set<PlatformWebMessageChannel> | Set<PlatformWebMessageChannel> webMessageChannels = Set() | / | yes |
| webMessageListeners  | Web 消息监听器集合               | Set<PlatformWebMessageListener> | Set<PlatformWebMessageListener> webMessageListeners = Set() | / | yes |

---

### InAppBrowser API 

| Name                  | Description                       | Type     | Input | Output | ohos Support |
|-----------------------|-----------------------------------|----------|-------|--------|--------------|
| openUrlRequest        | 使用指定的 URLRequest 打开网页   | function | URLRequest urlRequest, InAppBrowserClassOptions? options, InAppBrowserClassSettings? settings | Future<void> | no          |
| openFile              | 打开本地文件                    | function | String assetFilePath, InAppBrowserClassOptions? options, InAppBrowserClassSettings? settings | Future<void> | no           |
| openData              | 打开 HTML 数据                  | function | String data, String mimeType = "text/html", String encoding = "utf8", WebUri? baseUrl, WebUri? historyUrl, InAppBrowserClassSettings? settings | Future<void> | no          |
| show                  | 显示浏览器窗口                  | function | / | Future<void> | yes          |
| hide                  | 隐藏浏览器窗口                  | function | / | Future<void> | yes          |
| close                 | 关闭浏览器窗口                  | function | / | Future<void> | yes          |
| setSettings           | 设置浏览器配置                  | function | InAppBrowserClassSettings settings | Future<void> | partially    |
| getSettings           | 获取当前配置                    | function | / | Future<InAppBrowserClassSettings?> | yes          |
| addMenuItem           | 添加菜单项                      | function | InAppBrowserMenuItem menuItem | void | no           |
| removeMenuItem        | 移除菜单项                      | function | InAppBrowserMenuItem menuItem | bool | no           |
| isHidden              | 检查浏览器是否隐藏              | function | / | Future<bool> | yes          |
| isOpened              | 检查浏览器是否已打开            | function | / | bool | yes          |
| onBrowserCreated      | 浏览器创建回调                  | function | / | void | yes          |
| onLoadStart           | 页面加载开始回调                | function | WebUri? url | void | yes          |
| onLoadStop            | 页面加载完成回调                | function | WebUri? url | void | yes          |
| onLoadError           | 加载错误回调                    | function | WebUri? url, int code, String message | void | yes          |
| onProgressChanged     | 加载进度变化回调                | function | int progress | void | yes          |
| onTitleChanged        | 页面标题变化回调                | function | String? title | void | yes          |
| onExit                | 浏览器退出回调                  | function | / | void | no           |
| onConsoleMessage      | 控制台消息回调                  | function | ConsoleMessage consoleMessage | void | yes          |
| onReceivedIcon        | 网站图标接收回调               | function | Uint8List icon | void | no           |
| onPermissionRequest   | 权限请求回调                   | function | PermissionRequest permissionRequest | Future<PermissionResponse?> | yes          |
| onJsAlert             | JavaScript 弹窗回调              | function | JsAlertRequest jsAlertRequest | Future<JsAlertResponse?> | yes          |
| onJsConfirm           | JavaScript 确认框回调           | function | JsConfirmRequest jsConfirmRequest | Future<JsConfirmResponse?> | yes          |

---

### ChromeSafariBrowser API 

| Name                  | Description                       | Type     | Input | Output | ohos Support |
|-----------------------|-----------------------------------|----------|-------|--------|--------------|
| open                  | 使用指定 URL 打开浏览器          | function | WebUri? url, Map<String, String>? headers, List<WebUri>? otherLikelyURLs, ChromeSafariBrowserSettings? settings | Future<void> | no |
| launchUrl             | 启动指定的 URL                 | function | WebUri url, Map<String, String>? headers, List<WebUri>? otherLikelyURLs | Future<void> | no |
| close                 | 关闭浏览器                      | function | / | Future<void> | no |
| isAvailable           | 检查浏览器可用性               | static function | / | Future<bool> | no |
| clearWebsiteData      | 清除网站数据                   | static function | / | Future<void> | no |
| prewarmConnections    | 预热连接                      | static function | List<WebUri> URLs | Future<PrewarmingToken?> | no |
| onClosed              | 浏览器关闭回调                 | function | / | void | no |
| onOpened              | 浏览器打开回调                 | function | / | void | no |
| onCompletedInitialLoad | 初始加载完成回调               | function | bool? didLoadSuccessfully | void | no |
| onNavigationEvent     | 导航事件回调                   | function | CustomTabsNavigationEventType? navigationEvent | void | no |
| onPostMessage         | postMessage 回调                | function | String message | void | no |
| setActionButton       | 设置操作按钮                    | function | ChromeSafariBrowserActionButton actionButton | void | no |
| setSecondaryToolbar   | 设置二级工具栏                  | function | ChromeSafariBrowserSecondaryToolbar secondaryToolbar | void | no |
| addMenuItem           | 添加菜单项                      | function | ChromeSafariBrowserMenuItem menuItem | void | no |
| requestPostMessageChannel | 请求消息通道                  | function | WebUri sourceOrigin, WebUri? targetOrigin | Future<bool> | no |
| validateRelationship  | 验证关系                       | function | CustomTabsRelationType relation, WebUri origin | Future<bool> | no |

---

### InAppLocalhostServer API 

| Name         | Description                       | Type     | Input | Output | ohos Support |
|--------------|-----------------------------------|----------|-------|--------|--------------|
| InAppLocalhostServer | 创建本地服务器实例             | constructor | int port = 8080, String directoryIndex = "index.html", String documentRoot = "./", bool shared = false | InAppLocalhostServer | no |
| start        | 启动本地服务器                  | function | / | Future<void> | no |
| close        | 停止本地服务器                  | function | / | Future<void> | no |
| isRunning    | 检查服务器是否正在运行         | function | / | bool | no |
| port         | 获取服务器端口号                | int      | / | int | no |
| directoryIndex | 获取目录索引文件名             | String   | / | String | no |
| documentRoot | 获取文档根目录                  | String   | / | String | no |
| shared       | 检查实例是否为共享实例        | bool     | / | bool | no |

---

### CookieManager API 

| Name                  | Description                        | Type     | Input | Output | ohos Support |
|-----------------------|------------------------------------|----------|-------|--------|--------------|
| setCookie             | 为指定 URL 设置 Cookie           | function | WebUri url, String name, String value, String path = "/", String? domain, int? expiresDate, int? maxAge, bool? isSecure, bool? isHttpOnly, HTTPCookieSameSitePolicy? sameSite, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| getCookies            | 获取指定 URL 的所有 Cookie       | function | WebUri url, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<List<Cookie>> | yes |
| getCookie             | 按名称获取 Cookie                | function | WebUri url, String name, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<Cookie?> | yes |
| deleteCookie          | 删除指定的 Cookie                | function | WebUri url, String name, String path = "/", String? domain, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| deleteCookies         | 删除指定 URL 的所有 Cookie       | function | WebUri url, String path = "/", String? domain, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| deleteAllCookies      | 删除所有 Cookie                  | static function | / | Future<bool> | yes |
| getAllCookies         | 获取所有 Cookie                  | static function | / | Future<List<Cookie>> | yes |
| removeSessionCookies  | 删除会话 Cookie                  | static function | / | Future<bool> | yes |
| IOSCookieManager      | iOS 特定的 Cookie 管理类（已弃用） | Object | / | IOSCookieManager | no |

---

### HttpAuthCredentialDatabase API 

| Name                    | Description                          | Type     | Input | Output | ohos Support |
|-------------------------|--------------------------------------|----------|-------|--------|--------------|
| getAllAuthCredentials   | 获取所有 HTTP 认证凭据             | function | / | Future<List<URLProtectionSpaceHttpAuthCredentials>> | yes |
| getHttpAuthCredentials  | 获取指定保护空间的 HTTP 凭据       | function | URLProtectionSpace protectionSpace | Future<List<URLCredential>> | yes |
| setHttpAuthCredential   | 设置 HTTP 认证凭据                 | function | URLProtectionSpace protectionSpace, URLCredential credential | Future<void> | yes |
| removeHttpAuthCredential| 移除指定的 HTTP 认证凭据          | function | URLProtectionSpace protectionSpace, URLCredential credential | Future<void> | yes |
| removeHttpAuthCredentials | 移除指定保护空间的所有凭据        | function | URLProtectionSpace protectionSpace | Future<void> | yes |
| clearAllAuthCredentials | 清除所有认证凭据                  | function | / | Future<void> | yes |
| dispose                 | 释放资源                           | function | / | Future<void> | yes |

---

### WebAuthenticationSession API 

| Name                  | Description                          | Type     | Input | Output | ohos Support |
|-----------------------|--------------------------------------|----------|-------|--------|--------------|
| create                | 创建 Web 认证会话                 | function | WebUri url, String? callbackURLScheme, WebAuthenticationSessionCompletionHandler onComplete, WebAuthenticationSessionSettings? initialSettings | Future<WebAuthenticationSession> | no |
| canStart              | 检查是否可以启动会话              | function | / | Future<bool> | no |
| start                 | 启动 Web 认证会话                | function | / | Future<bool> | no |
| cancel                | 取消正在进行的认证会话             | function | / | Future<void> | no |
| dispose               | 释放会话资源                       | function | / | Future<void> | no |
| isAvailable           | 检查设备是否支持 Web 认证         | static function | / | Future<bool> | no |
| id                    | 获取会话唯一标识符                 | String   | / | String | no |
| url                   | 获取认证会话的 URL                 | WebUri   | / | WebUri | no |
| callbackURLScheme     | 获取回调 URL 方案                  | String   | / | String? | no |
| initialSettings         | 获取初始会话配置                   | WebAuthenticationSessionSettings | / | WebAuthenticationSessionSettings? | no |
| onComplete              | 认证完成处理程序                   | WebAuthenticationSessionCompletionHandler | / | WebAuthenticationSessionCompletionHandler | no |

---

### WebUri API 

| Name                | Description (中文描述)                         | Type     | Input | Output | ohos Support |
|---------------------|----------------------------------------------|----------|-------|--------|--------------|
| authority           | 获取 URI 的权限部分（主机:端口格式）        | String   | / | String | yes          |
| data                | 获取 URI 的数据部分                         | UriData? | / | UriData? | yes          |
| fragment            | 获取 URI 的片段标识符                       | String   | / | String | yes          |
| hasAbsolutePath     | 检查路径是否为绝对路径                     | bool     | / | bool | yes          |
| hasAuthority        | 检查是否存在权限信息                       | bool     | / | bool | yes          |
| hasEmptyPath        | 检查路径是否为空                           | bool     | / | bool | yes          |
| hasFragment         | 检查是否存在片段                           | bool     | / | bool | yes          |
| hasPort             | 检查是否存在端口号                         | bool     | / | bool | yes          |
| hasQuery            | 检查是否存在查询参数                       | bool     | / | bool | yes          |
| hasScheme           | 检查是否存在协议方案                       | bool     | / | bool | yes          |
| host                | 获取主机名（区分大小写）                    | String   | / | String | yes          |
| isAbsolute          | 检查 URI 是否为绝对路径                   | bool     | / | bool | yes          |
| isScheme            | 检查协议方案是否匹配                       | function | String scheme | bool | yes          |
| normalizePath       | 标准化路径（去除冗余）                     | function | / | Uri | yes          |
| origin              | 获取源（scheme+authority）                 | String   | / | String | yes          |
| path                | 获取路径（区分大小写）                      | String   | / | String | yes          |
| pathSegments        | 获取路径段的列表                            | List<String> | / | List<String> | yes          |
| port                | 获取端口号                                  | int      | / | int | yes          |
| query               | 获取原始查询字符串                          | String   | / | String | yes          |
| queryParameters     | 获取查询参数映射（仅第一个值）              | Map<String, String> | / | Map<String, String> | yes          |
| queryParametersAll  | 获取完整的查询参数映射                      | Map<String, List<String>> | / | Map<String, List<String>> | yes          |
| removeFragment      | 创建一个移除了片段的新 URI                  | function | / | Uri | yes          |
| replace             | 替换 URI 的组成部分                        | function | String? scheme, String? userInfo, String? host, int? port, String? path, Iterable<String>? pathSegments, String? query, Map<String, dynamic>? queryParameters, String? fragment | Uri | yes          |
| resolve             | 解析相对 URI                               | function | String reference | Uri | yes          |
| resolveUri          | 解析相对的 URI 对象                        | function | Uri reference | Uri | yes          |
| scheme              | 获取协议方案（例如 http）                   | String   | / | String | yes          |
| toFilePath          | 转换为文件路径                             | function | bool? windows | String | yes          |
| userInfo            | 获取用户信息组件                             | String   | / | String | yes          |
| rawValue            | 获取原始未解析的 URI 字符串                 | String   | / | String | yes          |
| uriValue            | 获取解析后的标准 URI 对象                   | Uri      | / | Uri | yes          |
| isValidUri          | 表示 URI 解析是否成功                      | bool     | / | bool | yes          |
| forceToStringRawValue | 控制 `toString()` 是否使用原始值            | bool     | / | bool | yes          |
| normalizePath()     | 返回标准化后的新路径 URI                    | function | / | Uri | yes          |
| toString()          | 字符串表示（可配置为使用原始值）           | function | / | String | yes          |

---

## 4. 遗留问题

- [ ] ohos端本地资源跨域问题: [issues#94](https://gitcode.com/openharmony-sig/flutter_inappwebview/issues/94)
- [ ] ohos端goBack无法返回到上一层页面问题: [issues#141](https://gitcode.com/openharmony-sig/flutter_inappwebview/issues/141)

## 5. 其他

## 6. 开源协议

本项目基于 [The Apache-2.0 license](/LICENSE) ，请自由地享受和参与开源。
