import UIKit


final class SplashViewController: UIViewController{
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    private var isFetchingProfile = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }

    private func setUpLayout() {
        view.backgroundColor = .ypBlack

        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func showAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        authViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                let window = windowScene.windows.first
        else {
                assertionFailure("Invalid window configuration")
                return
            }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = storage.token else { return }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        // после авторизации viewDidAppear вызывается повторно — не запускаем второй запрос
        guard !isFetchingProfile else { return }
        isFetchingProfile = true

        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }
            self.isFetchingProfile = false

            switch result {
            case .success(let profile):
            ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
                self.showProfileErrorAlert()
            }
        }
    }

    private func showProfileErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось загрузить профиль",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Ок", style: .default)
        )

        present(alert, animated: true)
    }
}
