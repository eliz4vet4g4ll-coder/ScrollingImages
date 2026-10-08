import UIKit
import WebKit

@MainActor
final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() {}

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        cleanCookies()
        switchToAuthScreen()
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

    private func switchToAuthScreen() {
        guard
            let window = UIApplication.shared.currentKeyWindow,
            let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else {
            assertionFailure("Failed to switch to AuthViewController")
            return
        }
        authViewController.delegate = self

        window.rootViewController = UINavigationController(rootViewController: authViewController)
    }
}

extension ProfileLogoutService: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // После входа сплэш загрузит профиль и переключит на ленту
        UIApplication.shared.currentKeyWindow?.rootViewController = SplashViewController()
    }
}
