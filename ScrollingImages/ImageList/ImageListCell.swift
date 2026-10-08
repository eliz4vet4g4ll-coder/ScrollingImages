import UIKit

final class ImageListCell: UITableViewCell{
    static let reuseIdentifier = "ImageListCell"
    
    
    @IBOutlet weak var setLikeButton: UIButton!
    @IBAction func likeButton(_ sender: Any) {
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgLabel: UIImageView!

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

    func setLike(isLike: Bool){
        let likeStatus: ImageResource = isLike ? .favouriteActive : .favouriteNotActive
        setLikeButton.setImage(UIImage(resource: likeStatus), for: .normal)
    }
    
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
