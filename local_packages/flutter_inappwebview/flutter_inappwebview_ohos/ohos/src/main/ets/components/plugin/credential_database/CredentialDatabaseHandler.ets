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

import { Any, MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import InAppWebViewFlutterPlugin from '../InAppWebViewFlutterPlugin';
import ChannelDelegateImpl from '../types/ChannelDelegateImpl';
import CredentialDatabase from './CredentialDatabase';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import List from '@ohos.util.List';
import web_webview from '@ohos.web.webview'

const TAG = "CredentialDatabaseHandler"
const METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_credential_database"

export default class CredentialDatabaseHandler extends ChannelDelegateImpl {
  public credentialDatabase: CredentialDatabase | null = null
  public plugin: InAppWebViewFlutterPlugin | null

  constructor(plugin: InAppWebViewFlutterPlugin) {
    super(new MethodChannel(plugin.messenger!, METHOD_CHANNEL_NAME))
    this.plugin = plugin
  }

  public init(plugin: InAppWebViewFlutterPlugin): void {
    if (this.credentialDatabase == null) {
      this.credentialDatabase = CredentialDatabase.getInstance(plugin.applicationContext!);
    }
  }

  public onMethodCall(call: MethodCall, result: MethodResult): void {
    if (this.plugin != null) {
      this.init(this.plugin);
    }

    switch (call.method) {
      case "getAllAuthCredentials":
        if (this.credentialDatabase != null) {
          this.getAllAuthCredentials(result);
        } else {
          result.success(false);
        }
        break;
      case "getHttpAuthCredentials":
        if (this.credentialDatabase != null) {
          this.getHttpAuthCredentials(call, result);
        } else {
          result.success(false);
        }
        break;
      case "setHttpAuthCredential":
        if (this.credentialDatabase != null) {
          let host: string = call.argument("host") as string;
          let protocol: string = call.argument("protocol") as string;
          let realm: string = call.argument("realm") as string;
          let port: number = call.argument("port") as number;
          let username: string = call.argument("username") as string;
          let password: string = call.argument("password") as string;
          this.credentialDatabase?.setHttpAuthCredential(host, protocol, realm, port, username, password);
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "removeHttpAuthCredential":
        if (this.credentialDatabase != null) {
          let host = call.argument("host") as string;
          let protocol: string = call.argument("protocol") as string;
          let realm: string = call.argument("realm") as string;
          let port: number = call.argument("port") as number;
          let username: string = call.argument("username") as string;
          let password: string = call.argument("password") as string;

          this.credentialDatabase.removeHttpAuthCredential(host, protocol, realm, port, username, password);
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "removeHttpAuthCredentials":
        if (this.credentialDatabase != null) {
          let host: string = call.argument("host") as string;
          let protocol: string = call.argument("protocol") as string;
          let realm: string = call.argument("realm") as string;
          let port: number = call.argument("port") as number;

          this.credentialDatabase.removeHttpAuthCredentials(host, protocol, realm, port);
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "clearAllAuthCredentials":
        if (this.credentialDatabase != null) {
          this.credentialDatabase.clearAllAuthCredentials();
          if (this.plugin != null && this.plugin.applicationContext != null) {
            web_webview.WebDataBase.deleteHttpAuthCredentials();
          }
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  private async getAllAuthCredentials(result: MethodResult){
    let allCredentials: List<Map<string, Any>> = new List<Map<string, Any>>();
    if (this.credentialDatabase != null) {
      let protectionSpaces = await this.credentialDatabase!.protectionSpaceDao.getAll();
      protectionSpaces.forEach(async (item) => {
        let credentials: List<Map<string, Any>> = new List<Map<string, Any>>();
        let URLCredentials = await this.credentialDatabase!.credentialDao.getAllByProtectionSpaceId(item.getId()!)
        URLCredentials.forEach(credential => {
          credentials.add(credential.toMap());
        })
        let obj : Map<string, Any> = new Map<string, Any>();
        obj.set("protectionSpace", item.toMap());
        obj.set("credentials", credentials);
        allCredentials.add(obj);
      })
    }
    result.success(allCredentials);
  }

  private async getHttpAuthCredentials(call: MethodCall, result: MethodResult) {
    let credentials: List<Map<string, Any>> = new List<Map<string, Any>>();
    if (this.credentialDatabase != null) {
      let host: string = call.argument("host") as string;
      let protocol: string = call.argument("protocol") as string;
      let realm: string = call.argument("realm") as string;
      let port: number = call.argument("port") as number;
      let URLCredentials = await this.credentialDatabase!.getHttpAuthCredentials(host, protocol, realm, port);
      URLCredentials.forEach(credential => {
        credentials.add(credential.toMap());
      })
    }
    result.success(credentials);
  }

  public dispose(): void {
    super.dispose();
    this.plugin = null;
    this.credentialDatabase = null;
  }
}