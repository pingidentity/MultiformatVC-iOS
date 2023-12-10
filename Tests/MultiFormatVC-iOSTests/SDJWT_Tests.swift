/**
 *
 * SDJWT_Tests.swift
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

import XCTest
@testable import MultiFormatVC_iOS

final class SDJWT_Tests: XCTestCase {
    private let sdjwtSeparators = CharacterSet(charactersIn: "~.")
    
    private func createVC() -> SDJWT_Creator {
        let vcWriter = SDJWT_Creator(algorithm: "EdDSA", keyId: UUID().uuidString)
        vcWriter.payload.jwtId = UUID().uuidString
        vcWriter.payload.subject = "did:jwk:ldkfjsaldfkjsadlfkjasdflkj"
        vcWriter.payload.issuer = "did:jwk:sdksadfkjaslfkjasdflkjadlfk"
        vcWriter.setCredentialSubject([
            "name" : "John" ,
            "age": 25,
            "gender" : "male",
            "over_21" : true,
            "roles" : ["user", "reports_admin"]
        ])
        vcWriter.payload.expiry = UInt64(futureDateByAddingMonths(1).timeIntervalSince1970)
        return vcWriter
    }
    
    func testFailCreateVC() throws {
        do {
            let vc = SDJWT_Creator(algorithm: "none", keyId: UUID().uuidString)
            let _ = try vc.getEncodedVC()
        } catch {
            assert(type(of: error) == CredentialWriterError.self)
        }
    }
    
    func testVCCreateWithoutSignature() throws {
        do {
            let vc = createVC()
            let sdjwt = try vc.getEncodedVC()
            print(sdjwt)
            assert(sdjwt.components(separatedBy: sdjwtSeparators).count == 7)
        } catch {
            assert(type(of: error) == CredentialWriterError.self)
        }
    }
    
    func testVCCreateWithSignature() throws {
        do {
            let vcWriter = createVC()
            vcWriter.payload.subject = "did:jwk:ldkfjsaldfkjsadlfkjasdflkj"
            vcWriter.payload.issuer = "did:jwk:sdksadfkjaslfkjasdflkjadlfk"
            vcWriter.setCredentialSubject([
                "name" : "John" ,
                "age": 25,
                "gender" : "male",
                "over_21" : true,
                "roles" : ["user", "reports_admin"]
            ])
            vcWriter.payload.jwtId = UUID().uuidString

            let keyPair = makeKeyPair()
            print(keyPair.1)
            let signer:(Data) throws -> Data = {(data) in
                return try keyPair.0.signature(for: data)
            }
            vcWriter.signer = signer
            let sdjwt = try vcWriter.getEncodedVC()
            try vcWriter.buildSDClaims()
            print(sdjwt, sdjwt.components(separatedBy: sdjwtSeparators).count)
            assert(sdjwt.components(separatedBy: sdjwtSeparators).count == 8)
            
        } catch {
            assertionFailure("Error happened")
        }
    }
    
    func testVCInit() throws {
        let vcCreator = createVC()
        let keyPair = makeKeyPair()
        let signer:(Data) throws -> Data = {(data) in
            return try keyPair.0.signature(for: data)
        }
        vcCreator.signer = signer
        let sdjwt = try vcCreator.getEncodedVC()
        let vc = try SDJWT(from: sdjwt)
        if try vc.verifySignature(verifier: {(signature:Data, data: Data) in
            return keyPair.1.isValidSignature(signature, for: data)
        }) {
            assert(true, "Signature validation successful")
        } else {
            assertionFailure("Signature validation failed")
        }
        assert(vc.verifySDContent().isEmpty, "VC Content Verification Successful")
        assert(vc.disclosures.count == 5, "Five disclosures expected")
    }
    
    func testExampleFromSpec() throws {
        let exampleVCPayload = """
      {
        "_sd": [
          "09vKrJMOlyTWM0sjpu_pdOBVBQ2M1y3KhpH515nXkpY",
          "2rsjGbaC0ky8mT0pJrPioWTq0_daw1sX76poUlgCwbI",
          "EkO8dhW0dHEJbvUHlE_VCeuC9uRELOieLZhh7XbUTtA",
          "IlDzIKeiZdDwpqpK6ZfbyphFvz5FgnWa-sN6wqQXCiw",
          "JzYjH4svliH0R3PyEMfeZu6Jt69u5qehZo7F7EPYlSE",
          "PorFbpKuVu6xymJagvkFsFXAbRoc2JGlAUA2BA4o7cI",
          "TGf4oLbgwd5JQaHyKVQZU9UdGE0w5rtDsrZzfUaomLo",
          "jdrTE8YcbY4EifugihiAe_BPekxJQZICeiUQwY9QqxI",
          "jsu9yVulwQQlhFlM_3JlzMaSFzglhQG0DpfayQwLUK4"
        ],
        "iss": "https://example.com/issuer",
        "iat": 1683000000,
        "exp": 1883000000,
        "type": "IdentityCredential",
        "_sd_alg": "sha-256",
        "cnf": {
          "jwk": {
            "kty": "EC",
            "crv": "P-256",
            "x": "TCAER19Zvu3OHF4j4W4vfSVoHIP1ILilDls7vCeGemc",
            "y": "ZxjiWWbZMQGHVWKVQ4hbSIirsVfuecCE6t4jT9F2HZQ"
          }
        }
      }
    """
        let exampleVCHeader = """
        {
            "alg" : "ES256",
            "kid" : "\(UUID().uuidString)",
            "typ" : "vc+sd-jwt"
        }
    """
        let disclosures = "WyIyR0xDNDJzS1F2ZUNmR2ZyeU5STjl3IiwgImdpdmVuX25hbWUiLCAiSm9obiJd~WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9BIiwgImZhbWlseV9uYW1lIiwgIkRvZSJd~WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImVtYWlsIiwgImpvaG5kb2VAZXhhbXBsZS5jb20iXQ~WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgInBob25lX251bWJlciIsICIrMS0yMDItNTU1LTAxMDEiXQ~WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgImFkZHJlc3MiLCB7InN0cmVldF9hZGRyZXNzIjogIjEyMyBNYWluIFN0IiwgImxvY2FsaXR5IjogIkFueXRvd24iLCAicmVnaW9uIjogIkFueXN0YXRlIiwgImNvdW50cnkiOiAiVVMifV0~WyJBSngtMDk1VlBycFR0TjRRTU9xUk9BIiwgImJpcnRoZGF0ZSIsICIxOTQwLTAxLTAxIl0~WyJQYzMzSk0yTGNoY1VfbEhnZ3ZfdWZRIiwgImlzX292ZXJfMTgiLCB0cnVlXQ~WyJHMDJOU3JRZmpGWFE3SW8wOXN5YWpBIiwgImlzX292ZXJfMjEiLCB0cnVlXQ~WyJsa2x4RjVqTVlsR1RQVW92TU5JdkNBIiwgImlzX292ZXJfNjUiLCB0cnVlXQ"
        if let vcPayloadData = exampleVCPayload.data(using: .utf8),
           let vcHeaderData = exampleVCHeader.data(using: .utf8) {
            do {
                let vc = try SDJWT(from: "\(vcHeaderData.base64URLEncodedString()).\(vcPayloadData.base64URLEncodedString()).YmFzZTY0Cg~\(disclosures)")
                print(try vc.verifySignature(verifier: {(signature:Data, data:Data) in return true}))
                print(vc.verifySDContent())
                print(vc.disclosures)
            } catch let error as NSError {
                print("Error: \(error)")
                print(Thread.callStackSymbols.forEach({print($0)}))
                assert(false, "Error \(error)")
            }
            
        }
    }
}
