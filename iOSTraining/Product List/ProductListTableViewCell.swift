//
//  ProductListTableViewCell.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var productReviewsLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var productIsInStock: UILabel!
    
    @IBOutlet weak var productIsFeatured: UILabel!
    
    @IBOutlet weak var productCategory: UILabel!
    
    @IBOutlet weak var productContentView: UIView!
    
    
    private var currentImageURL: String?

        var product: Product? {
            didSet {
                displayData()
            }
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            self.accessoryType = .disclosureIndicator
            self.backgroundColor = .clear
            self.selectionStyle = .none

            productIsFeatured.layer.cornerRadius = 10
            productIsFeatured.clipsToBounds = true

            productCategory.layer.cornerRadius = 10
            productCategory.clipsToBounds = true

            productReviewsLabel.layer.cornerRadius = 10
            productReviewsLabel.clipsToBounds = true

            productIsInStock.layer.cornerRadius = 10
            productIsInStock.clipsToBounds = true
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            productImageView.image = nil
            currentImageURL = nil
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }

        private func displayData() {
            guard let product = product else { return }

            productNameLabel.text = product.title

            // Format price
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            productPriceLabel.text = "₱ \(formatter.string(from: NSNumber(value: product.price)) ?? "0.00")"

            productDescription.text = product.description
            productCategory.text = product.category?.uppercased()

            // Availability status
            let status = product.availabilityStatus ?? "Unknown"
            productIsInStock.text = "  \(status.uppercased())"
            if status.lowercased().contains("in stock") {
                productIsInStock.textColor = .label
            } else if status.lowercased().contains("out") {
                productIsInStock.textColor = .systemPink
            } else {
                productIsInStock.textColor = .systemGray
            }

            // Discount as "featured" badge
            if let discount = product.discountPercentage, discount >= 10.0 {
                productIsFeatured.text = "\(String(format: "%.0f", discount))% OFF".uppercased()
                productIsFeatured.isHidden = false
            } else {
                productIsFeatured.isHidden = true
                productIsFeatured.backgroundColor = .clear
            }

            // Load thumbnail image from URL
            let thumbnailURL = product.thumbnail ?? product.images?.first
            if let urlString = thumbnailURL, let url = URL(string: urlString) {
                currentImageURL = urlString
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self = self,
                          let data = data,
                          let image = UIImage(data: data),
                          self.currentImageURL == urlString else { return }
                    DispatchQueue.main.async {
                        self.productImageView.image = image
                        self.productImageView.contentMode = .scaleAspectFit
                    }
                }.resume()
            } else {
                productImageView.image = UIImage(systemName: "photo")
                productImageView.contentMode = .scaleAspectFit
            }

            // Rating and review count
            let rating = product.rating ?? 0.0
            let reviewCount = product.reviews?.count ?? 0

            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: "  "))

            let starImageName = rating > 0 ? "star.fill" : "star"
            if let starImage = UIImage(systemName: starImageName) {
                let attachment = NSTextAttachment()
                let greenColor = UIColor(red: 0x21/255.0, green: 0xB4/255.0, blue: 0x85/255.0, alpha: 1.0)
                attachment.image = starImage.withTintColor(rating > 0 ? greenColor : .systemGray)
                let font = productReviewsLabel.font ?? UIFont.systemFont(ofSize: 17)
                attachment.bounds = CGRect(x: 0, y: font.capHeight / 2 - 8, width: 16, height: 16)
                attributedString.append(NSAttributedString(attachment: attachment))
            }

            if reviewCount > 0 {
                let formattedCount = reviewCount >= 1000 ? String(format: "%.1fK", Double(reviewCount) / 1000) : "\(reviewCount)"
                attributedString.append(NSAttributedString(string: " \(String(format: "%.1f", rating)) ◦ \(formattedCount)".uppercased()))
            } else {
                attributedString.append(NSAttributedString(string: " NO REVIEWS"))
            }

            productReviewsLabel.attributedText = attributedString
        }
    }
