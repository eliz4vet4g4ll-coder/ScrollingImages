import UIKit
import ProgressHUD

@MainActor
final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.currentKeyWindow
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
