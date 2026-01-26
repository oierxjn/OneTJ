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

import PluginScript from '../types/PluginScript';
import { UserScriptInjectionTime } from '../types/UserScriptInjectionTime';

export default class ConsoleLogJS{
  public static CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT";

  public static CONSOLE_LOG_JS_SOURCE = "(function(console) {" +
    "   function _buildMessage(args) {" +
    "     var message = '';" +
    "     for (var i in args) {" +
    "       try {" +
    "         message += message === '' ? args[i] : ' ' + args[i];" +
    "       } catch(ignored) {}" +
    "     }" +
    "     return message;" +
    "   }" +
    "   var oldLogs = {" +
    "       'log': console.log," +
    "       'debug': console.debug," +
    "       'error': console.error," +
    "       'info': console.info," +
    "       'warn': console.warn" +
    "   };" +
    "   for (var k in oldLogs) {" +
    "       (function(oldLog) {" +
    "           console[oldLog] = function() {" +
    "               oldLogs[oldLog].call(console, _buildMessage(arguments));" +
    "           }" +
    "       })(k);" +
    "   }" +
    "})(window.console);";

  public static CONSOLE_LOG_JS_PLUGIN_SCRIPT = new PluginScript(
    ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
    ConsoleLogJS.CONSOLE_LOG_JS_SOURCE,
    UserScriptInjectionTime.AT_DOCUMENT_START,
    null,
    true,
    null
  );
}