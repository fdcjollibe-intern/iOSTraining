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

    var products: [Product] = []
    var filteredProducts: [Product] = []
    var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Products"

        let sortBarButtonItem = UIBarButtonItem(
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

        productSearchBar.delegate = self
        productSearchBar.placeholder = "Search products..."
        productSearchBar.showsCancelButton = true
        productSearchBar.searchTextField.textColor = .black

        // Set self as the NetworkManager delegate, then fetch
        NetworkManager.shared.delegate = self
        NetworkManager.shared.fetchProducts()
    }

    //Search

    private func performSearch(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredProducts = products
        } else {
            isSearching = true
            filteredProducts = products.filter { product in
                product.title.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased()) ||
                (product.category?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }

    // Sort

    @objc func didTapSort() {
        let alert = UIAlertController(title: "Sort Products", message: "Choose a sorting option", preferredStyle: .actionSheet)

        let discountAction = UIAlertAction(title: "Highest Discount", style: .default) { [weak self] _ in
            self?.sortByDiscount()
        }
        if let sparklesImage = UIImage(systemName: "sparkles") {
            discountAction.setValue(sparklesImage, forKey: "image")
        }
        alert.addAction(discountAction)

        let nameAction = UIAlertAction(title: "Name (A-Z)", style: .default) { [weak self] _ in
            self?.sortByName()
        }
        if let textImage = UIImage(systemName: "textformat.abc") {
            nameAction.setValue(textImage, forKey: "image")
        }
        alert.addAction(nameAction)

        let priceAction = UIAlertAction(title: "Price (Low - High)", style: .default) { [weak self] _ in
            self?.sortByPrice()
        }
        if let moneyImage = UIImage(systemName: "dollarsign.circle") {
            priceAction.setValue(moneyImage, forKey: "image")
        }
        alert.addAction(priceAction)

        let ratingAction = UIAlertAction(title: "Top Rated", style: .default) { [weak self] _ in
            self?.sortByRating()
        }
        if let starImage = UIImage(systemName: "star.fill") {
            ratingAction.setValue(starImage, forKey: "image")
        }
        alert.addAction(ratingAction)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    
    private func sortByDiscount() {
        let sorted = (isSearching ? filteredProducts : products).sorted {
            ($0.discountPercentage ?? 0) > ($1.discountPercentage ?? 0)
        }
        isSearching ? (filteredProducts = sorted) : (products = sorted)
        tableView.reloadData()
    }

    private func sortByName() {
        if isSearching {
            filteredProducts.sort { $0.title < $1.title }
        } else {
            products.sort { $0.title < $1.title }
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
        let sorted = (isSearching ? filteredProducts : products).sorted {
            ($0.rating ?? 0) > ($1.rating ?? 0)
        }
        isSearching ? (filteredProducts = sorted) : (products = sorted)
        tableView.reloadData()
    }
    
    
    
    private func addToWishlist(product: Product) {
        let alert = UIAlertController(
            title: "❤️ Added to Wishlist",
            message: "\(product.title) has been added to your wishlist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func buyNow(product: Product) {
        let alert = UIAlertController(
            title: "🛒 Buy Now",
            message: "Proceed to purchase \(product.title)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { _ in
            let confirmationAlert = UIAlertController(
                title: "Order Placed!",
                message: "Thank you for purchasing \(product.title).",
                preferredStyle: .alert
            )
            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(confirmationAlert, animated: true)
        })
        present(alert, animated: true)
    }
    
    
    
}

// NetworkManagerDelegate

extension ProductListViewController: NetworkManagerDelegate {

    func didFetchProducts(_ products: [Product]) {
        self.products = products
        self.filteredProducts = products
        tableView.reloadData()
    }

    func didFailWithError(_ error: Error) {
        print("Failed to fetch products: \(error.localizedDescription)")

        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load products. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// TableView

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
        let selectedProduct = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]

        let productDetailVC = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
        productDetailVC.product = selectedProduct

        self.navigationController?.pushViewController(productDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let product = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
        
        let buyAction = UIContextualAction(style: .normal, title: "Buy Now") { [weak self] (_, _, completion) in
            self?.buyNow(product: product)
            completion(true)
        }
        buyAction.backgroundColor = .systemGreen
        buyAction.image = UIImage(systemName: "cart.fill")
        
        return UISwipeActionsConfiguration(actions: [buyAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let product = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
        
        let wishlistAction = UIContextualAction(style: .normal, title: "Add to Wishlist") { [weak self] (_, _, completion) in
            self?.addToWishlist(product: product)
            completion(true)
        }
        wishlistAction.backgroundColor = .systemPink
        wishlistAction.image = UIImage(systemName: "heart.fill")
        
        return UISwipeActionsConfiguration(actions: [wishlistAction])
    }
}





// orig file just for backup
//extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return isSearching ? filteredProducts.count : products.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProductListTableViewCell {
//            let product = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
//            cell.product = product
//            return cell
//        }
//        return UITableViewCell()
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedProduct = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
//
//        let productDetailVC = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
//        productDetailVC.product = selectedProduct
//
//        self.navigationController?.pushViewController(productDetailVC, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}

// SearchBar

extension ProductListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(with: searchText)
        }
        searchWorkItem = workItem
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



