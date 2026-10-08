import UIKit
import PhotosUI
import Kingfisher

final class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var label: UILabel!
    
    let imageView = UIImageView()
    let setProfileImage = UIButton()
    
    let nameLabel = UILabel()
    let userName = UILabel()
    let profileInfo = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setUpProfileImage()
        
        setProfileName()
        setUserName()
        setProfileInfo()
        exitButton()
        
        if let profile = profileService.profile {updateProfileDetails(profile: profile)}
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        let placeholder = UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70))
        setProfileImage.kf.setImage(with: url, for: .normal, placeholder: placeholder)
    }
    
    func setUpProfileImage(){
        let image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70))
        setProfileImage.setImage(image, for: .normal)
        
        setProfileImage.tintColor = .ypGray
        setProfileImage.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        
        setProfileImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(setProfileImage)
        
        setProfileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        setProfileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        setProfileImage.imageView?.contentMode = .scaleAspectFill
        setProfileImage.contentHorizontalAlignment = .fill
        setProfileImage.contentVerticalAlignment = .fill
        
        setProfileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32
        ).isActive = true

        setProfileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16
        ).isActive = true
        
        setProfileImage.layer.cornerRadius = 35
        setProfileImage.clipsToBounds = true
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self?.setProfileImage.setImage(image, for: .normal)
            }
        }
    }
    
    @objc
    private func didTapPhotoButton() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }
    
    func setProfileName(){
        nameLabel.text = "My Name"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nameLabel)
        
        nameLabel.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: setProfileImage.bottomAnchor, constant: 8).isActive = true
    }
    
    func setUserName(){
        userName.text = "@my_name"
        userName.textColor = .ypGray
        userName.font = .systemFont(ofSize: 13)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userName)
        
        userName.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
    }
    
    func setProfileInfo(){
        profileInfo.text = "Info"
        profileInfo.textColor = .ypWhite
        profileInfo.font = .systemFont(ofSize: 13)
        
        
        profileInfo.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(profileInfo)
        
        profileInfo.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileInfo.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
    }
        
    func exitButton(){
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(self.didTapButton)
        )
        exitButton.tintColor = .ypRed
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: setProfileImage.centerYAnchor).isActive = true
    }
        
    @objc
    private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
    
    // записывает данные в лейблы
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        userName.text = profile.loginName
        profileInfo.text = profile.bio
    }
}

