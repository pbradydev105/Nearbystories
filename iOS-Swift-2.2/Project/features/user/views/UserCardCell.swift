//
//  OfferCardCell.swift
//  NearbyUsers
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SwiftIcons

class UserCardCell: UICollectionViewCell {

    
    
    //contraints
    @IBOutlet weak var imageContainerConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var infoConstraintHeight: NSLayoutConstraint!
    
    //view
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
   
    @IBOutlet weak var imageContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    
        
    }
    
    func makeAsDefault() {
        
        self.imageContainer.isSkeletonable = false
        self.name.isSkeletonable = false
        self.detail.isSkeletonable = false
        
        self.imageContainer.hideSkeleton()
        self.name.hideSkeleton()
        self.detail.hideSkeleton()
        
    }
    
    func makeAsLoader() {
        
        self.image.isSkeletonable = true
        self.name.isSkeletonable = true
        self.detail.isSkeletonable = true
       
        self.image.showAnimatedGradientSkeleton()
        self.name.showAnimatedGradientSkeleton()
        self.detail.showAnimatedGradientSkeleton()
        
    }
    
    let offline = UIImage.init(icon: .googleMaterialDesign(.radioButtonUnchecked), size: CGSize(width: 18, height: 18), textColor: Colors.lightGreen)
    let online = UIImage.init(icon: .googleMaterialDesign(.checkCircle), size: CGSize(width: 18, height: 18), textColor: Colors.lightGreen)
    
    func setting(style: CardHorizontalStyle?){
        
        self.backgroundColor = .clear
        
        let size = CGFloat(style!.height!-50-Users_HCards.header_size)
        self.imageContainerConstraintHeight.constant = size
        
        
        self.imageConstraintHeight.constant = size
        self.imageConstraintWidth.constant = size

        //self.infoConstraintHeight.constant = CGFloat(40)
        
        
        
        self.image.contentMode = .scaleAspectFill
        self.image.layer.borderWidth = 2
        self.image.layer.masksToBounds = false
        self.image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        
        //setup image size
        self.image.layer.cornerRadius = CGFloat(size/2)
        self.image.clipsToBounds = true
        
        self.detail.initDefaultFont(size: 12)
        self.detail.textColor = .gray
        self.detail.textAlignment = .center
        
        
        self.name.initDefaultFont(size: 14)
        //self.name.textColor = .black
        self.name.textAlignment = .center
        
        
        
        self.name.setLeftIcon(image: online)
        self.name.textAlignment = .center
    
    }
    
    
    func setup(object: User?) {
        

        if let object = object {
            
            makeAsDefault()
         
            
            let fullNameArr = object.name.split(separator: " ")
            let firstName:String = String(fullNameArr[0])
            self.name.text = firstName
            
            // self.name.text = object.name
            
       
            if object.blocked {
                self.name.textColor = Colors.gray
            }else{
                self.name.textColor = Colors.Appearance.primaryColor
            }
            
            self.detail.text = "@\(object.username)"
            
            
            //set image
            if let image = object.images {
                
                let url = URL(string: image.url100_100)
                self.image.kf.indicatorType = .activity
                self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                
            }else{
                
                if let img = UIImage(named: "profile_placeholder") {
                    self.image.image = img
                }
            }
            
        }else{
            self.makeAsLoader()
        }
        
    }

}
