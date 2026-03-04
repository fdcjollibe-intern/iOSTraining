//
//  Checkout.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//


import SwiftUI

// MARK: - Courier Model
struct Courier: Identifiable {
    let id = UUID()
    let name: String
    let eta: String
    let icon: String
    let fee: Double
}

// MARK: - Payment Model
struct PaymentMethod: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct CheckoutView: View {
    @StateObject private var viewModel: CheckoutViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDraftAlert = false
    @State private var navigateToSuccess = false
    @State private var showCourierModal = false
    @State private var showPaymentModal = false

    private let couriers: [Courier] = [
        Courier(name: "SAP Express",  eta: "Arrive in 5–6 days", icon: "shippingbox",       fee: 150),
        Courier(name: "DHL Express",  eta: "Arrive in 3–5 days", icon: "airplane.departure", fee: 300),
        Courier(name: "FedEx",        eta: "Arrive in 2–3 days", icon: "bolt.horizontal",    fee: 250),
        Courier(name: "JNE Express",  eta: "Arrive in 1 day",    icon: "hare",               fee: 100),
    ]

    private let payments: [PaymentMethod] = [
        PaymentMethod(name: "Master Card", icon: "creditcard.fill",  color: .orange),
        PaymentMethod(name: "PayPal",      icon: "p.circle.fill",    color: .blue),
        PaymentMethod(name: "Google Pay",  icon: "g.circle.fill",    color: .red),
        PaymentMethod(name: "Apple Pay",   icon: "apple.logo",       color: .primary),
        PaymentMethod(name: "Cash On Delivery", icon: "banknote", color: .green),
    ]

