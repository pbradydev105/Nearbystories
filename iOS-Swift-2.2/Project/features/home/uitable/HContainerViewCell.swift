//
//  HContainerViewCell.swift
//  NearbyStores
//
//  Created by Amine  on 8/19/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit

class HContainerViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    @IBOutlet weak var container: UIView!
    


    var style: CardHorizontalStyle?

    func setup(style: CardHorizontalStyle) {
        
        guard let _style = style.type else {
            return
        }
        
       
        var instance: UIView? = nil
        switch _style {
        case .Nearby_Stores:
            instance = Stores_HCards.newInstance(style: style)
            break
        case .Recent_Offers:
            instance = Offers_HCards.newInstance(style: style)
            break
        case .TopCategories:
            instance = Categories_HCards.newInstance(style: style)
            break
        case .Nearby_Events:
            instance = Events_HCards.newInstance(style: style)
            break
        case .Nearby_Users:
            instance = Users_HCards.newInstance(style: style)
            break
        default:
            instance = Stores_HCards.newInstance(style: style)
            break
            
            
        }
        
        if let view = instance{
            
            addSubview(view)
           
            addConstraintsWithFormat(format: "H:|[v0]|", views: view)
            addConstraintsWithFormat(format: "V:|[v0]|", views: view)
            
            self.layoutIfNeeded()
        }
        
        
    }
    
  
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


enum CardHorizontalViewTypes {
    case Nearby_Stores, Top_Nearby_Stores, Nearby_Offers, Nearby_Events,Nearby_Users,Recent_Reviews, Recent_Stores, Recent_Offers,
    Recent_Events,TopCategories, FeaturedStores,FeaturedOffers,FeaturedEvents,SponsoredBanners, StoreGalley
}

enum CardHorizontalViewSizes {
    static let Small:[Float] = [300,320]
    static let Medium:[Float] = [300,320]
     static let Large:[Float] = [300,320]
     static let Xlarge:[Float] = [300,320]
    static let Xxlarge:[Float] = [300,320]
}


enum CardViewTypes {
    case VerticalMode ,HorizontalMode
}

class CardStyle {
    let mode: CardViewTypes?
    init(mode: CardViewTypes) {
        self.mode = mode
    }
}

class CardHorizontalStyle: CardStyle {
    
    var Title: String?
    var width: Float?
    var height: Float?
    var enabled: Bool?
    
    var type: CardHorizontalViewTypes?
    
    init(size: [Float], type: CardHorizontalViewTypes) {
        super.init(mode: .HorizontalMode)
        self.width = size[0]
        self.height = size[1]
        self.type = type
    }
    
    init(size: [Float], enabled: Bool) {
        super.init(mode: .HorizontalMode)
        self.width = size[0]
        self.height = size[1]
        self.enabled = enabled
    }
    
    init(width: Float, height: Float, enabled: Bool) {
        super.init(mode: .HorizontalMode)
        self.width = width
        self.height = height
        self.enabled = enabled
    }
    
    init(width: Float, height: Float, enabled: Bool, type: CardHorizontalViewTypes) {
        super.init(mode: .VerticalMode)
        self.width = width
        self.height = height
        self.enabled = enabled
        self.type = type
    }
    
    init(width: Float, height: Float, type: CardHorizontalViewTypes,title:String) {
        super.init(mode: .VerticalMode)
        self.width = width.adaptScreen()
        self.height = height.adaptScreen()
        self.Title = title
        self.type = type
    }
    
    init(width: Float, height: Float, type: CardHorizontalViewTypes) {
        super.init(mode: .VerticalMode)
        self.width = width.adaptScreen()
        self.height = height.adaptScreen()
        self.type = type
    }
    
    init(allSize: Float, type: CardHorizontalViewTypes) {
        super.init(mode: .VerticalMode)
        self.width = allSize
        self.height = allSize
        self.type = type
    }
    
    
}
