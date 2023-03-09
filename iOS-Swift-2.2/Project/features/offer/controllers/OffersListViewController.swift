//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus


protocol OffersLsitViewControllerDelegate {
    func onOffersLsitSearchPressed(controller: OffersLsitViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController)
}

class OffersLsitViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SearchDialogViewControllerDelegate{
    
    var delegate: OffersLsitViewControllerDelegate? = nil
    var filterCache: SearchDialogViewController.FilterCache? = nil
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
        
        //OffersLsitViewController.isAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
        
       // OffersLsitViewController.isAppear = true
    }
    

    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    var store_id: Int? = nil
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "offersCellId"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    
    
    //request
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = ListOfferCell.OffersListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    var __req_store: Int = 0
    var __req_list_type = "all" //percent/price/all
    var __req_list_type_value = ""
    
    
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
        
        
         let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
        
         if let vc = sb.instantiateInitialViewController() {
            
            let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
            
            if let cache = filterCache, let _type = cache._type, let _view =  cache._view{
                searchDialog.setup(type: _type, view: _view)
            }else{
                let view = UIView.loadFromNib(name: "OfferSearch")
                searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_OFFERS, view: view)
            }
            
            
            searchDialog.delegate = self
            
            self.present(searchDialog, animated: true, completion: nil)
        }

        
    }
    
    
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
        
        controller.onBackHandler()
        
        if type == AppConfig.Tabs.Tags.TAG_OFFERS{
            
            let instance = view as! OfferSearch
            
            __req_redius = Int(instance.sliderView.value)
            __req_search = instance.search_field.text!
            
            if let cat = instance.selected_category{
                __req_category = cat.numCat
            }
            
            if instance.isPriceType{
                __req_list_type = "value"
                __req_list_type_value = instance.priceRangeSelected
            }else if instance.isDiscountType{
                __req_list_type = "discount"
                __req_list_type_value = instance.discountRangeSelected
            }else{
                __req_list_type = "all"
                __req_list_type_value = ""
            }
            
            collectionView.reloadData()
            
            //refresh
        }else{
            
            if let del = delegate{
                del.onOffersLsitSearchPressed(controller: self, type: type, view: view, search_dialog_controller: controller)
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
    
 
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        

        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView?.register(ListOfferCell.self, forCellWithReuseIdentifier: AppConfig.Tabs.Tags.TAG_OFFERS)
        collectionView.isScrollEnabled = false
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
       
       
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
        
        
        if let store_id = self.store_id, let store = Store.findById(id: store_id){
            topBarTitle.text = store.name+" "+("offers").localized
        }else{
            topBarTitle.text = "Offers".localized
        }
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellId = AppConfig.Tabs.Tags.TAG_OFFERS
        let cell: ListOfferCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListOfferCell
        
        cell.viewController = self
        
        return cell
    }
    
    
    
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
        
        let myCell: ListOfferCell = cell as! ListOfferCell
        
        if myCell.isFetched  == false {
            
            if let store = self.store_id {
                myCell.__req_store = store
            }
            
            myCell.__req_redius = __req_redius
            myCell.__req_search = __req_search
            myCell.__req_store = __req_store
            myCell.__req_list_type = __req_list_type
            myCell.__req_list_type_value = __req_list_type_value
            
            
            
            
             myCell.fetch(request: ListOfferCell.OffersListRequestOrder.nearby)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
   

    
}





