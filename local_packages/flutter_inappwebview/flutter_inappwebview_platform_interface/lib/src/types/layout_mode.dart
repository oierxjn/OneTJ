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

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'layout_mode.g.dart';

///设置Web布局模式。
@ExchangeableEnum()
class LayoutMode_ {
  // ignore: unused_field
  final int _value;
  const LayoutMode_._internal(this._value);

  ///Web布局跟随系统。
  static const NONE = const LayoutMode_._internal(0);

  ///Web基于页面大小的自适应网页布局。
  static const FIT_CONTENT = const LayoutMode_._internal(1);
}