//
//  HomeTabView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI
import Combine

// MARK: - Cart Fly Animation

struct CartBubble: Identifiable {
    let id = UUID()
    var origin: CGPoint      // where the bubble starts
    var offset: CGSize       // animated offset toward tab bar
    var opacity: Double
    var scale: CGFloat
}

class CartAnimationStore: ObservableObject {
    static let shared = CartAnimationStore()
    @Published var bubbles: [CartBubble] = []

    /// Call with the global-frame origin of the "Add to Cart" button
    func fire(from origin: CGPoint) {
        // Estimate cart tab position: bottom-center of screen, shifted left (cart is ~3rd tab)
        let screenH = UIScreen.main.bounds.height
        let screenW = UIScreen.main.bounds.width
        let targetX = screenW * 0.62   // approximate cart tab x
        let targetY = screenH - 40     // just above tab bar

        let dx = targetX - origin.x
        let dy = targetY - origin.y

        var bubble = CartBubble(
            origin: origin,
            offset: .zero,
            opacity: 1.0,
            scale: 1.0
        )
        bubbles.append(bubble)
        guard let idx = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }

        // Phase 1 — pop up slightly then arc down
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            bubbles[idx].offset = CGSize(width: 0, height: -18)
            bubbles[idx].scale  = 1.25
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard self.bubbles.indices.contains(idx) else { return }
            withAnimation(.easeIn(duration: 0.52)) {
                self.bubbles[idx].offset  = CGSize(width: dx, height: dy)
                self.bubbles[idx].scale   = 0.35
                self.bubbles[idx].opacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.bubbles.removeAll { $0.id == bubble.id }
            }
        }
    }
}

// MARK: - HomeTabView

