//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus


protocol EventsLsitViewControllerDelegate {
    func onEventsLsitSearchPressed(controller: EventsLsitViewController, type: String, view: UIView, search_dialog_controller: SearchDialogViewController)
}

class EventsLsitViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SearchDialogViewControllerDelegate{
    
    var delegate: EventsLsitViewControllerDelegate? = nil
    var filterCache: SearchDialogViewController.FilterCache? = nil
    
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
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "eventsCellId"
    
    
    //request
    var __req_date_begin: String = ""
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list_order: String = ListEventCell.EventsListRequestOrder.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    
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
                let view = UIView.loadFromNib(name: "EventSearch")
                searchDialog.setup(type: AppConfig.Tabs.Tags.TAG_EVENTS, view: view)
            }
            
            searchDialog.delegate = self
            
            self.present(searchDialog, animated: true, completion: nil)
        }
        
    }
    
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController) {
    
        controller.onBackHandler()
        
        if type == AppConfig.Tabs.Tags.TAG_EVENTS{
            
            
            let instance = view as! EventSearch
            
            __req_redius = Int(instance.sliderView.value)
            __req_search = instance.search_field.text!
            
            if let cat = instance.selected_category{
                __req_category = cat.numCat
            }
            
           __req_date_begin = instance.date_begin_field.text!
            
            collectionView.reloadData()
            //refresh
        }else{
            
            if let del = delegate{
                del.onEventsLsitSearchPressed(controller: self, type: type, view: view, search_dialog_controller: controller)
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
        
        
        collectionView?.register(ListEventCell.self, forCellWithReuseIdentifier: AppConfig.Tabs.Tags.TAG_EVENTS)
        collectionView.isScrollEnabled = false
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        
        
        
        //marke events as notified
        if self.__req_list_order == ListEventCell.EventsListRequestOrder.upcoming{
            UpComingEvent.notified()
        }
        
        
    }
    
    
    
    
    
//    override func viewWillAppear(_ animated: Bool) {
//
//      //  EventsLsitViewController.isAppear = true
//
//    }
    
    
    static var isAppear = false
//
//    override func viewWillDisappear(_ animated: Bool) {
//
//      //  EventsLsitViewController.isAppear = false
//
//    }
    
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
        
        topBarTitle.text = "Events".localized
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellId = AppConfig.Tabs.Tags.TAG_EVENTS
        let myCell: ListEventCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListEventCell
        
        myCell.viewController = self
        
        myCell.__req_category = __req_category
        myCell.__req_search = __req_search
        myCell.__req_redius = __req_redius
        myCell.__req_date_begin = __req_date_begin
        
        
        
        myCell.__req_list_order = __req_list_order
        
        return myCell
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
        
        let myCell: ListEventCell = cell as! ListEventCell
        
        if myCell.isFetched  == false {
            myCell.fetch(request: ListEventCell.EventsListRequestOrder.nearby)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
}





