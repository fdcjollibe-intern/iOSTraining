//
//  OrderSuccessView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

struct OrderSuccessView: View {
    let onDone: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.brandGreenSoft)
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.brandGreen.opacity(0.15))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.brandGreen)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }

            Spacer().frame(height: 32)

            Text("Order Placed!")
                .font(.title)
                .fontWeight(.bold)

            Spacer().frame(height: 12)

            Text("Your order has been placed successfully.\nWe'll notify you when it's on the way.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: onDone) {
                Text("Back to Shop")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandGreen)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 48)
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(true)
    }
}
