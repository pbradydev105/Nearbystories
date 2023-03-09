//
//  Stores_HCards.swift
//  NearbyStores
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit
import SwiftIcons


class Stores_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, StoreLoaderDelegate{
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    @IBOutlet weak var h_header: UIView!
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_collection: UICollectionView!
    @IBOutlet weak var h_showAll: UIButton!
    
    @IBAction func showAllAction(_ sender: Any) {
        
        if let _ = self.style{
            
            showMoreStores()
          
        }
        
    }
    
    
    func showMoreStores() {
        
        let sb = UIStoryboard(name: "ResultList", bundle: nil)
        let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
        
        
        ms.current_module = AppConfig.Tabs.Tags.TAG_STORES
        
        
      
        ms.config.backHome = true
        ms.config.customToolbar = true
                   
 
        var parameters = [
            "__req_search": "",
            "__req_category": "0",
            "__req_redius": String(AppConfig.distanceMaxValue),
            "__req_opening_time": "0",
        ]
        
        if let _style = style, _style.type == CardHorizontalViewTypes.Nearby_Stores{
            
            ms.config.custom_title = "Nearby Stores".localized
            ms.request = ListStoresCell.StoresListRequestOrder.nearby
            parameters["__req_list_order"] = ListStoresCell.StoresListRequestOrder.nearby
            
             
        }else if let _style = style, _style.type == CardHorizontalViewTypes.FeaturedStores{
            
            ms.config.custom_title = "Featured Stores".localized
            ms.request = ListStoresCell.StoresListRequestOrder.featured
            parameters["__req_list_order"] = ListStoresCell.StoresListRequestOrder.featured
            
        }else if let _style = style, _style.type == CardHorizontalViewTypes.Top_Nearby_Stores{
            
            ms.config.custom_title = "Top Rated".localized
            ms.request = ListStoresCell.StoresListRequestOrder.nearby_top_rated
            parameters["__req_list_order"] = ListStoresCell.StoresListRequestOrder.nearby_top_rated
            
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
        let mStores_HCards = instanceFromNib(name: "Stores_HCards") as! Stores_HCards
        
        mStores_HCards.style = style
        mStores_HCards.setup(style: style)
    
        mStores_HCards.h_header.backgroundColor = .clear
        
        return mStores_HCards
        
    }
    
    
    
    //request
    var __req_loc_latitude: Double = 0.0
    var __req_loc_longitude: Double = 0.0
    
    var __req_list_order: String = ListStoresCell.StoresListRequestOrder.nearby
    
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list: String = ListStoresCell.StoresListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Store] = [Store]()
    
    
    let padding_size = CGFloat(20)
    
    
    func setup(){
        setup(style: nil)
    }
    
    func setup(style: CardHorizontalStyle?){
        
        self.backgroundColor = .clear
        
        self.h_label.leftTextInset = padding_size
        self.h_label.rightTextInset = padding_size
        self.h_label.initBolodFont(size: 18)
        
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
        h_collection.register(UINib(nibName: "StoreCardCell", bundle: nil), forCellWithReuseIdentifier: "storeCardCellId")
        
        h_collection.isScrollEnabled = true
        
        h_showAll.isHidden = true
        
    
        self.load()
        
        
       
     }
    
    func test() {
        
        
        let store = Store()
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
        self.LIST.append(store)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: StoreCardCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCardCellId", for: indexPath) as! StoreCardCell
        
        let object = LIST[indexPath.row]
        
        cell.setting(style: style!)
        
        if(object.id > 0){
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
            
            let calculated_height = height-Stores_HCards.header_size
            
            let ratio = Float(height/calculated_height)
            let calculated_width = Float(width/ratio)
            
            return CGSize(width: CGFloat(calculated_width-70),height: CGFloat(calculated_height))
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
        
        let store = self.LIST[indexPath.row]
        store.save()
        
        
        if AppConfig.Design.contentStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Content.contentStore.V2{
            
            let sb = UIStoryboard(name: "StoreDetailV2", bundle: nil)
            
            let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
            ms.storeId = store.id
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            if let controller = self.viewController {
                controller.present(ms, animated: true)
            }else if let controller = self.viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }else if let controller = self.viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }
            
        }
        
    }
    

    
    //API
    
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "6"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            if __req_redius > 0 && __req_redius < 100 {
                parameters["radius"] = String( (__req_redius*1000) ) //radius by merters
            }
            
            //            if let user = myUserSession {
            //               parameters["user_id"] = String(user.id)
            //            }
            
            parameters["category_id"] = String(__req_category)
            parameters["page"] = String(__req_page)
            parameters["search"] = String(__req_search)
            
            
            parameters["current_date"] = String(__req_current_date)
            parameters["current_tz"] = String(__req_default_tz)
            parameters["opening_time"] = String(__req_opening_time)
            
            
            
            if(style?.type == CardHorizontalViewTypes.Top_Nearby_Stores){
                parameters["order_by"] = String(ListStoresCell.StoresListRequestOrder.nearby_top_rated)
            }else if(style?.type == CardHorizontalViewTypes.FeaturedStores){
                parameters["order_by"] = String(ListStoresCell.StoresListRequestOrder.nearby)
                parameters["is_featured"] = String(1)
            }else if(style?.type == CardHorizontalViewTypes.Recent_Stores){
                parameters["order_by"] = String(ListStoresCell.StoresListRequestOrder.recent)
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
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.make_as_loader()
        
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
    }
    
    
    func success(parser: StoreParser,response: String) {
        
        self.make_as_result()
        
        if parser.success == 1 {
            
            
            let stores = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if(GLOBAL_COUNT>3){
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn()
                }
               
            }
            
            if stores.count > 0 {
                
                Utils.printDebug("We loaded \(stores.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = stores
                }else{
                    self.LIST += stores
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
                    //show emty layout
                   
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                   
                    Utils.printDebug("===> Is Empty!")
                }
                
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListStores")
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
        

        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
        
    }
    
    
    
}

extension UIButton{
    func setupShowMore() {
        self.initItalicFont()
        
        if(Utils.isRTL()){
            self.setIcon(prefixText: "\("Show all".localized) ", prefixTextColor: .red, icon: .googleMaterialDesign(.arrowBack), iconColor: Colors.Appearance.primaryColor, postfixText: "", postfixTextColor: .black, forState: .normal, textSize: 15, iconSize: 12)
        }else{
            self.setIcon(prefixText: "\("Show all".localized) ", prefixTextColor: .red, icon: .googleMaterialDesign(.arrowForward), iconColor: Colors.Appearance.primaryColor, postfixText: "", postfixTextColor: .black, forState: .normal, textSize: 15, iconSize: 12)
        }
        
    }
}
