//
//  GeoStoreViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import GoogleMaps
import Cosmos
import RealmSwift
import MapKit

class GeoStoreViewController: MyUIViewController,GMSMapViewDelegate, EmptyLayoutDelegate,ErrorLayoutDelegate,StoreLoaderDelegate, CLLocationManagerDelegate, SearchDialogViewControllerDelegate, ResultListViewControllerDelegate {
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
               ////controller.navigationBar.isHidden = false
           }
       }
       
       override func viewWillAppear(_ animated: Bool) {
           if let controller = self.navigationController, config.customToolbar == true{
               //controller.navigationBar.isHidden = true
           }
       }
       
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D? = nil
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.currentLocation = locValue
        
        Utils.printDebug("\(locations)")
        self.lat = locValue.latitude
        self.lng = locValue.longitude
        
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
                break
            }
        }
        
        
    }
    
    
    func requestLocation() {
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
   
    var latitude: Double? = nil
    var longitude: Double? = nil
    var name: String? = nil
    
    var _req_limit = 30
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var components_container: UIView!
    @IBOutlet weak var components_height_constraint: NSLayoutConstraint!
    
    //store geo map header
    @IBOutlet weak var storeContainer: UIView!
    @IBOutlet weak var storeClose: UIButton!
    @IBOutlet weak var storeRating: UIView!
    @IBOutlet weak var storeName: UILabel!
    
    @IBOutlet weak var find_direction_btn: UIButton!
    @IBOutlet weak var find_direction_icon: UIImageView!
    
    
    @IBAction func find_direction_action(_ sender: Any) {
        
        if let object = lastObject{
           
            let latitude: CLLocationDegrees = object.latitude
            let longitude: CLLocationDegrees = object.longitude
                                                             
            let regionDistance:CLLocationDistance = object.distance
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                                                             
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
                                           
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = object.name
            mapItem.openInMaps(launchOptions: options)
           
        }
        
    }
    //end
    @IBAction func zoomPlus(_ sender: Any) {
        
        if let mapView = self.mapView  {
            
            mapView.animate(toZoom: mapView.camera.zoom+1)
            
        }
        
    }
    
    @IBAction func zoomLess(_ sender: Any) {
        
        if let mapView = self.mapView  {
            
            mapView.animate(toZoom: mapView.camera.zoom-1)
 
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.storeHeader(hidden: true)
        
       self.components_height_constraint.constant = CGFloat(0)
        self.view.layoutIfNeeded()
    }
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: viewContainer)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        if Session.isLogged() ==  false {
            
            return
        }else{
            
        }
    }
    
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles() {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        if let name = self.name, let _ = self.latitude {
             topBarTitle.text = name
        }else{
             topBarTitle.text = "Geo Stores".localized
        }
       
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupNavBarButtons() {
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: Colors.white)
        
        
        if self.latitude == nil && self.longitude == nil{
            
             //setup more icon btn
            let mapIcon = UIImage.init(icon: .ionicons(.androidLocate), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
                    
            let refreshCustomBarButtonItem = UIBarButtonItem(image: mapIcon, style: .plain, target: self, action: #selector(onRefreshHandle))
            refreshCustomBarButtonItem.setIcon(icon: .ionicons(.androidLocate), iconSize: 25, color: Colors.white)
            
            navigationBarItem.rightBarButtonItems?.append(refreshCustomBarButtonItem)
            
        }
        
        
        let searchIcon = UIImage.init(icon: .googleMaterialDesign(.search), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        
        let searchButtonItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action: #selector(handleSearchClick))
        searchButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: Colors.white)
        
        
        
        
    
        
        navigationBarItem.rightBarButtonItems?.append(searchButtonItem)
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
  
    }
    
     @objc func onBackHandler()  {
        if let controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
    }
    
    @objc func onRefreshHandle() {
        load()
    }
    
    func setupGeoHeader()  {
        
        self.storeContainer.isHidden = true
        self.storeRating.addSubview(ratingView)
        self.storeClose.setIcon(icon: .ionicons(.androidClose), iconSize: 24, color: Colors.gray, forState: .normal)
        self.storeName.initBolodFont()
        
        self.storeContainer.backgroundColor = Colors.Appearance.whiteGrey
    }
    
    var mapView: GMSMapView? = nil
    
    var lastObject: Store? = nil
    @objc func onTapStoreHeader()  {
        if let object = lastObject{
           
            //show detail of store
            let sb = UIStoryboard(name: "StoreDetailV2", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                 let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
                ms.storeId = object.id
                
                self.present(ms, animated: true)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //update location
        self.locationManager.delegate = self
        self.requestLocation()
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
        
        
        self.setupNavBarTitles()
        self.setupNavBarButtons()
        self.setupViewloader()
        self.setupGeoHeader()
        
     
        /*self.find_direction_btn.setIcon(prefixText: "", prefixTextColor: Colors.Appearance.primaryColor, icon: .googleMaterialDesign(.directions), iconColor: Colors.Appearance.primaryColor, postfixText: " \("Find direction".localized)", postfixTextColor: Colors.Appearance.primaryColor, forState: .normal, textSize: 20, iconSize: 20)*/
        
        
        find_direction_icon.setIcon(icon: .googleMaterialDesign(.directions), textColor: Colors.Appearance.primaryColor, backgroundColor: .clear, size: CGSize(width: 25,height: 25))
        
        self.find_direction_btn.initItalicFont()
        self.find_direction_btn.setTitleColor(Colors.Appearance.primaryColor, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapStoreHeader))
        self.storeContainer.addGestureRecognizer(tap)
        
        
        if let guest = Guest.getInstance() {
            
            let camera = GMSCameraPosition.camera(withLatitude: guest.lat, longitude: guest.lng, zoom: 6.0)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), camera: camera)
            
            mapView?.delegate = self
            
            if let mapView = self.mapView  {
                
                mapView.animate(toZoom: 16)
                viewContainer.addSubview(mapView)
                
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude:  guest.lat, longitude: guest.lng)
                marker.map = mapView
                
                
            }

            
            self.load()
            
        }else if let lat = self.latitude, let lng = self.longitude{
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 6.0)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), camera: camera)
            
            mapView?.delegate = self
            
            if let mapView = self.mapView  {
                
                mapView.animate(toZoom: 17)
                viewContainer.addSubview(mapView)
                
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude:  lat, longitude: lng)
                marker.map = mapView
                
            }
            
        }
        
        
        self.__req_default_tz = TimeZone.current.abbreviation()!
        self.__req_current_date = DateUtils.getCurrent(format: DateFomats.defaultFormatUTC)
        
    }
    
    
    
    
    func storeHeader(hidden: Bool) {
        
        if hidden {
            let animation = UIAnimation(view: self.storeContainer)
            animation.zoomOut()
        }else{
            let animation = UIAnimation(view: self.storeContainer)
            animation.zoomIn()
        }
       
    }
    
    func onReloadAction(action: ErrorLayout) {
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
    }

    
    let ratingView: CosmosView = {
        
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = " 0 (0)"
        cosmosView.settings.textColor = Colors.Appearance.black
        cosmosView.settings.updateOnTouch = false
        
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 12) {
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
    
    
    
    ///API
    
    //API
    
    var storeLoader: StoreLoader = StoreLoader()
    var LIST: [Store] = [Store]()
    
    
    var lat = 0.0
    var lng = 0.0
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        lat = position.target.latitude
        lng = position.target.longitude
    }
    
    
    
    func load () {
        
        MyProgress.show(parent: self.view)
        
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "\(self._req_limit)"
        ]
        
        parameters["category_id"] = String(__req_category)
        parameters["current_date"] = String(__req_current_date)
        parameters["current_tz"] = String(__req_default_tz)
        parameters["opening_time"] = String(__req_opening_time)
        parameters["order_by"] = __req_order_by
        
        if let guest = Guest.getInstance() {
            
            if self.LIST.count>0{
                parameters["latitude"] = String(lat)
                parameters["longitude"] = String(lng)
            }else{
                parameters["latitude"] = String(guest.lat)
                parameters["longitude"] = String(guest.lng)
            }
        
        }
        
        
        if __req_loc{
            parameters["order_by"] = StoresListRequestOrder.nearby
            parameters["latitude"] = String(__req_loc_latitude)
            parameters["longitude"] = String(__req_loc_longitude)
        }else{
            parameters["order_by"] = __req_order_by
        }
        
        if __req_redius > 0 && __req_redius < AppConfig.distanceMaxValue {
                   
            if(AppConfig.distanceUnit ==  Distance.Types.Kilometers){
                parameters["radius"] = String( (__req_redius*1000) ) //radius by km (merters)s
            }else{
                parameters["radius"] = String( (__req_redius*1609) ) //radius by miles (meters)
            }
                   
        }
        
        Utils.printDebug("\(parameters)")
        
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        
        if(marker.iconView != nil ){
            let view: CustomViewStoreMarker = marker.iconView as! CustomViewStoreMarker
            if let object = view.object {
                
                object.save()
                
                self.lastObject = object
                storeName.text = object.name
                
                
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                formatter.minimumIntegerDigits = 1
                          
                let number = NSNumber(value: object.votes)
                          
                          
                if let value = formatter.string(from: number){
                    self.ratingView.text = "\(value) (\(object.nbr_votes)) "
                }else{
                    self.ratingView.text = "\(object.votes) (\(object.nbr_votes)) "
                }
                
                self.ratingView.rating = object.votes
                
                self.storeHeader(hidden: false)
                
                if object.nbrOffers > 0{
                    self.load_component_recent_offers(store: object)
                }
               
                let camera = GMSCameraPosition.camera(withLatitude: object.latitude, longitude: object.longitude, zoom: 16)
                // self.mapView?.camera = camera
                self.mapView?.animate(to: camera)
                
            }
        }
        
       
        return true
    }
    
    var onSeachFeature = false
    
     func success(parser: StoreParser,response: String) {
           
           
          MyProgress.dismiss()
         
           if parser.success == 1 {
               
               
               let stores = parser.parse()
               
             
               if stores.count > 0 {
                   
                   Utils.printDebug("We loaded \(stores.count)")
               
                    self.LIST = stores
                   
                   if stores.count > 0 {
                    
                       mapView?.clear()
                       
                       if let guest = Guest.getInstance(), let mapView = self.mapView {
                           // Creates a marker in the center of the map.
                           let marker = GMSMarker()
                           marker.position = CLLocationCoordinate2D(latitude:  guest.lat, longitude: guest.lng)
                           marker.map = mapView
                       
                           if onSeachFeature{
                            
                            var lt = 0.0
                            var lg = 0.0
                            
                            if __req_loc && __req_loc_latitude != 0 && __req_loc_longitude != 0{
                                lt = __req_loc_latitude
                                lg = __req_loc_longitude
                            }else{
                                lt = stores[0].latitude
                                lg = stores[0].longitude
                            }
                               
                                //move camera
                                let camera = GMSCameraPosition.camera(withLatitude: lt, longitude: lg, zoom: 15)
                                self.mapView?.camera = camera
                                self.mapView?.animate(to: camera)
                               
                           }else{
                               //move camera
                               let camera = GMSCameraPosition.camera(withLatitude: guest.lat, longitude: guest.lng, zoom: 15)
                               // self.mapView?.camera = camera
                               self.mapView?.animate(to: camera)
                           }
                       }
                   }
                   
                   if let mapView = self.mapView {
                   
                       for store in self.LIST{
                           
                           let marker = GMSMarker()
                           marker.position = CLLocationCoordinate2D(latitude:  store.latitude, longitude: store.longitude)
                           marker.map = mapView
                           
                          
                           let icon = CustomViewStoreMarker()
                           icon.object = store
                           icon.setup(marker: marker)

                           marker.iconView = icon
                           
                       }
                       
                   }
                
               }else{
                   
                   if self.LIST.count == 0 {
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
           
           
           onSeachFeature = false
           
       }
    
    func error(error: Error?, response: String) {
        MyProgress.dismiss()
        viewManager.showAsError()
    }
    
    
    var mOffers_HCards_instance:Offers_HCards?=nil
    
    func load_component_recent_offers(store: Store)  {
        
        let style = CardHorizontalStyle(width: 280, height: 240, type: .Recent_Offers,title: AppConfig.CardTags.TAG_RECENT_OFFERS)
        
        if let instance = mOffers_HCards_instance{
            
            instance.__req_store = store.id
            instance.load()
            
            UIView.animate(withDuration: 0.2, delay: 1.0, options: .curveEaseOut, animations: {
               self.components_height_constraint.constant = CGFloat(style.height!)
               self.view.layoutIfNeeded()
            }, completion: { finished in
              
            })
            
            return
        }
        
        
        mOffers_HCards_instance = (Offers_HCards.newInstance(style: style) as! Offers_HCards)
        mOffers_HCards_instance!.h_label.text = AppConfig.CardTags.TAG_RECENT_OFFERS.localized
        mOffers_HCards_instance!.viewTabBarController = self.tabBarController
        mOffers_HCards_instance!.__req_store = store.id
        mOffers_HCards_instance!.load()
                           
        if let title = style.Title{
            mOffers_HCards_instance!.h_label.text = title.localized
        }
        
        
        if let controller = self.navigationController{
            mOffers_HCards_instance!.viewNavigationController = controller
        }else{
            mOffers_HCards_instance!.viewNavigationController = self.tabBarController?.navigationController
        }
            
    
        
        components_container.addSubview(mOffers_HCards_instance!)
        components_container.addConstraintsWithFormat(format: "H:|[v0]|", views: mOffers_HCards_instance!)
        components_container.addConstraintsWithFormat(format: "V:|[v0]|", views: mOffers_HCards_instance!)
               
      
        
        UIView.animate(withDuration: 0.2, delay: 1.0, options: .curveEaseOut, animations: {
            self.components_height_constraint.constant = CGFloat(style.height!)
            self.view.layoutIfNeeded()
         }, completion: { finished in
           
         })
                           
    }
    
    
    
    
    /*
     * FILTER & SEARCH FEATURE SETUP
     */
    
    var filterCache: SearchDialogViewController.FilterCache? = nil
     
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
                 searchDialog.module_checkbox = false
                 searchDialog.setup(type: type, view: _view)
                 searchDialog.delegate = self
                 
                 if let cache = filterCache{
                     searchDialog.filterCache = cache
                 }
                 
                 //tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                 //tabBarController?.present(searchDialog, animated: true, completion: nil)
                searchDialog.modalPresentationStyle = .fullScreen
                self.present(searchDialog, animated: true)
             }
         }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
             
             let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
             if let vc = sb.instantiateInitialViewController() {
                 let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
                 
                   
                 let _view = UIView.loadFromNib(name: "OfferSearch")
                 searchDialog.module_checkbox = false
                 searchDialog.setup(type: type, view: _view)
                 searchDialog.delegate = self
                
                 
                 if let cache = filterCache{
                     searchDialog.filterCache = cache
                 }
                 
                // tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                 //tabBarController?.present(searchDialog, animated: true, completion: nil)
                searchDialog.modalPresentationStyle = .fullScreen
                self.present(searchDialog, animated: true)
             }
             
         }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
             
             let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
             if let vc = sb.instantiateInitialViewController() {
                 let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
                 
                 let _view = UIView.loadFromNib(name: "EventSearch")
                 searchDialog.module_checkbox = false
                 searchDialog.setup(type: type, view: _view)
                 searchDialog.delegate = self
                 
                 if let cache = filterCache{
                     searchDialog.filterCache = cache
                 }
                 
                 //tabBarController?.navigationController?.pushViewController(searchDialog, animated: true)
                 //tabBarController!.present(searchDialog, animated: true, completion: nil)
                searchDialog.modalPresentationStyle = .fullScreen
                self.present(searchDialog, animated: true)
             }
         }
         
         
     }
     
    
     
     func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
         
         
         filterCache = SearchDialogViewController.FilterCache()

         filterCache?._type = type
         filterCache?._view = view
         
        let sb = UIStoryboard(name: "ResultList", bundle: nil)
        let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
              
        
         if type == AppConfig.Tabs.Tags.TAG_STORES{
             
            
            //close search dialog
             controller.onBackHandler()
                        
            var parameters = ms.getParameters(type: type, instance: view)
            
         
             //Sort parameters DATE - GEO
             if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                 && SearchDialogViewController.listing_custom_location_enabled){
                 
  
                 parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                 parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                 parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                 
                
             }else{
                
                 parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.recent
                
             }
             
             
            
             reload_with_parameters(parameters: parameters)
        
            
         }else if type == AppConfig.Tabs.Tags.TAG_OFFERS{
             
            
            var parameters = ms.getParameters(type: type, instance: view)
                     
            
             //close search dialog
             controller.onBackHandler()
            
             
             //Sort parameters DATE - GEO
             if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                            && SearchDialogViewController.listing_custom_location_enabled){
                  
                 parameters["__req_order"] = ListStoresCell.StoresListRequestOrder.nearby
                 parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                 parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                    
                //self.latitude
             }else{

                 parameters["__req_order"] = ListOfferCell.OffersListRequestOrder.recent
                           
             }
                        
            reload_with_parameters(parameters: parameters)
          
             
         }else if type == AppConfig.Tabs.Tags.TAG_EVENTS{
             
         
             //let myView = view as! EventSearch
             
             var parameters = ms.getParameters(type: type, instance: view)
          
             
             //close search dialog
             controller.onBackHandler()
           
             
             //Sort parameters DATE - GEO
             if(SearchDialogViewController.selected_sort_type == SearchDialogViewController.SORT_RADIOBOW_KEY_GEO
                            && SearchDialogViewController.listing_custom_location_enabled){
                            
                 parameters["__req_order"] = ListEventCell.EventsListRequestOrder.nearby
                 parameters["__req_loc_latitude"] = "\(SearchDialogViewController.listing_custom_location_latitude)"
                 parameters["__req_loc_longitude"] = "\(SearchDialogViewController.listing_custom_location_longitude)"
                            
             }else{
                           
                 parameters["__req_order"] = ListEventCell.EventsListRequestOrder.recent
                          
             }
            
           
            reload_with_parameters(parameters: parameters)
           
         }
         
        
       
     }
    
    
    func reload_with_parameters(parameters: [String: String] ) {
       
        Utils.printDebug("parameters => \(parameters)")
        
        if let __req_redius = parameters["__req_redius"]{
            self.__req_redius = Int(__req_redius)!
        }
        
        if let __req_list_order = parameters["__req_list_order"]{
            self.__req_list_order = __req_list_order
        }
        
        if let __req_category = parameters["__req_category"]{
            self.__req_category = Int(__req_category)!
        }
        
        if let __req_opening_time = parameters["__req_opening_time"]{
            self.__req_opening_time = Int(__req_opening_time)!
        }
        
        if let __req_loc_latitude = parameters["__req_loc_latitude"]{
            self.__req_loc_latitude = Double(__req_loc_latitude)!
        }
        
        if let __req_loc_longitude = parameters["__req_loc_longitude"]{
            self.__req_loc_longitude = Double(__req_loc_longitude)!
        }
        
        if let __req_order = parameters["__req_order"], __req_order == ListStoresCell.StoresListRequestOrder.nearby{
            __req_order_by = ListEventCell.EventsListRequestOrder.nearby
            __req_loc = true
        }else if let __req_order = parameters["__req_order"], __req_order == ListStoresCell.StoresListRequestOrder.recent{
             __req_order_by = ListEventCell.EventsListRequestOrder.recent
            __req_loc = true
        }else{
            __req_loc = false
        }
        
        
        onSeachFeature = true
                      
        //re-load
        load()
    }
     
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = StoresListRequestOrder.nearby
    var __req_search: String = ""
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0

    var __req_loc_latitude: Double = 0
    var __req_loc_longitude: Double = 0
    var __req_loc: Bool = false
    
    
    var __req_order_by: String = StoresListRequestOrder.nearby
    
     
     func onSearchButtonPressed(controller: ResultListViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController) {
     
         controller.dismiss(animated: true) {
             self.onSearch(type: type, view: view, controller: search_dialog_controller)
             // self.view.isHidden = false
         }
         
     }
     
     
     func onSearchResultBackPressed(controller: ResultListViewController, filterCache: SearchDialogViewController.FilterCache) {
         
         self.filterCache = filterCache
         
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
