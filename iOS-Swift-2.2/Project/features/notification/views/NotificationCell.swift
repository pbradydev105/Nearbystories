//
//  NotificationCell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class NotificationCell: UICollectionViewCell {

    var optionLauncher: OptionsLauncher? = nil
    var object: Notification? = nil
    
    @IBAction func onOptionMore(_ sender: Any) {
        
        if let launcher = self.optionLauncher {
            
            launcher.clear()
            
            if let user = self.object  {
                
                /*launcher.addBottomMenuItem(option: Option(
                    id: 1,
                    name: "Turn off notifications".localized,
                    image: launcher.createIcon(.googleMaterialDesign(.notificationsOff)),
                    object: user.id
                ))*/
                
                launcher.addBottomMenuItem(option: Option(
                    id: 2,
                    name: "Remove notification".localized,
                    image: launcher.createIcon(.googleMaterialDesign(.delete)),
                    object: user.id
                ))
                
                
            }
            
            launcher.load()
            launcher.showOptions()
        }
        
    }
    
    
    func setOptionLauncher(optionsLauncher: OptionsLauncher) {
        self.optionLauncher = optionsLauncher
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var option: UIButton!
    
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.highlightedGray : Colors.Appearance.whiteGrey
        }
    }

    
    func setupSettings()  {
        

        
        date.backgroundColor = .clear
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
        
        
        message.initDefaultFont()
        name.initDefaultFont()
        
       
        option.setTitle("", for: .normal)
        option.setIcon(icon: .ionicons(.androidMoreVertical), iconSize: 24, color: .black, forState: .normal)
    
        self.backgroundColor = Colors.Appearance.whiteGrey
        
    }
    
    func setup(object: Notification)  {
        
        if(object.id == 0){
            makeAsLoader()
            return
        }else{
            makeAsDefault()
        }
        
        self.object = object

        self.name.text = object.label
        self.message.text = object.label_description
        
        
    
        let date = DateUtils.UTCToLocal(date: object.createdAt, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)
        self.date.text = date
    
        
       
        //set image
        if let image = object.images {
            
            let url = URL(string: image.url100_100)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.image.image = img
            }
        }
        
        
       
        if(AppStyle.isDarkModeEnabled){
            
            if object.status == 0{
                container.backgroundColor = Colors.Appearance.whiteGrey
            }else{
                container.backgroundColor = Colors.Appearance.white
            }
            
        }else{
            if object.status == 0{
                container.backgroundColor = Colors.Appearance.primaryColor.withAlphaComponent(0.1)
            }else{
                container.backgroundColor = Colors.Appearance.white
            }
        }
        
        
    }
    
    
    
    func makeAsDefault() {
              
        self.option.isHidden = false
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
              
        self.option.isHidden = true
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
