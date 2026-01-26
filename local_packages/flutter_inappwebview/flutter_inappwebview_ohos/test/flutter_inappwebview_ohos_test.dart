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

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos_platform_interface.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInappwebviewOhosPlatform
    with MockPlatformInterfaceMixin
    implements FlutterInappwebviewOhosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterInappwebviewOhosPlatform initialPlatform = FlutterInappwebviewOhosPlatform.instance;

  test('$MethodChannelFlutterInappwebviewOhos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterInappwebviewOhos>());
  });

  test('getPlatformVersion', () async {
    FlutterInappwebviewOhos flutterInappwebviewOhosPlugin = FlutterInappwebviewOhos();
    MockFlutterInappwebviewOhosPlatform fakePlatform = MockFlutterInappwebviewOhosPlatform();
    FlutterInappwebviewOhosPlatform.instance = fakePlatform;

    expect(await flutterInappwebviewOhosPlugin.getPlatformVersion(), '42');
  });
}
