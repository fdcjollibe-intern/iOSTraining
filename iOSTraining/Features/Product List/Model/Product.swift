//
//  Product.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//  from swiftuikit 

import Foundation

// MARK: - Discount Helper

struct DiscountInfo {
    let discountPercentage: Double
    let badgeLabel: String
    let tag: String?
}

/// Deterministic fake discount derived from product id — stable across reloads
func fakeDiscount(for product: Product) -> DiscountInfo {
    let seed = abs(product.id)
    let percents = [10, 15, 20, 25, 30, 35, 40, 50]
    let tags: [String?] = ["Best Seller", "Hot 🔥", "Top Pick", nil, nil, "Limited", nil, "Popular"]
    let pct = percents[seed % percents.count]
    let tag = tags[seed % tags.count]
    return DiscountInfo(discountPercentage: Double(pct), badgeLabel: "\(pct)% OFF", tag: tag)
}

// MARK: - Models

struct Review: Codable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}

struct Product: Codable, Identifiable {
    let id: Int
    let images: [String]?
    let title: String
    let rating: Double?
    let description: String
    let price: Double
    let category: String?
    let discountPercentage: Double?
    let reviews: [Review]?
    let availabilityStatus: String?
    let thumbnail: String?
}

struct ProductsResponse: Codable {
    let products: [Product]
}