struct HomeTabView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var discountModal = DiscountModalManager()
    @StateObject private var saleManager = SaleManager.shared
    @ObservedObject private var cartStore = CartAnimationStore.shared
    @State private var selectedTab: Tab = .home
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Jollibe"
    @State private var currentBannerIndex: Int = 0
    @State private var showAllProducts: Bool = false
    @State private var showAllSale: Bool = false

    enum Tab { case home, sale }

    let bannerTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    let banners: [(title: String, subtitle: String, store: String, color: [Color])] = [
        (
            title: "24% off shipping today",
            subtitle: "on bag purchases",
            store: "By Kwhlu Store",
            color: [Color.purple.opacity(0.8), Color.purple.opacity(0.5)]
        ),
        (
            title: "New Arrivals",
            subtitle: "208 Products",
            store: "Fresh Collection",
            color: [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.1, green: 0.5, blue: 0.4)]
        ),
        (
            title: "Flash Sale Today",
            subtitle: "Up to 50% OFF",
            store: "Limited Time Only",
            color: [Color.orange.opacity(0.8), Color.red.opacity(0.6)]
        )
    ]

    var displayName: String {
        userName.components(separatedBy: "@").first?.capitalized ?? "Jollibe"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection
                tabSelector

                if viewModel.isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.2)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        if selectedTab == .home {
                            homeContent
                        } else {
                            saleContent
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .background(Color.white)

            if discountModal.isVisible {
                DiscountModalView(manager: discountModal)
                    .transition(.opacity)
                    .zIndex(999)
            }
            
            if saleManager.showSaleEndedModal {
                SaleEndedModalView(onDismiss: {
                    saleManager.dismissSaleEndedModal()
                })
                .transition(.opacity)
                .zIndex(999)
            }

            // Fly-to-cart bubbles
            ForEach(cartStore.bubbles) { bubble in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.10, green: 0.75, blue: 0.50),
                                     Color(red: 0.05, green: 0.55, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "cart.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(red: 0.10, green: 0.65, blue: 0.45).opacity(0.5),
                            radius: 6, x: 0, y: 2)
                    .scaleEffect(bubble.scale)
                    .opacity(bubble.opacity)
                    .position(x: bubble.origin.x + bubble.offset.width,
                              y: bubble.origin.y + bubble.offset.height)
                    .allowsHitTesting(false)
                    .zIndex(1000)
            }
        }
        .onAppear {
            if viewModel.products.isEmpty { viewModel.fetchProducts() }
        }
        .onReceive(bannerTimer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
        .fullScreenCover(isPresented: $showAllProducts) {
            AllProductsView(title: "New Arrivals", isSaleMode: false)
        }
        .fullScreenCover(isPresented: $showAllSale) {
            AllProductsView(title: "Flash Sale", isSaleMode: true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Hi, \(displayName)")
                    .font(.headline).fontWeight(.semibold)
                Text("Let's go shopping")
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 20) {
                Button { } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20)).foregroundColor(.primary)
                }
                Button { } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20)).foregroundColor(.primary)
                        Circle().fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Home", isSelected: selectedTab == .home) {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = .home }
            }
            TabButton(title: "Sale 🔥", isSelected: selectedTab == .sale) {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = .sale }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .background(Color.white)
    }

    // MARK: - Home Content

    private var homeContent: some View {
        VStack(spacing: 24) {
            bannerSection
            newArrivalsSection
        }
        .padding(.bottom, 24)
    }

    private var bannerSection: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentBannerIndex) {
                ForEach(0..<banners.count, id: \.self) { index in
                    BannerCardView(banner: banners[index]).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 180)
            .padding(.horizontal, 16)

            HStack(spacing: 8) {
                ForEach(0..<banners.count, id: \.self) { index in
                    Circle()
                        .fill(currentBannerIndex == index ? Color.brandGreen : Color.gray.opacity(0.3))
                        .frame(width: currentBannerIndex == index ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentBannerIndex)
                }
            }
        }
        .padding(.top, 20)
    }

    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("New Arrivals \(Image(systemName: "flame.fill"))")
                    .font(.headline).fontWeight(.bold)
                Spacer()
                Button { showAllProducts = true } label: {
                    Text("See All").font(.subheadline).foregroundColor(.brandGreen)
                }
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.newArrivals.prefix(10)) { product in
                    ProductCardView(product: product, discount: fakeDiscount(for: product))
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Sale Content

    private var saleContent: some View {
        VStack(spacing: 0) {
            if saleManager.isSaleActive {
                saleBannerHeader

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Flash Deals")
                            .font(.headline).fontWeight(.bold)
                        Spacer()
                        Button { showAllSale = true } label: {
                            Text("See All").font(.subheadline).foregroundColor(.brandGreen)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.products.prefix(20)) { product in
                            ProductCardView(
                                product: product,
                                discount: fakeDiscount(for: product),
                                showSaleBadge: true
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            } else {
                saleInactiveView
            }
        }
    }
    
    private var saleInactiveView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Flash Sale Coming Soon!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("The next flash sale will start in")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(saleManager.formattedTimeRemaining())
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.brandGreen)
                .monospacedDigit()
            
            Text("Browse regular deals in the meantime")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }

    private var saleBannerHeader: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.24, blue: 0.17),
                    Color(red: 0.08, green: 0.40, blue: 0.27)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.13, green: 0.75, blue: 0.50).opacity(0.2))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: -80, y: 10)

            Circle()
                .fill(Color.yellow.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 30)
                .offset(x: 120, y: -10)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color(red: 0.04, green: 0.22, blue: 0.15))
                        Text("LIMITED TIME")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color(red: 0.04, green: 0.22, blue: 0.15))
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(red: 0.98, green: 0.82, blue: 0.18)))

                    Text("Up to\n50% OFF")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineSpacing(2)

                    HStack(spacing: 8) {
                        Text("On selected items")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: 10))
                        
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9))
                            Text(saleManager.formattedTimeRemaining())
                                .font(.system(size: 11, weight: .bold))
                                .monospacedDigit()
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.leading, 24)

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.15))
                    Image(systemName: "bag.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.10))
                }
                .padding(.trailing, 24)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                Rectangle()
                    .fill(isSelected ? Color.brandGreen : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Banner Card View

struct BannerCardView: View {
    let banner: (title: String, subtitle: String, store: String, color: [Color])

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: banner.color,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(banner.title)
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Text(banner.subtitle)
                        .font(.subheadline).foregroundColor(.white.opacity(0.9))
                    Text(banner.store)
                        .font(.caption).foregroundColor(.white.opacity(0.7)).padding(.top, 4)
                }
                .padding(.leading, 24)
                Spacer()
                Image(systemName: banner.title.contains("bag") ? "bag.fill"
                      : banner.title.contains("Arrivals") ? "sparkles" : "bolt.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.trailing, 24)
            }
        }
        .frame(height: 180)
    }
}

// MARK: - Product Card View

