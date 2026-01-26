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

import ChannelDelegateImpl  from '../types/ChannelDelegateImpl';
import PrintJobController from './PrintJobController';
import { MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PrintJobInfoExt from '../types/PrintJobInfoExt';

export default class PrintJobChannelDelegate extends ChannelDelegateImpl {
  private printJobController: PrintJobController | null

  constructor(printJobController: PrintJobController, channel: MethodChannel) {
    super(channel);
    this.printJobController = printJobController;
  }

  public onMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case "cancel":
        if (this.printJobController != null) {
          this.printJobController.cancel();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "restart":
        if (this.printJobController != null) {
          this.printJobController.restart();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "getInfo":
        if (this.printJobController != null) {
          let info: PrintJobInfoExt | null = this.printJobController.getInfo();
          result.success(info != null ? info.toMap() : null);
        } else {
          result.success(null);
        }
        break;
      case "dispose":
        if (this.printJobController != null) {
          this.printJobController.dispose();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public dispose(): void {
    super.dispose();
    this.printJobController = null;
  }
}