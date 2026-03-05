//
//  OrdersView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI

struct OrdersView: View {
    @StateObject private var orderManager = OrderManager.shared
    @State private var selectedOrder: Order?
    
    var body: some View {
        NavigationStack {
            Group {
                if orderManager.orders.isEmpty {
                    emptyState
                } else {
                    ordersList
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedOrder) { order in
            OrderDetailView(order: order)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 72))
                .foregroundColor(.gray.opacity(0.4))
            Text("No Orders Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Your order history will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Orders List
    
    private var ordersList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(orderManager.orders) { order in
                    OrderRowView(order: order)
                        .onTapGesture {
                            selectedOrder = order
                        }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Order Row View

struct OrderRowView: View {
    let order: Order
    
    var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Green separator line
            Rectangle()
                .fill(Color.brandGreen)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id.prefix(8))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(order.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(order.status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Divider()
                
                // Items summary
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(order.items.prefix(2)) { item in
                        HStack {
                            Text("• \(item.title)")
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text("x\(item.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if order.items.count > 2 {
                        Text("+ \(order.items.count - 2) more item(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Total
                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("$ \(String(format: "%.2f", order.total))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - Order Detail View

struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Order Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Information")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        Divider()
                        
                        infoRow(label: "Order ID", value: "#\(order.id.prefix(8))")
                        infoRow(label: "Date", value: order.date.formatted(date: .long, time: .shortened))
                        infoRow(label: "Status", value: order.status.rawValue)
                        infoRow(label: "Payment", value: order.paymentMethod)
                        infoRow(label: "Courier", value: order.courier)
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    
                    // Shipping Address Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shipping Address")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(order.shippingAddress.firstName) \(order.shippingAddress.lastName)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(order.shippingAddress.phoneNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(order.shippingAddress.formatted)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    
                    // Items Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        Divider()
                        
                        ForEach(order.items) { item in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: item.thumbnail ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    default:
                                        Image(systemName: "photo").foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", item.total))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        
                        Divider()
                        
                        VStack(spacing: 8) {
                            summaryRow(label: "Subtotal", value: "$\(String(format: "%.2f", order.subtotal))")
                            summaryRow(label: "Shipping Fee", value: "$\(String(format: "%.2f", order.courierFee))")
                            Divider().padding(.horizontal, 16)
                            summaryRow(label: "Total", value: "$\(String(format: "%.2f", order.total))", bold: true)
                        }
                        .padding(.bottom, 16)
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brandGreen)
                }
            }
        }
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private func summaryRow(label: String, value: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(bold ? .subheadline : .caption)
                .fontWeight(bold ? .semibold : .regular)
                .foregroundColor(bold ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(bold ? .subheadline : .caption)
                .fontWeight(bold ? .bold : .medium)
                .foregroundColor(bold ? .brandGreen : .primary)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    OrdersView()
}
