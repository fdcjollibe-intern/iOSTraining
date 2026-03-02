//
//  CartViewModel.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var showCheckoutAlert = false
    
    private let manager = CartManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        manager.$items
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
    
    var totalPrice: Double { manager.totalPrice }
    var isEmpty: Bool { items.isEmpty }
    
    func increment(_ item: CartItem) { manager.increment(item) }
    func decrement(_ item: CartItem) { manager.decrement(item) }
    func remove(_ item: CartItem) { manager.remove(item: item) }
    func checkout(items: [CartItem]) {
        items.forEach { manager.remove(item: $0) }
        showCheckoutAlert = true
    }
}

