/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import web_webview from '@ohos.web.webview'
import bundleManager from '@ohos.bundle.bundleManager';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView'
import { DVModel } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';
import { createDVModelFromJson } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicViewJson';
import URLRequest from '../../types/URLRequest';
import InAppWebViewFlutterPlugin from '../../InAppWebViewFlutterPlugin';
import InAppWebViewInterface from '../InAppWebViewInterface';
import { DVModelJson } from './DynamicUtils';
import InAppWebViewSettings from './InAppWebViewSettings';
import { buildOhosWebView } from './OhosWebView';
import { Any, Log, MethodChannel } from '@ohos/flutter_ohos';
import UserScript from '../../types/UserScript';
import JavaScriptBridgeInterface from '../JavaScriptBridgeInterface';
import JavaScriptBridgeJS from '../../plugin_scripts_js/JavaScriptBridgeJS';
import WebViewChannelDelegate from '../WebViewChannelDelegate';
import ContentWorld from '../../types/ContentWorld';
import { ValueCallback } from '../../types/ValueCallback';
import { WebMessageChannel } from '../web_message/WebMessageChannel';
import UserContentController from '../../types/UserContentController';
import util from '@ohos.util';
import Util from '../../Util';
import PluginScriptsUtil from '../../plugin_scripts_js/PluginScriptsUtil';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import InAppWebViewClient from './InAppWebViewClient';
import PluginScript from '../../types/PluginScript';
import PromisePolyfillJS from '../../plugin_scripts_js/PromisePolyfillJS';
import ConsoleLogJS from '../../plugin_scripts_js/ConsoleLogJS';
import PrintJS from '../../plugin_scripts_js/PrintJS';
import OnWindowBlurEventJS from '../../plugin_scripts_js/OnWindowBlurEventJS';
import OnWindowFocusEventJS from '../../plugin_scripts_js/OnWindowFocusEventJS';
import InterceptAjaxRequestJS from '../../plugin_scripts_js/InterceptAjaxRequestJS';
import InterceptFetchRequestJS from '../../plugin_scripts_js/InterceptFetchRequestJS';
import OnLoadResourceJS from '../../plugin_scripts_js/OnLoadResourceJS';
import { InAppBrowserDelegate } from '../../in_app_browser/InAppBrowserDelegate';
import { ArrayList, HashMap, List } from '@kit.ArkTS';
import PrintJobSettings from '../../print_job/PrintJobSettings';
import WebMessageListener from '../web_message/WebMessageListener';
import WebViewAssetLoaderExt from '../../types/WebViewAssetLoaderExt';
import ContentBlockerHandler from '../../content_blocker/ContentBlockerHandler';
import ContentBlockerAction from '../../content_blocker/ContentBlockerAction';
import ContentBlockerTrigger from '../../content_blocker/ContentBlockerTrigger';
import ContentBlocker from '../../content_blocker/ContentBlocker';
import cert from '@ohos.security.cert';
import image from '@ohos.multimedia.image';
import window from '@ohos.window';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';
import common from '@ohos.app.ability.common';
import { FindInteractionController } from '../../find_interaction/FindInteractionController';
import PullToRefreshLayout from '../../pull_to_refresh/PullToRefreshLayout';
import EventConstant from '../../EventConstant'
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = "InAppWebView"
const METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_";

export default class InAppWebView implements InAppWebViewInterface {
  public plugin: InAppWebViewFlutterPlugin;
  public inAppBrowserDelegate: InAppBrowserDelegate | null = null
  public id: number;
  public windowId: number | null | undefined;
  public inAppWebViewClient: InAppWebViewClient | null = null;
  public channelDelegate: WebViewChannelDelegate | null = null;
  private javaScriptBridgeInterface: JavaScriptBridgeInterface | null = null;
  public customSettings: InAppWebViewSettings;
  public isLoading: boolean = false
  private inFullscreen: boolean = false;
  public zoomScale: number = 1.0
  public contentBlockerHandler = new ContentBlockerHandler();
  public regexToCancelSubFramesLoadingCompiled: RegExp | null = null;
  // public  gestureDetector: GestureDetector | null = null;
  // public floatingContextMenu: LinearLayout | null = null;
  public contextMenu: Map<string, Any> | undefined = undefined;
  // static mHandler: Handler = new Handler();
  // public checkScrollStoppedTask: Runnable | null = null;
  public initialPositionScrollStoppedTask: number = -1;
  public newCheckScrollStoppedTask: number = 100;
  // ms
  // public checkContextMenuShouldBeClosedTask: Runnable | null = null;
  public newCheckContextMenuShouldBeClosedTaskTask: number = 100;
  // ms
  public userContentController: UserContentController = new UserContentController(this);
  public callAsyncJavaScriptCallbacks: Map<string, ValueCallback<string>> = new Map<string, ValueCallback<string>>();
  public evaluateJavaScriptContentWorldCallbacks: Map<string, ValueCallback<string>> = new Map<string, ValueCallback<string>>()
  public webMessageChannels: Map<string, WebMessageChannel> = new Map<string, WebMessageChannel>()
  public webMessageListeners: Array<WebMessageListener> = new Array<WebMessageListener>();
  private initialUserOnlyScripts: Array<UserScript>;
  public findInteractionController: FindInteractionController | null = null;
  public webViewAssetLoaderExt: WebViewAssetLoaderExt | null = null;
  private interceptOnlyAsyncAjaxRequestsPluginScript: PluginScript | null = null;
  public context: Context;
  public controller: web_webview.WebviewController = new web_webview.WebviewController();
  private ohosWebViewModel: DVModel | null = null;
  private controllerAttached: boolean = false;
  private pullToRefreshLayout: PullToRefreshLayout | null = null;
  private viewWidth = 0;
  private viewHeight= 0;
  private curUrl: string | Resource = "";

