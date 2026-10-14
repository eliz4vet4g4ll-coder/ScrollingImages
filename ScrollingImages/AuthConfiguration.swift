import Foundation

enum Constants {
    static let accessKey = infoValue(forKey: "UnsplashAccessKey")
    static let secretKey = infoValue(forKey: "UnsplashSecretKey")
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    // ключи попадают в Info.plist из Secrets.xcconfig
    private static func infoValue(forKey key: String) -> String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty
        else {
            fatalError("Не найден ключ \(key) в Info.plist. Создайте Secrets.xcconfig по образцу Secrets.example.xcconfig")
        }
        return value
    }
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    static var standard: AuthConfiguration {
        AuthConfiguration(accessKey: Constants.accessKey,
                          secretKey: Constants.secretKey,
                          redirectURI: Constants.redirectURI,
                          accessScope: Constants.accessScope,
                          defaultBaseURLString: Constants.defaultBaseURLString,
                          authURLString: Constants.unsplashAuthorizeURLString)
    }
}
