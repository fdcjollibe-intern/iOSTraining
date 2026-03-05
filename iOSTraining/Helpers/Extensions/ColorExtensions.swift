//
//  ColorExtensions.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI

extension Color {
    static let brandGreen = Color(red: 87/255.0, green: 175/255.0, blue: 135/255.0)
    static let brandGreenSoft = Color(red: 0xE9/255.0, green: 0xFD/255.0, blue: 0xF4/255.0)
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
