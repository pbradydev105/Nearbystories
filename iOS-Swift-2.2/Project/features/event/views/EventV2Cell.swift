//
//  EventV2Cell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class EventV2Cell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var buttom_container: UIView!
    
    @IBOutlet weak var dateContianer: EXUIView!
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var eventDate_day: UILabel!
    @IBOutlet weak var eventDate_month: UILabel!
    
    @IBOutlet weak var upcomingLabel: EdgeLabel!
    
    
    @IBOutlet weak var participate: UIButton!
    @IBOutlet weak var unparticipate: UIButton!
    
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
        title.initBolodFont(size: 14)
       // eventDates.initItalicFont(size: 12)
        
        eventDate_day.initBolodFont()
        eventDate_month.initItalicFont()
        eventDate_day.textColor = .red
        dateContianer.backgroundColor = Colors.Appearance.white
        
            
        container.backgroundColor = Colors.Appearance.whiteGrey
        buttom_container.backgroundColor = Colors.Appearance.whiteGrey
            
        
        //setup participate buttons
        setupButtonParticipate()
        setupButtonUnparticipate()
        
        participate.isHidden = true
        unparticipate.isHidden = false
        
    }
    
    
    func makeAsDefault() {
        
        self.dateContianer.isSkeletonable = false
        self.image.isSkeletonable = false
        self.title.isSkeletonable = false
        
        self.dateContianer.hideSkeleton()
        self.image.hideSkeleton()
        self.title.hideSkeleton()
        self.address.hideSkeleton()
        
        
        self.featured.isHidden = false
        self.distance.isHidden = false
        self.eventDate_month.isHidden = false
        self.address.isHidden = false
        
        self.eventDate_day.isHidden = false
        self.eventDate_month.isHidden = false
        
        self.title.isHidden = false
        
    }
    
    
    func makeAsLoader() {
        
        self.dateContianer.isSkeletonable = true
        self.image.isSkeletonable = true
        self.title.isSkeletonable = true
        
    
        self.dateContianer.showAnimatedGradientSkeleton()
        self.image.showAnimatedGradientSkeleton()
        self.title.showAnimatedGradientSkeleton()
        self.address.showAnimatedGradientSkeleton()
        
        self.featured.isHidden = true
        self.distance.isHidden = true
        self.address.isHidden = true
        
        self.title.isHidden = true
        
        self.participate.isHidden = true
        self.unparticipate.isHidden = true
        
    }
    
    func setupButtonParticipate() {
        
        var paticipateIcon = UIImage.init(icon: .googleMaterialDesign(.event), size: CGSize(width: 20, height: 20), textColor: .white)
        paticipateIcon = paticipateIcon.withRenderingMode(.alwaysOriginal)
        
        participate.backgroundColor =  Colors.Appearance.primaryColor
        participate.setImage(paticipateIcon, for: .normal)
        participate.roundCorners(radius: 40/2)
 
        
    }
    
    func setupButtonUnparticipate() {
        
        var unpaticipateIcon = UIImage.init(icon: .googleMaterialDesign(.eventAvailable), size: CGSize(width: 20, height: 20), textColor: .white)
        unpaticipateIcon = unpaticipateIcon.withRenderingMode(.alwaysOriginal)
        
        unparticipate.backgroundColor = Colors.lightGreen
        unparticipate.setImage(unpaticipateIcon, for: .normal)
        unparticipate.roundCorners(radius: 40/2)
     
    }
    
    
    
    
    func setup(object: Event)  {
        
        
        if object.id == 0{
            makeAsLoader()
            return
        }
        
        makeAsDefault()
        
        self.title.text = object.name
        
       
        
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
        

        self.address.text = object.address
        let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 20, height: 20), textColor: Colors.Appearance.primaryColor)
        self.address.setLeftIcon(image: icon)
        

        let month = DateUtils._UTC(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "MMM")
         let day = DateUtils._UTC(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "dd")
       
        eventDate_day.text = day
        eventDate_month.text = month
       
        
        if DateUtils.isLessThan24(dateUTC: object.dateBegin){
            upcomingLabel.isHidden = false
        }else{
            upcomingLabel.isHidden = true
        }
        
    
        self.featured.text = ""
        self.featured.setIcon(icon: .linearIcons(.pushpin), iconSize: 18, color: .white, bgColor: Colors.featuredTagColor)
             
        if object.joined{
            self.unparticipate.isHidden = false
            self.participate.isHidden = true
        }else{
            self.unparticipate.isHidden = true
            self.participate.isHidden = false
        }
        
    
    }
    
}
