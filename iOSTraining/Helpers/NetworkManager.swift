//
//  NetworkManager.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/27/26.
//

import Foundation


protocol NetworkManagerDelegate: AnyObject {
    func didFetchProducts(_ products: [Product])
    func didFailWithError(_ error: Error)
}


class NetworkManager {
    static let shared = NetworkManager()

    weak var delegate: NetworkManagerDelegate?

    private init() {}

    func fetchProducts() {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error)
                }
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                let productResponse = try decoder.decode(ProductsResponse.self, from: data)
                print("Fetched \(productResponse.products.count) products")

                DispatchQueue.main.async {
                    self.delegate?.didFetchProducts(productResponse.products)
                }
            } catch {
                print("Decode error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error)
                }
            }
        }.resume()
    }
}
