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

import { Any } from '@ohos/flutter_ohos'
import display from '@ohos.display';

export default class Util {
  static LOG_TAG: string = "Util"

  constructor() {
  }

  /// android.text.TextUtils未找对应的，未完善
  public static replaceAll(s: string, oldString: string, newString: string): string {
    let escapedOldString = oldString.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return s.replace(new RegExp(escapedOldString, 'g'), newString);
  }

  public static getOrDefault(map: Map<string, Any>, key: string, defaultValue: Any): Any {
    let keys = map.keys()
    for (let keyValue of keys) {
      if (keyValue == key) {
        return map.get(key) as Any
      }
    }
    return defaultValue;
  }

  public static objEquals(a: Any, b: Any): boolean {
    // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
    //   return Objects.equals(a, b);
    // }
    return (a == b) || (a != null && a.equals(b));
  }

  public static formatString(format: string, ...args: Any[]): string {
    return format.replace(/{(\d+)}/g, (match, index: number) => {
      const arg: Any = args[index];
      return arg !== undefined ? arg.toString() + "" : match;
    });
  }

  static getPixelDensity(): number {
    return display.getDefaultDisplaySync().densityPixels;
  }
}