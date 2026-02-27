//
//  ImageViewerViewController.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/27/26.
//
import UIKit

class ImageViewerViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let closeButton = UIButton(type: .system)
    private var images: [String] = []
    private var currentIndex: Int = 0
    private var initialTouchPoint: CGPoint = .zero

    init(images: [String], startIndex: Int = 0) {
        self.images = images
        self.currentIndex = startIndex
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupScrollView()
        setupImageView()
        setupCloseButton()
        setupGestures()
        displayImage(at: currentIndex)
    }

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
    }

    private func setupCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    private func displayImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }

        imageView.image = nil
        let urlString = images[index]

        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(systemName: "photo")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.frame = CGRect(origin: .zero, size: self.view.bounds.size)
                self.scrollView.contentSize = self.imageView.bounds.size
                self.scrollView.zoomScale = 1.0
            }
        }.resume()

        imageView.frame = CGRect(origin: .zero, size: view.bounds.size)
        scrollView.contentSize = imageView.bounds.size
        scrollView.zoomScale = 1.0
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == 1.0 else { return }

        let touchPoint = gesture.location(in: view.window)

        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            let translation = touchPoint.y - initialTouchPoint.y
            if abs(translation) > 0 {
                view.frame.origin.y = translation
                view.alpha = 1.0 - abs(translation) / view.bounds.height
            }
        case .ended, .cancelled:
            let translation = touchPoint.y - initialTouchPoint.y
            if abs(translation) > 100 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                    self.view.alpha = 1.0
                }
            }
        default:
            break
        }
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard scrollView.zoomScale == 1.0 else { return }

        if gesture.direction == .left && currentIndex < images.count - 1 {
            currentIndex += 1
            displayImage(at: currentIndex)
        } else if gesture.direction == .right && currentIndex > 0 {
            currentIndex -= 1
            displayImage(at: currentIndex)
        }
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                   y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
