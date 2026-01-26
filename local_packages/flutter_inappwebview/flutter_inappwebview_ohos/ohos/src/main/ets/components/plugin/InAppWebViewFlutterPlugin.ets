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

import { AbilityAware, AbilityPluginBinding, BinaryMessenger, Log } from '@ohos/flutter_ohos';
import {
  FlutterAssets,
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { HeadlessInAppWebViewManager } from './headless_in_webview/HeadlessInAppWebViewManager';
import MyCookieManager from './MyCookieManager';
import PrintJobManager from './print_job/PrintJobManager';
import FlutterWebViewFactory from './webview/FlutterWebViewFactory';
import { InAppWebViewManager } from './webview/InAppWebViewManager';
import InAppBrowserManager from './in_app_browser/InAppBrowserManager';
import common from '@ohos.app.ability.common';
import { UIAbility } from '@kit.AbilityKit';

const TAG = "InAppWebViewFlutterPlugin";

export default class InAppWebViewFlutterPlugin implements FlutterPlugin, AbilityAware {
  public flutterAssets: FlutterAssets | null = null;
  public flutterWebViewFactory: FlutterWebViewFactory | null = null
  public messenger: BinaryMessenger | null = null
  public printJobManager: PrintJobManager | null = null;
  public myCookieManager: MyCookieManager | null = null
  public headlessInAppWebViewManager: HeadlessInAppWebViewManager | null = null;
  public inAppWebViewManager: InAppWebViewManager | null = null;
  public inAppBrowserManager: InAppBrowserManager | null = null;
  public applicationContext: common.Context | null = null
  public uiAbility: UIAbility | null = null;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiAbility = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    this.uiAbility = null;
  }

  getUniqueClassName(): string {
    return "InAppWebViewFlutterPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, "onAttachedToEngine")
    this.messenger = binding.getBinaryMessenger()
    this.flutterAssets = binding.getFlutterAssets();
    this.inAppWebViewManager = new InAppWebViewManager( this );
    this.inAppBrowserManager = new InAppBrowserManager(this);
    this.flutterWebViewFactory = new FlutterWebViewFactory(this);
    this.messenger = binding.getBinaryMessenger();
    this.applicationContext = binding.getApplicationContext()
    binding.getPlatformViewRegistry()
      .registerViewFactory(FlutterWebViewFactory.VIEW_TYPE_ID, this.flutterWebViewFactory);

    this.myCookieManager = new MyCookieManager(this)
    this.printJobManager = new PrintJobManager(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.printJobManager != null) {
      this.printJobManager.dispose();
      this.printJobManager = null;
    }
    if (this.inAppWebViewManager != null) {
      this.inAppWebViewManager.dispose();
      this.inAppWebViewManager = null;
    }
    if (this.inAppBrowserManager != null) {
      this.inAppBrowserManager.dispose();
      this.inAppBrowserManager = null;
    }
    if (this.myCookieManager != null) {
      this.myCookieManager.dispose();
      this.myCookieManager = null;
    }
  }
}