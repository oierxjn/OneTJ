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

import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import PullToRefreshLayout from '../pull_to_refresh/PullToRefreshLayout'
import { Disposable } from '../types/Disposable'
import InAppWebView from '../webview/in_app_webview/InAppWebView'
import { InAppBrowserDelegate } from './InAppBrowserDelegate'
import InAppBrowserSettings from './InAppBrowserSettings'
import { List } from '@kit.ArkTS'
import { ActivityResultListener } from './ActivityResultListener'
import InAppBrowserManager from './InAppBrowserManager'
import InAppBrowserChannelDelegate from './InAppBrowserChannelDelegate'
import InAppBrowserMenuItem from '../types/InAppBrowserMenuItem'
import InAppWebViewSettings from '../webview/in_app_webview/InAppWebViewSettings'
import Util from '../Util'
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel'
import { Any } from '@ohos/flutter_ohos'
import { Log } from '@ohos/flutter_ohos';

const LOG_TAG = "InAppBrowserAbility"
const METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappbrowser_"

//TODO 这种模式不支持，OHOS的har不支持定义Ability
export default class InAppBrowserAbility extends UIAbility implements InAppBrowserDelegate, Disposable{

  public windowId: string | null = null
  public id: string | null = null
  public webView: InAppWebView | null = null
  public pullToRefreshLayout: PullToRefreshLayout | null = null

  /// 缺少androidx.appcompat.app.ActionBar
  // public actionBar: ActionBar | null = null

  /// 缺少android.view.Menu
  // public menu: Menu | null = null

  /// 缺少android.widget.SearchView
  // public searchView: SearchView | null = null

  public customSettings: InAppBrowserSettings = new InAppBrowserSettings()

  /// 缺少android.widget.ProgressBar
  // public progressBar: ProgressBar | null = null

  public isHidden: boolean = false
  public fromActivity: string | null = null
  private activityResultListeners: List<ActivityResultListener> = new List<ActivityResultListener>()
  public manager: InAppBrowserManager | null = null
  public channelDelegate: InAppBrowserChannelDelegate | null = null
  public menuItems: List<InAppBrowserMenuItem> = new List<InAppBrowserMenuItem>()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {

  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('components/plugin/pages/InAppBrowser', (err, data) => {
      if (err.code) {
        Log.e(LOG_TAG,  `Failed to load the content. Cause: ${JSON.stringify(err)}`);
        return;
      }
    });
  }

  private prepareView(): void {
    if (this.webView != null) {
      this.webView.prepare();
    }

    if (this.customSettings.hidden)
      this.hide();
    else
      this.show();

    // this.progressBar = findViewById(R.id.progressBar);
    //
    // if (this.progressBar != null) {
    //   if (this.customSettings.hideProgressBar)
    //     this.progressBar.setMax(0);
    //   else
    //     this.progressBar.setMax(100);
    // }

    // if (this.actionBar != null) {
    //   this.actionBar.setDisplayShowTitleEnabled(!this.customSettings.hideTitleBar);
    //
    //   if (this.customSettings.hideToolbarTop)
    //     this.actionBar.hide();
    //
    //   if (this.customSettings.toolbarTopBackgroundColor != null && !this.customSettings.toolbarTopBackgroundColor.isEmpty())
    //     this.actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(this.customSettings.toolbarTopBackgroundColor)));
    //
    //   if (this.customSettings.toolbarTopFixedTitle != null && !this.customSettings.toolbarTopFixedTitle.isEmpty())
    //     this.actionBar.setTitle(this.customSettings.toolbarTopFixedTitle);
    // }
  }

  public getCustomSettings(): Map<string, Any> | null {
    let webViewSettingsMap: Map<string, Any> | null = this.webView != null ? this.webView.getCustomSettings() : null
    if (this.customSettings == null || webViewSettingsMap == null)
      return null;

    let settingsMap: Map<string, Any> = this.customSettings.getRealSettings(this);
    let keys = webViewSettingsMap.keys()
    for(let key of keys) {
      settingsMap.set(key, webViewSettingsMap[key])
    }
    return settingsMap;
  }

