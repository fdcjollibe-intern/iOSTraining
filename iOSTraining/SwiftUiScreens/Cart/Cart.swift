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
    @StateObject private var saleManager = SaleManager.shared
    @State private var selectedIDs: Set<Int> = []
    @State private var selectedItem: CartItem? = nil
    @State private var navigateToCheckout = false
    @State private var itemToDelete: CartItem? = nil
    @State private var showSwipeDeleteConfirmation = false
    @State private var showWishlist = false

    var selectedTotal: Double {
        viewModel.items
            .filter { selectedIDs.contains($0.id) }
            .reduce(0) { $0 + $1.total }
    }
    
    var allSelected: Bool {
        !viewModel.items.isEmpty && selectedIDs.count == viewModel.items.count
    }
    
    func toggleSelectAll() {
        if allSelected {
            selectedIDs.removeAll()
        } else {
            selectedIDs = Set(viewModel.items.map { $0.id })
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if viewModel.isEmpty {
                        emptyState
                    } else {
                        cartList
                    }
                }
                .navigationTitle("My Cart")
                .navigationBarTitleDisplayMode(.inline)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCheckoutScreen"))) { _ in
                    // Select all items and navigate to checkout
                    if !viewModel.items.isEmpty {
                        selectedIDs = Set(viewModel.items.map { $0.id })
                        navigateToCheckout = true
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !selectedIDs.isEmpty {
                            Button(action: toggleSelectAll) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(allSelected ? Color.brandGreen : Color.gray.opacity(0.35), lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                    if allSelected {
                                        Circle()
                                            .fill(Color.brandGreen)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showWishlist = true
                        } label: {
                            Image(systemName: "heart")
                                .foregroundColor(.red)
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
                    .presentationDetents([.large, .medium])
                    .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showWishlist) {
                    WishlistView()
                }
                .navigationDestination(isPresented: $navigateToCheckout) {
                    CheckoutView(items: viewModel.items.filter { selectedIDs.contains($0.id) })
                }
                .alert("Remove Item", isPresented: $showSwipeDeleteConfirmation) {
                    Button("Remove", role: .destructive) {
                        if let item = itemToDelete {
                            selectedIDs.remove(item.id)
                            viewModel.remove(item)
                            itemToDelete = nil
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        itemToDelete = nil
                    }
                } message: {
                    if let item = itemToDelete {
                        Text("Are you sure you want to remove \"\(item.title)\" from your cart?")
                    } else {
                        Text("Are you sure you want to remove this item from your cart?")
                    }
                }
                
                if saleManager.showSaleEndedModal {
                    SaleEndedModalView(onDismiss: {
                        saleManager.dismissSaleEndedModal()
                    })
                    .transition(.opacity)
                    .zIndex(999)
                }
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            itemToDelete = item
                            showSwipeDeleteConfirmation = true
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
                        Text("$ \(String(format: "%.2f", selectedTotal))")
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
                        .background(selectedIDs.isEmpty ? Color.gray.opacity(0.4) : Color.brandGreen)
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







