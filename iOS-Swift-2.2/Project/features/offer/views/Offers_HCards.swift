//
//  Offers_HCards.swift
//  NearbyOffers
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit


protocol Offers_HCards_Delegate {
    func onOffersLoaded(count: Int)
}

class Offers_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, OfferLoaderDelegate{
    
    
    var delegate: Offers_HCards_Delegate? = nil
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBOutlet weak var h_header: UIView!
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_collection: UICollectionView!
    @IBOutlet weak var h_showAll: UIButton!
    
    
    @IBAction func showAllAction(_ sender: Any) {
           
           let sb = UIStoryboard(name: "ResultList", bundle: nil)
                      let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
                      ms.current_module = AppConfig.Tabs.Tags.TAG_OFFERS
                      
           var parameters = [
               "__req_search": "",
               "__req_category": "0",
               "__req_redius": String(AppConfig.distanceMaxValue),
               "__req_store": String(__req_store),
           ]
           
           if let _style = self.style, _style.type == CardHorizontalViewTypes.Nearby_Offers{
                          
               ms.config.custom_title = "Nearby Offers".localized
               ms.request = ListOfferCell.OffersListRequestOrder.nearby
               parameters["__req_list_order"] = ListOfferCell.OffersListRequestOrder.nearby
                           
           }else if let _style = self.style, _style.type == CardHorizontalViewTypes.FeaturedEvents{
                          
               ms.config.custom_title = "Featured Offers".localized
               ms.request = ListOfferCell.OffersListRequestOrder.featured
               parameters["__req_list_order"] = ListOfferCell.OffersListRequestOrder.featured
                          
           }else if let _style = self.style, _style.type == CardHorizontalViewTypes.Recent_Events{
                          
               ms.config.custom_title = "Recent Offers".localized
               ms.request = ListOfferCell.OffersListRequestOrder.recent
               parameters["__req_list_order"] = ListOfferCell.OffersListRequestOrder.recent
                          
           }
           
           ms.parameters = parameters
           
           if let controller = self.viewController{
               controller.present(ms, animated: true)
           }else if let controller = self.viewNavigationController{
               controller.pushViewController(ms, animated: true)
           }else if let controller = self.viewTabBarController{
               controller.navigationController?.pushViewController(ms, animated: true)
           }
           
       }
    
    
    var style: CardHorizontalStyle?
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
    
    static func newInstance(style: CardHorizontalStyle) -> UIView{
        
        //load xib
        let mOffers_HCards = instanceFromNib(name: "Offers_HCards") as! Offers_HCards
        
        mOffers_HCards.style = style
        mOffers_HCards.setup()
        
        mOffers_HCards.h_header.backgroundColor = .clear
        
        return mOffers_HCards
        
    }
    
    
    enum Request {
        static let nearby = 0
        static let saved = -1
        static let recent = 1
    }
    
    //request
    var __req_loc_latitude: Double = 0.0
    var __req_loc_longitude: Double = 0.0
      
