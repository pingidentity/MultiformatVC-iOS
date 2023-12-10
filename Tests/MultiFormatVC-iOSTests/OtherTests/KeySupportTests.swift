/**
 *
 * KeySupportTests.swift
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
import CryptoKit
@testable import MultiFormatVC_iOS

let ed25519_pbk = "{\"kty\": \"OKP\",\"use\": \"sig\",\"crv\": \"Ed25519\",\"kid\": \"ee0750b0-5f2a-4eef-9cb3-999ed6c4cd5d\",\"x\": \"rU9K49C18p2OiCTdPqfY9teM1IlT6Zqs7YTsE87GXi8\",\"alg\": \"EdDSA\"}"

let ed25519_pbk_prk = "{\"kty\": \"OKP\", \"d\": \"yxinTCG98GILOk2A_eWber7nxyPWK6pAC9bEoZOgLZo\", \"use\": \"sig\", \"crv\": \"Ed25519\", \"kid\": \"ee0750b0-5f2a-4eef-9cb3-999ed6c4cd5d\", \"x\": \"rU9K49C18p2OiCTdPqfY9teM1IlT6Zqs7YTsE87GXi8\", \"alg\": \"EdDSA\"}"

final class KeySupportTests: XCTestCase {
    
    func testMkjwk() throws {
        let decoder = JSONDecoder()
        
        let jwk = try decoder.decode(jwk_okp.self, from: ed25519_pbk.data(using: .utf8)!)
        if let publicKey = try jwk.getPublicKey() as? Curve25519.Signing.PublicKey {
            assert(publicKey.rawRepresentation.base64EncodedString() == jwk.x.base64urlToBase64(), "Public Key rawRepresentation should match d value from JWK")
        } else {
            assertionFailure("Unable to produce PublicKey from JWK")
        }
    }
    
    func testPrivateKey() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_okp.self, from: ed25519_pbk_prk.data(using: .utf8)!)
        
        if let privateKey = try jwk.getPrivateKey() as? Curve25519.Signing.PrivateKey {
            assert(privateKey.rawRepresentation.base64EncodedString() == jwk.d!.base64urlToBase64(), "Private Key rawRepresentation should match d value from JWK")
        } else {
            assertionFailure("Unable to produce PrivateKey from JWK")
        }
    }
    
    func testSignVerify() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_okp.self, from: ed25519_pbk_prk.data(using: .utf8)!)
        
        if let privateKey = try jwk.getPrivateKey() as? Curve25519.Signing.PrivateKey,
           let publicKey = try jwk.getPublicKey() as? Curve25519.Signing.PublicKey {
            if let data = "This is going to be signed".data(using: .utf8) {
                let sign = try privateKey.signature(for: data)
                let verify = publicKey.isValidSignature(sign, for: data)
                assert(verify, "Failed verification of signature of data by public Key from JWK")
            }
        } else {
            assertionFailure("Unable to produce PublicKey or PrivateKey from JWK")
        }
    }
}

let p256_pbk = """
{
    "kty": "EC",
    "use": "sig",
    "crv": "P-256",
    "kid": "sig-2023-11-29T09:47:41Z",
    "x": "3ntPwz46eNFy2D0IPa5K-bRVmgRyz0OIoda0qB1Quig",
    "y": "Rvcw8Gc-oXI9mlEaHw9SnOKIjHshuYBxy9Aws5ZmmQw"
}
"""

let p256_pbk_prk = """
{
    "kty": "EC",
    "d": "EqTTeRxKxq6mgir94l5v85SPaPNa2nFjjsF4f_F01wk",
    "use": "sig",
    "crv": "P-256",
    "kid": "sig-2023-11-29T09:47:41Z",
    "x": "3ntPwz46eNFy2D0IPa5K-bRVmgRyz0OIoda0qB1Quig",
    "y": "Rvcw8Gc-oXI9mlEaHw9SnOKIjHshuYBxy9Aws5ZmmQw"
}
"""
extension KeySupportTests {
    func testECPublicKey() throws {
        let decoder = JSONDecoder()
        
        let jwk = try decoder.decode(jwk_ec.self, from: p256_pbk.data(using: .utf8)!)
        if let publicKey = try jwk.getPublicKey() as? P256.Signing.PublicKey {
            print(publicKey.rawRepresentation.base64EncodedString())
            print(jwk.x.base64urlToBase64())
            assert(publicKey.rawRepresentation.base64EncodedString().prefix(10) == jwk.x.base64urlToBase64().prefix(10), "PublicKey rawRepresentation should start with x value from JWK")
        } else {
            assertionFailure("Unable to produce PublicKey from JWK")
        }
    }
    
    func testECPrivateKey() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p256_pbk_prk.data(using: .utf8)!)

        if let privateKey = try jwk.getPrivateKey() as? P256.Signing.PrivateKey {
            assert(privateKey.rawRepresentation.base64EncodedString() == jwk.d!.base64urlToBase64(), "Private Key rawRepresentation should match d value from JWK")
        } else {
            assertionFailure("Unable to produce PrivateKey from JWK")
        }
    }
    
    func testECSignVerify() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p256_pbk_prk.data(using: .utf8)!)
        
        if let privateKey = try jwk.getPrivateKey() as? P256.Signing.PrivateKey,
           let publicKey = try jwk.getPublicKey() as? P256.Signing.PublicKey {
            if let data = "This is going to be signed".data(using: .utf8) {
                let sign = try privateKey.signature(for: data)
                let verify = publicKey.isValidSignature(sign, for: data)
                assert(verify, "Failed verification of signature of data by public Key from JWK")
            }
        } else {
            assertionFailure("Unable to produce PublicKey or PrivateKey from JWK")
        }
    }
}


let p384_pbk = """
{
    "kty": "EC",
    "use": "sig",
    "crv": "P-384",
    "kid": "sig-2023-11-29T19:40:12Z",
    "x": "76WMpVgussZfUDkMPCurUErPTpYvnEH5vKA78fbHpZ1Oe1twbCS47ufg8WvtY-Ig",
    "y": "eKP4hqO5QcMOoFzw5t2NwmVnOBFjD78s8nsHhHYO5RgSR0kcWJn_RCZSgxxvKrN-"
}
"""

let p384_pbk_prk = """
{
    "kty": "EC",
    "d": "COtsb8N08bR-FcdbPNd3COsq2RKPuFOdeOC4ObkkILOy8bC7Z_GuvRwfbrfHedbb",
    "use": "sig",
    "crv": "P-384",
    "kid": "sig-2023-11-29T19:40:12Z",
    "x": "76WMpVgussZfUDkMPCurUErPTpYvnEH5vKA78fbHpZ1Oe1twbCS47ufg8WvtY-Ig",
    "y": "eKP4hqO5QcMOoFzw5t2NwmVnOBFjD78s8nsHhHYO5RgSR0kcWJn_RCZSgxxvKrN-"
}
"""

extension KeySupportTests {
    func testP384ECPublicKey() throws {
        let decoder = JSONDecoder()
        
        let jwk = try decoder.decode(jwk_ec.self, from: p384_pbk.data(using: .utf8)!)
        if let publicKey = try jwk.getPublicKey() as? P384.Signing.PublicKey {
            print(publicKey.rawRepresentation.base64EncodedString())
            print(jwk.x.base64urlToBase64())
            assert(publicKey.rawRepresentation.base64EncodedString().prefix(10) == jwk.x.base64urlToBase64().prefix(10), "PublicKey rawRepresentation should start with x value from JWK")
        } else {
            assertionFailure("Unable to produce PublicKey from JWK")
        }
    }
    
    func testP384ECPrivateKey() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p384_pbk_prk.data(using: .utf8)!)

        if let privateKey = try jwk.getPrivateKey() as? P384.Signing.PrivateKey {
            assert(privateKey.rawRepresentation.base64EncodedString() == jwk.d!.base64urlToBase64(), "Private Key rawRepresentation should match d value from JWK")
        } else {
            assertionFailure("Unable to produce PrivateKey from JWK")
        }
    }
    
    func testP384ECSignVerify() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p384_pbk_prk.data(using: .utf8)!)
        
        if let privateKey = try jwk.getPrivateKey() as? P384.Signing.PrivateKey,
           let publicKey = try jwk.getPublicKey() as? P384.Signing.PublicKey {
            if let data = "This is going to be signed".data(using: .utf8) {
                let sign = try privateKey.signature(for: data)
                let verify = publicKey.isValidSignature(sign, for: data)
                assert(verify, "Failed verification of signature of data by public Key from JWK")
            }
        } else {
            assertionFailure("Unable to produce PublicKey or PrivateKey from JWK")
        }
    }
}

let p521_pbk = """
{
    "kty": "EC",
    "use": "sig",
    "crv": "P-521",
    "kid": "sig-2023-11-29T19:41:41Z",
    "x": "AeTy3GdADgDh2VwE05hDQXOBvejyyrhoaOVQgsR7A_h_NRf-CRuEQKyayrT1r39hTUxTWexPe9ZSnleDE7kaPIrH",
    "y": "ANHiOJpBZDUvxok1sXXbQvP2HK_xfueWqWBZSGfEZ7Rv-eIsDgv-EEDJVTocHsu6SewTHacsb532hDv1g4voSPHb"
}
"""
let p521_pbk_prk = """
{
    "kty": "EC",
    "d": "APtpz8owejNWpYT9n4cilu1ehkUlhYbvHtDKIlCZ4-s_QlOOPtxfG7-RhXygz7EIyEgZFlm2d0rS6irtHrL9Tgxy",
    "use": "sig",
    "crv": "P-521",
    "kid": "sig-2023-11-29T19:41:41Z",
    "x": "AeTy3GdADgDh2VwE05hDQXOBvejyyrhoaOVQgsR7A_h_NRf-CRuEQKyayrT1r39hTUxTWexPe9ZSnleDE7kaPIrH",
    "y": "ANHiOJpBZDUvxok1sXXbQvP2HK_xfueWqWBZSGfEZ7Rv-eIsDgv-EEDJVTocHsu6SewTHacsb532hDv1g4voSPHb"
}
"""
extension KeySupportTests {
    func testP521ECPublicKey() throws {
        let decoder = JSONDecoder()
        
        let jwk = try decoder.decode(jwk_ec.self, from: p521_pbk.data(using: .utf8)!)
        if let publicKey = try jwk.getPublicKey() as? P521.Signing.PublicKey {
            print(publicKey.rawRepresentation.base64EncodedString())
            print(jwk.x.base64urlToBase64())
            assert(publicKey.rawRepresentation.base64EncodedString().prefix(10) == jwk.x.base64urlToBase64().prefix(10), "PublicKey rawRepresentation should start with x value from JWK")
        } else {
            assertionFailure("Unable to produce PublicKey from JWK")
        }
    }
    
    func testP521ECPrivateKey() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p521_pbk_prk.data(using: .utf8)!)

        if let privateKey = try jwk.getPrivateKey() as? P521.Signing.PrivateKey {
            assert(privateKey.rawRepresentation.base64EncodedString() == jwk.d!.base64urlToBase64(), "Private Key rawRepresentation should match d value from JWK")
        } else {
            assertionFailure("Unable to produce PrivateKey from JWK")
        }
    }
    
    func testP521ECSignVerify() throws {
        let decoder = JSONDecoder()
        let jwk = try decoder.decode(jwk_ec.self, from: p521_pbk_prk.data(using: .utf8)!)
        
        if let privateKey = try jwk.getPrivateKey() as? P521.Signing.PrivateKey,
           let publicKey = try jwk.getPublicKey() as? P521.Signing.PublicKey {
            if let data = "This is going to be signed".data(using: .utf8) {
                let sign = try privateKey.signature(for: data)
                let verify = publicKey.isValidSignature(sign, for: data)
                assert(verify, "Failed verification of signature of data by public Key from JWK")
            }
        } else {
            assertionFailure("Unable to produce PublicKey or PrivateKey from JWK")
        }
    }
}

// Test JWK Base class encode decode
extension KeySupportTests {
    func testJWKEncodeDecode() throws {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        
        if let jwkData = ed25519_pbk.data(using: .utf8) {
            let jwk = try jsonDecoder.decode(jwk_base.self, from: jwkData)
            
            let jwkJson = try jsonEncoder.encode(jwk)
            
            print(String(data: jwkJson, encoding: .utf8)!)
        }
    }
}
