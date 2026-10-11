import UIKit
import Kingfisher

// экран полноэкранного просмотра фото
final class SingleImageViewController: UIViewController {
    var fullImageURL: URL?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    // поделиться картинкой
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {return}
        
        let sharePic = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(sharePic, animated: true)
        }
    
    @IBOutlet private var imageView: UIImageView!
    
    // возврат назад
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImage()
    }
    
    // загрузка полноразмерной картинки
    private func loadImage() {
        guard let fullImageURL else {return}
        
        scrollView.setZoomScale(1, animated: false)
        scrollView.contentInset = .zero
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {return}
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    // алерт с ошибкой загрузки
    private func showError() {
        let alert = UIAlertController(
            title: nil,
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        present(alert, animated: true)
    }
    
    // масштабирование и центрирование картинки
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.setZoomScale(1, animated: false)
        imageView.frame.size = image.size
        
        // рескейл
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        
        // центрирование
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}



// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    // view для зума
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // центрирование картинки после зума
    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat)
    {
        guard let view = view else { return }
        
        let h = max(0, (scrollView.bounds.width - view.frame.width) / 2)
        let v = max(0, (scrollView.bounds.height - view.frame.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: v, left: h, bottom: v, right: h)
    }
}
