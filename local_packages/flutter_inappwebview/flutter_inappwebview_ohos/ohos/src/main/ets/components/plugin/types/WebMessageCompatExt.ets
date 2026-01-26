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

import WebMessagePortCompatExt from './WebMessagePortCompatExt'
import { List } from '@kit.ArkTS'
import { Any } from '@ohos/flutter_ohos'
import web_webview from '@ohos.web.webview';

export default class WebMessageCompatExt {
  private data: Any

  private type: number

  private ports: List<WebMessagePortCompatExt> | null

  constructor(data: Any, type: number, ports: List<WebMessagePortCompatExt> | null) {
    this.data = data;
    this.type = type;
    this.ports = ports;
  }

  public static fromMapWebMessageCompat(message: web_webview.WebMessageExt): WebMessageCompatExt {
    let data: Any
    if(message.getType() == web_webview.WebMessageType.ARRAY_BUFFER) {
      data = message.getArrayBuffer()
    } else {
      data = message.getString()
    }
    return new WebMessageCompatExt(data, message.getType(), null);
  }

  public static fromMap(map: Map<string, Any> | null): WebMessageCompatExt | null {
    if (map == null) {
      return null;
    }
    let data: Any = map.get("data")
    let type: number = map.get("type") as number
    let portMapList: List<Map<string, Any>> = map.get("ports") as List<Map<string, Any>>
    let ports: List<WebMessagePortCompatExt> | null = null;
    if (portMapList != null && !portMapList.isEmpty()) {
      ports = new List<WebMessagePortCompatExt>();
      for (let i = 0; i < portMapList.length; i++) {
        ports.add(WebMessagePortCompatExt.fromMap(portMapList[i]));
      }
    }
    return new WebMessageCompatExt(data, type, ports);
  }

  public toMap(): Map<string, Any> {
    let proxyRuleMap: Map<string, Any> = new Map<string, Any>()
    proxyRuleMap.set("data", this.data);
    proxyRuleMap.set("type", this.type);
    return proxyRuleMap;
  }

  public getData(): Any {
    return this.data;
  }

  public setData(data: Any): void {
    this.data = data;
  }

  public getType(): number {
    return this.type;
  }

  public setType(type: number): void {
    this.type = type;
  }

  public getPorts(): List<WebMessagePortCompatExt> {
    return this.ports!;
  }

  public setPorts(ports: List<WebMessagePortCompatExt>): void {
    this.ports = ports;
  }

  public equals(o: Any): boolean {
    if (this == o) return true;
    // if (o == null || getClass() != o.getClass()) return false;

    let that: WebMessageCompatExt = o as WebMessageCompatExt;

    if (this.type != that.type) return false;
    // if (!this.Objects.equals(this.data, that.data)) return false;
    // return Objects.equals(ports, that.ports);
    return true
  }

  public toString(): string {
    return "WebMessageCompatExt{" +
      "data=" + this.data +
      ", type=" + this.type +
      ", ports=" + this.ports +
      '}';
  }
}