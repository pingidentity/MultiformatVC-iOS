# Swift Package for Multiformat VC

## Overview

Swift package for creating Verifiable Credentials (VCs) in multiple formats

- SD JWT "**Selective Disclosure for JWTs (SD-JWT)**" using the specification defined at https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/
- VC JWT "**Verifiable Credentials as JWTs**" using the format defined at JWT VC Presentation Profile https://identity.foundation/jwt-vc-presentation-profile/
- ISO 23220 mDoc format (coming soon)

Support for mulitple data types for disclosed values including

- String
- Int
- Boolean
- Array of Strings - [String]
- Dictionary of String keys and String values - [String:String]

## License

Apache License, Version 2.0

## Getting Started

### Swift Package Manager

Go to File > Swift Packages > Add Package Dependency and add the following URL:

```
https://github.com/pingidentity/MultiformatVC-iOS
```

## SDJWT

### Creating SD JWT format VC

The `SDJWT_Writer` class is used to create an SD JWT format Verifiable Credential. To instantiate the class you simply provide the signing algorithm and the Key ID

```swift
    let vcWriter = SDJWT_Creator(algorithm: "EdDSA", keyId: UUID().uuidString)
```

You can directly access the payload for defining other claims for the VC

```swift
      vcWriter.payload.jwtId = UUID().uuidString
      vcWriter.payload.subject = "did:jwk:ewogICAgImt0eSI6IC...iIKfQo"
      vcWriter.payload.issuer = "did:jwk:ewogICAgImt0eSI6IC...SIKfQo"
```

**Note:** issuer and subject edited for brevity

You can specify a `credentialSubject` for the Verifiable Credential. The `credentialSubject` is a dictionary with `String` keys. The values of the dictionary can be of following types

- String
- Int
- Bool
- Array of Strings - [String]
- Dictionary of String keys and String values - [String:String]

```swift
        vcWriter.setCredentialSubject([
            "name" : "John" ,
            "age": 25,
            "gender" : "male",
            "over_21" : true,
            "roles" : ["user", "reports_admin"]
        ])
```

You can also provide date claims like expiry, issued at and not before

```swift
        vcWriter.issuedAt.expiry = UInt64(Date().timeIntervalSince1970)
        vcWriter.payload.expiry = UInt64(futureDateByAddingMonths(1).timeIntervalSince1970)
```

Once the instance of the `VCJWT_Writer` class has been setup you can call the `getEncodedVC` method to get the SD JWT encoded VC

```swift
    try vcWriter.getEncodedVC()
```

You can provide an **optional** `hashAlgorithm` parameter to the `getEncodedVC` method. The `hashAlgorithm` parameter accepts an enum `HashAlgorithm`. This is used to request the `getEncodedVC` method to use one of the three supported hash algorithms for creating the digests in the `_sd` claim.

- sha-256 (default value)
- sha-384
- sha-512

```swift
    try vcWriter.getEncodedVC(hashAlgorithm: HashAlgorithm.SHA_512)
```

You can also provide an **optional** `decoyDigests` parameter to the `getEncodedVC` method. The `decoyDigests` parameter accepts an Integer. This value is used to determine how many extra decoy digests will be created in the `_sd` claim.

_Note_: default value is 0

```swift
    try vcWriter.getEncodedVC(decoyDigests: 5)
```

Once the Encoded JWT is created it can be shared with the holder. An example encoded SD JWT based on the above calls is shared here:

