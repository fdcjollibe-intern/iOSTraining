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

           let imageNib = UINib(nibName: imageCellIdentifier, bundle: nil)
           productImageCollectionView.register(imageNib, forCellWithReuseIdentifier: imageCellIdentifier)
           productImageCollectionView.dataSource = self
           productImageCollectionView.delegate = self
           productImageCollectionView.isPagingEnabled = true
           productImageCollectionView.showsHorizontalScrollIndicator = false

           let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
           swipeLeft.direction = .left
           productImageCollectionView.addGestureRecognizer(swipeLeft)

           let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
           swipeRight.direction = .right
           productImageCollectionView.addGestureRecognizer(swipeRight)

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

           self.title = product.title
           productNameLabel.text = product.title
           productDescriptionLabel.text = product.description
           productCategoryLabel.text = product.category

           // Overview: use description as overview since API doesn't have separate overview
           productOverviewLabel.text = product.description

           // Highlights: use category, availability, discount info
           productTopHiglhightLabel1.text = product.category != nil ? "• Category: \(product.category!)" : ""
           productTopHiglhightLabel2.text = product.availabilityStatus != nil ? "• \(product.availabilityStatus!)" : ""
           if let discount = product.discountPercentage {
               productTopHiglhightLabel3.text = "• \(String(format: "%.1f", discount))% Discount"
           } else {
               productTopHiglhightLabel3.text = ""
           }

           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           formatter.minimumFractionDigits = 2
           formatter.maximumFractionDigits = 2
           formatter.groupingSeparator = ","
           productPriceLabel.text = "₱ \(formatter.string(from: NSNumber(value: product.price)) ?? "0.00")"

           // Discount badge
           if let discount = product.discountPercentage, discount >= 10.0 {
               isFeaturedLabel.text = "\(String(format: "%.0f", discount))% OFF"
               isFeaturedLabel.isHidden = false
           } else {
               isFeaturedLabel.isHidden = true
           }

           // Rating and review count
           let rating = product.rating ?? 0.0
           let reviewCount = product.reviews?.count ?? 0
           if reviewCount > 0 {
               productRatingReviewLabel.text = "\(String(format: "%.1f", rating)) (\(reviewCount) reviews)"
           } else {
               productRatingReviewLabel.text = "No reviews yet"
           }

           // Page control
           let imageCount = product.images?.count ?? 0
           pageControl.numberOfPages = imageCount
           pageControl.currentPage = 0
       }

       @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
           guard let imageCount = product?.images?.count else { return }
           let currentPage = pageControl.currentPage

           if gesture.direction == .left, currentPage < imageCount - 1 {
               let nextIndexPath = IndexPath(item: currentPage + 1, section: 0)
               productImageCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
               pageControl.currentPage = currentPage + 1
           } else if gesture.direction == .right, currentPage > 0 {
               let prevIndexPath = IndexPath(item: currentPage - 1, section: 0)
               productImageCollectionView.scrollToItem(at: prevIndexPath, at: .centeredHorizontally, animated: true)
               pageControl.currentPage = currentPage - 1
           }
       }
   }

   extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return product?.images?.count ?? 0
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as? ProductImageCollectionViewCell {
               cell.imageURL = product?.images?[indexPath.item]
               return cell
           }
           return UICollectionViewCell()
       }

       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           guard let images = product?.images else { return }
           let imageViewer = ImageViewerViewController(images: images, startIndex: indexPath.item)
           present(imageViewer, animated: true)
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
