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

import { Any, MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import ChannelDelegateImpl from '../../types/ChannelDelegateImpl';
import WebMessageCompatExt from '../../types/WebMessageCompatExt';
import InAppWebView from '../in_app_webview/InAppWebView';
import WebMessageListener from './WebMessageListener';

export default class WebMessageListenerChannelDelegate extends ChannelDelegateImpl {
  private webMessageListener: WebMessageListener | null

  constructor(webMessageListener: WebMessageListener, channel: MethodChannel) {
    super(channel);
    this.webMessageListener = webMessageListener;
  }

  public onMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case "postMessage":
        if (this.webMessageListener != null && this.webMessageListener.webView instanceof InAppWebView) {
          let message: WebMessageCompatExt | null = WebMessageCompatExt.fromMap(call.argument("message") as Map<string, Any>);
          this.webMessageListener.postMessageForInAppWebView(message, result);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public onPostMessage(message: WebMessageCompatExt, sourceOrigin: string, isMainFrame: boolean): void {
    let channel: MethodChannel = this.getChannel();
    if (channel == null) return;
    let obj: Map<string, Any> = new Map<string, Any>();
    obj.set("message", message != null ? message.toMap() : null);
    obj.set("sourceOrigin", sourceOrigin);
    obj.set("isMainFrame", isMainFrame);
    channel.invokeMethod("onPostMessage", obj);
  }

  public dispose(): void {
    super.dispose();
    this.webMessageListener = null;
  }
}