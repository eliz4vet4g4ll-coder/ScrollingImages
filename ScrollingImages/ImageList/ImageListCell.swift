import UIKit
import Kingfisher

// делегат ячейки: через него ячейка сообщает о нажатии на лайк
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell{
    static let reuseIdentifier = "ImageListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // состояние картинки: загрузка — градиент, готово — фото, ошибка — заглушка
    var imageState: FeedCellImageState? {
        didSet {
            switch imageState {
            case .loading:
                imgLabel.image = nil
                imgLabel.showGradientLoading(cornerRadius: 16)
            case .finished(let image):
                imgLabel.hideGradientLoading()
                imgLabel.image = image
            case .error:
                imgLabel.hideGradientLoading()
                imgLabel.image = UIImage(resource: .loadingPic)
            case nil:
                imgLabel.hideGradientLoading()
                imgLabel.image = nil
            }
        }
    }
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgLabel: UIImageView!
    
    // нажатие на лайк
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // отмена загрузки картинки при переиспользовании ячейки
    override func prepareForReuse() {
        super.prepareForReuse()
        imgLabel.kf.cancelDownloadTask()
        imageState = nil
    }

    // виньетка
    private let vignetteLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        layer.locations = [0.6, 1]
        layer.startPoint = CGPoint(x: 0.3, y: 0.3)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    // ставит картинку лайка
    func setIsLiked(_ isLiked: Bool) {
        let likeImage: UIImage
        if isLiked {
            likeImage = UIImage(resource: .favouriteActive)
        }
        else {
            likeImage = UIImage(resource: .favouriteNotActive)
        }
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // скругление и виньетка
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLabel.layer.cornerRadius = 16
        imgLabel.layer.masksToBounds = true
        imgLabel.layer.addSublayer(vignetteLayer)
    }

    // размер виньетки под картинку
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        vignetteLayer.frame = imgLabel.bounds
        CATransaction.commit()
    }
}
