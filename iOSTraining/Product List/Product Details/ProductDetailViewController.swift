//
//  ProductDetailViewController.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var isFeaturedLabel: UILabel!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productRatingReviewLabel: UILabel!
    @IBOutlet weak var productOverviewLabel: UILabel!
    @IBOutlet weak var productTopHiglhightLabel1: UILabel!
    @IBOutlet weak var productTopHiglhightLabel2: UILabel!
    @IBOutlet weak var productTopHiglhightLabel3: UILabel!
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    var product: Product?
        private let imageCellIdentifier = "ProductImageCollectionViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register collection view cell
        let imageNib = UINib(nibName: imageCellIdentifier, bundle: nil)
        productImageCollectionView.register(imageNib, forCellWithReuseIdentifier: imageCellIdentifier)
        productImageCollectionView.dataSource = self
        productImageCollectionView.delegate = self
        productImageCollectionView.isPagingEnabled = true
        productImageCollectionView.showsHorizontalScrollIndicator = false

        // Setup swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        productImageCollectionView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        productImageCollectionView.addGestureRecognizer(swipeRight)

        // Ensure page control updates after layout
        view.layoutIfNeeded()
        
        displayProductDetails()
    }
        
        private func displayProductDetails() {
            guard let product = product else { return }
            
            isFeaturedLabel.layer.cornerRadius = 10
            isFeaturedLabel.clipsToBounds = true
            
            productCategoryLabel.layer.cornerRadius = 10
            productCategoryLabel.clipsToBounds = true
            
            productRatingReviewLabel.layer.cornerRadius = 10
            productRatingReviewLabel.clipsToBounds = true
            
            self.title = product.name
            productNameLabel.text = product.name
            productDescriptionLabel.text = product.description
            productCategoryLabel.text = product.category
            
            productOverviewLabel.text = product.overview
            
            if let highlights = product.highlight {
                productTopHiglhightLabel1.text = highlights.count > 0 ? "• \(highlights[0])" : ""
                productTopHiglhightLabel2.text = highlights.count > 1 ? "• \(highlights[1])" : ""
                productTopHiglhightLabel3.text = highlights.count > 2 ? "• \(highlights[2])" : ""
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            productPriceLabel.text = "₱ \(formatter.string(from: NSNumber(value: product.price)) ?? "0.00")"
            
            if let isFeatured = product.isFeatured, isFeatured {
                isFeaturedLabel.text = "FEATURED"
                isFeaturedLabel.isHidden = false
            } else {
                isFeaturedLabel.isHidden = true
            }
            
            if let rating = product.rating, let reviews = product.reviews {
                productRatingReviewLabel.text = "\(String(format: "%.1f", rating)) (\(Int(reviews)) reviews)"
            } else {
                productRatingReviewLabel.text = "No reviews yet"
            }
            
            // Setup page control
            if let imageCount = product.image?.count {
                pageControl.numberOfPages = imageCount
                pageControl.currentPage = 0
            }
        }
        
        @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            guard let imageCount = product?.image?.count else { return }

            let currentPage = pageControl.currentPage

            if gesture.direction == .left {
                // Next image (don't loop)
                if currentPage < imageCount - 1 {
                    let nextIndexPath = IndexPath(item: currentPage + 1, section: 0)
                    productImageCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                    pageControl.currentPage = currentPage + 1
                }
            } else if gesture.direction == .right {
                // Previous image (don't loop)
                if currentPage > 0 {
                    let prevIndexPath = IndexPath(item: currentPage - 1, section: 0)
                    productImageCollectionView.scrollToItem(at: prevIndexPath, at: .centeredHorizontally, animated: true)
                    pageControl.currentPage = currentPage - 1
                }
            }
        }
    }

    extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return product?.image?.count ?? 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as? ProductImageCollectionViewCell {
                if let imageName = product?.image?[indexPath.item] {
                    cell.imageName = imageName
                }
                return cell
            }
            return UICollectionViewCell()
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let pageWidth = productImageCollectionView.bounds.width
            let currentPage = Int(scrollView.contentOffset.x / pageWidth)
            pageControl.currentPage = currentPage
        }
    }

    extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width - 32, height: 250)
        }
    }
