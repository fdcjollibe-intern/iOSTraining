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
    
    func add(product: Product) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += 1
        } else {
            let item = CartItem(
                id: product.id,
                title: product.title,
                price: product.price,
                thumbnail: product.thumbnail,
                category: product.category,
                itemDescription: product.description,
                quantity: 1
            )
            items.append(item)
        }
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
