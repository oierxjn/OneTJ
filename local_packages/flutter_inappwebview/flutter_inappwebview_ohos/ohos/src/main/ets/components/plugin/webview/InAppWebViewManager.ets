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

import { MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView'
import { DVModel, DVModelParameters } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';
import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import ChannelDelegateImpl from '../types/ChannelDelegateImpl';
import { FlutterWebView } from './in_app_webview/FlutterWebView';
import { Context } from '@kit.AbilityKit';
import web_webview from '@ohos.web.webview';
import business_error from '@ohos.base';

const LOG_TAG = "InAppWebViewManager"
const METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_manager"

export class InAppWebViewManager extends ChannelDelegateImpl {

  private plugin: InAppWebViewFlutterPlugin | null = null

  public keepAliveWebViews: Map<string, FlutterWebView | undefined> = new Map<string, FlutterWebView | undefined>()

  public controller: web_webview.WebviewController = new web_webview.WebviewController();

  public windowWebViewMessages: Map<number, ControllerHandler> = new Map<number, ControllerHandler>()

  public windowAutoincrementId: number = 0

  public debuggingEnabled = false;

  constructor(plugin: InAppWebViewFlutterPlugin) {
    super(new MethodChannel(plugin.messenger!, METHOD_CHANNEL_NAME));
    this.plugin = plugin
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "getDefaultUserAgent":
        if (this.plugin != null) {
          result.success(this.controller.getUserAgent());
        } else {
          result.success(null);
        }
        break;
      case "clearClientCertPreferences":
        try{
          this.controller.clearClientAuthenticationCache();
          result.success(true);
        } catch (error) {
          let e: business_error.BusinessError = error as business_error.BusinessError;
          console.error(`ErrorCode: ${e.code},  Message: ${e.message}`);
          result.success(false);
        }
        break;
      case "getSafeBrowsingPrivacyPolicyUrl":
      /// 返回指向安全浏览报告的隐私策略的URL。
        result.success(null);
        break;
      case "setSafeBrowsingAllowlist":
      /// 配置一组免于安全浏览检查的主机（域名/IP地址）
      /// ohos非法和欺诈网站是强制启用的
      /// 目前还未找到实现方法
        result.success(false);
        break;
      case "getCurrentWebViewPackage":
      // {
      //   Context context = null;
      //   if (plugin != null) {
      //     context = plugin.activity;
      //     if (context == null) {
      //       context = plugin.applicationContext;
      //     }
      //   }
      //   PackageInfo packageInfo = context != null ? WebViewCompat.getCurrentWebViewPackage(context) : null;
      //   result.success(packageInfo != null ? convertWebViewPackageToMap(packageInfo) : null);
      // }
        break;
      case "setWebContentsDebuggingEnabled":
        {
          this.debuggingEnabled = call.argument("debuggingEnabled") as boolean;
          web_webview.WebviewController.setWebDebuggingAccess(this.debuggingEnabled)
        }
        result.success(true);
        break;
      case "getVariationsHeader":
      /// 获取编码后用作X-Client-Data HTTP标头的WebView变体，未找到实现
        result.success(null);
        break;
      case "isMultiProcessEnabled":
      /// 监测WebView是否在多进程模式下运行，未找到对应实现
        result.success(false);
        break;
      case "disableWebView":
        this.controller.stop()
        result.success(true);
        break;
      case "disposeKeepAlive":
        let keepAliveId: string = call.argument("keepAliveId") as string;
        if (keepAliveId != null) {
          this.disposeKeepAlive(keepAliveId);
        }
        result.success(true);
        break;
      case "clearAllCache":
      // {
      //   Context context = null;
      //   if (plugin != null) {
      //     context = plugin.activity;
      //     if (context == null) {
      //       context = plugin.applicationContext;
      //     }
      //     if (context != null) {
      //       boolean includeDiskFiles = (boolean) call.argument("includeDiskFiles");
      //       clearAllCache(context, includeDiskFiles);
      //     }
      //   }
      // }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  // public convertWebViewPackageToMap(webViewPackageInfo: PackageInfo): Map<string, Any> {
  //   let webViewPackageInfoMap: Map<string, Any> = new Map<string, Any>()
  //
  //   webViewPackageInfoMap.set("versionName", webViewPackageInfo.versionName);
  //   webViewPackageInfoMap.set("packageName", webViewPackageInfo.packageName);
  //
  //   return webViewPackageInfoMap;
  // }

  public disposeKeepAlive(keepAliveId: string): void {
    let flutterWebView: FlutterWebView | undefined = this.keepAliveWebViews.get(keepAliveId)
    if (flutterWebView != null) {
      flutterWebView.keepAliveId = null;
      // be sure to remove the view from the previous parent.
      let view: WrappedBuilder<[Params]> = flutterWebView.getView();
      if (view != null) {
        // let parent: ViewGroup = view.getParent();
        // if (parent != null) {
        //   parent.removeView(view);
        // }
      }
      flutterWebView.dispose();
    }
    let containsKey: boolean = true
    for(let key of this.keepAliveWebViews.keys()) {
      if(key == keepAliveId) {
        containsKey = false
      }
    }
    if (containsKey) {
      this.keepAliveWebViews.set(keepAliveId, undefined);
    }
  }

  public clearAllCache(context: Context, includeDiskFiles: boolean): void {
    // let tempWebView: WebView = new WebView(context)
    // tempWebView.clearCache(includeDiskFiles);
    // tempWebView.destroy();
  }

  public dispose(): void {
    super.dispose();
    // let flutterWebViews: Collection<FlutterWebView> = this.keepAliveWebViews.values()
    // for (let flutterWebView: FlutterWebView of flutterWebViews) {
    //   let keepAliveId: string = flutterWebView.keepAliveId;
    //   if (keepAliveId != null) {
    //     this.disposeKeepAlive(flutterWebView.keepAliveId);
    //   }
    // }
    this.keepAliveWebViews.clear();
    this.windowWebViewMessages.clear();
    this.plugin = null;
  }
}