//
//  DiscussionCell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class DiscussionCell: UICollectionViewCell {

    
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var notification: EdgeLabel!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var gradienView: GradientBGView!
    
    
    override var isHighlighted: Bool {
        didSet {
           // backgroundColor = isHighlighted ? Colors.highlightedGray : UIColor.white
        }
    }

  
    func setupSettings()  {
        
      
        
        //distance tag
        notification.leftTextInset = 3
        notification.rightTextInset = 3
        notification.bottomTextInset = 3
        notification.topTextInset = 3
        notification.layer.masksToBounds = false
        notification.layer.cornerRadius = 5
        notification.clipsToBounds = true
        notification.initDefaultFont()
        
        
        
        
        date.layer.masksToBounds = false
        date.layer.cornerRadius = 5
        date.clipsToBounds = true
        date.initDefaultFont()
        
    
        image.contentMode = .scaleAspectFill
        
        image.layer.borderWidth = 2
        image.layer.masksToBounds = false
        image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        
        
        name.textColor = Colors.Appearance.black
        message.textColor = Colors.Appearance.black
        date.textColor = Colors.Appearance.black
        
        message.initDefaultFont()
        name.initDefaultFont()
        
        
        if Utils.isRTL(){
            
            message.textAlignment = .right
            
            let startColor = gradienView.startColor
            let endColor = gradienView.endColor
        
            gradienView.startColor = endColor
            gradienView.endColor = startColor
            
            gradienView.alpha = CGFloat(0.7)
            
        }
      
    
        if(AppStyle.isDarkModeEnabled){
    
            cover.isHidden = true
            date.backgroundColor = .clear
        }else{
            cover.isHidden = false
            date.backgroundColor = Colors.white
        }
        
              backgroundColor = Colors.Appearance.white
        
    }
    
    func setup(object: Discussion)  {
        
        
        if(object.id == 0){
                   makeAsLoader()
                   return
               }else{
                   makeAsDefault()
               }
               
        
        
        self.name.text = object.senderUser?.name
        
        let date = DateUtils.getPreparedDateDT(dateUTC: object.createdAt)
        self.date.text = date
        
        if object.nbrMessages > 0 {
            self.notification.isHidden = false
            self.notification.text = String(object.nbrMessages)
        }else{
            self.notification.isHidden = true
        }
        
        self.message.text = "Sent message".localized
        if object.messages.count > 0 {
            if let message = object.messages.first {
                  self.message.text = message.message
            }
        }
    
        //set image
        if let image = object.senderUser?.images {
            
            let url = URL(string: image.url100_100)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.image.image = img
            }
        }
        
        
    }
    
    
    
    func makeAsDefault() {
                 
         
        self.notification.isHidden = true
        self.image.isSkeletonable = false
        self.name.isSkeletonable = false
        self.message.isSkeletonable = false
        self.date.isSkeletonable = false
        
         self.image.hideSkeleton()
         self.name.hideSkeleton()
         self.message.hideSkeleton()
         self.date.hideSkeleton()
                  
     }
              
     func makeAsLoader() {
                  
         self.notification.isHidden = true
         self.image.isSkeletonable = true
         self.name.isSkeletonable = true
         self.message.isSkeletonable = true
         self.date.isSkeletonable = true
                 
         self.image.showAnimatedGradientSkeleton()
         self.name.showAnimatedGradientSkeleton()
         self.message.showAnimatedGradientSkeleton()
         self.date.showAnimatedGradientSkeleton()
                  
     }
     
}
