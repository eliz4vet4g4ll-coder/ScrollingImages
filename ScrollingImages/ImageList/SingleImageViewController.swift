import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?{
        didSet {
            guard isViewLoaded else {return}
            imageView.image = image
            imageView.frame.size = image!.size
            guard image != nil else {return}
            rescaleAndCenterImageInScrollView(image: image!)
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {return}
        
        let sharePic = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(sharePic, animated: true)
        }
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        
        guard image != nil else {return}
        imageView.image = image
        imageView.frame.size = image!.size
        rescaleAndCenterImageInScrollView(image: image!)
        }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // рескейл
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        
        // Центрирование
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}



extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
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