  constructor(context: Context, plugin: InAppWebViewFlutterPlugin, id: number, windowId: number | null | undefined,
              customSettings: InAppWebViewSettings, userScripts: Array<UserScript>, contextMenu?: Map<string, Any>) {
    this.context = context;
    this.plugin = plugin;
    this.id = id;
    let channel = new MethodChannel(plugin.messenger!, METHOD_CHANNEL_NAME_PREFIX + id);
    this.channelDelegate = new WebViewChannelDelegate(this, channel);
    this.windowId = windowId;
    this.customSettings = customSettings;
    this.contextMenu = contextMenu;
    this.initialUserOnlyScripts = userScripts;
    // if (plugin != null && plugin.activity != null) {
    //   plugin.activity.registerForContextMenu(this);
    // }
  }

  setPullToRefreshLayout(pullToRefreshLayout: PullToRefreshLayout) {
    this.pullToRefreshLayout = pullToRefreshLayout;
  }

  getPullToRefreshLayout(): PullToRefreshLayout {
    return this.pullToRefreshLayout!!;
  }

  public async prepare() {
    if (this.plugin != null) {
      this.webViewAssetLoaderExt = WebViewAssetLoaderExt.fromMap(this.customSettings.webViewAssetLoader, this.plugin, getContext());
    }

    this.javaScriptBridgeInterface = new JavaScriptBridgeInterface(this);
    //addJavascriptInterface(javaScriptBridgeInterface, JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME);

    this.inAppWebViewClient = new InAppWebViewClient(this.plugin, this);

    if (this.windowId == null || this.windowId == undefined) {
      this.prepareAndAddUserScripts();
    }

    if (this.customSettings.useOnDownloadStart) {
      // setDownloadListener(new DownloadStartListener());
    }

    // WebSettings settings = getSettings();
    //
    // settings.setJavaScriptEnabled(customSettings.javaScriptEnabled);
    // settings.setJavaScriptCanOpenWindowsAutomatically(customSettings.javaScriptCanOpenWindowsAutomatically);
    // settings.setBuiltInZoomControls(customSettings.builtInZoomControls);
    // settings.setDisplayZoomControls(customSettings.displayZoomControls);
    // settings.setSupportMultipleWindows(customSettings.supportMultipleWindows);

    this.contentBlockerHandler.getRuleList().clear();
    this.customSettings.contentBlockers.forEach((contentBlocker: Any) => {
      let trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
      let action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
      this.contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
    })

    if (this.customSettings.regexToCancelSubFramesLoading != null) {
      this.regexToCancelSubFramesLoadingCompiled = new RegExp(this.customSettings.regexToCancelSubFramesLoading);
    }

    await this.waitControllerAttached()
    this.controller.registerJavaScriptProxy(this.javaScriptBridgeInterface, JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME, this.javaScriptBridgeInterface.getMethodList());

    if (this.customSettings.incognito)
      this.setIncognito(true);

    this.setCacheEnabled(this.customSettings.cacheEnabled);

    // settings
    if (this.customSettings.userAgent != null && this.customSettings.userAgent.length > 0) {
      this.controller.setCustomUserAgent(this.customSettings.userAgent);
    }

    if (this.customSettings.applicationNameForUserAgent != null && this.customSettings.applicationNameForUserAgent.length > 0) {
      let userAgent = (this.customSettings.userAgent != null && this.customSettings.userAgent.length > 0) ? this.customSettings.userAgent : this.controller.getUserAgent();
      let userAgentWithApplicationName = userAgent + " " + this.customSettings.applicationNameForUserAgent;
      this.controller.setCustomUserAgent(userAgentWithApplicationName);
    }

    web_webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(this.customSettings.thirdPartyCookiesEnabled);
  }

