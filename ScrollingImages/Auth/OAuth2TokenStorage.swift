import Foundation

final class OAuth2TokenStorage{
    private let tokenKey = "bearerToken"
    
    var token: String?{
        get{
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
