//
//  ProductListViewController.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/25/26.
//

import UIKit

class ProductListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "ProductListTableViewCell"
    
    
    var products: [Product] = [
        Product(image: ["L5Pro"],
                name: "Lenovo Legion 5 Pro R9000P 2025",
                rating: 4.5,
                description: "High-performance gaming laptop with AMD Ryzen processor",
                price: 110999.0,
                category: "Laptops",
                isFeatured: true,
                reviews: 128.0,
                inStock: true),
        Product(image: ["RG16"],
                name: "ASUS ROG Strix G16 2025",
                rating: 4.0,
                description: "Powerful gaming machine with RGB lighting",
                price: 160547.0,
                category: "Laptops",
                isFeatured: false,
                reviews: 95.0,
                inStock: true),
        Product(image: ["ZG14"],
                name: "ASUS ROG Zephyrus G14 2025",
                rating: 4.8,
                description: "Ultra-portable gaming laptop",
                price: 130499.0,
                category: "Laptops",
                isFeatured: true,
                reviews: 203.0,
                inStock: false),
        Product(image: ["ZG16"],
                name: "ASUS ROG Zephyrus G16",
                rating: 4.2,
                description: "Premium gaming laptop with sleek design",
                price: 147150.00,
                category: "Laptops",
                isFeatured: false,
                reviews: 147.0,
                inStock: true),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Product List"
        
        let  sortBarButtonItem = UIBarButtonItem(
            title: "Sort",
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
            products.sort { (product1, product2) -> Bool in
                let isFeatured1 = product1.isFeatured ?? false
                let isFeatured2 = product2.isFeatured ?? false
                return isFeatured1 && !isFeatured2
            }
            tableView.reloadData()
        }

        private func sortByName() {
            products.sort { $0.name < $1.name }
            tableView.reloadData()
        }

        private func sortByPrice() {
            products.sort { $0.price < $1.price }
            tableView.reloadData()
        }

        private func sortByRating() {
            products.sort { (product1, product2) -> Bool in
                let rating1 = product1.rating ?? 0.0
                let rating2 = product2.rating ?? 0.0
                return rating1 > rating2
            }
            tableView.reloadData()
        }
    
    
}

    
    
    

extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProductListTableViewCell {
            cell.product = products[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tap on product at index: \(indexPath.row)")
        
        let productDetailVC = ProductDetailViewController()
        self.navigationController?.pushViewController(productDetailVC, animated: true)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
