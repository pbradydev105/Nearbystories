//
//  CategoryCell.swift
//  NearbyStores
//
//  Created by Amine on 7/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class CategoryCell: UICollectionViewCell {

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: EdgeLabel!
    @IBOutlet weak var highlightedCover: UIView!
    
    @IBOutlet weak var container: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted{
                highlightedCover.backgroundColor = Colors.white.withAlphaComponent(0.2)
            }else{
                highlightedCover.backgroundColor = UIColor.clear
            }
        }
    }
    
    func setupSettings() {
        
        self.name.initBolodFont()
        self.desc.initDefaultFont()
        
        self.image.contentMode = .scaleAspectFill
        
        self.container.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.container.layer.masksToBounds = true
        
        self.highlightedCover.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.highlightedCover.layer.masksToBounds = true
        
        if Utils.isRTL(){
             self.image.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
     
    
        self.desc.layer.masksToBounds = true
        self.desc.layer.borderColor = UIColor.white.cgColor
        self.desc.layer.borderWidth = 2.0
        self.desc.roundedCorners(radius: 25.0)
        
        self.desc.leftTextInset = 15
        self.desc.rightTextInset = 20
        self.desc.topTextInset = 2
        self.desc.bottomTextInset = 2
    }
    
    func setup(object: Category) {
        
        Utils.printDebug("category => \(object)")
        self.desc.text = " \("%d stores".localized.format(arguments: object.nbr_stores))"
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.locationOn), size: CGSize(width: 20, height: 20), textColor: UIColor.white)
        self.desc.setLeftIcon(image: icon)
        
        self.name.text = object.nameCat
        
        if let image = object.images {
            
            let url = URL(string: image.url500_500)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
    }
  

}
