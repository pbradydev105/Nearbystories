//
//  GPhotoCardCell.swift
//  NearbyGallery
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos
import SkeletonView

class GPhotoCardCell: UICollectionViewCell {

  
    //view
    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
    }
    
    func makeAsDefault() {
        
        self.image.isSkeletonable = false
        self.image.hideSkeleton()
      
    }
    
    
    func makeAsLoader() {
        
    self.image.isSkeletonable = true
       self.image.showAnimatedGradientSkeleton()
        
    }
    
    func setting(style: CardHorizontalStyle){
        
        //self.imageConstraintHeight.constant = CGFloat(style.height!-50-Gallery_HCards.header_size)
        //self.infoConstraintHeight.constant = CGFloat(40)

        
    }
    
    
    func setup(object: Images?) {
        
        //configure & setup
        if object != nil {
            
            self.makeAsDefault()
            
          
        }else{
            
            self.makeAsLoader()
            
        }
        
    }

}
