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
        VStack(spacing: 0) {
            
            // Replace the Header section:
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.gray.opacity(0.7))
                }
                Spacer()
                Text("Edit Item")
                    .padding(.top, 4)
                    .fontWeight(Font.Weight.bold)
                Spacer()
                Color.clear.frame(width: 26, height: 26)
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)        // ← was 20, increased
            .padding(.bottom, 16)
            
            // Replace the Product row section (add description after subtotal):
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "photo").foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text("₱ \(item.price, specifier: "%.2f") each")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    if let live = liveItem {
                        Text("Subtotal: ₱ \(live.total, specifier: "%.2f")")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            
            // Quantity stepper
            HStack {
                Text("Quantity")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                
                HStack(spacing: 0) {
                    Button {
                        onDecrement()
                        if let live = liveItem { quantity = live.quantity } else { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.brandGreen)
                            .background(Color(UIColor.tertiarySystemBackground))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("\(liveItem?.quantity ?? quantity)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 52)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        onIncrement()
                        if let live = liveItem { quantity = live.quantity } else { quantity += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.brandGreen)
                            .background(Color(UIColor.tertiarySystemBackground))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            
            
            Text(item.itemDescription ?? "No description available.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 15)

            Divider()
            
            Spacer()
            
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Done")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.brandGreen)
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 8)
            
            // Delete button
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Remove from Cart")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.08))
                .foregroundColor(.red)
                .cornerRadius(14)
                .padding(.horizontal, 20)
            }
            .alert("Remove Item", isPresented: $showDeleteConfirmation) {
                Button("Remove", role: .destructive) {
                    onDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove \"\(item.title)\" from your cart?")
            }
            .padding(.bottom, -5)
            .padding(.bottom, 10)
        }
        .background(Color(UIColor.systemBackground))
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


extension Color {
    static let brandGreen = Color(red: 0x29/255.0, green: 0xA8/255.0, blue: 0x7B/255.0)
    static let brandGreenSoft = Color(red: 0xE9/255.0, green: 0xFD/255.0, blue: 0xF4/255.0)
}
