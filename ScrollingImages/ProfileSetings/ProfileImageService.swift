import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    struct ProfileImage: Codable {
        let small: String
    }

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService{
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange") // имя по которому узнаем, что URL аватарки получен
    private(set) var avatarURL: String?
     
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
     
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
 
        guard let request = makeProfileImageRequest(username: username) else {
            print("[ProfileImageService.fetchProfileImageURL]: failed to create request")
            completion(.failure(URLError(.badURL)))
            return
        }
 
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
 
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
 
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
 
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(type(of: error)) - \(error), username: \(username)")
                completion(.failure(error))
            }
            self.task = nil
        }
 
        self.task = task
        task.resume()
    }
     
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage().token,
            let url = URL(string: "https://api.unsplash.com/users/\(username)")
        else {
            return nil
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
