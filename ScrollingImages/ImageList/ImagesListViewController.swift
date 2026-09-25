import UIKit

class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView.register(ImageListCell.self, forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        
        // tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath) // получаем нужную ячейку
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        } // приводим ячейку к нужному типу, для работы с ней
        
        configCell(for: imageListCell, with: indexPath) // конфигурируем ячейку
        return imageListCell
    }
    
    
    // метод, который определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count // отвечает за кол-во фоток
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImageListCell, with indexPath: IndexPath){
        // фото
        let photoName = photosName[indexPath.row]
        guard let image = UIImage(named: photoName) else {return}
        cell.imgLabel.image = image
        
        // дата лейбл
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        // лайк
        if indexPath.row % 2 == 0{
            cell.setLike(isLike: true)
        }else{cell.setLike(isLike: false)}
    }
}


extension ImagesListViewController {
    // Этот метод отвечает за действия, которые будут выполнены при тапе по ячейке таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // метод для вычисления высоты ячейки по картинке
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        guard let image = UIImage(named: photosName[indexPath.row]) else {return 0}
        let imageWidht = tableView.bounds.width - 32
        let imageHeight = (imageWidht * image.self.size.height) / image.self.size.width
        return imageHeight + 8
    }
}
