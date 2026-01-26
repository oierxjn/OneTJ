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
import BaseCallbackResultImpl from './BaseCallbackResultImpl';
import napi from 'libinappwebview.so';

export default class SyncBaseCallbackResultImpl<T> extends BaseCallbackResultImpl<T> {
  public result: T | null = null;
  public responsed: boolean = false

  defaultBehaviour(result: T | null): void {
    this.responsed = true
  }

  success(obj: Any): void {
    let result = this.decodeResult(obj);
    this.result = result;
    let shouldRunDefaultBehaviour: boolean = false;
    if (result == null) {
      shouldRunDefaultBehaviour = this.nullSuccess();
    } else {
      shouldRunDefaultBehaviour = this.nonNullSuccess(result);
    }
    if (shouldRunDefaultBehaviour) {
      this.defaultBehaviour(result);
    } else {
      this.responsed = true
    }
  }

  waitResponse(): void {
    while (!this.responsed) {
      napi.uvRunNowait();
    }
  }

  error(errorCode: string, errorMessage: string, errorDetails: Any) {
    this.responsed = true
  }

  notImplemented(): void {
    this.defaultBehaviour(null);
  }
}
