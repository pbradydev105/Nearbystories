//
//  OfferDetailV2ViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/10/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import ImageSlideshow
import AssistantKit
import GoogleMobileAds
import SwiftWebVC
import SkeletonView

class OfferDetailV2ViewController: MyUIViewController, EmptyLayoutDelegate,ErrorLayoutDelegate, OfferLoaderDelegate, UIScrollViewDelegate,GADBannerViewDelegate, UITextViewDelegate, StoreDetailCardDelegate  {
   
    
    override func viewWillDisappear(_ animated: Bool) {
        if let controller = self.navigationController, config.customToolbar == true{
             ////controller.navigationBar.isHidden = false
        }
        
        OfferDetailV2ViewController.isAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let controller = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
        
        OfferDetailV2ViewController.isAppear = true
    }
    
 
    
    static var isAppear = false
    
    
    
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
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    //adview
    @IBOutlet weak var adSubContainer: UIView!
    @IBOutlet weak var adContainer: UIView!
    
    @IBOutlet weak var datesContainer: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var store_detail_container: EXUIView!
    
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var category_label: EdgeLabel!
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var stackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var offer_dates: EdgeLabel!
    
    func setupSize()  {
        if Device.isPad{
            let width = self.view.frame.width/1.5
            let finalSize = self.view.frame.width-width
            self.stackViewLeftConstraint.constant = finalSize/2
            self.stackViewRightConstraint.constant = finalSize/2
        }
    }
    
    @IBOutlet weak var imageContainer: UIView!
    //
   
