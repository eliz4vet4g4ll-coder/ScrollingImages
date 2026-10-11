import UIKit
import Kingfisher

// экран ленты фотографий
class ImagesListViewController: UIViewController {
    // идентификатор перехода на полноэкранный просмотр и имя ассета-заглушки
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let placeholderImageName = "loading_pic"
    @IBOutlet private var tableView: UITableView!

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


    // сервис загрузки фото, подписка на его уведомления и фото, которые показывает таблица
    private let imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    var photos: [Photo] = []

    // форматтер даты под фото (например, «10 октября 2026 г.»)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 12, right: 0)

        // подписываемся на появление новых фото в сервисе
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        // запрашиваем первую страницу фото
        imagesListService.fetchPhotosNextPage()
    }

    // обновляем таблицу, добавляя только новые ячейки
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

    // передаём ссылку на большое фото экрану полноэкранного просмотра
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
    // создаём и заполняем ячейку для строки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath) // получаем нужную ячейку

        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        } // приводим ячейку к нужному типу, для работы с ней

        imageListCell.delegate = self // контроллер обрабатывает нажатия на лайк
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
    // заполняем ячейку данными фото: картинка, дата, лайк
    func configCell(for cell: ImageListCell, with indexPath: IndexPath){
        let photo = photos[indexPath.row]

        // фото: грузим превью через Kingfisher, пока грузится — крутилка и заглушка
        cell.imgLabel.kf.indicatorType = .activity
        cell.imgLabel.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: placeholderImageName)
        ) { [weak self] result in
            // перезагружаем строку только после загрузки из сети: картинка из кэша
            // приходит синхронно и reloadRows вызвал бы бесконечную перерисовку
            guard case .success(let value) = result, value.cacheType == .none else { return }
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        // дата создания фото (если её нет — пустая строка)
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }

        // лайк: активное или неактивное сердечко
        cell.setIsLiked(photo.isLiked)
    }
}


// MARK: - UITableViewDelegate
extension ImagesListViewController {
    // Этот метод отвечает за действия, которые будут выполнены при тапе по ячейке таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    // метод для вычисления высоты ячейки по картинке
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let imageSize = photos[indexPath.row].size
        guard imageSize.width > 0 else {return 0}
        let imageWidht = tableView.bounds.width - 32
        let imageHeight = (imageWidht * imageSize.height) / imageSize.width
        return imageHeight + 8
    }

    // подгружаем следующую страницу, когда показывается последняя ячейка
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    // нажали на лайк в ячейке: отправляем запрос и обновляем сердечко
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        // находим строку, в которой нажали лайк
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            // успех: берём обновлённые фото из сервиса и перерисовываем лайк
            case .success:
                guard let self else { return }
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            // ошибка: показываем алерт
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
