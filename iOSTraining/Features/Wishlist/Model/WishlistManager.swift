//
//  WishlistManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import Foundation
import Combine

class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    
    @Published var items: [Product] = [] {
        didSet { save() }
    }
    
    private let key = "wishlist_items"
    
    private init() { load() }
    
    // MARK: - Public Methods
    
    func add(product: Product) {
        // Check if already in wishlist
        if !items.contains(where: { $0.id == product.id }) {
            items.append(product)
        }
    }
    
    func remove(product: Product) {
        items.removeAll { $0.id == product.id }
    }
    
    func toggle(product: Product) {
        if items.contains(where: { $0.id == product.id }) {
            remove(product: product)
        } else {
            add(product: product)
        }
    }
    
    func isInWishlist(_ product: Product) -> Bool {
        items.contains(where: { $0.id == product.id })
    }
    
    func clear() { items.removeAll() }
    
    var count: Int {
        items.count
    }
    
    // MARK: - Persistence (UserDefaults)
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Wishlist saved: \(items.count) item(s)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Product].self, from: data) else { return }
        items = decoded
    }
}
