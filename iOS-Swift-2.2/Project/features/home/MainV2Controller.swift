//
//  MainV2Controller.swift
//  NearbyStores
//
//  Created by Amine  on 7/27/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import SwiftEventBus
import UserNotifications
import AssistantKit
import GoogleMobileAds
import CoreLocation
import RealmSwift


class MyUICollectionViewController: UICollectionViewController {
    
    struct ViewControllerConfig {
        var toolbar: Bool = true
        var backHome: Bool = true
    }
    
    var config: ViewControllerConfig = ViewControllerConfig()
    
    
    override func viewDidLoad() {
        
        InComingDataParser.openViewEventBus(controller: self)
        self.view.backgroundColor = Colors.Appearance.darkColor
       
        UIApplication.shared.applicationIconBadgeNumber = 0

    }
    
}

class MyUIViewController: UIViewController {
    
    struct ViewControllerConfig {
        var customToolbar: Bool = true
        var backHome: Bool = true
        var custom_title: String? = nil
    }
    
    var config: ViewControllerConfig = ViewControllerConfig()
    
    override func viewDidLoad() {
        InComingDataParser.openViewEventBus(controller: self)
        self.view.backgroundColor = Colors.Appearance.darkColor
        if #available(iOS 13.0, *) {
           // overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0

    }
}

class MainV2Controller: MyUIViewController, CategoryLoaderDelegate,  CLLocationManagerDelegate, SearchDialogViewControllerDelegate, ResultListViewControllerDelegate, UIScrollViewDelegate{
   
    static func newInstance() -> MainV2Controller{
        let main_sb = UIStoryboard(name: "MainV2", bundle: nil)
        let main_vc: MainV2Controller = main_sb.instantiateViewController(withIdentifier: "mainv2VC") as! MainV2Controller
        return main_vc
    }
 
    var filterCache: SearchDialogViewController.FilterCache? = nil
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let controller = self.navigationController, config.customToolbar == true{
            controller.navigationBar.isHidden = false
            
        }

        MainV2Controller.isAppear = false
        
        self.view.backgroundColor = Colors.Appearance.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let controller = self.navigationController, config.customToolbar == true{
            controller.navigationBar.isHidden = true
        }
        
