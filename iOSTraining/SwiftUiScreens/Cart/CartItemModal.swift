//
//  CartItemModal.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

struct CartItemModal: View {
    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    
    @State private var showDeleteConfirmation = false
    @State private var showDecrementConfirmation = false
    @State private var quantity: Int
    @ObservedObject private var manager = CartManager.shared
    
    init(item: CartItem, onIncrement: @escaping () -> Void, onDecrement: @escaping () -> Void, onDelete: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.item = item
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.onDelete = onDelete
        self.onDismiss = onDismiss
        _quantity = State(initialValue: item.quantity)
    }
    
    private var liveItem: CartItem? {
        manager.items.first { $0.id == item.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    Spacer()
                    Text("Edit Item")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 24)
                
                // Product Card
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        .frame(width: 90, height: 90)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(14)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.category?.capitalized ?? "Product")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .foregroundColor(.primary)
                            
                            Text("₱ \(item.price, specifier: "%.2f") each")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            if let live = liveItem {
                                Text("Subtotal: ₱ \(live.total, specifier: "%.2f")")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brandGreen)
                            }
                        }
                        Spacer()
                    }
                    .padding(18)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    .overlay(
                        HStack {
                            Color.brandGreen
                                .frame(width: 4)
                                .cornerRadius(16, corners: [.topLeft, .bottomLeft])
                            Spacer()
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // Description
                if let description = item.itemDescription {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Quantity stepper
                HStack {
                    Text("Quantity")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button {
                            if (liveItem?.quantity ?? quantity) > 1 {
                                onDecrement()
                                if let live = liveItem { quantity = live.quantity } else { quantity -= 1 }
                            } else {
                                showDecrementConfirmation = true
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 38, height: 38)
                                .foregroundStyle(.white)
                                .background(Color.brandGreen)
                                .clipShape(Circle())
                        }
                        
                        Text("\(liveItem?.quantity ?? quantity)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(width: 48)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            onIncrement()
                            if let live = liveItem { quantity = live.quantity } else { quantity += 1 }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 38, height: 38)
                                .foregroundStyle(.white)
                                .background(Color.brandGreen)
                                .clipShape(Circle())
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .alert("Remove Item", isPresented: $showDecrementConfirmation) {
                        Button("Remove", role: .destructive) {
                            onDelete()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to remove \"\(item.title)\" from your cart?")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onDismiss) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Done")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color.brandGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Remove from Cart")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(14)
                    }
                    .alert("Remove Item", isPresented: $showDeleteConfirmation) {
                        Button("Remove", role: .destructive) {
                            onDelete()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to remove \"\(item.title)\" from your cart?")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    
    #Preview {
        CartItemModal(
            item: CartItem(
                id: 1,
                title: "Arm Chair Herman Miller",
                price: 32.00,
                thumbnail: "https://cdn.dummyjson.com/products/images/furniture/Annibale%20Colombo%20Bed/1.png",
                category: "Furniture",
                itemDescription: "A comfortable and stylish arm chair perfect for any living room setting.",
                quantity: 2
            ),
            onIncrement: {},
            onDecrement: {},
            onDelete: {},
            onDismiss: {}
        )
        
        
        
        
        
    }
}
