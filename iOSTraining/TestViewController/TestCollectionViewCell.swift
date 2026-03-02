//
//  CollectionViewCell.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/26/26.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var imageName: String? {
        didSet {
            displayImage()
        }
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
        
        
        private func displayImage(){
            photoImageView.image = UIImage(named: imageName ?? "" )
            
        }

}
