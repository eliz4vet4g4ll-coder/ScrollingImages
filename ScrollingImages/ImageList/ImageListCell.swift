import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell{
    static let reuseIdentifier = "ImageListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgLabel: UIImageView!
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
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


    func setIsLiked(_ isLiked: Bool) {
        let likeImage: UIImage
        if isLiked {
            likeImage = UIImage(resource: .favouriteActive)
        }
        else {
            likeImage = UIImage(resource: .favouriteNotActive)
        }
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? AccessibilityIdentifiers.likeButtonOn : AccessibilityIdentifiers.likeButtonOff
    }
    
    // разовая настройка после загрузки из storyboard: скругление и виньетка
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLabel.layer.cornerRadius = 16
        imgLabel.layer.masksToBounds = true
        imgLabel.layer.addSublayer(vignetteLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        vignetteLayer.frame = imgLabel.bounds
        CATransaction.commit()
    }
}
