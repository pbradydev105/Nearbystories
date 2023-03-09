//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus


protocol ResultListViewControllerDelegate {
    func onSearchButtonPressed(controller: ResultListViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController)
    func onSearchResultBackPressed(controller: ResultListViewController, filterCache: SearchDialogViewController.FilterCache)
}

class ResultListViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SearchDialogViewControllerDelegate{
    
    let modules = [AppConfig.Tabs.Tags.TAG_STORES, AppConfig.Tabs.Tags.TAG_OFFERS, AppConfig.Tabs.Tags.TAG_EVENTS]
    var current_module = AppConfig.Tabs.Tags.TAG_STORES
    
    var delegate: ResultListViewControllerDelegate? = nil
    var filterCache: SearchDialogViewController.FilterCache? = nil
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
        
         StoresLsitViewController.isAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
        
         StoresLsitViewController.isAppear = true
    }
    
  
    static var isAppear = false
    
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    var request: String = ListStoresCell.StoresListRequestOrder.nearby

    
    var parameters: [String: String] = [
        "__req_category": "0",
        "__req_redius": String(AppConfig.distanceMaxValue),
        "__req_list_order": String(ListStoresCell.StoresListRequestOrder.nearby),
        "__req_search": "",
        "__req_store": "0",
        "__req_page": "1",
        "__req_current_date": "",
        "__req_default_tz": "",
        "__req_opening_time": "0",
    ]

    var category_id: Int? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    
    func renderResult(title: String) {
        
        
        topBarTitle.text = title
        
        for tag in AppConfig.Tabs.Pages{
            if tag == AppConfig.Tabs.Tags.TAG_STORES{
                collectionView?.register(ListStoresCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_OFFERS{
                collectionView?.register(ListOfferCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_EVENTS{
                collectionView?.register(ListEventCell.self, forCellWithReuseIdentifier: tag)
            }
        }
      
        collectionView.reloadData()
        
        
    }
    
    func setupNavBarButtons() {
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        
        
        //setp search icon btn
        let searchImage = UIImage.init(icon: .linearIcons(.magnifier), size: CGSize(width: 25, height: 25), textColor: Colors.Appearance.darkColor)
        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(searchBarButtonItem)
        
    }
    
    
    
    @objc func handleSearch() {
        
        Utils.printDebug("handleSearch: \(self.parameters)")
        
        let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
        
        if let vc = sb.instantiateInitialViewController() {
            
            let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController

            if let cache = filterCache, let _type = cache._type, let _view =  cache._view{
                searchDialog.setup(type: _type, view: _view)
            }else{
                
                Utils.printDebug("handleSearch: current_module =>\(self.current_module)")
                
                //instance current filter
                if(self.current_module == AppConfig.Tabs.Tags.TAG_STORES ){
                    
                    let mStoreSearch = UIView.loadFromNib(name: "StoreSearch") as! StoreSearch
                    mStoreSearch.ex_parameters = parameters
                    searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_STORES, view: mStoreSearch)
                    
                }else if(self.current_module == AppConfig.Tabs.Tags.TAG_OFFERS ){
                    
                    let mOfferSearch = UIView.loadFromNib(name: "OfferSearch") as! OfferSearch
                    mOfferSearch.ex_parameters = parameters
                    searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_OFFERS, view: mOfferSearch)
                    
                }else if(self.current_module == AppConfig.Tabs.Tags.TAG_EVENTS ){
                    
                    let mEventSearch = UIView.loadFromNib(name: "EventSearch") as! EventSearch
                    mEventSearch.ex_parameters = parameters
                    searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_EVENTS, view: mEventSearch)
                    
                }
                
            }

            searchDialog.delegate = self

            if let controller = self.tabBarController{
                controller.present(searchDialog, animated: true, completion: nil)
            }else{
                self.present(searchDialog, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func getParameters(type: String, instance: UIView?) ->  [String: String] {
    
        parameters["__req_list_order"] = request
    
        if type == AppConfig.Tabs.Tags.TAG_STORES{
            
            let myView = instance as! StoreSearch
            
            parameters["__req_search"] = myView.search_field.text!
            
            if let cat = myView.selected_category {
                parameters["__req_category"] = String(cat.numCat)
            }
            
            parameters["__req_redius"] = String(Int(myView.sliderView.value))
            
            
            if myView.openOnlySwitch.isOn{
                parameters["__req_opening_time"] = "1"
            }else{
                parameters["__req_opening_time"] = "0"
            }
            
            
        }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
            
            
            let myView = instance as! OfferSearch
            
            //parameters["__req_list_order"] = ListOfferCell.OffersListRequestOrder.nearby
            parameters["__req_search"] = myView.search_field.text!
            
            if let cat = myView.selected_category {
                parameters["__req_category"] = String(cat.numCat)
            }
            
            parameters["__req_redius"] = String(Int(myView.sliderView.value))
            
            if myView.isPriceType{
                parameters["__req_list_type"] = "price"
                parameters["__req_list_type_value"] = myView.priceRangeSelected
            }else if myView.isDiscountType{
                parameters["__req_list_type"] = "percent"
                parameters["__req_list_type_value"] = myView.discountRangeSelected
            }else{
                parameters["__req_list_type"] = "all"
                parameters["__req_list_type_value"] = ""
            }
            
            
        }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
            
            
            let myView = instance as! EventSearch
            
        
            parameters["__req_search"] = myView.search_field.text!
            
            if let cat = myView.selected_category {
                parameters["__req_category"] = String(cat.numCat)
            }
            
            parameters["__req_redius"] = String(Int(myView.sliderView.value))
            parameters["__req_date_begin"] = myView.date_begin_field.text!
            
        }
    
    
        return parameters
    
    }
    
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
        
        controller.onBackHandler()
        
        filterCache = SearchDialogViewController.FilterCache()
        filterCache?._type = type
        filterCache?._view = view
        
        current_module = type
        
        self.parameters = getParameters(type: current_module, instance: view)
        
        Utils.printDebug("Result Parameters=> \(parameters)")
       
      
       
        if type == AppConfig.Tabs.Tags.TAG_STORES{
                
                  //Sort parameters DATE - GEO
                  if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                      && SearchDialogViewController.listing_custom_location_enabled){
                      
                      request = ListStoresCell.StoresListRequestOrder.nearby
                      parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                      parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                      parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                      
                  }else  if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                    
                    request = ListStoresCell.StoresListRequestOrder.nearby
                    parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                    
                  }else{
                     
                      request = ListStoresCell.StoresListRequestOrder.recent
                      parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.recent
                     
                  }
                  
               
                
              }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
                  
                  //Sort parameters DATE - GEO
                  if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                                 && SearchDialogViewController.listing_custom_location_enabled){
                                 
                      request = ListOfferCell.OffersListRequestOrder.nearby
                      parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                      parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                      parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                                 
                  }else if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                                 
                      request = ListOfferCell.OffersListRequestOrder.nearby
                      parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                                
                  }else{
                                
                      request = ListOfferCell.OffersListRequestOrder.recent
                      parameters["__req_order"] = ListOfferCell.OffersListRequestOrder.recent
                                
                  }
                
              }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
                  
                  
                  //Sort parameters DATE - GEO
                  if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                                 && SearchDialogViewController.listing_custom_location_enabled){
                                 
                      request = ListEventCell.EventsListRequestOrder.recent
                      parameters["__req_order"] = ListEventCell.EventsListRequestOrder.nearby
                      parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                      parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                                 
                  }else if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                                 
                      request = ListEventCell.EventsListRequestOrder.nearby
                      parameters["__req_order"] = ListEventCell.EventsListRequestOrder.nearby
                               
                  }else{
                                
                      request = ListEventCell.EventsListRequestOrder.recent
                      parameters["__req_order"] = ListEventCell.EventsListRequestOrder.recent
                               
                  }
                  
                 
              }
        
        
        renderResult(title: "Result for %@ ".localized.format(arguments: current_module.localized))
        
        
    }
    
    
    @objc func onBackHandler()  {
        
        if let del = delegate, let cache = filterCache{
            del.onSearchResultBackPressed(controller: self, filterCache: cache)
        }
        
        if let controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if config.customToolbar{
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        for tag in AppConfig.Tabs.Pages{
            if tag == AppConfig.Tabs.Tags.TAG_STORES{
               collectionView?.register(ListStoresCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_OFFERS{
                collectionView?.register(ListOfferCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_EVENTS{
                collectionView?.register(ListEventCell.self, forCellWithReuseIdentifier: tag)
            }
        }
        
        
        collectionView.isScrollEnabled = false
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        
         if let custom_title = config.custom_title{
            renderResult(title: custom_title)
        }else{
            renderResult(title: "Result for %@ ".localized.format(arguments: current_module.localized))
        }
        
    }
    
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        
       
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles() {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
       
        
        
        if let custom_title = config.custom_title{
            topBarTitle.text = custom_title
        }else{
            topBarTitle.text = ""
        }
       
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{

        
         parameters["__req_list_order"] = self.request
        
        
        if current_module == AppConfig.Tabs.Tags.TAG_STORES {
            
            
            let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: current_module, for: indexPath) as! ListStoresCell
            
            if let _navigationController = navigationController{
                cell.viewNavigationController = _navigationController
            }else{
                cell.viewController = self
            }
            
            
            cell.__req_list_order = self.request
                
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            cell.__req_list_order = parameters["__req_list_order"]!
            cell.__req_category = Int(parameters["__req_category"]!)!
            cell.__req_search =  parameters["__req_search"]!
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            cell.__req_opening_time = Int(parameters["__req_opening_time"]!)!
            
            if let lat = parameters["__req_loc_latitude"], let lng = parameters["__req_loc_longitude"]{
                cell.__req_loc_latitude = Double(lat)!
                cell.__req_loc_longitude = Double(lng)!
            }
            
            
            
            cell.setupViews()
            cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
            
            if(cell.isFetched){
                cell.__req_page = 1
                cell.load()
            }
           
            
            return cell
            
        }else if current_module == AppConfig.Tabs.Tags.TAG_OFFERS {
            
            let cell: ListOfferCell  = collectionView.dequeueReusableCell(withReuseIdentifier: current_module, for: indexPath) as! ListOfferCell
            
            if let _navigationController = navigationController{
                cell.viewNavigationController = _navigationController
            }else{
                cell.viewController = self
            }
            
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            cell.__req_list_order = parameters["__req_list_order"]!
            
            if let __req_store = parameters["__req_store"]{
                cell.__req_store = Int(__req_store)!
            }
            
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            cell.__req_search = parameters["__req_search"]!
            
            if let __req_list_type = parameters["__req_list_type"]{
                cell.__req_list_type = __req_list_type
            }
            
            if let __req_list_type_value = parameters["__req_list_type_value"] {
                cell.__req_list_type_value = __req_list_type_value
            }
            
             if let lat = parameters["__req_loc_latitude"], let lng = parameters["__req_loc_longitude"]{
                cell.__req_loc_latitude = Double(lat)!
                cell.__req_loc_longitude = Double(lng)!
            }
            
            cell.setupViews()
            cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
            
            if(cell.isFetched){
                cell.__req_page = 1
                cell.load()
            }
            
             return cell
            
        }else if current_module == AppConfig.Tabs.Tags.TAG_EVENTS {
            
            let cell: ListEventCell  = collectionView.dequeueReusableCell(withReuseIdentifier: current_module, for: indexPath) as! ListEventCell
            
            if let _navigationController = navigationController{
                cell.viewNavigationController = _navigationController
            }else{
                cell.viewController = self
            }
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            cell.__req_list_order = parameters["__req_list_order"]!
            
            cell.__req_category = Int(parameters["__req_category"]!)!
            cell.__req_search = parameters["__req_search"]!
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            
            if let __req_date_begin = parameters["__req_date_begin"] {
                cell.__req_date_begin = __req_date_begin
            }
            
                  
            if let lat = parameters["__req_loc_latitude"], let lng = parameters["__req_loc_longitude"]{
                cell.__req_loc_latitude = Double(lat)!
                cell.__req_loc_longitude = Double(lng)!
            }
            
            cell.setupViews()
            cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
            
            if(cell.isFetched){
                cell.__req_page = 1
                cell.load()
            }
             return cell
            
        }else{
            
            
            let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: current_module, for: indexPath) as! ListStoresCell
            
            cell.viewController = self
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            cell.setupViews()
            
            return cell
            
        }
        
        
    
    }
    
    
    var count = 1
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width ,height: view.frame.height - 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
      /*  if current_module == AppConfig.Tabs.Tags.TAG_STORES {
            
            
            let cell: ListStoresCell  = cell as! ListStoresCell
            
            cell.__req_category = Int(parameters["__req_category"]!)!
            cell.__req_search =  parameters["__req_search"]!
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            cell.__req_opening_time = Int(parameters["__req_opening_time"]!)!
            

            cell.setupViews()
            //cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
           
            
            
        }else if current_module == AppConfig.Tabs.Tags.TAG_OFFERS {
            
            
             let cell: ListOfferCell  = cell as! ListOfferCell
            
            if let _navigationController = navigationController{
                cell.viewNavigationController = _navigationController
            }else{
                cell.viewController = self
            }
            
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            //cell.setupViews()
            
            if let __req_store = parameters["__req_store"]{
                cell.__req_store = Int(__req_store)!
            }
            
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            cell.__req_search = parameters["__req_search"]!
            
            if let __req_list_type = parameters["__req_list_type"]{
                cell.__req_list_type = __req_list_type
            }
            
            if let __req_list_type_value = parameters["__req_list_type_value"] {
                cell.__req_list_type_value = __req_list_type_value
            }
            

            cell.setupViews()
            //cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
            cell.refreshControl.beginRefreshing()
            
        }else if current_module == AppConfig.Tabs.Tags.TAG_EVENTS {
            
            let cell: ListEventCell  = cell as! ListEventCell
            
            if let _navigationController = navigationController{
                cell.viewNavigationController = _navigationController
            }else{
                cell.viewController = self
            }
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            
            cell.__req_category = Int(parameters["__req_category"]!)!
            cell.__req_search = parameters["__req_search"]!
            cell.__req_redius = Int(parameters["__req_redius"]!)!
            
            if let __req_date_begin = parameters["__req_date_begin"] {
                cell.__req_date_begin = __req_date_begin
            }
            
            
            cell.setupViews()
            //cell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
            cell.refreshControl.beginRefreshing()
            
        }else{
            
            
            let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: current_module, for: indexPath) as! ListStoresCell
            
            cell.viewController = self
            
            cell.__req_list_order = self.request
            
            if let cat = self.category_id{
                cell.__req_category = cat
            }
            
            cell.setupViews()
            
            
        }
        */
        
    
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
}






