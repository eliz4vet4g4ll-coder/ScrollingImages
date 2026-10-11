import UIKit
import Kingfisher

// экран полноэкранного просмотра фото
final class SingleImageViewController: UIViewController {
    // ссылка на полноразмерное фото, её передаёт лента
    var fullImageURL: URL?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    // кнопка «Поделиться»: открываем системное меню отправки картинки
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {return}
        
        let sharePic = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(sharePic, animated: true)
        }
    
    @IBOutlet private var imageView: UIImageView!
    
    // кнопка «Назад»: закрываем экран
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // пределы масштабирования
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        // грузим фото по ссылке
        loadImage()
    }
    
    // загружаем полноразмерное фото по ссылке, на время загрузки блокируем UI
    private func loadImage() {
        guard let fullImageURL else {return}
        
        // сбрасываем зум и отступы от прошлой попытки (важно при «Повторить»)
        scrollView.setZoomScale(1, animated: false)
        scrollView.contentInset = .zero
        
        // пока грузится — блокирующий лоадер ProgressHUD
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {return}
            switch result {
            // успех: imageView в реальный размер картинки, затем подгоняем масштаб
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            // ошибка: предлагаем повторить загрузку
            case .failure:
                self.showError()
            }
        }
    }
    
    // алерт об ошибке загрузки с возможностью повторить
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
    
    // масштаб как aspect fill: фото заполняет экран, края обрезаются (их можно докрутить),
    // и ставим его по центру
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // размер imageView = реальный размер картинки (зум считаем от масштаба 1)
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
        
        // Центрирование
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}



// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    // какое view увеличивать жестом
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // после зума центрируем фото, если оно меньше экрана
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
