//
//  CheckoutViewModel.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//


import Foundation
import Combine

class CheckoutViewModel: ObservableObject {

    // MARK: - Address
    @Published var address: ShippingAddress = ShippingAddress()
    @Published var showAddressForm: Bool = false

    // MARK: - Courier
    @Published var selectedCourier: String = ""

    // MARK: - Payment
    @Published var selectedPayment: String = ""

    // MARK: - Flow
    @Published var showOrderSuccess: Bool = false
    @Published var showDraftModal: Bool = false

    // MARK: - Cart items passed in
    var checkoutItems: [CartItem] = []

    var subtotal: Double {
        checkoutItems.reduce(0) { $0 + $1.total }
    }
    
    var totalSavings: Double {
        checkoutItems.reduce(0) { $0 + $1.savings }
    }

    var shippingFee: Double {
        switch selectedCourier {
        case "SAP Express": return 150
        case "DHL Express": return 300
        case "FedEx": return 250
        case "JNE Express": return 100
        default: return 0
        }
    }

    var total: Double { subtotal + shippingFee }

    // MARK: - Draft tracking
    private let draftStore = CheckoutDraftStore.shared
    private var initialDraft: CheckoutDraft = CheckoutDraft()

    var hasUnsavedChanges: Bool {
        let current = currentDraft
        return current.address != initialDraft.address ||
               current.selectedCourier != initialDraft.selectedCourier ||
               current.selectedPayment != initialDraft.selectedPayment
    }

    var currentDraft: CheckoutDraft {
        CheckoutDraft(
            address: address,
            selectedCourier: selectedCourier,
            selectedPayment: selectedPayment
        )
    }

    init(items: [CartItem] = []) {
        self.checkoutItems = items
        if let saved = draftStore.load() {
            address = saved.address
            selectedCourier = saved.selectedCourier
            selectedPayment = saved.selectedPayment
            initialDraft = saved
        }
    }

    func saveDraft() {
        draftStore.save(currentDraft)
        initialDraft = currentDraft
    }

    func clearDraft() {
        draftStore.clear()
    }

    func placeOrder() {
        // Save order to OrderManager
        OrderManager.shared.placeOrder(
            items: checkoutItems,
            address: address,
            courier: selectedCourier,
            courierFee: shippingFee,
            paymentMethod: selectedPayment,
            subtotal: subtotal,
            total: total
        )
        
        // Remove ordered items from cart
        checkoutItems.forEach { item in
            if let cartItem = CartManager.shared.items.first(where: { $0.id == item.id }) {
                CartManager.shared.remove(item: cartItem)
            }
        }
        
        // Clear draft
        clearDraft()
        showOrderSuccess = true
    }

    var canPlaceOrder: Bool {
        !address.isEmpty && !selectedCourier.isEmpty && !selectedPayment.isEmpty
    }
}
