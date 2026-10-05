import Foundation

struct OAuthTokenResponseBody: Decodable{
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service{
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Failed to create URLComponents")
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
            print("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String,completion: @escaping (Result<String, Error>) -> Void){
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to create OAuth token request")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем сетевую ошибку

            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {completion(.failure(error))
                }
                return
            }
            
            // Проверяем HTTP-ответ
            guard let response = response as? HTTPURLResponse else {return}
            
            // Проверяем статус-код
            guard 200..<300 ~= response.statusCode else {
                let error = NetworkError.httpStatusCode(response.statusCode)
                print("Unsplash error: \(error)")
                DispatchQueue.main.async {completion(.failure(error))}
                return
            }
            
            guard let data = data else {return}
            
            do {
                let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                
                DispatchQueue.main.async{
                    completion(.success(responseBody.accessToken))
                }
            }
            catch {
                print("Decoding error: \(error)")
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