        MainV2Controller.isAppear = true
    }
    
    static var isAppear = false
    
    //end setup uicollection protocoles
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header_image_bg_view: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var box_search_container: EXUIView!
    @IBOutlet weak var box_search_icon: UIImageView!
    @IBOutlet weak var box_search_label: UILabel!
    @IBOutlet weak var box_search_button: UIButton!
    
    @IBOutlet weak var main_view: UIView!
    
    //cards view listeners
    func onLoadMore(object: Any) {
        
    }
    
    func onItemClicked(object: Any) {
        
    }
    //END cards view listeners
    

    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D? = nil


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        self.currentLocation = locValue

      
        if let guest = Guest.getInstance(), let cl = self.currentLocation {


            let realm = try! Realm()
            try! realm.write {

                guest.lat = cl.latitude
                guest.lng = cl.longitude
                realm.add(guest,update: .all)

            }

            self.locationManager.stopUpdatingLocation()

        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            self.locationManager.startUpdatingLocation()
        }

    }



    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.requestLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                self.requestLocation()
            default:
                //do thing
                break
            }
        }


    }

    func requestLocation() {

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }



    let topBarTitle: EdgeLabel = {

        let titleLabel = EdgeLabel()

        let appname = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Home".localized

        titleLabel.text = appname

        if(AppConfig.Design.uiColor == AppStyle.uiColor.dark){
            titleLabel.textColor = UIColor.white
        }else{
            titleLabel.textColor = Colors.Appearance.primaryColor
        }

        titleLabel.font = UIFont.systemFont(ofSize: 20)

        return titleLabel

    }()
    
    func setupNavigationBar() {
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
    }
    
    
    func setupNavBarTitles() {
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        topBarTitle.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        
        navigationBarItem.titleView = topBarTitle

    }
    
    
    /* Set up collection view for horizontal cards */
    
    private let refreshControl = UIRefreshControl()
    
    func setupRefreshControl() {
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
    }
    
    
    @objc private func refreshData(_ sender: Any) {
        
        
    }
    
    
    let cellId = "horizontalCellId"
    
    let padding_size = CGFloat(20)
    
    func setupHeaderView(){
    
        self.box_search_button.addTarget(self, action: #selector(handleSearchClick), for: .touchUpInside)
        
        
       self.header_image_bg_view.contentMode = .scaleAspectFill
       self.header_image_bg_view.backgroundColor = .clear
        
        self.header_image_bg_view.image = UIImage(named: AppConfig.Design.homeHeaderBackgounds.randomElement()!)
        
         
       self.box_search_label.initItalicFont()
        self.box_search_label.text = "Search for restaurants, offers...".localized
        self.box_search_label.textColor = .gray
        
        
        let searchImage = UIImage.init(icon: .linearIcons(.magnifier), size: CGSize(width: 28, height: 28), textColor: .gray)
        self.box_search_icon.image = searchImage
        
    }
    
  

    func setupCards() {
     
        
        for index in 0...AppConfig.Design.homeList.count-1{
            
            let style = AppConfig.Design.homeList[index] as! CardHorizontalStyle
           
            guard let _style = style.type else {
                return
            }
            
            
            var instance: UIView? = nil
            switch _style {
                case .Top_Nearby_Stores:
                    instance = Stores_HCards.newInstance(style: style)
                    (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_TOP_RATED.localized
                    (instance as! Stores_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Stores_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .Nearby_Stores:
                    instance = Stores_HCards.newInstance(style: style)
                    (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_STORES.localized
                    (instance as! Stores_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Stores_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .FeaturedStores:
                    instance = Stores_HCards.newInstance(style: style)
                    (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_FEATURED_STORES.localized
                    (instance as! Stores_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Stores_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .Recent_Offers:
                    instance = Offers_HCards.newInstance(style: style)
                    (instance as! Offers_HCards).h_label.text = AppConfig.CardTags.TAG_RECENT_OFFERS.localized
                    (instance as! Offers_HCards).viewTabBarController = self.tabBarController
                    (instance as! Offers_HCards).load()
                    
                    if let title = style.Title{
                        (instance as! Offers_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .TopCategories:
                    instance = Categories_HCards.newInstance(style: style)
                    (instance as! Categories_HCards).h_label.text = AppConfig.CardTags.TAG_TOP_CATEGORIES.localized
                    (instance as! Categories_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Categories_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .Nearby_Events:
                    instance = Events_HCards.newInstance(style: style)
                    (instance as! Events_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_EVENTS.localized
                    (instance as! Events_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Events_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .Nearby_Users:
                    instance = Users_HCards.newInstance(style: style)
                    (instance as! Users_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_USERS.localized
                    (instance as! Users_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Users_HCards).h_label.text = title.localized
                    }
                    
                    break
                case .SponsoredBanners:
                    instance = Banners_HCards.newInstance(style: style)
                    (instance as! Banners_HCards).h_label.text = AppConfig.CardTags.TAG_SPONSORED_BANNERS.localized
                    (instance as! Banners_HCards).viewTabBarController = self.tabBarController
                    break
                default:
                    instance = Stores_HCards.newInstance(style: style)
                    (instance as! Stores_HCards).h_label.text = AppConfig.CardTags.TAG_NEARBY_STORES.localized
                    (instance as! Stores_HCards).viewTabBarController = self.tabBarController
                    
                    if let title = style.Title{
                        (instance as! Stores_HCards).h_label.text = title.localized
                    }
                    break
                
                }
            
            
            if let _view = instance{
                
                if let height = style.height{
                    instance?.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
                }
                
                stackView.addArrangedSubview(_view)
            }
            
        }
        

    }


    private var lastContentOffset: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
       
        if scrollView.contentOffset.y > 70{
            
            navigationBar.isTranslucent = false
            //navigationBarItem.titleView?.isHidden = false
           
            UIView.animate(withDuration: 0.2) {
                self.navigationBar.layoutIfNeeded()
            }
            
        }else{
            
            //make it transeparent
            navigationBar.isTranslucent = true
            //navigationBarItem.titleView?.isHidden = true

            UIView.animate(withDuration: 0.2) {
                self.navigationBar.layoutIfNeeded()
            }
             
            
        }
        
        
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 13.0, *) {
            _ = previousTraitCollection!.hasDifferentColorAppearance(comparedTo: traitCollection) // Bool
             
          
        } else {
            // Fallback on earlier versions
        }
         
        
            
    }
    
    
    func setAppearance() {
        self.main_view.backgroundColor = Colors.Appearance.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setAppearance()
                
        //update location
        self.locationManager.delegate = self
        self.requestLocation()
        
        setupHeaderView()
        setupCards()
      
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        //self.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
       // self.setupTableView()
        //self.setupCollectionView()
       
        LoginViewController.listner(parent: self)
        SignUpViewController.listner(parent: self)


        self.loadCategories()

        // check and push they
        self.checkUpComingEvents()

        //setup controller views
        navigationBar.isTranslucent = true
        setupNavigationBar()
        setupNavBarButtons()
        setupNavBarTitles()

        busEventsListiner()

        //init and show interstitial ad after 10 seconds
        if AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.ADS_INTERSTITIEL_ENABLED{

            interstitial = GADInterstitial(adUnitID: AppConfig.Ads.AD_INTERSTITIEL_ID)
            let request = GADRequest()
            interstitial.load(request)

            DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                self.showInterstitial()
            }

        }
        
        
        self.scrollView.delegate = self
     
        //get notifications count from server
        count_notifications()
        count_messages()

    }

    var interstitial: GADInterstitial!

    func showInterstitial()  {
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }
    }

    func busEventsListiner() {

        SwiftEventBus.onMainThread(self, name: "open_view_list_event") { result in

            if let req = result?.object{

                let request: String = req as! String
                self.startEventsListVC(request: request)

            }

        }

        SwiftEventBus.onMainThread(self, name: "on_main_refresh") { result in

            if let _ = result?.object{

                self.settingsLauncher.load()

            }

        }

        SwiftEventBus.onMainThread(self, name: "on_badge_refresh") { result in

            if let _ = result?.object{



            }

        }


        SwiftEventBus.onMainThread(self, name: "on_main_redirect") { result in

            if let index = result?.object{

                //

            }

        }

        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in

            if let object = result?.object{


                if Session.isLogged() {

                    let message: Message = object as! Message
                    message.save()

                    guard MessengerViewController.isAppear == false else {
                        Messenger.nbrMessagesNotSeen = 0

                        return
                    }

                    Messenger.nbrMessagesNotSeen += 1


                    if Messenger.nbrMessagesNotSeen == 1 {

                        NotificationManager.push(
                                title: "New Message".localized,
                                subtitle: message.message,
                                identifier: InComingDataParser.tag_new_message
                        )

                    }else if Messenger.nbrMessagesNotSeen > 1 &&  Messenger.nbrMessagesNotSeen < 3 {

                        NotificationManager.push(
                                title: AppConfig.APP_NAME,
                                subtitle: "You have %@ messages".localized.format(arguments: String(Messenger.nbrMessagesNotSeen)),
                                identifier: InComingDataParser.tag_new_message
                        )

                    }
                    
                    self.calculNotifications(newCount: 1)
                  
                }



            }

        }
        
        
        SwiftEventBus.onMainThread(self, name: "on_receive_notification") { result in
            if let object = result?.object{
                self.calculNotifications(newCount: 1)
            }
        }
        
        
        SwiftEventBus.onMainThread(self, name: "decrease_notifications_badge") { result in
            
            guard let b = self.notificationBarButtonItem else {
                return
            }
            
            let button: BadgeButton = b.customView as! BadgeButton
            
            if(button.notification>0){
                self.updateNotificationBadge(count: button.notification-1)
            }else{
                self.updateNotificationBadge(count: 0)
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "increase_notifications_badge") { result in
            
            guard let b = self.notificationBarButtonItem else {
                return
            }
            
            let button: BadgeButton = b.customView as! BadgeButton
            
            if(button.notification>0){
                self.updateNotificationBadge(count: button.notification+1)
            }else{
                self.updateNotificationBadge(count: 0)
            }
            
        }

    }


  
    var notificationBarButtonItem: UIBarButtonItem? = nil
    var inboxBarButtonItem: UIBarButtonItem? = nil
    
    func setupNavBarButtons() {

      
        //setup notification icon btn
        let badgeAlert = BadgeButton()
        badgeAlert.setIcon(icon: .linearIcons(.alarm), iconSize: 24, color: .white, forState: .normal)
        badgeAlert.setupBadge().refreshBadge(count: 0)
        badgeAlert.addTarget(self, action: #selector(handleNotificationClick), for: .touchUpInside)
        notificationBarButtonItem = UIBarButtonItem(customView: badgeAlert)
        
        

        self.navigationBarItem.rightBarButtonItems = []
        self.navigationBarItem.leftBarButtonItems = []


        if let btn = notificationBarButtonItem{
            self.navigationBarItem.rightBarButtonItems?.append(btn)
        }
        
        if let btn = inboxBarButtonItem{
            //self.navigationBarItem.rightBarButtonItems?.append(btn)
        }

        

    }
    
    func updateNotificationBadge(count: Int) {
         
        guard let b = notificationBarButtonItem else {
            return
        }
             
        let button: BadgeButton = b.customView as! BadgeButton
        button.refreshBadge(count: count)
             
    }
    
    
    /*
    * FILTER & SEARCH FEATURE SETUP
    */


    @objc func handleNotificationClick() {
        
        if(!Session.isLogged()){
            startLoginVC()
            return
        }
        
   
        let main = UINavigationController(rootViewController: NotificationTabBarController())
        main.navigationBar.isHidden = true
        main.modalPresentationStyle = .fullScreen
              
        tabBarController?.navigationController?.present(main, animated: true)
       
     
    }
    
    @objc func handleSearchClick() {
           
           if let cache = filterCache, let type = cache._type{
                launchSearchDialog(type: type)
           }else{
                launchSearchDialog(type: AppConfig.Tabs.Tags.TAG_STORES)
           }
          
       }
    
    
    func launchSearchDialog(type: String){
        
        if type == AppConfig.Tabs.Tags.TAG_STORES{
            
            let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
                
                let _view = UIView.loadFromNib(name: "StoreSearch")
                searchDialog.setup(type: type, view: _view)
                searchDialog.delegate = self
                
                if let cache = filterCache{
                    searchDialog.filterCache = cache
                }
                
                tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                //tabBarController?.present(searchDialog, animated: true, completion: nil)
            }
        }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
            
            let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
                
                let _view = UIView.loadFromNib(name: "OfferSearch")
                searchDialog.setup(type: type, view: _view)
                searchDialog.delegate = self
                
                if let cache = filterCache{
                    searchDialog.filterCache = cache
                }
                
                tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                //tabBarController?.present(searchDialog, animated: true, completion: nil)
            }
            
        }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
            
            let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
                
                let _view = UIView.loadFromNib(name: "EventSearch")
                searchDialog.setup(type: type, view: _view)
                searchDialog.delegate = self
                
                if let cache = filterCache{
                    searchDialog.filterCache = cache
                }
                
                tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                //tabBarController!.present(searchDialog, animated: true, completion: nil)
            }
        }
        
        
    }
    
   
    
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
        
        
        filterCache = SearchDialogViewController.FilterCache()

        filterCache?._type = type
        filterCache?._view = view
        
        
        let sb = UIStoryboard(name: "ResultList", bundle: nil)
        let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
        
        
        ms.current_module = type
        
        if type == AppConfig.Tabs.Tags.TAG_STORES{
            
            //let myView = view as! StoreSearch
            
           
          
            ms.parameters = ms.getParameters(type: type, instance: view)
            
            
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            //send saved filter
            ms.filterCache = filterCache
            
            //close search dialog
             controller.onBackHandler()
            
            //register delegate for this controller to manage it from this controller
            ms.delegate = self
            
            
            //Sort parameters DATE - GEO
            if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                && SearchDialogViewController.listing_custom_location_enabled){
                
                ms.request = ListStoresCell.StoresListRequestOrder.nearby
                ms.parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                ms.parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                ms.parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                
            }else if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                
                ms.request = ListStoresCell.StoresListRequestOrder.nearby
                ms.parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
              
            }else{
               
                ms.request = ListStoresCell.StoresListRequestOrder.recent
                ms.parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.recent
               
            }
            
            
            Utils.printDebug("__req_order => \(ms.parameters)")
           
            
            //open result
            //tabBarController?.present(ms, animated: true)
            tabBarController?.navigationController?.pushViewController(ms, animated: true)
            
        }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
            
            ms.parameters = ms.getParameters(type: type, instance: view)
                      
            //ms.delegate = self
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            //send saved filter
            ms.filterCache = filterCache
            
            
            //close search dialog
            controller.onBackHandler()
            
            
            //register delegate for this controller to manage it from this controller
            ms.delegate = self
            
            
            //Sort parameters DATE - GEO
            if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                           && SearchDialogViewController.listing_custom_location_enabled){
                           
                ms.request = ListOfferCell.OffersListRequestOrder.nearby
                ms.parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                ms.parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                ms.parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                           
            }else  if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                                      
                           ms.request = ListOfferCell.OffersListRequestOrder.nearby
                           ms.parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                                   
            }else{
                          
                ms.request = ListOfferCell.OffersListRequestOrder.recent
                ms.parameters["__req_order"] = ListOfferCell.OffersListRequestOrder.recent
                          
            }
            
            //open result
            //tabBarController?.present(ms, animated: true)
            tabBarController?.navigationController?.pushViewController(ms, animated: true)
            
        }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
            
        
            //let myView = view as! EventSearch
            
            ms.parameters = ms.getParameters(type: type, instance: view)
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            //send saved filter
            ms.filterCache = filterCache
            
            
            //close search dialog
             controller.onBackHandler()
            
            //register delegate for this controller to manage it from this controller
            ms.delegate = self
            
            
            //Sort parameters DATE - GEO
            if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                           && SearchDialogViewController.listing_custom_location_enabled){
                           
                ms.request = ListEventCell.EventsListRequestOrder.recent
                ms.parameters["__req_order"] = ListEventCell.EventsListRequestOrder.nearby
                ms.parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                ms.parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                           
            }else if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO){
                           
                ms.request = ListEventCell.EventsListRequestOrder.nearby
                ms.parameters["__req_order"] = ListEventCell.EventsListRequestOrder.nearby
                 
            }else{
                          
                ms.request = ListEventCell.EventsListRequestOrder.recent
                ms.parameters["__req_order"] = ListEventCell.EventsListRequestOrder.recent
                         
            }
            
            //open result
            //tabBarController?.present(ms, animated: true)
            tabBarController?.navigationController?.pushViewController(ms, animated: true)
            
        }
        
    }
    

    
    func onSearchButtonPressed(controller: ResultListViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController) {
    
        controller.dismiss(animated: true) {
            self.onSearch(type: type, view: view, controller: search_dialog_controller)
            // self.view.isHidden = false
        }
        
    }
    
    
    func onSearchResultBackPressed(controller: ResultListViewController, filterCache: SearchDialogViewController.FilterCache) {
        
        self.filterCache = filterCache
        
    }
    
    
    
    
    /*
     * END FILTER & SEARCH FEATURE SETUP
     */

    lazy var settingsLauncher: BottomOptLauncher = {
        let launcher = BottomOptLauncher()
        //launcher.mainController = self
        return launcher
    }()

    @objc func handleMore() {
        settingsLauncher.showOptions()
    }

   

   static var mInstance: MainV2Controller? = nil

    
    func startLoginVC() {

        let sb = UIStoryboard(name: "Login", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            navigationController?.present(ms, animated: true)
        }

    }


    func startSignUpVC() {

        let sb = UIStoryboard(name: "SignUp", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: SignUpViewController = sb.instantiateViewController(withIdentifier: "signupVC") as! SignUpViewController
            navigationController?.present(ms, animated: true)
        }

    }

    func startEditProfileVC() {

        let sb = UIStoryboard(name: "EditProfile", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: EditProfileViewController = sb.instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileViewController
            navigationController?.present(ms, animated: true)
        }

    }


    func startMessenger(client_id: Int,discussion_id: Int) {

        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            ms.discussionId = discussion_id

            navigationController?.present(ms, animated: true)
        }

    }

    func startMessenger(client_id: Int) {

        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id

            navigationController?.present(ms, animated: true)
        }

    }

    func startPeopleList() {

        let sb = UIStoryboard(name: "PeopleList", bundle: nil)

        if sb.instantiateInitialViewController() != nil {

            let vc: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
            navigationController?.present(vc, animated: true)
        }

    }


    func startStoreDetailVC(store_id: Int) {

        let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
            ms.storeId = store_id

            navigationController?.present(ms, animated: true)
        }

    }



    func startStoresList(request: String) {

        let sb = UIStoryboard(name: "StoresList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: StoresLsitViewController = sb.instantiateViewController(withIdentifier: "storeslistVC") as! StoresLsitViewController

            ms.request = request
            
            ms.config.backHome = false
            ms.config.customToolbar = true

            navigationController?.present(ms, animated: true)
        }

    }

    func startCategoriesList() {

        let sb = UIStoryboard(name: "Categories", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: CategoriesViewController = sb.instantiateViewController(withIdentifier: "categoriesVC") as! CategoriesViewController

            ms.config.backHome = false
            ms.config.customToolbar = true
            
            navigationController?.present(ms, animated: true)
        }

    }


    func startOfferDetailVC(offerId: Int) {

        let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController

            ms.offer_id = offerId
            
            ms.config.backHome = false
            ms.config.customToolbar = true

            navigationController?.present(ms, animated: true)
        }

    }


    func startEventDetailVC(eventId: Int) {

        let sb = UIStoryboard(name: "EventDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController

            ms.event_id = eventId
            
            ms.config.backHome = false
            ms.config.customToolbar = true

            navigationController?.present(ms, animated: true)
        }

    }


    func startEventsListVC(request: String) {

        let sb = UIStoryboard(name: "EventsList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: EventsLsitViewController = sb.instantiateViewController(withIdentifier: "eventslistVC") as! EventsLsitViewController

            ms.__req_list_order = request
            
            ms.config.backHome = false
            ms.config.customToolbar = true

            navigationController?.present(ms, animated: true)
        }

    }


    func startAboutVC() {

        let sb = UIStoryboard(name: "About", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: AboutViewController = sb.instantiateViewController(withIdentifier: "aboutVC") as! AboutViewController

            ms.config.backHome = false
            ms.config.customToolbar = true
            
            navigationController?.present(ms, animated: true)
        }

    }


    func startSettingVC() {

        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if sb.instantiateInitialViewController() != nil {

            let ms: SettingsViewController = sb.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController

            navigationController?.pushViewController(ms, animated: true)
            //navigationController?.present(ms, animated: true)
        }

    }


    func checkUpComingEvents() {

        DispatchQueue.main.asyncAfter(deadline: .now()+4) {

            let upeList = UpComingEvent.getUpComingEventsNotNotified()

            if upeList.count>1{
                //push local notification then remove it

                NotificationManager.push(title: AppConfig.APP_NAME, subtitle: "Upcoming Events soon".localized, identifier: "upcomingevents")


            }else if upeList.count>0{

                NotificationManager.push(title: "Upcoming Event".localized, subtitle: upeList[0].event_name, identifier: "upcomingevents")

            }
        }


    }



    var cloader: CategoryLoader = CategoryLoader()

    func loadCategories () {

        self.cloader.delegate = self

        //Get current Location

        var parameters = [
            "limit"          : "50"
        ]

        parameters["page"] = String(describing: 1)

        self.cloader.load(url: Constances.Api.API_USER_GET_CATEGORY,parameters: parameters)

    }


    func success(parser: CategoryParser,response: String) {

        if parser.success == 1 {

            let categories = parser.parse()

            if categories.count > 0 {
                categories.saveAll()
            }


        }
    }

    func error(error: Error?, response: String) {

    }

    
    
       //notification counter
       func count_notifications(){
           
           if(!Session.isLogged()){
              // return
           }
           
        
           
           let api = SimpleLoader()
           var parameters = [
               "status": "\(0)"
           ]
           
           if(Session.isLogged()){
               if let sess = Session.getInstance(), let user = sess.user{
               
                   parameters["user_id"] = "\(user.id)"
                   
                   if let guest = Guest.getInstance(){
                       parameters["guest_id"] = "\(guest.id)"
                   }
                   
               }
           }else if let guest = Guest.getInstance(){
               parameters["auth_type"] = "guest"
               parameters["auth_id"] = "\(guest.id)"
           }else{
                return
            }
               
           
           
            Utils.printDebug("count_notifications===>parameters===> \(parameters)")
           
           api.run(url: Constances.Api.API_GET_NOTIFICATIONS_COUNT, parameters: parameters) { (parser) in
           
               if(parser?.success == 1){
                   Utils.printDebug("\(parser)")
                   if let count = parser?.result?.intValue{
                        Notification.unread_notifications = count
                       self.updateNotificationBadge(count: count)
                   }
                  
               }
               
           }
           
           
       }
    
          
       
       
        
        func count_messages(){
               
               if(!Session.isLogged()){
                  return
               }
               
            
               let api = SimpleLoader()
               var parameters = [
                   "status": "\(0)"
               ]
               
               guard let sess = Session.getInstance(), let user = sess.user else {return}
               parameters["user_id"] = "\(user.id)"
               
               
               
                Utils.printDebug("count_messages===>parameters===> \(parameters)")
               
               api.run(url: Constances.Api.API_COUNT_UNREAD_MESSAGES, parameters: parameters) { (parser) in
               
                   if(parser?.success == 1){
                       Utils.printDebug("\(parser)")
                    if let count = parser?.result?.intValue{
                        Messenger.nbrMessagesNotSeen = count
                        self.calculNotifications(newCount: count)
                    }
                      
                   }
                   
               }
               
               
           }
      
       func calculNotifications(newCount: Int){
           
           guard let b = self.notificationBarButtonItem else {
               return
           }
           
           let button: BadgeButton = b.customView as! BadgeButton
           self.updateNotificationBadge(count: button.notification+newCount)
       }


}
















