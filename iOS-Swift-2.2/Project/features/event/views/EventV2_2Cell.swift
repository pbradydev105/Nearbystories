//
//  EventV2Cell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class EventV2_2Cell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var titleConstraintRight: NSLayoutConstraint!
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var eventDates: UILabel!
    
    @IBOutlet weak var upcomingLabel: EdgeLabel!
    
    func setupSettings()  {
        
         self.addShadowView()
        
        //distance tag
        distance.leftTextInset = 15
        distance.rightTextInset = 15
        distance.bottomTextInset = 10
        distance.topTextInset = 10
        distance.backgroundColor = Colors.Appearance.primaryColor
        distance.initDefaultFont()
        distance.roundedCorners(radius: 25)
        
        
        featured.leftTextInset = 15
        featured.rightTextInset = 15
        featured.bottomTextInset = 10
        featured.topTextInset = 10
        featured.backgroundColor = Colors.featuredTagColor
        featured.text = "Featured".localized.uppercased()
        featured.initDefaultFont()
        featured.roundedCorners(radius: 25)
        
        
        upcomingLabel.leftTextInset = 10
        upcomingLabel.rightTextInset = 10
        upcomingLabel.bottomTextInset = 5
        upcomingLabel.topTextInset = 5
        upcomingLabel.backgroundColor = Colors.upComingColor
        upcomingLabel.text = "Upcoming".localized
        upcomingLabel.initDefaultFont()
        
        
        
        image.contentMode = .scaleAspectFill
        
        
        title.initDefaultFont()
        address.initDefaultFont()
        
        container.roundedCorners(radius: 25)
       // upcomingLabel.roundedCorners(radius: 25)
        
        
        upcomingLabel.initItalicFont(size: 14)
        title.initBolodFont(size: 16)
        eventDates.initItalicFont(size: 12)
        
        
        titleConstraintRight.constant = upcomingLabel.frame.width+20
       
    }
    
    
    func makeAsDefault() {
        
  
        self.image.isSkeletonable = false
        self.title.isSkeletonable = false
        self.address.isSkeletonable = false
        
        self.image.hideSkeleton()
        self.title.hideSkeleton()
        self.address.hideSkeleton()
        
        
        self.featured.isHidden = false
        self.distance.isHidden = false
        
        
    }
    
    
    func makeAsLoader() {
        
        self.image.isSkeletonable = true
        self.title.isSkeletonable = true
        self.address.isSkeletonable = true
        
        self.image.showGradientSkeleton()
        self.title.showAnimatedGradientSkeleton()
        self.address.showAnimatedGradientSkeleton()
        
        self.featured.isHidden = true
        self.distance.isHidden = true
        
    }
    
    
    
    func setup(object: Event)  {
        
        
        if object.id == 0{
            makeAsLoader()
            return
        }
        
        makeAsDefault()
        
        self.title.text = object.name
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.dateRange), size: CGSize(width: 20, height: 20), textColor: UIColor.white)
        self.address.setLeftIcon(image: icon)
        
        
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
        
        
        if object.featured == 1 {
            self.featured.isHidden = false
        }else {
            self.featured.isHidden = true
        }


        let begin_at = DateUtils._UTC(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)
        let end_at = DateUtils._UTC(date: object.dateEnd, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)


        self.eventDates.text = "\(begin_at) - \(end_at)"

        
        if DateUtils.isLessThan24(dateUTC: object.dateBegin){
            upcomingLabel.isHidden = false
        }else{
            upcomingLabel.isHidden = true
        }
        
    }
    
}