  public setSettings(newSettings: InAppBrowserSettings, newSettingsMap: Map<string, Any>): void {

    let newInAppWebViewSettings: InAppWebViewSettings = new InAppWebViewSettings();
    newInAppWebViewSettings.parse(newSettingsMap);
    if (this.webView != null) {
      this.webView.setSettings(newInAppWebViewSettings, newSettingsMap);
    }

    if (newSettingsMap.get("hidden") != null && this.customSettings.hidden != newSettings.hidden) {
      if (newSettings.hidden)
        this.hide();
      else
        this.show();
    }

    // if (newSettingsMap.get("hideProgressBar") != null && this.customSettings.hideProgressBar != newSettings.hideProgressBar && this.progressBar != null) {
    //   if (newSettings.hideProgressBar)
    //     this.progressBar.setMax(0);
    //   else
    //     this.progressBar.setMax(100);
    // }

    // if (this.actionBar != null && newSettingsMap.get("hideTitleBar") != null && this.customSettings.hideTitleBar != newSettings.hideTitleBar)
    //   this.actionBar.setDisplayShowTitleEnabled(!newSettings.hideTitleBar);
    //
    // if (this.actionBar != null && newSettingsMap.get("hideToolbarTop") != null && this.customSettings.hideToolbarTop != newSettings.hideToolbarTop) {
    //   if (newSettings.hideToolbarTop)
    //     this.actionBar.hide();
    //   else
    //     this.actionBar.show();
    // }

    // if (this.actionBar != null && newSettingsMap.get("toolbarTopBackgroundColor") != null &&
    //         !Util.objEquals(this.customSettings.toolbarTopBackgroundColor, newSettings.toolbarTopBackgroundColor) &&
    //         newSettings.toolbarTopBackgroundColor != null && !newSettings.toolbarTopBackgroundColor.isEmpty())
    //   this.actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(newSettings.toolbarTopBackgroundColor)));
    //
    // if (this.actionBar != null && newSettingsMap.get("toolbarTopFixedTitle") != null &&
    //         !Util.objEquals(this.customSettings.toolbarTopFixedTitle, newSettings.toolbarTopFixedTitle) &&
    //         newSettings.toolbarTopFixedTitle != null && !newSettings.toolbarTopFixedTitle.isEmpty())
    //   this.actionBar.setTitle(newSettings.toolbarTopFixedTitle);
    //
    // if (this.menu != null && newSettingsMap.get("hideUrlBar") != null && this.customSettings.hideUrlBar != newSettings.hideUrlBar) {
    //   let menuSearchItem: MenuItem = menu.findItem(R.id.menu_search);
    //   if (menuSearchItem != null) {
    //     menuSearchItem.setVisible(!newSettings.hideUrlBar);
    //   }
    // }
    //
    // if (this.menu != null && newSettingsMap.get("hideDefaultMenuItems") != null && this.customSettings.hideDefaultMenuItems != newSettings.hideDefaultMenuItems) {
    //   let actionClose: MenuItem = menu.findItem(R.id.action_close);
    //   if (actionClose != null) {
    //     actionClose.setVisible(!newSettings.hideDefaultMenuItems);
    //   }
    //   let actionGoBack: MenuItem = menu.findItem(R.id.action_go_back);
    //   if (actionGoBack != null) {
    //     actionGoBack.setVisible(!newSettings.hideDefaultMenuItems);
    //   }
    //   let actionReload: MenuItem = menu.findItem(R.id.action_reload);
    //   if (actionReload != null) {
    //     actionReload.setVisible(!newSettings.hideDefaultMenuItems);
    //   }
    //   let actionGoForward: MenuItem = menu.findItem(R.id.action_go_forward);
    //   if (actionGoForward != null) {
    //     actionGoForward.setVisible(!newSettings.hideDefaultMenuItems);
    //   }
    //   let actionShare: MenuItem = menu.findItem(R.id.action_share);
    //   if (actionShare != null) {
    //     actionShare.setVisible(!newSettings.hideDefaultMenuItems);
    //   }
    // }

    this.customSettings = newSettings;
  }

  public hide(): void {
    if (this.fromActivity != null) {
      try {
        this.isHidden = true;
        // let openActivity: Intent = new Intent(this, Class.forName(fromActivity));
        // openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        // startActivityIfNeeded(openActivity, 0);
      } catch (e) {
        console.log(LOG_TAG, "", e);
      }
    }
  }

  public show(): void {
    this.isHidden = false;
    // let openActivity: Intent = new Intent(this, InAppBrowserActivity.class);
    // openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    // startActivityIfNeeded(openActivity, 0);
  }

  public close(result: MethodResult): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.onExit();
    }

    this.dispose();

    if (result != null) {
      result.success(true);
    }
  }

  getActivityResultListeners(): List<ActivityResultListener> {
    return this.activityResultListeners
  }

  didChangeTitle(title: string): void {
    // if (this.actionBar != null && (this.customSettings.toolbarTopFixedTitle == null || this.customSettings.toolbarTopFixedTitle.isEmpty())) {
    //   this.actionBar.setTitle(title);
    // }
    throw new Error('Method not implemented.')
  }

  didStartNavigation(url: string): void {
    // if (this.progressBar != null) {
    //   this.progressBar.setProgress(0);
    // }
    // if (this.searchView != null) {
    //   this.searchView.setQuery(url, false);
    // }
    throw new Error('Method not implemented.')
  }

  didUpdateVisitedHistory(url: string): void {
    // if (this.searchView != null) {
    //   this.searchView.setQuery(url, false);
    // }
    throw new Error('Method not implemented.')
  }

  didFinishNavigation(url: string): void {
    // if (this.searchView != null) {
    //   this.searchView.setQuery(url, false);
    // }
    // if (this.progressBar != null) {
    //   this.progressBar.setProgress(0);
    // }
    throw new Error('Method not implemented.')
  }

  didFailNavigation(url: string, errorCode: number, description: string): void {
    // if (this.progressBar != null) {
    //   this.progressBar.setProgress(0);
    // }
    throw new Error('Method not implemented.')
  }

  didChangeProgress(progress: number): void {
    // if (this.progressBar != null) {
    //   this.progressBar.setVisibility(View.VISIBLE);
    //   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
    //     this.progressBar.setProgress(progress, true);
    //   } else {
    //     this.progressBar.setProgress(progress);
    //   }
    //   if (progress == 100) {
    //     this.progressBar.setVisibility(View.GONE);
    //   }
    // }
    throw new Error('Method not implemented.')
  }

  dispose(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate = null;
    }
    this.activityResultListeners.clear();
    if (this.webView != null) {
      // if (this.manager != null && this.manager.plugin != null &&
      //         this.manager.plugin.activityPluginBinding != null && this.webView.inAppWebViewChromeClient != null) {
      //   this.manager.plugin.activityPluginBinding.removeActivityResultListener(webView.inAppWebViewChromeClient);
      // }
      // let containerView: RelativeLayout = findViewById(R.id.container) as RelativeLayout;
      // if (containerView != null) {
      //   containerView.removeAllViews();
      // }
      this.webView.dispose();
      this.webView = null;
      // finish();
    }
  }
}