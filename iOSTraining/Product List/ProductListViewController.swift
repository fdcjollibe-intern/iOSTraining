//
//  ProductListViewController.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//

import UIKit

class ProductListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var productSearchBar: UISearchBar!
    
    
    private let cellIdentifier = "ProductListTableViewCell"
    private var searchWorkItem: DispatchWorkItem?
    
    
    
    var products: [Product] = [
        Product(image: ["L5Pro", "RG16", "ZG14", "ZG16"],
                name: "Lenovo Legion 5 Pro R9000P 2025",
                rating: 4.5,
                description: "Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease. Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations.",
                price: 110999.0,
                category: "Laptops",
                isFeatured: true,
                reviews: 128.0,
                inStock: true,
                overview: """
Premium design meets powerful performance in this sleek gaming laptop.
The Aurex ProBook X14 is engineered for performance-driven users who demand speed, reliability, and mobility in one sleek device. Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease.

Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations. The ultra-fast 512GB NVMe SSD ensures quick boot times and seamless file access.

Encased in a premium aluminum chassis, the ProBook X14 combines durability with a lightweight design, perfect for work on the go. With up to 10 hours of battery life and advanced security features like fingerprint authentication, it’s built to keep up with your day — wherever it takes you.
""",
                highlight: ["AMD Ryzen 9 Processor", "16GB DDR5 RAM", "RTX 4060 Graphics"]),
        Product(image: ["RG16", "L5Pro", "ZG14", "ZG16"],
                name: "ASUS ROG Strix G16 2025",
                rating: 4.0,
                description: "Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease. Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations.",
                price: 160547.0,
                category: "Laptops",
                isFeatured: false,
                reviews: 95.0,
                inStock: true,
                overview: """
Premium design meets powerful performance in this sleek gaming laptop.
The Aurex ProBook X14 is engineered for performance-driven users who demand speed, reliability, and mobility in one sleek device. Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease.

Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations. The ultra-fast 512GB NVMe SSD ensures quick boot times and seamless file access.

Encased in a premium aluminum chassis, the ProBook X14 combines durability with a lightweight design, perfect for work on the go. With up to 10 hours of battery life and advanced security features like fingerprint authentication, it’s built to keep up with your day — wherever it takes you.
""",
                highlight: ["Intel Core i7", "32GB RAM", "RGB Keyboard"]),
        Product(image: ["ZG14", "L5Pro", "RG16", "ZG16"],
                name: "ASUS ROG Zephyrus G14 2025",
                rating: 4.8,
                description: "Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease. Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations.",
                price: 130499.0,
                category: "Laptops",
                isFeatured: true,
                reviews: 203.0,
                inStock: false,
                overview: """
Premium design meets powerful performance in this sleek gaming laptop.
The Aurex ProBook X14 is engineered for performance-driven users who demand speed, reliability, and mobility in one sleek device. Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease.

Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations. The ultra-fast 512GB NVMe SSD ensures quick boot times and seamless file access.

Encased in a premium aluminum chassis, the ProBook X14 combines durability with a lightweight design, perfect for work on the go. With up to 10 hours of battery life and advanced security features like fingerprint authentication, it’s built to keep up with your day — wherever it takes you.
""",
                highlight: ["AMD Ryzen 7", "Compact 14-inch Design", "Long Battery Life"]),
        Product(image: ["ZG16", "ZG14", "RG16", "L5Pro"],
                name: "ASUS ROG Zephyrus G16",
                rating: 4.2,
                description: "Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease. Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations.",
                price: 147150.00,
                category: "Laptops",
                isFeatured: false,
                reviews: 147.0,
                inStock: true,
                overview: """
Premium design meets powerful performance in this sleek gaming laptop.
The Aurex ProBook X14 is engineered for performance-driven users who demand speed, reliability, and mobility in one sleek device. Powered by the latest Intel Core i7 processor and 16GB of high-speed DDR5 RAM, it handles multitasking, creative workloads, and business applications with ease.

Its 14-inch Full HD IPS display delivers sharp visuals and vibrant colors, making it ideal for content creation, streaming, and professional presentations. The ultra-fast 512GB NVMe SSD ensures quick boot times and seamless file access.

Encased in a premium aluminum chassis, the ProBook X14 combines durability with a lightweight design, perfect for work on the go. With up to 10 hours of battery life and advanced security features like fingerprint authentication, it’s built to keep up with your day — wherever it takes you.
""",
                highlight: ["Intel Core i9", "QHD Display", "Premium Build Quality"]),
    ]
    
    var filteredProducts: [Product] = []
    
    var isSearching: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Product List"
        
        let  sortBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(didTapSort)
        )
        self.navigationItem.rightBarButtonItem = sortBarButtonItem
        
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        //tableView.backgroundColor = .systemGroupedBackground
        
        
        productSearchBar.delegate = self
        productSearchBar.placeholder = "Search products..."
        productSearchBar.showsCancelButton = true
        productSearchBar.searchTextField.textColor = .black
        
        
        filteredProducts = products
    }
    
    
    
    private func performSearch(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredProducts = products
        } else {
            isSearching = true
            filteredProducts = products.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                (product.description.lowercased().contains(searchText.lowercased())) ||
                (product.category?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }
    
    
    @objc func didTapSort() {
        
        let alert = UIAlertController(title: "Sort Products", message: "Choose a sorting option", preferredStyle: .actionSheet)
        
        // Featured sort
        let featuredAction = UIAlertAction(title: "Featured", style: .default) { [weak self] _ in
            self?.sortByFeatured()
        }
        if let sparklesImage = UIImage(systemName: "sparkles") {
            featuredAction.setValue(sparklesImage, forKey: "image")
        }
        alert.addAction(featuredAction)
        
        // A-Z Name sort
        let nameAction = UIAlertAction(title: "Name (A-Z)", style: .default) { [weak self] _ in
            self?.sortByName()
        }
        if let textImage = UIImage(systemName: "textformat.abc") {
            nameAction.setValue(textImage, forKey: "image")
        }
        alert.addAction(nameAction)
        
        // Price Low to High sort
        let priceAction = UIAlertAction(title: "Price (Low - High)", style: .default) { [weak self] _ in
            self?.sortByPrice()
        }
        if let moneyImage = UIImage(systemName: "dollarsign.circle") {
            priceAction.setValue(moneyImage, forKey: "image")
        }
        alert.addAction(priceAction)
        
        // Top Rated sort
        let ratingAction = UIAlertAction(title: "Top Rated", style: .default) { [weak self] _ in
            self?.sortByRating()
        }
        if let starImage = UIImage(systemName: "star.fill") {
            ratingAction.setValue(starImage, forKey: "image")
        }
        alert.addAction(ratingAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func sortByFeatured() {
        let dataToSort = isSearching ? filteredProducts : products
        let sorted = dataToSort.sorted { (product1, product2) -> Bool in
            let isFeatured1 = product1.isFeatured ?? false
            let isFeatured2 = product2.isFeatured ?? false
            return isFeatured1 && !isFeatured2
        }
        
        if isSearching {
            filteredProducts = sorted
        } else {
            products = sorted
        }
        
        tableView.reloadData()
    }
    
    private func sortByName() {
        if isSearching {
            filteredProducts.sort { $0.name < $1.name }
        } else {
            products.sort { $0.name < $1.name }
        }
        tableView.reloadData()
    }
    
    private func sortByPrice() {
        if isSearching {
            filteredProducts.sort { $0.price < $1.price }
        } else {
            products.sort { $0.price < $1.price }
        }
        tableView.reloadData()
    }
    
    private func sortByRating() {
        let dataToSort = isSearching ? filteredProducts : products
        let sorted = dataToSort.sorted { (product1, product2) -> Bool in
            let rating1 = product1.rating ?? 0.0
            let rating2 = product2.rating ?? 0.0
            return rating1 > rating2
        }
        
        if isSearching {
            filteredProducts = sorted
        } else {
            products = sorted
        }
        tableView.reloadData()
    }
    
    
}





extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredProducts.count : products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProductListTableViewCell {
            let product = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
            cell.product = product
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tap on product at index: \(indexPath.row)")
        
        let selectedProduct = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
        
        let productDetailVC = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
        productDetailVC.product = selectedProduct
        
        self.navigationController?.pushViewController(productDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

extension ProductListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel previous search work item
        searchWorkItem?.cancel()
        
        // Create new work item with 0.5 second delay
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(with: searchText)
        }
        
        searchWorkItem = workItem
        
        // Execute search after 0.5 seconds of no typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        isSearching = false
        searchBar.text = ""
        filteredProducts = products
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        if let searchText = searchBar.text {
            performSearch(with: searchText)
        }
        searchBar.resignFirstResponder()
    }
}
