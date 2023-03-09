//
//  CatetorySelectCell.swift
//  NearbyStores
//
//  Created by Amine  on 8/21/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Kingfisher

class CatetorySelectCell: UICollectionViewCell {

    //constraints
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var category_label: EdgeLabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    }
    
    func isSelected() {
        
        self.leftConstraint.constant = 0
        self.rightConstraint.constant = 0
        self.topConstraint.constant = 0
        self.bottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
        
    }

    func isDeselected() {
        
        self.leftConstraint.constant = 10
        self.rightConstraint.constant = 10
        self.topConstraint.constant = 10
        self.bottomConstraint.constant = 10
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
   
    
    func setting() {
        
        self.image.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.image.layer.masksToBounds = true
        
        self.container.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.container.layer.masksToBounds = true
        self.container.backgroundColor = Colors.Appearance.primaryColor
        
        category_label.leftTextInset = 5
        category_label.rightTextInset = 5
        category_label.topTextInset = 5
        category_label.bottomTextInset = 5
        
        category_label.initItalicFont(size: 14)
        category_label.text = "Category".localized
        
    }
    
    func setup(object: Category){
       
        
        self.setting()
        
        
        category_label.text = object.nameCat
        
    
        
        if(object.numCat == -1){
            
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
            
        }else if object.images?.url200_200 != ""{
            
            let url = URL(string: object.images!.url200_200)
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
    }
    
    
    
}
