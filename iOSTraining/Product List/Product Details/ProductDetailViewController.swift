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
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
    
    
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
           isFeaturedLabel.text = isFeaturedLabel.text?.uppercased()

           productCategoryLabel.layer.cornerRadius = 10
           productCategoryLabel.clipsToBounds = true
           productCategoryLabel.text = productCategoryLabel.text?.uppercased()

           productRatingReviewLabel.layer.cornerRadius = 10
           productRatingReviewLabel.clipsToBounds = true

           self.title = product.title
           productNameLabel.text = product.title
           productDescriptionLabel.text = product.description
           productCategoryLabel.text = product.category

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
    
    // MARK: - Button Actions
    
    @IBAction func addToWishlistTapped(_ sender: UIButton) {
        guard let product = product else { return }
        
        // Add to wishlist manager
        WishlistManager.shared.add(product: product)
        
        // Show success feedback
        let alert = UIAlertController(
            title: "Added to Wishlist",
            message: "\(product.title) has been added to your wishlist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func addToCartTapped(_ sender: UIButton) {
        guard let product = product else { return }
        
        // Add to cart manager
        CartManager.shared.add(product: product)
        
        // Show success feedback with animation
        let alert = UIAlertController(
            title: "Added to Cart",
            message: "\(product.title) has been added to your cart.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func buyNowTapped(_ sender: UIButton) {
        guard let product = product else { return }
        
        // Add to cart first
        CartManager.shared.add(product: product)
        
        // Navigate directly to checkout
        navigateToCheckout()
    }
    
    private func navigateToCheckout() {
        // Navigate to checkout screen
        // Since we're in a UIKit ViewController, we need to navigate to the SwiftUI Checkout view
        if let tabBarController = self.tabBarController {
            // Switch to Cart tab (index 2)
            tabBarController.selectedIndex = 2
            
            // Post notification to show checkout screen
            NotificationCenter.default.post(name: NSNotification.Name("ShowCheckoutScreen"), object: nil)
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
