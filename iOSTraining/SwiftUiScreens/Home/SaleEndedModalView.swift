//
//  SaleEndedModalView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/4/26.
//

import SwiftUI

struct SaleEndedModalView: View {
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.01
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            modalCard
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.62, blendDuration: 0)) {
                        scale   = 1.0
                        opacity = 1.0
                    }
                }
        }
    }

    private var modalCard: some View {
        ZStack(alignment: .topLeading) {
            fullCard
            closeButton
        }
        .frame(width: 330)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.gray.opacity(0.35), radius: 40, x: 0, y: 16)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
    }

    private var fullCard: some View {
        ZStack {
            // Dark gray base
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.20),
                    Color(red: 0.25, green: 0.25, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Glowing orbs
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -60, y: -40)

            Circle()
                .fill(Color.orange.opacity(0.08))
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

            // Content
            VStack(spacing: 20) {
                Spacer().frame(height: 12)

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "clock.badge.xmark.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                }

                // Headline
                Text("Sale Ended")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

                Text("Thank you for shopping with us!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 32)

                Text("All items have been updated\nto regular pricing")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
    }

    private var closeButton: some View {
        Button { onDismiss() } label: {
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

#Preview {
    SaleEndedModalView(onDismiss: {})
}
