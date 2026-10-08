import Foundation
import os

struct OAuthTokenResponseBody: Decodable{
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service{
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "OAuth2Service")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            logger.error("Failed to create URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            logger.error("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void){
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            logger.error("[OAuth2Service.fetchOAuthToken]: AuthServiceError - повторный запрос с тем же code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            logger.error("[OAuth2Service.fetchOAuthToken]: AuthServiceError - не удалось создать запрос, code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let body):
                completion(.success(body.accessToken))
            case .failure(let error):
                logger.error("[OAuth2Service.fetchOAuthToken]: \(type(of: error)) - \(error), code: \(code)")
                completion(.failure(error))
            }
            
            // Отменённая старая задача не должна сбрасывать состояние новой
            if self.lastCode == code {
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
