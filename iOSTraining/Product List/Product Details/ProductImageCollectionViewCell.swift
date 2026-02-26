//
//  ProductImageCollectionViewCell.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/26/26.
//

import UIKit

class ProductImageCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var photoImageCollection: UIImageView!
    
    
    
    var imageName: String? {
        didSet {
            displayImage()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
        
        
        private func displayImage(){
            photoImageCollection.image = UIImage(named: imageName ?? "" )
            
        }
    

}
