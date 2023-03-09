//
//  ListOffersCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit

class ListOfferCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , OfferLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
   
    
    //request
    var __req_loc_latitude: Double = 0.0
    var __req_loc_longitude: Double = 0.0
    
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = OffersListRequestOrder.nearby
    
    var __req_list_type = "all" //discount/value/all
    var __req_list_type_value = ""
    
    var __req_search: String = ""
    var __req_page: Int = 1
    var __req_store: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Offer] = [Offer]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "offerCellId"
    
    
    //instance for scrolling
    var isFetched = false
    let spacing_row = CGFloat(AppStyle.padding_size_item)
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = Colors.Appearance.background
        
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemOffer.V2{
            if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = spacing_row
            }
        }else{
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
        
        Utils.printDebug("Fetch ListOffers")
        
        contentView.addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemOffer.V2{
            collectionView.register(UINib(nibName: "OfferV2Cell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }else{
            collectionView.register(UINib(nibName: "OfferCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }
        
       
        
        //refreshControl.beginRefreshing()
        
        load()
        
        
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_search_offers") { result in
            
            if let object = result?.object{
                
                let array: [String: String] = object as! [String : String]
                
                self.__req_redius = Int(array["radius"]!)!
                self.__req_search = array["search"]!
                self.__req_page = 1
                
                
                self.viewManager.showAsLoading()
                self.load()
                
                
            }
            
        }
        
        
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
            
             if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemOffer.V2{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OfferV2Cell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                return cell
            
            }else{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OfferCell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                return cell
                
            }
            
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let offer = self.LIST[indexPath.row]
        offer.save()
        
        
        let sb = UIStoryboard(name: "OfferDetailV2", bundle: nil)
                   let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
                   
                   ms.offer_id = offer.id
                   
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       /* if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemOffer.V2{
            
              if Device.isPhone{
                     let finalHeight = frame.width / 2.0
                     let finalWidth = frame.width - 20
                     return CGSize(width: finalWidth,height: finalHeight)
                 }else if Device.isPad{
                     let finalHeight = (frame.width / 3.5)
                     let finalWidth = (frame.width/2)-11
                     return CGSize(width: finalWidth,height: finalHeight)
                 }else{
                     let finalHeight = frame.width / 2.0
                     let finalWidth = frame.width - 20
                     return CGSize(width: finalWidth,height: finalHeight)
                 }
            
        }else{
            
               if Device.isPhone{
                     let finalHeight = frame.width / 2.0
                     let finalWidth = frame.width - 20
                     return CGSize(width: finalWidth,height: finalHeight)
                 }else if Device.isPad{
                     let finalHeight = (frame.width / 3.5)
                     let finalWidth = (frame.width/2)-11
                     return CGSize(width: finalWidth,height: finalHeight)
                 }else{
                     let finalHeight = frame.width / 2.0
                     let finalWidth = frame.width - 20
                     return CGSize(width: finalWidth,height: finalHeight)
                 }
            
        }*/
        
        if Device.isPhone{
                 let finalHeight = frame.width / 2.0
                 let finalWidth = frame.width - 20
                 return CGSize(width: finalWidth,height: finalHeight)
             }else if Device.isPad{
                 let finalHeight = (frame.width / 3.5)
                 let finalWidth = (frame.width/2)-11
                 return CGSize(width: finalWidth,height: finalHeight)
             }else{
                 let finalHeight = frame.width / 2.0
                 let finalWidth = frame.width - 20
                 return CGSize(width: finalWidth,height: finalHeight)
             }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemOffer.V2{
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
    
    var offerLoader: OfferLoader = OfferLoader()
    
    func load () {
        
        if __req_page == 1 {
            make_as_loader()
        }else{
            self.viewManager.showAsLoading()
        }
        
    
        
        
        self.offerLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "10"
        ]
        
         if __req_redius > 0 && __req_redius < 100 {
                       parameters["radius"] = String( (__req_redius*1000) ) //radius by merters
                   }
               
                   
                   parameters["category_id"] = String(__req_category)
                   parameters["page"] = String(__req_page)
                   parameters["search"] = String(__req_search)
                   parameters["date"] = String(__req_search)
                   parameters["store_id"] = String(__req_store)
                   
                   
                   parameters["value_type"] = String(__req_list_type)
                   parameters["offer_value"] = String(__req_list_type_value)
                   
                   parameters["order_by"] = String(__req_list_order)
                   
                   if(__req_loc_latitude != 0.0 && __req_loc_longitude != 0.0){
                              parameters["latitude"] = String(__req_loc_latitude)
                              parameters["longitude"] = String(__req_loc_longitude)
                          }else  if let guest = Guest.getInstance() {
                              parameters["latitude"] = String(guest.lat)
                              parameters["longitude"] = String(guest.lng)
                          }
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.offerLoader.load(url: Constances.Api.API_GET_OFFERS,parameters: parameters)
        
        
    }
    
    
    func success(parser: OfferParser,response: String) {
        
      
        if(self.__req_page == 1){
            self.make_as_result()
        }
        
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
        
        
        self.isLoading = false
        
        if parser.success == 1 {
            
            
            let offers = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if offers.count > 0 {
                
                Utils.printDebug("We loaded \(offers.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = offers
                }else{
                    self.LIST += offers
                }
                
                self.collectionView.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                    //show emty layout
                    viewManager.showAsEmpty()
                    
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    
                    viewManager.showAsEmpty()
                    
                    Utils.printDebug("===> Is Empty!")
                }
                
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListOffers")
                Utils.printDebug("\(errors)")
                
                viewManager.showAsError()
                
            }
            
        }
        
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
        
        Utils.printDebug("===> Request Error! ListOffers")
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
    
    
    
    enum OffersListRequestOrder {
        static let nearby = "nearby"
        static let recent = "recent"
        static let featured = "featured"
        static let saved = "saved"
        static let own = "own"
    }
    
    
    
}


extension ListOfferCell{
    
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
    
}



