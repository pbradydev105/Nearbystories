//
//  OfferDetailViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/10/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import GoogleMaps
import ImageSlideshow
import AssistantKit
import GoogleMobileAds
import SwiftWebVC
import RealmSwift
import MapKit

class EventDetailV2ViewController: MyUIViewController, EmptyLayoutDelegate,ErrorLayoutDelegate, EventLoaderDelegate, UIScrollViewDelegate, GMSMapViewDelegate, GADBannerViewDelegate, UITextViewDelegate, LoginControllerDelegate   {
    
    let request_join_login = 11
    let request_chat_login = 12
    
    func loginSuccess(controller: LoginViewController, user: User) {
        
        
        if request_join_login == controller.request{
            controller.onBackHandler()
            onJoinAction(UIView())
        }
        
        
    }
    
    func loginFaild(controller: LoginViewController) {
        
        
        
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
         EventDetailV2ViewController.isAppear = true
    }
    
 
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adContainer.isHidden = false
        
        if AppConfig.DEBUG {
            print("adViewDidReceiveAd")
        }
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        
        if AppConfig.DEBUG {
            print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }
        
    }
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    let slideShow = ImageSlideshow()
    
    @IBOutlet weak var buttons_container: UIStackView!
    //adview
    @IBOutlet weak var adSubContainer: UIView!
    @IBOutlet weak var adConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var adContainer: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
 
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var name_label: UILabel!

    @IBOutlet weak var join: UIButton!
    @IBOutlet weak var joined: UIButton!
    
    
    @IBAction func onJoinAction(_ sender: Any) {
        
        if let id = self.event_id, let _ = Event.findById(id: id){
        
            if !Session.isLogged(){
                
                let sb = UIStoryboard(name: "Login", bundle: nil)
                let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                
                ms.config.backHome = true
                ms.config.customToolbar = true
                
                ms.delegate = self
                ms.request = request_join_login
                
                
                if let controller = navigationController{
                    controller.pushViewController(ms, animated: true)
                }else{
                    self.present(ms, animated: true)
                }
                
                return
                
            }else{
                self.saveAction()
            }
            
        }
        
        UIView.animate(withDuration: 0.15) {
            self.joined.isHidden = false
            self.join.isHidden = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func onUnjoinAction(_ sender: Any) {
        
        self.unsaveAction()
        
        UIView.animate(withDuration: 0.15) {
            self.joined.isHidden = true
            self.join.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
    func saveAction() {
        
        if let user = Session.getInstance()?.user, let event_id = self.event_id, let event = Event.findById(id: event_id){
            
            let realm = try! Realm()
            realm.beginWrite()
            event.joined = true
            realm.add(event, update: .all)
            try! realm.commitWrite()
            
            let parameters = [
                "user_id": String(user.id),
                "event_id": String(event_id),
            ]
            
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_SAVE_EVENT, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                    if let id = parser?.result?.intValue{
                        //popup
                        self.notify_me(bookmark_id: id)
                    }
                    
                    
                }else{
                    
                }
            }
            
        }
        
    }
    
    
    func unsaveAction() {
        
        
        if let user = Session.getInstance()?.user, let event_id = self.event_id, let event = Event.findById(id: event_id){
            
            let realm = try! Realm()
            realm.beginWrite()
            event.joined = false
            realm.add(event, update: .all)
            try! realm.commitWrite()
            
            let parameters = [
                "user_id": String(user.id),
                "event_id": String(event_id),
            ]
            
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_REMOVE_EVENT, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                    if let id = parser?.result?.intValue{
                        //popup
                        self.notify_me(bookmark_id: id)
                    }
                    
                    
                }else{
                    
                }
            }
            
        }
        
    }
    
    @IBAction func onWebAction(_ sender: Any) {
        
        if let id = event_id, let event = Event.findById(id: id) {
            
            if let url = URL(string: event.webSite), UIApplication.shared.canOpenURL(url) {
                let webVC = SwiftModalWebVC(pageURL: url, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
                //self.navigationController?.pushViewController(webVC, animated: true)
                self.present(webVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    
    func notify_me(bookmark_id: Int) {
        
        //
        if !ExtendedConfig.notify_me_ask{
            return
        }
        
        guard let user = Session.getInstance()?.user else {
            return
        }
        
        let alert = UIAlertController(title: "Do you would remind you?".localized, message: "By clicking on on Remind me, you will receive a Reminder before 48 Hours".localized, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Remind me".localized, style: .default, handler: { action in
            
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
    

    
    @IBOutlet weak var date_begin_box: UIView!
    @IBOutlet weak var date_begin_short_month: UILabel!
    @IBOutlet weak var date_begin_short_day: UILabel!
    
    
    @IBOutlet weak var mapsContainer: UIView!
    @IBOutlet weak var event_dates: EdgeLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    
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
    
    
    
    
    @IBOutlet weak var imageContainer: UIView!

    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var descriptionContainer: UIView! //view store
    @IBOutlet weak var descriptionSubContainer: EXUIView! //subview store
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var eventAddress: UILabel!


    @IBAction func phoneCallAction(_ sender: Any) {
        
        if let id = event_id, let event = Event.findById(id: id) {
            
            let phone = Utils.formatPhone(string: event.tel)
          
            let result = phone.isValid(regex: .phone)
            
            if result{
                if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }else{
                    
                    let message: [String:String] = ["alert":event.tel]
                    self.showAlertError(title: "Phone".localized, content: message, msgBnt: "OK".localized)
                    
                }
            }else{
                
                let message: [String:String] = ["alert":event.tel]
                self.showAlertError(title: "Phone".localized, content: message, msgBnt: "OK".localized)
                
            }
            
        }
        
    }
    
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var webBtn: UIButton!
    
  
    
    
    private var lastContentOffset: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            name.alpha = CGFloat(alpha)
            distance.alpha = CGFloat(alpha)
            
            
        }else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            featured.alpha = CGFloat(alpha)
            distance.alpha = CGFloat(alpha)
            
        }*/
        
        
        
        if scrollView.contentOffset.y > -250{
            
            navigationBar.isTranslucent = false
            navigationBarItem.titleView?.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                // self.navigationBar.layoutIfNeeded()
            }
            
        }else{
            
            //make it transeparent
            navigationBar.isTranslucent = true
            navigationBarItem.titleView?.isHidden = true
            
            UIView.animate(withDuration: 0.2) {
                // self.navigationBar.layoutIfNeeded()
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func setupViews() {
        
        
        scrollView.delegate = self
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        
        self.stackview.distribution = .fillProportionally
        
        scrollView.parallaxHeader.view = self.imageContainer
      
        scrollView.parallaxHeader.mode = .fill;
        scrollView.parallaxHeader.minimumHeight = 0;
        
       
        if Device.isNotched{
              scrollView.parallaxHeader.height = self.imageView.frame.height-24
        }else{
              scrollView.parallaxHeader.height = self.imageView.frame.height
        }
       
     
        self.descriptionSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.descriptionSubContainer.layer.masksToBounds = true
        
        //self.join.layer.cornerRadius = 5/UIScreen.main.nativeScale
        //self.join.layer.masksToBounds = true
        
       
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
        self.imageContainer.addGestureRecognizer(gestureRecognizerImageView)
        self.imageContainer.isUserInteractionEnabled = true
        
        let gestureRecognizerGeoMap = UITapGestureRecognizer(target: self, action: #selector(didTapOnGeoMaps))
        self.mapsContainer.addGestureRecognizer(gestureRecognizerGeoMap)
        self.mapsContainer.isUserInteractionEnabled = true
        
        //localization
        self.detailLabel.text = "Event Detail".localized
        
       
        self.detailLabel.initBolodFont()
       
        
        self.name_label.initBolodFont(size: 20)
        self.name_label.textColor = .white
        
    
        self.eventAddress.initDefaultFont(size: 16)
        self.eventAddress.textColor = .white
        
        
        
        
        self.date_begin_short_month.initItalicFont()
        self.date_begin_short_month.textColor = .black
        
        
        self.date_begin_short_day.initBolodFont()
        self.date_begin_short_day.textColor = .red
        
        self.date_begin_box.roundCorners(radius: 25/UIScreen.main.nativeScale)
    
        
        self.event_dates.leftTextInset = 6
        self.event_dates.rightTextInset = 8
        self.event_dates.topTextInset = 3
        self.event_dates.bottomTextInset = 3
        self.event_dates.roundedCorners(radius: 10)
        self.event_dates.initItalicFont()
        self.event_dates.textColor = .black
        self.event_dates.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
    
        setupButtonParticipate()
        setupButtonUnparticipate()
        
        
        setupButtonWeb()
        setupButtonCall()
        
        
    }
    
    
    func setupButtonCall(){
        
        var icon = UIImage.init(icon: .googleMaterialDesign(.call), size: CGSize(width: 32, height: 32), textColor: .white)
        icon = icon.withRenderingMode(.alwaysOriginal)
        

        phoneBtn.setImage(icon, for: .normal)
        phoneBtn.setTitle("Call".localized, for: .normal)
        phoneBtn.setTitleColor(.white, for: .normal)
        phoneBtn.backgroundColor =  Colors.Appearance.primaryColor
        phoneBtn.initBolodFont(size: 16)
        
    }
    
    func setupButtonWeb(){
        
        var icon = UIImage.init(icon: .googleMaterialDesign(.language), size: CGSize(width: 32, height: 32), textColor: .white)
        icon = icon.withRenderingMode(.alwaysOriginal)
        
        
        webBtn.setImage(icon, for: .normal)
        webBtn.setTitle("www".localized, for: .normal)
        webBtn.setTitleColor(.white, for: .normal)
        webBtn.backgroundColor =  Colors.Appearance.primaryColor
        webBtn.initBolodFont(size: 16)
        
    }
    
    func setupButtonParticipate() {
        
        var icon = UIImage.init(icon: .googleMaterialDesign(.event), size: CGSize(width: 32, height: 32), textColor: .white)
        icon = icon.withRenderingMode(.alwaysOriginal)
        
        
        join.setImage(icon, for: .normal)
        join.setTitle("Join".localized, for: .normal)
        join.setTitleColor(.white, for: .normal)
        join.backgroundColor =  Colors.Appearance.primaryColor
        join.initBolodFont(size: 14)
        
    }
    
    func setupButtonUnparticipate() {
        
       
        var icon = UIImage.init(icon: .googleMaterialDesign(.eventAvailable), size: CGSize(width: 32, height: 32), textColor: .white)
        icon = icon.withRenderingMode(.alwaysOriginal)
        
        
        joined.setImage(icon, for: .normal)
        joined.setTitle("Joined".localized, for: .normal)
        joined.setTitleColor(.white, for: .normal)
        joined.backgroundColor = Colors.lightGreen
        joined.initBolodFont(size: 14)
        
        
    }
    
    @objc func didTapOnImage() {
         if #available(iOS 13.0, *){
            self.slideShow.presentFullScreenControllerForIos13(from: self)
        }else{
            self.slideShow.presentFullScreenController(from: self)
        }
    }
    
    
    @objc func didTapOnGeoMaps() {
        
        if let id = event_id, let event = Event.findById(id: id){
            
            /*let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GeoStoreViewController = sb.instantiateViewController(withIdentifier: "geostoreVC") as! GeoStoreViewController
                ms.latitude = event.lat
                ms.longitude = event.lng
                ms.name = event.name
                
                self.present(ms, animated: true)
            }*/
            
            
            let latitude: CLLocationDegrees = event.lat
            let longitude: CLLocationDegrees = event.lng
            
            let regionDistance:CLLocationDistance = event.distance
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = event.name
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
    
    var mapView: GMSMapView? = nil
    
    
    func setupGoogleMaps(lat:Double,lng:Double) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        
        let width = self.mapsContainer.frame.width
        
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: self.mapsContainer.frame.height), camera: camera)
        
       
        
        mapView?.delegate = self
        mapView?.settings.setAllGesturesEnabled(false)
        
        if let mapView = self.mapView  {
            
            
            self.mapsContainer.addSubview(mapView)
            
            
           
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
                NSLayoutConstraint(item: self.bannerView!,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: self.adSubContainer,
                                   attribute: .centerX,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: self.bannerView!,
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
        
        self.imageHeightConstraint.constant = view.frame.height-20-60
        self.view.layoutIfNeeded()
        
        
        
        self.setupSize()
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
       
        self.joined.isHidden = false
        self.join.isHidden = true
        
        self.joined.isEnabled = false
        self.join.isEnabled = false
        
        
        self.view.backgroundColor = Colors.bg_gray
        
        
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        
        
        setupNavBarTitles(title: "Offer detail".localized)
        setupNavBarButtons()
        setupViews()
        
        
        startAnimation()
        if let id = event_id, let _ = Event.findById(id: id){
            self.setupEventDetail()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_EVENT_DETAIL_ENABLED){
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
        if interstitial.isReady &&   EventDetailV2ViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            EventDetailV2ViewController.ad_seen += 1
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//       EventDetailV2ViewController.isAppear = false
//    }
    
    func setupNavBarButtons() {
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)

        //arrow back icon
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        
        
        let shareImage = UIImage.init(icon: .googleMaterialDesign(.share), size: CGSize(width: 25, height: 25), textColor: Colors.Appearance.darkColor)
        let shareCustomBarButtonItem = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(onSharehHandle))
        shareCustomBarButtonItem.setIcon(icon: .googleMaterialDesign(.share), iconSize: 25, color: _color)
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(shareCustomBarButtonItem)
        
        
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
    
    @objc func onSharehHandle() {
        
        if let id = event_id, let event = Event.findById(id: id) {
            
            let text = "%@ - Only on %@ \n %@".localized.format(arguments: event.name,AppConfig.APP_NAME,event.link)
            
            //%@ - Only on %@ \n %@
            
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
        }
        
    }
    
 
    
    static var isAppear = false
    
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles(title: String) {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        topBarTitle.text = title
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupEventDetail()  {
        
        
        if let id = event_id, let event = Event.findById(id: id){
            
            //stop skelete animation
            stopAnimation()
            
            if event.joined{
                self.joined.isHidden = false
                self.join.isHidden = true
            }else{
                self.joined.isHidden = true
                self.join.isHidden = false
            }
            
            self.joined.isEnabled = true
            self.join.isEnabled = true
          
            
            self.name_label.text = event.name
            
           
            //setup maps
            self.setupGoogleMaps(lat: event.lat, lng: event.lng)
            
            
            //setup images
            if event.listImages.count > 0 {
                
                var imagesInputs:[InputSource] = []
                
                for index in 0...event.listImages.count-1{
                    let url = event.listImages[index].url500_500
                    imagesInputs.append(KingfisherSource(urlString: url)!)
                }
                
                self.slideShow.setImageInputs(imagesInputs)
                
                
                if let first = event.listImages.first {
                    
                    let url = URL(string: first.url500_500)
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }else{
                    if let img = UIImage(named: "default_store_image") {
                        self.imageView.image = img
                    }
                }
            }else{
                
                if let img = UIImage(named: "default_store_image") {
                    self.imageView.image = img
                }
                
            }
            
            
            //setup description
            if event.desc != ""  {
                
               
                if  event.desc != "" {
                    
                   
                    self.descriptionContainer.isHidden = false
                    
                    //description Text View
                    
                    self.descriptionTextView.delegate = self
                    self.descriptionTextView.isUserInteractionEnabled = true // default: true
                    self.descriptionTextView.isEditable = false // default: true
                    self.descriptionTextView.isSelectable = true // default: true
                    self.descriptionTextView.dataDetectorTypes = [.link]
                    self.descriptionTextView.isScrollEnabled = false
                    
                    self.descriptionTextView.textAlignment = .natural
                    self.descriptionTextView.tintColor = Colors.Appearance.primaryColor
                    
                    
                    let attributedString  = event.desc.toHtml().attributedString
                    self.descriptionTextView.attributedText = attributedString
                    
                    
                    if(AppStyle.isDarkModeEnabled){
                        self.descriptionTextView.textColor = Colors.Appearance.black
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        
                        //ceate a constraint to fix height size
                        self.descriptionSubContainer.translatesAutoresizingMaskIntoConstraints = false
                        
                        let heightConstraint = NSLayoutConstraint(item: self.descriptionSubContainer!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.descriptionSubContainer.frame.height)
                        
                        self.descriptionContainer.addConstraints([heightConstraint])
                        self.descriptionContainer.layoutIfNeeded()
                        self.descriptionSubContainer.layoutIfNeeded()
                        
                    
                    }
                    
                }
                
            }else{
                self.descriptionContainer.isHidden = true
            }
            
            
            
            //store address
            
            if event.store_name != "" {
            
                
                let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: .white)
                
                self.eventAddress.text = event.store_name
                
                if Utils.isRTL(){
                    self.eventAddress.setRightIcon(image: icon)
                }else{
                    self.eventAddress.setLeftIcon(image: icon)
                }
                
                
            }else{
                
               
                let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: .white)
                
                self.eventAddress.text = event.address
                
                if Utils.isRTL(){
                    self.eventAddress.setRightIcon(image: icon)
                }else{
                    self.eventAddress.setLeftIcon(image: icon)
                }
            
            
            }
            
            
            
            if let url = URL(string: event.webSite), UIApplication.shared.canOpenURL(url) {
                
            }else{
                self.webBtn.isHidden = true
            }
            
            
            //store title
            self.setupNavBarTitles(title: event.name)
            
            
            //setup dates
            let begin_at = DateUtils.UTCToLocal(date: event.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)
            let end_at = DateUtils.UTCToLocal(date: event.dateEnd, fromFormat:  DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)
            
           
            let icon = UIImage.init(icon: .googleMaterialDesign(.dateRange), size: CGSize(width: 22, height: 22), textColor: .black)
            
 
            self.event_dates.text = " \(begin_at) - \(end_at)"
            self.event_dates.setLeftIcon(image: icon)
            
            
            let _month = DateUtils._UTC(date: event.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "MMM")
            let _day = DateUtils._UTC(date: event.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  "dd")
            
            
            self.date_begin_short_month.text = _month
            self.date_begin_short_day.text = _day
            
            
         
        }
        
    }
    
    
    func startAnimation() {
        
        self.name_label.isSkeletonable = true
        self.date_begin_box.isSkeletonable = true
        self.eventAddress.isSkeletonable = true
        self.event_dates.isSkeletonable = true
        
        self.name_label.showAnimatedGradientSkeleton()
        self.date_begin_box.showAnimatedGradientSkeleton()
        self.eventAddress.showAnimatedGradientSkeleton()
        self.event_dates.showAnimatedGradientSkeleton()
        
        self.buttons_container.alpha = 0
        
        self.scrollView.isScrollEnabled = false
    }
       
    func stopAnimation() {
       
        self.name_label.isSkeletonable = false
        self.date_begin_box.isSkeletonable = false
        self.eventAddress.isSkeletonable = false
        self.event_dates.isSkeletonable = false
               
        self.name_label.hideSkeleton()
        self.date_begin_box.hideSkeleton()
        self.eventAddress.hideSkeleton()
        self.event_dates.hideSkeleton()
        
        self.buttons_container.alpha = 1
        self.scrollView.isScrollEnabled = true
    }
         
    
    
    var event_id: Int? = nil
    
    
    //load store
    var eventLoader: EventLoader = EventLoader()
    
    func load () {
        
        
        self.eventLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            
            if let event_id = self.event_id{
                parameters["event_id"] = String(event_id)
            }
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.eventLoader.load(url: Constances.Api.API_USER_GET_EVENTS,parameters: parameters)
        
    }
    
    func success(parser: EventParser,response: String) {
        
        self.viewManager.showMain()
        
        if parser.success == 1 {
            
            let events = parser.parse()
            
            if events.count > 0 {
                
                events[0].save()
                self.setupEventDetail()
                
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
    
    func calculateEstimatedFrame(content: String,fontSize: Float,defWidth: CGFloat) -> CGSize {
        
        let size = CGSize(width: defWidth, height: 1500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
        
        let width = estimatedFrame.width
        let height = estimatedFrame.height
        
        return CGSize(width: width, height: height)
    }
    
    func calculateEstimatedFrame(content: String,fontSize: Float) -> CGSize {
        
        let size = CGSize(width: 250, height: 1500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
        
        let width = estimatedFrame.width
        let height = estimatedFrame.height
        
        return CGSize(width: width, height: height)
    }
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: view)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        if Session.isLogged() ==  false {
            
            return
        }else{
            
        }
    }
    
    func onReloadAction(action: EmptyLayout) {
        
    }
    
    func onReloadAction(action: ErrorLayout) {
        
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let webVC = SwiftModalWebVC(pageURL: URL, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
        //self.navigationController?.pushViewController(webVC, animated: true)
        self.present(webVC, animated: true, completion: nil)
        
        return false
    }
    
    
    
}
