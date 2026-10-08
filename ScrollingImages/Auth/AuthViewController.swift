import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
    
final class AuthViewController: UIViewController{
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Ок", style: .default)
        )

        present(alert, animated: true)
    }
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        super.prepare(for: segue, sender: sender)
        
        if let viewController = segue.destination as? WebViewViewController {
            viewController.delegate = self
        }
    }
}

    
    
extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) // Закрыли WebView

        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code) { result in
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                let storage = OAuth2TokenStorage.shared
                storage.token = token
                self.delegate?.didAuthenticate(self)

            case .failure(let error):
                self.showAuthErrorAlert()
            }
        }
    }
        
        func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
            dismiss(animated: true)
        }
}