    @IBOutlet weak var descriptionContainer: UIView! //view store
    @IBOutlet weak var descriptionSubContainer: UIView! //subview store
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var offerDetailLabel: UILabel!
    
    
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var offer: EdgeLabel!
    
  
    @IBAction func onStoreNameClicked(_ sender: Any) {
        
        if let id = offer_id, let offer = Offer.findById(id: id){
            let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
                ms.storeId = offer.store_id
                
                self.present(ms, animated: true)
            }
        }
    }
    
    
    private var lastContentOffset: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            title_label.alpha = CGFloat(alpha)
            category_label.alpha = CGFloat(alpha)
            offer.alpha = CGFloat(alpha)
           
            
        }else if (self.lastContentOffset < scrollView.contentOffset.y) {
            
            // move down
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            title_label.alpha = CGFloat(alpha)
            category_label.alpha = CGFloat(alpha)
            offer.alpha = CGFloat(alpha)
            
        }
        
       
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
        scrollView.parallaxHeader.height = self.imageView.frame.height;
    
        
        //offer dates
        offer_dates.leftTextInset = 15
        offer_dates.rightTextInset = 15
        offer_dates.topTextInset = 10
        offer_dates.bottomTextInset = 10
        offer_dates.initItalicFont()

        
        
        self.descriptionSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.descriptionSubContainer.layer.masksToBounds = true
        
       
        
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
        
    
        //localization
    
        self.offerDetailLabel.text = "Offer Detail".localized
        
       
        self.offerDetailLabel.initBolodFont()
        
        
        
        self.title_label.initBolodFont(size: 20)
        self.title_label.textColor = .white
        
        
        
        self.offer.leftTextInset = 15
        self.offer.rightTextInset = 15
        self.offer.topTextInset = 5
        self.offer.bottomTextInset = 5
        self.offer.backgroundColor = Colors.Appearance.primaryColor
        self.offer.initBolodFont(size: 16)
        self.offer.textColor = .white
        self.offer.roundCorners(radius: 25/UIScreen.main.nativeScale)

        
        
        self.distance.backgroundColor = .clear
        self.distance.textColor = Colors.Appearance.primaryColor
        self.distance.initBolodFont(size: 14)

        

        self.category_label.leftTextInset = 15
        self.category_label.rightTextInset = 15
        self.category_label.topTextInset = 5
        self.category_label.bottomTextInset = 5
        self.category_label.backgroundColor = .orange
        self.category_label.initBolodFont(size: 16)
        self.category_label.textColor = .white
        self.category_label.roundCorners(radius: 25/UIScreen.main.nativeScale)

        
        self.descriptionSubContainer.backgroundColor = Colors.Appearance.whiteGrey
        
        
        store_detail_container.isHidden = true
        category_label.isHidden = true

    }
    
    func setupStoreObject(){
        
       
        guard let id = self.offer_id, let _offer = Offer.findById(id: id) else {
            return
        }
        
        
        let std = StoreDetailCardView.instanceFromNib(name: "StoreDetailCardView") as! StoreDetailCardView
        self.store_detail_container.addSubview(std)
        
        
        std.translatesAutoresizingMaskIntoConstraints = false
        let left = std.leftAnchor.constraint(equalTo: store_detail_container.leftAnchor)
        let right = std.rightAnchor.constraint(equalTo: store_detail_container.rightAnchor)
        let top = std.topAnchor.constraint(equalTo: store_detail_container.topAnchor)
        let bottom = std.bottomAnchor.constraint(equalTo: store_detail_container.bottomAnchor)
        
        left.constant = 0
        right.constant = 0
        bottom.constant = 0
        top.constant = 0
        
        left.isActive = true
        right.isActive = true
        bottom.isActive = true
        top.isActive = true
        
        store_detail_container.isHidden = false
        
        
        //register gesture reconizer for gallery
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnStoreDetail))
       
        store_detail_container.isUserInteractionEnabled = true
        store_detail_container.addGestureRecognizer(gestureRecognizer1)
       
        
        
        guard let _store = Store.findById(id: _offer.store_id) else {
            std.setup(store_id: _offer.store_id)
            std.delegate = self
            return
        }
        
        
        
        category_label.isHidden = false
        category_label.text = _store.category_name
        category_label.backgroundColor = Utils.hexStringToUIColor(hex: _store.category_color)
        
        std.setup(object: _store)
        
        
    }
    
    func onLoaded(store: Store) {
        
        category_label.isHidden = false
        category_label.text = store.category_name
        category_label.backgroundColor = Utils.hexStringToUIColor(hex: store.category_color)
        
        
        //save in realm
        store.save()
        
    }
    
    @objc func didTapOnStoreDetail(){
        
        
        guard let offer_id = self.offer_id, let _offer = Offer.findById(id: offer_id) else{
            return
        }
        
        
       let sb = UIStoryboard(name: "StoreDetailV2", bundle: nil)
       let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
       
       ms.storeId = _offer.store_id
       
       ms.config.backHome = true
       ms.config.customToolbar = true
       
       if let controller = self.navigationController {
           controller.pushViewController(ms, animated: true)
       }else{
           self.present(ms, animated: true)
       }
        
       
        
    }
    
    @objc func didTapOnImage() {
        if #available(iOS 13.0, *){
            self.slideShow.presentFullScreenControllerForIos13(from: self)
        }else{
            self.slideShow.presentFullScreenController(from: self)
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
        
     
        self.bannerView.delegate = self
        self.adContainer.isHidden = true
        
    }
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageHeightConstraint.constant = view.frame.height/2
        self.view.layoutIfNeeded()
       
        setupSize()
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        
    
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
       
        setupNavBarTitles(title: "Offer detail")
        setupNavBarButtons()
        setupViews()
        
        
        self.startAnimation()
        
        if let id = offer_id, let _ = Offer.findById(id: id){
            self.setupOfferDetailV2()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_OFFER_DETAIL_ENABLED){
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
    
    func startAnimation() {
        self.title_label.isSkeletonable = true
        self.offer.isHidden = true
        self.store_detail_container.isHidden = true
        self.datesContainer.isHidden = true
        self.title_label.showAnimatedGradientSkeleton()
        
         self.scrollView.isScrollEnabled = false
    }
    
    func stopAnimation() {
        
        self.title_label.isSkeletonable = false
        self.offer.isHidden = false
        self.store_detail_container.isHidden = false
        self.title_label.hideSkeleton()
        
         self.scrollView.isScrollEnabled = true
    }
       
    
    private static var ad_seen = 0
    var interstitial: GADInterstitial!
    
    func showInterstitial()  {
        if interstitial.isReady &&   OfferDetailV2ViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            OfferDetailV2ViewController.ad_seen += 1
        }
    }
 
    func setupNavBarButtons() {
        

        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)


        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
    
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
            
            //icon: FontType, size: CGSize, textColor: UIColor = .black, backgroundColor: UIColor = .clear
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        
        let shareImage = UIImage.init(icon: .openIconic(.share), size: CGSize(width: 25, height: 25), textColor: Colors.Appearance.darkColor)
        
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
        
        if let id = offer_id, let offer = Offer.findById(id: id) {
            
            let text = "%@ - Only on %@ \n %@".localized.format(arguments: offer.name,AppConfig.APP_NAME,offer.link)
            
            //%@ - Only on %@ \n %@
            
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
        }
        
    }
    
 

    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles(title: String) {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        topBarTitle.text = title
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupOfferDetailV2()  {
        
        if let id = offer_id, let offer = Offer.findById(id: id){
            
            //stop skelete animation
            stopAnimation()
            
            Utils.printDebug("\(offer)")

            let end_at = DateUtils._UTC(date: offer.date_end, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatDate)
            offer_dates.text = " \("End at".localized) "+end_at
            
            if(end_at == ""){
               self.datesContainer.isHidden  = true
            }else{
                 self.datesContainer.isHidden  = false
                let date_icon = UIImage.init(icon: .linearIcons(.calendarFull), size: CGSize(width: 24, height: 24), textColor:Colors.Appearance.primaryColor)
                offer_dates.textColor = Colors.Appearance.primaryColor
                offer_dates.setLeftIcon(image: date_icon)
            }
            
           
            let distance = offer.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: AppConfig.distanceUnit)
            self.title_label.text = offer.name

            //setup imageview
            if offer.listImages.count > 0 {
                
                //let url = URL(string: images.url500_500)
                //self.imageView.kf.indicatorType = .activity
                //self.imageView.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                if offer.listImages[0].url500_500 != ""{
                    let imagesInputs:[InputSource] = [KingfisherSource(urlString: offer.listImages[0].url500_500)!]
                    self.slideShow.setImageInputs(imagesInputs)
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
            
            
            if offer.value_type == "price" {
                
                if let currency = offer.currency {
                    if let pprice = currency.parseCurrencyFormat(price: Float(offer.offer_value)){
                        self.offer.text = pprice
                    }
                }
                
            }else if offer.value_type == "percent" {
                self.offer.text = "\(Int(offer.offer_value))%"
            }else{
                self.offer.text = "Promotion".localized
            }
            
            //setup description
            if offer._description != "" {
                
                Utils.printDebug("\(offer._description)")
                //self.descriptionLabel.text = offer._description
             
                
                //description Text View
                
                Utils.printDebug("Height-before: \(self.descriptionSubContainer.frame.height)")
                //description Text View
                
                
                
                self.descriptionTextView.delegate = self
                self.descriptionTextView.isUserInteractionEnabled = true // default: true
                self.descriptionTextView.isEditable = false // default: true
                self.descriptionTextView.isSelectable = true // default: true
                self.descriptionTextView.dataDetectorTypes = [.link]
                self.descriptionTextView.isScrollEnabled = false
               
                self.descriptionTextView.textAlignment = .natural
                self.descriptionTextView.tintColor = Colors.Appearance.primaryColor
            
                //self.descriptionTextView.backgroundColor = UIColor.yellow
            
                let attributedString  = offer._description.toHtml().attributedString
                self.descriptionTextView.attributedText = attributedString
                
                
                if(AppStyle.isDarkModeEnabled){
                    self.descriptionTextView.textColor = Colors.Appearance.black
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    
                    Utils.printDebug("Height-after: \(self.descriptionSubContainer.frame.height)")
                 
                    //ceate a constraint to fix height size
                   self.descriptionSubContainer.translatesAutoresizingMaskIntoConstraints = false
                    
                    let heightConstraint = NSLayoutConstraint(item: self.descriptionSubContainer, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.descriptionSubContainer.frame.height)
                    
                    
                    
                    
                    self.descriptionContainer.addConstraints([heightConstraint])
                    self.descriptionContainer.layoutIfNeeded()
                    self.descriptionSubContainer.layoutIfNeeded()
 
                    
                }
                
                
                
            }else{
                self.descriptionContainer.isHidden = true
            }
            
            
    
            //store title
            self.setupNavBarTitles(title: offer.name)
            
            //setup store data
            self.setupStoreObject()
            
            
            
         
            
        }
        
    }
    
    
    var offer_id: Int? = nil
    
    
    //load store
    var offerLoader: OfferLoader = OfferLoader()
    
    func load () {
        
        
        self.offerLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            
            if let offer_id = self.offer_id{
                parameters["offer_id"] = String(offer_id)
            }
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.offerLoader.load(url: Constances.Api.API_GET_OFFERS,parameters: parameters)
        
    }
    
    func success(parser: OfferParser,response: String) {
        
        self.viewManager.showMain()
        
        if parser.success == 1 {
            
            let offers = parser.parse()
            
            if offers.count > 0 {
                
                offers[0].save()
                self.setupOfferDetailV2()
                
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

