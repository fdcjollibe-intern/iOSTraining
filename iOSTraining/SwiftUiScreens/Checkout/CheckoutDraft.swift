//
//  CheckoutDraft.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import Foundation

struct ShippingAddress: Codable, Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var street: String = ""
    var houseNo: String = ""
    var barangay: String = ""
    var city: String = ""
    var province: String = ""
    var postalCode: String = ""

    var isEmpty: Bool {
        firstName.isEmpty && lastName.isEmpty && street.isEmpty
    }

    var formatted: String {
        "\(houseNo) \(street), \(barangay), \(city), \(province) \(postalCode)"
    }
}

struct CheckoutDraft: Codable {
    var address: ShippingAddress = ShippingAddress()
    var selectedCourier: String = ""
    var selectedPayment: String = ""

    var isEmpty: Bool {
        address.isEmpty && selectedCourier.isEmpty && selectedPayment.isEmpty
    }
}

class CheckoutDraftStore {
    static let shared = CheckoutDraftStore()
    private let key = "checkout_draft"

    func save(_ draft: CheckoutDraft) {
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func load() -> CheckoutDraft? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let draft = try? JSONDecoder().decode(CheckoutDraft.self, from: data) else { return nil }
        return draft
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
