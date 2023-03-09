//
//  OfferCardCell.swift
//  NearbyCategories
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SwiftIcons
import Kingfisher

class CategoryCardCell: UICollectionViewCell {

    
    //contraints
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
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
        
        self.imageContainer.isSkeletonable = true
        self.name.isSkeletonable = true
        self.detail.isSkeletonable = true
        
        self.imageContainer.showAnimatedGradientSkeleton()
        self.name.showAnimatedGradientSkeleton()
        self.detail.showAnimatedGradientSkeleton()
        
    }
    
    func setting(style: CardHorizontalStyle?){
        
        
        self.imageConstraintHeight.constant = CGFloat(style!.height!-45-Categories_HCards.header_size)
        //self.infoConstraintHeight.constant = CGFloat(35)
        
        
        self.image.contentMode = .scaleAspectFit
        self.image.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.image.layer.masksToBounds = true
        
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
        self.imageContainer.backgroundColor = Colors.Appearance.primaryColor
        
        self.detail.initDefaultFont(size: 12)
        self.detail.textColor = .gray
        
        
        self.name.initDefaultFont(size: 14)
        self.name.textAlignment = .center
        self.detail.textAlignment = .center
       
        
        
        //test icons
        if let _style = style, let width = _style.width{
            let size = Double(width)/2
            
            let iconTest = UIImage.init(icon: .linearIcons(.coffeeCup), size: CGSize(width: size, height: size), textColor: .white)
            self.image.image = iconTest
            self.image.contentMode = .center
            
        }
        
        
        
    }
    
    
    func setup(object: Category?) {
        
        if let object = object {
            
            self.makeAsDefault()
            
            self.detail.text = " \("%d stores".localized.format(arguments: object.nbr_stores))"
            self.name.text = object.nameCat
            
            if let color = object.color, object.color != ""{
                self.imageContainer.backgroundColor =  Utils.hexStringToUIColor(hex: color)
            }else{
                
            }
            
            if let image = object.icon, image.id != "" {
                
                let url = URL(string: image.url500_500)
            
                self.image.contentMode = .scaleAspectFit
                self.image.kf.indicatorType = .activity
                
                let processor = OverlayImageProcessor(overlay: .white, fraction: 0.0)

                self.image.kf.setImage(with: url,options: [.transition(.fade(0.2)), .processor(processor) ])
                
            }else if let image = object.images {
                
                let url = URL(string: image.url500_500)
                
                self.image.contentMode = .scaleAspectFill
                self.image.kf.indicatorType = .activity
                self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                
            }else{
                if let img = UIImage(named: "default_store_image") {
                    self.image.image = img
                }
            }
            
        }else{
            self.makeAsLoader()
        }
        
    }

}
