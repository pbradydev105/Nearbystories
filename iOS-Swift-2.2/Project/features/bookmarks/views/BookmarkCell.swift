//
//  FavoriteCell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class BookmarkCell: UICollectionViewCell {

    var optionLauncher: OptionsLauncher? = nil
    var object: Bookmark? = nil
    
    @IBAction func onOptionMore(_ sender: Any) {
        
        if let launcher = self.optionLauncher {
            
            launcher.clear()
            
            if let user = self.object  {
              
                launcher.addBottomMenuItem(option: Option(
                    id: 2,
                    name: "Remove from bookmarks".localized,
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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var _description: UILabel!
    @IBOutlet weak var module: EdgeLabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var option: UIButton!
    
    
    override var isHighlighted: Bool {
        didSet {
           // backgroundColor = isHighlighted ? Colors.highlightedGray : Colors.Appearance.white
        }
    }

    
    func setupSettings()  {
        

        module.leftTextInset = 8
        module.rightTextInset = 8
        module.bottomTextInset = 3
        module.topTextInset = 3
        
        module.backgroundColor = .clear
        module.layer.masksToBounds = false
        module.layer.cornerRadius = 5
        module.clipsToBounds = true
        module.initDefaultFont()
        module.textColor = .white
        self.module.backgroundColor = Colors.Appearance.primaryColor.withAlphaComponent(0.8)
        
    
        image.contentMode = .scaleAspectFill
        
        image.layer.borderWidth = 0.5
        image.layer.masksToBounds = false
        image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        image.roundCorners(radius: 10)
        
        
        _description.initDefaultFont()
        title.initDefaultFont()
       
        option.setTitle("", for: .normal)
        option.setIcon(icon: .ionicons(.androidMoreVertical), iconSize: 24, color: .black, forState: .normal)
    
        self.backgroundColor = Colors.Appearance.whiteGrey
        
    }
    
    func setup(object: Bookmark)  {
        
        if(object.id == 0){
            makeAsLoader()
            return
        }else{
            makeAsDefault()
        }
        
        
        self.object = object

        self.title.text = object.label
        self._description.text = object.label_description
        

        self.module.text = object.module.localized.capitalizingFirstLetter()
        
        if(object.module == "store"){
            self.module.backgroundColor = Colors.Appearance.primaryColor.withAlphaComponent(0.8)
        }else if(object.module == "event"){
             self.module.backgroundColor = Colors.lightGreen.withAlphaComponent(0.8)
        }
        
    
    
       
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
        
    
        
    }
    
    
    func makeAsDefault() {
                
        self.module.isHidden = false
        self.option.isHidden = false
        self.image.isSkeletonable = false
        self.title.isSkeletonable = false
        self._description.isSkeletonable = false
        //self.date.isSkeletonable = false
                 
        self.image.hideSkeleton()
        self.title.hideSkeleton()
        self._description.hideSkeleton()
        //self.date.hideSkeleton()
                 
    }
             
    func makeAsLoader() {
                 
        self.module.isHidden = true
        self.option.isHidden = true
        self.image.isSkeletonable = true
        self.title.isSkeletonable = true
        self._description.isSkeletonable = true
        //self.date.isSkeletonable = true
                
        self.image.showAnimatedGradientSkeleton()
        self.title.showAnimatedGradientSkeleton()
        self._description.showAnimatedGradientSkeleton()
        //self.date.showAnimatedGradientSkeleton()
                 
    }
    
}
