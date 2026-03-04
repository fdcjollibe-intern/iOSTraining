//
//  SaleManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/4/26.
//

import Foundation
import Combine

class SaleManager: ObservableObject {
    static let shared = SaleManager()
    
    // Sale end time (23 hours, 11 minutes, 47 seconds from now)
    private let saleEndTimeKey = "saleEndTime"
    
    @Published var isSaleActive: Bool = false
    @Published var showSaleEndedModal: Bool = false
    
    private var timer: AnyCancellable?
    
    var saleEndDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: saleEndTimeKey) as? Date {
            return savedDate
        } else {
            // First launch - set sale end time
            let endDate = Date().addingTimeInterval(15) //(23 * 3600 + 11 * 60 + 47)
            UserDefaults.standard.set(endDate, forKey: saleEndTimeKey)
            return endDate
        }
    }
    
    private init() {
        updateSaleStatus()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSaleStatus()
            }
    }
    
    private func updateSaleStatus() {
        let wasActive = isSaleActive
        isSaleActive = Date() < saleEndDate
        
        // If sale just ended
        if wasActive && !isSaleActive {
            onSaleEnded()
        }
    }
    
    private func onSaleEnded() {
        print("🔴 Sale has ended! Clearing cart discounts...")
        
        // Clear all discounted items from cart
        CartManager.shared.clearDiscounts()
        
        // Show sale ended modal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showSaleEndedModal = true
        }
    }
    
    func dismissSaleEndedModal() {
        showSaleEndedModal = false
    }
    
    // For testing - reset sale timer
    func resetSaleTimer() {
        let endDate = Date().addingTimeInterval(15)//(23 * 3600 + 11 * 60 + 47)
        UserDefaults.standard.set(endDate, forKey: saleEndTimeKey)
        isSaleActive = true
        showSaleEndedModal = false
    }
}
