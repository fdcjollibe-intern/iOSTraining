//
//  AllProductsView.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import SwiftUI
import Combine
import UIKit

// MARK: - Response model

struct AllProductsResponse: Decodable {
    let products: [Product]
}

// MARK: - ViewModel

final class AllProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchAll() {
        guard products.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://dummyjson.com/products?limit=200&skip=0") else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(AllProductsResponse.self, from: data)
                    self?.products = response.products
                } catch {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

// MARK: - AllProductsView

struct AllProductsView: View {
    let title: String
    let isSaleMode: Bool

    @StateObject private var viewModel = AllProductsViewModel()
    @StateObject private var saleManager = SaleManager.shared
    @State private var searchText: String = ""
    @State private var selectedProduct: Product? = nil
    @Environment(\.dismiss) private var dismiss

    var filtered: [Product] {
        guard !searchText.isEmpty else { return viewModel.products }
        return viewModel.products.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.category ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if let err = viewModel.errorMessage {
                    errorView(message: err)
                } else {
                    productGrid
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search products…")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Circle().fill(Color(UIColor.secondarySystemBackground)))
                    }
                }
            }
        }
        .onAppear { viewModel.fetchAll() }
        .background(
            AllProductDetailPresenter(selectedProduct: $selectedProduct)
        )
    }

    // MARK: - Grid

    private var productGrid: some View {
        ScrollView(showsIndicators: false) {
            if isSaleMode && saleManager.isSaleActive {
                saleHeaderStrip
            }

            HStack {
                Text("\(filtered.count) Products")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(UIColor.secondarySystemBackground)))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ], spacing: 14) {
                ForEach(filtered) { product in
                    AllProductCard(
                        product: product,
                        discount: fakeDiscount(for: product),
                        showSaleBorder: isSaleMode && saleManager.isSaleActive
                    )
                    .onTapGesture {
                        selectedProduct = product
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Sale Header Strip

    private var saleHeaderStrip: some View {
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
                .fill(Color(red: 0.13, green: 0.75, blue: 0.50).opacity(0.20))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: -80, y: 10)
            Circle()
                .fill(Color.yellow.opacity(0.10))
                .frame(width: 100, height: 100)
                .blur(radius: 28)
                .offset(x: 120, y: -5)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(Color(red: 0.04, green: 0.22, blue: 0.15))
                        Text("FLASH SALE — ALL DEALS")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(Color(red: 0.04, green: 0.22, blue: 0.15))
                            .tracking(1.4)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.98, green: 0.82, blue: 0.18)))

                    Text("Up to 50% OFF")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Text("\(viewModel.products.count) items")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        
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
                .padding(.leading, 20)
                Spacer()
                Image(systemName: "tag.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.12))
                    .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding(.bottom, 4)
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.4)
            Text("Loading products…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Retry") { viewModel.fetchAll() }
                .foregroundColor(.brandGreen)
        }
    }
}

// MARK: - All Product Card

struct AllProductCard: View {
    let product: Product
    let discount: DiscountInfo
    var showSaleBorder: Bool = false

    @State private var isFavorite: Bool = false
    @State private var cartAdded: Bool = false

    var discountedPrice: Double {
        product.price * (1.0 - discount.discountPercentage / 100.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: product.thumbnail ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.07)
                            ProgressView().scaleEffect(0.8)
                        }
                    case .success(let img):
                        img.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.07)
                            Image(systemName: "photo")
                                .foregroundColor(.gray.opacity(0.35))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .clipped()

                HStack(alignment: .top) {
                    Text(discount.badgeLabel)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(red: 0.88, green: 0.18, blue: 0.18))
                        )
                        .padding(8)
                    Spacer()
                    Button {
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(isFavorite ? .red : .gray)
                            .padding(6)
                            .background(Circle().fill(Color.white.opacity(0.93)))
                            .shadow(color: .black.opacity(0.10), radius: 3)
                    }
                    .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                if let tag = discount.tag {
                    Text(tag)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(red: 0.10, green: 0.52, blue: 0.36))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.10, green: 0.52, blue: 0.36).opacity(0.10))
                        )
                        .padding(.top, 2)
                }

                Text(product.title)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(minHeight: 32, alignment: .top)

                Text(product.category?.capitalized ?? "")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$\(String(format: "%.2f", discountedPrice))")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color.brandGreen)
                    Text("$\(String(format: "%.0f", product.price))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .strikethrough(true, color: .secondary)
                    Spacer()
                }
                .padding(.top, 2)

                // Add to Cart
                Button {
                    CartManager.shared.add(product: product, discountInfo: discount)
                    cartAdded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        cartAdded = false
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: cartAdded ? "checkmark" : "cart.badge.plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(cartAdded ? "Added!" : "Add to Cart")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
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
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .shadow(
                        color: Color(red: 0.10, green: 0.60, blue: 0.42).opacity(cartAdded ? 0.15 : 0.30),
                        radius: 5, x: 0, y: 3
                    )
                }
                .padding(.top, 7)
                .animation(.easeInOut(duration: 0.2), value: cartAdded)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
        .overlay(
            Group {
                if showSaleBorder {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(
                            Color(red: 0.10, green: 0.52, blue: 0.36).opacity(0.2),
                            lineWidth: 1
                        )
                }
            }
        )
    }
}

// MARK: - UIKit Bridge

struct AllProductDetailPresenter: UIViewControllerRepresentable {
    @Binding var selectedProduct: Product?

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard
            let product = selectedProduct,
            uiViewController.presentedViewController == nil
        else { return }

        // No storyboard — init from XIB (same name as the class)
        let detailVC = ProductDetailViewController(
            nibName: "ProductDetailViewController",
            bundle: nil
        )
        detailVC.product = product
        detailVC.modalPresentationStyle = .fullScreen

        Task { @MainActor in
            uiViewController.present(detailVC, animated: true)
            selectedProduct = nil
        }
    }
}

// MARK: - Hosting Controller

final class AllProductsHostingController: UIHostingController<AllProductsView> {

    init(title: String, isSaleMode: Bool) {
        super.init(rootView: AllProductsView(title: title, isSaleMode: isSaleMode))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
