//
//  NSimple_SliderCell.swift
//  NearbyStores
//
//  Created by Amine  on 10/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

protocol NSimple_Slider_Delegate {
    func onPressed(object: Banner)
}

class NSimple_SliderCell: UICollectionViewCell {
    
    var delegate: NSimple_Slider_Delegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    
    func setting() {
        
        title_label.initBolodFont(size: 16)
        description_label.initItalicFont(size: 12)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        if let banner = self.banner{
            if let del = delegate{
                del.onPressed(object: banner)
            }
        }
    }
    
    var banner: Banner? = nil
     
    func setup(banner: Banner){
       
        self.banner = banner
        
        setting()
        
        title_label.text = banner.title
        description_label.text = banner.detail
        
        //set image
        if let image = banner.images {
                       
            let url = URL(string: image.url500_500)
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                       
        }else{
                       
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
    }
    
    
    
      func makeAsDefault() {
        
        self.image.hideSkeleton()
          
        self.image.isSkeletonable = false
        self.title_label.isHidden = true
        self.description_label.isHidden = true
        
      }
      
      func makeAsLoader() {
          
        self.image.isSkeletonable = false
        self.title_label.isHidden = true
        self.description_label.isHidden = true
         
        self.image.showAnimatedGradientSkeleton()
          
      }

}
