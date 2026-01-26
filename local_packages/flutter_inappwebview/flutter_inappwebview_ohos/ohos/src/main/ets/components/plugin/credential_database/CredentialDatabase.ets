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

import CredentialDatabaseHelper from './CredentialDatabaseHelper'
import URLCredentialDao from './URLCredentialDao'
import URLProtectionSpaceDao from './URLProtectionSpaceDao'
import URLProtectionSpace from '../types/URLProtectionSpace'
import common from '@ohos.app.ability.common';
import URLCredential from '../types/URLCredential'
import List from '@ohos.util.List'

const TAG = "CredentialDatabase"

export default class CredentialDatabase {
  private static instance: CredentialDatabase | null = null;
  public static DATABASE_VERSION: number = 2
  public static DATABASE_NAME: string = "CredentialDatabase.db";
  public protectionSpaceDao: URLProtectionSpaceDao
  public credentialDao: URLCredentialDao
  public db: CredentialDatabaseHelper

  constructor(db: CredentialDatabaseHelper, protectionSpaceDao: URLProtectionSpaceDao,
    credentialDao: URLCredentialDao) {
    this.db = db
    this.credentialDao = credentialDao
    this.protectionSpaceDao = protectionSpaceDao
  }

  public static getInstance(context: common.Context): CredentialDatabase {
    if (CredentialDatabase.instance != null) {
      return CredentialDatabase.instance
    }
    let db: CredentialDatabaseHelper = new CredentialDatabaseHelper(context)
    CredentialDatabase.instance = new CredentialDatabase(db, new URLProtectionSpaceDao(db), new URLCredentialDao(db))
    return CredentialDatabase.instance
  }

  public async getHttpAuthCredentials(host: string, protocol: string, realm: string, port: number) {
    let credentials: List<URLCredential> = new List<URLCredential>();
    let protectionSpace = await this.protectionSpaceDao.find(host, protocol, realm, port);
    if (protectionSpace != null) {
      credentials = await this.credentialDao.getAllByProtectionSpaceId(protectionSpace.getId()!);
    }
    return credentials;
  }

  public async setHttpAuthCredential(host: string, protocol: string, realm: string, port: number, username: string,
    password: string) {
    let protectionSpace = await this.protectionSpaceDao.find(host, protocol, realm, port);
    let protectionSpaceId: number | null = null;
    if (protectionSpace == null) {
      protectionSpaceId = await this.protectionSpaceDao.insert(new URLProtectionSpace(host, protocol, realm, port));
    } else {
      protectionSpaceId = protectionSpace.getId();

    }
    let credential = await this.credentialDao.find(username, password, protectionSpaceId!);
    if (credential != null) {
      let needUpdate = false;
      if (credential.getUsername() != username) {
        credential.setUsername(username);
        needUpdate = true;
      }
      if (credential.getPassword() != password) {
        credential.setPassword(password);
        needUpdate = true;
      }
      if (needUpdate) {
        await this.credentialDao.update(credential);
      }
    } else {
      credential = new URLCredential(null, username, password, protectionSpaceId);
      credential.setId(await this.credentialDao.insert(credential));
    }
  }

  public async removeHttpAuthCredentials(host: string, protocol: string, realm: string, port: number) {
    let URLProtectionSpace = await this.protectionSpaceDao.find(host, protocol, realm, port);
    if (URLProtectionSpace != null) {
      this.protectionSpaceDao.delete(URLProtectionSpace);
    }
  }

  public async removeHttpAuthCredential(host: string, protocol: string, realm: string, port: number, username: string,
    password: string) {
    let protectionSpace = await this.protectionSpaceDao.find(host, protocol, realm, port);
    if (protectionSpace != null) {
      let credential = await this.credentialDao.find(username, password, protectionSpace.getId()!);
      if (credential != null) {
        this.credentialDao.delete(credential!);
      }
    }
  }

  public clearAllAuthCredentials() {
    this.db.clearAllTables();
  }
}