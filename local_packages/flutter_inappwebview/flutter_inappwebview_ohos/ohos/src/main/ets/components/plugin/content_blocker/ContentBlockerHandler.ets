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

import { Any } from '@ohos/flutter_ohos';
import ContentBlocker from './ContentBlocker';
import { ArrayList } from '@kit.ArkTS';
import InAppWebView from '../webview/in_app_webview/InAppWebView';
import WebResourceRequestExt from '../types/WebResourceRequestExt';
import { ContentBlockerTriggerResourceType } from './ContentBlockerTriggerResourceType';

export default class ContentBlockerHandler {
  protected ruleList = new ArrayList<ContentBlocker>();

  constructor(ruleList?: ArrayList<ContentBlocker>) {
    if (ruleList) {
      this.ruleList = ruleList;
    }
  }

  getRuleList(): ArrayList<ContentBlocker> {
    return this.ruleList;
  }

  setRuleList(newRuleList: ArrayList<ContentBlocker>) {
    this.ruleList = newRuleList;
  }

  checkUrl(webView: InAppWebView, request: WebResourceRequestExt, contentType?: string): WebResourceResponse | null {
    return this.checkUrlWithResourceType(webView, request, contentType ? this.getResourceTypeFromContentType(contentType) : ContentBlockerTriggerResourceType.RAW);
  }

  checkUrlWithResourceType(webView: InAppWebView, request: WebResourceRequestExt, responseResourceType: ContentBlockerTriggerResourceType): WebResourceResponse | null {
    return null
  }

  getResourceTypeFromContentType(contentType: string): ContentBlockerTriggerResourceType {
    let responseResourceType = ContentBlockerTriggerResourceType.RAW;
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
    if (contentType == "text/css") {
      responseResourceType = ContentBlockerTriggerResourceType.STYLE_SHEET;
    } else if (contentType == "image/svg+xml") {
      responseResourceType = ContentBlockerTriggerResourceType.SVG_DOCUMENT;
    } else if (contentType.startsWith("image/")) {
      responseResourceType = ContentBlockerTriggerResourceType.IMAGE;
    } else if (contentType.startsWith("font/")) {
      responseResourceType = ContentBlockerTriggerResourceType.FONT;
    } else if (contentType.startsWith("audio/") || contentType.startsWith("video/") || contentType == "application/ogg") {
      responseResourceType = ContentBlockerTriggerResourceType.MEDIA;
    } else if (contentType.endsWith("javascript")) {
      responseResourceType = ContentBlockerTriggerResourceType.SCRIPT;
    } else if (contentType.startsWith("text/")) {
      responseResourceType = ContentBlockerTriggerResourceType.DOCUMENT;
    }
    return responseResourceType;
  }
}