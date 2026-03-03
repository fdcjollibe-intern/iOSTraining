//
//  OrderManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import Foundation
import Combine

struct Order: Identifiable, Codable {
    let id: String
    let items: [CartItem]
    let shippingAddress: ShippingAddress
    let courier: String
    let courierFee: Double
    let paymentMethod: String
    let subtotal: Double
    let total: Double
    let date: Date
    var status: OrderStatus
    
    enum OrderStatus: String, Codable {
        case pending = "Pending"
        case processing = "Processing"
        case shipped = "Shipped"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
    }
}

class OrderManager: ObservableObject {
    static let shared = OrderManager()
    
    @Published var orders: [Order] = [] {
        didSet { save() }
    }
    
    private let key = "user_orders"
    
    private init() { load() }
    
    // MARK: - Public Methods
    
    func placeOrder(items: [CartItem], address: ShippingAddress, courier: String, courierFee: Double, paymentMethod: String, subtotal: Double, total: Double) {
        let order = Order(
            id: UUID().uuidString,
            items: items,
            shippingAddress: address,
            courier: courier,
            courierFee: courierFee,
            paymentMethod: paymentMethod,
            subtotal: subtotal,
            total: total,
            date: Date(),
            status: .pending
        )
        orders.insert(order, at: 0) // Insert at beginning for newest first
    }
    
    func updateOrderStatus(orderId: String, status: Order.OrderStatus) {
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { return }
        orders[index].status = status
    }
    
    func clearAll() {
        orders.removeAll()
    }
    
    var unreadCount: Int {
        orders.filter { $0.status == .pending || $0.status == .processing }.count
    }
    
    // MARK: - Persistence (UserDefaults)
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Orders saved: \(orders.count) order(s)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Order].self, from: data) else { return }
        orders = decoded
    }
}
