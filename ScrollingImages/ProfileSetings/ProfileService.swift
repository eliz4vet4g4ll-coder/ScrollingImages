import Foundation
import os

struct Profile{
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "ProfileService")
     static let shared = ProfileService()
     private init() {} //делаем синглтаном

     private(set) var profile: Profile?

     private var task: URLSessionTask?
     private let urlSession = URLSession.shared

     func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
         assert(Thread.isMainThread)
         task?.cancel()

         guard let request = makeProfileRequest(token: token) else {
             logger.error("[ProfileService.fetchProfile]: failed to create request")
             completion(.failure(URLError(.badURL)))
             return
         }

     let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
         guard let self else { return }
         
         switch result {
         case .success(let profileResult):
            let name = [profileResult.firstName, profileResult.lastName]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")

            let profile = Profile(
                username: profileResult.username,
                name: name,
                loginName: "@\(profileResult.username)",
                bio: profileResult.bio
                )
             
                self.profile = profile
                completion(.success(profile))
             
            case .failure(let error):
                logger.error("[ProfileService.fetchProfile]: \(type(of: error)) - \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

     private func makeProfileRequest(token: String) -> URLRequest? {
         guard let url = URL(string: "https://api.unsplash.com/me") else {
             return nil
         }

         var request = URLRequest(url: url)
         request.httpMethod = HTTPMethod.get.rawValue
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         return request
     }
}
  
