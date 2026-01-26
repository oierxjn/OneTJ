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

import { Any, MethodChannel } from '@ohos/flutter_ohos';
import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import { Disposable } from '../types/Disposable';
import PrintJobInfoExt from '../types/PrintJobInfoExt';
import PrintJobChannelDelegate from './PrintJobChannelDelegate';
import PrintJobSettings from './PrintJobSettings';

export default class PrintJobController implements Disposable {
  protected LOG_TAG: string = "PrintJob"
  public METHOD_CHANNEL_NAME_PREFIX: string = "com.pichillilorenzo/flutter_inappwebview_printjobcontroller_"

  public id: string

  public plugin: InAppWebViewFlutterPlugin | null

  public channelDelegate: PrintJobChannelDelegate | null

  ///android.print.PrintJob类型，暂未完善
  public job: Any | null

  public settings: PrintJobSettings | null

  constructor(id: string, job: Any, settings: PrintJobSettings, plugin: InAppWebViewFlutterPlugin) {
    this.id = id
    this.plugin = plugin
    this.job = job
    this.settings = settings
    let channel: MethodChannel = new MethodChannel(plugin.messenger!, this.METHOD_CHANNEL_NAME_PREFIX + id)
    this.channelDelegate = new PrintJobChannelDelegate(this, channel);
  }

  public cancel(): void {
    if(this.job != null) {
      // this.job.cancel();
    }
  }

  public restart(): void {
    if(this.job != null) {
      // this.job.restart();
    }
  }

  public getInfo(): PrintJobInfoExt | null {
    if (this.job != null) {
      // return PrintJobInfoExt.fromPrintJobInfo(this.job.getInfo());
    }
    return null;
  }

  public disposeNoCancel(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate  = null;
    }
    if (this.plugin != null) {
      // let printJobManager: PrintJobManager = plugin.printJobManager;
      // if (printJobManager != null && printJobManager.jobs.containsKey(this.id)) {
      //   printJobManager.jobs.put(this.id, null);
      // }
    }
    if (this.job != null) {
      this.job = null;
    }
    this.plugin = null;
  }

  public dispose(): void {
    if (this.channelDelegate != null) {
      this.channelDelegate.dispose();
      this.channelDelegate  = null;
    }
    if (this.plugin != null) {
      // let printJobManager: PrintJobManager = this.plugin.printJobManager;
      // if (printJobManager != null && printJobManager.jobs.containsKey(this.id)) {
      //   printJobManager.jobs.put(this.id, null);
      // }
    }
    if (this.job != null) {
      // this.job.cancel();
      this.job = null;
    }
    this.plugin = null;
  }
}