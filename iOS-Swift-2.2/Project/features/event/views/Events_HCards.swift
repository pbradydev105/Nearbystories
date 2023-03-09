//
//  Events_HCards.swift
//  NearbyEvents
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit

class Events_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, EventLoaderDelegate{
    
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
                   ms.current_module = AppConfig.Tabs.Tags.TAG_EVENTS
                         
                   
                   
        var parameters = [
            "__req_search": "",
            "__req_category": "0",
            "__req_redius": String(AppConfig.distanceMaxValue),
        ]
        
        if let _style = self.style, _style.type == CardHorizontalViewTypes.Nearby_Events{
                       
            ms.config.custom_title = "Nearby Events".localized
            ms.request = ListEventCell.EventsListRequestOrder.nearby
            parameters["__req_list_order"] = ListEventCell.EventsListRequestOrder.nearby
                        
        }else if let _style = self.style, _style.type == CardHorizontalViewTypes.FeaturedEvents{
                       
            ms.config.custom_title = "Featured Events".localized
            ms.request = ListEventCell.EventsListRequestOrder.featured
            parameters["__req_list_order"] = ListStoresCell.StoresListRequestOrder.featured
                       
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
        let mEvents_HCards = instanceFromNib(name: "Events_HCards") as! Events_HCards
        
        mEvents_HCards.style = style
        mEvents_HCards.setup()
        
        mEvents_HCards.h_header.backgroundColor = .clear
       
        return mEvents_HCards
        
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
    var LIST: [Event] = [Event]()
    
    
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
        h_collection.register(UINib(nibName: "EventCardCell", bundle: nil), forCellWithReuseIdentifier: "offerCardCellId")
        
        h_collection.isScrollEnabled = true
        
        h_showAll.isHidden = true
        
        self.load()
        //self.test()
    }
    
    func test() {
        
        _ = Event()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: EventCardCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "offerCardCellId", for: indexPath) as! EventCardCell
        
        cell.setting(style: style!)
        
        let object = LIST[indexPath.row]
        
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
    
    
    
    
    static let header_size = Float(50)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let style = self.style, let height = style.height, let width = style.width{
            //add 60 for store information
            
            let calculated_height = height-Events_HCards.header_size
            
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let event = self.LIST[indexPath.row]
        let event_id = event.id
    
        event.save()
        
       
        let sb = UIStoryboard(name: "EventDetailV2", bundle: nil)
                   let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController
                   
                   ms.event_id = event_id
                   
                   ms.config.customToolbar = true
                   ms.config.backHome = true
                   
                   if let controller = self.viewController{
                       controller.present(ms, animated: true)
                   }else if let controller = self.viewNavigationController{
                       controller.pushViewController(ms, animated: true)
                   }else if let controller = self.viewTabBarController{
                       controller.navigationController?.pushViewController(ms, animated: true)
                   }
        
     
        
    }
    
    //API
    
    var offerLoader: EventLoader = EventLoader()
    
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
         
        
         if(style?.type == CardHorizontalViewTypes.FeaturedEvents){
             parameters["order_by"] = String(ListEventCell.EventsListRequestOrder.nearby)
             parameters["is_featured"] = String(1)
         }else if(style?.type == CardHorizontalViewTypes.Recent_Events){
             parameters["order_by"] = String(ListEventCell.EventsListRequestOrder.recent)
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
        
 
        self.offerLoader.load(url: Constances.Api.API_USER_GET_EVENTS,parameters: parameters)
        
        
    }
    
    
    func success(parser: EventParser,response: String) {
        
        Utils.printDebug("We loaded \(response)")
                     
        make_as_result()
    
        if parser.success == 1 {
            
            
            let events = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if(GLOBAL_COUNT>6){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn()
                }
            }
            
            if events.count > 0 {
                
                Utils.printDebug("We loaded \(events.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = events
                }else{
                    self.LIST += events
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
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListEvents")
                Utils.printDebug("\(errors)")
                
        
                
            }
            
        }
        
    }
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.h_collection.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        
        
        Utils.printDebug("===> Request Error! ListEvents")
        Utils.printDebug("\(response)")
        
    }
    
    
    
}


extension Events_HCards{
    
    func make_as_loader(){
       
        self.LIST = []
        
        let object = Event()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = false
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = true
    }
    
}
