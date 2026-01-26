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
import common from '@ohos.app.ability.common';
import { Any } from '@ohos/flutter_ohos'
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView'
import { FlutterWebView } from './FlutterWebView'
import InAppWebView from './InAppWebView'
import EventConstant from '../../EventConstant'
import { JSON, List } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct OhosWebView {
  @Prop params: Params;
  controller: web_webview.WebviewController = new web_webview.WebviewController()
  schemeHandler: web_webview.WebSchemeHandler = new web_webview.WebSchemeHandler();
  static readonly schemeArray = [
    'snssdk1128',
    'sinaweibo',
    'xhsdiscover',
    'bilibili',
    'kwai',
    'weixin',
    'mqqapi',
    'alipays',
    'upwallet',
    'openapp.jdmobile',
    'imeituan',
    'pinduoduo',
    'tbopen',
    'amapuri',
    'wemeet'
  ];
  inAppWebView: InAppWebView | null = null
  @State isRefreshing: boolean = false
  @State isEnableRefresh: boolean = false
  @State startScripts: Array<ScriptItem> = [];
  @State cacheEnabled: boolean = true

  aboutToAppear(): void {
    this.isEnableRefresh = this.inAppWebView!.getPullToRefreshLayout().settings.enabled;
    this.cacheEnabled = this.inAppWebView!.customSettings.cacheEnabled;
    this.startScripts = this.inAppWebView!.userContentController.getStartScripts()
    let context = getContext() as common.UIAbilityContext;
    context.eventHub.on(EventConstant.EVENT_PULL_SETREFRESHING, (refreshing : boolean) => {
      this.isRefreshing = refreshing;
    });

    context.eventHub.on(EventConstant.EVENT_UPDATE_STARTSCRIPTS, (scripts : Array<ScriptItem>) => {
      this.startScripts = scripts;
    });

    context.eventHub.on(EventConstant.EVENT_UPDATE_CACHEENABLE, (enable : boolean) => {
      this.cacheEnabled = enable;
    });

    //不知道为什么这个静态方法必须要在aboutToAppear里面设置才能生效？
    web_webview.WebviewController.setWebDebuggingAccess(this.inAppWebView!.isDebuggingEnabled());
  }

  aboutToDisappear(): void {
    let context = getContext() as common.UIAbilityContext;
    context.eventHub.off(EventConstant.EVENT_PULL_SETREFRESHING);
    context.eventHub.off(EventConstant.EVENT_UPDATE_STARTSCRIPTS);
  }

  build() {
    Column() {
      if (this.isEnableRefresh) {
        Refresh({ refreshing: $$this.isRefreshing }) {
          this.buildWeb()
        }
        .onStateChange((refreshStatus: RefreshStatus) => {
          console.info('Refresh onStatueChange state is ' + refreshStatus)
        })
        .onRefreshing(() => {
          this.inAppWebView!.getPullToRefreshLayout().onRefresh()
        })
      } else {
        this.buildWeb()
      }
    }
  }

  @Builder
  buildWeb() {
    Web(
      {
        src: this.inAppWebView?.getLoadUrl(),
        controller: this.controller
      })
      .keyboardAvoidMode(WebKeyboardAvoidMode.RESIZE_VISUAL)
      .onControllerAttached(()=>{
        this.setPathAllowingUniversalAccess()
        this.inAppWebView!.onControllerAttached()
        this.setWebSchemeHandler();
      })
      .onAlert(this.inAppWebView!.inAppWebViewClient?.onAlert)
      .onBeforeUnload(this.inAppWebView!.inAppWebViewClient?.onBeforeUnload)
      .onConfirm(this.inAppWebView!.inAppWebViewClient?.onConfirm)
      .onPrompt((event) => {
        return this.inAppWebView!.inAppWebViewClient?.onPrompt(event, this)
      })
      .onConsole(this.inAppWebView!.inAppWebViewClient?.onConsole)
      .onDownloadStart(this.inAppWebView!.inAppWebViewClient?.onDownloadStart)
      .onErrorReceive(this.inAppWebView!.inAppWebViewClient?.onErrorReceive)
      .onHttpErrorReceive(this.inAppWebView!.inAppWebViewClient?.onHttpErrorReceive)
      .onPageBegin(this.inAppWebView!.inAppWebViewClient?.onPageBegin)
      .onPageEnd(this.inAppWebView!.inAppWebViewClient?.onPageEnd)
      .onProgressChange(this.inAppWebView!.inAppWebViewClient?.onProgressChange)
      .onTitleReceive(this.inAppWebView!.inAppWebViewClient?.onTitleReceive)
      .onRefreshAccessedHistory(this.inAppWebView!.inAppWebViewClient?.onRefreshAccessedHistory)
      .onRenderExited(this.inAppWebView!.inAppWebViewClient?.onRenderExited)
      .onShowFileSelector(this.inAppWebView!.inAppWebViewClient?.onShowFileSelector)
      .onResourceLoad(this.inAppWebView!.inAppWebViewClient?.onResourceLoad)
      .onScaleChange(this.inAppWebView!.inAppWebViewClient?.onScaleChange)
      .onInterceptRequest((event) => {
        return this.inAppWebView!.inAppWebViewClient?.onInterceptRequest(event)
      })
      .onHttpAuthRequest(this.inAppWebView!.inAppWebViewClient?.onHttpAuthRequest)
      .onSslErrorEventReceive(this.inAppWebView!.inAppWebViewClient?.onSslErrorEventReceive)
      .onClientAuthenticationRequest(this.inAppWebView!.inAppWebViewClient?.onClientAuthenticationRequest)
      .onPermissionRequest(this.inAppWebView!.inAppWebViewClient?.onPermissionRequest)
      .onContextMenuShow(this.inAppWebView!.inAppWebViewClient?.onContextMenuShow)
      .onContextMenuHide(this.inAppWebView!.inAppWebViewClient?.onContextMenuHide)
      .onScroll(this.inAppWebView!.inAppWebViewClient?.onScroll)
      .onGeolocationShow(this.inAppWebView!.inAppWebViewClient?.onGeolocationShow)
      .onGeolocationHide(this.inAppWebView!.inAppWebViewClient?.onGeolocationHide)
      .onFullScreenEnter(this.inAppWebView!.inAppWebViewClient?.onFullScreenEnter)
      .onFullScreenExit(this.inAppWebView!.inAppWebViewClient?.onFullScreenExit)
      .onWindowNew(this.inAppWebView!.inAppWebViewClient?.onWindowNew)
      .onWindowExit(this.inAppWebView!.inAppWebViewClient?.onWindowExit)
      .onSearchResultReceive(this.inAppWebView!.inAppWebViewClient?.onSearchResultReceive)
      .onDataResubmitted(this.inAppWebView!.inAppWebViewClient?.onDataResubmitted)
      .onPageVisible(this.inAppWebView!.inAppWebViewClient?.onPageVisible)
      .onInterceptKeyEvent(this.inAppWebView!.inAppWebViewClient?.onInterceptKeyEvent)
      .onTouchIconUrlReceived(this.inAppWebView!.inAppWebViewClient?.onTouchIconUrlReceived)
      .onFaviconReceived(this.inAppWebView!.inAppWebViewClient?.onFaviconReceived)
      .onAudioStateChanged(this.inAppWebView!.inAppWebViewClient?.onAudioStateChanged)
      .onFirstContentfulPaint(this.inAppWebView!.inAppWebViewClient?.onFirstContentfulPaint)
      .onLoadIntercept(this.inAppWebView!.inAppWebViewClient?.onLoadIntercept)
      .onOverrideUrlLoading(this.inAppWebView!.inAppWebViewClient?.onOverrideUrlLoading)
      .onRequestSelected(this.inAppWebView!.inAppWebViewClient?.onRequestSelected)
      .onScreenCaptureRequest(this.inAppWebView!.inAppWebViewClient?.onScreenCaptureRequest)
      .onOverScroll(this.inAppWebView!.inAppWebViewClient?.onOverScroll)
      .onNavigationEntryCommitted(this.inAppWebView!.inAppWebViewClient?.onNavigationEntryCommitted)
      .onSafeBrowsingCheckResult(this.inAppWebView!.inAppWebViewClient?.onSafeBrowsingCheckResult)
      .onNativeEmbedLifecycleChange(this.inAppWebView!.inAppWebViewClient?.onNativeEmbedLifecycleChange)
      .onNativeEmbedGestureEvent(this.inAppWebView!.inAppWebViewClient?.onNativeEmbedGestureEvent)
      .onRenderProcessNotResponding(this.inAppWebView!.inAppWebViewClient?.onRenderProcessNotResponding)
      .onRenderProcessResponding(this.inAppWebView!.inAppWebViewClient?.onRenderProcessResponding)
      .onAreaChange(this.inAppWebView!.onAreaChange)
      .domStorageAccess(this.inAppWebView!.customSettings.domStorageAccess)
      .fileAccess(this.inAppWebView!.customSettings.fileAccess)
      .imageAccess(this.inAppWebView!.customSettings.imageAccess)
      .javaScriptAccess(this.inAppWebView!.customSettings.javaScriptAccess)
      .overScrollMode(this.inAppWebView!.customSettings.overScrollMode)
      .mixedMode(this.inAppWebView!.customSettings.mixedMode)
      .onlineImageAccess(this.inAppWebView!.customSettings.onlineImageAccess)
      .zoomAccess(this.inAppWebView!.customSettings.zoomAccess)
      .overviewModeAccess(this.inAppWebView!.customSettings.overviewModeAccess)
      .databaseAccess(this.inAppWebView!.customSettings.databaseAccess)
      .geolocationAccess(this.inAppWebView!.customSettings.geolocationAccess)
      .mediaPlayGestureAccess(this.inAppWebView!.customSettings.mediaPlayGestureAccess)
      .multiWindowAccess(this.inAppWebView!.customSettings.multiWindowAccess)
      .horizontalScrollBarAccess(this.inAppWebView!.customSettings.horizontalScrollBarAccess)
      .verticalScrollBarAccess(this.inAppWebView!.customSettings.verticalScrollBarAccess)
      .cacheMode(this.cacheEnabled ? this.inAppWebView!.customSettings.cacheMode : CacheMode.Online)
      .textZoomRatio(this.inAppWebView!.customSettings.textZoomRatio)
      .initialScale(this.inAppWebView!.customSettings.initialScale)
      .blockNetwork(this.inAppWebView!.customSettings.blockNetwork)
      .defaultFixedFontSize(this.inAppWebView!.customSettings.defaultFixedFontSize)
      .defaultFontSize(this.inAppWebView!.customSettings.defaultFontSize)
      .minFontSize(this.inAppWebView!.customSettings.minFontSize)
      .minLogicalFontSize(this.inAppWebView!.customSettings.minLogicalFontSize)
      .webFixedFont(this.inAppWebView!.customSettings.webFixedFont)
      .webSansSerifFont(this.inAppWebView!.customSettings.webSansSerifFont)
      .webSerifFont(this.inAppWebView!.customSettings.webSerifFont)
      .webStandardFont(this.inAppWebView!.customSettings.webStandardFont)
      .webFantasyFont(this.inAppWebView!.customSettings.webFantasyFont)
      .webCursiveFont(this.inAppWebView!.customSettings.webCursiveFont)
      .darkMode(this.inAppWebView!.customSettings.darkMode)
      .forceDarkAccess(this.inAppWebView!.customSettings.forceDarkAccess)
      .pinchSmooth(this.inAppWebView!.customSettings.pinchSmooth)
      .allowWindowOpenMethod(this.inAppWebView!.customSettings.allowWindowOpenMethod)
      .layoutMode(this.inAppWebView!.customSettings.layoutMode)
      .enableNativeEmbedMode(this.inAppWebView!.customSettings.enableNativeEmbedMode)
      .javaScriptOnDocumentStart(this.startScripts)
      .backgroundColor(this.inAppWebView!.customSettings.transparentBackground ? Color.Transparent : Color.White)
  }

  private  setPathAllowingUniversalAccess(){
    if(this.inAppWebView!.customSettings.allowFileAccessFromFileURLs){
      try {
        const appFilesDirPath = `${getContext().getApplicationContext().filesDir}/flutter`
        const filesDirPath = `${getContext().filesDir}/flutter`
        const resourceDirPath = this.getUIContext().getHostContext()?.resourceDir;
        const accessList = new List<string>()
        accessList.add(appFilesDirPath)
        accessList.add(filesDirPath)
        if(resourceDirPath){
          accessList.add(resourceDirPath)
        }
        this.controller.setPathAllowingUniversalAccess(accessList.convertToArray())
      }catch (error) {
        console.info(`setPathAllowingUniversalAccess error Code：${(error as BusinessError).code} ; msg：${(error as BusinessError).message}`)
      }
    }
  }

  private setWebSchemeHandler() {
    this.schemeHandler.onRequestStart((request: web_webview.WebSchemeHandlerRequest,
      resourceHandler: web_webview.WebResourceHandler) => {
      return true;
    })
    for (let scheme of OhosWebView.schemeArray) {
      this.controller.setWebSchemeHandler(scheme, this.schemeHandler);
    }
  }
}

@Builder
export function buildOhosWebView(params: Params) {
  OhosWebView({
    params: params,
    controller: (params.platformView as FlutterWebView).getController(),
    inAppWebView: (params.platformView as FlutterWebView).getWebView()
  }).backgroundColor(Color.Transparent)
}