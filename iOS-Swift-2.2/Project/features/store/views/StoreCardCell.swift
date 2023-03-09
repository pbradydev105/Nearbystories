//
//  StoreCardCell.swift
//  NearbyStores
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SkeletonView

class StoreCardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet weak var infosConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var infosConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var infosConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var infosConstraintBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var infosContainer: UIView!
    
    //contraints
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var infoConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerConstraintWidth: NSLayoutConstraint!
    //view
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var category: EdgeLabel!
    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    
    
    @IBOutlet weak var sale: EdgeLabel!
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
   
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        
        
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
        self.name.isSkeletonable = false
            
        self.image.hideSkeleton()
        self.name.hideSkeleton()
        
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
        self.name.isSkeletonable = true
        
        self.image.showAnimatedGradientSkeleton()
        self.name.showAnimatedSkeleton()
        
        
    }
    
    func setting(){
       setting(style: nil)
    }
    
    func setting(style: CardHorizontalStyle?){
        
    
        if let style = style {
            self.imageConstraintHeight.constant = CGFloat(style.height!-70-Stores_HCards.header_size)
        }
        
        self.container.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.image.roundCorners(radius: 25/UIScreen.main.nativeScale)
            
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
        self.featured.initDefaultFont(size: 14)
        self.featured.textColor = .white
        self.featured.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.featured.text = "Featured".localized
        
    
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
    
        self.name.roundedCorners(radius: 10)
        
        self.address.initDefaultFont(size: 12)
        self.address.textColor = .gray
        
        
        self.name.initDefaultFont(size: 14)
        //self.name.textColor = .black
        
        
        self.category.layer.cornerRadius = self.category.frame.height/3
        self.category.layer.masksToBounds = true
        self.category.backgroundColor = .orange
        self.category.leftTextInset = 8
        self.category.rightTextInset = 8
        
        //text color & font
        self.category.textColor = .white
        self.category.textAlignment = .center
        self.category.initBolodFont(size: 10)
        
        
        //setup rating view
        ratingContainer.addSubview(ratingView)
        ratingContainer.addSubview(ratingsLabel)
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor).isActive = true
        
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
            ])
        
        
    
        
        
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
        label.text = "  (0)"
        label.initDefaultFont(size: 10)
        return label
    }()
    
    
    
    
    func setup(object: Store?) {
        
        //configure & setup
        
        if let object = object {
            
            makeAsDefault()
            
            
            self.name.text = object.name
            self.address.text = object.address
            
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            formatter.minimumIntegerDigits = 1
            
            let number = NSNumber(value: object.votes)
            
            
            if let value = formatter.string(from: number){
                self.ratingView.text = "\(value)"
            }else{
                self.ratingView.text = "\(object.votes)"
            }
            
            
            self.ratingsLabel.text = "("+object.nbr_votes+")"
            self.ratingView.rating = object.votes
            
            self.category.text = object.category_name
            self.category.backgroundColor = Utils.hexStringToUIColor(hex: object.category_color)
            
            
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
                sale.isHidden = false
                sale.text = object.lastOffer
            }else{
                sale.isHidden = true
            }
            
            
            
            let distance = object.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
            
            
            if object.featured == 1 {
                self.featured.isHidden = false
            }else {
                self.featured.isHidden = true
            }
            
            
            /*if object.opening == 1{
                self._openedTag.isHidden = false
                self._closedTag.isHidden = true
            }else if object.opening == -1 {
                self._openedTag.isHidden = true
                self._closedTag.isHidden = false
            }else{
                self._openedTag.isHidden = true
                self._closedTag.isHidden = true
            }*/

            
            self.featured.text = ""
            self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
                
            
        }else{

            self.makeAsLoader()
            
            
        }
        
        
      
        
        
    }

}

extension Stores_HCards{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Store()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = false
        
        //start scrolling from the first item
        if Utils.isRTL(){
            h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
        }
        
        layoutIfNeeded()
        layoutIfNeeded()
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = true
        
        layoutIfNeeded()
    }
    
}

