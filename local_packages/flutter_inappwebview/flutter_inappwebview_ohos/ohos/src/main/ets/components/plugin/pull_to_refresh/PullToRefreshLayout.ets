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
import common from '@ohos.app.ability.common';
import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import { Disposable } from '../types/Disposable';
import PullToRefreshChannelDelegate from './PullToRefreshChannelDelegate';
import PullToRefreshSettings from './PullToRefreshSettings';
import InAppWebView from '../webview/in_app_webview/InAppWebView';
import EventConstant from '../EventConstant'

const LOG_TAG = "PullToRefreshLayout";
const METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_";

export default class PullToRefreshLayout implements Disposable {
  channelDelegate: PullToRefreshChannelDelegate | null;
  settings: PullToRefreshSettings = new PullToRefreshSettings();
  enabled: boolean = false
  public webView: InAppWebView | null = null

  constructor(plugin: InAppWebViewFlutterPlugin | null, id: Object | null = null, settings: PullToRefreshSettings) {
    this.settings = settings;
    let channel: MethodChannel = new MethodChannel(plugin!.messenger!, METHOD_CHANNEL_NAME_PREFIX + id);
    this.channelDelegate = new PullToRefreshChannelDelegate(this, channel);
  }

  setEnabled(enable: boolean) {

  }

  isEnabled(): boolean {
    return this.settings.enabled
  }

  setRefreshing(refreshing: boolean) {
    let context = this.webView!.context as common.UIAbilityContext;
    context.eventHub.emit(EventConstant.EVENT_PULL_SETREFRESHING, refreshing)
  }

  isRefreshing(): boolean {
    return false
  }

  onRefresh() {
    if (this.channelDelegate == null) {
      this.setRefreshing(false);
      return;
    }
    this.channelDelegate!!.onRefresh();
  }

  addView(webView: InAppWebView): void {
    this.webView = webView;
    webView.setPullToRefreshLayout(this);
  }

  public prepare(): void {
    if (this.webView != null) {
      this.webView.refresh()
      this.webView.scrollToTop()
    }
  }

  dispose(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate = null;
    }
    // removeAllViews();
  }
}