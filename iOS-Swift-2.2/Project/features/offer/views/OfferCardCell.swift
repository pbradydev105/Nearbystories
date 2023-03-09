//
//  OfferCardCell.swift
//  NearbyOffers
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SkeletonView

class OfferCardCell: UICollectionViewCell {

    
    //contraints
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var infoConstraintHeight: NSLayoutConstraint!
    
    //view
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var sale: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    
        
    }
    
    func makeAsDefault() {
        
        self.image.isSkeletonable = false
        self.name.isSkeletonable = false
        self.detail.isSkeletonable = false
        
        self.image.hideSkeleton()
        self.name.hideSkeleton()
        self.detail.hideSkeleton()
        
        
        self.featured.isHidden = false
        self.sale.isHidden = false
        
       
    }
    
    
    func makeAsLoader() {
        
        self.image.isSkeletonable = true
        self.name.isSkeletonable = true
        self.detail.isSkeletonable = true
        
        self.image.showAnimatedGradientSkeleton()
        self.name.showAnimatedGradientSkeleton()
        self.detail.showAnimatedGradientSkeleton()
        
        self.featured.isHidden = true
        self.sale.isHidden = true
        
    }
    
    func setting(style: CardHorizontalStyle){
        
        self.imageConstraintHeight.constant = CGFloat(style.height!-50-Offers_HCards.header_size)
        //self.infoConstraintHeight.constant = CGFloat(40)
        
        
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
    
        
        self.detail.initDefaultFont(size: 12)
        self.detail.textColor = .gray
        
        
        self.name.initDefaultFont(size: 14)
        //self.name.textColor = .black
        
        //offers tag
        self.sale.leftTextInset = 8
        self.sale.rightTextInset = 8
        self.sale.topTextInset = 4
        self.sale.bottomTextInset = 4
        self.sale.backgroundColor = Colors.Appearance.primaryColor
        self.sale.initDefaultFont(size: 14)
        self.sale.textColor = .white
        self.sale.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        
        self.featured.leftTextInset = 5
        self.featured.rightTextInset = 5
        self.featured.topTextInset = 4
        self.featured.bottomTextInset = 4
        self.featured.backgroundColor = Colors.featuredTagColor
        self.featured.initDefaultFont(size: 14)
        self.featured.textColor = .white
        self.featured.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.featured.text = ""
        
        self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
        
        
    }
    
    
    func setup(object: Offer?) {
        
        //configure & setup
        if let object = object {
            
            self.makeAsDefault()
            
            self.name.text = object.name
            
            
            if object.listImages.count>0 {
                
                if object.listImages[0].url500_500 != ""{
                    let url = URL(string: object.listImages[0].url500_500)
                    self.image.kf.indicatorType = .activity
                    self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                }else{
                    if let img = UIImage(named: "default_store_image") {
                        self.image.image = img
                    }
                }
                
                
            }else{
                if let img = UIImage(named: "default_store_image") {
                    self.image.image = img
                }
            }
            
            
            if object.featured == 1 {
                self.featured.isHidden = false
            }else {
                self.featured.isHidden = true
            }
            
            self.detail.text = object.short_description
            
            
            _ = object.distance.calculeDistance()
            //self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
            
            if object.value_type == "price" {
                
                if let currency = object.currency {
                    if let pprice = currency.parseCurrencyFormat(price: Float(object.offer_value)){
                     
                        // self.detail.text = "\(pprice) - "+object._description
                         self.sale.text = "\(pprice)"
                    }
                }
                
            }else if object.value_type == "percent" {
                //self.detail.text = "\(Int(object.offer_value))% - "+object._description
                self.sale.text = "\(Int(object.offer_value))%"
            }else{
               // self.detail.text = "\("Promotion".localized) - "+object._description
                self.sale.text = "\("Promotion".localized)"
            }
            
            
        }else{
            
            self.makeAsLoader()
            
        }
        
    }

}
