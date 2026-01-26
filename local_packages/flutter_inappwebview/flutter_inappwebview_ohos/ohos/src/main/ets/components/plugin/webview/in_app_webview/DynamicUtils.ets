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

import { DVModelParameters } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView'

export class DynamicUtils {
  static getParams(params: DVModelParameters, element: string): string | Any {
    let params2 = params as Record<string, Any>;
    return params2[element];
  }

  static setParams(params: DVModelParameters, key: string, element: Any): void {
    let params2 = params as Record<string, Any>;
    params2[key] = element;
  }
}

export class DVModelJson {
  compType: string
  children: Array<Any>
  attributes: Any
  events: Any
  build: Any

  constructor(compType: string, children: Array<Any>, attributes: Any, events: Any, build?: Any) {
    this.compType = compType
    this.children = children
    this.attributes = attributes
    this.events = events;
    this.build = build;
  }
}