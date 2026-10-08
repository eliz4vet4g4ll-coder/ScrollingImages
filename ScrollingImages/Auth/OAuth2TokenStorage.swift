import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage{
    private let tokenKey = "Auth token"

    var token: String?{
        get{
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set{
            if let newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("[OAuth2TokenStorage] Не удалось сохранить токен в Keychain")
                }
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
