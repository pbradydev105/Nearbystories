//
//  Store2Cell.swift
//  NearbyStores
//
//  Created by Amine on 10/26/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SkeletonView
import CoreLocation

class StoreV2Cell: UICollectionViewCell {


    //Outlets
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockInfoConstraint: NSLayoutConstraint!
    

     @IBOutlet weak var imageContainer: UIView!
    
    
    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var sale: EdgeLabel!
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var category: EdgeLabel!


    @IBOutlet weak var ratingContainer: UIView!


  
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted{
               
              
                
                UIView.animate(withDuration: 0.1) {
                    self.layoutIfNeeded()
                }
                
            }else{
            
              
                
                UIView.animate(withDuration: 0.1) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    override var isSelected: Bool{
        didSet {
            if isSelected{
              
            }else{
                
            }
        }
    }
    
    let spacing = CGFloat(20)

    func setupSettings()  {
        
        
        self.mainViewLeftConstraint.constant = 0
        self.mainViewRightConstraint.constant = 0
        
        self.mainViewTopConstraint.constant = 0
        self.mainViewBottomConstraint.constant = 0

        self.imageHeightConstraint.constant = self.frame.height
        self.imageWidthConstraint.constant = self.frame.height
        self.blockInfoConstraint.constant = self.frame.height/1.5
        
        

        ratingContainer.backgroundColor = UIColor.white
        ratingView.backgroundColor = UIColor.white
        
        
        self.container.roundCorners(radius: 25/UIScreen.main.nativeScale)

        
        //offers tag
        self.sale.leftTextInset = 8
        self.sale.rightTextInset = 8
        self.sale.topTextInset = 4
        self.sale.bottomTextInset = 4
        self.sale.backgroundColor = Colors.Appearance.primaryColor
        self.sale.initDefaultFont(size: 14)
        self.sale.textColor = .white
        self.sale.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        self.distance.leftTextInset = 8
        self.distance.rightTextInset = 8
        self.distance.topTextInset = 4
        self.distance.bottomTextInset = 4
        self.distance.backgroundColor = Colors.Appearance.primaryColor
        self.distance.initDefaultFont(size: 12)
        self.distance.textColor = .white
        self.distance.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        
        self.featured.leftTextInset = 8
        self.featured.rightTextInset = 8
        self.featured.topTextInset = 4
        self.featured.bottomTextInset = 4
        self.featured.backgroundColor = Colors.featuredTagColor
        self.featured.initDefaultFont(size: 12)
        self.featured.textColor = .white
        self.featured.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.featured.text = "Featured".localized
        
        self.image.contentMode = .scaleAspectFill
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
        
        self.image.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.imageContainer.roundedCorners(radius: 25)
       
        
        self.address.initDefaultFont(size: 12)
        self.address.textColor = .gray
        
        self.title.initDefaultFont(size: 14)
        self.title.textColor = .black
        
        
        self.category.layer.cornerRadius = self.category.frame.height/3
        self.category.layer.masksToBounds = true
        self.category.backgroundColor = .orange
        self.category.leftTextInset = 8
        self.category.rightTextInset = 8
        
        //text color & font
        self.category.textColor = .white
        self.category.textAlignment = .center
        self.category.initBolodFont(size: 12)
        
        
        //setup rating view
        ratingContainer.addSubview(ratingView)
        ratingContainer.addSubview(ratingsLabel)
        
        
        //if it is RTL
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor).isActive = true
        
        
        if Utils.isRTL(){
            
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
        
       
        //ratingsLabel const
        ratingsLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingContainer.addConstraints([
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingContainer,
                attribute: .top,
                multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .bottom,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingContainer,
                attribute: .bottom,
                multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .leading,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingView,
                attribute: .trailing,
                multiplier: 1, constant: 2),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .centerY,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingView,
                attribute: .centerY,
                multiplier: 1, constant: 0),
            ])
        
      
        
        self.featured.text = ""
        self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
       
      
    }

   
    func setup(object: Store?)  {
        
        if let _object = object{
            
             makeAsDefault()
          
            
            self.title.text = _object.name
            self.address.text = _object.address


            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            // localize to your grouping and decimal separator
            formatter.locale = Locale.current

            let number = NSNumber(value: _object.votes)


            if let value = formatter.string(from: number){
                self.ratingView.text = "\(value) (\(_object.nbr_votes)) "
            }else{
                self.ratingView.text = "\(_object.votes) (\(_object.nbr_votes)) "
            }

            if _object.votes==0{
                self.ratingView.rating = 0
            }else{
                self.ratingView.rating = _object.votes
            }



            //set image

            if _object.listImages.count > 0 {


                if let first = _object.listImages.first {

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



            if _object.lastOffer != "" {
                self.sale.isHidden = false
                self.sale.text = _object.lastOffer
            }else{
                self.sale.isHidden = true
            }



            let distance = _object.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)


            if _object.featured == 1 {
                self.featured.isHidden = false
            }else {
                self.featured.isHidden = true
            }

            self.category.text = _object.category_name
            self.category.backgroundColor = Utils.hexStringToUIColor(hex: _object.category_color)
            
            
        }else{
            makeAsLoader()
        }
    }
    
    

  func makeAsDefault() {
      
      self.distance.isHidden = false
      self.featured.isHidden = false
      self.sale.isHidden = false
      self.ratingsLabel.isHidden = false
      self.address.isHidden = false
      self.ratingContainer.isHidden = false
      self.category.isHidden = false
          
      self.image.isSkeletonable = false
      self.title.isSkeletonable = false
          
      self.image.hideSkeleton()
      self.title.hideSkeleton()
      
  }
  
  func makeAsLoader() {
      
      
      self.distance.isHidden = true
      self.featured.isHidden = true
      self.sale.isHidden = true
      self.ratingsLabel.isHidden = true
      self.address.isHidden = true
      self.ratingContainer.isHidden = true
      self.category.isHidden = true
      
      self.image.isSkeletonable = true
      self.title.isSkeletonable = true
      
      self.image.showSkeleton()
      self.title.showAnimatedSkeleton()
      
      
  }


    let ratingView: CosmosView = {
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = "4.8"
        cosmosView.settings.textColor = Colors.Appearance.black
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.totalStars = 1
        cosmosView.settings.starSize = 18
        
        if let font = UIFont(name: AppConfig.Design.Fonts.bold, size: 10) {
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
    
    let ratingsLabel: EdgeLabel = {
        let label = EdgeLabel()
        label.textColor = .gray
        label.text = "  (30 reviews)"
        label.initDefaultFont(size: 10)
        return label
    }()
    
    

    

}


extension ListStoresCell{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Store()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.collectionView.reloadData()
        self.collectionView.isScrollEnabled = false
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.collectionView.reloadData()
        self.collectionView.isScrollEnabled = true
    }
    
}

