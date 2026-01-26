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

import { Any, Log } from '@ohos/flutter_ohos';
import web_webview from '@ohos.web.webview';
import cameraPicker from '@ohos.multimedia.cameraPicker';
import picker from '@ohos.file.picker';
import uri from '@ohos.uri'
import InAppWebViewFlutterPlugin from '../../InAppWebViewFlutterPlugin';
import DownloadStartRequest from '../../types/DownloadStartRequest';
import URLUtil from '../../types/URLUtil';
import InAppWebView from './InAppWebView';
import WebResourceResponseExt from '../../types/WebResourceResponseExt';
import CustomSchemeResponse from '../../types/CustomSchemeResponse';
import WebResourceRequestExt from '../../types/WebResourceRequestExt';
import URLRequest from '../../types/URLRequest';
import NavigationAction from '../../types/NavigationAction';
import { NavigationActionPolicy } from '../../types/NavigationActionPolicy';
import URLCredential from '../../types/URLCredential';
import JavaScriptBridgeJS from '../../plugin_scripts_js/JavaScriptBridgeJS';
import { image } from '@kit.ImageKit';
import { InAppBrowserDelegate } from '../../in_app_browser/InAppBrowserDelegate';
import WebResourceErrorExt from '../../types/WebResourceErrorExt';
import Util from '../../Util';
import {
  GeolocationPermissionsShowPromptCallback,
  JsAlertCallback,
  JsBeforeUnloadCallback,
  JsConfirmCallback,
  JsPromptCallback,
  PermissionRequestCallback,
  ReceivedHttpAuthRequestCallback,
  ReceivedServerTrustAuthRequestCallback,
  ReceivedClientCertRequestCallback,
  CreateWindowCallback,
  FormResubmissionCallback,
  ShouldOverrideUrlLoadingCallback,
  SafeBrowsingHitCallback,
  RenderProcessUnresponsiveCallback,
  RenderProcessResponsiveCallback
} from '../WebViewChannelDelegate';
import JsAlertResponse from '../../types/JsAlertResponse';
import JsConfirmResponse from '../../types/JsConfirmResponse';
import JsPromptResponse from '../../types/JsPromptResponse';
import HttpAuthResponse from '../../types/HttpAuthResponse';
import { ohosPromptDialogBuilder } from './OhosPromptDialog';
import { promptAction } from '@kit.ArkUI';
import JsBeforeUnloadResponse from '../../types/JsBeforeUnloadResponse';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import MimeTypes from '../../MimeTypes';
import PermissionResponse from '../../types/PermissionResponse';
import GeolocationPermissionShowPromptResponse from '../../types/GeolocationPermissionShowPromptResponse';
import CredentialDatabase from '../../credential_database/CredentialDatabase';
import HttpAuthenticationChallenge from '../../types/HttpAuthenticationChallenge';
import URLProtectionSpace from '../../types/URLProtectionSpace';
import ServerTrustAuthResponse from '../../types/ServerTrustAuthResponse';
import ServerTrustChallenge from '../../types/ServerTrustChallenge';
import ClientCertChallenge from '../../types/ClientCertChallenge';
import ClientCertResponse from '../../types/ClientCertResponse';
import CreateWindowAction from '../../types/CreateWindowAction';
import SafeBrowsingResponse from '../../types/SafeBrowsingResponse';
import { cert } from '@kit.DeviceCertificateKit'
import { ArrayList, List, util  } from '@kit.ArkTS';
import { common, Permissions,bundleManager,abilityAccessCtrl } from '@kit.AbilityKit';

const TAG = "InAppWebViewClient";

// 参考文档 所有事件 https://docs.openharmony.cn/pages/v4.1/zh-cn/application-dev/reference/apis-arkweb/ts-basic-components-web.md#onalert
export default class InAppWebViewClient {
  public static previousAuthRequestFailureCount = 0;
  public static credentialsProposed: List<URLCredential> | null = null;
  private plugin: InAppWebViewFlutterPlugin;
  private inAppWebView: InAppWebView;
  private inAppBrowserDelegate: InAppBrowserDelegate | null = null;
  private fullScreenExitHandler: FullScreenExitHandler | null = null;
  private isOriginalLayoutFullScreen = false;
  private isOriginalFullScreen = false;
  public progress = 0;
  private permissionValues: Map<string, Permissions> = new Map([
    [ProtectedResourceType.VIDEO_CAPTURE, 'ohos.permission.CAMERA'],// 视频捕获资源，例如相机。
    [ProtectedResourceType.AUDIO_CAPTURE, 'ohos.permission.MICROPHONE'],// 音频捕获资源，例如麦克风。
  // [ProtectedResourceType.MidiSysex, 'ohos.permission.MIDI_SYSEX'],// MIDI SYSEX资源
  // [ProtectedResourceType.SENSOR, 'ohos.permission.SENSOR'] // 传感器资源，例如加速度传感器。
  ]);

  constructor(plugin: InAppWebViewFlutterPlugin, inAppWebView: InAppWebView) {
    this.plugin = plugin;
    this.inAppWebView = inAppWebView;
  }