```swift
eyJhbGciOiJFZERTQSIsInR5cCI6InZjK3NkLWp3dCIsImtpZCI6IjQyMzk3NkQ5LTczQUQtNEJFMC05NjNFLURCRDFDQzI4Qjc0MCJ9.eyJfc2QiOlsiMk5RYzExZjR0V3pNUHg3SGhMRzVaU2NndUlwVExiTTNzZ2x5dWstSEZQdyIsImd6V0p2bEtYdldCQnoyclNtdGZnUjlvYjVFYUhMeE1SdEQ0UmJrcTh6RU0iLCJHUWN2WVIxZFFKa1R4eUJRdThZcE9BZVE2N0RiTmVQOEhTempENS1OY3pzIiwiallidENCa3YxSzR1V1loV1dNSVNmbXYxWHRyTm92aXhtcW5femxzU29xayIsIkV4X0pDRS1jem5oV2VYNGpWcGdLVUw1aU4tYk9DOGxrMFpVcDAtOTE3cDgiXSwiaXNzIjoiZGlkOmp3azpzZGtzYWRma2phc2xma2phc2RmbGtqYWRsZmsiLCJleHAiOjE3MDQ2NTI3MTgsInN1YiI6ImRpZDpqd2s6bGRrZmpzYWxkZmtqc2FkbGZramFzZGZsa2oiLCJfc2RfYWxnIjoic2hhLTI1NiJ9.khYZCYUc1ebfVIq8MyUigxmB~WyJDWkNJT1MwZmtOWmxYNjdIV1BjVjlxeUd1eUlFSXVDdWllT3JnWXRLcS1jIiwiZ2VuZGVyIiwibWFsZSJd~WyJZMjdqVkJLRVFkUTF5OUVXS3FkTEVjbWVmMWNwVWNOQmJvUDFORThuZ0ZjIiwib3Zlcl8yMSIsdHJ1ZV0~WyIzampKNHRSdlNXd3F1ZGpueVJKX2V3MjJKakkxc2Vaa243NEZuMnBkMHc0IiwibmFtZSIsIkpvaG4iXQ~WyJIRUpjWWFUOC1XRnB4aFRUT0t1U2lMblVkdGRaMnc1N0JHQVVPUWZPYllvIiwicm9sZXMiLFsidXNlciIsInJlcG9ydHNfYWRtaW4iXV0~WyItNjUtcXpDbGcyLXJtVFEteWdobnh0aUxXWU12R25HWlhtUVU4ZURMSV9nIiwiYWdlIiwyNV0
```

To create a signed SD JWT you need to provide the `signer` method to the `SDJWT_Creator` instance. Here is an example

```swift
    let privateKey = Curve25519.Signing.PrivateKey()
    let signer:(Data) throws -> Data = {(data) in
        return try privateKey.signature(for: data)
    }
```

When a signer function is provided the output of the getEncodedVC() will look slightly different

```
eyJ0eXAiOiJ2YytzZC1qd3QiLCJraWQiOiJDNzY1QzZCQi0xOUI0LTQ2QTYtQTcxNC03NjBGRkJEQjJBMTIiLCJhbGciOiJFZERTQSJ9.eyJzdWIiOiJkaWQ6andrOmxka2Zqc2FsZGZranNhZGxma2phc2RmbGtqIiwiaXNzIjoiZGlkOmp3azpzZGtzYWRma2phc2xma2phc2RmbGtqYWRsZmsiLCJfc2RfYWxnIjoic2hhLTI1NiIsIl9zZCI6WyJLU3RmYUNsZTZDMUgxMU56ZW9vTWRaeXBXeU56VXVSSmpubXk5RlFnVGlBIiwiUS1BU3BwTGwwZXpXUTdubGRBUmpSY09IM1BNemJGRUVkMC1UQ0pFMVlJayIsInBRUFJfelVaVDdKY3NlODhEbWpXbnFZZGQ5OUNGb3VtbGR3WXY5cEYyZVUiLCJibGI3QmlWeHpoTmdtMkExMXA0bVItWUc3d2hoNEd0WGQzZWVlSFpwbUNVIiwiRGhWVjZ1TzNHQ190TUF3ajZxNGpqdEo4eUljUHFYQnoteGZac2ptWFhCMCJdLCJleHAiOjE3MDQ0NzY0Njh9.2zeB_qy5uJj1tZbPKIhlOfoO5ECKgTghCFBOVfnY4yWa3HkbbIBEppJwgPLVsFfy8qjjT_p-wyHjPMWJI4bBBQ~WyJKUEwwSnVTOG5FeU1BNWR5ZmthZ2lCYUU1NmhzTnlZcElkdmlRNTVINy0wIiwiZ2VuZGVyIiwibWFsZSJd~WyJHTmZ2WWZtYktCVTVjeEhJYTNRQUV5bl9Da3ZLUVRnUE1ubXo0SmpqdU9vIiwiYWdlIiwyNV0~WyJHeVFDdVZna1pZdGdyV1lUTXRVM0ZfVDBGczRqT2pIVVp4Wk1mZnFILTdvIiwicm9sZXMiLFsidXNlciIsInJlcG9ydHNfYWRtaW4iXV0~WyJteGxxQXE3ZWJDY29sNjZoRU9ya2p3eEIzTl91cnZWcmVPUzdCNTQ5SnlnIiwib3Zlcl8yMSIsdHJ1ZV0~WyJkaHRGaGpVUjhjb1hUcDdpaGJaLU1qMmVvblR4bXFhT3pJakpHVXNXQTk4IiwibmFtZSIsIkpvaG4iXQ
```

