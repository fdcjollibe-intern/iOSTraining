//
//  CartManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import Foundation
import Combine

class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var items: [CartItem] = [] {
        didSet { save() }
    }
    
    private let key = "cart_items"
    
    private init() { load() }
    
    // MARK: - Public Methods
    
    func add(product: Product, discountInfo: DiscountInfo? = nil) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += 1
        } else {
            // Check if sale is active and apply discount
            let isSaleActive = SaleManager.shared.isSaleActive
            let discountPct = discountInfo?.discountPercentage
            let apiPrice = product.price
            let finalPrice: Double
            let originalPrice: Double?
            
            if isSaleActive, let pct = discountPct {
                // FLASH SALE: Apply fake discount on top of API price
                finalPrice = apiPrice * (1.0 - pct / 100.0)
                originalPrice = apiPrice
            } else if !isSaleActive, let pct = discountPct {
                // AFTER SALE: API price is already discounted, calculate original backwards
                finalPrice = apiPrice
                originalPrice = apiPrice / (1.0 - pct / 100.0)
            } else {
                // No discount
                finalPrice = apiPrice
                originalPrice = nil
            }
            
            let item = CartItem(
                id: product.id,
                title: product.title,
                price: finalPrice,
                thumbnail: product.thumbnail,
                category: product.category,
                itemDescription: product.description,
                quantity: 1,
                discountPercentage: discountPct,
                originalPrice: originalPrice
            )
            items.append(item)
        }
    }
    
    func clearDiscounts() {
        // When sale ends, restore original prices and clear discount info
        for index in items.indices {
            if let originalPrice = items[index].originalPrice {
                items[index] = CartItem(
                    id: items[index].id,
                    title: items[index].title,
                    price: originalPrice,
                    thumbnail: items[index].thumbnail,
                    category: items[index].category,
                    itemDescription: items[index].itemDescription,
                    quantity: items[index].quantity,
                    discountPercentage: nil,
                    originalPrice: nil
                )
            }
        }
        save()
    }
    
    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func increment(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
    }
    
    func decrement(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }
    
    func clear() { items.removeAll() }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.total }
    }
    
    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - Persistence (UserDefaults)
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Cart saved: \(items.count) item(s)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CartItem].self, from: data) else { return }
        items = decoded
    }
}
