//
//  SaleManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/4/26.
//

import Foundation
import Combine

enum SalePhase: Equatable {
    case countdown     // 5 seconds - sale starting soon
    case active        // 45 seconds - flash sale active
    case inactive      // 30 seconds - normal prices with real discounts
}

class SaleManager: ObservableObject {
    static let shared = SaleManager()
    
    // Phase durations
    private let countdownDuration: TimeInterval = 5      // 5 seconds countdown
    private let activeDuration: TimeInterval = 45        // 45 seconds flash sale
    private let inactiveDuration: TimeInterval = 30      // 30 seconds normal period
    
    @Published var isSaleActive: Bool = false
    @Published var currentPhase: SalePhase = .countdown
    @Published var showSaleEndedModal: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    
    private var timer: AnyCancellable?
    private var phaseEndTime: Date = Date()
    
    private init() {
        startCountdown()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePhase()
            }
    }
    
    private func updatePhase() {
        let now = Date()
        timeRemaining = max(0, phaseEndTime.timeIntervalSince(now))
        
        // Check if current phase has ended
        if now >= phaseEndTime {
            transitionToNextPhase()
        }
    }
    
    private func transitionToNextPhase() {
        let wasActive = isSaleActive
        
        switch currentPhase {
        case .countdown:
            // Countdown ended, start flash sale
            startFlashSale()
            
        case .active:
            // Flash sale ended, start normal period
            startNormalPeriod()
            if wasActive {
                onSaleEnded()
            }
            
        case .inactive:
            // Normal period ended, start countdown again
            startCountdown()
        }
    }
    
    private func startCountdown() {
        print("⏱️ Flash sale starting in 5 seconds...")
        currentPhase = .countdown
        isSaleActive = false
        phaseEndTime = Date().addingTimeInterval(countdownDuration)
        timeRemaining = countdownDuration
    }
    
    private func startFlashSale() {
        print("🔥 FLASH SALE STARTED! (45 seconds)")
        currentPhase = .active
        isSaleActive = true
        phaseEndTime = Date().addingTimeInterval(activeDuration)
        timeRemaining = activeDuration
        
        // Notify that sale has started
        NotificationCenter.default.post(name: NSNotification.Name("SaleStarted"), object: nil)
    }
    
    private func startNormalPeriod() {
        print("✅ Normal period - Real discounts active (30 seconds)")
        currentPhase = .inactive
        isSaleActive = false
        phaseEndTime = Date().addingTimeInterval(inactiveDuration)
        timeRemaining = inactiveDuration
    }
    
    private func onSaleEnded() {
        print("🔴 Flash sale ended! Clearing flash discounts...")
        
        // Clear flash sale discounts from cart
        CartManager.shared.clearDiscounts()
        
        // Show sale ended modal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showSaleEndedModal = true
        }
    }
    
    func dismissSaleEndedModal() {
        showSaleEndedModal = false
    }
    
    // Get formatted time remaining
    func formattedTimeRemaining() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Get phase description
    func phaseDescription() -> String {
        switch currentPhase {
        case .countdown:
            return "Flash Sale Starting Soon"
        case .active:
            return "⚡ FLASH SALE ACTIVE"
        case .inactive:
            return "Regular Prices"
        }
    }
    
    // For testing - skip to next phase
    func skipToNextPhase() {
        phaseEndTime = Date()
        updatePhase()
    }
    
    // For testing - reset to countdown
    func resetCycle() {
        startCountdown()
        showSaleEndedModal = false
    }
}
