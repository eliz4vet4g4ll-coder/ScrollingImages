import UIKit
import Kingfisher

// экран ленты фотографий
class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


    private let imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    var photos: [Photo] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 12, right: 0)

        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }

    // добавление новых ячеек в таблицу
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    // передача ссылки на фото в SingleImage
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                print("Invalid segue destination")
                return
            }

            viewController.fullImageURL = URL(string: photos[indexPath.row].largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath) // получаем нужную ячейку

        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        } // приводим ячейку к нужному типу, для работы с ней

        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath) // конфигурируем ячейку
        return imageListCell
    }


    // метод, который определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count // отвечает за кол-во фоток
    }
}

// MARK: - Настройка ячейки
extension ImagesListViewController {
    // заполнение ячейки данными фото
    func configCell(for cell: ImageListCell, with indexPath: IndexPath){
        let photo = photos[indexPath.row]

        // фото
        cell.imageState = .loading
        cell.imgLabel.kf.setImage(with: URL(string: photo.thumbImageURL)) { [weak self] result in
            switch result {
            case .success(let value):
                cell.imageState = .finished(value.image)
                guard value.cacheType == .none else { return }
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                // отмена при переиспользовании ячейки — не ошибка
                guard !error.isTaskCancelled, !error.isNotCurrentTask else { return }
                cell.imageState = .error
            }
        }

        // дата лейбл
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }

        // лайк
        cell.setIsLiked(photo.isLiked)
    }
}


// MARK: - UITableViewDelegate
extension ImagesListViewController {
    // действия, которые будут выполнены при тапе по ячейке таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    // вычисление высоты ячейки по картинке
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let imageSize = photos[indexPath.row].size
        guard imageSize.width > 0 else {return 0}
        let imageWidht = tableView.bounds.width - 32
        let imageHeight = (imageWidht * imageSize.height) / imageSize.width
        return imageHeight + 8
    }

    // подгрузка следующей страницы на последней ячейке
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    // нажатие на лайк в ячейке
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success:
                guard let self else { return }
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure:
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: nil,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}
