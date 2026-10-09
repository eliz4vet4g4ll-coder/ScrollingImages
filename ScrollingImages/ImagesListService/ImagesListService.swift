import UIKit
import os

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    private static let dateFormatter = ISO8601DateFormatter()

    init(from photoResult: PhotoResult) {
        self.init(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: photoResult.createdAt.flatMap { Photo.dateFormatter.date(from: $0) },
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
}

final class ImagesListService {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "ImagesListService")
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        // Запрос уже идёт — не прерываем его и не создаём новый
        guard task == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makePhotosRequest(page: nextPage) else {
            logger.error("[ImagesListService.fetchPhotosNextPage]: failed to create request, page: \(nextPage)")
            return
        }

        // objectTask вызывает completion на главном потоке
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                logger.error("[ImagesListService.fetchPhotosNextPage]: \(type(of: error)) - \(error), page: \(nextPage)")
            }
            self.task = nil
        }

        self.task = task
        task.resume()
    }

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")
        else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10")
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
