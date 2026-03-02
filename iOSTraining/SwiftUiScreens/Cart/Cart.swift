//
//  SwiftUIView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

// Cart.swift
import SwiftUI

struct Cart: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var selectedIDs: Set<Int> = []
    @State private var selectedItem: CartItem? = nil
    @State private var navigateToCheckout = false

    var selectedTotal: Double {
        viewModel.items
            .filter { selectedIDs.contains($0.id) }
            .reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isEmpty {
                    emptyState
                } else {
                    cartList
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // wishlist action placeholder
                    } label: {
                        Image(systemName: "heart")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Order Placed! 🎉", isPresented: $viewModel.showCheckoutAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Thank you for your purchase!")
            }
            .sheet(item: $selectedItem) { item in
                CartItemModal(
                    item: item,
                    onIncrement: { viewModel.increment(item) },
                    onDecrement: { viewModel.decrement(item) },
                    onDelete: {
                        selectedIDs.remove(item.id)
                        viewModel.remove(item)
                        selectedItem = nil
                    },
                    onDismiss: { selectedItem = nil }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToCheckout) {
                CheckoutView(items: viewModel.items.filter { selectedIDs.contains($0.id) })
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 72))
                .foregroundColor(.gray.opacity(0.4))
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add products from the shop to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Cart List

    private var cartList: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.items) { item in
                    CartRowView(
                            item: item,
                            isSelected: selectedIDs.contains(item.id),
                            onToggle: {
                                if selectedIDs.contains(item.id) {
                                    selectedIDs.remove(item.id)
                                } else {
                                    selectedIDs.insert(item.id)
                                }
                            },
                            onTap: { selectedItem = item },
                            onIncrement: { viewModel.increment(item) },
                            onDecrement: { viewModel.decrement(item) }   
                        )
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            selectedIDs.remove(item.id)
                            viewModel.remove(item)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "trash.fill")
                                Text("Delete")
                                    .font(.caption)
                            }
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)

            checkoutBar
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - Checkout Bar

    private var checkoutBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if selectedIDs.isEmpty {
                        Text("Select items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("₱ \(String(format: "%.2f", selectedTotal))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .transition(.opacity)
                    }
                }
                Spacer()
                Button {
                    let checkedItems = viewModel.items.filter { selectedIDs.contains($0.id) }
                    guard !checkedItems.isEmpty else { return }
                    navigateToCheckout = true
                } label: {
                    Text("Checkout\(selectedIDs.isEmpty ? "" : " (\(selectedIDs.count))")")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(selectedIDs.isEmpty ? Color.gray.opacity(0.4) : Color.accentColor)
                        .clipShape(Capsule())
                }
                .disabled(selectedIDs.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: selectedIDs.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
        }
    }
}






