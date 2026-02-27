//
//  ProductImageCollectionViewCell.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/26/26.
//

import UIKit

class ProductImageCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var photoImageCollection: UIImageView!
    
    
    private var currentURL: String?

        var imageURL: String? {
            didSet {
                loadImage()
            }
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            photoImageCollection.contentMode = .scaleAspectFit
            photoImageCollection.clipsToBounds = true
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            photoImageCollection.image = nil
            currentURL = nil
        }

        private func loadImage() {
            guard let urlString = imageURL, let url = URL(string: urlString) else {
                photoImageCollection.image = UIImage(systemName: "photo")
                return
            }

            currentURL = urlString

            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data),
                      self.currentURL == urlString else { return }

                DispatchQueue.main.async {
                    self.photoImageCollection.image = image
                }
            }.resume()
        }
    }