    init(items: [CartItem]) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(items: items))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        shippingInfoSection
                        courierSection
                        paymentSection
                        orderSummarySection
                        placeOrderButton
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if viewModel.hasUnsavedChanges {
                            showDraftAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddressForm) {
                AddressFormView(address: $viewModel.address)
            }
            .sheet(isPresented: $showCourierModal) {
                CourierSelectionModal(
                    couriers: couriers,
                    selectedCourier: $viewModel.selectedCourier,
                    onDismiss: { showCourierModal = false }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPaymentModal) {
                PaymentSelectionModal(
                    payments: payments,
                    selectedPayment: $viewModel.selectedPayment,
                    onDismiss: { showPaymentModal = false }
                )
                .presentationDetents([.medium])
            }
            .navigationDestination(isPresented: $navigateToSuccess) {
                OrderSuccessView {
                    navigateToSuccess = false
                    dismiss()
                }
            }
            .overlay {
                if showDraftAlert {
                    draftModalOverlay
                }
            }
        }
    }

    // MARK: - Draft Modal Overlay
    private var draftModalOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showDraftAlert = false }

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.brandGreenSoft)
                        .frame(width: 64, height: 64)
                    Image(systemName: "doc.badge.clock")
                        .font(.system(size: 28))
                        .foregroundColor(.brandGreen)
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Save as Draft?")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("You have unsaved changes. Would you like to save them as a draft so you can continue later?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                Divider()

                HStack(spacing: 0) {
                    Button {
                        showDraftAlert = false
                        dismiss()
                    } label: {
                        Text("Discard")
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }

                    Divider().frame(height: 52)

                    Button {
                        viewModel.saveDraft()
                        showDraftAlert = false
                        dismiss()
                    } label: {
                        Text("Save Draft")
                            .fontWeight(.semibold)
                            .foregroundColor(.brandGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 32)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        }
    }

    // MARK: - Section 1: Shipping Info
    private var shippingInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(number: "1", title: "Shipping Information")

            VStack(spacing: 0) {
                infoRow(icon: "person.fill", label: "Name", value: fullName)
                Divider().padding(.leading, 52)
                infoRow(icon: "phone.fill", label: "Phone", value: viewModel.address.phoneNumber.isEmpty ? "—" : viewModel.address.phoneNumber)
                Divider().padding(.leading, 52)
                infoRow(icon: "envelope.fill", label: "Email", value: viewModel.address.email.isEmpty ? "—" : viewModel.address.email)

                Divider()

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.brandGreen)
                        .font(.system(size: 18))
                        .padding(.leading, 16)
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delivery Address")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if viewModel.address.isEmpty {
                            Text("No address added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 2)
                        } else {
                            Text(viewModel.address.formatted)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 2)
                        }
                    }
                    .padding(.vertical, 14)

                    Spacer()

                    Button {
                        viewModel.showAddressForm = true
                    } label: {
                        Text(viewModel.address.isEmpty ? "Add" : "Edit")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brandGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.brandGreenSoft)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }

    private var fullName: String {
        let name = "\(viewModel.address.firstName) \(viewModel.address.lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "—" : name
    }

    // MARK: - Section 2: Courier
    private var courierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(number: "2", title: "Select Shipping Courier")

            HStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 20))
                    .foregroundColor(.brandGreen)
                    .frame(width: 48, height: 48)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.selectedCourier.isEmpty ? "Select Courier" : viewModel.selectedCourier)
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedCourier.isEmpty ? .regular : .semibold)
                        .foregroundColor(viewModel.selectedCourier.isEmpty ? .secondary : .primary)
                    
                    if !viewModel.selectedCourier.isEmpty {
                        if let courier = couriers.first(where: { $0.name == viewModel.selectedCourier }) {
                            Text(courier.eta)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Tap to choose shipping method")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .onTapGesture {
                showCourierModal = true
            }
        }
    }

    // MARK: - Section 3: Payment
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(number: "3", title: "Payment Method")

            HStack(spacing: 12) {
                Image(systemName: viewModel.selectedPayment.isEmpty ? "creditcard" : (payments.first(where: { $0.name == viewModel.selectedPayment })?.icon ?? "creditcard"))
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.selectedPayment.isEmpty ? .gray : (payments.first(where: { $0.name == viewModel.selectedPayment })?.color ?? .gray))
                    .frame(width: 48, height: 48)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.selectedPayment.isEmpty ? "Select Payment" : viewModel.selectedPayment)
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedPayment.isEmpty ? .regular : .semibold)
                        .foregroundColor(viewModel.selectedPayment.isEmpty ? .secondary : .primary)
                    
                    if viewModel.selectedPayment.isEmpty {
                        Text("Tap to choose payment method")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .onTapGesture {
                showPaymentModal = true
            }
        }
    }

    // MARK: - Section 4: Order Summary
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(number: "4", title: "Order Summary")

            VStack(spacing: 0) {
                ForEach(viewModel.checkoutItems) { item in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: item.thumbnail ?? "")) { img in
                            img.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "photo").foregroundColor(.gray)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.leading, 16)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline)
                                .lineLimit(1)
                            HStack(spacing: 4) {
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let discountPct = item.discountPercentage {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(discountPct))% OFF")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.88, green: 0.18, blue: 0.18))
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            if let originalPrice = item.displayOriginalPrice {
                                Text("₱\(String(format: "%.2f", originalPrice * Double(item.quantity)))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .strikethrough(true, color: .secondary)
                            }
                            Text("₱\(String(format: "%.2f", item.total))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(item.discountPercentage != nil ? Color.brandGreen : .primary)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.vertical, 12)
                    Divider().padding(.leading, 76)
                }

                VStack(spacing: 0) {
                    summaryRow(label: "Subtotal", value: "₱\(String(format: "%.2f", viewModel.subtotal))")
                    if viewModel.totalSavings > 0 {
                        summaryRow(
                            label: "Sale Savings 🔥",
                            value: "-₱\(String(format: "%.2f", viewModel.totalSavings))",
                            savings: true
                        )
                    }
                    summaryRow(
                        label: "Shipping (\(viewModel.selectedCourier.isEmpty ? "—" : viewModel.selectedCourier))",
                        value: viewModel.selectedCourier.isEmpty ? "—" : "₱\(Int(viewModel.shippingFee))"
                    )
                    Divider().padding(.horizontal, 16).padding(.vertical, 4)
                    summaryRow(label: "Total", value: "₱\(String(format: "%.2f", viewModel.total))", bold: true)
                }
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Place Order Button
    private var placeOrderButton: some View {
        Button {
            viewModel.placeOrder()
            navigateToSuccess = true
        } label: {
            Text("Place Order")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(viewModel.canPlaceOrder ? Color.primary : Color.gray.opacity(0.4))
                .cornerRadius(16)
                .padding(.horizontal, 16)
        }
        .disabled(!viewModel.canPlaceOrder)
        .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func sectionHeader(number: String, title: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.brandGreen)
                    .frame(width: 26, height: 26)
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 20)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brandGreen)
                .font(.system(size: 14))
                .frame(width: 20)
                .padding(.leading, 16)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1), savings: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(bold ? .subheadline : .footnote)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(savings ? Color(red: 0.88, green: 0.18, blue: 0.18) : (bold ? .primary : .secondary))
                .padding(.leading, 16)
            Spacer()
            Text(value)
                .font(bold ? .subheadline : .footnote)
                .fontWeight(bold ? .bold : (savings ? .bold : .regular))
                .foregroundColor(savings ? Color(red: 0.88, green: 0.18, blue: 0.18) : (bold ? .brandGreen : .primary)
                .foregroundColor(bold ? .primary : .secondary)
                .padding(.leading, 16)
            Spacer()
            Text(value)
                .font(bold ? .subheadline : .footnote)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(bold ? .brandGreen : .primary)
                .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Courier Selection Modal

struct CourierSelectionModal: View {
    let couriers: [Courier]
    @Binding var selectedCourier: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ForEach(Array(couriers.enumerated()), id: \.element.id) { index, courier in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .frame(width: 48, height: 48)
                                Image(systemName: courier.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.brandGreen)
                            }
                            .padding(.leading, 16)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(courier.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(courier.eta)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("$\(Int(courier.fee))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)

                            ZStack {
                                Circle()
                                    .strokeBorder(
                                        selectedCourier == courier.name ? Color.brandGreen : Color.gray.opacity(0.35),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 22, height: 22)
                                if selectedCourier == courier.name {
                                    Circle()
                                        .fill(Color.brandGreen)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedCourier = courier.name
                            }
                        }

                        Text("Estimated date of receipt depends on store packaging time and delivery time. The goods are sent according to the courier's schedule.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                    }

                    if index < couriers.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedCourier.isEmpty ? Color.gray.opacity(0.4) : Color.brandGreen)
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .disabled(selectedCourier.isEmpty)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Select Courier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(.brandGreen)
                }
            }
        }
    }
}

