//
//  DiscountModalView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI
import Combine

// MARK: - Discount Modal Manager

class DiscountModalManager: ObservableObject {
    @Published var isVisible: Bool = false

    private let userDefaultsKey = "isDiscountModalSeen"

    var hasBeenSeen: Bool {
        get { UserDefaults.standard.bool(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }

    /// Call this on HomeTabView .onAppear — shows after 3 seconds if not yet seen
    func scheduleIfNeeded() {
        guard !hasBeenSeen else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { self.isVisible = true }
        }
    }

    func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isVisible = false
        }
        hasBeenSeen = true
    }

    /// For debug / testing — resets the seen flag so the modal shows again
    func resetSeen() {
        hasBeenSeen = false
    }
}

// MARK: - Countdown View Model

class CountdownViewModel: ObservableObject {
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0

    private var cancellable: AnyCancellable?

    init(targetDate: Date) {
        update(targetDate: targetDate)
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update(targetDate: targetDate)
            }
    }

    private func update(targetDate: Date) {
        let remaining = max(0, targetDate.timeIntervalSince(Date()))
        hours   = Int(remaining) / 3600
        minutes = (Int(remaining) % 3600) / 60
        seconds = Int(remaining) % 60
    }
}

// MARK: - Discount Modal View

struct DiscountModalView: View {
    @ObservedObject var manager: DiscountModalManager

    @StateObject private var countdown = CountdownViewModel(
        targetDate: Date().addingTimeInterval(15) //(23 * 3600 + 11 * 60 + 47)
    )

    @State private var scale: CGFloat = 0.01
    @State private var opacity: Double = 0
    @State private var pulseTag: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { manager.dismiss() }

            modalCard
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.62, blendDuration: 0)) {
                        scale   = 1.0
                        opacity = 1.0
                    }
                    withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(0.8)) {
                        pulseTag = true
                    }
                }
        }
    }

    // MARK: - Modal Card

    private var modalCard: some View {
        ZStack(alignment: .topLeading) {
            // Single full-green card
            fullCard

            // X button — top left
            closeButton
        }
        .frame(width: 330)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(red: 0.08, green: 0.55, blue: 0.37).opacity(0.35), radius: 40, x: 0, y: 16)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
    }

    // MARK: Full Card (single green surface)

    private var fullCard: some View {
        ZStack {
            // Dark green base
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.24, blue: 0.17),
                    Color(red: 0.06, green: 0.35, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Glowing orbs
            Circle()
                .fill(Color(red: 0.13, green: 0.75, blue: 0.50).opacity(0.18))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -60, y: -40)

            Circle()
                .fill(Color(red: 0.9, green: 0.75, blue: 0.1).opacity(0.10))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: 100, y: 120)

            // Grid texture
            GeometryReader { geo in
                Canvas { ctx, size in
                    let spacing: CGFloat = 28
                    ctx.opacity = 0.05
                    var x: CGFloat = 0
                    while x <= size.width {
                        ctx.stroke(Path { p in p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: size.height)) },
                                   with: .color(.white), lineWidth: 0.5)
                        x += spacing
                    }
                    var y: CGFloat = 0
                    while y <= size.height {
                        ctx.stroke(Path { p in p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y)) },
                                   with: .color(.white), lineWidth: 0.5)
                        y += spacing
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }

            // All content stacked vertically on one surface
            VStack(spacing: 20) {

                // Top spacer for X button clearance
                Spacer().frame(height: 12)

                // Badge
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(red: 0.08, green: 0.24, blue: 0.17))
                    Text("FLASH SALE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Color(red: 0.08, green: 0.24, blue: 0.17))
                        .tracking(1.8)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.98, green: 0.82, blue: 0.18))
                        .shadow(color: Color(red: 0.98, green: 0.82, blue: 0.18).opacity(0.6),
                                radius: pulseTag ? 12 : 4, x: 0, y: 0)
                )
                .scaleEffect(pulseTag ? 1.04 : 1.0)

                // Headline
                Text("Up to 50% OFF")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

                Text("on selected items today only")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))

                // Thin divider
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 32)

                // Sale ends label
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                    Text("SALE ENDS IN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1.6)
                }

                // Countdown boxes
                HStack(spacing: 10) {
                    SaleCountdownBox(value: countdown.hours,   label: "HRS")
                    countdownColon
                    SaleCountdownBox(value: countdown.minutes, label: "MIN")
                    countdownColon
                    SaleCountdownBox(value: countdown.seconds, label: "SEC")
                }

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
    }

    // MARK: Helpers

    private var countdownColon: some View {
        Text(":")
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundColor(.white.opacity(0.5))
            .offset(y: -10)
    }

    private var closeButton: some View {
        Button { manager.dismiss() } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 30, height: 30)
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(14)
    }
}

// MARK: - Sale Countdown Box

private struct SaleCountdownBox: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 80, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                // Flip-clock centre line
                Rectangle()
                    .fill(Color.black.opacity(0.20))
                    .frame(width: 80, height: 1)

                Text(String(format: "%02d", value))
                    .font(.system(size: 34, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.easeInOut(duration: 0.25), value: value)
            }

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.55))
                .tracking(2)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.93, green: 0.93, blue: 0.95).ignoresSafeArea()
        DiscountModalView(manager: {
            let m = DiscountModalManager()
            m.isVisible = true
            return m
        }())
    }
}