### Reading an encoded SD JWT format VC

The `SDJWT` class is used to read an SD JWT format Verifiable Credential. To instantiate the class you simply encoded SD JWT

```swift
    let sdjwt = "eyJ0eXAiOiJ2YytzZC1qd3QiLCJraWQiOiJDNzY1QzZCQi0xOUI0LTQ2QTYtQTcxNC03NjBGRkJEQjJBMTIiLCJhbGciOiJFZERTQSJ9.eyJzdWIiOiJkaWQ6andrOmxka2Zqc2FsZGZranNhZGxma2phc2RmbGtqIiwiaXNzIjoiZGlkOmp3azpzZGtzYWRma2phc2xma2phc2RmbGtqYWRsZmsiLCJfc2RfYWxnIjoic2hhLTI1NiIsIl9zZCI6WyJLU3RmYUNsZTZDMUgxMU56ZW9vTWRaeXBXeU56VXVSSmpubXk5RlFnVGlBIiwiUS1BU3BwTGwwZXpXUTdubGRBUmpSY09IM1BNemJGRUVkMC1UQ0pFMVlJayIsInBRUFJfelVaVDdKY3NlODhEbWpXbnFZZGQ5OUNGb3VtbGR3WXY5cEYyZVUiLCJibGI3QmlWeHpoTmdtMkExMXA0bVItWUc3d2hoNEd0WGQzZWVlSFpwbUNVIiwiRGhWVjZ1TzNHQ190TUF3ajZxNGpqdEo4eUljUHFYQnoteGZac2ptWFhCMCJdLCJleHAiOjE3MDQ0NzY0Njh9.2zeB_qy5uJj1tZbPKIhlOfoO5ECKgTghCFBOVfnY4yWa3HkbbIBEppJwgPLVsFfy8qjjT_p-wyHjPMWJI4bBBQ~WyJKUEwwSnVTOG5FeU1BNWR5ZmthZ2lCYUU1NmhzTnlZcElkdmlRNTVINy0wIiwiZ2VuZGVyIiwibWFsZSJd~WyJHTmZ2WWZtYktCVTVjeEhJYTNRQUV5bl9Da3ZLUVRnUE1ubXo0SmpqdU9vIiwiYWdlIiwyNV0~WyJHeVFDdVZna1pZdGdyV1lUTXRVM0ZfVDBGczRqT2pIVVp4Wk1mZnFILTdvIiwicm9sZXMiLFsidXNlciIsInJlcG9ydHNfYWRtaW4iXV0~WyJteGxxQXE3ZWJDY29sNjZoRU9ya2p3eEIzTl91cnZWcmVPUzdCNTQ5SnlnIiwib3Zlcl8yMSIsdHJ1ZV0~WyJkaHRGaGpVUjhjb1hUcDdpaGJaLU1qMmVvblR4bXFhT3pJakpHVXNXQTk4IiwibmFtZSIsIkpvaG4iXQ"
    let vc = try SDJWT(from: sdjwt)
```

