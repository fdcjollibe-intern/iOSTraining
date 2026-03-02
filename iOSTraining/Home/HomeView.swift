//
//  HomeView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

// MARK: - Models

struct PromoCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let discount: String
    let color: Color
    let icon: String
}

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct FeaturedProduct: Identifiable {
    let id: Int
    let title: String
    let category: String
    let price: Double
    let originalPrice: Double
    let rating: Double
    let thumbnail: String?
}

// MARK: - HomeView

struct HomeView: View {
    
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Shopper"
    
    private let promoCards: [PromoCard] = [
        PromoCard(title: "Summer Sale",    subtitle: "Up to 50% off on selected items",  discount: "50% OFF", color: Color(red: 0x29/255, green: 0xA8/255, blue: 0x7B/255), icon: "sun.max.fill"),
        PromoCard(title: "New Arrivals",   subtitle: "Fresh picks just for you",          discount: "NEW",     color: Color(red: 0x1C/255, green: 0x1C/255, blue: 0x1E/255), icon: "sparkles"),
        PromoCard(title: "Flash Deal",     subtitle: "Limited time offers today only",    discount: "30% OFF", color: Color(red: 0xFF/255, green: 0x6B/255, blue: 0x35/255), icon: "bolt.fill"),
    ]
    
    private let categories: [Category] = [
        Category(name: "Electronics", icon: "laptopcomputer",       color: .blue),
        Category(name: "Fashion",     icon: "tshirt.fill",          color: .pink),
        Category(name: "Furniture",   icon: "sofa.fill",            color: .orange),
        Category(name: "Beauty",      icon: "sparkle",              color: .purple),
        Category(name: "Sports",      icon: "figure.run",           color: .green),
        Category(name: "Books",       icon: "books.vertical.fill",  color: .brown),
    ]
    
    private let featuredProducts: [FeaturedProduct] = [
        FeaturedProduct(id: 1, title: "iPhone 15 Pro",     category: "Electronics", price: 999,  originalPrice: 1199, rating: 4.8, thumbnail: "https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/iphone-15-pro-max.png"),
        FeaturedProduct(id: 2, title: "Air Jordan 1",      category: "Fashion",     price: 180,  originalPrice: 220,  rating: 4.6, thumbnail: "https://www.sneakerfiles.com/wp-content/uploads/2025/02/air-jordan-1-high-og-fir-pro-green-FD2596-101-release-info-1024x725.jpg"),
        FeaturedProduct(id: 3, title: "MacBook Pro 14\"",  category: "Electronics", price: 1599, originalPrice: 1999, rating: 4.9, thumbnail: "https://apple-store.net.ru/image/cache/catalog/tovary/macbook/macbook-pro-14-2023/macbook-pro-14-2023-seryy-cosmos-400x400.png"),
        FeaturedProduct(id: 4, title: "Lounge Chair",      category: "Furniture",   price: 320,  originalPrice: 450,  rating: 4.5, thumbnail: "https://m.media-amazon.com/images/I/71zDHYH56jL.jpg"),
    ]
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    var displayName: String {
        userName.components(separatedBy: "@").first?.capitalized ?? "Jollibe"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    VStack(spacing: 28) {
                        promoCardsSection
                        categoriesSection
                        flashDealsSection
                        featuredSection
                    }
                    .padding(.bottom, 32)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(greeting),")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Notification bell
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    // Badge
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 10, y: -10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 14)
                Text("Search products...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.brandGreen)
                        .frame(width: 32, height: 32)
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 8)
            }
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(14)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.brandGreen)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    // MARK: - Promo Cards
    
    private var promoCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Promotions", actionLabel: "See all")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(promoCards) { card in
                        promoCardView(card: card)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .padding(.vertical, -8)
        }
        .padding(.top, 24)
    }
    
    private func promoCardView(card: PromoCard) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(card.color)
                .frame(width: 260, height: 140)
            
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 120, height: 120)
                .offset(x: 160, y: -30)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 80, height: 80)
                .offset(x: 200, y: 20)
            
            // Icon top right
            Image(systemName: card.icon)
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.25))
                .frame(width: 260, height: 140, alignment: .topTrailing)
                .padding(.trailing, 20)
                .padding(.top, 16)
            
            // Text
            VStack(alignment: .leading, spacing: 6) {
                Text(card.discount)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(6)
                
                Text(card.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(card.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
            }
            .padding(16)
        }
        .frame(width: 260, height: 140)
    }
    
    // MARK: - Categories
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Categories", actionLabel: "All")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(categories) { cat in
                        categoryChip(cat: cat)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func categoryChip(cat: Category) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(cat.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: cat.icon)
                    .font(.system(size: 22))
                    .foregroundColor(cat.color)
            }
            Text(cat.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Flash Deals
    
    private var flashDealsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header banner
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("Flash Deals")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("· Ends in")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("02:45:10")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .monospacedDigit()
                Spacer()
                Text("See all")
                    .font(.subheadline)
                    .foregroundColor(.brandGreen)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredProducts.prefix(3)) { product in
                        flashDealCard(product: product)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .padding(.vertical, -8)
        }
    }
    
    private func flashDealCard(product: FeaturedProduct) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.thumbnail ?? "")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                }
                .frame(width: 150, height: 130)
                .clipped()
                
                // Discount badge
                let discountPct = Int(((product.originalPrice - product.price) / product.originalPrice) * 100)
                Text("-\(discountPct)%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .cornerRadius(6)
                    .padding(8)
            }
            .frame(width: 150, height: 130)
            .background(Color(UIColor.secondarySystemBackground))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .padding(.top, 8)
                
                HStack(spacing: 4) {
                    Text("₱\(String(format: "%.0f", product.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                    Text("₱\(String(format: "%.0f", product.originalPrice))")
                        .font(.caption2)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
                
                // Progress bar (stock indicator)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: geo.size.width * 0.6, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.top, 2)
                
                Text("60% sold")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 150)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Featured Products
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Featured For You", actionLabel: "See all")
            
            VStack(spacing: 12) {
                ForEach(featuredProducts) { product in
                    featuredProductRow(product: product)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func featuredProductRow(product: FeaturedProduct) -> some View {
        HStack(spacing: 14) {
            // Thumbnail
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "photo").foregroundColor(.gray)
            }
            .frame(width: 72, height: 72)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.category)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.brandGreen)
                    Text(String(format: "%.1f", product.rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Price + cart
            VStack(alignment: .trailing, spacing: 6) {
                Text("₱\(String(format: "%.0f", product.price))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("₱\(String(format: "%.0f", product.originalPrice))")
                    .font(.caption2)
                    .strikethrough()
                    .foregroundColor(.secondary)
                
                Button {
                    // Add to cart
                } label: {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.brandGreen)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String, actionLabel: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button {
                // navigate
            } label: {
                Text(actionLabel)
                    .font(.subheadline)
                    .foregroundColor(.brandGreen)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    //HomeView()
}
















