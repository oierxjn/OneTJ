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

import fs from '@ohos.file.fs';
import uri from '@ohos.uri'
import buffer from '@ohos.buffer';
import { Log } from '@ohos/flutter_ohos';
import MimeUtil from './MimeUtil';

const TAG = "WebViewAssetLoader";

export interface PathHandler {
  handle(path: string): WebResourceResponse;
}

//读取rawfile目录文件
export class AssetsPathHandler implements PathHandler {
  private context: Context

  constructor(context: Context) {
    this.context = context;
  }

  handle(path: string): WebResourceResponse {
    let webResponse = new WebResourceResponse();
    try {
      this.context.resourceManager.getRawFileContent(path).then(contentData => {
        webResponse.setResponseData(contentData);
        webResponse.setResponseMimeType(MimeUtil.guessMimeType(path));
        webResponse.setResponseIsReady(true);
      })
    } catch (e) {
      Log.e(TAG, "Error opening asset path: " + path, e);
    }
    return webResponse;
  }
}

//读取安卓下面有res/raw的资源文件 OHOS没有 OHOS也读取rawfile
export class ResourcesPathHandler implements PathHandler {
  private context: Context

  constructor(context: Context) {
    this.context = context;
  }

  handle(path: string): WebResourceResponse {
    let webResponse = new WebResourceResponse();
    try {
      this.context.resourceManager.getRawFileContent(path).then(contentData => {
        webResponse.setResponseData(contentData);
        webResponse.setResponseMimeType(MimeUtil.guessMimeType(path));
        webResponse.setResponseIsReady(true);
      });
    } catch (e) {
      Log.e(TAG, "Error opening asset path: " + path, e);
    }
    return webResponse;
  }
}

export class InternalStoragePathHandler implements PathHandler {
  private static FORBIDDEN_DATA_DIRS = ["app_webview/", "databases/", "lib/", "preferences/", "code_cache/"];
  private context: Context;
  private directory: string;

  constructor(context: Context, directory: string) {
    this.context = context;
    this.directory = directory.endsWith("/") ? directory : (directory + "/");
  }

  handle(path: string): WebResourceResponse {
    let webResponse = new WebResourceResponse();
    try {
      let stream = fs.createStreamSync(this.directory + path, "r+")
      let arrayBuffer = new ArrayBuffer(4096);
      let readLen = stream.readSync(arrayBuffer);
      let contentData = buffer.from(arrayBuffer, 0, readLen).buffer
      webResponse.setResponseData(contentData);
      webResponse.setResponseMimeType(MimeUtil.guessMimeType(path));
      webResponse.setResponseIsReady(true);
    } catch (e) {
      Log.e(TAG, "Error opening asset path: " + path, e);
    }
    return webResponse;
  }
}

export class PathMatcher {
  static HTTP_SCHEME = "http";
  static HTTPS_SCHEME = "https";
  mHttpEnabled: boolean = false;
  mAuthority: string | null = null;
  mPath: string | null = null;
  mHandler: PathHandler | null = null;

  constructor(authority: string, path: string, httpEnabled: boolean, handler: PathHandler) {
    if (path == '' || path.charAt(0) != '/') {
      throw Error("Path should start with a slash '/'.");
    }
    if (!path.endsWith("/")) {
      throw Error("Path should end with a slash '/'");
    }
    this.mAuthority = authority;
    this.mPath = path;
    this.mHttpEnabled = httpEnabled;
    this.mHandler = handler;
  }

  match(uri: uri.URI): PathHandler | null {
    // Only match HTTP_SCHEME if caller enabled HTTP matches.
    if (uri.scheme == PathMatcher.HTTP_SCHEME && !this.mHttpEnabled) {
      return null;
    }
    // Don't match non-HTTP(S) schemes.
    if (!(uri.scheme == PathMatcher.HTTP_SCHEME) && !(uri.scheme == PathMatcher.HTTPS_SCHEME)) {
      return null;
    }
    if (!(uri.authority == this.mAuthority)) {
      return null;
    }
    if (!(uri.path.startsWith(this.mPath!!))) {
      return null;
    }
    return this.mHandler;
  }

  getSuffixPath(path: string): string {
    let pattern = new RegExp(this.mPath!!)
    return path.replace(pattern, "");
  }
}

export default class WebViewAssetLoader {
  public static DEFAULT_DOMAIN = "appassets.androidplatform.net";
  private mMatchers: Array<PathMatcher>;

  constructor(pathMatchers: Array<PathMatcher>) {
    this.mMatchers = pathMatchers;
  }

  shouldInterceptRequest(url: uri.URI) {
    for (let matcher of this.mMatchers) {
      let handler = matcher.match(url);
      // The requested URL doesn't match the URL where this handler has been registered.
      if (handler == null) {
        continue;
      }
      let suffixPath = matcher.getSuffixPath(url.path);
      let response = handler.handle(suffixPath);
      // Handler doesn't want to intercept this request, try next handler.
      if (response == null) {
        continue;
      }
      return response;
    }
    return null;
  }
}

interface Pair {
  path: string;
  handler: PathHandler;
}

export class WebViewAssetLoaderBuilder {
  private mHttpAllowed: boolean = false;
  private mDomain = WebViewAssetLoader.DEFAULT_DOMAIN;
  private mHandlerList = new Array<Pair>();

  setDomain(domain: string): WebViewAssetLoaderBuilder {
    this.mDomain = domain;
    return this;
  }

  setHttpAllowed(httpAllowed: boolean): WebViewAssetLoaderBuilder {
    this.mHttpAllowed = httpAllowed;
    return this;
  }

  addPathHandler(path: string, handler: PathHandler) {
    this.mHandlerList.push({ path: path, handler: handler });
    return this;
  }

  build(): WebViewAssetLoader {
    let pathMatcherList = new Array<PathMatcher>();
    for (let el of this.mHandlerList) {
      pathMatcherList.push(new PathMatcher(this.mDomain, el.path, this.mHttpAllowed, el.handler));
    }
    return new WebViewAssetLoader(pathMatcherList);
  }
}