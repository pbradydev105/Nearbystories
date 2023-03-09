//
//  EventCardCell.swift
//  NearbyEvents
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos

class EventCardCell: UICollectionViewCell {

    //contraints
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var infoConstraintHeight: NSLayoutConstraint!
    
    //view
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var distance: EdgeLabel!
    
    
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var dateContainer: UIView!
    
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
    
    func setting(style: CardHorizontalStyle){
        
        self.backgroundColor = .clear
        
        self.imageConstraintHeight.constant = CGFloat(style.height!-50-Events_HCards.header_size)
        //self.infoConstraintHeight.constant = CGFloat(60)
        
        
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
    
        
        self.detail.initDefaultFont(size: 12)
        self.detail.textColor = .gray
        
        
        self.name.initDefaultFont(size: 14)
        //self.name.textColor = .black

        
        self.distance.leftTextInset = 8
        self.distance.rightTextInset = 8
        self.distance.topTextInset = 4
        self.distance.bottomTextInset = 4
        self.distance.backgroundColor = Colors.Appearance.primaryColor
        self.distance.initDefaultFont(size: 12)
        self.distance.textColor = .white
        self.distance.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        
        self.distance.leftTextInset = 8
        self.distance.rightTextInset = 8
        self.distance.topTextInset = 4
        self.distance.bottomTextInset = 4
        self.distance.backgroundColor = Colors.Appearance.primaryColor
        self.distance.initDefaultFont(size: 14)
        self.distance.textColor = .white
        self.distance.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        
    
        self.dateContainer.roundCorners(radius: 25/UIScreen.main.nativeScale)
        
        self.day.initBolodFont()
        self.month.initItalicFont()
        self.day.textColor = .red
        self.dateContainer.backgroundColor = Colors.Appearance.white
        
        
        
    }
    
    func setup(object: Event?) {
       
        //configure & setup

        
        if let object = object {
            
            makeAsDefault()
            
            self.name.text = object.name
         
            
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
            
            
            
            let distance = object.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
            
            
          
            self.detail.text = object.address
            
            let _month = DateUtils._UTC(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "MMM")
            let _day = DateUtils._UTC(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "dd")
            
            
            self.month.text = _month
            self.day.text = _day
            
            
        }else{
            self.makeAsLoader()
        }
        
    }

}