If the `SDJWT` constructor successfully returns the class allows access to the `disclosures` array.

```swift
    let disclosures:[String:Any] = vc.disclosures
```

You can call the `verifySignature` methods to validate the signature of a signed SD-JWT by calling the `verifySignature` method of the `SDJWT` instance with a function to verify the signature

```swift
    let privateKey =  Curve25519.Signing.PrivateKey()
    if try vc.verifySignature(verifier: {(signature:Data, data: Data) in
            return keyPair.1.isValidSignature(signature, for: data)
        }) {
          ... // Signature verified successfully
        }
```

## VCJWT

### Creating JWT formatted VC

The `VCJWT_Writer` class is used to create an JWT formatted Verifiable Credential. To instantiate the class you simply provide the signing algorithm and the Key ID

```swift
    let vcWriter = VCJWT_Creator(algorithm: "EdDSA", keyId: UUID().uuidString)
```

You can directly access the payload for defining other claims for the VC

```swift
      vcWriter.payload.jwtId = UUID().uuidString
      vcWriter.payload.subject = "did:jwk:ewogICAgImt0eSI6IC...iIKfQo"
      vcWriter.payload.issuer = "did:jwk:ewogICAgImt0eSI6IC...SIKfQo"
```

**Note:** issuer and subject edited for brevity

You can specify a `credentialSubject` for the Verifiable Credential. The `credentialSubject` is a dictionary with `String` keys. The values of the dictionary can be of following types

- String
- Int
- Bool
- Array of Strings - [String]
- Dictionary of String keys and String values - [String:String]

```swift
    vcWriter.setCredentialSubject([
      "name" : "John" ,
      "age": 25,
      "gender" : "male",
      "over_21" : true,
      "roles" : ["user", "reports_admin"]
    ])

```

You can also provide date claims like expiry, issued at and not before

```swift
        vcWriter.payload.issuedAt = UInt64(Date().timeIntervalSince1970)
        vcWriter.payload.expiry = UInt64(futureDateByAddingMonths(1).timeIntervalSince1970)
```

Once the instance of the `SDJWT_Writer` class has been setup you can call the `getEncodedVC` method to get the SD JWT encoded VC

```swift
    try vcWriter.getEncodedVC()
```

Once the Encoded JWT is created it can be shared with the holder. An example encoded SD JWT based on the above calls is shared here:

```
eyJraWQiOiIxMEYxOEZDRS00QjhGLTQ4RjQtOTIxOS0zRkI0MDg1NjkyMjciLCJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJpc3N1ZXIiLCJzdWIiOiJzdWJqZWN0IiwianRpIjoiMTgwMzhBODUtM0MxRS00RDQyLTk1RDctOEMzQURFMENFMTc4IiwidmMiOnsidHlwZSI6WyJWZXJpZmllZEVtcGxveWVlIl0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7Im5hbWUiOiJKb2huIiwicm9sZXMiOlsidXNlciIsInJlcG9ydHNfYWRtaW4iXSwiZ2VuZGVyIjoibWFsZSIsImFnZSI6MjUsIm92ZXJfMjEiOnRydWV9fX0.N5125_lpu1uCpd8H2STWEPpBsY6huRzAyVZ-a-Eh6Bwxuh6Wqd7vx6XxjKzR6_YMhJdGuHypRWYD-gzf4jc8CQ
```

To create a signed SD JWT you need to provide the `signer` method to the `SDJWT_Creator` instance. Here is an example

```swift
    let privateKey = Curve25519.Signing.PrivateKey()
    let signer:(Data) throws -> Data = {(data) in
        return try privateKey.signature(for: data)
    }
```

When a signer function is provided the output of the getEncodedVC() will look slightly different

