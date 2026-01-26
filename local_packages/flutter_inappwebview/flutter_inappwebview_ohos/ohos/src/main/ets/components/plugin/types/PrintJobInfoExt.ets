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

import { PrintAttributesExt } from './PrintAttributesExt'

export default class PrintJobInfoExt {
  private state: number | null = null
  private copies: number | null = null
  private numberOfPages: number | null = null
  private creationTime: number | null = null
  private label: string | null = null
  private printerId: string | null = null
  private attributes: PrintAttributesExt | null = null

  /// 缺少android.print.PrintJobInfo
  // public static fromPrintJobInfo(info: PrintJobInfo): PrintJobInfoExt | null {
  //   if (info == null) {
  //     return null;
  //   }
  //   let printJobInfoExt: PrintJobInfoExt = new PrintJobInfoExt();
  //   printJobInfoExt.state = info.getState();
  //   printJobInfoExt.copies = info.getCopies();
  //   printJobInfoExt.numberOfPages = info.getPages() != null ? info.getPages().length : null;
  //   printJobInfoExt.creationTime = info.getCreationTime();
  //   printJobInfoExt.label = info.getLabel();
  //   printJobInfoExt.printerId = info.getPrinterId() != null ? info.getPrinterId().getLocalId() : null;
  //   printJobInfoExt.attributes = PrintAttributesExt.fromPrintAttributes(info.getAttributes());
  //   return printJobInfoExt;
  // }

  public toMap(): Map<String, Object> {
    let obj: Map<String, Object> = new Map<String, Object>();
    obj.set("state", this.state!);
    obj.set("copies", this.copies!);
    obj.set("numberOfPages", this.numberOfPages!);
    obj.set("creationTime", this.creationTime!);
    obj.set("label", this.label!);
    let printer: Map<String, Object> = new Map<String, Object>();
    printer.set("id", this.printerId!);
    obj.set("printer", printer);
    obj.set("attributes", this.attributes != null ? this.attributes.toMap() : Object);
    return obj;
  }
}