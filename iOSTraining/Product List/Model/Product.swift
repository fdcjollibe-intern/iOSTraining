//
//  Product.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//

import Foundation


struct Review: Decodable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}

struct Product: Decodable {
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

struct ProductsResponse: Decodable {
    let products: [Product]
}