```
eyJraWQiOiIxMEYxOEZDRS00QjhGLTQ4RjQtOTIxOS0zRkI0MDg1NjkyMjciLCJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJpc3N1ZXIiLCJzdWIiOiJzdWJqZWN0IiwianRpIjoiMTgwMzhBODUtM0MxRS00RDQyLTk1RDctOEMzQURFMENFMTc4IiwidmMiOnsidHlwZSI6WyJWZXJpZmllZEVtcGxveWVlIl0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7Im5hbWUiOiJKb2huIiwicm9sZXMiOlsidXNlciIsInJlcG9ydHNfYWRtaW4iXSwiZ2VuZGVyIjoibWFsZSIsImFnZSI6MjUsIm92ZXJfMjEiOnRydWV9fX0
```

#### Reading an encoded JWT format VC

The `VCJWT` class is used to read an JWT formatted Verifiable Credential. To instantiate the class you simply encoded SD JWT

```
    let vcjwt = "eyJ0eXAiOiJ2YytzZC1qd3QiLCJraWQiOiJDNzY1QzZCQi0xOUI0LTQ2QTYtQTcxNC03NjBGRkJEQjJBMTIiLCJhbGciOiJFZERTQSJ9.eyJzdWIiOiJkaWQ6andrOmxka2Zqc2FsZGZranNhZGxma2phc2RmbGtqIiwiaXNzIjoiZGlkOmp3azpzZGtzYWRma2phc2xma2phc2RmbGtqYWRsZmsiLCJfc2RfYWxnIjoic2hhLTI1NiIsIl9zZCI6WyJLU3RmYUNsZTZDMUgxMU56ZW9vTWRaeXBXeU56VXVSSmpubXk5RlFnVGlBIiwiUS1BU3BwTGwwZXpXUTdubGRBUmpSY09IM1BNemJGRUVkMC1UQ0pFMVlJayIsInBRUFJfelVaVDdKY3NlODhEbWpXbnFZZGQ5OUNGb3VtbGR3WXY5cEYyZVUiLCJibGI3QmlWeHpoTmdtMkExMXA0bVItWUc3d2hoNEd0WGQzZWVlSFpwbUNVIiwiRGhWVjZ1TzNHQ190TUF3ajZxNGpqdEo4eUljUHFYQnoteGZac2ptWFhCMCJdLCJleHAiOjE3MDQ0NzY0Njh9.2zeB_qy5uJj1tZbPKIhlOfoO5ECKgTghCFBOVfnY4yWa3HkbbIBEppJwgPLVsFfy8qjjT_p-wyHjPMWJI4bBBQ~WyJKUEwwSnVTOG5FeU1BNWR5ZmthZ2lCYUU1NmhzTnlZcElkdmlRNTVINy0wIiwiZ2VuZGVyIiwibWFsZSJd~WyJHTmZ2WWZtYktCVTVjeEhJYTNRQUV5bl9Da3ZLUVRnUE1ubXo0SmpqdU9vIiwiYWdlIiwyNV0~WyJHeVFDdVZna1pZdGdyV1lUTXRVM0ZfVDBGczRqT2pIVVp4Wk1mZnFILTdvIiwicm9sZXMiLFsidXNlciIsInJlcG9ydHNfYWRtaW4iXV0~WyJteGxxQXE3ZWJDY29sNjZoRU9ya2p3eEIzTl91cnZWcmVPUzdCNTQ5SnlnIiwib3Zlcl8yMSIsdHJ1ZV0~WyJkaHRGaGpVUjhjb1hUcDdpaGJaLU1qMmVvblR4bXFhT3pJakpHVXNXQTk4IiwibmFtZSIsIkpvaG4iXQ"
    let vc = try VCJWT(from: sdjwt)
```

If the `VCJWT` constructor successfully you can access the credentialSubject from the decoded payload

```swift
    let credentialSubject:[String:Any] = vc.getCredentialSubject()
```

You can call the `verifySignature` methods to validate the signature of a signed JWT by calling the `verifySignature` method of the `VDJWT` instance with a function to verify the signature

```swift
    let privateKey =  Curve25519.Signing.PrivateKey()
    if try vc.verifySignature(verifier: {(signature:Data, data: Data) in
            return keyPair.1.isValidSignature(signature, for: data)
        }) {
          ... // Signature verified successfully
        }
```