  onAlert = (event: Any) => {
    Log.d(TAG, "onAlert=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onJsAlert(event.url, event.message, null,
        new InnerJsAlertCallback(event.result, event.message));
      return true;
    }
    return false;
  }
  onBeforeUnload = (event: Any) => {
    Log.d(TAG, "onBeforeUnload=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onJsBeforeUnload(event.url, event.message,
        new InnerJsBeforeUnloadCallback(event.result, event.message));
      return true;
    }
    return false;
  }
  onConfirm = (event: Any) => {
    Log.d(TAG, "onConfirm=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onJsConfirm(event.url, event.message, null,
        new InnerJsConfirmCallback(event.result, event.message));
      return true;
    }
    return false;
  }
  onPrompt = (event: Any, uiObject: Any) => {
    Log.d(TAG, "onPrompt=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onJsPrompt(event.url, event.message, event.value, null,
        new InnerJsPromptCallback(event.result, event.message, event.value, uiObject));
      return true;
    }
    return false;
  }
  onConsole = (event: Any) => {
    Log.d(TAG, "onConsole=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onConsoleMessage(event.message.getMessage(), event.message.getMessageLevel());
      return true;
    }
    return false;
  }
  onDownloadStart = (event: Any) => { //对应安卓setDownloadListener
    Log.d(TAG, "onDownloadStart=" + JSON.stringify(event))
    if (this.inAppWebView.customSettings.useOnDownloadStart) {
      let downloadStartRequest = new DownloadStartRequest(
        event.url,
        event.userAgent,
        event.contentDisposition,
        event.mimetype,
        event.contentLength,
        URLUtil.guessFileName(event.url, event.contentDisposition, event.mimetype),
        null
      );
      this.inAppWebView.channelDelegate?.onDownloadStartRequest(downloadStartRequest)
    }
  }
  onErrorReceive = (event: Any) => {
    Log.d(TAG, "onErrorReceive=" + JSON.stringify(event))
    let request: WebResourceRequest = event.request;
    let error: WebResourceError = event.error;
    if (request.isMainFrame()) {
      if (this.inAppWebView.customSettings.disableDefaultErrorPage) {
        this.inAppWebView.stopLoading();
        this.inAppWebView.controller.loadUrl("about:blank");
      }

      this.inAppWebView.isLoading = false;
      InAppWebViewClient.previousAuthRequestFailureCount = 0;
      InAppWebViewClient.credentialsProposed = null;

      if (this.inAppBrowserDelegate != null) {
        let type = error.getErrorCode();
        let description = error.getErrorInfo();
        this.inAppBrowserDelegate.didFailNavigation(request.getRequestUrl(), type, description);
      }
    }
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedError(
        WebResourceRequestExt.fromWebResourceRequest(request),
        WebResourceErrorExt.fromWebResourceError(error));
    }
  }
  onHttpErrorReceive = (event: Any) => {
    Log.d(TAG, "onHttpErrorReceive=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedHttpError(
        WebResourceRequestExt.fromWebResourceRequest(event.request),
        WebResourceResponseExt.fromWebResourceResponse(event.response));
    }
  }
  onPageBegin = (event: Any) => {
    Log.d(TAG, "onPageBegin=" + JSON.stringify(event))
    this.inAppWebView.isLoading = true;
    this.inAppWebView.disposeWebMessageChannels();
    this.inAppWebView.userContentController.resetContentWorlds();
    this.loadCustomJavaScriptOnPageStarted(this.inAppWebView);

    if (this.inAppBrowserDelegate != null) {
      this.inAppBrowserDelegate.didStartNavigation(event.url);
    }

    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onLoadStart(event.url);
    }
  }
  onPageEnd = (event: Any) => {
    Log.d(TAG, "onPageEnd=" + JSON.stringify(event))
    this.inAppWebView.isLoading = false;
    this.loadCustomJavaScriptOnPageFinished(this.inAppWebView);
    InAppWebViewClient.previousAuthRequestFailureCount = 0;
    InAppWebViewClient.credentialsProposed = null;

    if (this.inAppBrowserDelegate != null) {
      this.inAppBrowserDelegate.didFinishNavigation(event.url);
    }

    web_webview.WebCookieManager.saveCookieAsync()

    let js = JavaScriptBridgeJS.PLATFORM_READY_JS_SOURCE;
    this.inAppWebView.controller.runJavaScriptExt(js)

    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onLoadStop(event.url);
    }
  }
  onProgressChange = (event: Any) => {
    Log.d(TAG, "onProgressChange=" + JSON.stringify(event))
    if (this.inAppBrowserDelegate != null) {
      this.inAppBrowserDelegate.didChangeProgress(event.newProgress);
    }

    this.progress = event.newProgress
    this.loadCustomJavaScriptOnPageStarted(this.inAppWebView);

    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onProgressChanged(event.newProgress);
    }
  }
  onTitleReceive = (event: Any) => {
    Log.d(TAG, "onTitleReceive=" + JSON.stringify(event))
    if (this.inAppBrowserDelegate != null) {
      this.inAppBrowserDelegate.didChangeTitle(event.title);
    }
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onTitleChanged(event.title);
    }
  }
  onRefreshAccessedHistory = (event: Any) => {
    Log.d(TAG, "onRefreshAccessedHistory=" + JSON.stringify(event))
    if (this.inAppBrowserDelegate != null) {
      this.inAppBrowserDelegate.didUpdateVisitedHistory(event.url);
    }
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onUpdateVisitedHistory(event.url, event.isRefreshed);
    }
  }
  onRenderExited = (event: Any) => {
    Log.d(TAG, "onRenderExited=" + JSON.stringify(event))
    if (this.inAppWebView.customSettings.useOnRenderProcessGone && this.inAppWebView.channelDelegate != null) {
      let didCrash = event.renderExitReason == RenderExitReason.ProcessCrashed;
      this.inAppWebView.channelDelegate.onRenderProcessGone(didCrash, event.renderExitReason);
    }
  }
  onShowFileSelector = (event: Any) => {
    Log.d(TAG, "onShowFileSelector=" + JSON.stringify(event))
    Log.d(TAG, "onShowFileSelector=" + JSON.stringify(event.fileSelector))
    let acceptTypes: Array<string> = event.fileSelector.getAcceptType();
    let allowMultiple = event.fileSelector.getMode() == FileSelectorMode.FileOpenMultipleMode;
    let captureEnabled: boolean = event.fileSelector.isCapture();
    let images = this.acceptsImages(acceptTypes);
    let video = this.acceptsVideo(acceptTypes);
    if (captureEnabled) {
      if (!this.needsCameraPermission()) {
        if (images || video) {
          let pickerProfile: cameraPicker.PickerProfile = {
            cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
          };
          cameraPicker.pick(this.inAppWebView.context,
            images ? [cameraPicker.PickerMediaType.PHOTO] : [cameraPicker.PickerMediaType.VIDEO], pickerProfile)
            .then(result => {
              event.result.handleFileList([result.resultUri]);
            }).catch((err: BusinessError) => {
            event.result.handleFileList([]);
            Log.e(TAG, `the pick call failed. error code: ${err.code}`);
          });
          return true;
        }
      }
    }

    return false;
  }
  onResourceLoad = (event: Any) => {
    // TODO 没有找到安卓对于方法
    Log.d(TAG, "onResourceLoad=" + JSON.stringify(event))
  }
  onScaleChange = (event: Any) => {
    Log.d(TAG, "onScaleChange=" + JSON.stringify(event))
    this.inAppWebView.zoomScale = event.newScale / Util.getPixelDensity();

    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onZoomScaleChanged(event.oldScale, event.newScale);
    }
  }
  onInterceptRequest = (event: Any) => { //对应安卓shouldInterceptRequest
    let request = WebResourceRequestExt.fromWebResourceRequest(event.request);
    Log.d(TAG, "onInterceptRequest=" + JSON.stringify(event))
    if (this.inAppWebView.webViewAssetLoaderExt != null && this.inAppWebView.webViewAssetLoaderExt.loader != null) {
      try {
        let url = new uri.URI(request.getUrl());
        let webResourceResponse = this.inAppWebView.webViewAssetLoaderExt.loader.shouldInterceptRequest(url);
        if (webResourceResponse != null) {
          return webResourceResponse;
        }
      } catch (e) {
        Log.e(TAG, "", e);
      }
    }
    if (this.inAppWebView.customSettings.useShouldInterceptRequest) {
      if (this.inAppWebView.channelDelegate != null) {
        try {
          let response = this.inAppWebView.channelDelegate.shouldInterceptRequest(request);
          if (response != null) {
            let webResourceResponse = new WebResourceResponse();
            if(response.getData()){
              const uint8 = new Uint8Array(response.getData());
              let data = util.TextDecoder.create().decodeToString(uint8);
              webResourceResponse.setResponseData(data)
            }
            if(response.getContentType()){
              webResourceResponse.setResponseMimeType(response.getContentType())
            }
            if(response.getContentEncoding()){
              webResourceResponse.setResponseEncoding(response.getContentEncoding())
            }
            if(response.getStatusCode()){
              webResourceResponse.setResponseCode(response.getStatusCode())
            }
            if(response.getReasonPhrase()){
              webResourceResponse.setReasonMessage(response.getReasonPhrase())
            }
            if(response.getHeaders()){
              webResourceResponse.setResponseHeader(response.getHeaderArray())
            }
            webResourceResponse.setResponseIsReady(true)
            return webResourceResponse
          }
          Log.i(TAG, 'return null ');
          return null;
        } catch (e) {
          Log.e(TAG, "", e);
        }
      }
      return null;
    }

    let url: string = request.getUrl();
    let scheme = url.split(":")[0].toLowerCase();
    try {
      scheme = new uri.URI(url).scheme;
    } catch (e) {

    }

    if (this.inAppWebView.customSettings.resourceCustomSchemes != null &&
      this.inAppWebView.customSettings.resourceCustomSchemes.indexOf(scheme) > -1) {
      if (this.inAppWebView.channelDelegate != null) {
        let resourceResponse = new WebResourceResponse();
        try {
          this.inAppWebView.channelDelegate.onLoadResourceWithCustomScheme(request).then(customSchemeResponse => {
            if (customSchemeResponse != null) {
              try {
                response = this.inAppWebView.contentBlockerHandler.checkUrl(this.inAppWebView, request,
                  customSchemeResponse.getContentType());
              } catch (e) {
                Log.e(TAG, "", e);
              }
              if (response != null) {
                resourceResponse.setResponseData(response.getResponseData())
                resourceResponse.setResponseMimeType(response.getResponseMimeType())
                resourceResponse.setResponseEncoding(response.getResponseEncoding())
                resourceResponse.setResponseCode(response.getResponseCode())
                resourceResponse.setReasonMessage(response.getReasonMessage())
                resourceResponse.setResponseHeader(response.getResponseHeader())
                resourceResponse.setResponseIsReady(true)
              } else {
                resourceResponse.setResponseMimeType(customSchemeResponse.getContentType());
                resourceResponse.setResponseEncoding(customSchemeResponse.getContentEncoding());
                resourceResponse.setResponseData(customSchemeResponse.getData())
              }
            } else {
              resourceResponse.setResponseIsReady(false)
            }
          });
        } catch (e) {
          Log.e(TAG, "", e);
          resourceResponse.setResponseIsReady(false)
        }
        return resourceResponse;
      }
    }

    let response: WebResourceResponse | null = null;
    if (this.inAppWebView.contentBlockerHandler.getRuleList().length > 0) {
      try {
        response = this.inAppWebView.contentBlockerHandler.checkUrl(this.inAppWebView, request);
      } catch (e) {
        Log.e(TAG, "", e);
      }
    }
    Log.d(TAG, "onInterceptRequestend= end")
    return response;
  }
  onHttpAuthRequest = (event: Any) => {
    Log.d(TAG, "onHttpAuthRequest=" + JSON.stringify(event))
    this.onReceivedHttpAuthRequest(event.handler, event.host, event.realm)
    return true;
  }
  onSslErrorEventReceive = (event: Any) => {
    Log.d(TAG, "onSslErrorEventReceive=" + JSON.stringify(event))
    this.onReceivedSslErrorEventReceive(event.handler, event.error)
  }
  onClientAuthenticationRequest = (event: Any) => {
    Log.d(TAG, "onClientAuthenticationRequest=" + JSON.stringify(event))
    this.onReceivedClientAuthenticationRequest(event.handler, event.host, event.port, event.keyTypes, event.issuers)
  }
  onPermissionRequest = (event: Any) => {
    const _this = this;
    if (_this.inAppWebView != null && _this.inAppWebView.channelDelegate != null) {

      const request = event.request as PermissionRequest;
      let accessibleResource = request.getAccessibleResource();
      let permissionList: Array<Permissions> = [];
      accessibleResource.forEach(item => {
        if (this.permissionValues.has(item)) {
          permissionList.push(this.permissionValues.get(item)!);
        }
      });
      _this.requestPermissions(permissionList)
        .then((res)=>{
          if(res){
            _this.inAppWebView.channelDelegate?.onPermissionRequest(request.getOrigin(),  request.getAccessibleResource() ,null
              ,new InnerPermissionRequestCallback(request))
          }
          else{
            event.request.deny();
          }
        })
        .catch((error: BusinessError)=>{
          Log.d(TAG, `requestPermissions=${error}`)
          event.request.deny();
        })
    } else {
      event.request.deny();
    }
    Log.d(TAG, "onPermissionRequest=" + JSON.stringify(event))
  }
  onContextMenuShow = (event: Any) => {
    Log.d(TAG, "onContextMenuShow=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onLongPressHitTestResult(event);
      return false;
    }
    return true;
  }
  onContextMenuHide = () => {
    // TODO
    Log.d(TAG, "onContextMenuHide=")
  }
  onScroll = (event: Any) => {
    Log.d(TAG, "onScroll=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onScrollChanged(event.xOffset,
        event.yOffset);
    }
  }
  onGeolocationShow = (event: Any) => {
    Log.d(TAG, "onGeolocationShow=" + JSON.stringify(event))
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onGeolocationPermissionsShowPrompt(event.origin,
        new InnerGeolocationPermissionsShowPromptCallback(event.origin, event.geolocation));
    } else {
      event.geolocation.invoke(event.origin, false, false);
    }
  }
  onGeolocationHide = () => {
    Log.d(TAG, "onGeolocationHide=")
    if (this.inAppWebView != null && this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onGeolocationPermissionsHidePrompt();
    }
  }
  onFullScreenEnter = (event: Any) => {
    let context = this.inAppWebView.context as common.UIAbilityContext;
    let windowClass = context.windowStage.getMainWindowSync();
    let windowProperties = windowClass.getWindowProperties();
    this.isOriginalLayoutFullScreen = windowProperties.isLayoutFullScreen;
    this.isOriginalFullScreen = windowProperties.isFullScreen;
    windowClass.setWindowLayoutFullScreen(true)
    windowClass.setWindowSystemBarEnable([])
    this.fullScreenExitHandler = event.handler
    Log.d(TAG, "onFullScreenEnter=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onEnterFullscreen();
    }
    this.inAppWebView.setInFullscreen(true);
  }
  onFullScreenExit = () => {
    Log.d(TAG, "onFullScreenExit=")
    let context = this.inAppWebView.context as common.UIAbilityContext;
    let windowClass = context.windowStage.getMainWindowSync();
    windowClass.setWindowLayoutFullScreen(this.isOriginalLayoutFullScreen)
    windowClass.setWindowSystemBarEnable(this.isOriginalFullScreen ? [] : ['status', 'navigation'])
    if (this.fullScreenExitHandler) {
      this.fullScreenExitHandler.exitFullScreen()
    }
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onExitFullscreen();
    }
    this.inAppWebView.setInFullscreen(false);
  }
  onWindowNew = (event: Any) => {
    Log.d(TAG, "onWindowNew=" + JSON.stringify(event))
    let windowId = 0;
    if (this.plugin != null && this.plugin.inAppWebViewManager != null) {
      this.plugin.inAppWebViewManager.windowAutoincrementId++;
      windowId = this.plugin.inAppWebViewManager.windowAutoincrementId;
    }

    let request = new URLRequest(event.targetUrl, "GET", null, new Map<string, string>());
    let createWindowAction = new CreateWindowAction(request, true, event.isUserTrigger, false, windowId, event.isAlert);
    if (this.plugin != null && this.plugin.inAppWebViewManager != null) {
      this.plugin.inAppWebViewManager.windowWebViewMessages.set(windowId, event.handler);
    }
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onCreateWindow(createWindowAction,
        new InnerCreateWindowCallback(this.inAppWebView, windowId));
    }
  }
  onWindowExit = () => {
    Log.d(TAG, "onWindowExit=")
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onCloseWindow();
    }
  }
  onSearchResultReceive = (event: Any) => {
    Log.d(TAG, "onSearchResultReceive=" + JSON.stringify(event))
    // TODO
  }
  onDataResubmitted = (event: Any) => {
    Log.d(TAG, "onDataResubmitted=" + JSON.stringify(event))
    let callback = new InnerFormResubmissionCallback(event.handler);
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onFormResubmission(this.inAppWebView!.controller!.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }
  onPageVisible = (event: Any) => {
    Log.d(TAG, "onPageVisible=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onPageCommitVisible(event.url);
    }
  }
  onInterceptKeyEvent = (event: Any) => {
    Log.d(TAG, "onInterceptKeyEvent=" + JSON.stringify(event))
    // TODO
    return false;
  }
  onTouchIconUrlReceived = (event: Any) => {
    Log.d(TAG, "onTouchIconUrlReceived=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedTouchIconUrl(event.url, event.precomposed);
    }
  }
  onFaviconReceived = async (event: Any) => {
    Log.d(TAG, "onFaviconReceived=" + JSON.stringify(event))
    let options: image.PackingOption = {
      format: 'image/png',
      quality: 100
    };
    let packer = image.createImagePacker();
    let imageBuffer = await packer.packing(event.favicon, options);
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedIcon(imageBuffer);
    }
    await event.favicon.release()
    await packer.release()
  }
  onAudioStateChanged = (event: Any) => {
    Log.d(TAG, "onAudioStateChanged=" + JSON.stringify(event))
    // TODO
  }
  onFirstContentfulPaint = (event: Any) => {
    Log.d(TAG, "onFirstContentfulPaint=" + JSON.stringify(event))
    // TODO
  }
  onLoadIntercept = (event: Any) : boolean => {
    Log.d(TAG, "onLoadIntercept=" + event.data.getRequestUrl())
    // TODO
    return false;
  }
  onOverrideUrlLoading =  (request: WebResourceRequest) : boolean => {
    Log.d(TAG, "onOverrideUrlLoading=" + request.getRequestUrl())
    if (this.inAppWebView.customSettings.useShouldOverrideUrlLoading) {
      let headers = new Map<string, string>()
      request.getRequestHeader().forEach(header => headers.set(header.headerKey, header.headerValue));

      this.onShouldOverrideUrlLoading(
        this.inAppWebView,
        request.getRequestUrl(),
        request.getRequestMethod(),
        headers,
        request.isMainFrame(),
        request.isRequestGesture(),
        request.isRedirect());

      if (this.inAppWebView.regexToCancelSubFramesLoadingCompiled != null) {
        if (request.isMainFrame())
          return true
        else {
          return this.inAppWebView.regexToCancelSubFramesLoadingCompiled!.test(request.getRequestUrl());
        }
      } else {
        // There isn't any way to load an URL for a frame that is not the main frame,
        // so if the request is not for the main frame, the navigation is allowed.
        return request.isMainFrame();
      }
    }
    return false;
  }
  onRequestSelected = () => {
    Log.d(TAG, "onRequestSelected=")
    if(this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onRequestFocus();
    }
  }
  onScreenCaptureRequest = (event: Any) => {
    Log.d(TAG, "onScreenCaptureRequest=" + JSON.stringify(event))
    // TODO
  }
  onOverScroll = (event: Any) => {
    // TODO 没有clampedX clampedY？
    Log.d(TAG, "onOverScroll=" + JSON.stringify(event))
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.canScrollHorizontally({
        onReceiveValue(canScroll: boolean | null): void {
          let overScrolledHorizontally: boolean = canScroll!;
          let overScrolledVertically: boolean = this.inAppWebView.canScrollVertically();
          this.inAppWebView.channelDelegate.onOverScrolled(event.xOffset, event.yOffset, overScrolledHorizontally, overScrolledVertically);
        }
      });
    }
  }
  onNavigationEntryCommitted = () => {
    Log.d(TAG, "onNavigationEntryCommitted=")
    // TODO
  }
  onSafeBrowsingCheckResult = (threatType: ThreatType) => {
    Log.d(TAG, "onSafeBrowsingCheckResult=")
    let resultCallback = new InnerSafeBrowsingHitCallback();
    if (this.inAppWebView.channelDelegate != null) {
      let url = this.inAppWebView!.controller!.getUrl();
      this.inAppWebView.channelDelegate.onSafeBrowsingHit(url, threatType, resultCallback);
    } else {
      resultCallback.defaultBehaviour(null);
    }
  }
  onNativeEmbedLifecycleChange = (callback: NativeEmbedDataInfo) => {
    Log.d(TAG, "onNativeEmbedLifecycleChange=")
    // TODO
  }
  onNativeEmbedGestureEvent = (callback: NativeEmbedTouchInfo) => {
    Log.d(TAG, "onNativeEmbedGestureEvent=")
    // TODO
  }
  onRenderProcessNotResponding = (data: RenderProcessNotRespondingData) => {
    let callback = new InnerRenderProcessUnresponsiveCallback(this.inAppWebView)
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onRenderProcessUnresponsive(this.inAppWebView.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }
  onRenderProcessResponding = () => {
    let callback = new InnerRenderProcessResponsiveCallback(this.inAppWebView)
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onRenderProcessResponsive(this.inAppWebView.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  // 申请权限
  private requestPermissions(permissionList:Array<Permissions>):Promise<boolean>{
    const _this = this;
    return new Promise(async (resolve, reject) => {
      try {
        // 筛选没授权的权限
        const withoutAuthorizationList = new ArrayList<Permissions>();
        for (let i = 0; i < permissionList.length; i++) {
          const item =  permissionList[i];
          const isAuthorization = await _this.checkPermissionGrant(item);
          if(!isAuthorization){
            withoutAuthorizationList.add(item);
          }
        }

        if(withoutAuthorizationList.isEmpty()){
          resolve(true);
          return;
        }

        // 请求权限
        const atManager = abilityAccessCtrl.createAtManager();
        const permissionsFromUserRes = await atManager.requestPermissionsFromUser(getContext(this),
          withoutAuthorizationList.convertToArray());

        // 判断请求的权限是否全部授权
        let allGranted = true;
        for (let i = 0; i < permissionsFromUserRes.authResults.length; i++) {
          const authItem = permissionsFromUserRes.authResults[i];
          if (authItem !== 0) {
            allGranted = false;
            break;
          }
        }
        if (allGranted) {
          resolve(true);
          return;
        }

        // 筛选 需要二次授权的权限
        allGranted = true;
        for (let i = 0; i < permissionsFromUserRes.authResults.length; i++) {
          const authItem =  permissionsFromUserRes.authResults[i];
          // 没授权，没系统弹窗
          if(authItem!==0 && permissionsFromUserRes.dialogShownResults != null && !permissionsFromUserRes.dialogShownResults[i]){
            // 引导用户授权
            const permissionOnSettingRes = await atManager.requestPermissionOnSetting(getContext(this),
              [permissionsFromUserRes.permissions[i] as Permissions])
            if (permissionOnSettingRes[0] !== 0) {
              allGranted = false;
              break;
            }
          }
        }
        resolve(allGranted);
      }catch (error) {
        Log.e(TAG,`Failed requestPermissions error is ${error}`);
        reject(error)
      }
    });
  }

  // 检查权限
  private async  checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID。
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Log.e(TAG,`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限。
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Log.e(TAG,`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }


  private onShouldOverrideUrlLoading(webView: InAppWebView, url: string, method: string,
    headers: Map<string, string>,
    isForMainFrame: boolean, hasGesture: boolean, isRedirect: boolean) {
    let request = new URLRequest(url, method, null, headers);
    let navigationAction = new NavigationAction(request, isForMainFrame, hasGesture, isRedirect);

    let callback = new InnerShouldOverrideUrlLoadingCallback(this.inAppWebView, url, headers, isForMainFrame)
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.shouldOverrideUrlLoading(navigationAction, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  private async onReceivedHttpAuthRequest(handler: HttpAuthHandler, host: string, realm: string) {
    let url = this.inAppWebView!.controller!.getUrl();
    let protocol = "https";
    let port = 0;

    if (url != null) {
      try {
        let uriurl = new uri.URI(url);
        protocol = uriurl.scheme;
        port = Number.parseInt(uriurl.port);
      } catch (e) {
        Log.e(TAG, "", e);
      }
    }

    InAppWebViewClient.previousAuthRequestFailureCount++;

    if (InAppWebViewClient.credentialsProposed == null) {
      InAppWebViewClient.credentialsProposed = await CredentialDatabase.getInstance(this.inAppWebView.context)
        .getHttpAuthCredentials(host, protocol, realm, port);
    }

    let credentialProposed: URLCredential | null = null;
    if (InAppWebViewClient.credentialsProposed != null &&
      InAppWebViewClient.credentialsProposed.length > 0) {
      credentialProposed = InAppWebViewClient.credentialsProposed.get(0);
    }

    let certificate: cert.X509Cert | null = null;
    let certificates = await this.inAppWebView!.controller!.getCertificate();
    if (certificates && certificates.length > 0) {
      certificate = certificates[0];
    }
    let protectionSpace = new URLProtectionSpace(host, protocol, realm, port, null, certificate, null);
    let challenge =
      new HttpAuthenticationChallenge(protectionSpace, InAppWebViewClient.previousAuthRequestFailureCount,
        credentialProposed);

    let callback = new InnerReceivedHttpAuthRequestCallback(this.inAppWebView, handler, host, protocol, realm, port);
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedHttpAuthRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  private onReceivedSslErrorEventReceive(handler: SslErrorHandler, sslError: SslError) {
    let url = this.inAppWebView!.controller!.getUrl();
    let host = "";
    let protocol = "https";
    let port = 0;

    try {
      let uriurl = new uri.URI(url);
      host = uriurl.host;
      protocol = uriurl.scheme;
      port = Number.parseInt(uriurl.port);
    } catch (e) {
      Log.e(TAG, "", e);
    }

    // TODO  sslError.getCertificate()没有这方法 用null先适配
    let protectionSpace = new URLProtectionSpace(host, protocol, null, port, null, null, sslError);
    let challenge = new ServerTrustChallenge(protectionSpace);
    let callback = new InnerReceivedServerTrustAuthRequestCallback(handler);
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedServerTrustAuthRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  private async onReceivedClientAuthenticationRequest(handler: ClientAuthenticationHandler, host: string,
    port: number, keyTypes: Array<string>, issuers: Array<string>) {
    let url = this.inAppWebView!.controller!.getUrl();
    let protocol = "https";

    if (url != null) {
      try {
        let uriurl = new uri.URI(url);
        protocol = uriurl.scheme;
      } catch (e) {
        Log.e(TAG, "", e);
      }
    }

    let certificate: cert.X509Cert | null = null;
    let certificates = await this.inAppWebView!.controller!.getCertificate();
    if (certificates && certificates.length > 0) {
      certificate = certificates[0];
    }
    let protectionSpace = new URLProtectionSpace(host, protocol, null, port, null, certificate, null);
    let challenge = new ClientCertChallenge(protectionSpace, issuers, keyTypes);

    let callback = new InnerReceivedClientCertRequestCallback(this.inAppWebView!, handler);
    if (this.inAppWebView.channelDelegate != null) {
      this.inAppWebView.channelDelegate.onReceivedClientCertRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  private loadCustomJavaScriptOnPageStarted(webView: InAppWebView) {
    let source = webView.userContentController.generateWrappedCodeForDocumentStart();
    webView.controller.runJavaScriptExt(source)
  }

  private loadCustomJavaScriptOnPageFinished(webView: InAppWebView) {
    let source = webView.userContentController.generateWrappedCodeForDocumentEnd();
    webView.controller.runJavaScriptExt(source)
  }

  private needsCameraPermission(): boolean {
    return false
  }

  private acceptsVideo(types: Array<string>): boolean {
    let mimeTypes = this.getAcceptedMimeType(types);
    return this.acceptsAny(mimeTypes) || this.arrayContainsString(mimeTypes, "video");
  }

  private acceptsImages(types: Array<string>): boolean {
    let mimeTypes = this.getAcceptedMimeType(types);
    return this.acceptsAny(mimeTypes) || this.arrayContainsString(mimeTypes, "image");
  }

  private getAcceptedMimeType(types: Array<string>): Array<string> {
    if (this.isArrayEmpty(types)) {
      return ["*/*"];
    }
    let mimeTypes = new Array<string>();
    for (let i = 0; i < types.length; i++) {
      let t = types[i];
      // convert file extensions to mime types
      if (t.indexOf(".") > -1) {
        let mimeType = MimeTypes.getMimeTypeFromExtension(t.replace(".", ""));
        mimeTypes[i] = mimeType;
      } else {
        mimeTypes[i] = t;
      }
    }
    return mimeTypes;
  }

  private acceptsAny(types: Array<string>) {
    if (this.isArrayEmpty(types)) {
      return true;
    }
    for (let type of types) {
      if (type == "*/*") {
        return true;
      }
    }
    return false;
  }

  private arrayContainsString(array: Array<string>, pattern: string): boolean {
    for (let content of array) {
      if (content != null && content.indexOf(pattern) > -1) {
        return true;
      }
    }
    return false;
  }

  private isArrayEmpty(arr: Array<string>): boolean {
    // when our array returned from getAcceptTypes() has no values set from the webview
    // i.e. <input type="file" />, without any "accept" attr
    // will be an array with one empty string element, afaik
    return arr.length == 0 || (arr.length == 1 && arr[0].length == 0);
  }
}

class InnerJsAlertCallback extends JsAlertCallback {
  private result: JsResult;
  private message: string;

  constructor(result: JsResult, message: string) {
    super();
    this.result = result;
    this.message = message;
  }

  nonNullSuccess(response: JsAlertResponse): boolean {
    if (response.isHandledByClient()) {
      let action = response.getAction();
      action = action != null ? action : 1;
      switch (action) {
        case 0:
          this.result.handleConfirm();
          break;
        case 1:
        default:
          this.result.handleCancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(response: JsAlertResponse | null): void {
    let responseMessage: string | null = null;
    let confirmButtonTitle: string | null = null;
    if (response != null) {
      responseMessage = response.getMessage();
      confirmButtonTitle = response.getConfirmButtonTitle();
    }
    this.createAlertDialog(this.message, this.result, responseMessage, confirmButtonTitle);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.result.handleCancel();
  }

  private createAlertDialog(message: string, result: JsResult, responseMessage: string | null,
    confirmButtonTitle: string | null) {
    let alertMessage = (responseMessage != null && responseMessage.length > 0) ? responseMessage : message;
    AlertDialog.show(
      {
        message: alertMessage,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        confirm: {
          value: confirmButtonTitle != null ? confirmButtonTitle : "确定",
          action: () => {
            result.handleConfirm()
          }
        },
        cancel: () => {
          result.handleCancel()
        }
      }
    )
  }
}

class InnerJsConfirmCallback extends JsConfirmCallback {
  private result: JsResult;
  private message: string;

  constructor(result: JsResult, message: string) {
    super();
    this.result = result;
    this.message = message;
  }

  nonNullSuccess(response: JsConfirmResponse): boolean {
    if (response.isHandledByClient()) {
      let action = response.getAction();
      action = action != null ? action : 1;
      switch (action) {
        case 0:
          this.result.handleConfirm();
          break;
        case 1:
        default:
          this.result.handleCancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(response: JsConfirmResponse | null): void {
    let responseMessage: string | null = null;
    let confirmButtonTitle: string | null = null;
    let cancelButtonTitle: string | null = null;
    if (response != null) {
      responseMessage = response.getMessage();
      confirmButtonTitle = response.getConfirmButtonTitle();
      cancelButtonTitle = response.getCancelButtonTitle();
    }
    this.createConfirmDialog(this.message, this.result, responseMessage, confirmButtonTitle, cancelButtonTitle);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.result.handleCancel();
  }

  private createConfirmDialog(message: string, result: JsResult, responseMessage: string | null,
    confirmButtonTitle: string | null, cancelButtonTitle: string | null) {
    let alertMessage = (responseMessage != null && responseMessage.length > 0) ? responseMessage : message;
    AlertDialog.show(
      {
        message: alertMessage,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: cancelButtonTitle != null ? cancelButtonTitle : "取消",
          action: () => {
            result.handleCancel()
          }
        },
        secondaryButton: {
          defaultFocus: true,
          value: confirmButtonTitle != null ? confirmButtonTitle : "确定",
          action: () => {
            result.handleConfirm()
          }
        },
        cancel: () => {
          result.handleCancel()
        }
      }
    )
  }
}

class InnerJsPromptCallback extends JsPromptCallback {
  private result: JsResult;
  private message: string;
  private defaultValue: string;
  private uiObject: Any;

  constructor(result: JsResult, message: string, defaultValue: string, uiObject: Any) {
    super();
    this.result = result;
    this.message = message;
    this.defaultValue = defaultValue;
    this.uiObject = uiObject;
  }

  nonNullSuccess(response: JsPromptResponse): boolean {
    if (response.isHandledByClient()) {
      let action = response.getAction();
      action = action != null ? action : 1;
      switch (action) {
        case 0:
          this.result.handlePromptConfirm(response.getValue());
          break;
        case 1:
        default:
          this.result.handleCancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(response: JsPromptResponse | null): void {
    let responseMessage: string | null = null;
    let responseDefaultValue: string | null = null;
    let value: string | null = null;
    let confirmButtonTitle: string | null = null;
    let cancelButtonTitle: string | null = null;
    if (response != null) {
      responseMessage = response.getMessage();
      responseDefaultValue = response.getDefaultValue();
      value = response.getValue();
      confirmButtonTitle = response.getConfirmButtonTitle();
      cancelButtonTitle = response.getCancelButtonTitle();
    }
    this.createPromptDialog(this.message, this.defaultValue, this.result, responseMessage, responseDefaultValue, value,
      cancelButtonTitle, confirmButtonTitle);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.result.handleCancel();
  }

  private createPromptDialog(message: string, defaultValue: string, result: JsResult, responseMessage: string | null,
    responseDefaultValue: string | null, value: string | null, cancelButtonTitle: string | null,
    confirmButtonTitle: string | null) {
    let initValue =
      (responseDefaultValue != null && responseDefaultValue.length > 0) ? responseDefaultValue : defaultValue;
    let alertMessage = (responseMessage != null && responseMessage.length > 0) ? responseMessage : message;
    let finalValue = value;
    let customDialogId = -1;
    let isCancel = true;
    promptAction.openCustomDialog({
      builder: ohosPromptDialogBuilder.bind(this.uiObject, initValue, alertMessage, cancelButtonTitle,
        confirmButtonTitle, () => {
          isCancel = false
          result.handleCancel()
          promptAction.closeCustomDialog(customDialogId)
        }, (value: string | null) => {
          isCancel = false
          promptAction.closeCustomDialog(customDialogId)
          result.handlePromptConfirm(finalValue != null ? finalValue : value);
        }),
      alignment: DialogAlignment.Center,
      onDidDisappear: () => {
        if (isCancel) {
          result.handleCancel()
        }
      }
    }).then((dialogId: number) => {
      customDialogId = dialogId
    })
  }
}

class InnerJsBeforeUnloadCallback extends JsBeforeUnloadCallback {
  private result: JsResult;
  private message: string;

  constructor(result: JsResult, message: string) {
    super();
    this.result = result;
    this.message = message;
  }

  nonNullSuccess(response: JsBeforeUnloadResponse): boolean {
    if (response.isHandledByClient()) {
      let action = response.getAction();
      action = action != null ? action : 1;
      switch (action) {
        case 0:
          this.result.handleConfirm();
          break;
        case 1:
        default:
          this.result.handleCancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(response: JsBeforeUnloadResponse | null): void {
    let responseMessage: string | null = null;
    let confirmButtonTitle: string | null = null;
    let cancelButtonTitle: string | null = null;
    if (response != null) {
      responseMessage = response.getMessage();
      confirmButtonTitle = response.getConfirmButtonTitle();
      cancelButtonTitle = response.getCancelButtonTitle();
    }
    this.createBeforeUnloadDialog(this.message, this.result, responseMessage, confirmButtonTitle, cancelButtonTitle);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.result.handleCancel();
  }

  private createBeforeUnloadDialog(message: string, result: JsResult, responseMessage: string | null,
    confirmButtonTitle: string | null, cancelButtonTitle: string | null) {
    let alertMessage = (responseMessage != null && responseMessage.length > 0) ? responseMessage : message;
    AlertDialog.show(
      {
        message: alertMessage,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: cancelButtonTitle != null ? cancelButtonTitle : "取消",
          action: () => {
            result.handleCancel()
          }
        },
        secondaryButton: {
          defaultFocus: true,
          value: confirmButtonTitle != null ? confirmButtonTitle : "确定",
          action: () => {
            result.handleConfirm()
          }
        },
        cancel: () => {
          result.handleCancel()
        }
      }
    )
  }
}

class InnerPermissionRequestCallback extends PermissionRequestCallback {
  private request: PermissionRequest;

  constructor(request: PermissionRequest) {
    super();
    this.request = request;
  }

  nonNullSuccess(response: PermissionResponse): boolean {
    let action = response.getAction();
    if (action != null) {
      switch (action) {
        case 1:
          this.request.grant(this.request.getAccessibleResource());
          break;
        case 0:
        default:
          this.request.deny();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(response: PermissionResponse | null): void {
    this.request.deny();
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}



class InnerGeolocationPermissionsShowPromptCallback extends GeolocationPermissionsShowPromptCallback {
  private geolocation: JsGeolocation;
  private origin: string;

  constructor(origin: string, geolocation: JsGeolocation) {
    super();
    this.geolocation = geolocation;
    this.origin = origin;
  }

  nonNullSuccess(response: GeolocationPermissionShowPromptResponse): boolean {
    this.geolocation.invoke(response.getOrigin(), response.isAllow(), response.isRetain());
    return false;
  }

  defaultBehaviour(response: GeolocationPermissionShowPromptResponse | null): void {
    this.geolocation.invoke(this.origin, false, false);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerReceivedHttpAuthRequestCallback extends ReceivedHttpAuthRequestCallback {
  private handler: HttpAuthHandler;
  private host: string;
  private finalProtocol: string;
  private realm: string;
  private finalPort: number;
  private inAppWebView: InAppWebView;

  constructor(inAppWebView: InAppWebView, handler: HttpAuthHandler, host: string, protocol: string, realm: string,
    port: number) {
    super();
    this.handler = handler;
    this.host = host;
    this.finalProtocol = protocol;
    this.realm = realm;
    this.finalPort = port;
    this.inAppWebView = inAppWebView;
  }

  nonNullSuccess(response: HttpAuthResponse): boolean {
    let action = response.getAction();
    if (action != null) {
      switch (action) {
        case 1:
          let username = response.getUsername();
          let password = response.getPassword();
          let permanentPersistence = response.isPermanentPersistence();
          if (permanentPersistence) {
            CredentialDatabase.getInstance(this.inAppWebView.context)
              .setHttpAuthCredential(this.host, this.finalProtocol, this.realm, this.finalPort, username, password);
          }
          this.handler.confirm(username, password);
          break;
        case 2:
          if (InAppWebViewClient.credentialsProposed!.length > 0) {
            let credential = InAppWebViewClient.credentialsProposed!.removeByIndex(0);
            this.handler.confirm(credential.getUsername(), credential.getPassword());
          } else {
            this.handler.cancel();
          }
          // used custom CredentialDatabase!
          // handler.useHttpAuthUsernamePassword();
          break;
        case 0:
        default:
          InAppWebViewClient.credentialsProposed = null;
          InAppWebViewClient.previousAuthRequestFailureCount = 0;
          this.handler.cancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(result: HttpAuthResponse | null): void {
    if (result == null) {
      this.handler.cancel();
    } else {
      this.nonNullSuccess(result)
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerReceivedServerTrustAuthRequestCallback extends ReceivedServerTrustAuthRequestCallback {
  private handler: SslErrorHandler;

  constructor(handler: SslErrorHandler) {
    super();
    this.handler = handler;
  }

  nonNullSuccess(response: ServerTrustAuthResponse): boolean {
    let action = response.getAction();
    if (action != null) {
      switch (action) {
        case 1:
          this.handler.handleConfirm();
          break;
        case 0:
        default:
          this.handler.handleCancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(result: ServerTrustAuthResponse | null) {
    if (result != null) {
      this.nonNullSuccess(result);
    } else {
      this.handler.handleCancel();
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerReceivedClientCertRequestCallback extends ReceivedClientCertRequestCallback {
  private handler: ClientAuthenticationHandler;
  private inAppWebView: InAppWebView;

  constructor(inAppWebView: InAppWebView, handler: ClientAuthenticationHandler) {
    super();
    this.inAppWebView = inAppWebView;
    this.handler = handler;
  }

  nonNullSuccess(response: ClientCertResponse): boolean {
    let action = response.getAction();
    if (action != null && this.inAppWebView.plugin != null) {
      switch (action) {
        case 1: {
          let certificatePath = response.getCertificatePath();
          let certificatePassword = response.getCertificatePassword();
          let keyStoreType = response.getKeyStoreType();
          //TODO  priKeyFile？
          this.handler.confirm(keyStoreType, certificatePath)
        }
          break;
        case 2:
          this.handler.ignore();
          break;
        case 0:
        default:
          this.handler.cancel();
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(result: ClientCertResponse | null) {
    if (result != null) {
      this.nonNullSuccess(result);
    } else {
      this.handler.cancel();
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerCreateWindowCallback extends CreateWindowCallback {
  private finalWindowId: number;
  private inAppWebView: InAppWebView;

  constructor(inAppWebView: InAppWebView, finalWindowId: number) {
    super();
    this.inAppWebView = inAppWebView;
    this.finalWindowId = finalWindowId;
  }

  nonNullSuccess(handledByClient: boolean): boolean {
    return !handledByClient;
  }

  defaultBehaviour(handledByClient: boolean | null) {
    if (this.inAppWebView.plugin != null && this.inAppWebView.plugin.inAppWebViewManager != null) {
      this.inAppWebView.plugin.inAppWebViewManager.windowWebViewMessages.delete(this.finalWindowId);
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerFormResubmissionCallback extends FormResubmissionCallback {
  private hanlder: DataResubmissionHandler;

  constructor(hanlder: DataResubmissionHandler) {
    super();
    this.hanlder = hanlder;
  }

  nonNullSuccess(action: number): boolean {
    switch (action) {
      case 0:
        this.hanlder.resend();
        break;
      case 1:
      default:
        this.hanlder.cancel();
    }
    return false;
  }

  defaultBehaviour(result: number | null) {
    if (result != null) {
      this.nonNullSuccess(result);
    } else {
      this.hanlder.cancel();
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
};

class InnerShouldOverrideUrlLoadingCallback extends ShouldOverrideUrlLoadingCallback {

  private inAppWebView: InAppWebView;
  private url: string;
  private headers: Map<string, string>;
  private isForMainFrame: boolean;

  constructor(inAppWebView: InAppWebView, url: string, headers: Map<string, string>, isForMainFrame: boolean) {
    super();
    this.inAppWebView = inAppWebView;
    this.url = url;
    this.headers = headers;
    this.isForMainFrame = isForMainFrame;
  }

  nonNullSuccess(result: NavigationActionPolicy) : boolean {
    switch (result) {
      case NavigationActionPolicy.ALLOW:
        this.allowShouldOverrideUrlLoading(this.inAppWebView, this.url, this.headers, this.isForMainFrame);
        break;
      case NavigationActionPolicy.CANCEL:
      default:
        break;
    }
    return false;
  }

  defaultBehaviour(result: NavigationActionPolicy | null) {
    this.allowShouldOverrideUrlLoading(this.inAppWebView, this.url, this.headers, this.isForMainFrame);
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }

  allowShouldOverrideUrlLoading(inAppWebView: InAppWebView, url: string, headers: Map<string, string>,
    isForMainFrame: boolean) {
    if (isForMainFrame) {
      this.inAppWebView.controller.loadUrl(url, this.inAppWebView.toWebHeaders(headers));
    }
  }
};

class InnerSafeBrowsingHitCallback extends SafeBrowsingHitCallback {
  public nonNullSuccess(response: SafeBrowsingResponse): boolean {
    let action = response.getAction();
    if (action != null) {
      let report = response.isReport();
      switch (action) {
        case 0: // TODO  android backToSafety
          return true;
          break;
        case 1: // TODO android proceed
          return true;
          break;
        case 2:
        default: //TODO android showInterstitial
          return true;
      }
      return false;
    }
    return true;
  }

  defaultBehaviour(result: SafeBrowsingResponse | null) {
    if (result != null) {
      this.nonNullSuccess(result)
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerRenderProcessUnresponsiveCallback extends RenderProcessUnresponsiveCallback {
  private inAppWebView: InAppWebView;

  constructor(inAppWebView: InAppWebView) {
    super();
    this.inAppWebView = inAppWebView;
  }

  public nonNullSuccess(action: number): boolean {
    switch (action) {
      case 0:
        this.inAppWebView.controller.terminateRenderProcess();
        break;
    }
    return false;
  }

  defaultBehaviour(result: number | null) {

  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}

class InnerRenderProcessResponsiveCallback extends RenderProcessResponsiveCallback {
  private inAppWebView: InAppWebView;

  constructor(inAppWebView: InAppWebView) {
    super();
    this.inAppWebView = inAppWebView;
  }

  public nonNullSuccess(action: number): boolean {
    switch (action) {
      case 0:
        this.inAppWebView.controller.terminateRenderProcess();
        break;
    }
    return false;
  }

  defaultBehaviour(result: number | null) {

  }

  error(errorCode: string, errorMessage: string, errorDetails: Any): void {
    Log.e(TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
    this.defaultBehaviour(null);
  }
}