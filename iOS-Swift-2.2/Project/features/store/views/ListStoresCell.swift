//
//  ListStoresCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit

class ListStoresCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , StoreLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
   
    //request
    var __req_loc_latitude: Double = 0.0
    var __req_loc_longitude: Double = 0.0
    
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = StoresListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1

    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0

 
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Store] = [Store]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "storeCellId"
  
    
    //instance for scrolling
    var isFetched = false
    
    
    let spacing_row = CGFloat(AppStyle.padding_size_item)
    
    
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
     
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
            cv.backgroundColor = Colors.Appearance.background
            if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = spacing_row
            }
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2_2{
            cv.backgroundColor = Colors.Appearance.background
            if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = spacing_row
            }
        }else{
            cv.backgroundColor = Colors.Appearance.background
            if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = 3
            }
        }
        
       
        
        cv.dataSource = self
        cv.delegate = self
        return cv
        
    }()
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    override func setupViews() {
        super.setupViews()
        
        collectionView.backgroundColor = Colors.Appearance.background

        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        
    
    }
    
    private let refreshControl = UIRefreshControl()
    
    
    func fetch(request: String) {
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        isFetched = true
        
       
        contentView.addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
            collectionView.register(UINib(nibName: "StoreV2Cell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2_2{
            collectionView.register(UINib(nibName: "StoreCardCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }else{
            collectionView.register(UINib(nibName: "StoreCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }
        
        
        self.__req_default_tz = TimeZone.current.abbreviation()!
        self.__req_current_date = DateUtils.getCurrent(format: DateFomats.defaultFormatUTC)
       
        Utils.printDebug("\(self.__req_default_tz) ---- \(self.__req_current_date)")
        
        
        //refreshControl.beginRefreshing()
        
        load()
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: self)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
       
    }
    
    
    
    @objc private func refreshData(_ sender: Any) {
        //Init params
        __req_page = 1
        
        // Fetch Data
        load()
    }
    
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            
            if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
                           
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCell
                           
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                           
                return cell
                           
            }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreV2Cell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                return cell
                
            }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2_2{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCardCell
                
                cell.setting()
                
                let object = LIST[indexPath.item]
                
                if object.id > 0{
                    
                    cell.setup(object: LIST[indexPath.item])
                    
                
                }else{
                    cell.setup(object: nil)
                }
                
                
                cell.roundedCorners(radius: 25)
                cell.addShadowView()
                
                
                cell.infosConstraintTop.constant = 0
                cell.infosConstraintLeft.constant = 10
                cell.infosConstraintRight.constant = 10
                cell.infosConstraintBottom.constant = 5
                
                cell.imageConstraintTop.constant = 3
                cell.imageConstraintLeft.constant = 3
                cell.imageConstraintRight.constant = 3
                cell.imageConstraintBottom.constant = 3
                
                cell.backgroundColor = Colors.Appearance.whiteGrey
                
                
                /*cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOpacity = 0.1
                cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
                cell.layer.shadowRadius = 25
                cell.layer.masksToBounds = false*/
                
                
                return cell
                
            }else{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                return cell
            }
            
    }
    
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let store = self.LIST[indexPath.row]
        store.save()
        
    
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
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
      /* if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
            
             if Device.isPhone{
                       let finalHeight = frame.width / 1.7
                       let finalWidth = frame.width - 20
                       return CGSize(width: finalWidth,height: finalHeight)
            }else if Device.isPad{
                       let finalHeight = (frame.width / 3)
                       let finalWidth = (frame.width/2)-11
                       return CGSize(width: finalWidth,height: finalHeight)
                   }else{
                        let finalHeight = frame.width / 1.7
                       let finalWidth = frame.width - 20
                       return CGSize(width: finalWidth,height: finalHeight)
                   }
            
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2_2{
            
            if Device.isPhone{
                       let finalHeight = frame.width / 1.7
                       let finalWidth = frame.width - 20
                       return CGSize(width: finalWidth,height: finalHeight)
                   }else if Device.isPad{
                       let finalHeight = (frame.width / 3)
                       let finalWidth = (frame.width/2)-11
                       return CGSize(width: finalWidth,height: finalHeight)
                   }else{
                        let finalHeight = frame.width / 1.7
                       let finalWidth = frame.width - 20
                       return CGSize(width: finalWidth,height: finalHeight)
                   }
            
        }else{
            
            if Device.isPhone{
                let finalHeight = frame.width / 1.3
                return CGSize(width: frame.width,height: finalHeight)
            }else if Device.isPad{
                let finalHeight = frame.width / 2
                return CGSize(width: frame.width,height: finalHeight)
            }else{
                let finalHeight = frame.width / 1.3
                return CGSize(width: frame.width,height: finalHeight)
            }
           
        }*/
        
      
        if Device.isPhone{
                              let finalHeight = frame.width / 1.7
                              let finalWidth = frame.width - 20
                              return CGSize(width: finalWidth,height: finalHeight)
                   }else if Device.isPad{
                              let finalHeight = (frame.width / 3)
                              let finalWidth = (frame.width/2)-11
                              return CGSize(width: finalWidth,height: finalHeight)
                          }else{
                               let finalHeight = frame.width / 1.7
                              let finalWidth = frame.width - 20
                              return CGSize(width: finalWidth,height: finalHeight)
                          }
       
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V1{
            return UIEdgeInsets(top: spacing_row, left: 0, bottom: spacing_row, right: 0)
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2{
            return UIEdgeInsets(top: spacing_row, left: 0, bottom: spacing_row, right: 0)
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_STORES] == AppStyle.Listing.itemStore.V2_2{
            return UIEdgeInsets(top: spacing_row, left: 0, bottom: spacing_row, right: 0)
        }else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //item = 10, count = 10 , COUNT = 23
        
         Utils.printDebug(" Paginate \( (indexPath.item + 1) ) - \(LIST.count) - \(GLOBAL_COUNT)")
      
        
        if indexPath.item + 1 == LIST.count && LIST.count < GLOBAL_COUNT && !isLoading {
            Utils.printDebug(" Paginate! \(__req_page) ")
            self.load()
        }
        
    }
    private var isLoading = false
    
    
    
    //API
    
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        
        self.__req_default_tz = TimeZone.current.abbreviation()!
        self.__req_current_date = DateUtils.getCurrent(format: DateFomats.defaultFormatUTC)
       
        Utils.printDebug("\(self.__req_default_tz) ---- \(self.__req_current_date)")
        
        
        
        if __req_page == 1 {
            make_as_loader()
        }else{
            self.viewManager.showAsLoading()
        }
       

        self.storeLoader.delegate = self

        //Get current Location
    
        var parameters = [
            "limit"          : "10"
        ]
        
      
        
        if __req_redius > 0 && __req_redius < AppConfig.distanceMaxValue {
            
            if(AppConfig.distanceUnit ==  Distance.Types.Kilometers){
                parameters["radius"] = String( (__req_redius*1000) ) //radius by km (merters)s
            }else{
                parameters["radius"] = String( (__req_redius*1609) ) //radius by miles (meters)
            }
            
        }
        

        parameters["category_id"] = String(__req_category)
        parameters["page"] = String(__req_page)
        parameters["search"] = String(__req_search)
        
        
        parameters["current_date"] = String(__req_current_date)
        parameters["current_tz"] = String(__req_default_tz)
        parameters["opening_time"] = String(__req_opening_time)


        if(__req_list_order == StoresListRequestOrder.featured){
            parameters["order_by"] = String(StoresListRequestOrder.nearby)
            parameters["is_featured"] = String(1)
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
        
        self.isLoading = true
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
    }
    
    
    func success(parser: StoreParser,response: String) {
        
        
        if(self.__req_page == 1){
          self.make_as_result()
        }
        
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
               
             
        
        if parser.success == 1 {
         
            let stores = parser.parse()
           
            self.GLOBAL_COUNT = parser.count
            
            if stores.count > 0 {
                
                Utils.printDebug("We loaded \(stores.count)")
                
                if self.__req_page == 1 {
                    self.LIST = stores
                }else{
                    self.LIST += stores
                }
                
                 self.collectionView.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
               
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                    viewManager.showAsEmpty()
                    
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    viewManager.showAsEmpty()
                }
               
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListStores")
                Utils.printDebug("\(errors)")
                
                 viewManager.showAsError()
              
            }
            
        }
        
        
         self.isLoading = false
               
    }
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.collectionView.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        self.isLoading = false
        self.refreshControl.endRefreshing()
        self.viewManager.showAsError()
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
    
    }
    
  
    func onReloadAction(action: ErrorLayout) {
        
        self.viewManager.showAsLoading()
        
        __req_search = ""
        __req_page = 1

        load()
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
        self.viewManager.showAsLoading()
        
        __req_search = ""
        __req_page = 1

        load()
        
    }
    
 

    
    enum StoresListRequestOrder {
        static let nearby = "nearby"
        static let featured = "featured"
        static let recent = "recent"
        static let saved = "saved"
        static let own = "own"
        static let top_rated = "top_rated"
        static let nearby_top_rated = "nearby_top_rated"
    }

    
}



/*
extension ListStoresCell{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Offer()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.collectionView.reloadData()
        self.collectionView.isScrollEnabled = false
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.collectionView.reloadData()
        self.collectionView.isScrollEnabled = true
    }
    
}*/

