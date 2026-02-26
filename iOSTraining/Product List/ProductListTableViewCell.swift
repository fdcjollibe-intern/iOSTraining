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
    
    
    
    
    var product: Product? {
        didSet {
            displayData()
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
            
            // Remove default cell background
            self.backgroundColor = .clear
            self.selectionStyle = .none
            
            // Setup corner radius for labels
            productIsFeatured.layer.cornerRadius = 10
            productIsFeatured.clipsToBounds = true
            
            productCategory.layer.cornerRadius = 10
            productCategory.clipsToBounds = true
            
            productReviewsLabel.layer.cornerRadius = 10
            productReviewsLabel.clipsToBounds = true
            
            productIsInStock.layer.cornerRadius = 10
            productIsInStock.clipsToBounds = true
            
        
    }
    
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func displayData() {
        
        
        productNameLabel.text = product?.name
        
        // Format price with thousand separators and 2 decimals
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        if let price = product?.price {
            productPriceLabel.text = "₱ \(formatter.string(from: NSNumber(value: price)) ?? "0.00")"
        }
        
        productDescription.text = product?.description
        productCategory.text = product?.category
        
        // Display stock status with padding
        if let inStock = product?.inStock {
            if inStock {
                productIsInStock.text = "  In Stock"
                productIsInStock.textColor = .label
            } else {
                productIsInStock.text = "  Out of Stock"
                productIsInStock.textColor = .systemPink
            }
        } else {
            productIsInStock.text = "  Stock Unknown"
            productIsInStock.textColor = .systemGray
        }
        
        // Display featured status
        if let isFeatured = product?.isFeatured, isFeatured {
            productIsFeatured.text = "FEATURED"
            productIsFeatured.isHidden = false
        } else {
            productIsFeatured.isHidden = true
            productIsFeatured.backgroundColor = .clear
        }
        
        // Load product image
        if let imageName = product?.image?.first {
            productImageView.image = UIImage(named: imageName)
            productImageView.contentMode = .scaleAspectFit
        } else {
            productImageView.image = UIImage(systemName: "photo")
            productImageView.contentMode = .scaleAspectFit
        }
        
        // Display rating with single green star
        if let rating = product?.rating, let reviewCount = product?.reviews {
            let attributedString = NSMutableAttributedString()
            
            // Add left padding
            attributedString.append(NSAttributedString(string: "  "))
            
            // Add green star icon
            let starImage = UIImage(systemName: rating > 0 ? "star.fill" : "star")
            if let image = starImage {
                let attachment = NSTextAttachment()
                // Use custom green color #21B485
                let greenColor = UIColor(red: 0x21/255.0, green: 0xB4/255.0, blue: 0x85/255.0, alpha: 1.0)
                attachment.image = image.withTintColor(greenColor)
                
                let font = productReviewsLabel.font ?? UIFont.systemFont(ofSize: 17)
                attachment.bounds = CGRect(x: 0, y: font.capHeight / 2 - 8, width: 16, height: 16)
                
                attributedString.append(NSAttributedString(attachment: attachment))
            }
            
            // Format review count
            let formattedCount: String
            if reviewCount >= 1000 {
                let thousands = reviewCount / 1000
                formattedCount = String(format: "%.1fK", thousands)
            } else {
                formattedCount = String(Int(reviewCount))
            }
            
            // add rating and review count
            let ratingText = NSAttributedString(string: " \(String(format: "%.1f", rating)) ◦ \(formattedCount)")
            attributedString.append(ratingText)
            
            productReviewsLabel.attributedText = attributedString
        } else {
            let attributedString = NSMutableAttributedString()
            
            // add left padding
            attributedString.append(NSAttributedString(string: "  "))
            
            // add empty star
            if let starImage = UIImage(systemName: "star") {
                let attachment = NSTextAttachment()
                attachment.image = starImage.withTintColor(.systemGray)
                
                let font = productReviewsLabel.font ?? UIFont.systemFont(ofSize: 17)
                attachment.bounds = CGRect(x: 0, y: font.capHeight / 2 - 8, width: 14, height: 14)
                
                attributedString.append(NSAttributedString(attachment: attachment))
            }
            
            let noRatingText = NSAttributedString(string: " No Reviews")
            attributedString.append(noRatingText)
            
            productReviewsLabel.attributedText = attributedString
            
        }
    }
}
    
