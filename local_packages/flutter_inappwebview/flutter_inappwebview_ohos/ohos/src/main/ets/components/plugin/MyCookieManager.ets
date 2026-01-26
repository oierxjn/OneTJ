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

import ChannelDelegateImpl from './types/ChannelDelegateImpl';
import web_webview from '@ohos.web.webview';
import InAppWebViewFlutterPlugin from './InAppWebViewFlutterPlugin';
import { Any, MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import business_error from '@ohos.base'
import Intl from '@ohos.intl';
import { List } from '@kit.ArkTS';
import systemDateTime from '@ohos.systemDateTime';

const LOG_TAG = "MyCookieManager"
const METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_cookiemanager"

export default class MyCookieManager extends ChannelDelegateImpl {
  public plugin: InAppWebViewFlutterPlugin | null

  constructor(plugin: InAppWebViewFlutterPlugin) {
    super(new MethodChannel(plugin.messenger!, METHOD_CHANNEL_NAME))
    this.plugin = plugin
  }


  public async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {

    switch (call.method) {
      case "setCookie":
        {
          let url: string = call.argument("url") as string;
          let name: string = call.argument("name") as string;
          let value: string = call.argument("value") as string;
          let domain: string = call.argument("domain") as string;
          let path: string = call.argument("path") as string;
          let expiresDateString: string = call.argument("expiresDate") as string;
          let expiresDate: number | null = (expiresDateString != null ? new Number(expiresDateString).valueOf() : null);
          let maxAge: number = call.argument("maxAge") as number;
          let isSecure: boolean = call.argument("isSecure") as boolean;
          let isHttpOnly: boolean = call.argument("isHttpOnly") as boolean;
          let sameSite: string = call.argument("sameSite") as string;
          this.setCookie(url,
                  name,
                  value,
                  domain,
                  path,
                  expiresDate,
                  maxAge,
                  isSecure,
                  isHttpOnly,
                  sameSite,
                  result);
        }
        break;
      case "getCookies":
        result.success(await this.getCookies(call.argument("url") as string));
        break;
      case "deleteCookie":
        {
          let url: string = call.argument("url") as string;
          let name: string = call.argument("name") as string;
          let domain: string = call.argument("domain") as string;
          let path: string = call.argument("path") as string;
          this.deleteCookie(url, name, domain, path, result);
        }
        break;
      case "deleteCookies":
        {
          let url: string = call.argument("url") as string;
          let domain: string = call.argument("domain") as string;
          let path: string = call.argument("path") as string;
          this.deleteCookies(url, domain, path, result);
        }
        break;
      case "deleteAllCookies":
        this.deleteAllCookies(result);
        break;
      case "removeSessionCookies":
        this.removeSessionCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  public setCookie(url: string, name: string, value: string, domain: string, path: string,
                   expiresDate: number | null, maxAge: number, isSecure: boolean, isHttpOnly: boolean, sameSite: string, result: MethodResult): void {

    if (!web_webview.WebCookieManager.isCookieAllowed()) {
      result.success(false);
      return;
    }

    try {
      let cookieValue = name + "=" + value + "; Path=" + path;

      if (domain != null) {
        cookieValue += "; Domain=" + domain;
      }
      if (expiresDate != null) {
        cookieValue += "; Expires=" + this.getCookieExpirationDate(expiresDate);
      }
      if (maxAge != null) {
        cookieValue += "; Max-Age=" + maxAge.toString();
      }
      if (isSecure) {
        cookieValue += "; Secure";
      }
      if (isHttpOnly) {
        cookieValue += "; HttpOnly";
      }
      if (sameSite != null) {
        cookieValue += "; SameSite=" + sameSite;
      }
      web_webview.WebCookieManager.configCookie(url, cookieValue)
      result.success(true)
    } catch (error) {
      let e: business_error.BusinessError = error as business_error.BusinessError
      console.error(`ErrorCode: ${e.code},  Message: ${e.message}`)
      result.success(false)
    }

  }

  public async getCookies(url: string): Promise<List<Map<string, Any>>> {
    let cookieListMap: List<Map<string, Any>> = new List<Map<string, Any>>()

    if(web_webview.WebCookieManager.fetchCookieSync(url) == "") return cookieListMap

    /// Android中同样只获取了setCookies中“name=value”这一段，因此目前先这样写着
    let cookies: string[] = web_webview.WebCookieManager.fetchCookieSync(url).split(";")

    for (let cookie of cookies) {
      let nameValue: string[] = cookie.split("=");
      let name: string = nameValue[0].trim();
      let value: string = (nameValue.length > 1) ? nameValue[1].trim() : "";
      let cookieMap: Map<string, Any> = new Map<string, Any>()
      cookieMap.set("name", name);
      cookieMap.set("value", value);
      cookieMap.set("expiresDate", null);
      cookieMap.set("isSessionOnly", null);
      cookieMap.set("domain", null);
      cookieMap.set("sameSite", null);
      cookieMap.set("isSecure", null);
      cookieMap.set("isHttpOnly", null);
      cookieMap.set("path", null);
      cookieListMap.add(cookieMap)
    }

    return cookieListMap
  }

  public deleteCookie(url: string, name: string, domain: string, path: string, result: MethodResult): void {
    if (!web_webview.WebCookieManager.isCookieAllowed()) {
      result.success(false);
      return;
    }
    try {
      let cookieValue = name + "=; Path=" + path + "; Max-Age=-1";
      if (domain != null)
        cookieValue += "; Domain=" + domain;
      web_webview.WebCookieManager.configCookieSync(url, cookieValue);
      result.success(true)
    } catch (error) {
      let e: business_error.BusinessError = error as business_error.BusinessError
      console.error(`ErrorCode: ${e.code},  Message: ${e.message}`)
    }
  }

  public deleteCookies(url: string, domain: string, path: string, result: MethodResult): void {
    if (!web_webview.WebCookieManager.isCookieAllowed()) {
      result.success(false);
      return;
    }
    let cookiesString: string = web_webview.WebCookieManager.fetchCookieSync(url)
    if (cookiesString != null) {
      for (let cookiesValue of cookiesString.split(";")) {
        let nameValue: string[] = cookiesValue.split("=")
        let name: string = nameValue[0].trim()
        let cookieValue = name + "=; Path=" + path + "; Max-Age=-1";
        if (domain != null)
          cookieValue += "; Domain=" + domain;
        web_webview.WebCookieManager.configCookieSync(url, cookieValue)
      }
    }

    result.success(true);
  }

  public deleteAllCookies(result: MethodResult): void {
    if (!web_webview.WebCookieManager.isCookieAllowed()) {
      result.success(false);
      return;
    }

    try {
      web_webview.WebCookieManager.clearAllCookiesSync()
      result.success(true)
    } catch (e) {
      console.error(LOG_TAG, e)
    }
  }

  public removeSessionCookies(result: MethodResult): void {
    if (!web_webview.WebCookieManager.isCookieAllowed()) {
      result.success(false);
      return;
    }

    try {
      web_webview.WebCookieManager.clearSessionCookieSync()
      result.success(true)
    } catch (e) {
      console.error(LOG_TAG, e)
    }
  }

  public getCookieExpirationDate(timestamp: number): string {
    let dateFormat = new Intl.DateTimeFormat("en-US", {weekday: 'short', day: '2-digit',
      month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', timeZone: 'GMT'})
    return dateFormat.format(new Date(timestamp))
  }

  public dispose(): void {
    super.dispose();
    this.plugin = null;
  }
}