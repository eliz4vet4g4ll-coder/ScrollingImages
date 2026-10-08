import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
    }
}
