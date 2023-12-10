/**
 *
 * vc_claim.swift
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

internal struct vc_claim:Codable {
    internal var credentialSubject:[String:MixedCodable]?
    internal var type:[String]?
    internal var context:[String]?
    internal var credentialStatus:vc_status?
    /*
     "vc" : {
         "credentialSubject" : {
           "preferredLanguage" : "en-US",
           "mail" : "pat.smith@example.com",
           "displayName" : "Pat Smith",
           "surname" : "Smith",
           "givenName" : "Pat",
           "jobTitle" : "Worker"
         },
         "type" : [ "VerifiableCredential", "VerifiedEmployee" ],
         "@context" : [ "https://www.w3.org/2018/credentials/v1" ],
         "credentialStatus" : {
           "statusListIndex" : "0",
           "id" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1#0",
           "type" : "RevocationList2021Status",
           "statusListCredential" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1"
         }
       },
     */
}
