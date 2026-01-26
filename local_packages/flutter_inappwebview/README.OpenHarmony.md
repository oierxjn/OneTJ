> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>flutter_inappwebview</code> </h1>
</p>

This project is based on [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

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

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](/flutter_inappwebview/example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;


## 3. API

> [!TIP] If the value of ohos Support is yes, it means that the ohos platform supports this property; no means the opposite; partially means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### InAppWebView API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| key                 | Flutter framework base identifier   | Key      | /     | Key    | yes          |
| controllerFromPlatform | Callback to get WebView controller from platform | function | PlatformInAppWebViewController controller | void | yes          |
| windowId            | Window ID identifier               | int      | /     | int    | no           |
| initialUrlRequest   | Initial URLRequest to load         | WebUri   | /     | WebUri | yes          |
| initialFile         | Initial local file path to load    | String   | /     | String | yes          |
| initialData         | Initial HTML data to load          | InAppWebViewInitialData | / | InAppWebViewInitialData | yes          |
| onWebViewCreated    | WebView creation event callback    | function | InAppWebViewController controller | void | yes          |
| onLoadStart         | URL loading start event callback   | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onLoadStop          | URL loading completion callback    | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onReceivedError     | Loading error reception callback   | function | InAppWebViewController controller, WebUri? url, WebResourceError error | void | yes          |
| onReceivedHttpError | HTTP error reception callback      | function | InAppWebViewController controller, WebUri? url, WebResourceResponse response | void | yes          |
| shouldOverrideUrlLoading | URL loading interception callback | function | InAppWebViewController controller, NavigationAction navigationAction | Future<NavigationActionPolicy?> | yes          |
| onConsoleMessage    | Console message callback           | function | InAppWebViewController controller, ConsoleMessage consoleMessage | void | yes          |
| onProgressChanged   | Loading progress change callback   | function | InAppWebViewController controller, int progress | void | yes          |
| onPermissionRequest | Permission request callback (camera/location, etc.) | function | InAppWebViewController controller, PermissionRequest permissionRequest | void | yes          |
| onSafeBrowsingHit   | Safe browsing interception callback  | function | InAppWebViewController controller, WebUri? url, SafeBrowsingThreatType threatType | void | no           |
| onZoomScaleChanged  | Zoom scale change callback         | function | InAppWebViewController controller, double scale | void | yes          |
| gestureRecognizers  | Gesture recognizer collection      | Set<Factory<OneSequenceGestureRecognizer>> | / | Set<Factory<OneSequenceGestureRecognizer>> | yes          |
| keepAlive           | Whether to keep WebView alive      | InAppWebViewKeepAlive | / | InAppWebViewKeepAlive | no           |
| onJsAlert           | JavaScript alert dialog callback   | function | InAppWebViewController controller, JsAlertRequest jsAlertRequest | void | yes          |
| onJsConfirm         | JavaScript confirmation dialog callback | function | InAppWebViewController controller, JsConfirmRequest jsConfirmRequest | void | yes          |
| onJsPrompt          | JavaScript prompt dialog callback  | function | InAppWebViewController controller, JsPromptRequest jsPromptRequest | void | yes          |
| onLoadResource      | Resource loading completion callback | function | InAppWebViewController controller, WebResourceResponse response | void | no           |
| onDownloadStartRequest | File download start callback    | function | InAppWebViewController controller, DownloadStartRequest request | void | no           |
| onCreateWindow      | Window creation request callback   | function | InAppWebViewController controller, CreateWindowRequest request | void | no           |
| onCloseWindow       | Window closure request callback    | function | InAppWebViewController controller | void | no           |
| onFormResubmission  | Form resubmission request          | function | InAppWebViewController controller, FormResubmissionAction action | void | no           |
| onNavigationResponse| Navigation response handling       | function | InAppWebViewController controller, NavigationResponseAction action | void | no           |
| onContentSizeChanged| Content size change callback       | function | InAppWebViewController controller, Size contentSize | void | no           |
| onOverScrolled      | Overscroll boundary callback       | function | InAppWebViewController controller, int scrollX, bool clampedX, int scrollY, bool clampedY | void | yes          |
| onEnterFullscreen   | Fullscreen entry callback          | function | InAppWebViewController controller | void | no           |
| onExitFullscreen    | Fullscreen exit callback           | function | InAppWebViewController controller | void | no           |
| onPrintRequest      | Print request callback             | function | InAppWebViewController controller | void | no           |
| onGeolocationPermissionsShowPrompt | Geolocation permission request | function | InAppWebViewController controller, String origin, bool allow | void | yes    |
| shouldInterceptRequest | Request interception            | function | InAppWebViewController controller, WebResourceRequest request | Future<WebResourceResponse?> | yes          |
| shouldInterceptAjaxRequest | AJAX request interception    | function | InAppWebViewController controller, AjaxRequest request | Future<AjaxRequestPolicy?> | yes          |
| onRenderProcessGone | Render process crash callback     | function | InAppWebViewController controller, RenderProcessGoneDetail detail | void | no           |
| onRenderProcessResponsive | Render process recovery callback | function | InAppWebViewController controller | void | no           |
| ohosParams          | OHOS-specific configuration parameters | OhosInAppWebViewWidgetCreationParams | / | OhosInAppWebViewWidgetCreationParams | yes          |
| useHybridComposition | Whether to use hybrid rendering mode | bool | / | bool | yes          |

---

### InAppWebViewSettings API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| javaScriptEnabled | Whether to enable JavaScript execution | bool | bool | void | yes          |
| mediaPlaybackRequiresUserGesture | Whether media playback requires user gesture | bool | bool | void | yes          |
| domStorageEnabled | Whether DOM storage (localStorage/sessionStorage) is enabled | bool | bool | void | yes          |
| userAgent | Custom User-Agent string for WebView | String | String | void | yes          |
| applicationNameForUserAgent | Application name appended to User-Agent | String | String | void | yes          |
| javaScriptCanOpenWindowsAutomatically | Whether JavaScript can open new windows automatically | bool | bool | void | no            |
| useShouldOverrideUrlLoading | Whether to intercept URL loading via shouldOverrideUrlLoading | bool | bool | void | yes          |
| useOnLoadResource | Whether to monitor resource loading events | bool | bool | void | yes          |
| useOnDownloadStart | Whether to handle download start events | bool | bool | void | yes          |
| clearCache | Whether to clear cache before loading | bool | bool | void | no           |
| verticalScrollBarEnabled | Whether vertical scrollbar is enabled | bool | bool | void | yes          |
| horizontalScrollBarEnabled | Whether horizontal scrollbar is enabled | bool | bool | void | yes          |
| supportZoom | Whether zoom control is supported | bool | bool | void | no          |
| allowFileAccess | Whether file access is allowed | bool | bool | void | yes          |
| allowFileAccessFromFileURLs | Whether to allow file access from file:// URLs | bool | bool | void | no          |
| allowUniversalAccessFromFileURLs | Whether universal access from file:// URLs is allowed | bool | bool | void | no           |
| blockNetworkImage | Whether network image loading is blocked | bool | bool | void | no           |
| blockNetworkLoads | Whether all network requests are blocked | bool | bool | void | no           |
| contentBlockers | List of content blocking rules applied to WebView | List | List<String> | void | yes          |
| preferredContentMode | Preferred content rendering mode (e.g., desktop, mobile) | enum | ContentMode | void | no          |
| minimumFontSize | Minimum font size for displaying web content | int | int | void | no           |
| minimumLogicalFontSize | Minimum logical font size for web content | int | int | void | no           |
| layoutAlgorithm | Layout algorithm used for HTML rendering | enum | LayoutAlgorithm | void | no           |
| mixedContentMode | Controls loading strategy for mixed HTTP/HTTPS content | enum | MixedContentMode | void | yes          |
| geolocationEnabled | Whether geolocation permission is enabled | bool | bool | void | yes          |
| databaseEnabled | Whether database storage is enabled | bool | bool | void | no           |
| appCacheEnabled | Whether application cache is enabled | bool | bool | void | no           |
| appCachePath | Path to store application cache data | String | String | void | no           |
| textZoom | Page text zoom scale (default 100) | int | int | void | yes          |
| enableNativeEmbedMode | Enables WebView's native embedding mode | bool | bool | void | yes          |
| onlineImageAccess | Controls whether online image resources can be accessed | bool | bool | void | no           |
| blockNetwork | Whether to block all network requests | bool | bool | void | no           |
| darkMode | Sets WebView's dark mode behavior | enum | WebDarkMode | void | yes          |
| fileAccess | Whether file access permissions are enabled | bool | bool | void | yes          |
| domStorageAccess | Whether DOM storage access is enabled | bool | bool | void | yes          |
| multiWindowAccess | Whether multiple window access is allowed | bool | bool | void | yes          |
| initialScale | Initial zoom scale for WebView (0 means default) | int | int | void | yes          |
| needInitialFocus | Whether WebView needs initial focus | bool | bool | void | no           |
| forceDark | Forces dark theme for WebView content | enum | WebDarkMode | void | yes          |
| hardwareAcceleration | Whether hardware acceleration is enabled | bool | bool | void | no           |
| supportMultipleWindows | Whether multiple windows are supported | bool | bool | void | yes          |
| setGeolocationEnabled | Enables/disables geolocation support | function | bool | void | no          |
| setTextZoom | Sets page text zoom scale (percentage value) | function | int | void | yes          |
| setJavaScriptEnabled | Enables/disables JavaScript execution | function | bool | void | yes          |
| setDomStorageEnabled | Enables/disables DOM storage | function | bool | void | yes          |
| setSupportZoom | Enables/disables zoom control | function | bool | void | no          |
| setMixedContentMode | Sets handling method for mixed content (HTTP/HTTPS) | function | MixedContentMode | void | no          |
| setAllowFileAccess | Enables/disables file system access | function | bool | void | yes          |
| setDatabaseEnabled | Enables/disables database storage | function | bool | void | no           |
| setMinimumFontSize | Sets minimum font size for web content | function | int | void | no           |
| setLayoutAlgorithm | Sets layout algorithm for HTML rendering | function | LayoutAlgorithm | void | no           |

---

### HeadlessInAppWebView API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| run                 | Runs WebView in headless mode       | function | /     | Future<void> | no           |
| getSize             | Gets size of headless WebView       | function | /     | Future<Size?> | no           |
| setSize             | Sets size for headless WebView      | function | Size size | Future<void> | no           |
| dispose             | Disposes headless WebView           | function | /     | Future<void> | no           |
| initialSize         | Initial size setting                | Size     | Size  | Size   | no           |
| initialUrlRequest   | Initial URLRequest to load          | WebUri   | URLRequest? | URLRequest? | yes          |
| initialFile         | Initial local file path to load     | String   | String? | String? | yes          |
| initialData         | Initial HTML data to load           | InAppWebViewInitialData | InAppWebViewInitialData? | InAppWebViewInitialData? | yes          |
| onWebViewCreated    | WebView creation event callback     | function | InAppWebViewController controller | void | yes          |
| onLoadStart         | URL loading start event callback    | function | InAppWebViewController controller, WebUri? url | void | yes    |
| onLoadStop          | URL loading completion callback     | function | InAppWebViewController controller, WebUri? url | void | yes          |
| onReceivedError     | Loading error reception callback    | function | InAppWebViewController controller, WebUri? url, WebResourceError error | void | yes    |
| onConsoleMessage    | Console message callback            | function | InAppWebViewController controller, ConsoleMessage consoleMessage | void | yes          |
| shouldOverrideUrlLoading | URL loading interception callback | function | InAppWebViewController controller, NavigationAction navigationAction | Future<NavigationActionPolicy?> | yes          |
| onJsAlert           | JavaScript alert dialog callback    | function | InAppWebViewController controller, JsAlertRequest jsAlertRequest | void | yes    |
| onJsConfirm         | JavaScript confirmation dialog callback | function | InAppWebViewController controller, JsConfirmRequest jsConfirmRequest | void | yes    |
| onPermissionRequest | Permission request callback (camera/location, etc.) | function | InAppWebViewController controller, PermissionRequest permissionRequest | void | yes          |
| onDownloadStartRequest | File download start callback     | function | InAppWebViewController controller, DownloadStartRequest request | void | no           |
| onContentSizeChanged| Content size change callback        | function | InAppWebViewController controller, Size contentSize | void | no    |
| onRenderProcessGone | Render process crash callback      | function | InAppWebViewController controller, RenderProcessGoneDetail detail | void | no           |

---

### InAppWebViewController API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| getUrl | Gets the URL of the current page | function | / | Future<WebUri?> | yes |
| getTitle | Gets the title of the current page | function | / | Future<String?> | yes |
| getProgress | Gets the loading progress of the current page (0-100) | function | / | Future<int?> | yes |
| loadUrl | Loads the specified URL in the WebView | function | URLRequest urlRequest, WebUri? allowingReadAccessTo | Future<void> | yes |
| reload | Reloads the WebView | function | / | Future<void> | yes |
| goBack | Navigates back in the WebView's history | function | / | Future<void> | partially |
| setSettings | Sets WebView configuration with new settings | function | InAppWebViewSettings settings | Future<void> | partially |
| getSettings | Gets current WebView configuration | function | / | Future<InAppWebViewSettings?> | yes |
| evaluateJavascript | Executes a JavaScript expression and returns the result | function | String source, ContentWorld? contentWorld | Future<dynamic> | yes |
| loadData | Loads HTML data into the WebView | function | String data, String mimeType = "text/html", String encoding = "utf8", WebUri? baseUrl, WebUri? historyUrl, WebUri? allowingReadAccessTo | Future<void> | yes |
| postUrl | Loads a specified URL using POST request | function | WebUri url, Uint8List postData | Future<void> | yes |
| getOriginalUrl | Gets the original request URL of the current page | function | / | Future<WebUri?> | yes |
| getScrollX | Gets horizontal scroll position | function | / | Future<int?> | yes |
| getScrollY | Gets vertical scroll position | function | / | Future<int?> | yes |
| scrollTo | Scrolls to specified coordinates | function | int x, int y, bool animated = false | Future<void> | yes |
| scrollBy | Scrolls by specified delta values | function | int x, int y, bool animated = false | Future<void> | yes |
| canGoBack | Checks if navigation back in history is possible | function | / | Future<bool> | yes |
| canGoForward | Checks if navigation forward in history is possible | function | / | Future<bool> | yes |
| goForward | Navigates forward in WebView history | function | / | Future<void> | no |
| pauseTimers | Pauses all timers in WebView | function | / | Future<void> | no |
| resumeTimers | Resumes all timers in WebView | function | / | Future<void> | no |
| clearCache | Clears cache | function | / | Future<void> | no |
| zoomBy | Zooms by specified scale | function | double zoomFactor, bool animated = false | Future<void> | no |
| getZoomScale | Gets current zoom scale | function | / | Future<double?> | no |
| getCertificate | Gets SSL certificate information | function | / | Future<SslCertificate?> | no |
| createPdf | Creates PDF document | function | PDFConfiguration? pdfConfiguration | Future<Uint8List?> | no |
| printCurrentPage | Prints current page | function | PrintJobSettings? settings | Future<PrintJobController?> | no |
| addJavaScriptHandler | Adds JavaScript message handler | function | String handlerName, JavaScriptHandlerCallback callback | void | yes |
| removeJavaScriptHandler | Removes JavaScript message handler | function | String handlerName | JavaScriptHandlerCallback? | yes |
| hasJavaScriptHandler | Checks existence of specified handler | function | String handlerName | bool | yes |
| canScrollVertically | Checks if vertical scrolling is possible | function | / | Future<bool> | yes |
| canScrollHorizontally | Checks if horizontal scrolling is possible | function | / | Future<bool> | yes |
| getHitTestResult | Gets hit test result for touched HTML element | function | / | Future<InAppWebViewHitTestResult?> | no |
| getSelectedText | Gets selected text in WebView | function | / | Future<String?> | no |
| getContentHeight | Gets page content height | function | / | Future<int?> | yes |
| getContentWidth | Gets page content width | function | / | Future<int?> | yes |
| pause | Pauses the WebView | function | / | Future<void> | yes |
| resume | Resumes the WebView | function | / | Future<void> | yes |
| pageDown | Scrolls page down | function | bool bottom | Future<bool> | yes |
| pageUp | Scrolls page up | function | bool top | Future<bool> | yes |
| setAllMediaPlaybackSuspended | Sets media playback state | function | bool suspended | Future<void> | no |
| isInFullscreen | Checks if in fullscreen mode | function | / | Future<bool> | no |
| getDefaultUserAgent | Gets default User-Agent | static function | / | Future<String> | yes |
| clearAllCache | Clears all caches | static function | bool includeDiskFiles = true | Future<void> | yes |

---

### WebStorage API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| localStorage        | Represents `window.localStorage`      | Object   | /     | LocalStorage | yes      |
| sessionStorage      | Represents `window.sessionStorage`    | Object   | /     | SessionStorage | yes      |
| length              | Returns number of stored items        | function | /     | Future<int?> | yes |
| setItem             | Adds/updates a storage item         | function | String key, dynamic value | Future<void> | yes      |
| getItem             | Retrieves a storage item            | function | String key | Future<dynamic> | yes      |
| removeItem          | Removes a storage item              | function | String key | Future<void> | yes      |
| clear               | Clears all keys from storage        | function | /     | Future<void> | yes      |
| key                 | Gets key name at specified index    | function | int index | Future<String> | yes |

---

### WebStorageManager API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| getOrigins          | Gets storage usage for specific origins | function | / | Future<List<WebStorageOrigin>> | yes |
| deleteAllData       | Removes all storage data             | function | / | Future<void> | yes |
| deleteOrigin        | Removes storage data for specific origin | function | String origin | Future<void> | yes |
| getQuotaForOrigin   | Gets storage quota for specific origin | function | String origin | Future<int> | yes |
| getUsageForOrigin   | Gets storage usage for specific origin | function | String origin | Future<int> | yes |
| fetchDataRecords    | Gets website data records            | function | Set<WebsiteDataType> dataTypes | Future<List<WebsiteDataRecord>> | no |
| removeDataFor       | Removes specified website data records | function | Set<WebsiteDataType> dataTypes, List<WebsiteDataRecord> dataRecords | Future<void> | no |
| removeDataModifiedSince | Removes website data modified after specified time | function | Set<WebsiteDataType> dataTypes, DateTime date | Future<void> | no |

---

### PrintJobController API 

| Name         | Description                     | Type     | Input                      | Output               | ohos Support |
|--------------|---------------------------------|----------|----------------------------|----------------------|--------------|
| cancel       | Cancels an ongoing print job    | function | /                          | Future<void>         | yes           |
| restart      | Restarts a cancelled print job  | function | /                          | Future<void>         | yes           |
| dismiss      | Closes print interface          | function | bool animated = true       | Future<void>         | yes           |
| getInfo      | Gets print job information      | function | /                          | Future<PrintJobInfo?>| yes           |
| dispose      | Releases resources              | function | /                          | void                 | yes           |
| id           | Unique identifier for print job | String   | /                          | String               | yes           |
| onComplete   | Print completion callback       | function | PrintJobCompletionHandler? | void                 | yes           |

---

### FindInteractionController API 

| Name                  | Description                   | Type     | Input                          | Output               | ohos Support |
|-----------------------|-------------------------------|----------|--------------------------------|----------------------|--------------|
| findAll               | Finds all matching items        | function | String? find                   | Future<void>         | yes          |
| findNext              | Finds next matching item        | function | bool forward = true            | Future<void>         | yes          |
| clearMatches          | Clears all match highlights   | function | /                              | Future<void>         | yes          |
| setSearchText         | Sets search text value        | function | String? searchText             | Future<void>         | yes          |
| getSearchText         | Gets current search text      | function | /                              | Future<String?>       | yes          |
| isFindNavigatorVisible| Checks if find navigator visible | function | /                              | Future<bool?>        | no    |
| presentFindNavigator  | Shows find navigator          | function | /                              | Future<void>         | no    |
| dismissFindNavigator  | Hides find navigator          | function | /                              | Future<void>         | no    |
| onFindResultReceived  | Find result callback          | function | void Function(controller, int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)? | void | yes          |

---

### ProxyController API

| Name                | Description                    | Type     | Input                      | Output               | ohos Support |
|---------------------|--------------------------------|----------|----------------------------|----------------------|--------------|
| setProxyOverride            | Sets network proxy configuration | function | ProxySettings settings     | Future<void>         | yes           |
| clearProxyOverride          | Clears network proxy configuration | function | /                          | Future<void>         | yes           |
---

### PullToRefreshController API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| setEnabled | Enables/disables pull-to-refresh feature | function | bool enabled | Future<void> | yes |
| beginRefreshing | Manually starts refresh animation | function | / | Future<void> | yes |
| endRefreshing | Ends refresh animation | function | / | Future<void> | yes |
| isEnabled | Checks if refresh is enabled | function | / | Future<bool> | yes |
| isRefreshing | Checks if currently refreshing | function | / | Future<bool> | yes |
| setColor | Sets refresh indicator color | function | Color color | Future<void> | no |
| setBackgroundColor | Sets refresh background color | function | Color color | Future<void> | no |
| setDistanceToTriggerSync | Sets trigger distance for refresh | function | int distanceToTriggerSync | Future<void> | no |
| setSlingshotDistance | Sets elastic rebound distance (iOS-specific) | function | int slingshotDistance | Future<void> | no |
| setIndicatorSize | Sets indicator size (Android-specific) | function | PullToRefreshSize size | Future<void> | no |
| setStyledTitle | Sets refresh title (iOS-specific) | function | AttributedString attributedTitle | Future<void> | no |

---

### WebViewAssetLoader API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| handle | Handles resource requests at specified path | function | String path | Future<WebResourceResponse?> | yes |
| path | Resource path matching rules | String | / | String | yes |
| type | Path handler type | String | / | String | yes |
| AssetsPathHandler | Asset file handler | Object | String path | AssetsPathHandler | yes |
| ResourcesPathHandler | Resource file handler | Object | String path | ResourcesPathHandler | yes |
| InternalStoragePathHandler | Internal storage handler | Object | String path, String directory | InternalStoragePathHandler | no |
| CustomPathHandler | Custom path handler | Object | String path | CustomPathHandler | yes |

---

### ContentBlocker API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| ContentBlocker | Content blocking rule container | Object | ContentBlockerTrigger trigger, ContentBlockerAction action | ContentBlocker | yes |
| trigger | Trigger rule definition | ContentBlockerTrigger | / | ContentBlockerTrigger | yes |
| action | Execution action after trigger | ContentBlockerAction | / | ContentBlockerAction | yes |
| urlFilter | URL matching regular expression | String | String urlFilter | String | yes |
| urlFilterIsCaseSensitive | URL matching case sensitivity | bool | bool urlFilterIsCaseSensitive = false | bool | yes |
| resourceType | Resource type filter list | List<ContentBlockerTriggerResourceType> | List<ContentBlockerTriggerResourceType> resourceType = const [] | List<ContentBlockerTriggerResourceType> | no |
| ifDomain | Domain list for effective rules | List<String> | List<String> ifDomain = const [] | List<String> | yes |
| unlessDomain | Excluded domain list | List<String> | List<String> unlessDomain = const [] | List<String> | yes |
| loadType | Loading type filter | List<ContentBlockerTriggerLoadType> | List<ContentBlockerTriggerLoadType> loadType = const [] | List<ContentBlockerTriggerLoadType> | no |
| ifFrameUrl | iframe URL matching rules | List<String> | List<String> ifFrameUrl = const [] | List<String> | no |
| unlessTopUrl | Excluded main document URLs | List<String> | List<String> unlessTopUrl = const [] | List<String> | yes |
| type | Action type (block/display-none, etc.) | enum | ContentBlockerActionType type | ContentBlockerActionType | yes |
| selector | CSS selector (display-none only) | String | String? selector | String? | no |

---

### InAppWebViewKeepAlive API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| InAppWebViewKeepAlive | Creates WebView keep-alive instance | constructor | / | InAppWebViewKeepAlive | yes |
| id | Gets/sets keep-alive instance ID | String | / | String | yes |
| javaScriptHandlersMap | JavaScript handler mapping table | Map<String, JavaScriptHandlerCallback> | Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap | / | yes |
| userScripts | User script collection | Map<UserScriptInjectionTime, List<UserScript>> | Map<UserScriptInjectionTime, List<UserScript>> userScripts | / | yes |
| webMessageListenerObjNames | Web message listener object names | Set<String> | Set<String> webMessageListenerObjNames | / | yes |
| injectedScriptsFromURL | Script attributes injected via URL | Map<String, ScriptHtmlTagAttributes> | Map<String, ScriptHtmlTagAttributes> injectedScriptsFromURL | / | yes |
| webMessageChannels | Web message channel collection | Set<PlatformWebMessageChannel> | Set<PlatformWebMessageChannel> webMessageChannels = Set() | / | yes |
| webMessageListeners | Web message listener collection | Set<PlatformWebMessageListener> | Set<PlatformWebMessageListener> webMessageListeners = Set() | / | yes |

---

### InAppBrowser API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| openUrlRequest | Opens webpage with specified URLRequest | function | URLRequest urlRequest, InAppBrowserClassOptions? options, InAppBrowserClassSettings? settings | Future<void> | no |
| openFile | Opens local file | function | String assetFilePath, InAppBrowserClassOptions? options, InAppBrowserClassSettings? settings | Future<void> | no |
| openData | Opens HTML data | function | String data, String mimeType = "text/html", String encoding = "utf8", WebUri? baseUrl, WebUri? historyUrl, InAppBrowserClassSettings? settings | Future<void> | no |
| show | Shows browser window | function | / | Future<void> | yes |
| hide | Hides browser window | function | / | Future<void> | yes |
| close | Closes browser window | function | / | Future<void> | yes |
| setSettings | Sets browser configuration | function | InAppBrowserClassSettings settings | Future<void> | partially |
| getSettings | Gets current configuration | function | / | Future<InAppBrowserClassSettings?> | yes |
| addMenuItem | Adds menu item | function | InAppBrowserMenuItem menuItem | void | no |
| removeMenuItem | Removes menu item | function | InAppBrowserMenuItem menuItem | bool | no |
| isHidden | Checks if browser is hidden | function | / | Future<bool> | yes |
| isOpened | Checks if browser is open | function | / | bool | yes |
| onBrowserCreated | Browser creation callback | function | / | void | yes |
| onLoadStart | Page loading start callback | function | WebUri? url | void | yes |
| onLoadStop | Page loading completion callback | function | WebUri? url | void | yes |
| onLoadError | Loading error callback | function | WebUri? url, int code, String message | void | yes |
| onProgressChanged | Loading progress change callback | function | int progress | void | yes |
| onTitleChanged | Page title change callback | function | String? title | void | yes |
| onExit | Browser exit callback | function | / | void | no |
| onConsoleMessage | Console message callback | function | ConsoleMessage consoleMessage | void | yes |
| onReceivedIcon | Website icon reception callback | function | Uint8List icon | void | no |
| onPermissionRequest | Permission request callback | function | PermissionRequest permissionRequest | Future<PermissionResponse?> | yes |
| onJsAlert | JavaScript alert callback | function | JsAlertRequest jsAlertRequest | Future<JsAlertResponse?> | yes |
| onJsConfirm | JavaScript confirmation callback | function | JsConfirmRequest jsConfirmRequest | Future<JsConfirmResponse?> | yes |

---

### ChromeSafariBrowser API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| open | Opens browser with specified URL | function | WebUri? url, Map<String, String>? headers, List<WebUri>? otherLikelyURLs, ChromeSafariBrowserSettings? settings | Future<void> | no |
| launchUrl | Launches specified URL | function | WebUri url, Map<String, String>? headers, List<WebUri>? otherLikelyURLs | Future<void> | no |
| close | Closes browser | function | / | Future<void> | no |
| isAvailable | Checks browser availability | static function | / | Future<bool> | no |
| clearWebsiteData | Clears website data | static function | / | Future<void> | no |
| prewarmConnections | Prewarms connections | static function | List<WebUri> URLs | Future<PrewarmingToken?> | no |
| onClosed | Browser closure callback | function | / | void | no |
| onOpened | Browser open callback | function | / | void | no |
| onCompletedInitialLoad | Initial load completion callback | function | bool? didLoadSuccessfully | void | no |
| onNavigationEvent | Navigation event callback | function | CustomTabsNavigationEventType? navigationEvent | void | no |
| onPostMessage | postMessage callback | function | String message | void | no |
| setActionButton | Sets action button | function | ChromeSafariBrowserActionButton actionButton | void | no |
| setSecondaryToolbar | Sets secondary toolbar | function | ChromeSafariBrowserSecondaryToolbar secondaryToolbar | void | no |
| addMenuItem | Adds menu item | function | ChromeSafariBrowserMenuItem menuItem | void | no |
| requestPostMessageChannel | Requests message channel | function | WebUri sourceOrigin, WebUri? targetOrigin | Future<bool> | no |
| validateRelationship | Validates relationship | function | CustomTabsRelationType relation, WebUri origin | Future<bool> | no |

---

### InAppLocalhostServer API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| InAppLocalhostServer | Creates local server instance | constructor | int port = 8080, String directoryIndex = "index.html", String documentRoot = "./", bool shared = false | InAppLocalhostServer | no |
| start | Starts local server | function | / | Future<void> | no |
| close | Stops local server | function | / | Future<void> | no |
| isRunning | Checks server running status | function | / | bool | no |
| port | Gets server port number | int | / | int | no |
| directoryIndex | Gets directory index filename | String | / | String | no |
| documentRoot | Gets document root directory | String | / | String | no |
| shared | Checks if instance is shared | bool | / | bool | no |

---

### CookieManager API 

| Name | Description | Type | Input | Output | ohos Support |
|------|-------------|------|-------|--------|--------------|
| setCookie | Sets cookie for specified URL | function | WebUri url, String name, String value, String path = "/", String? domain, int? expiresDate, int? maxAge, bool? isSecure, bool? isHttpOnly, HTTPCookieSameSitePolicy? sameSite, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| getCookies | Gets all cookies for URL | function | WebUri url, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<List<Cookie>> | yes |
| getCookie | Gets cookie by name | function | WebUri url, String name, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<Cookie?> | yes |
| deleteCookie | Deletes specified cookie | function | WebUri url, String name, String path = "/", String? domain, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| deleteCookies | Deletes all cookies for URL | function | WebUri url, String path = "/", String? domain, InAppWebViewController? iosBelow11WebViewController, InAppWebViewController? webViewController | Future<bool> | yes |
| deleteAllCookies | Deletes all cookies | static function | / | Future<bool> | yes |
| getAllCookies | Gets all cookies | static function | / | Future<List<Cookie>> | yes |
| removeSessionCookies | Removes session cookies | static function | / | Future<bool> | yes |
| IOSCookieManager | iOS-specific cookie manager class (deprecated) | Object | / | IOSCookieManager | no |

---

### HttpAuthCredentialDatabase API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| getAllAuthCredentials | Gets all HTTP authentication credentials | function | / | Future<List<URLProtectionSpaceHttpAuthCredentials>> | yes |
| getHttpAuthCredentials | Gets HTTP credentials for specified protection space | function | URLProtectionSpace protectionSpace | Future<List<URLCredential>> | yes |
| setHttpAuthCredential | Sets HTTP authentication credentials | function | URLProtectionSpace protectionSpace, URLCredential credential | Future<void> | yes |
| removeHttpAuthCredential | Removes specified HTTP authentication credentials | function | URLProtectionSpace protectionSpace, URLCredential credential | Future<void> | yes |
| removeHttpAuthCredentials | Removes all credentials for specified protection space | function | URLProtectionSpace protectionSpace | Future<void> | yes |
| clearAllAuthCredentials | Clears all authentication credentials | function | / | Future<void> | yes |
| dispose             | Releases resources                  | function | / | Future<void> | yes |

---

### WebAuthenticationSession API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| create              | Creates Web authentication session  | function | WebUri url, String? callbackURLScheme, WebAuthenticationSessionCompletionHandler onComplete, WebAuthenticationSessionSettings? initialSettings | Future<WebAuthenticationSession> | no |
| canStart            | Checks if session can be started  | function | / | Future<bool> | no |
| start               | Starts Web authentication session | function | / | Future<bool> | no |
| cancel              | Cancels ongoing authentication session | function | / | Future<void> | no |
| dispose             | Releases session resources          | function | / | Future<void> | no |
| isAvailable         | Checks device support for Web authentication | static function | / | Future<bool> | no |
| id                  | Gets session unique identifier    | String   | / | String | no |
| url                 | Gets authentication session URL   | WebUri   | / | WebUri | no |
| callbackURLScheme   | Gets callback URL scheme          | String   | / | String? | no |
| initialSettings     | Gets initial session configuration  | WebAuthenticationSessionSettings | / | WebAuthenticationSessionSettings? | no |
| onComplete          | Authentication completion handler   | WebAuthenticationSessionCompletionHandler | / | WebAuthenticationSessionCompletionHandler | no |

---

### WebUri API 

| Name                | Description                         | Type     | Input | Output | ohos Support |
|---------------------|-------------------------------------|----------|-------|--------|--------------|
| authority           | Gets URI authority part (host:port format) | String   | / | String | yes          |
| data                | Gets URI data part                | UriData? | / | UriData? | yes          |
| fragment            | Gets URI fragment identifier      | String   | / | String | yes          |
| hasAbsolutePath     | Checks if path is absolute         | bool     | / | bool | yes          |
| hasAuthority        | Checks existence of authority       | bool     | / | bool | yes          |
| hasEmptyPath        | Checks if path is empty            | bool     | / | bool | yes          |
| hasFragment         | Checks existence of fragment        | bool     | / | bool | yes          |
| hasPort             | Checks existence of port number     | bool     | / | bool | yes          |
| hasQuery            | Checks existence of query parameters | bool     | / | bool | yes          |
| hasScheme           | Checks existence of protocol scheme | bool     | / | bool | yes          |
| host                | Gets hostname (case-sensitive)      | String   | / | String | yes          |
| isAbsolute          | Checks if URI is absolute         | bool     | / | bool | yes          |
| isScheme            | Checks protocol scheme match        | function | String scheme | bool | yes          |
| normalizePath       | Standardizes path (removes redundancy) | function | / | Uri | yes          |
| origin              | Gets origin (scheme+authority)    | String   | / | String | yes          |
| path                | Gets path (case-sensitive)          | String   | / | String | yes          |
| pathSegments        | Gets path segment list              | List<String> | / | List<String> | yes          |
| port                | Gets port number                  | int      | / | int | yes          |
| query               | Gets raw query string             | String   | / | String | yes          |
| queryParameters     | Gets query parameters map (first value only) | Map<String, String> | / | Map<String, String> | yes          |
| queryParametersAll  | Gets complete query parameters map  | Map<String, List<String>> | / | Map<String, List<String>> | yes          |
| removeFragment      | Creates new URI with fragment removed | function | / | Uri | yes          |
| replace             | Replaces URI components           | function | String? scheme, String? userInfo, String? host, int? port, String? path, Iterable<String>? pathSegments, String? query, Map<String, dynamic>? queryParameters, String? fragment | Uri | yes          |
| resolve             | Resolves relative URI             | function | String reference | Uri | yes          |
| resolveUri          | Resolves relative URI object      | function | Uri reference | Uri | yes          |
| scheme              | Gets protocol scheme (e.g., http) | String   | / | String | yes          |
| toFilePath          | Converts to file path             | function | bool? windows | String | yes          |
| userInfo            | Gets user info component          | String   | / | String | yes          |
| rawValue            | Gets raw unparsed URI string      | String   | / | String | yes          |
| uriValue            | Gets parsed standard URI object    | Uri      | / | Uri | yes          |
| isValidUri          | Indicates if URI parsing succeeded  | bool     | / | bool | yes          |
| forceToStringRawValue | Controls toString() to use raw value | bool     | / | bool | yes          |
| normalizePath()     | Returns new standardized path URI   | function | / | Uri | yes          |
| toString()          | String representation (configurable to use raw value) | function | / | String | yes          |

---

## 4. Known Issues

- [ ] Cross-domain issue with local resources on ohos: [issues#94](https://gitcode.com/openharmony-sig/flutter_inappwebview/issues/94)
- [ ] The goBack method cannot return to the previous page on ohos: [issues#141](https://gitcode.com/openharmony-sig/flutter_inappwebview/issues/141)

## 5. Others

## 6. License

This project is licensed under [The Apache-2.0 license](/LICENSE).
