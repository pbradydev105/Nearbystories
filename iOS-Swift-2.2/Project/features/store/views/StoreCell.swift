//
//  StoreCell.swift
//  NearbyStores
//
//  Created by Amine on 5/31/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher

class StoreCell: UICollectionViewCell {
    
    
    //Outlets
    @IBOutlet weak var container_shadow: UIView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var infosContainer: UIView!
    @IBOutlet weak var sale: EdgeLabel!
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var category: EdgeLabel!
    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var lastOffer: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var highlightedCover: UIView!
    
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted{
                highlightedCover.backgroundColor = Colors.white.withAlphaComponent(0.2)
            }else{
                highlightedCover.backgroundColor = UIColor.clear
            }
        }
    }
    
    func setupSettings()  {
        
        // radius & shadowing style
        container_shadow.addShadowView(width:1, height:5, opcaity:0.1, maskToBounds:false, radius:5)
        container.roundedCorners(radius: 20)
          
       
        //distance tag
        distance.leftTextInset = 10
        distance.rightTextInset = 10
        distance.bottomTextInset = 5
        distance.topTextInset = 5
        distance.backgroundColor = Colors.darkColor
        distance.initDefaultFont()
        distance.roundedCorners(radius: 20)
        
        
        //offers tag
        category.leftTextInset = 10
        category.rightTextInset = 10
        category.topTextInset = 5
        category.bottomTextInset = 5
        category.backgroundColor = Colors.primaryColor
        category.initDefaultFont()
        category.roundedCorners(radius: 20)
     
        
        
        //offers tag
        sale.leftTextInset = 12
        sale.rightTextInset = 12
        sale.topTextInset = 8
        sale.bottomTextInset = 8
        sale.backgroundColor = Colors.promoTagColor
        sale.initDefaultFont()
        sale.roundedCorners(radius: 20)
        
        
        featured.leftTextInset = 12
        featured.rightTextInset = 12
        featured.bottomTextInset = 8
        featured.topTextInset = 8
        featured.backgroundColor = Colors.featuredTagColor
        featured.text = "Featured".localized.uppercased()
        featured.initDefaultFont()
        featured.roundedCorners(radius: 20)
       
    
        image.contentMode = .scaleAspectFill
        
        ratingContainer.addSubview(ratingView)
      
        
        
        //if it is RTL
        if Utils.isRTL(){
            
            ratingView.translatesAutoresizingMaskIntoConstraints = false
            ratingContainer.addConstraints([
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .top,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .top,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .bottom,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .bottom,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .right,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .right,
                    multiplier: 1, constant: 0),
                ])
        }
        
        
      
        title.initDefaultFont()
        address.initDefaultFont()
        title.textColor = .black

        
        self.featured.text = ""
        self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
        
        
        self.infosContainer.backgroundColor = Colors.Appearance.white
        self.title.textColor = Colors.Appearance.black
    
    }
    
    
    func setup(object: Store)  {
        
        guard object.id > 0 else {
                   makeAsLoader()
                   return
               }
               
               makeAsDefault()
               
      
        
        self.title.text = object.name
        self.address.text = object.address
        
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        // localize to your grouping and decimal separator
        formatter.locale = Locale.current
        
        let number = NSNumber(value: object.votes)
     
        
        if let value = formatter.string(from: number){
             self.ratingView.text = "\(value) (\(object.nbr_votes)) "
        }else{
            self.ratingView.text = "\(object.votes) (\(object.nbr_votes)) "
        }
       
        self.ratingView.rating = 1
        
    
        //set image
        
        if object.listImages.count > 0 {
            
           
            if let first = object.listImages.first {
                
                let url = URL(string: first.url500_500)
              
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
        
        
        
        if object.lastOffer != "" {
            lastOffer.isHidden = false
            self.lastOffer.text = object.lastOffer
        }else{
            lastOffer.isHidden = true
        }
    
        
        
        let distance = object.distance.calculeDistance()
        self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
        self.distance.isHidden = false
     
       /* if MyLocation.isProvided{
            self.distance.isHidden = false
        }else{
            self.distance.isHidden = trues
        }*/
        
        if object.featured == 1 {
            self.featured.isHidden = false
        }else {
            self.featured.isHidden = true
        }
        
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 18, height: 18), textColor: UIColor.gray)
               
        if Utils.isRTL(){
            self.address.setRightIcon(image: icon)
        }else{
            self.address.setLeftIcon(image: icon)
        }
        
        
        
        self.category.text = object.category_name
        
        if object.category_color != ""{
            self.category.backgroundColor = Utils.hexStringToUIColor(hex: object.category_color)
        }else{
            self.category.backgroundColor = Colors.primaryColor
        }
        
       
        
    }
    
    
    let ratingView: CosmosView = {
        
        
       
        let cosmosView = CosmosView()
        
        cosmosView.rating = 1
        cosmosView.settings.totalStars = 1
        
        // Change the text
        cosmosView.text = " 0 (0)"
        cosmosView.settings.textColor = Colors.white
        cosmosView.settings.updateOnTouch = false
        
        if let font = UIFont(name: AppConfig.Design.Fonts.bold, size: 14) {
             cosmosView.settings.textFont = font
        }
       
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        cosmosView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        cosmosView.didTouchCosmos = { rating in }
        
        
        return cosmosView
    }()
    
    
  
      func makeAsDefault() {
         
        self.image.isSkeletonable = false
        self.title.isSkeletonable = false
        self.address.isSkeletonable = false
          
        self.image.hideSkeleton()
        self.title.hideSkeleton()
        self.address.hideSkeleton()
        
    
        self.ratingContainer.isHidden = false
        self.ratingContainer.isHidden = false
        self.category.isHidden = false
        self.lastOffer.isHidden = false
        
      }
      
      
      func makeAsLoader() {
        
        self.image.isSkeletonable = true
        self.title.isSkeletonable = true
        self.address.isSkeletonable = true
              
        self.image.showAnimatedSkeleton()
        self.title.showAnimatedGradientSkeleton()
        self.address.showAnimatedGradientSkeleton()
              
        self.featured.isHidden = true
        self.distance.isHidden = true
                
        self.ratingContainer.isHidden = true
        self.category.isHidden = true
        self.lastOffer.isHidden = true
          
      }

}
