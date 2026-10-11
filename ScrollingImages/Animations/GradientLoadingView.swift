import UIKit

// состояние картинки в ячейке ленты
enum FeedCellImageState {
    case loading
    case error
    case finished(UIImage)
}

// вью с анимированным градиентом загрузки
final class GradientLoadingView: UIView {
    private static let animationKey = "locationsChange"
    private static let startLocations: [NSNumber] = [0, 0.1, 0.3]
    private static let endLocations: [NSNumber] = [0, 0.8, 1]

    // слой вью сам является градиентом, поэтому всегда совпадает с её bounds
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    init(cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        setUpGradient(cornerRadius: cornerRadius)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpGradient(cornerRadius: 0)
    }

    // настройка цветов и направления градиента
    private func setUpGradient(cornerRadius: CGFloat) {
        isUserInteractionEnabled = false
        gradientLayer.locations = Self.startLocations
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.masksToBounds = true
    }

    // запуск анимации градиента
    func startAnimating() {
        isHidden = false
        guard gradientLayer.animation(forKey: Self.animationKey) == nil else { return }

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = Self.startLocations
        animation.toValue = Self.endLocations
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: Self.animationKey)
    }

    // остановка анимации и удаление вью
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: Self.animationKey)
        isHidden = true
        removeFromSuperview()
    }
}

extension UIView {
    // показывает градиент загрузки поверх вью
    // minWidth / minHeight — чтобы градиент перекрывал лейбл, даже если текст короче, чем в макете
    func showGradientLoading(cornerRadius: CGFloat = 0, minWidth: CGFloat = 0, minHeight: CGFloat = 0) {
        // повторный вызов не добавляет второй градиент
        if let gradientView = gradientLoadingView {
            gradientView.startAnimating()
            return
        }

        let gradientView = GradientLoadingView(cornerRadius: cornerRadius)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)

        // размер = max(размер вью, минимальный размер)
        let equalWidth = gradientView.widthAnchor.constraint(equalTo: widthAnchor)
        equalWidth.priority = .defaultLow
        let equalHeight = gradientView.heightAnchor.constraint(equalTo: heightAnchor)
        equalHeight.priority = .defaultLow

        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gradientView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor),
            gradientView.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
            gradientView.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor),
            gradientView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            equalWidth,
            equalHeight
        ])

        gradientView.startAnimating()
    }

    // убирает градиент загрузки
    func hideGradientLoading() {
        gradientLoadingView?.stopAnimating()
    }

    private var gradientLoadingView: GradientLoadingView? {
        subviews.first { $0 is GradientLoadingView } as? GradientLoadingView
    }
}
