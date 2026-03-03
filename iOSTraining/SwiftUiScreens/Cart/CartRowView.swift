//
//  CartRowView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

struct CartRowView: View {
    let item: CartItem
    let isSelected: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    let onIncrement: () -> Void   // ← add
    let onDecrement: () -> Void   // ← add
    
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 14) {

            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.brandGreen : Color.gray.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color.brandGreen)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .buttonStyle(.plain)

            // Thumbnail
            AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .frame(width: 80, height: 80)
            .padding(8)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.category?.capitalized ?? "Product")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Price and Quantity stepper on same line
                HStack(spacing: 8) {
                    Text("₱\(item.total, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Quantity stepper
                    HStack(spacing: 0) {
                        Button(action: {
                            if item.quantity > 1 {
                                onDecrement()
                            } else {
                                showDeleteConfirmation = true
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.brandGreen)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)

                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 24)
                            .multilineTextAlignment(.center)

                        Button(action: onIncrement) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.brandGreen)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                }
                .alert("Remove Item", isPresented: $showDeleteConfirmation) {
                    Button("Remove", role: .destructive) {
                        onDecrement()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to remove \"\(item.title)\" from your cart?")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .overlay(
            HStack {
                Color.brandGreen
                    .frame(width: 4)
                    .cornerRadius(16, corners: [.topLeft, .bottomLeft])
                Spacer()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }  // ← only row tap opens modal
    }
}
