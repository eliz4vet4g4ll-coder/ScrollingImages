import UIKit
import WebKit

@MainActor
final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() {}

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        cleanCookies()
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
        switchToSplashScreen()
    }

    private func cleanCookies() {
        // Чистим cookie
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)

        // Чистим данные WebView (сессия Unsplash хранится здесь)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }

    // сплэш сам покажет авторизацию, так как токена уже нет
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.currentKeyWindow else {
            assertionFailure("Failed to switch to SplashViewController")
            return
        }
        window.rootViewController = SplashViewController()
    }
}
