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

import { Any, MethodChannel } from '@ohos/flutter_ohos';
import { Disposable } from '../../types/Disposable';
import WebMessagePort from '../../types/WebMessagePort';
import InAppWebViewInterface from '../InAppWebViewInterface';
import InAppWebView from '../in_app_webview/InAppWebView';
import { WebMessageChannelChannelDelegate } from './WebMessageChannelChannelDelegate';
import { ArrayList, List } from '@kit.ArkTS';
import { ValueCallback } from '../../types/ValueCallback';
import JavaScriptBridgeJS from '../../plugin_scripts_js/JavaScriptBridgeJS';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import WebMessageCompatExt from '../../types/WebMessageCompatExt';
import web_webview from '@ohos.web.webview';
import WebMessagePortCompatExt from '../../types/WebMessagePortCompatExt';

const LOG_TAG = "WebMessageChannel"
const METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_web_message_channel_"

export class WebMessageChannel implements Disposable {
  public id: string

  public channelDelegate: WebMessageChannelChannelDelegate | null

  public compatPorts: web_webview.WebMessagePort[]

  public ports: List<WebMessagePort>

  public webView: InAppWebViewInterface | null

  constructor(id: string, webView: InAppWebViewInterface) {
    this.id = id;
    let channel: MethodChannel = new MethodChannel(webView.getPlugin().messenger!, METHOD_CHANNEL_NAME_PREFIX + id)
    this.channelDelegate = new WebMessageChannelChannelDelegate(this, channel)
    if(webView instanceof InAppWebView) {
      this.compatPorts = webView.controller.createWebMessagePorts();
      this.ports = new List<WebMessagePort>()
    } else {
      this.ports = new List<WebMessagePort>()
      this.ports.set(0, new WebMessagePort("port1", this))
      this.ports.set(1, new WebMessagePort("port2", this))
      this.compatPorts = webView.getController().createWebMessagePorts()
    }
    this.webView = webView
  }

  public initJsInstance(webView: InAppWebViewInterface, callback: ValueCallback<WebMessageChannel>) {
    if (webView != null) {
      let webMessageChannel: WebMessageChannel = this;
      webView.evaluateJavascript("(function() {" +
      JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME + "['" + webMessageChannel.id + "'] = new MessageChannel();" +
        "})();", null, {
        onReceiveValue(value: string | null): void {
          callback.onReceiveValue(webMessageChannel);
        }
      }
      );
    } else {
      callback.onReceiveValue(this);
    }
  }

  public setWebMessageCallbackForInAppWebView(index: number, message: WebMessageCompatExt | null, result: MethodResult): void {
    if (this.webView != null && this.compatPorts.length > 0) {
      let webMessagePort: web_webview.WebMessagePort = this.compatPorts[index];
      let webMessageChannel: WebMessageChannel = this;
      try {
        webMessagePort.onMessageEventExt((msg) => {
          webMessageChannel.onMessage(index, message != null ? WebMessageCompatExt.fromMapWebMessageCompat(msg) : null)
        })
        result.success(true);
      } catch (e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  public postMessageForInAppWebView(index: number, message: WebMessageCompatExt, result: MethodResult): void {
    if (this.webView != null && this.compatPorts.length > 0) {
      let port: web_webview.WebMessagePort = this.compatPorts[index];
      let webMessagePorts: List<web_webview.WebMessagePort> = new List<web_webview.WebMessagePort>();
      let portsExt: List<WebMessagePortCompatExt> = message.getPorts();
      if (portsExt != null) {
        for (let portExt of portsExt) {
          let webMessageChannel: WebMessageChannel | undefined = this.webView.getWebMessageChannels().get(portExt.getWebMessageChannelId());
          if (webMessageChannel != null) {
            webMessagePorts.add(webMessageChannel.compatPorts[portExt.getIndex()]);
          }
        }
      }
      let data: Any = message.getData();
      try {
        /// 安卓端还会传入WebMessagePortCompat[]类型，目前ohos没有
        if (data != null && message.getType() == web_webview.WebMessageType.ARRAY_BUFFER) {
          let webMessageExt: web_webview.WebMessageExt = new web_webview.WebMessageExt()
          webMessageExt.setArrayBuffer(data as ArrayBuffer)
          webMessageExt.setType(web_webview.WebMessageType.ARRAY_BUFFER)
          port.postMessageEventExt(webMessageExt);
        } else {
          let webMessageExt: web_webview.WebMessageExt = new web_webview.WebMessageExt()
          webMessageExt.setString(data != null ? data.toString() : null)
          webMessageExt.setType(web_webview.WebMessageType.STRING)
          port.postMessageEventExt(webMessageExt);
        }
        result.success(true);
      } catch (e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  public closeForInAppWebView(index: number, result: MethodResult): void {
    if (this.webView != null && this.compatPorts.length > 0 ) {
      let port: web_webview.WebMessagePort = this.compatPorts[index];
      try {
        port.close();
        result.success(true);
      } catch (e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  public onMessage(index: number, message: WebMessageCompatExt | null): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.onMessage(index, message);
    }
  }

  public toMap(): Map<string, Any> {
    let webMessageChannelMap: Map<string, Any> = new Map<string, Any>()
    webMessageChannelMap.set("id", this.id);
    return webMessageChannelMap;
  }

  public dispose(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate = null;
    }
    this.compatPorts.forEach(item => item.close())
    this.compatPorts = []
    this.webView = null;
  }
}