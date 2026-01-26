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

import { Log, PlatformView, PlatformViewFactory, StandardMessageCodec } from '@ohos/flutter_ohos';
import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import { FlutterWebView } from './in_app_webview/FlutterWebView';
import { Any } from '@ohos/flutter_ohos';
import { HeadlessInAppWebViewManager } from '../headless_in_webview/HeadlessInAppWebViewManager';
import { HeadlessInAppWebView } from '../headless_in_webview/HeadlessInAppWebView';
import { InAppWebViewManager } from './InAppWebViewManager';

const TAG: string = "FlutterWebViewFactory";

export default class FlutterWebViewFactory extends PlatformViewFactory {
  public static VIEW_TYPE_ID = "com.pichillilorenzo/flutter_inappwebview";
  private plugin: InAppWebViewFlutterPlugin;

  constructor(plugin: InAppWebViewFlutterPlugin) {
    super(StandardMessageCodec.INSTANCE);
    this.plugin = plugin;
  }

  public create(context: Context, id: number, args: Any): PlatformView {
    Log.d(TAG, "create")
    let params: Map<string, Any> = args as Map<string, Any>;
    let flutterWebView: FlutterWebView | undefined = undefined;
    let viewId: Any = id;

    let keepAliveId: string = params.get("keepAliveId") as string;
    let headlessWebViewId: string = params.get("headlessWebViewId") as string;

    let headlessInAppWebViewManager: HeadlessInAppWebViewManager | null = this.plugin.headlessInAppWebViewManager;
    if (headlessWebViewId != null && headlessInAppWebViewManager != null) {
      let headlessInAppWebView: HeadlessInAppWebView | undefined = headlessInAppWebViewManager.webViews.get(headlessWebViewId);
      if (headlessInAppWebView != undefined) {
        flutterWebView = headlessInAppWebView.disposeAndGetFlutterWebView();
        if (flutterWebView != null) {
          flutterWebView.keepAliveId = keepAliveId;
        }
      }
    }

    let inAppWebViewManager: InAppWebViewManager | null = this.plugin.inAppWebViewManager;
    if (keepAliveId != null && flutterWebView == null && inAppWebViewManager != null) {
      flutterWebView = inAppWebViewManager.keepAliveWebViews.get(keepAliveId);
      if (flutterWebView != null) {
        // be sure to remove the view from the previous parent.
        let view = flutterWebView.getView();
        // if (view != null) {
        //   let parent:ViewGroup = view.getParent() ;
        //   if (parent != null) {
        //     parent.removeView(view);
        //   }
        // }
      }
    }

    let shouldMakeInitialLoad: boolean = flutterWebView == null;
    if (flutterWebView == null) {
      if (keepAliveId != null) {
        viewId = keepAliveId;
      }
      flutterWebView = new FlutterWebView(this.plugin, context, viewId, params);
    }

    if (shouldMakeInitialLoad) {
      flutterWebView.makeInitialLoad(params);
    }

    // flutterWebView = new FlutterWebView(this.plugin, context, viewId, args);
    // flutterWebView.makeInitialLoad(args);
    return flutterWebView;
  }
}