struct ProductCardView: View {
    let product: Product
    let discount: DiscountInfo
    var showSaleBadge: Bool = false

    @State private var isFavorite: Bool = false
    @State private var cartAdded: Bool = false
    @State private var cartButtonFrame: CGRect = .zero

    var discountedPrice: Double {
        product.price * (1.0 - discount.discountPercentage / 100.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Image ──────────────────────────────────────────────
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.07)
                            ProgressView()
                        }
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.07)
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(.gray.opacity(0.35))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: (UIScreen.main.bounds.width - 48) / 2, height: 155)
                .clipped()

                // Badge row
                HStack(alignment: .top) {
                    // Red discount badge
                    Text(discount.badgeLabel)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color(red: 0.88, green: 0.18, blue: 0.18))
                        )
                        .padding(10)

                    Spacer()

                    // Heart button
                    Button { isFavorite.toggle() } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isFavorite ? .red : .gray)
                            .padding(7)
                            .background(Circle().fill(Color.white.opacity(0.93)))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    .padding(10)
                }
            }

            // ── Info ───────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 4) {

                // Tag pill (Best Seller / Hot etc.)
                if let tag = discount.tag {
                    Text(tag)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 0.10, green: 0.52, blue: 0.36))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.10, green: 0.52, blue: 0.36).opacity(0.10))
                        )
                        .padding(.top, 2)
                }

                Text(product.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(minHeight: 34, alignment: .top)

                Text(product.category?.capitalized ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                // Price row
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("$\(String(format: "%.2f", discountedPrice))")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color.brandGreen)

                    Text("$\(String(format: "%.0f", product.price))")
                        .font(.system(size: 11))
                        .foregroundColor(Color.secondary.opacity(0.8))
                        .strikethrough(true, color: .secondary)

                    Spacer()
                }
                .padding(.top, 3)

                // Add to Cart button
                Button {
                    CartManager.shared.add(product: product, discountInfo: discount)
                    cartAdded = true
                    // Fire fly-to-cart bubble from button center
                    let origin = CGPoint(
                        x: cartButtonFrame.midX,
                        y: cartButtonFrame.midY
                    )
                    CartAnimationStore.shared.fire(from: origin)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        cartAdded = false
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: cartAdded ? "checkmark" : "cart.badge.plus")
                            .font(.system(size: 11, weight: .bold))
                        Text(cartAdded ? "Added!" : "Add to Cart")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: cartAdded
                                    ? [Color(red: 0.12, green: 0.58, blue: 0.42), Color(red: 0.06, green: 0.42, blue: 0.30)]
                                    : [Color(red: 0.10, green: 0.68, blue: 0.46), Color(red: 0.05, green: 0.50, blue: 0.34)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(
                        color: Color(red: 0.10, green: 0.60, blue: 0.42).opacity(cartAdded ? 0.2 : 0.35),
                        radius: 6, x: 0, y: 3
                    )
                }
                .padding(.top, 8)
                .animation(.easeInOut(duration: 0.2), value: cartAdded)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                cartButtonFrame = geo.frame(in: .global)
                            }
                    }
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
        .overlay(
            Group {
                if showSaleBadge {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            Color(red: 0.10, green: 0.52, blue: 0.36).opacity(0.2),
                            lineWidth: 1
                        )
                }
            }
        )
    }
}

// MARK: - Category Card View (kept for potential reuse)

struct CategoryCardView: View {
    let name: String
    let count: Int
    let icon: String
    let colorName: String

    var backgroundColor: Color {
        switch colorName {
        case "purple": return Color.purple.opacity(0.1)
        case "pink":   return Color.pink.opacity(0.1)
        case "orange": return Color.orange.opacity(0.1)
        case "blue":   return Color.blue.opacity(0.1)
        case "green":  return Color.green.opacity(0.1)
        default:       return Color.gray.opacity(0.1)
        }
    }

    var iconColor: Color {
        switch colorName {
        case "purple": return .purple
        case "pink":   return .pink
        case "orange": return .orange
        case "blue":   return .blue
        case "green":  return .green
        default:       return .gray
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor).frame(width: 70, height: 70)
                Image(systemName: icon)
                    .font(.system(size: 30)).foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(name).font(.headline).fontWeight(.semibold)
                Text("\(count) Product\(count == 1 ? "" : "s")")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14)).foregroundColor(.secondary)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomeTabView()
}
