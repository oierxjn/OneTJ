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

import 'dart:convert';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [OhosWebStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebStorageCreationParams] for
/// more information.
class OhosWebStorageCreationParams extends PlatformWebStorageCreationParams {
  /// Creates a new [OhosWebStorageCreationParams] instance.
  OhosWebStorageCreationParams(
      {required super.localStorage, required super.sessionStorage});

  /// Creates a [OhosWebStorageCreationParams] instance based on [PlatformWebStorageCreationParams].
  factory OhosWebStorageCreationParams.fromPlatformWebStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebStorageCreationParams params) {
    return OhosWebStorageCreationParams(
        localStorage: params.localStorage,
        sessionStorage: params.sessionStorage);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage}
class OhosWebStorage extends PlatformWebStorage {
  /// Constructs a [OhosWebStorage].
  OhosWebStorage(PlatformWebStorageCreationParams params)
      : super.implementation(
          params is OhosWebStorageCreationParams
              ? params
              : OhosWebStorageCreationParams
                  .fromPlatformWebStorageCreationParams(params),
        );

  @override
  PlatformLocalStorage get localStorage => params.localStorage;

  @override
  PlatformSessionStorage get sessionStorage => params.sessionStorage;

  @override
  void dispose() {
    localStorage.dispose();
    sessionStorage.dispose();
  }
}

/// Object specifying creation parameters for creating a [OhosStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformStorageCreationParams] for
/// more information.
class OhosStorageCreationParams extends PlatformStorageCreationParams {
  /// Creates a new [OhosStorageCreationParams] instance.
  OhosStorageCreationParams(
      {required super.controller, required super.webStorageType});

  /// Creates a [OhosStorageCreationParams] instance based on [PlatformStorageCreationParams].
  factory OhosStorageCreationParams.fromPlatformStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformStorageCreationParams params) {
    return OhosStorageCreationParams(
        controller: params.controller, webStorageType: params.webStorageType);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformStorage}
abstract mixin class OhosStorage implements PlatformStorage {

  @override
  OhosInAppWebViewController? controller;

  @override
  Future<int?> length() async {
    var result = await controller?.evaluateJavascript(source: """
    window.$webStorageType.length;
    """);
    return result != null ? int.parse(json.decode(result)) : null;
  }

  @override
  Future<void> setItem({required String key, required dynamic value}) async {
    var encodedValue = json.encode(value);
    await controller?.evaluateJavascript(source: """
    window.$webStorageType.setItem("$key", ${value is String ? encodedValue : "JSON.stringify($encodedValue)"});
    """);
  }

  @override
  Future<dynamic> getItem({required String key}) async {
    var itemValue = await controller?.evaluateJavascript(source: """
    window.$webStorageType.getItem("$key");
    """);

    if (itemValue == null) {
      return null;
    }

    try {
      return json.decode(itemValue);
    } catch (e) {}

    return itemValue;
  }

  @override
  Future<void> removeItem({required String key}) async {
    await controller?.evaluateJavascript(source: """
    window.$webStorageType.removeItem("$key");
    """);
  }

  @override
  Future<List<WebStorageItem>> getItems() async {
    var webStorageItems = <WebStorageItem>[];

    List<Map<dynamic, dynamic>>? items =
        (await controller?.evaluateJavascript(source: """
(function() {
  var webStorageItems = [];
  for(var i = 0; i < window.$webStorageType.length; i++){
    var key = window.$webStorageType.key(i);
    webStorageItems.push(
      {
        key: key,
        value: window.$webStorageType.getItem(key)
      }
    );
  }
  return webStorageItems;
})();
    """))?.cast<Map<dynamic, dynamic>>();

    if (items == null) {
      return webStorageItems;
    }

    for (var item in items) {
      webStorageItems
          .add(WebStorageItem(key: item["key"], value: item["value"]));
    }

    return webStorageItems;
  }

  @override
  Future<void> clear() async {
    await controller?.evaluateJavascript(source: """
    window.$webStorageType.clear();
    """);
  }

  @override
  Future<String> key({required int index}) async {
    var result = await controller?.evaluateJavascript(source: """
    window.$webStorageType.key($index);
    """);
    return result != null ? json.decode(result) : null;
  }

  @override
  void dispose() {
    controller = null;
  }
}

/// Object specifying creation parameters for creating a [OhosLocalStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformLocalStorageCreationParams] for
/// more information.
class OhosLocalStorageCreationParams
    extends PlatformLocalStorageCreationParams {
  /// Creates a new [OhosLocalStorageCreationParams] instance.
  OhosLocalStorageCreationParams(super.params);

  /// Creates a [OhosLocalStorageCreationParams] instance based on [PlatformLocalStorageCreationParams].
  factory OhosLocalStorageCreationParams.fromPlatformLocalStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformLocalStorageCreationParams params) {
    return OhosLocalStorageCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage}
class OhosLocalStorage extends PlatformLocalStorage with OhosStorage {
  /// Constructs a [OhosLocalStorage].
  OhosLocalStorage(PlatformLocalStorageCreationParams params)
      : super.implementation(
          params is OhosLocalStorageCreationParams
              ? params
              : OhosLocalStorageCreationParams
                  .fromPlatformLocalStorageCreationParams(params),
        );

  /// Default storage
  factory OhosLocalStorage.defaultStorage(
      {required PlatformInAppWebViewController? controller}) {
    return OhosLocalStorage(OhosLocalStorageCreationParams(
        PlatformLocalStorageCreationParams(PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.LOCAL_STORAGE))));
  }

  @override
  OhosInAppWebViewController? get controller =>
      params.controller as OhosInAppWebViewController?;
}

/// Object specifying creation parameters for creating a [OhosSessionStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformSessionStorageCreationParams] for
/// more information.
class OhosSessionStorageCreationParams
    extends PlatformSessionStorageCreationParams {
  /// Creates a new [OhosSessionStorageCreationParams] instance.
  OhosSessionStorageCreationParams(super.params);

  /// Creates a [OhosSessionStorageCreationParams] instance based on [PlatformSessionStorageCreationParams].
  factory OhosSessionStorageCreationParams.fromPlatformSessionStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformSessionStorageCreationParams params) {
    return OhosSessionStorageCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage}
class OhosSessionStorage extends PlatformSessionStorage with OhosStorage {
  /// Constructs a [OhosSessionStorage].
  OhosSessionStorage(PlatformSessionStorageCreationParams params)
      : super.implementation(
          params is OhosSessionStorageCreationParams
              ? params
              : OhosSessionStorageCreationParams
                  .fromPlatformSessionStorageCreationParams(params),
        );

  /// Default storage
  factory OhosSessionStorage.defaultStorage(
      {required PlatformInAppWebViewController? controller}) {
    return OhosSessionStorage(OhosSessionStorageCreationParams(
        PlatformSessionStorageCreationParams(PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.SESSION_STORAGE))));
  }

  @override
  OhosInAppWebViewController? get controller =>
      params.controller as OhosInAppWebViewController?;
}
