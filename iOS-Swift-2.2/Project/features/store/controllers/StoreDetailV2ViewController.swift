//
//  StoreDetailV2ViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/2/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import Kingfisher
import Atributika
import ImageSlideshow
import AssistantKit
import GoogleMobileAds
import SwiftWebVC
import RealmSwift
import MapKit
import SkeletonView

class StoreDetailV2ViewController: MyUIViewController, ErrorLayoutDelegate, EmptyLayoutDelegate,GMSMapViewDelegate, RateDialogViewControllerDelegate, StoreLoaderDelegate,UIScrollViewDelegate,GADBannerViewDelegate, UITextViewDelegate, Offers_HCards_Delegate, Gallery_HCards_Delegate, LoginControllerDelegate  {
    
    let request_login_chat_id = 1002
    let request_login_add_bookmarks_id = 1003
    
    func loginSuccess(controller: LoginViewController, user: User) {
        
         if request_login_chat_id == controller.request{
            
            if let store = store{
                startMessenger(client_id: store.user_id)
            }
            
         }else if request_login_add_bookmarks_id == controller.request{
            
            if let store = self.store, store.saved{
                 unsaveAction()
            }else{
                saveAction()
            }
            
        }
        
        controller.onBackHandler()
    }
    
    func loginFaild(controller: LoginViewController) {
        controller.onBackHandler()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
    }
    
    
    @IBOutlet weak var stackViewStoreDetailHorizontal: UIStackView!
    @IBOutlet weak var stackViewSDHStart: UIStackView!
    @IBOutlet weak var stackViewSDHMiddle: UIStackView!
    @IBOutlet weak var stackViewSDHEnd: UIStackView!
    
    
    @IBOutlet weak var item_container: UIView!
    @IBOutlet weak var gallery_container: UIView!
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adContainer.isHidden = false
        if AppConfig.DEBUG {
            print("adViewDidReceiveAd")
        }
    }
    
    private var store: Store? = nil
    let slideShow = ImageSlideshow()
    
    @IBOutlet weak var mainView: UIView!
    
    //adview
    @IBOutlet weak var adSubContainer: UIView!
    @IBOutlet weak var adConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var adContainer: UIView!
    
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftConstraint: NSLayoutConstraint!
    
    func setupSize()  {
        if Device.isPad{
            let width = self.view.frame.width/1.5
            let finalSize = self.view.frame.width-width
            self.stackViewLeftConstraint.constant = finalSize/2
            self.stackViewRightConstraint.constant = finalSize/2
        }
    }
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var category_badge: EdgeLabel!
    

    func onCategoryAction() {
        
        if let id = self.storeId, let store = Store.findById(id: id){
            
            let sb = UIStoryboard(name: "StoresList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoresLsitViewController = sb.instantiateViewController(withIdentifier: "storeslistVC") as! StoresLsitViewController
                
                ms.request = ListStoresCell.StoresListRequestOrder.nearby
                ms.category_id = store.category_id
                
                self.present(ms, animated: true)
                
            }
        }
        
    }
    
    
    
    
    //image container
    @IBOutlet weak var hb_left_label: UILabel!
    @IBOutlet weak var hb_rating_detail: UILabel!

    @IBOutlet weak var hb_center_label: UILabel!
    @IBOutlet weak var hb_center_detail: UILabel!
    
    @IBOutlet weak var hb_right_label: UILabel!
    @IBOutlet weak var hb_right_detail: UILabel!
    
    @IBOutlet weak var open_store_badge: EdgeLabel!
    
    /*
     * STORE DETAIL
     */
   
    
    @IBOutlet weak var opening_time_sub_container: EXUIView!
    @IBOutlet weak var opening_time_container: UIStackView!
    @IBOutlet weak var opening_time_label: UILabel!
    @IBOutlet weak var opening_time_text_view: UITextView!
 

    @IBOutlet weak var featured: EdgeLabel!
    
    @IBOutlet weak var mapsContainer: UIView!
    @IBOutlet weak var mapsSubContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
 
    @IBOutlet weak var scrollView: UIScrollView!
    
    //
    @IBOutlet weak var storeDetailContainer: UIView! //view store
    @IBOutlet weak var storeDetailSubContainer: EXUIView! //subview store
    @IBOutlet weak var descriptionTextView: UITextView!

    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var title_label: UILabel!

    @IBOutlet weak var imageContainerHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var btnsContainer: UIView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBAction func chatAction(_ sender: Any) {
        
        if let store = self.store {
            
            if Session.isLogged(){
                startMessenger(client_id: store.user_id)
            }else{
                
                
                let sb = UIStoryboard(name: "Login", bundle: nil)
                let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                
                ms.config.backHome = true
                ms.config.customToolbar = true
                
                ms.delegate = self
                ms.request = request_login_chat_id
                
                if #available(iOS 13, *){
                        ms.config.backHome = false
                     self.present(ms, animated: true)
                }else{
                    if let controller = navigationController{
                        controller.pushViewController(ms, animated: true)
                    }else{
                        self.present(ms, animated: true)
                    }
                }
    
                
            }
            
        }
    }
    
    
    
    @IBAction func callAction(_ sender: Any) {
        
        if let store = self.store {
            
            Utils.printDebug("Phone: \(store.phone)")
            
            let phone_number = store.phone.phoneFormat()
            let result = phone_number.isValid(regex: .phone)
            
            if result{
                if let url = URL(string: "tel://\(phone_number)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }else{
                    
                    let message: [String:String] = ["alert":"This app is not allowed to query for scheme tel".localized]
                    self.showAlertError(title: "Alert!".localized, content: message, msgBnt: "OK".localized)
                    
                }
            }else{
                
                let message: [String:String] = ["alert":"This app is not allowed to query for scheme tel or Phone number is not valid".localized]
                self.showAlertError(title: "Alert!".localized, content: message, msgBnt: "OK".localized)
                
            }
            
            
        }
        
    }
    
   //
    
    @IBAction func shareAction(_ sender: Any) {
        
        if let id = storeId, let store = Store.findById(id: id) {
            
            _ = store.latitude
            _ = store.longitude
            //_ = "https://maps.google.com/?ll=\(lat),\(lng)"
            
            let text = "%@ - Only on %@ \n %@".localized.format(arguments: store.name,AppConfig.APP_NAME,store.link)
        
            //%@ - Only on %@ \n %@
            
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
        }
        
    }
    
    func saveAction() {
        
        
        if let user = Session.getInstance()?.user, let store = self.storeId{
            
            
            if let _ = self.store{
                let realm = try! Realm()
                realm.beginWrite()
                self.store?.saved = true
                try! realm.commitWrite()
            }
            
            
            let parameters = [
                "user_id": String(user.id),
                "store_id": String(store),
            ]
            
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_SAVE_STORE, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                    if let id = parser?.result?.intValue{
                        //popup
                        self.notify_me(bookmark_id: id)
                    }
                    
                    if let _ = self.storeId, let _ = self.store {
                        
                        let realm = try! Realm()
                        realm.beginWrite()
                        self.store?.saved = true
                        realm.add(self.store!, update: .all)
                        try! realm.commitWrite()
                        
                    }
                    
                   
                }else{
                   
                }
            }
            
        }else{
            
            if let _ = self.store{
                
            }
            
        }
        
        updateNavBarButtons()
        
    }
    
 
    func unsaveAction() {
        
        
        if let user = Session.getInstance()?.user, let store = self.storeId{
            
            if let _ = self.store{
                let realm = try! Realm()
                realm.beginWrite()
                self.store?.saved = false
                try! realm.commitWrite()
            }
            
            let parameters = [
                "user_id": String(user.id),
                "store_id": String(store),
            ]
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_REMOVE_STORE, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                     if let _ = self.storeId, let _ = self.store {
                                           
                        let realm = try! Realm()
                        realm.beginWrite()
                        self.store?.saved = false
                        realm.add(self.store!, update: .all)
                        try! realm.commitWrite()
                                           
                    }
                    
                }
                
                
                
            }
            
        }else{
            
            if let store = self.storeId{
                
                
            }
       
        }

        self.updateNavBarButtons()
       
    }
    
    
    func notify_me(bookmark_id: Int) {
        
        //
        if !ExtendedConfig.notify_me_ask{
            return
        }
        
        guard let user = Session.getInstance()?.user else {
            return
        }
        
        let alert = UIAlertController(title: "Do you would receive notifications?".localized, message: "By clicking on on Notify me, you will receive notifications from this business".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Notify me".localized, style: .default, handler: { action in
            
            let parameters = [
                "user_id": String(user.id),
                "bookmark_id": String(bookmark_id),
                "agreement": "1",
            ]
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_NOTIFICATION_AGGREMENT, parameters: parameters) { (parser) in
                
               
                if parser?.success==1{
                    
                }else{
                    
                }
            }
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
    
        
        alert.addAction(UIAlertAction(title: "No, Thanks".localized, style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)
        
    }
 
    
    
    var storeId: Int? = nil
    
    private var lastContentOffset: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
          
            //featured.alpha = CGFloat(alpha)
           
            title_label.alpha = CGFloat(alpha)
            storeAddress.alpha = CGFloat(alpha)
            
            
        }else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
             let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
           
            //featured.alpha = CGFloat(alpha)
           
            title_label.alpha = CGFloat(alpha)
            storeAddress.alpha = CGFloat(alpha)
            
        }
        
       
        //back
        /*if(y>view.frame.height){
            
            if let controller = self.navigationController{
                let transition = CATransition()
                transition.duration = 0.4
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromBottom
                controller.view.layer.add(transition, forKey: kCATransition)
                controller.popViewController(animated: false)
            }
           
        }*/
       
        
        if scrollView.contentOffset.y > -100{
            
            navigationBar.isTranslucent = false
            navigationBarItem.titleView?.isHidden = false
           
            UIView.animate(withDuration: 0.2) {
                self.navigationBar.layoutIfNeeded()
            }
            
            
        }else{
            
            //make it transeparent
            navigationBar.isTranslucent = true
            navigationBarItem.titleView?.isHidden = true

            UIView.animate(withDuration: 0.2) {
                self.navigationBar.layoutIfNeeded()
            }
             
            
        }
        
        
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: mainView)
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
    
    func setupCustomNavBar(title: String) {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)

        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        topBarTitle.text = title
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupNavBarButtons() {
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        

        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)

        let customBackButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBackButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        
       
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        if(config.backHome){
            navigationBarItem.leftBarButtonItems?.append(customBackButtonItem)
        }
        
        
    }
    
    
    func updateNavBarButtons() {
        
        navigationBarItem.rightBarButtonItems = []
     
        //navigationBarItem.rightBarButtonItems?.append(rateCustomBarButtonItem)
        
        
        if let store = self.store, !store.saved{
            
            let bookmarkIcon = UIImage.init(icon: .googleMaterialDesign(.bookmarkBorder), size: CGSize(width: 32, height: 32), textColor: Colors.Appearance.darkColor)
            let bookmarkCustomBarButtonItem = UIBarButtonItem(image: bookmarkIcon, style: .plain, target: self, action: #selector(onAddBookmarkhHandle))
            
            navigationBarItem.rightBarButtonItems?.append(bookmarkCustomBarButtonItem)
            
        }else{
            
            let bookmarkIcon = UIImage.init(icon: .googleMaterialDesign(.bookmark), size: CGSize(width: 32, height: 32), textColor: Colors.Appearance.darkColor)
            let bookmarkCustomBarButtonItem = UIBarButtonItem(image: bookmarkIcon, style: .plain, target: self, action: #selector(onAddBookmarkhHandle))
            
            navigationBarItem.rightBarButtonItems?.append(bookmarkCustomBarButtonItem)
            
        }
        
    }
    
    
    
    func onOffersLoaded(count: Int) {
        
        if count == 0{
            
            self.item_container.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }else{
            
            self.item_container.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
    
    
    func onGalleryloaded(count: Int) {
        
        
        if count == 0{
            
            self.gallery_container.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }else{
            
            self.gallery_container.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        }
        
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
    
    
    @objc func onAddBookmarkhHandle() {
        
        
        if !Session.isLogged(){
            
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            ms.delegate = self
            
            if #available(iOS 13, *){
                ms.config.backHome = false
                self.present(ms, animated: true)
            }else{
                if let controller = navigationController{
                    controller.pushViewController(ms, animated: true)
                }else{
                    self.present(ms, animated: true)
                }
            }
            
            return
            
        }
        
        if let store = self.store, store.saved{
             unsaveAction()
        }else{
             saveAction()
        }
        
        
    }
    
    @objc func onRatehHandle() {
       
        
        let sb = UIStoryboard(name: "RateDialog", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            let rateDialog: RateDialogViewController = vc as! RateDialogViewController

            rateDialog.store_id = storeId
            rateDialog.delegate = self
        
            self.present(rateDialog, animated: true, completion: nil)
        }
        
    }
    
    func onRate(rating: Double, review: String) {
        //add review
        
        let message: [String: String] = ["alert": "Thank for your review!".localized]
        self.showAlertError(title: "Alert",content: message,msgBnt: "OK")
        
    }
    

    var mapView: GMSMapView? = nil
    
    
    func setupGoogleMaps(lat:Double,lng:Double) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        
        let width = self.mapsSubContainer.frame.width
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: self.mapsSubContainer.frame.height), camera: camera)
        
    

        mapView?.delegate = self
        mapView?.settings.setAllGesturesEnabled(false)
        
        if let mapView = self.mapView  {
            
            
            self.mapsSubContainer.addSubview(mapView)
            
            
            Utils.printDebug("mapView \(mapView.frame)")
            Utils.printDebug("mapsContainer \(mapsSubContainer.frame)")
            
            mapView.backgroundColor = UIColor.yellow
            
            mapView.animate(toZoom: 14)
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:  lat, longitude: lng)
            marker.map = mapView
            
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
            self.mapView?.camera = camera
            self.mapView?.animate(to: camera)
            
            
            self.mapView?.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                
                
                let frame = self.mapsContainer.bounds
                self.mapView?.frame = frame
                self.mapView?.bounds = self.mapsContainer.bounds
                self.view.layoutIfNeeded()
                
                
                self.mapView?.isHidden = false
                
                Utils.printDebug("bounds: \(self.mapsContainer.bounds)")

            }
            
           
           
            
        }
        
    }
    
    
    //Admob Configure & Setup
    var bannerView: GADBannerView!
    func adSetup(_ bannerView: GADBannerView) {
        
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.adSubContainer.addSubview(bannerView)
        self.adSubContainer.addConstraints(
            [
             NSLayoutConstraint(item: self.bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.adSubContainer,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: self.bannerView,
                                attribute: .centerY,
                                relatedBy: .equal,
                                toItem: self.adSubContainer,
                                attribute: .centerY,
                                multiplier: 1,
                                constant: 0),
             ])
        
        self.bannerView.adUnitID = AppConfig.Ads.AD_BANNER_ID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        self.adConstraintHeight.constant = bannerView.frame.height+20
        
        self.bannerView.delegate = self
        self.adContainer.isHidden = true
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageContainerHeightConstraint.constant = view.frame.height-20
        self.view.layoutIfNeeded()
        
        self.setupSize()
        
         StoreDetailV2ViewController.mInstance = self
        
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        
        if config.customToolbar == true{
            self.setupCustomNavBar(title: "Store detail".localized)
            self.setupNavBarButtons()
        }else{
            self.navigationBar.isHidden = true
        }

        
        self.setupViewloader()
        self.setupViews()
        
        

        if let id = storeId, let _ = Store.findById(id: id){
            self.setupStoreDetail()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_STORE_DETAIL_ENABLED){
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            adSetup(bannerView)
        }else{
            self.adContainer.isHidden = true
        }
        
        
        if AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.ADS_INTERSTITIEL_ENABLED{
            interstitial = GADInterstitial(adUnitID: AppConfig.Ads.AD_INTERSTITIEL_ID)
            let request = GADRequest()
            interstitial.load(request)
        }
        
    }
    
    private static var ad_seen = 0
    var interstitial: GADInterstitial!
    
    func showInterstitial()  {
        if interstitial.isReady &&   StoreDetailV2ViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            StoreDetailV2ViewController.ad_seen += 1
        }
    }
    
    func setupHeaderIcons() {
        
        //rating detail
        self.hb_left_label.initBolodFont(size: 18)
        self.hb_left_label.textColor = .white
        self.hb_rating_detail.initDefaultFont(size: 14)
        self.hb_rating_detail.textColor = .white
        
        //average detail
        self.hb_center_label.initBolodFont(size: 18)
        self.hb_center_label.textColor = .white
        self.hb_center_detail.initDefaultFont(size: 14)
        self.hb_center_detail.textColor = .white
        
        
        //photos detail
        self.hb_right_label.initBolodFont(size: 18)
        self.hb_right_label.textColor = .white
        self.hb_right_detail.initDefaultFont(size: 14)
        self.hb_right_detail.textColor = .white
        
      
        //register gesture reconizer for gallery
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnRating))
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnRating))
        
        hb_left_label.addGestureRecognizer(gestureRecognizer1)
        hb_left_label.isUserInteractionEnabled = true
        
        hb_rating_detail.addGestureRecognizer(gestureRecognizer2)
        hb_rating_detail.isUserInteractionEnabled = true
        
        
    }
 
    @objc func didTapOnRating() {
        
        if let store = self.store{
            startReviewsLsit(store_id: store.id)
        }
        
    }
    
    
    func setupBottomLargeIcons(){
        
    /*
        //let featuredIcon = UIImage.init(icon:  .ionicons(.clock), size: CGSize(width: 18, height: 18), textColor: Colors.green)
        
        featured.leftTextInset = 15
        featured.rightTextInset = 15
        featured.topTextInset = 10
        featured.bottomTextInset = 10
        featured.textColor = Colors.featuredTagColor
        featured.isHidden = true
        featured.initBolodFont(size: 12)
        //featured.addLeftBorderWithColor(color: UIColor.lightGray.withAlphaComponent(0.3), width: 0.8)
        */
     
       
    }
    
    @objc func didTapIOnGallery() {
       
        if let store = self.store, store.gallery > 0{
            self.startGalleryLsit(store_id: store.id)
        }
        
    }
    
    func setupButtonsAction() {
        
        
        self.chatBtn.setIcon(icon: .ionicons(.chatbubbles), iconSize: 20, color: .white, forState: .normal)
        self.callBtn.setIcon(icon: .ionicons(.androidCall), iconSize: 20, color: .white, forState: .normal)
        self.shareBtn.setIcon(icon: .openIconic(.share), iconSize: 20, color: .white, forState: .normal)
        
        
        self.chatBtn.backgroundColor = Colors.Appearance.primaryColor
        self.callBtn.backgroundColor = Colors.Appearance.primaryColor
        self.shareBtn.backgroundColor = Colors.Appearance.primaryColor
        
        
        self.chatBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.chatBtn.layer.masksToBounds = true
        
        self.callBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.callBtn.layer.masksToBounds = true
        
        self.shareBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.shareBtn.layer.masksToBounds = true
        
        
    }
    
    func setupViews() {
        
        setupBottomLargeIcons()
        setupHeaderIcons()
        setupButtonsAction()
        
        
        self.scrollView.delegate = self

        self.view.backgroundColor = Colors.Appearance.darkColor
        
        self.stackView.distribution = .fillProportionally
        

        scrollView.parallaxHeader.view = self.imageContainer
        
        if Device.isNotched {
             scrollView.parallaxHeader.height = self.imageView.frame.height-24;
         }else{
             scrollView.parallaxHeader.height = self.imageView.frame.height;
        }
       
        scrollView.parallaxHeader.mode = .fill;
        scrollView.parallaxHeader.minimumHeight = 0;
       
      
        self.storeDetailSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.storeDetailSubContainer.layer.masksToBounds = true
        
    

        self.btnsContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.btnsContainer.layer.masksToBounds = true
    
     
      
        
        self.slideShow.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutConstraint.Attribute.right,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.imageView,
            attribute: NSLayoutConstraint.Attribute.right,
            multiplier: 1, constant: 0)
        )

        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.imageView,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1, constant: 0)
        )

        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.imageView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1, constant: 0)
        )

        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutConstraint.Attribute.left,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.imageView,
            attribute: NSLayoutConstraint.Attribute.left,
            multiplier: 1, constant: 0)
        )
        
       
        self.imageView.addSubview(slideShow)
        self.imageView.addConstraints(constraints)
        //self.imageView.layoutIfNeeded()
        //self.slideShow.isHidden = true
        
        self.slideShow.pageIndicator = nil
        self.slideShow.contentScaleMode = .scaleAspectFill
        
        let gestureRecognizerImageView = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage))
        self.stackViewSDHEnd.addGestureRecognizer(gestureRecognizerImageView)
        
        
        let gestureRecognizerGeoMap = UITapGestureRecognizer(target: self, action: #selector(didTapOnGeoMaps))
        self.mapsContainer.addGestureRecognizer(gestureRecognizerGeoMap)
        
        
        //localization
        self.featured.text = "Featured".localized
        self.detailLabel.text = "Store Detail".localized
      
        
        
        
        self.detailLabel.initBolodFont()
        
        self.title_label.initBolodFont(size: 22)
        self.title_label.textColor = .white
        
        self.storeAddress.initDefaultFont(size: 16)
        self.storeAddress.textColor = .white
        

        self.opening_time_label.text = "Opening time".localized
        self.opening_time_label.initBolodFont()
        self.opening_time_container.isHidden = true
        
    
      
        
        self.imageContainerHeightConstraint.constant = 600
        self.view.layoutIfNeeded()
        
        
        self.category_badge.layer.cornerRadius = self.category_badge.frame.height/3
        self.category_badge.layer.masksToBounds = true
        self.category_badge.backgroundColor = .orange
        self.category_badge.leftTextInset = 10
        self.category_badge.rightTextInset = 10
        //text color & font
        self.category_badge.textColor = .white
        self.category_badge.textAlignment = .center
        self.category_badge.initBolodFont(size: 14)
        
        
        
        
        self.open_store_badge.layer.cornerRadius = self.category_badge.frame.height/3
        self.open_store_badge.layer.masksToBounds = true
        self.open_store_badge.backgroundColor = .orange
        self.open_store_badge.leftTextInset = 8
        self.open_store_badge.rightTextInset = 8
        //text color & font
        self.open_store_badge.textColor = .white
        self.open_store_badge.textAlignment = .center
        self.open_store_badge.initBolodFont(size: 12)
        
        
        
        let color = UIColor.white.withAlphaComponent(0.35)
        self.stackViewSDHStart.addRightBorderWithColor(color: color, width: 0.8)
        self.stackViewSDHMiddle.addRightBorderWithColor(color: color, width: 0.8)
       
        
        self.hb_center_label.text = "".localized
        self.hb_right_label.text = "Photo(s)".localized
        
        
        self.storeDetailSubContainer.backgroundColor = Colors.Appearance.whiteGrey
        self.opening_time_sub_container.backgroundColor = Colors.Appearance.whiteGrey

    }
    
    @objc func didTapOnImage() {
        if #available(iOS 13.0, *){
            self.slideShow.presentFullScreenControllerForIos13(from: self)
        }else{
            self.slideShow.presentFullScreenController(from: self)
        }
    }
    
    @objc func didTapOnGeoMaps() {
        
        if let id = storeId, let store = Store.findById(id: id){
            
           
            let latitude: CLLocationDegrees = store.latitude
            let longitude: CLLocationDegrees = store.longitude
            
            let regionDistance:CLLocationDistance = store.distance
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = store.name
            mapItem.openInMaps(launchOptions: options)
            
            /*let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GeoStoreViewController = sb.instantiateViewController(withIdentifier: "geostoreVC") as! GeoStoreViewController
                ms.latitude = store.latitude
                ms.longitude = store.longitude
                ms.name = store.name
                
                self.present(ms, animated: true)
            }*/
            
        }
        
    }
    
   
    
    func fetchGallery(store: Store) {
       
        
        /*
         * Start binding gallery view
         */
        
        gallery_container.isHidden = true
        
        if store.gallery > 0{
            
            gallery_container.isHidden = false
            
            let style =  CardHorizontalStyle(width: 150, height: 150, type: .StoreGalley)
            let gallery_view = Gallery_HCards.newInstance(style: style) as! Gallery_HCards
            
            gallery_view.h_label.text = AppConfig.CardTags.TAG_PHOTOS.localized
            gallery_view.backgroundColor = .clear
            
            
            if let controller = self.navigationController{
                gallery_view.viewNavigationController = controller
            }
            
            if let height = style.height{
                gallery_view.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            }
            
            self.gallery_container.addSubview(gallery_view)
            
            self.gallery_container.addConstraintsWithFormat(format: "H:|[v0]|", views: gallery_view)
            self.gallery_container.addConstraintsWithFormat(format: "V:|[v0]|", views: gallery_view)
            
            gallery_view.req_limit = 10
            gallery_view.type = "store"
            gallery_view.module_id = store.id
            gallery_view.load(module_id: store.id, type: "store")
            
            gallery_view.delegate = self
            
        }else{
            self.gallery_container.isHidden = true
        }
        
        /*
         * End binding gallery view
         */
        
    }
  
  
    
    func setupStoreDetail()  {
        
        if let id = storeId, let store = Store.findById(id: id){
            
            
            if let session = Session.getInstance(), let user = session.user{
                if user.id == store.user_id{
                    self.chatBtn.isHidden = true
                }
            }
            
    

            self.store = store
            
            if store.canChat==1{
                 self.chatBtn.isHidden = false
            }else{
                self.chatBtn.isHidden = true
            }
            
            updateNavBarButtons()
            
           /*
            * Start binding offers view
            */
            
            item_container.isHidden = true
            
            if store.nbrOffers > 0{
                
                item_container.isHidden = false
                
                let style =  CardHorizontalStyle(width: 280, height: 240, type: .Recent_Offers)
                let offers_view = Offers_HCards.newInstance(style: style) as! Offers_HCards
                
                offers_view.h_label.text = AppConfig.CardTags.TAG_RECENT_OFFERS.localized
                offers_view.backgroundColor = .clear
                
                
                if let controller = self.navigationController{
                    offers_view.viewNavigationController = controller
                }else{
                    offers_view.viewNavigationController = self.tabBarController?.navigationController
                }
                    
                
                if let height = style.height{
                    offers_view.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
                }
                
                self.item_container.addSubview(offers_view)
                
                self.item_container.addConstraintsWithFormat(format: "H:|[v0]|", views: offers_view)
                self.item_container.addConstraintsWithFormat(format: "V:|[v0]|", views: offers_view)
                
                offers_view.__req_store = self.store!.id
                offers_view.load()
                
                offers_view.delegate = self
                
            }else{
                
               // self.offers_container_block.isHidden = true
            }
            
            /*
             * End binding offers view
             */
            
            
            
            self.setupDistanceButton(store: store)
            
            /*
             * Start binding gallery view
             */
            
            fetchGallery(store: store)
            ////////End binding gallery view
 
           
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            formatter.minimumIntegerDigits = 1
            
            let number = NSNumber(value: store.votes)
            
    
            if let value = formatter.string(from: number){
                self.hb_left_label.text = "\(value)"
            }else{
                self.hb_left_label.text = "\(store.votes)"
            }
            
            let starIcon = UIImage.init(icon: .googleMaterialDesign(.star), size: CGSize(width: 26, height: 26), textColor: Utils.hexStringToUIColor(hex: "#e5b700"))
            self.hb_left_label.setLeftIcon(image: starIcon)
            
            self.hb_rating_detail.text = "\(store.nbr_votes) \("Reviews".localized)"
            
            
            //////
            let photosIcon = UIImage.init(icon: .googleMaterialDesign(.insertPhoto), size: CGSize(width: 26, height: 26), textColor: .white)
            self.hb_right_label.text = "\(store.listImages.count)"
            self.hb_right_label.setLeftIcon(image: photosIcon)
           
            /*
            * OPENING CLOSING TIME TABLE
            */

            if store.opening == 1{
                
                let icon = UIImage.init(icon: .ionicons(.clock), size: CGSize(width: 18, height: 18), textColor: .white)
                self.open_store_badge.text = " \("Open".localized)"
                self.open_store_badge.setLeftIcon(image: icon)
                self.open_store_badge.backgroundColor = .greenSea
                
                self.open_store_badge.isHidden = false
                self.opening_time_container.isHidden = false
                
            }else if store.opening == -1 {
               
                let icon = UIImage.init(icon: .ionicons(.clock), size: CGSize(width: 18, height: 18), textColor: .white)
                self.open_store_badge.text = " \("Closed".localized)"
                self.open_store_badge.setLeftIcon(image: icon)
                self.open_store_badge.backgroundColor = .orange
                
                self.open_store_badge.isHidden = false
                self.opening_time_container.isHidden = false
                
            }else{
                
                self.open_store_badge.isHidden = true
                self.opening_time_container.isHidden = true
                
            }


            if(store.opening == 1 || store.opening == -1){

                var hours_text = ""
                for opt: OpeningTime in store.opening_time_table_list{

                    let opening = DateUtils.getPreparedDateSimple2(dateUTC: "2011-01-01 \(opt.opening)",dateFormat: "h:mm a")
                    let closing = DateUtils.getPreparedDateSimple2(dateUTC: "2011-01-01 \(opt.closing)",dateFormat: "h:mm a")
                    var day:String = opt.day
                    day = day.localized
                    day = String(day.prefix(3))
                    day = day.capitalizingFirstLetter()

                    if(opt.enabled == 1){
                        if(DateUtils.getCurrentDay().lowercased() == opt.day.lowercased() && store.opening == 1){
                            hours_text = hours_text+"<b>\(day)</b>   \(opening) - \(closing)  - <bgreen>\("Open Now".localized)</bgreen>\n"
                        }else if(DateUtils.getCurrentDay().lowercased() == opt.day.lowercased() && store.opening == -1){
                            hours_text = hours_text+"<b>\(day)</b>   \(opening) - \(closing)  - <bred>\("Closed Now".localized)</bred>  \n"
                        }else{
                            hours_text = hours_text+"<b>\(day)</b>   \(opening) - \(closing) \n"
                        }
                    }else{
                        hours_text = hours_text+"<b>\(day)</b>   -- \n"
                    }


                }

                 let attributedStringOPT  = hours_text.toHtml().attributedString
                //self.opening_time_text_view.text = hours_text

                self.opening_time_text_view.attributedText = attributedStringOPT
                
                if(AppStyle.isDarkModeEnabled){
                    self.opening_time_text_view.textColor = Colors.Appearance.black
                }
                
            
            }

            /*
            * END OPENING CLOSING TIME TABLE
            */

            
            if store.featured == 1 {
                self.featured.isHidden = false
            }else{
                self.featured.isHidden = true
            }
            
          
            
            if  let cobj = Category.findById(id: store.category_id){
                Utils.printDebug("\(cobj)")
                self.category_badge.text = cobj.nameCat
                if let color = cobj.color{
                    self.category_badge.backgroundColor = Utils.hexStringToUIColor(hex: color)
                }
            }
            
            
            //setup maps
            self.setupGoogleMaps(lat: store.latitude, lng: store.longitude)
            
            //setup imageview
            var imagesInputs:[InputSource] = []
            if store.listImages.count > 0 {
                
                
                for index in 0...store.listImages.count-1{
                    let url = store.listImages[index].full
                    if let k = KingfisherSource(urlString: url){
                         imagesInputs.append(k)
                    }
                }
                
                self.slideShow.setImageInputs(imagesInputs)
                
                
                if let first = store.listImages.first {
                    
                    let url = URL(string: first.url500_500)
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }
                
            }
            
            
            if imagesInputs.count == 0 {
                if let img = UIImage(named: "default_store_image") {
                    self.imageView.image = img
                }
            }
            
            
            //setup store description and resize height of textview
         
            
            if store.detail != ""{
                
                Utils.printDebug("\(store.detail)")
                
                Utils.printDebug("Height-before: \(self.storeDetailSubContainer.frame.height)")
                //description Text View
                
                self.descriptionTextView.delegate = self
                self.descriptionTextView.isUserInteractionEnabled = true // default: true
                self.descriptionTextView.isEditable = false // default: true
                self.descriptionTextView.isSelectable = true // default: true
                self.descriptionTextView.dataDetectorTypes = [.link]
                self.descriptionTextView.isScrollEnabled = false
                
                self.descriptionTextView.textAlignment = .natural
                self.descriptionTextView.tintColor = Colors.Appearance.primaryColor
                
                
                let attributedString  = store.detail.toHtml().attributedString
                self.descriptionTextView.attributedText = attributedString
                
                if(AppStyle.isDarkModeEnabled){
                        self.descriptionTextView.textColor = Colors.Appearance.black
                    }
                
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    
                    Utils.printDebug("Height-after: \(self.storeDetailSubContainer.frame.height)")
                  
                    //ceate a constraint to fix height size
                    self.storeDetailSubContainer.translatesAutoresizingMaskIntoConstraints = false
                  
                    let heightConstraint = NSLayoutConstraint(item: self.storeDetailSubContainer, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.storeDetailSubContainer.frame.height)
                    
                
                    
                    self.storeDetailContainer.addConstraints([heightConstraint])
                    self.storeDetailContainer.layoutIfNeeded()
                    self.storeDetailSubContainer.layoutIfNeeded()
                  
                 
                }
                
               
                
            }
          
            
            
            //address
            self.storeAddress.text = store.address
            
            let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: .white)
            
            if Utils.isRTL(){
                self.storeAddress.setRightIcon(image: icon)
            }else{
                self.storeAddress.setLeftIcon(image: icon)
            }
           
            
            //store title
            self.setupCustomNavBar(title: store.name)
            self.title_label.text = store.name
            
       
          
  
        }else{
            //sync with server
            //load()
            navigationBar.isTranslucent = false
            viewManager.showAsError()
        }
        
    }
    
    func setupDistanceButton(store: Store) {
        
        let distance = store.distance.calculeDistance()
        //self.average_labe
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.directions), size: CGSize(width: 26, height: 26), textColor: .white)

       
        if(distance.getObject(type: AppConfig.distanceUnit).nearby){
            self.hb_center_label.text = " \("Near".localized)"
        }else{
            self.hb_center_label.text = " \("Far".localized)"
        }
        
        self.hb_center_label.setLeftIcon(image: icon)
        
        self.hb_center_detail.text = distance.getCurrent(type: AppConfig.distanceUnit)
        
        
           
    }

    
    func onReloadAction(action: EmptyLayout) {
        self.load()
    }
    
    func onReloadAction(action: ErrorLayout) {
        self.load()
    }
    
    
    func makeUIAsLoading() {
        
        //enable skelete view
        self.title_label.isSkeletonable = true
        self.storeAddress.isSkeletonable = true
        
        self.stackViewSDHStart.isHidden = true
        self.stackViewSDHMiddle.isHidden = true
        self.stackViewSDHEnd.isHidden = true
        self.category_badge.isHidden = true
        
      
        self.storeAddress.showAnimatedGradientSkeleton()
        self.title_label.showAnimatedGradientSkeleton()
        
        self.scrollView.isScrollEnabled = false
        
    }
    
    func makeUIAsDefault() {
        
        //enable skelete view
        self.title_label.isSkeletonable = false
        self.storeAddress.isSkeletonable = false
        
        self.stackViewSDHStart.isHidden = false
        self.stackViewSDHMiddle.isHidden = false
        self.stackViewSDHEnd.isHidden = false
        self.category_badge.isHidden = false
        
        
        self.storeAddress.hideSkeleton()
        self.title_label.hideSkeleton()
        
        self.scrollView.isScrollEnabled = true
        
    }
    
    //load store
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        makeUIAsLoading()
        
       // viewManager.showAsLoading()
    
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
          
            if let store_id = self.storeId{
                parameters["store_id"] = String(store_id)
            }
           
        }
        
        Utils.printDebug("\(parameters)")
        
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
  
    }
    
    func success(parser: StoreParser,response: String) {
        
        makeUIAsDefault()
        
        self.viewManager.showMain()
       
        if parser.success == 1 {

            let stores = parser.parse()
           
            if stores.count > 0 {
                
                stores[0].save()
                self.setupStoreDetail()
                
            }else{
                viewManager.showAsEmpty()
            }
            
        }else {
            
            if parser.errors != nil {
                viewManager.showAsError()
            }
            
        }
        
    }
    
   
    
    func error(error: Error?,response: String) {
        
        self.viewManager.showAsError()
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
        
    }
    
    func calculateEstimatedFrame(content: String,fontSize: Float) -> CGSize {
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
    
        let width = estimatedFrame.width
        let height = estimatedFrame.height
       
        return CGSize(width: width, height: height)
    }
    
    static var mInstance: StoreDetailV2ViewController? = nil
    
    
    func startGalleryLsit(store_id: Int)  {
        
        
        let sb = UIStoryboard(name: "GalleryList", bundle: nil)
        
        let ms: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
        ms.module_id = store_id
        ms.type = "store"
        
        ms.config.backHome = true
        ms.config.customToolbar = true
        
        if let controller = self.navigationController{
            controller.pushViewController(ms, animated: true)
        }else{
             self.present(ms, animated: true)
        }
       
       
    }
    
    func startReviewsLsit(store_id: Int)  {
        
        let sb = UIStoryboard(name: "ReviewsList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            
            let ms: ReviewsListViewController = sb.instantiateViewController(withIdentifier: "reviewsListVC") as! ReviewsListViewController
            ms.store_id = store_id
            
            self.present(ms, animated: true)
        }
    }
    
    func startOffersLsit(store_id: Int)  {
        
        let sb = UIStoryboard(name: "OffersList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OffersLsitViewController = sb.instantiateViewController(withIdentifier: "offersListVC") as! OffersLsitViewController
            ms.store_id = store_id
            
            self.present(ms, animated: true)
        }
    }
    
    
    func startMessenger(client_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            present(ms, animated: true)
        }
        
    }
    
    
    func startOfferDetailVC(offerId: Int) {
        
        let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
            
            ms.offer_id = offerId
            
            self.present(ms, animated: true)
        }
        
    }
    
   
   
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let webVC = SwiftModalWebVC(pageURL: URL, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
        //self.navigationController?.pushViewController(webVC, animated: true)
        self.present(webVC, animated: true, completion: nil)
        
        return false
    }

   

}
