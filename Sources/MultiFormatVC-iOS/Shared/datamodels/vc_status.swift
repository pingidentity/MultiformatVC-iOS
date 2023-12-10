/**
 *
 * vc_status.swift
 *
 * MultiFormatVC-iOS
 * 2023
 *
 * Copyright: Ping Identity
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public struct vc_status:Codable {
    public var statusListIndex:String?
    public var id:String?
    public var type:String?
    public var statusListCredential:String?

    /*
    "credentialStatus" : {
          "statusListIndex" : "0",
          "id" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1#0",
          "type" : "RevocationList2021Status",
          "statusListCredential" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1"
        }
      },
     */
}
