//
//  StoreDetailCardView.swift
//  NearbyStores
//
//  Created by Amine  on 9/5/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import Cosmos


protocol StoreDetailCardDelegate {
    func onLoaded(store: Store)
}

class StoreDetailCardView: UIView, StoreLoaderDelegate {
    
    
    var delegate: StoreDetailCardDelegate? = nil
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    

    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!

    //contraints
    @IBOutlet weak var imageConstraintHeight: NSLayoutConstraint!
    
    //view
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var category: EdgeLabel!
    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(store_id: Int) {
        
        setupSettings()
        
        self.__req_default_tz = TimeZone.current.abbreviation()!
        self.__req_current_date = DateUtils.getCurrent(format: DateFomats.simpleDateFormat)
        self.__req_opening_time = 0
        self.__request_id =  store_id
        
        load()
        
    }
    
    
    func setup(object: Store?) {
        
        setupSettings()
      
        guard let _object = object else {
            return
        }
        
        
        self.name.text = _object.name
        self.address.text = _object.address
        
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        // localize to your grouping and decimal separator
        formatter.locale = Locale.current
        
        let number = NSNumber(value: _object.votes)
        
        
        if let value = formatter.string(from: number){
            self.ratingView.text = "\(value) (\(_object.nbr_votes)) "
        }else{
            self.ratingView.text = "\(_object.votes) (\(_object.nbr_votes)) "
        }
        
        if _object.votes==0{
            self.ratingView.rating = 0
        }else{
            self.ratingView.rating = _object.votes
        }
        
        
        
        //set image
        
        if _object.listImages.count > 0 {
            
            
            if let first = _object.listImages.first {
                
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
        
        
       
        self.category.text = _object.category_name
        self.category.backgroundColor = Utils.hexStringToUIColor(hex: _object.category_color)
        
        
        // self.makeAsLoader()
        
    }
    
    
    let ratingView: CosmosView = {
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = "4.8"
        cosmosView.settings.textColor = Colors.Appearance.black
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.totalStars = 1
        cosmosView.settings.starSize = 18
        
        if let font = UIFont(name: AppConfig.Design.Fonts.bold, size: 10) {
            cosmosView.settings.textFont = font
        }
        
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        cosmosView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        cosmosView.didTouchCosmos = { rating in }
        
        
        return cosmosView
    }()
    
    let ratingsLabel: EdgeLabel = {
        let label = EdgeLabel()
        label.textColor = .gray
        label.text = "  (30 reviews)"
        label.initDefaultFont(size: 10)
        return label
    }()
    
    
    
    
   
    
    func setupSettings()  {
       
    
      
        self.image.contentMode = .scaleAspectFill
        self.imageContainer.layer.cornerRadius = 30/UIScreen.main.nativeScale
        self.imageContainer.layer.masksToBounds = true
        
        self.image.roundCorners(radius: 25/UIScreen.main.nativeScale)
        self.imageContainer.roundedCorners(radius: 25)
        
        
        self.address.initDefaultFont(size: 12)
        self.address.textColor = .gray
        
        self.name.initDefaultFont(size: 14)
        //self.name.textColor = .black
        
        
        self.category.layer.cornerRadius = self.category.frame.height/3
        self.category.layer.masksToBounds = true
        self.category.backgroundColor = .orange
        self.category.leftTextInset = 8
        self.category.rightTextInset = 8
        
        //text color & font
        self.category.textColor = .white
        self.category.textAlignment = .center
        self.category.initBolodFont(size: 12)
        
        
        //setup rating view
        ratingContainer.addSubview(ratingView)
        ratingContainer.addSubview(ratingsLabel)
        
        
        //if it is RTL
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor).isActive = true
        
        
        if Utils.isRTL(){
            
            ratingContainer.addConstraints([
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .top,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .top,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .bottom,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .bottom,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .right,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: ratingContainer,
                    attribute: .right,
                    multiplier: 1, constant: 0),
                ])
            
        }
        
        
        //ratingsLabel const
        ratingsLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingContainer.addConstraints([
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingContainer,
                attribute: .top,
                multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .bottom,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingContainer,
                attribute: .bottom,
                multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .leading,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingView,
                attribute: .trailing,
                multiplier: 1, constant: 2),
            NSLayoutConstraint(
                item: ratingsLabel,
                attribute: .centerY,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: ratingView,
                attribute: .centerY,
                multiplier: 1, constant: 0),
            ])
        
        
        
    }

    
    
    //API
    
    var __request_id = 0
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0

    
    
    
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        
        self.__req_default_tz = TimeZone.current.abbreviation()!
        self.__req_current_date = DateUtils.getCurrent(format: DateFomats.simpleDateFormat)
        self.__req_opening_time = 0
        
        
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
           
            parameters["current_date"] = String(__req_current_date)
            parameters["current_tz"] = String(__req_default_tz)
            parameters["opening_time"] = String(__req_opening_time)
            
            parameters["store_id"] = String(__request_id)
            
        }
        

        
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
    }
    
    
    //RESULT
   
    func success(parser: StoreParser,response: String) {
        
        if parser.success == 1 {
            
            
            let stores = parser.parse()
            
          
            
            if stores.count > 0 {
                
               setup(object: stores[0])
                
                if let del = self.delegate{
                    del.onLoaded(store: stores[0])
                }
                
            }else{
                
              
                
            }
            
        }else {
            
            if parser.errors != nil {
                
               
            }
            
        }
        
    }
    
   
    
    func error(error: Error?,response: String) {
        
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
        
    }


    

}
