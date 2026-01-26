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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///设置Web布局模式。
class LayoutMode {
  final int _value;
  final int _nativeValue;
  const LayoutMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory LayoutMode._internalMultiPlatform(int value, Function nativeValue) =>
      LayoutMode._internal(value, nativeValue());

  ///Web基于页面大小的自适应网页布局。
  static const FIT_CONTENT = LayoutMode._internal(1, 1);

  ///Web布局跟随系统。
  static const NONE = LayoutMode._internal(0, 0);

  ///Set of all values of [LayoutMode].
  static final Set<LayoutMode> values = [
    LayoutMode.FIT_CONTENT,
    LayoutMode.NONE,
  ].toSet();

  ///Gets a possible [LayoutMode] instance from [int] value.
  static LayoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return LayoutMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [LayoutMode] instance from a native value.
  static LayoutMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return LayoutMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'FIT_CONTENT';
      case 0:
        return 'NONE';
    }
    return _value.toString();
  }
}
