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

import { Any, BinaryMessenger, MethodChannel } from '@ohos/flutter_ohos';
import { Disposable } from '../../types/Disposable';
import InAppWebViewInterface from '../InAppWebViewInterface';
import WebMessageListenerChannelDelegate from './WebMessageListenerChannelDelegate';
import { List, uri } from '@kit.ArkTS';
import WebMessageCompatExt from '../../types/WebMessageCompatExt';
import Util from '../../Util';
import JavaScriptBridgeJS from '../../plugin_scripts_js/JavaScriptBridgeJS';
import PluginScript from '../../types/PluginScript';
import { UserScriptInjectionTime } from '../../types/UserScriptInjectionTime';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';

const LOG_TAG = "WebMessageListener"
const METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_web_message_listener_"

export default class WebMessageListener implements Disposable {
  public id: string
  public jsObjectName: string
  public allowedOriginRules: Set<string>

  /// 未完善，缺少androidx.webkit.WebViewCompat对应类型和方法
  // public listener: WebViewCompat.WebMessageListener

  /// 未完善，缺少androidx.webkit.JavaScriptReplyProxy对应类型和方法
  // public replyProxy: replyProxy

  public webView: InAppWebViewInterface | null

  public channelDelegate: WebMessageListenerChannelDelegate | null

  constructor(id: string, webView: InAppWebViewInterface, messenger: BinaryMessenger | null, jsObjectName: string, allowedOriginRules: Set<string>) {
    this.id = id
    this.webView = webView
    this.jsObjectName = jsObjectName
    this.allowedOriginRules = allowedOriginRules
    let channel: MethodChannel = new MethodChannel(messenger!, METHOD_CHANNEL_NAME_PREFIX + this.id + "_" + this.jsObjectName);
    this.channelDelegate = new WebMessageListenerChannelDelegate(this, channel);

    // if (this.webView instanceof InAppWebView) {
    //   this.listener = new WebViewCompat.WebMessageListener() {
    //     public onPostMessage(view: WebView, message: WebMessageCompat, sourceOrigin: uri, isMainFrame: boolean, javaScriptReplyProxy: JavaScriptReplyProxy): void {
    //       this.replyProxy = javaScriptReplyProxy;
    //       if (this.channelDelegate != null) {
    //         this.channelDelegate.onPostMessage(WebMessageCompatExt.fromMapWebMessageCompat(message),
    //                 sourceOrigin.toString().equals("null") ? null : sourceOrigin.toString(),
    //                 isMainFrame);
    //       }
    //     }
    //   };
    // }
  }

  public initJsInstance(): void {
    if (this.webView != null) {
      let jsObjectNameEscaped: string = Util.replaceAll(this.jsObjectName, "\'", "\\'");
      let allowedOriginRulesStringList: List<String> = new List<String>();
      for (let allowedOriginRule of this.allowedOriginRules) {
        // if ("*".equals(allowedOriginRule)) {
        //   allowedOriginRulesStringList.add("'*'");
        // } else {
        //   let rule: uri.URI = new uri.URI(allowedOriginRule);
        //   let host: string = rule.getHost() != null ? "'" + Util.replaceAll(rule.getHost(), "\'", "\\'") + "'" : "null";
        //   allowedOriginRulesStringList.add("{scheme: '" + rule.getScheme() + "', host: " + host + ", port: " + (rule.getPort() != -1 ? rule.getPort() : "null") + "}");
        // }
      }
      // let allowedOriginRulesString: string = TextUtils.join(", ", allowedOriginRulesStringList);
      let allowedOriginRulesString: string = "Not yet implemented";

      let source: string = "(function() {" +
              "  var allowedOriginRules = [" + allowedOriginRulesString + "];" +
              "  var isPageBlank = window.location.href === 'about:blank';" +
              "  var scheme = !isPageBlank ? window.location.protocol.replace(':', '') : null;" +
              "  var host = !isPageBlank ? window.location.hostname : null;" +
              "  var port = !isPageBlank ? window.location.port : null;" +
              "  if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "._isOriginAllowed(allowedOriginRules, scheme, host, port)) {" +
              "      window['" + jsObjectNameEscaped + "'] = new FlutterInAppWebViewWebMessageListener('" + jsObjectNameEscaped + "');" +
              "  }" +
              "})();";
      this.webView.getUserContentController().addPluginScript(new PluginScript(
              "WebMessageListener-" + this.jsObjectName,
              source,
              UserScriptInjectionTime.AT_DOCUMENT_START,
              null,
              false,
              null
      ));
    }
  }

  public static fromMap(webView: InAppWebViewInterface, messenger: BinaryMessenger | null, map: Map<string, Any> | null): WebMessageListener | null {
    if (map == null) {
      return null;
    }
    let id: string = map.get("id") as string;
    let jsObjectName: string = map.get("jsObjectName") as string;
    // assert jsObjectName != null;
    if(jsObjectName == null) return null
    let allowedOriginRuleList: List<string> = map.get("allowedOriginRules") as List<string>;
    // assert allowedOriginRuleList != null;
    if(allowedOriginRuleList == null) return null
    let allowedOriginRules: Set<string> = new Set<string>(allowedOriginRuleList);
    return new WebMessageListener(id, webView, messenger, jsObjectName, allowedOriginRules);
  }

  public postMessageForInAppWebView(message: WebMessageCompatExt | null, result: MethodResult): void {
    // if (replyProxy != null && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
    //   let data: Any = message.getData();
    //   if (data != null) {
    //     if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) && message.getType() == WebMessageCompat.TYPE_ARRAY_BUFFER) {
    //       replyProxy.postMessage(data as ArrayBuffer[]);
    //     } else {
    //       replyProxy.postMessage(data.toString());
    //     }
    //   }
    // }
    result.success(true);
  }

  public dispose(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate = null;
    }
    // this.listener = null;
    // this.replyProxy = null;
    this.webView = null;
  }
}