    var __req_list_order: String = ListEventCell.EventsListRequestOrder.nearby
      
      
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list: Int = Request.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    var __req_store: Int = 0
    
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Offer] = [Offer]()
    
    
    let padding_size = CGFloat(20)
    
    
    func setup(){
        
        
        self.backgroundColor = .clear
        
        self.h_label.leftTextInset = padding_size
        self.h_label.rightTextInset = padding_size
        self.h_label.initBolodFont(size: 18)
        
        
        self.h_showAll.initItalicFont()
        self.h_showAll.setTitleColor(.black, for: .normal)
        self.h_showAll.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        self.h_showAll.setupShowMore()
               
        
        if let flowLayout = h_collection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            layoutIfNeeded()
        }
        
        
        h_collection.contentInset = UIEdgeInsets(top: padding_size, left: padding_size, bottom: padding_size, right: padding_size)
        
         
        h_collection.dataSource = self
        h_collection.delegate = self
        h_collection.showsHorizontalScrollIndicator = false
        
        h_collection.backgroundColor = .clear
        h_collection.register(UINib(nibName: "OfferCardCell", bundle: nil), forCellWithReuseIdentifier: "offerCardCellId")
        
        h_collection.isScrollEnabled = true

        
        h_showAll.isHidden = true
        
        
    }
    
    func test() {
        
        let offer = Offer()
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        self.LIST.append(offer)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: OfferCardCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "offerCardCellId", for: indexPath) as! OfferCardCell
        
        let object = LIST[indexPath.row]
        
        cell.setting(style: style!)
        
        if object.id > 0{
             cell.setup(object: object)
        }else{
            
             cell.setup(object: nil)
            
            //start scrolling from the first item
            if Utils.isRTL(){
                h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
            }
            
        }
       
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let offer = self.LIST[indexPath.row]
        offer.save()
        
       
        let sb = UIStoryboard(name: "OfferDetailV2", bundle: nil)
        let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
        
        ms.offer_id = offer.id
        
        ms.config.backHome = true
        ms.config.customToolbar = true
        
        if let controller = self.viewController{
            controller.present(ms, animated: true)
        }else if let controller = self.viewNavigationController{
            controller.pushViewController(ms, animated: true)
        }else if let controller = self.viewTabBarController{
            controller.navigationController!.pushViewController(ms, animated: true)
        }
        
        
    }
    
   
    
    static let header_size = Float(50)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let style = self.style, let height = style.height, let width = style.width{
            //add 60 for store information
            
            let calculated_height = height-Offers_HCards.header_size
            
            let ratio = Float(height/calculated_height)
            let calculated_width = Float(width/ratio)
            
            return CGSize(width: CGFloat(calculated_width-50),height: CGFloat(calculated_height))
        }else{
            return CGSize(width: CGFloat(60) , height: CGFloat(60))
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(padding_size)
    }
    
    //API
    
    var offerLoader: OfferLoader = OfferLoader()
    
    func load () {
        
        
        make_as_loader()
        
        self.offerLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "6"
        ]
      
       if __req_redius > 0 && __req_redius < 100 {
           parameters["radius"] = String( (__req_redius*1000) ) //radius by merters
       }
       

       parameters["category_id"] = String(__req_category)
       parameters["page"] = String(__req_page)
       parameters["search"] = String(__req_search)
       parameters["date"] = String(__req_search)
       parameters["store_id"] = String(__req_store)
        
        
        if(style?.type == CardHorizontalViewTypes.FeaturedStores){
            parameters["order_by"] = String(ListOfferCell.OffersListRequestOrder.nearby)
            parameters["is_featured"] = String(1)
        }else if(style?.type == CardHorizontalViewTypes.Recent_Offers){
            parameters["order_by"] = String(ListOfferCell.OffersListRequestOrder.recent)
        }else{
            parameters["order_by"] = String(__req_list_order)
        }
                        
                              
        if(__req_loc_latitude != 0.0 && __req_loc_longitude != 0.0){
            parameters["latitude"] = String(__req_loc_latitude)
            parameters["longitude"] = String(__req_loc_longitude)
        }else  if let guest = Guest.getInstance() {
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
        }
        
        Utils.printDebug("\(parameters)")
 
        self.offerLoader.load(url: Constances.Api.API_GET_OFFERS,parameters: parameters)
        
    }
    
    
    func success(parser: OfferParser,response: String) {
        
        make_as_result()
    
        if parser.success == 1 {
            
            
            let offers = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if(GLOBAL_COUNT>6){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn()
                }
            }
            
            if offers.count > 0 {
                
                Utils.printDebug("We loaded \(offers.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = offers
                }else{
                    self.LIST += offers
                }
                
                self.h_collection.reloadData()
                
                //start scrolling from the first item
                if self.__req_page  == 1 && Utils.isRTL(){
                    h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
                }
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                   
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    
                    
                    Utils.printDebug("===> Is Empty!")
                }
                
                
            }
            
            
            if let del = delegate{
                delegate?.onOffersLoaded(count: self.LIST.count)
            }

            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListOffers")
                Utils.printDebug("\(errors)")
                
                
            }
            
            if let del = delegate{
                delegate?.onOffersLoaded(count: 0)
            }
            
        }
        
    }
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.h_collection.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        if let del = delegate{
            delegate?.onOffersLoaded(count: 0)
        }
        
        Utils.printDebug("===> Request Error! ListOffers")
        Utils.printDebug("\(response)")
        
    }
    
    
    
}

extension Offers_HCards{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Offer()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = false
        
        //start scrolling from the first item
               if Utils.isRTL(){
                   h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
               }
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = true
    }
    
}

