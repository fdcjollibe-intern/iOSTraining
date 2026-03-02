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
    
    var total: Double {
        price * Double(quantity)
    }
}
