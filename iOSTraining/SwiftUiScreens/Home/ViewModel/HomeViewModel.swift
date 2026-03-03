//
//  HomeViewModel.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/3/26.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://dummyjson.com/products?limit=30") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ProductsResponse.self, decoder: {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error fetching products: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.products = response.products
                print("✅ Fetched \(response.products.count) products")
            }
            .store(in: &cancellables)
    }
    
    var newArrivals: [Product] {
        // Get products with high discount as new arrivals
        products
            .filter { ($0.discountPercentage ?? 0) >= 10 }
            .prefix(10)
            .map { $0 }
    }
    
    var categories: [(name: String, count: Int, icon: String, products: [Product])] {
        let categoryGroups = Dictionary(grouping: products) { $0.category ?? "Other" }
        
        return categoryGroups.map { (name, products) in
            let icon: String
            switch name.lowercased() {
            case "smartphones", "laptops", "tablets":
                icon = "iphone"
            case "mens-shirts", "mens-shoes", "mens-watches", "womens-dresses", "womens-shoes", "womens-watches", "womens-bags", "womens-jewellery":
                icon = "tshirt.fill"
            case "furniture", "home-decoration":
                icon = "sofa.fill"
            case "beauty", "fragrances", "skin-care", "sunglasses":
                icon = "sparkles"
            case "sports-accessories", "motorcycle", "vehicle":
                icon = "figure.run"
            default:
                icon = "square.grid.2x2.fill"
            }
            
            return (name: name.capitalized, count: products.count, icon: icon, products: products)
        }
        .sorted { $0.count > $1.count }
    }
    
    var categoriesSimplified: [(name: String, count: Int, icon: String, color: String)] {
        [
            ("New Arrivals", newArrivals.count, "sparkles", "purple"),
            ("Clothes", products.filter { $0.category?.contains("shirt") == true || $0.category?.contains("dress") == true }.count, "tshirt.fill", "pink"),
            ("Bags", products.filter { $0.category?.contains("bag") == true }.count, "bag.fill", "orange"),
            ("Shoes", products.filter { $0.category?.contains("shoe") == true }.count, "figure.walk", "blue"),
            ("Electronics", products.filter { $0.category?.contains("phone") == true || $0.category?.contains("laptop") == true || $0.category?.contains("tablet") == true }.count, "iphone", "green"),
        ]
    }
}
