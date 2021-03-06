import CTLS

typealias CX509Key = UnsafeMutablePointer<X509>

extension RSAKey {
    public init(x509Cert cert: Bytes) throws {
        guard
            let cert = cert.withUnsafeBufferPointer({ rawKeyPointer -> CX509Key? in
                var base = rawKeyPointer.baseAddress
                let count = cert.count

                return d2i_X509(nil, &base, count)
            }) else {
                throw JWTError.createPublicKey
        }

        defer {
            X509_free(cert)
        }

        guard let pubkey = X509_get_pubkey(cert) else {
            throw JWTError.createPublicKey
        }

        defer {
            EVP_PKEY_free(pubkey)
        }

        guard let rsa = EVP_PKEY_get1_RSA(pubkey) else {
            throw JWTError.createPublicKey
        }

        self = .public(rsa)
    }
}

extension RSASigner {
    public init(x509Cert: Bytes) throws {
        try self.init(rsaKey: RSAKey(x509Cert: x509Cert))
    }
}
