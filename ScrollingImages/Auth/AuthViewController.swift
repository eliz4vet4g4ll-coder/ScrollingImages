import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
    
final class AuthViewController: UIViewController{
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service()

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBackground")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
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
        
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print(error)
            }
        }
    }
        
        func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
            dismiss(animated: true)
        }
}

