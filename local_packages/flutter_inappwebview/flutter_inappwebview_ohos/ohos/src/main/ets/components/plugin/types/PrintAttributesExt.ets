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

import MarginsExt from './MarginsExt'
import MediaSizeExt from './MediaSizeExt'
import ResolutionExt from './ResolutionExt'

export class PrintAttributesExt {
  private colorMode: number = 0
  private duplex: number | null = null
  private orientation: number | null = null
  private mediaSize: MediaSizeExt | null = null
  private resolution: ResolutionExt | null = null
  private margins: MarginsExt | null = null

  constructor() {}

  ///  缺少android.print.PrintAttributes，缺少android.os.build中的SystemProperties.getInt()
  // public fromPrintAttributes(attributes: PrintAttributes): PrintAttributesExt | null {
  //   if (attributes == null) {
  //     return null;
  //   }
  //   let attributesExt: PrintAttributesExt = new PrintAttributesExt();
  //   attributesExt.colorMode = attributes.getColorMode();
  //   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
  //     attributesExt.duplex = attributes.getDuplexMode();
  //   }
  //   let mediaSize: PrintAttributes.MediaSize = attributes.getMediaSize();
  //   if (mediaSize != null) {
  //     attributesExt.mediaSize = MediaSizeExt.fromMediaSize(mediaSize);
  //     attributesExt.orientation = mediaSize.isPortrait() ? 0 : 1;
  //   }
  //   attributesExt.resolution = ResolutionExt.fromResolution(attributes.getResolution());
  //   attributesExt.margins = MarginsExt.fromMargins(attributes.getMinMargins());
  //   return attributesExt;
  // }

  public toMap(): Map<String, Object> {
    let obj: Map<String, Object> = new Map<String, Object>();
    obj.set("colorMode", this.colorMode!);
    obj.set("duplex", this.duplex!);
    obj.set("orientation", this.orientation!);
    obj.set("mediaSize", this.mediaSize != null ? this.mediaSize.toMap() : Object);
    obj.set("resolution", this.resolution != null ? this.resolution.toMap() : Object);
    obj.set("margins", this.margins != null ? this.margins.toMap() : Object);
    return obj;
  }
}