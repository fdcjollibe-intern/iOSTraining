//
//  TestViewController.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 2/26/26.
//

import UIKit

class TestViewController: UIViewController {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    private let identifier = "TestCollectionViewCell"
    private let identifier1 = "Section1CollectionViewCell"
    
    private var photos: [String] = [
        "person1", "person2", "L5Pro", "RG16", "ZG16",
        "person1", "person2", "L5Pro", "RG16", "ZG16",
        "person1", "person2", "L5Pro", "RG16", "ZG16",
        "person1", "person2", "L5Pro", "RG16", "ZG16",
        "person1", "person2", "L5Pro", "RG16", "ZG16",
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: identifier, bundle: nil)
        let nib1 = UINib(nibName: identifier1, bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        collectionView.register(nib1, forCellWithReuseIdentifier: identifier1)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    
    }

}


extension TestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // number of sections in the collection view
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier1, for: indexPath) as? Section1CollectionViewCell {
                
                //cell.imageName = photos[indexPath.row]
                return cell
            }
            
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TestCollectionViewCell {
                cell.imageName = photos[indexPath.row]
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let column: CGFloat = 3
        let spacing: CGFloat = 10
        let insets: CGFloat = 10 * 2
        
        let totalInterItemSpacing = spacing * (column - 1)
        let availableWidth = collectionView.bounds.width - insets - totalInterItemSpacing
        let itemWitdh = floor (availableWidth / column)
                               
        return CGSize(width: itemWitdh, height: itemWitdh)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Wohoo!",
            message: "Do you want to proceed? ",
            preferredStyle: .alert)
       

        
    let yesAction = UIAlertAction(title: "Yes", style: .destructive){ _ in
            
    }
       
    let noAction = UIAlertAction(title: "No", style: .default){ _ in
                
    }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
    //alert.addAction(okAction)
    self.present(alert, animated: true)
    
}
}







      
