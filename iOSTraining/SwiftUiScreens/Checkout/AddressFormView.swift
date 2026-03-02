//
//  AddressFormView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//


import SwiftUI

struct AddressFormView: View {
    @Binding var address: ShippingAddress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Personal Info
                    sectionCard(title: "Personal Info") {
                        fieldRow(icon: "person", placeholder: "First Name", text: $address.firstName)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "person", placeholder: "Last Name", text: $address.lastName)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "phone", placeholder: "Phone Number", text: $address.phoneNumber, keyboard: .phonePad)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "envelope", placeholder: "Email", text: $address.email, keyboard: .emailAddress)
                    }

                    // Address Details
                    sectionCard(title: "Address") {
                        fieldRow(icon: "house", placeholder: "House / Unit No.", text: $address.houseNo)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "map", placeholder: "Street", text: $address.street)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "building.2", placeholder: "Barangay", text: $address.barangay)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "building.columns", placeholder: "City", text: $address.city)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "mappin.and.ellipse", placeholder: "Province", text: $address.province)
                        Divider().padding(.leading, 44)
                        fieldRow(icon: "number", placeholder: "Postal Code", text: $address.postalCode, keyboard: .numberPad)
                    }

                    // Save button
                    Button {
                        dismiss()
                    } label: {
                        Text("Save Address")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.brandGreen)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Shipping Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.brandGreen)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func fieldRow(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.brandGreen)
                .frame(width: 20)
                .padding(.leading, 16)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.subheadline)
                .padding(.vertical, 14)
                .padding(.trailing, 16)
        }
    }
}