  prepareAndAddUserScripts(): void {
    this.userContentController.addPluginScript(PromisePolyfillJS.PROMISE_POLYFILL_JS_PLUGIN_SCRIPT);
    this.userContentController.addPluginScript(JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT);
    this.userContentController.addPluginScript(ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT);
    this.userContentController.addPluginScript(PrintJS.PRINT_JS_PLUGIN_SCRIPT);
    this.userContentController.addPluginScript(OnWindowBlurEventJS.ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT);
    this.userContentController.addPluginScript(OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT);
    this.interceptOnlyAsyncAjaxRequestsPluginScript = InterceptAjaxRequestJS.createInterceptOnlyAsyncAjaxRequestsPluginScript(
      this.customSettings.interceptOnlyAsyncAjaxRequests);
    if (this.customSettings.useShouldInterceptAjaxRequest) {
      this.userContentController.addPluginScript(this.interceptOnlyAsyncAjaxRequestsPluginScript);
      this.userContentController.addPluginScript(InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (this.customSettings.useShouldInterceptFetchRequest) {
      this.userContentController.addPluginScript(InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (this.customSettings.useOnLoadResource) {
      this.userContentController.addPluginScript(OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT);
    }
    if (!this.customSettings.useHybridComposition) {
      this.userContentController.addPluginScript(PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT);
    }
    this.userContentController.addUserOnlyScripts(this.initialUserOnlyScripts);
  }

  public setIncognito(enabled: boolean): void {
    if (enabled) {
      web_webview.WebCookieManager.clearAllCookiesSync(true);

      this.setCacheEnabled(false);

      this.controller.clearHistory();
      this.controller.clearMatches();
      this.controller.clearSslCache();
      this.controller.removeCache(true);

      // No form data or autofill enabled
      // clearFormData();
      // settings.setSavePassword(false);
      // settings.setSaveFormData(false);
    } else {
      this.setCacheEnabled(true);

      // settings.setSavePassword(true);
      // settings.setSaveFormData(true);
    }
  }

  public setCacheEnabled(enabled: boolean): void {
    let context = this.context as common.UIAbilityContext;
    context.eventHub.emit(EventConstant.EVENT_UPDATE_CACHEENABLE, enabled);
  }

  async loadUrl(urlRequest: URLRequest) {
    await this.waitControllerAttached();
    let url = urlRequest.getUrl();
    let method = urlRequest.getMethod();
    if (method != null && method == "POST") {
      this.postUrl(url, urlRequest.getBody());
      return;
    }
    let realUrl = url.startsWith("resources/rawfile/") ? $rawfile(url.replace("resources/rawfile/", "")) : url;
    let headers = urlRequest.getHeaders();
    this.curUrl = realUrl;
    if (headers != null) {
      this.controller.loadUrl(realUrl, this.toWebHeaders(headers));
      return;
    }
    this.controller.loadUrl(realUrl);
  }

  async loadFile(assetFilePath: string) {
    if (this.plugin == null) {
      return;
    }
    let realUrl = $rawfile("flutter_assets/" + assetFilePath)
    this.curUrl = realUrl;
    await this.waitControllerAttached();
    this.controller.loadUrl(realUrl)
  }

  getLoadUrl(): string | Resource {
    return this.curUrl
  }

  getLoading(): boolean {
    return this.isLoading
  }

  clearCookies(): void {
    web_webview.WebCookieManager.clearAllCookiesSync()
  }

  refresh(): void{
    this.controller.refresh()
  }

  scrollToTop(): void {
    this.controller.scrollTo(0, 0)
  }

  public clearAllCache(): void {
    this.controller.removeCache(true);
    this.clearCookies();
  }

  public async takeScreenshot(screenshotConfiguration: Map<string, Any> | null, result: MethodResult): Promise<void> {
    let pixelDensity: number = Util.getPixelDensity()

    try {
      let windowClass: window.Window = await window.getLastWindow(this.context)
      let screenshotBitmap: image.PixelMap = await image.createPixelMap(new ArrayBuffer(96), {
        pixelFormat: 3,
        size: {
          height: windowClass.getWindowProperties().windowRect.height,
          width: windowClass.getWindowProperties().windowRect.width
        }
      })
      await screenshotBitmap.translate(-windowClass.getWindowProperties()
        .windowRect
        .left, -windowClass.getWindowProperties().windowRect.top)

      let compressFormat: string = "image/jpeg"
      let quality: number = 100

      if (screenshotConfiguration != null) {
        let rect: Map<string, number> = screenshotConfiguration.get("rect") as Map<string, number>
        if (rect != null) {
          let rectX: number = Math.floor(rect.get("x") ?? 0 * pixelDensity + 0.5) as number
          let rectY: number = Math.floor(rect.get("y") ?? 0 * pixelDensity + 0.5) as number
          let rectWidth: number = Math.min((await screenshotBitmap.getImageInfo()).size.width, Math.floor(rect.get("width") ?? 0 * pixelDensity + 0.5));
          let rectHeight: number = Math.min((await screenshotBitmap.getImageInfo()).size.height, Math.floor(rect.get("height") ?? 0 * pixelDensity + 0.5));
          await screenshotBitmap.crop({
            x: rectX, y: rectY, size: {
              height: rectHeight, width: rectWidth
            }
          })
        }

        let snapshotWidth: number = screenshotConfiguration.get("snapshotWidth") as number
        if (snapshotWidth != null) {
          let dstWidth: number = Math.floor(snapshotWidth * pixelDensity + 0.5) as number
          let bitMapInfo: image.ImageInfo = await screenshotBitmap.getImageInfo()
          let ratioBitmap: number = bitMapInfo.size.width / bitMapInfo.size.height
          let dstHeight: number = dstWidth / ratioBitmap
          screenshotBitmap.scale(dstWidth, dstHeight)
        }

        try {
          switch (screenshotConfiguration.get("compressFormat")) {
            case "JPEG":
              compressFormat = "image/jpeg"
              break
            case "PNG":
              compressFormat = "image/png"
              break
            default:
              compressFormat = "image/jpeg"
          }
        } catch (e) {
          Log.e(TAG, "", e);
        }

        quality = screenshotConfiguration.get("quality") as number
      }

      const imagePackerApi = image.createImagePacker()
      let packOpts: image.PackingOption = {
        format: compressFormat, quality: quality
      }

      let bos: ArrayBuffer = await imagePackerApi.packing(screenshotBitmap, packOpts)

      result.success(bos);
    } catch (e) {
      Log.e(TAG, "", e);
      result.success(null);
    }
  }

  public setSettings(newCustomSettings: InAppWebViewSettings, newSettingsMap: Map<string, Any>): void {

    if (newSettingsMap.has("useShouldInterceptAjaxRequest") && this.customSettings.useShouldInterceptAjaxRequest != newCustomSettings.useShouldInterceptAjaxRequest) {
      this.enablePluginScriptAtRuntime(
        InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE,
        newCustomSettings.useShouldInterceptAjaxRequest,
        InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newSettingsMap.has("interceptOnlyAsyncAjaxRequests") && this.customSettings.interceptOnlyAsyncAjaxRequests != newCustomSettings.interceptOnlyAsyncAjaxRequests) {
      this.enablePluginScriptAtRuntime(
        InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_INTERCEPT_ONLY_ASYNC_AJAX_REQUESTS_JS_SOURCE,
        newCustomSettings.interceptOnlyAsyncAjaxRequests,
        this.interceptOnlyAsyncAjaxRequestsPluginScript!!
      );
    }

    if (newSettingsMap.has("useShouldInterceptFetchRequest") && this.customSettings.useShouldInterceptFetchRequest != newCustomSettings.useShouldInterceptFetchRequest) {
      this.enablePluginScriptAtRuntime(
        InterceptFetchRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE,
        newCustomSettings.useShouldInterceptFetchRequest,
        InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newSettingsMap.has("useOnLoadResource") && this.customSettings.useOnLoadResource != newCustomSettings.useOnLoadResource) {
      this.enablePluginScriptAtRuntime(
        OnLoadResourceJS.FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE,
        newCustomSettings.useOnLoadResource,
        OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT
      );
    }

    if (newCustomSettings.contentBlockers != null) {
      this.contentBlockerHandler.getRuleList().clear();
      newCustomSettings.contentBlockers.forEach((contentBlocker: Any) => {
        let trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
        let action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
        this.contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
      })
    }

    if (newSettingsMap.has("regexToCancelSubFramesLoading") && (this.customSettings.regexToCancelSubFramesLoading == null ||
      this.customSettings.regexToCancelSubFramesLoading != newCustomSettings.regexToCancelSubFramesLoading)) {
      if (newCustomSettings.regexToCancelSubFramesLoading == null)
        this.regexToCancelSubFramesLoadingCompiled = null;
      else
        this.regexToCancelSubFramesLoadingCompiled = new RegExp(newCustomSettings.regexToCancelSubFramesLoading);
    }

    if (newSettingsMap.has("userAgent") != null && this.customSettings.userAgent != newCustomSettings.userAgent && newCustomSettings.userAgent.length > 0)
      this.controller.setCustomUserAgent(newCustomSettings.userAgent);

    if (newSettingsMap.has("applicationNameForUserAgent") && this.customSettings.applicationNameForUserAgent != newCustomSettings.applicationNameForUserAgent && newCustomSettings.applicationNameForUserAgent != null &&
      newCustomSettings.applicationNameForUserAgent.length > 0) {
      let userAgent = (newCustomSettings.userAgent != null && newCustomSettings.userAgent.length > 0) ? newCustomSettings.userAgent : this.controller.getUserAgent();
      let userAgentWithApplicationName = userAgent + " " + newCustomSettings.applicationNameForUserAgent;
      this.controller.setCustomUserAgent(userAgentWithApplicationName);
    }

    if (newSettingsMap.has("incognito") && this.customSettings.incognito != newCustomSettings.incognito){
      this.setIncognito(newCustomSettings.incognito);
    }

    if (newSettingsMap.has("cacheEnabled") && this.customSettings.cacheEnabled != newCustomSettings.cacheEnabled)
      this.setCacheEnabled(newCustomSettings.cacheEnabled);

    if (this.plugin != null) {
      if (this.webViewAssetLoaderExt != null) {
        this.webViewAssetLoaderExt.dispose();
      }
      this.webViewAssetLoaderExt = WebViewAssetLoaderExt.fromMap(newCustomSettings.webViewAssetLoader, this.plugin, getContext());
    }
    this.customSettings = newCustomSettings;
    this.onSettinsUpdated()
  }

  public getCustomSettings(): Map<string, Any> | null {
    return this.customSettings != null ? this.customSettings.getRealSettings(this) : null
  }

  public enablePluginScriptAtRuntime(flagVariable: string, enable: boolean, pluginScript: PluginScript) {
    this.evaluateJavascript("window." + flagVariable, null, {
      onReceiveValue: (value) => {
        let alreadyLoaded = value != null && value.toLowerCase() != "null";
        if (alreadyLoaded) {
          let enableSource = "window." + flagVariable + " = " + enable + ";";
          this.evaluateJavascript(enableSource, null, null);
          if (!enable) {
            this.userContentController.removePluginScript(pluginScript);
          }
        } else if (enable) {
          this.evaluateJavascript(pluginScript.getSource(), null, null);
          this.userContentController.addPluginScript(pluginScript);
        }
      }
    });
  }

  public injectDeferredObject(source: string, contentWorld: ContentWorld | null, jsWrapper: string | null, resultCallback: ValueCallback<string> | null): void {
    let resultUuid: string | null = contentWorld != null && !contentWorld.equals(ContentWorld.PAGE) ? util.generateRandomUUID(true)
      .toString() : null
    let scriptToInject: string = source
    if (jsWrapper != null) {
      let jsonEsc = Array<string>();
      jsonEsc.push(source);
      let jsonRepr: string = JSON.stringify(jsonEsc);
      let jsonSourceString: string = jsonRepr.substring(1, jsonRepr.length - 1);
      scriptToInject = Util.formatString(jsWrapper, jsonSourceString);
    }
    if (resultUuid != null && resultCallback != null) {
      this.evaluateJavaScriptContentWorldCallbacks.set(resultUuid, resultCallback);
      scriptToInject = Util.replaceAll(PluginScriptsUtil.EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE,
        PluginScriptsUtil.VAR_RANDOM_NAME, "_" + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "_" + Math.round(Math.random() * 1000000))
        .replace(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, UserContentController.escapeCode(source))
        .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid);
    }

    scriptToInject = this.userContentController.generateCodeForScriptEvaluation(scriptToInject, contentWorld);
    try {
      this.controller.runJavaScript(scriptToInject).then(res => {
        if (resultUuid != null || resultCallback == null)
          return;
        resultCallback.onReceiveValue(res);
      });
    } catch (error) {
      let errorCode = (error as BusinessError).code;
      let errorMsg = (error as BusinessError).message;
      console.log(`run JavaScript error, ErrorCode:${errorCode}, errorMessage:${errorMsg}`);
    }
  }

  public evaluateJavascript(source: string, contentWorld: ContentWorld | null, resultCallback: ValueCallback<string> | null): void {
    this.injectDeferredObject(source, contentWorld, null, resultCallback);
  }

  public injectJavascriptFileFromUrl(urlFile: string, scriptHtmlTagAttributes: Map<string, Any> | null): void {
    let scriptAttributes: string = "";
    if (scriptHtmlTagAttributes != null) {
      let typeAttr: string = scriptHtmlTagAttributes.get("type") as string;
      if (typeAttr != null) {
        // scriptAttributes += " script.type = '" + typeAttr.replaceAll("'", "\\\\'") + "'; ";
        scriptAttributes += " script.type = '" + typeAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let idAttr: string = scriptHtmlTagAttributes.get("id") as string;
      if (idAttr != null) {
        // let scriptIdEscaped: string = idAttr.replaceAll("'", "\\\\'");
        let scriptIdEscaped: string = idAttr.replace(/'/g, "\\\\'");
        scriptAttributes += " script.id = '" + scriptIdEscaped + "'; ";
        scriptAttributes += " script.onload = function() {" +
          "  if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + " != null) {" +
          "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('onInjectedScriptLoaded', '" + scriptIdEscaped + "');" +
          "  }" +
          "};";
        scriptAttributes += " script.onerror = function() {" +
          "  if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + " != null) {" +
          "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('onInjectedScriptError', '" + scriptIdEscaped + "');" +
          "  }" +
          "};";
      }
      let asyncAttr: boolean = scriptHtmlTagAttributes.get("async") as boolean;
      if (asyncAttr != null && asyncAttr) {
        scriptAttributes += " script.async = true; ";
      }
      let deferAttr: boolean = scriptHtmlTagAttributes.get("defer") as boolean;
      if (deferAttr != null && deferAttr) {
        scriptAttributes += " script.defer = true; ";
      }
      let crossOriginAttr: string = scriptHtmlTagAttributes.get("crossOrigin") as string;
      if (crossOriginAttr != null) {
        // scriptAttributes += " script.crossOrigin = '" + crossOriginAttr.replaceAll("'", "\\\\'") + "'; ";
        scriptAttributes += " script.crossOrigin = '" + crossOriginAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let integrityAttr: string = scriptHtmlTagAttributes.get("integrity") as string;
      if (integrityAttr != null) {
        // scriptAttributes += " script.integrity = '" + integrityAttr.replaceAll("'", "\\\\'") + "'; ";
        scriptAttributes += " script.integrity = '" + integrityAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let noModuleAttr: boolean = scriptHtmlTagAttributes.get("noModule") as boolean;
      if (noModuleAttr != null && noModuleAttr) {
        scriptAttributes += " script.noModule = true; ";
      }
      let nonceAttr: string = scriptHtmlTagAttributes.get("nonce") as string;
      if (nonceAttr != null) {
        // scriptAttributes += " script.nonce = '" + nonceAttr.replaceAll("'", "\\\\'") + "'; ";
        scriptAttributes += " script.nonce = '" + nonceAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let referrerPolicyAttr: string = scriptHtmlTagAttributes.get("referrerPolicy") as string;
      if (referrerPolicyAttr != null) {
        // scriptAttributes += " script.referrerPolicy = '" + referrerPolicyAttr.replaceAll("'", "\\\\'") + "'; ";
        scriptAttributes += " script.referrerPolicy = '" + referrerPolicyAttr.replace(/'/g, "\\\\'") + "'; ";
      }
    }
    let jsWrapper: string = "(function(d) { var script = d.createElement('script'); " + scriptAttributes +
      " script.src = %s; if (d.body != null) { d.body.appendChild(script); } })(document);";
    this.injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  public injectCSSCode(source: string): void {
    let jsWrapper: string = "(function(d) { var style = d.createElement('style'); style.innerHTML = %s;" +
      " if (d.head != null) { d.head.appendChild(style); } })(document);";
    this.injectDeferredObject(source, null, jsWrapper, null);
  }

  public injectCSSFileFromUrl(urlFile: string, cssLinkHtmlTagAttributes: Map<string, Any> | null): void {
    let cssLinkAttributes: string = "";
    let alternateStylesheet: string = "";
    if (cssLinkHtmlTagAttributes != null) {
      let idAttr: string = cssLinkHtmlTagAttributes.get("id") as string;
      if (idAttr != null) {
        // cssLinkAttributes += " link.id = '" + idAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.id = '" + idAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let mediaAttr: string = cssLinkHtmlTagAttributes.get("media") as string;
      if (mediaAttr != null) {
        // cssLinkAttributes += " link.media = '" + mediaAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.media = '" + mediaAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let crossOriginAttr: string = cssLinkHtmlTagAttributes.get("crossOrigin") as string;
      if (crossOriginAttr != null) {
        // cssLinkAttributes += " link.crossOrigin = '" + crossOriginAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.crossOrigin = '" + crossOriginAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let integrityAttr: string = cssLinkHtmlTagAttributes.get("integrity") as string;
      if (integrityAttr != null) {
        // cssLinkAttributes += " link.integrity = '" + integrityAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.integrity = '" + integrityAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let referrerPolicyAttr: string = cssLinkHtmlTagAttributes.get("referrerPolicy") as string;
      if (referrerPolicyAttr != null) {
        // cssLinkAttributes += " link.referrerPolicy = '" + referrerPolicyAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.referrerPolicy = '" + referrerPolicyAttr.replace(/'/g, "\\\\'") + "'; ";
      }
      let disabledAttr: boolean = cssLinkHtmlTagAttributes.get("disabled") as boolean;
      if (disabledAttr != null && disabledAttr) {
        cssLinkAttributes += " link.disabled = true; ";
      }
      let alternateAttr: boolean = cssLinkHtmlTagAttributes.get("alternate") as boolean;
      if (alternateAttr != null && alternateAttr) {
        alternateStylesheet = "alternate ";
      }
      let titleAttr: string = cssLinkHtmlTagAttributes.get("title") as string;
      if (titleAttr != null) {
        // cssLinkAttributes += " link.title = '" + titleAttr.replaceAll("'", "\\\\'") + "'; ";
        cssLinkAttributes += " link.title = '" + titleAttr.replace(/'/g, "\\\\'") + "'; ";
      }
    }
    let jsWrapper: string = "(function(d) { var link = d.createElement('link'); link.rel='" + alternateStylesheet + "stylesheet'; link.type='text/css'; " +
      cssLinkAttributes + " link.href = %s; if (d.head != null) { d.head.appendChild(link); } })(document);";
    this.injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  public getCopyBackForwardList(): HashMap<string, Any> {
    let currentList: web_webview.BackForwardList = this.controller.getBackForwardEntries();
    let currentSize: number = currentList.size;
    let currentIndex: number = currentList.currentIndex;

    let history: List<HashMap<String, String>> = new List<HashMap<String, String>>();

    for (let i: number = 0; i < currentSize; i++) {
      let historyItem: web_webview.HistoryItem = currentList.getItemAtIndex(i);
      let historyItemMap: HashMap<string, string> = new HashMap<string, string>();

      historyItemMap.set("originalUrl", historyItem.historyRawUrl);
      historyItemMap.set("title", historyItem.title);
      historyItemMap.set("url", historyItem.historyUrl);

      history.add(historyItemMap);
    }

    let result: HashMap<string, Any> = new HashMap<string, Any>();

    result.set("list", history);
    result.set("currentIndex", currentIndex);

    return result;
  }

  public scrollTo(x: number, y: number, animated: boolean): void {
    if (animated) {
      let options: AnimatorOptions = {
        duration: 300,
        easing: "friction",
        delay: 0,
        fill: "forwards",
        direction: "normal",
        iterations: 3,
        begin: x,
        end: y
      };
      let animatorResult: AnimatorResult | undefined = animator.create(options);
      animatorResult.play()
    } else {
      this.controller.scrollTo(x, y);
    }
  }

  public async scrollBy(x: number, y: number, animated: boolean): Promise<void> {
    let windowClass: window.Window = await window.getLastWindow(this.context)
    if (animated) {
      let options: AnimatorOptions = {
        duration: 300,
        easing: "friction",
        delay: 0,
        fill: "forwards",
        direction: "normal",
        iterations: 3,
        begin: windowClass.getWindowProperties().windowRect.left + x,
        end: windowClass.getWindowProperties().windowRect.top + y
      };
      let animatorResult: AnimatorResult | undefined = animator.create(options);
      animatorResult.play()
    } else {
      this.controller.scrollBy(x, y);
    }
  }

  public printCurrentPage(settings: PrintJobSettings): string | null {
    return null;
  }

  dispose() {
    if (this.webViewAssetLoaderExt != null) {
      this.webViewAssetLoaderExt.dispose();
      this.webViewAssetLoaderExt = null;
    }
    if(this.controller){
      this.controller.deleteJavaScriptRegister(JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME);
      this.controller.refresh();
    }
    if(this.javaScriptBridgeInterface != null){
      this.javaScriptBridgeInterface.dispose();
      this.javaScriptBridgeInterface = null;
    }
    if(this.findInteractionController != null){
      this.findInteractionController.dispose();
      this.findInteractionController = null;
    }
    if(this.pullToRefreshLayout != null){
      this.pullToRefreshLayout.dispose();
      this.pullToRefreshLayout = null;
    }
    if(this.channelDelegate != null){
      this.channelDelegate.dispose();
      this.channelDelegate = null;
    }
  }

  getUrl(): string {
    return this.controller.getUrl()
  }

  getTitle(): string {
    return this.controller.getTitle()
  }

  getProgress(): number {
    return this.inAppWebViewClient ? this.inAppWebViewClient!.progress : 0
  }

  reload(): void {
    this.controller.refresh();
  }

  canGoBack(): boolean {
    return this.controller.accessBackward()
  }

  goBack(): void {
    this.controller.backward()
  }

  canGoForward(): boolean {
    return this.controller.accessForward()
  }

  goForward(): void {
    this.controller.forward()
  }

  canGoBackOrForward(steps: number): boolean {
    return this.controller.accessStep(steps)
  }

  goBackOrForward(steps: number): void {
    this.controller.backOrForward(steps)
  }

  stopLoading(): void {
    this.controller.stop()
  }

  clearSslPreferences(): void {
    this.controller.clearSslCache()
  }

  findAllAsync(find: string): void {
    this.controller.searchAllAsync(find)
  }

  findNext(forward: boolean): void {
    this.controller.searchNext(forward)
  }

  clearMatches(): void {
    this.controller.clearMatches()
  }

  onPause(): void {
    this.controller.pauseAllMedia()
    this.controller.onInactive()
  }

  onResume(): void {
    this.controller.resumeAllMedia()
    this.controller.onActive()
  }

  pauseTimers(): void {
    web_webview.WebviewController.pauseAllTimers();
  }

  resumeTimers(): void {
    web_webview.WebviewController.resumeAllTimers();
  }

  getContentHeight(): number {
    return this.controller.getPageHeight()
  }

  public getContentWidth(callback: ValueCallback<number>): void {
    this.controller.runJavaScriptExt("document.documentElement.scrollWidth;").then((result) => {
      callback.onReceiveValue(result.getNumber())
    })
  }

  public saveWebArchive(baseName: string, autoName: boolean, callback: ValueCallback<string>): void {
    this.controller.storeWebArchive(baseName, autoName).then(fileName => {
      callback.onReceiveValue(fileName)
    })
  }

  public isSecureContext(resultCallback: ValueCallback<boolean>): void {
    this.evaluateJavascript("window.isSecureContext", null,  {
      onReceiveValue: (value) => {
        if (value == null || value.length == 0 || value == "null" || value == "false") {
          resultCallback.onReceiveValue(false);
          return;
        }
        resultCallback.onReceiveValue(true);
      }
    });
  }

  zoomBy(zoomFactor: number): void {
    if (zoomFactor < 0.01)
      throw new Error("zoomFactor must be greater than 0.01.");
    if (zoomFactor > 100.0)
      throw new Error("zoomFactor must be less than 100.");

    this.controller.zoom(zoomFactor)
  }

  getOriginalUrl(): string {
    return this.controller.getOriginalUrl()
  }

  getZoomScale(): number {
    return this.zoomScale
  }

  getHitTestResult(): web_webview.HitTestValue {
    return this.controller.getHitTestValue()
  }

  pageDown(bottom: boolean): boolean {
    try {
      this.controller.pageDown(bottom)
      return true
    } catch (e) {
      throw Error("Jumping to the bottom of the page failed")
    }
  }

  pageUp(top: boolean): boolean {
    try {
      this.controller.pageUp(top)
      return true
    } catch (e) {
      throw Error("Jumping to the top of the page failed")
    }
  }

  zoomIn(): boolean {
    try {
      this.controller.zoomIn()
      return true
    } catch (e) {
      throw Error("Failed to perform amplification operation")
    }
  }

  zoomOut(): boolean {
    try {
      this.controller.zoomOut()
      return true
    } catch (e) {
      throw Error("Failed to perform shrink operation")
    }
  }

  clearFocus(): void {
    this.controller.onInactive()
  }

  async getCertificate() {
    let certificates = await this.controller.getCertificate()
    if (certificates && certificates.length > 0) {
      return certificates[0]
    } else {
      return null
    }
  }

  clearHistory(): void {
    this.controller.clearHistory()
  }

  async postUrl(url: string, postData: ArrayBuffer | null) {
    await this.waitControllerAttached();
    const uint8Array: Uint8Array = postData as Uint8Array;
    const buffer: ArrayBuffer = uint8Array.buffer as ArrayBuffer;
    this.controller.postUrl(url, buffer);
  }

  async loadDataWithBaseURL(baseUrl: string, data: string, mimeType: string, encoding: string, historyUrl: string) {
    await this.waitControllerAttached();
    baseUrl ??= "about:blank";
    historyUrl ??= "about:blank";
    this.controller.loadData(data, mimeType, encoding, baseUrl, historyUrl)
  }

  getController(): web_webview.WebviewController {
    return this.controller;
  }

  public getInAppBrowserDelegate(): InAppBrowserDelegate | null {
    return this.inAppBrowserDelegate;
  }

  public setContextMenu(contextMenu: Map<string, Any>): void {
    this.contextMenu = contextMenu;
  }

  public requestFocusNodeHref(): Map<string, Any> {
    /// Android中方法可获取其他的属性，ohos只能返回对应图片或连接的url
    let hitValue = this.controller.getHitTestValue();

    let obj: Map<string, Any> = new Map<string, Any>();
    obj.set("src", hitValue.extra);
    obj.set("url", hitValue.extra);
    obj.set("title", hitValue.type);

    return obj;
  }

  public requestImageRef(): Map<string, Any> {
    /// Android中方法可获取其他的属性，ohos只能返回对应图片或连接的url
    let hitValue = this.controller.getHitTestValue();

    let obj: Map<string, Any> = new Map<string, Any>();
    obj.set("src", hitValue.extra);
    obj.set("url", hitValue.extra);
    obj.set("title", hitValue.type);

    return obj;
  }

  public createCompatWebMessageChannel(): WebMessageChannel {
    let id: string = util.generateRandomUUID(true).toString();
    let webMessageChannel: WebMessageChannel = new WebMessageChannel(id, this);
    this.webMessageChannels.set(id, webMessageChannel);
    return webMessageChannel;
  }

  public addWebMessageListener(webMessageListener: WebMessageListener): void {
    //TODO
    // if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
    //   WebViewCompat.addWebMessageListener(this, webMessageListener.jsObjectName, webMessageListener.allowedOriginRules, webMessageListener.listener);
    //   webMessageListeners.add(webMessageListener);
    // }
  }

  public canScrollVertically(): boolean {
    return this.controller.getPageHeight() > this.viewHeight;
  }

  public canScrollHorizontally(callback: ValueCallback<boolean>) {
    this.controller.runJavaScriptExt("document.documentElement.scrollWidth;").then(result => {
      callback.onReceiveValue(result.getNumber() > this.viewWidth)
    })
  }

  public isInFullscreen(): boolean {
    return this.inFullscreen;
  }

  setInFullscreen(inFullscreen: boolean) {
    this.inFullscreen = inFullscreen;
  }

  public getPlugin(): InAppWebViewFlutterPlugin {
    return this.plugin;
  }

  public getWebMessageChannels(): Map<string, WebMessageChannel> {
    return this.webMessageChannels;
  }

  public getUserContentController(): UserContentController {
    return this.userContentController;
  }

  public onControllerAttached = () => {
    Log.d(TAG, "onControllerAttached");
    this.controllerAttached = true
  }

  onAreaChange = (oldValue: Area, newValue: Area) => {
    this.viewWidth = newValue.width as number;
    this.viewHeight = newValue.height as number;
  }

  toWebHeaders(headers: Map<string, string>): Array<web_webview.WebHeader> {
    let result: Array<web_webview.WebHeader> = new Array;
    if (headers == null || headers.size == 0) {
      return result;
    }
    for (let arr of headers) {
      let key = arr[0];
      let value = arr[1];
      let header: web_webview.WebHeader = {
        headerKey: key, headerValue: value
      };
      result.push(header);
    }
    return result;
  }

  private async waitControllerAttached() {
    if (!this.controllerAttached) {
      await this.checkControllerAttached()
    }
  }

  private checkControllerAttached(): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        let intervalId = setInterval(() => {
          if (this.controllerAttached) {
            clearInterval(intervalId)
            resolve()
          }
        }, 20)
      } catch (err) {
        reject()
      }
    })
  }

  isDebuggingEnabled() {
    return this.plugin.inAppWebViewManager!.debuggingEnabled
  }

  disposeWebMessageChannels(): void {
    for (let webMessageChannel of this.webMessageChannels.values()) {
      webMessageChannel.dispose();
    }
    this.webMessageChannels.clear();
  }

  hideContextMenu() {
    // TODO
    // removeView(floatingContextMenu);
    // this.floatingContextMenu = null;

    if (this.channelDelegate != null) this.channelDelegate.onHideContextMenu();
  }

  public getSelectedText(resultCallback: ValueCallback<string>): void {
    this.controller.runJavaScriptExt(PluginScriptsUtil.GET_SELECTED_TEXT_JS_SOURCE).then((result) => {
      resultCallback.onReceiveValue(result.getString())
    })
  }

  callAsyncJavaScript(functionBody: string, args: Map<string, Any>, contentWorld: ContentWorld | null, resultCallback: ValueCallback<string>) {
    let resultUuid = util.generateRandomUUID(true);
    if (resultCallback != null) {
      this.callAsyncJavaScriptCallbacks.set(resultUuid, resultCallback);
    }

    let keys = args.keys();

    let functionArgumentNamesList = new Array<string>();
    let functionArgumentValuesList = new Array<string>();
    for (let key of keys) {
      functionArgumentNamesList.push(key);
      functionArgumentValuesList.push("obj." + key);
    }

    let functionArgumentNames = functionArgumentNamesList.join(", ");
    let functionArgumentValues = functionArgumentValuesList.join(", ");
    let functionArgumentsObj = JSON.stringify(args);

    let sourceToInject = PluginScriptsUtil.CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES, functionArgumentNames)
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES, functionArgumentValues)
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ, functionArgumentsObj)
      .replace(PluginScriptsUtil.VAR_FUNCTION_BODY, functionBody)
      .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)
      .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid);

    sourceToInject = this.userContentController.generateCodeForScriptEvaluation(sourceToInject, contentWorld);
    this.controller.runJavaScriptExt(sourceToInject, null);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(buildOhosWebView)
  }

  private onSettinsUpdated() {
    this.ohosWebViewModel!.params['domStorageAccess'] = this.customSettings.domStorageAccess;
    this.ohosWebViewModel!.params['fileAccess'] = this.customSettings.fileAccess;
    this.ohosWebViewModel!.params['imageAccess'] = this.customSettings.imageAccess;
    this.ohosWebViewModel!.params['javaScriptAccess'] = this.customSettings.javaScriptAccess;
    this.ohosWebViewModel!.params['overScrollMode'] = this.customSettings.overScrollMode;
    this.ohosWebViewModel!.params['mixedMode'] = this.customSettings.mixedMode;
    this.ohosWebViewModel!.params['onlineImageAccess'] = this.customSettings.onlineImageAccess;
    this.ohosWebViewModel!.params['zoomAccess'] = this.customSettings.zoomAccess;
    this.ohosWebViewModel!.params['overviewModeAccess'] = this.customSettings.overviewModeAccess;
    this.ohosWebViewModel!.params['databaseAccess'] = this.customSettings.databaseAccess;
    this.ohosWebViewModel!.params['geolocationAccess'] = this.customSettings.geolocationAccess;
    this.ohosWebViewModel!.params['mediaPlayGestureAccess'] = this.customSettings.mediaPlayGestureAccess;
    this.ohosWebViewModel!.params['multiWindowAccess'] = this.customSettings.multiWindowAccess;
    this.ohosWebViewModel!.params['horizontalScrollBarAccess'] = this.customSettings.horizontalScrollBarAccess;
    this.ohosWebViewModel!.params['verticalScrollBarAccess'] = this.customSettings.verticalScrollBarAccess;
    this.ohosWebViewModel!.params['cacheMode'] = this.customSettings.cacheMode;
    this.ohosWebViewModel!.params['textZoomRatio'] = this.customSettings.textZoomRatio;
    this.ohosWebViewModel!.params['initialScale'] = this.customSettings.initialScale;
    this.ohosWebViewModel!.params['blockNetwork'] = this.customSettings.blockNetwork;
    this.ohosWebViewModel!.params['defaultFixedFontSize'] = this.customSettings.defaultFixedFontSize;
    this.ohosWebViewModel!.params['defaultFontSize'] = this.customSettings.defaultFontSize;
    this.ohosWebViewModel!.params['minFontSize'] = this.customSettings.minFontSize;
    this.ohosWebViewModel!.params['minLogicalFontSize'] = this.customSettings.minLogicalFontSize;
    this.ohosWebViewModel!.params['webFixedFont'] = this.customSettings.webFixedFont;
    this.ohosWebViewModel!.params['webSansSerifFont'] = this.customSettings.webSansSerifFont;
    this.ohosWebViewModel!.params['webSerifFont'] = this.customSettings.webSerifFont;
    this.ohosWebViewModel!.params['webStandardFont'] = this.customSettings.webStandardFont;
    this.ohosWebViewModel!.params['webFantasyFont'] = this.customSettings.webFantasyFont;
    this.ohosWebViewModel!.params['webCursiveFont'] = this.customSettings.webCursiveFont;
    this.ohosWebViewModel!.params['darkMode'] = this.customSettings.darkMode;
    this.ohosWebViewModel!.params['forceDarkAccess'] = this.customSettings.forceDarkAccess;
    this.ohosWebViewModel!.params['pinchSmooth'] = this.customSettings.pinchSmooth;
    this.ohosWebViewModel!.params['allowWindowOpenMethod'] = this.customSettings.allowWindowOpenMethod;
    this.ohosWebViewModel!.params['layoutMode'] = this.customSettings.layoutMode;
    this.ohosWebViewModel!.params['enableNativeEmbedMode'] = this.customSettings.enableNativeEmbedMode;
  }
}