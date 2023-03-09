//
//  HContainerViewCell.swift
//  NearbyStores
//
//  Created by Amine  on 8/19/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit

class HContainerCollectionCell: UICollectionViewCell {
    
    var isInitialized = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        backgroundColor = .clear
       
    }
    
    @IBOutlet weak var container: UIView!
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    
    
    var style: CardHorizontalStyle?
    
    func load(){
       
        
        
    }
    
    var instance: UIView? = nil
    
    func setup(style: CardHorizontalStyle) {
        
        guard let _style = style.type else {
            return
        }
        
        
        var instance: UIView? = nil
        switch _style {
        case .Nearby_Stores:
            instance = Stores_HCards.newInstance(style: style)
            (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_STORES.localized
            (instance as! Stores_HCards).viewNavigationController = viewNavigationController!
            break
        case .FeaturedStores:
            instance = Stores_HCards.newInstance(style: style)
            (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_FEATURED_STORES.localized
             (instance as! Stores_HCards).viewNavigationController = viewNavigationController!
            
            break
        case .Recent_Offers:
            
            instance = Offers_HCards.newInstance(style: style)
            (instance as! Offers_HCards).h_label.text = AppConfig.CardTags.TAG_RECENT_OFFERS.localized
            (instance as! Offers_HCards).viewNavigationController = viewNavigationController!
            
            break
        case .TopCategories:
            instance = Categories_HCards.newInstance(style: style)
            (instance as! Categories_HCards).h_label.text = AppConfig.CardTags.TAG_TOP_CATEGORIES.localized
            (instance as! Categories_HCards).viewNavigationController = viewNavigationController!
            
            break
        case .Nearby_Events:
            instance = Events_HCards.newInstance(style: style)
            (instance as! Events_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_EVENTS.localized
            (instance as! Events_HCards).viewNavigationController = viewNavigationController!
            
            break
        case .Nearby_Users:
            instance = Users_HCards.newInstance(style: style)
            (instance as! Users_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_USERS.localized
            (instance as! Users_HCards).viewNavigationController = viewNavigationController!
            
            break
        case .SponsoredBanners:
            instance = Banners_HCards.newInstance(style: style)
            (instance as! Banners_HCards).h_label.text = AppConfig.CardTags.TAG_SPONSORED_BANNERS.localized
            (instance as! Banners_HCards).viewNavigationController = viewNavigationController!
            break
        default:
            instance = Stores_HCards.newInstance(style: style)
            (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_STORES.localized
            (instance as! Stores_HCards).viewNavigationController = viewNavigationController!
            
            break
 
        }
 
        if let view = instance{
            
            self.instance = view
            
            addSubview(view)
            
            addConstraintsWithFormat(format: "H:|[v0]|", views: view)
            addConstraintsWithFormat(format: "V:|[v0]|", views: view)
            
            self.layoutIfNeeded()
        }
        
        isInitialized = true
        
    }
    
    

  
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

