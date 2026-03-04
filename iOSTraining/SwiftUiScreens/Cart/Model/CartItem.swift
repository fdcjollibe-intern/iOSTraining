//
//  Model.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import Foundation

struct CartItem: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let thumbnail: String?
    let category: String?
    let itemDescription: String?
    var quantity: Int
    
    // Discount info - only present if added during sale
    var discountPercentage: Double?
    var originalPrice: Double?
    
    var effectivePrice: Double {
        // If has discount info, use discounted price
        if let _ = discountPercentage, let _ = originalPrice {
            return price
        }
        return price
    }
    
    var displayOriginalPrice: Double? {
        return originalPrice
    }
    
    var total: Double {
        effectivePrice * Double(quantity)
    }
    
    var savings: Double {
        guard let original = originalPrice else { return 0 }
        return (original - price) * Double(quantity)
    }
}
