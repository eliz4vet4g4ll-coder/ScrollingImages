import Foundation
import SwiftKeychainWrapper
import os

final class OAuth2TokenStorage{
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "OAuth2TokenStorage")
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let tokenKey = "Auth token"

    var token: String?{
        get{
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set{
            if let newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    logger.error("[OAuth2TokenStorage] Не удалось сохранить токен в Keychain")
                }
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
