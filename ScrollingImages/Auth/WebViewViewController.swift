import UIKit
import WebKit


protocol WebViewViewControllerDelegate: AnyObject {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}


final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate?
    
    @IBOutlet weak var webView: WKWebView!
    let progressView = UIProgressView()
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        loadAuthView()
        setProgressView()
        updateProgress()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            })
    }

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Не удалось создать URLComponents из Unsplash URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Не удалось создать URL из URLComponents")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func setProgressView(){
        progressView.tintColor = .ypBackground
        progressView.progress = 0.5
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        progressView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ).isActive = true
            
            progressView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ).isActive = true
            
            progressView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

extension WebViewViewController: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
