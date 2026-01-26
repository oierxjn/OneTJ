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

import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import ChannelDelegateImpl from '../types/ChannelDelegateImpl';
import { util } from '@kit.ArkTS';
import { Any, Log, MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const LOG_TAG = "InAppBrowserManager"
const METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappbrowser"

export default class InAppBrowserManager extends ChannelDelegateImpl {

  public plugin: InAppWebViewFlutterPlugin | null
  public id: string

  public static shared: Map<string, InAppBrowserManager> = new Map<string, InAppBrowserManager>()

  constructor(plugin:InAppWebViewFlutterPlugin) {
    super(new MethodChannel(plugin.messenger!, METHOD_CHANNEL_NAME));
    this.id = util.generateRandomUUID(true)
    this.plugin = plugin
    InAppBrowserManager.shared.set(this.id, this)
  }

  public onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "open":
      if (this.plugin != null && this.plugin.uiAbility != null) {
        this.open(this.plugin.uiAbility, call.args as Map<string, Any>);
        result.success(true);
      } else {
        result.success(false);
      }
        break;
      case "openWithSystemBrowser":
        if (this.plugin != null && this.plugin.uiAbility != null) {
          let url: string = call.argument("url") as string;
          this.openWithSystemBrowser(this.plugin.uiAbility, url, result);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public open(uiAbility: UIAbility, args: Map<string, Any>) {
    let want: Want = {
      bundleName: uiAbility.context.abilityInfo.bundleName,
      abilityName: 'InAppBrowserAbility'
    };

    uiAbility.context.startAbility(want, (err: BusinessError) => {
      if (err.code) {
        Log.e(LOG_TAG,  `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      }
    });
  }

  public openWithSystemBrowser(uiAbility: UIAbility, url: string, result: MethodResult): void {
    try {
      let want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url
      }

      uiAbility.context.startAbility(want, (err: BusinessError) => {
        if (err.code) {
          Log.e(LOG_TAG,  `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
          result.error(`Code: ${err.code}`, err.message, null);
        } else {
          result.success(true)
        }
      });
    } catch ( e) {
      Log.d(LOG_TAG, url + " cannot be opened: " + e.toString());
      result.error(LOG_TAG, url + " cannot be opened!", null);
    }
  }

  public dispose(): void {
    super.dispose();
    InAppBrowserManager.shared.delete(this.id);
    this.plugin = null;
  }
}