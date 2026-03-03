//
//  HomeTabView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI

struct HomeTabView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: Tab = .home
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Jonathan"
    @State private var currentBannerIndex: Int = 0
    
    enum Tab {
        case home
        case category
    }
    
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
        userName.components(separatedBy: "@").first?.capitalized ?? "Jonathan"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Tab Selector
            tabSelector
            
            // Content
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    if selectedTab == .home {
                        homeContent
                    } else {
                        categoryContent
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .background(Color.white)
        .onAppear {
            if viewModel.products.isEmpty {
                viewModel.fetchProducts()
            }
        }
        .onReceive(bannerTimer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            // Profile Image
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
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Let's go shopping")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    // Search action
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Button {
                    // Notification action
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                        
                        Circle()
                            .fill(Color.red)
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .home
                }
            }
            
            TabButton(title: "Category", isSelected: selectedTab == .category) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .category
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .background(Color.white)
    }
    
    // MARK: - Home Content
    
    private var homeContent: some View {
        VStack(spacing: 24) {
            // Banner Carousel
            bannerSection
            
            // New Arrivals
            newArrivalsSection
        }
        .padding(.bottom, 24)
    }
    
    private var bannerSection: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentBannerIndex) {
                ForEach(0..<banners.count, id: \.self) { index in
                    BannerCardView(banner: banners[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 180)
            .padding(.horizontal, 16)
            
            // Custom Page Indicator
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
                Text("New Arrivals 🔥")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    // See all action
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.brandGreen)
                }
            }
            .padding(.horizontal, 20)
            
            // Product Grid (2 columns)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.newArrivals.prefix(10)) { product in
                    ProductCardView(product: product)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Category Content
    
    private var categoryContent: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.categoriesSimplified, id: \.name) { category in
                CategoryCardView(
                    name: category.name,
                    count: category.count,
                    icon: category.icon,
                    colorName: category.color
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
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
                .fill(
                    LinearGradient(
                        colors: banner.color,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(banner.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(banner.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(banner.store)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding(.leading, 24)
                
                Spacer()
                
                Image(systemName: banner.title.contains("bag") ? "bag.fill" : banner.title.contains("Arrivals") ? "sparkles" : "bolt.fill")
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
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Product Image
                AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: (UIScreen.main.bounds.width - 48) / 2, height: 160)
                .background(Color.gray.opacity(0.1))
                .clipped()
                
                // Heart Icon
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .frame(height: 38, alignment: .top)
                
                Text(product.category?.capitalized ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                
                HStack {
                    Text("₱\(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(14)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Category Card View

struct CategoryCardView: View {
    let name: String
    let count: Int
    let icon: String
    let colorName: String
    
    var backgroundColor: Color {
        switch colorName {
        case "purple": return Color.purple.opacity(0.1)
        case "pink": return Color.pink.opacity(0.1)
        case "orange": return Color.orange.opacity(0.1)
        case "blue": return Color.blue.opacity(0.1)
        case "green": return Color.green.opacity(0.1)
        default: return Color.gray.opacity(0.1)
        }
    }
    
    var iconColor: Color {
        switch colorName {
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "blue": return Color.blue
        case "green": return Color.green
        default: return Color.gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(count) Product\(count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
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
