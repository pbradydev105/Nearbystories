//
//  OfferCell.swift
//  NearbyStores
//
//  Created by Amine on 6/7/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import SkeletonView

class OfferV2Cell: UICollectionViewCell {

    
    @IBOutlet weak var gradient_bg: GradientBGView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var featured: EdgeLabel!
    
    @IBOutlet weak var offer: EdgeLabel!
    
    @IBOutlet weak var store_name: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var distance: EdgeLabel!
    
    func makeAsDefault() {
        
        self.image.isSkeletonable = false
        self.title.isSkeletonable = false
        self.store_name.isSkeletonable = false
        
        self.image.hideSkeleton()
        self.title.hideSkeleton()
        self.store_name.hideSkeleton()
        
        
        self.featured.isHidden = false
        self.offer.isHidden = false
        self.distance.isHidden = false
        self.gradient_bg.isHidden = false
        
    }
    
    
    func makeAsLoader() {
        
        self.image.isSkeletonable = true
        self.title.isSkeletonable = true
        self.store_name.isSkeletonable = true
        
        self.image.showAnimatedGradientSkeleton()
        self.title.showAnimatedGradientSkeleton()
        self.store_name.showAnimatedGradientSkeleton()
        
        self.featured.isHidden = true
        self.offer.isHidden = true
        self.distance.isHidden = true
        self.gradient_bg.isHidden = true
    
        
    }
    
    func setupSettings()  {
        
        self.addShadowView()
        
        self.container.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        //offers tag
        offer.leftTextInset = 15
        offer.rightTextInset = 15
        offer.topTextInset = 10
        offer.bottomTextInset = 10
        offer.backgroundColor = Colors.Appearance.darkColor
        offer.initDefaultFont()
        
        offer.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        
        featured.leftTextInset = 15
        featured.rightTextInset = 15
        featured.bottomTextInset = 10
        featured.topTextInset = 10
        featured.backgroundColor = Colors.featuredTagColor
        featured.text = "Featured".localized.uppercased()
        featured.initDefaultFont()
        
        featured.roundCorners(radius: 25/UIScreen.main.nativeScale)
       
        
        distance.leftTextInset = 15
        distance.rightTextInset = 15
        distance.topTextInset = 10
        distance.bottomTextInset = 10
        distance.backgroundColor = Colors.Appearance.primaryColor
        distance.initDefaultFont()
        
        distance.roundCorners(radius: 25/UIScreen.main.nativeScale)
      
        image.contentMode = .scaleAspectFill
        
        title.initBolodFont()
        store_name.initDefaultFont()
        
        //title.text = "Lorim Ipsum"
        //store_name.text = "Lorim Ipsum"
        
    
        
        
    }
    
    func setup(object: Offer)  {
        
        guard object.id > 0 else {
            makeAsLoader()
            return 
        }
        
        makeAsDefault()
        
        self.title.text = object.name
        self.store_name.text = object.store_name
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: UIColor.white)
        
        if Utils.isRTL(){
            self.store_name.setRightIcon(image: icon)
        }else{
           self.store_name.setLeftIcon(image: icon)
        }
        
        
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
        
        let distance = object.distance.calculeDistance()
        self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
        
        if object.value_type == "price" {
            
            if let currency = object.currency {
                if let pprice = currency.parseCurrencyFormat(price: Float(object.offer_value)){
                    offer.text = pprice
                }
            }
            
        }else if object.value_type == "percent" {
            offer.text = "\(Int(object.offer_value))%"
            
        }else{
            offer.text = "Promotion".localized
        }
        
    
        self.featured.text = ""
        self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
        
        
    }
    
    
   
}










