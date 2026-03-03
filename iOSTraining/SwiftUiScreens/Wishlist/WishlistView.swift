//
//  WishlistView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var wishlistManager = WishlistManager.shared
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if wishlistManager.items.isEmpty {
                    emptyState
                } else {
                    wishlistList
                }
            }
            .navigationTitle("My Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 72))
                .foregroundColor(.gray.opacity(0.4))
            Text("Your wishlist is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Save your favorite products here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Wishlist List
    
    private var wishlistList: some View {
        List {
            ForEach(wishlistManager.items, id: \.id) { product in
                WishlistRowView(
                    product: product,
                    onAddToCart: {
                        cartManager.add(product: product)
                    },
                    onRemove: {
                        wishlistManager.remove(product: product)
                    }
                )
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
            }
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Wishlist Row View

struct WishlistRowView: View {
    let product: Product
    let onAddToCart: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Green separator line
            Rectangle()
                .fill(Color.brandGreen)
                .frame(width: 4)
            
            HStack(spacing: 12) {
                // Product Image
                AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    if let category = product.category {
                        Text(category.uppercased())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(product.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("₱ \(String(format: "%.2f", product.price))")
                        .font(.headline)
                        .foregroundColor(.brandGreen)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 8) {
                    Button {
                        onAddToCart()
                    } label: {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(.brandGreen)
                            .frame(width: 40, height: 40)
                            .background(Color.brandGreenSoft)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    WishlistView()
}