// MARK: - Payment Selection Modal

struct PaymentSelectionModal: View {
    let payments: [PaymentMethod]
    @Binding var selectedPayment: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ForEach(Array(payments.enumerated()), id: \.element.id) { index, method in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(width: 48, height: 48)
                            Image(systemName: method.icon)
                                .font(.system(size: 22))
                                .foregroundColor(method.color)
                        }
                        .padding(.leading, 16)

                        Text(method.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        ZStack {
                            Circle()
                                .strokeBorder(
                                    selectedPayment == method.name ? Color.brandGreen : Color.gray.opacity(0.35),
                                    lineWidth: 1.5
                                )
                                .frame(width: 22, height: 22)
                            if selectedPayment == method.name {
                                Circle()
                                    .fill(Color.brandGreen)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.vertical, 18)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedPayment = method.name
                        }
                    }

                    if index < payments.count - 1 {
                        Divider().padding(.leading, 78)
                    }
                }
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedPayment.isEmpty ? Color.gray.opacity(0.4) : Color.brandGreen)
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .disabled(selectedPayment.isEmpty)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(.brandGreen)
                }
            }
        }
    }
}

#Preview {
    CheckoutView(items: [
        CartItem(id: 1, title: "Arm Chair Herman Miller", price: 32.00, thumbnail: nil, category: "Furniture", itemDescription: "A comfy chair", quantity: 2),
        CartItem(id: 2, title: "Lounge Sofa", price: 120.00, thumbnail: nil, category: "Furniture", itemDescription: "A lounge sofa", quantity: 1)
    ])
}
