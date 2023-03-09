//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus


protocol StoresLsitViewControllerDelegate {
    func onStoresListSearchPressed(controller: StoresLsitViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController)
}

class StoresLsitViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SearchDialogViewControllerDelegate{
    
    
    var delegate: StoresLsitViewControllerDelegate? = nil
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
    
    
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = ListStoresCell.StoresListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0

    var category_id: Int? = nil
    
    let cellId = "storesCellId"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    
    
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
                let view = UIView.loadFromNib(name: "StoreSearch")
                searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_STORES, view: view)
            }

            searchDialog.delegate = self

            self.present(searchDialog, animated: true, completion: nil)
        }
        
    }
    
    
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
        
        controller.onBackHandler()
        
        if type == AppConfig.Tabs.Tags.TAG_STORES{
            
            
            let instance = view as! StoreSearch
            __req_redius = Int(instance.sliderView.value)
            __req_search = instance.search_field.text!
            
            if let cat = instance.selected_category{
                __req_category = cat.numCat
            }
            
            if instance.openOnlySwitch.isOn{
                __req_opening_time = 1
            }
            
        
            //reload store cell
            collectionView.reloadData()
            
            //refresh
        }else{
            
            if let del = delegate{
                del.onStoresListSearchPressed(controller: self, type: type, view: view, search_dialog_controller: controller)
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
        
        if config.customToolbar{
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        
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
        
        
        collectionView?.register(ListStoresCell.self, forCellWithReuseIdentifier: AppConfig.Tabs.Tags.TAG_STORES)
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
        
       
        if let id = self.category_id, let category = Category.findById(id: id){
            topBarTitle.text = category.nameCat
        }else{
            topBarTitle.text = "Stores".localized
        }
       
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellId = AppConfig.Tabs.Tags.TAG_STORES
        let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListStoresCell
        
        cell.viewController = self
        
        cell.__req_list_order = self.request
        
        if let cat = self.category_id{
            cell.__req_category = cat
        }
        
        cell.setupViews()
        
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
        
        let myCell: ListStoresCell = cell as! ListStoresCell

        myCell.__req_category = __req_category
        myCell.__req_search = __req_search
        myCell.__req_redius = __req_redius
        myCell.__req_opening_time = __req_opening_time
        
        myCell.fetch(request: ListStoresCell.StoresListRequestOrder.nearby)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
}






