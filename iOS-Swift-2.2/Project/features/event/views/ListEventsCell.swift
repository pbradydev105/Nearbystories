//
//  ListEventCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit

class ListEventCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , EventLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
    
    //request
    var __req_loc_latitude: Double = 0.0
    var __req_loc_longitude: Double = 0.0
    
    
    var __req_date_begin: String = ""
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String =  EventsListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Event] = [Event]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "eventCellId"
    
    
    //instance for scrolling
    var isFetched = false
    
    let spacing_row = CGFloat(AppStyle.padding_size_item)
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = Colors.bg_gray
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2{
            if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = spacing_row
            }
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2_2{
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
        
        collectionView.backgroundColor = Colors.Appearance.background
        
    }
    
    private let refreshControl = UIRefreshControl()
    
    
    func fetch(request: String) {
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        isFetched = true
        
        Utils.printDebug("Fetch ListEvents")
        
        contentView.addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        
         if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2{
            collectionView.register(UINib(nibName: "EventV2Cell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2_2{
            collectionView.register(UINib(nibName: "EventV2_2Cell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }else{
            collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        }
        

        
       // refreshControl.beginRefreshing()
        
        load()
        
        
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_search_events") { result in
            
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
        
        
        layoutIfNeeded()
    }
    
    
    
    @objc private func refreshData(_ sender: Any) {
        //Init params
        __req_page = 1
        
        // Fetch Data
        load()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            
            if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EventV2Cell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                
                return cell
                
            }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2_2{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EventV2_2Cell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                
                return cell
                
            }else{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EventCell
                
                cell.setupSettings()
                cell.setup(object: LIST[indexPath.item])
                
                
                return cell
                
            }
            
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let event = self.LIST[indexPath.row]
        event.save()
        
       
         let sb = UIStoryboard(name: "EventDetailV2", bundle: nil)
                   let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController
                   
                   ms.event_id = event.id
                   
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
        
       /* if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2{
            
            if Device.isPhone{
                if Device.screen <= .inches_5_5{
                    let finalHeight = frame.width / 1.8
                    return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
                }else{
                    let finalHeight = frame.width / 1.6
                    return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
                }
            }else if Device.isPad{
                let finalHeight = frame.width / 3.2
                return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
            }else{
                let finalHeight = frame.width / 1.5
                return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
            }
            
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_EVENTS] == AppStyle.Listing.itemEvent.V2_2{
            
            if Device.isPhone{
                if Device.screen <= .inches_5_5{
                    let finalHeight = frame.width / 1.8
                    return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
                }else{
                    let finalHeight = frame.width / 1.6
                    return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
                }
            }else if Device.isPad{
                let finalHeight = frame.width / 3.2
                return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
            }else{
                let finalHeight = frame.width / 1.5
                return CGSize(width: frame.width-(spacing_row*2),height: finalHeight)
            }
            
        }else{
            
            if Device.isPhone{
                if Device.screen <= .inches_5_5{
                    let finalHeight = frame.width / 1.6
                    return CGSize(width: frame.width,height: finalHeight)
                }else{
                    let finalHeight = frame.width / 1.4
                    return CGSize(width: frame.width,height: finalHeight)
                }
            }else if Device.isPad{
                let finalHeight = frame.width / 3
                return CGSize(width: frame.width/1.5,height: finalHeight)
            }else{
                let finalHeight = frame.width / 1.3
                return CGSize(width: frame.width,height: finalHeight)
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
        
        if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemEvent.V2{
            return UIEdgeInsets(top: spacing_row, left: 0, bottom: spacing_row, right: 0)
        }else if AppConfig.Design.listingStyle[AppConfig.Tabs.Tags.TAG_OFFERS] == AppStyle.Listing.itemEvent.V2_2{
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
    
    var eventLoader: EventLoader = EventLoader()
    
    func load () {
        
        if __req_page == 1 {
            make_as_loader()
           // self.refreshControl.beginRefreshing()
        }else{
            self.viewManager.showAsLoading()
        }
        
        
        self.eventLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "10"
        ]
        
        if __req_redius > 0 && __req_redius < 100 {
                       parameters["radius"] = String( (__req_redius*1000) ) //radius by merters
                   }
                   
                   if let user = myUserSession {
                       parameters["user_id"] = String(user.id)
                   }
                   
                   parameters["category_id"] = String(__req_category)
                   parameters["page"] = String(__req_page)
                   parameters["search"] = String(__req_search)
                   parameters["date"] = String(__req_date_begin)
                   
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
        self.eventLoader.load(url: Constances.Api.API_USER_GET_EVENTS,parameters: parameters)
        
    }
    
    
    func success(parser: EventParser,response: String) {
        
        
        make_as_result()
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
        
        
        self.isLoading = false
        
        if parser.success == 1 {
            
            
            let events = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if events.count > 0 {
                
                Utils.printDebug("We loaded \(events.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = events
                }else{
                    self.LIST += events
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
                
                Utils.printDebug("===> Request Error with Messages! ListevEntss")
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
        
        Utils.printDebug("===> Request Error! ListEventss")
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
    
    
    
    enum EventsListRequestOrder {
        static let nearby = "nearby"
        static let featured = "featured"
        static let recent = "recent"
        static let saved = "saved"
        static let own = "own"
        static let upcoming = "upcoming"
    }
    

    
}


extension ListEventCell{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Event()
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
