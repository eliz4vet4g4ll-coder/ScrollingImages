import UIKit
import Kingfisher

// делегат ячейки: через него ячейка сообщает о нажатии на лайк
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell{
    static let reuseIdentifier = "ImageListCell"
    
    // делегат (контроллер ленты), weak — чтобы не было цикла сильных ссылок
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgLabel: UIImageView!
    
    // нажатие на лайк: сообщаем делегату (контроллеру), что по кнопке тапнули
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // перед переиспользованием ячейки отменяем незавершённую загрузку картинки,
    // чтобы старое фото не появилось в ячейке с другим фото
    override func prepareForReuse() {
        super.prepareForReuse()
        imgLabel.kf.cancelDownloadTask()
    }

    // затемнение по краям фото (виньетка)
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

    // ставим на кнопку активное или неактивное сердечко
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
    
    // разовая настройка после загрузки из storyboard: скругление и виньетка
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLabel.layer.cornerRadius = 16
        imgLabel.layer.masksToBounds = true
        imgLabel.layer.addSublayer(vignetteLayer)
    }

    // подгоняем размер виньетки под размер фото (без анимации)
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        vignetteLayer.frame = imgLabel.bounds
        CATransaction.commit()
    }
}
