//
//  ListOffersCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import RealmSwift
import AssistantKit
import SwiftIcons
import SwiftWebVC


class ListBookmarksCell: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource ,BookmarksApiDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate,CustomLayoutDelegate, OptionsDelegate{
    
  
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
   
    enum Request {
        static let nearby = 0
        static let saved = -1
    }
    
    //request
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list: Int = Request.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    var __req_store: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Bookmark] = [Bookmark]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "bookmarkCellId"
    
    
    //instance for scrolling
    var isFetched = false
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
    
        cv.backgroundColor = Colors.Appearance.background
    
        if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 1
        }
        
        cv.dataSource = self
        cv.delegate = self
        return cv
        
    }()
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
      override init(frame: CGRect) {
          super.init(frame: frame)
          
          if #available(iOS 10.0, *) {
                     collectionView.refreshControl = refreshControl
                 } else {
                     collectionView.addSubview(refreshControl)
                 }
                 
                 // Configure Refresh Control
                 refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
                 
      }
      
      required init?(coder: NSCoder) {
          super.init(coder: coder)
      }
      
    
    private let refreshControl = UIRefreshControl()
    
    
    func fetch(request: Int) {
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        
        
        Utils.printDebug("Fetch ListFavorites")
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        

        
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_search_favorites") { result in
            
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
        viewManager.getCustomLayout().delegate = self

        viewManager.getEmptyLayout().header.numberOfLines = 0
        viewManager.getEmptyLayout().messageError.numberOfLines = 0


        viewManager.getErrorLayout().header.numberOfLines = 0
        viewManager.getErrorLayout().messageError.numberOfLines = 0

        
        
        //
        isFetched = true
        
   
        //pull data from server
        load()
        
    
        //regster Listeners
        onReceiveListener()
        
    }
    
    
    func setupCustomLayoutChatLogin() {
        

        viewManager.getCustomLayout().customBtn.initBolodFont()
        viewManager.getCustomLayout().customBtn.backgroundColor = .clear
        viewManager.getCustomLayout().customBtn.setTitleColor(Colors.Appearance.primaryColor, for: .normal)
        viewManager.getCustomLayout().customBtn.setTitle("Logg In".localized, for: .normal)
        
        viewManager.getCustomLayout().customText.initBolodFont(size: 22)
        viewManager.getCustomLayout().customText.text = "Find people around you!".localized
        viewManager.getCustomLayout().customText.numberOfLines = 0
        
        
    }
    
    func setupCustomLayoutFindNeighbour() {
        
        
        //let refreshIcon = UIImage.init(icon: .linearIcons(.undo), size: CGSize(width: 35, height: 35), textColor: .red)

        viewManager.getCustomLayout().customBtn.initBolodFont()
        viewManager.getCustomLayout().customBtn.backgroundColor = .clear
        viewManager.getCustomLayout().customBtn.setTitleColor(Colors.Appearance.primaryColor, for: .normal)
        viewManager.getCustomLayout().customBtn.setTitle("Refresh".localized, for: .normal)
        
        
        viewManager.getCustomLayout().customBtn.setIcon(prefixText: "", prefixTextColor: Colors.Appearance.primaryColor, icon: .linearIcons(.undo), iconColor: Colors.Appearance.primaryColor, postfixText: "  "+"Refresh".localized, postfixTextColor: Colors.Appearance.primaryColor, forState: .normal, textSize: 15, iconSize: 15)


        viewManager.getCustomLayout().customText.initBolodFont(size: 22)
        viewManager.getCustomLayout().customText.text = "No favorite found!".localized
        viewManager.getCustomLayout().customText.numberOfLines = 0
        
    }
    
    func checker() {
    
        self.viewManager.showMain()
        /*if Session.isLogged() == false {
            self.setupCustomLayoutChatLogin()
            self.viewManager.showAsCustomLayout()
        }else{
            self.viewManager.showMain()
        }*/
    }
    
    func onReceiveListener() {
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in
            
            if (result?.object) != nil{
                
            
                
            }
            
        }
        
 
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        if Session.isLogged() {
            //Init params
            __req_page = 1
            
            // Fetch Data
            load()
            
        }else{
            self.viewManager.showAsCustomLayout()
        }
       
    }
    
    
    lazy var optionsLauncher: OptionsLauncher = {
        let launcher = OptionsLauncher()
        launcher.delegate = self
        return launcher
    }()

    func onOptionItemPressed(option: Option) {
        if option.id ==  2{
             let id = option.object as! Int
            removeFromBookmarks(id: id)
        }
    }
    
    
    
    func removeFromBookmarks(id: Int)  {
        
        guard let sess = Session.getInstance(), let user = sess.user else {
            return
        }
        
        //sync
        let parameters = [
            "id": String(id),
            "user_id": String(user.id),
        ]
        
        let api = SimpleLoader()
        api.run(url: Constances.Api.API_EMOVE_FROM_BOOKMARKS, parameters: parameters) { (parser) in
            
            if parser?.success==1{
                
                self.__req_page = 1
                self.load()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BookmarkCell
            
            cell.setupSettings()
            cell.setOptionLauncher(optionsLauncher: optionsLauncher)
            cell.setup(object: LIST[indexPath.item])
            
            
            return cell
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

       
        if Device.isPhone{
            let finalHeight = frame.width / 3.5
            return CGSize(width: frame.width,height: finalHeight)
        }else if Device.isPad{
            
            if Device.screen > .inches_9_7{
                let finalHeight = frame.width / 3.5
                return CGSize(width: frame.width/1.5,height: finalHeight)
            }else{
                let finalHeight = frame.width / 5.5
                return CGSize(width: frame.width,height: finalHeight)
            }
           
        }else{
            let finalHeight = frame.width / 3.5
            return CGSize(width: frame.width,height: finalHeight)
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       let bookmarkObject = self.LIST[indexPath.row]
       
        if bookmarkObject.module == "store"{
            
            let sb = UIStoryboard(name: "StoreDetailV2", bundle: nil)
            let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
            ms.storeId = bookmarkObject.module_id
            
            if let controller = viewController{
                 controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                 controller.pushViewController(ms, animated: true)
            }
            
        }else if bookmarkObject.module == "offer"{
            
            let sb = UIStoryboard(name: "OfferDetailV2", bundle: nil)
            let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
            ms.offer_id = bookmarkObject.module_id
            
            if let controller = viewController{
                controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }
            
        }else if bookmarkObject.module == "event"{
            
            let sb = UIStoryboard(name: "EventDetailV2", bundle: nil)
            let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController
            
            ms.event_id = bookmarkObject.module_id
            
            if let controller = viewController{
                controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }
            
        }else if bookmarkObject.module == "link"{
            
          /*  let link = favorite.detail
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                let webVC = SwiftModalWebVC(pageURL: url, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
                //self.navigationController?.pushViewController(webVC, animated: true)
                if let controller = viewController{
                    controller.present(webVC, animated: true)
                }else if let controller = viewNavigationController{
                    controller.present(webVC, animated: true)
                }else if let controller = viewTabBarController{
                    controller.present(webVC, animated: true)
                }
            }*/
            
        }
        
        
        
       
    }
    
  
   
    private var isLoading = false
    //API
    
    var favoriteLoader: BookmarksApi = BookmarksApi()
    
    func load () {
        
        if let session = Session.getInstance(), let user = session.user{
            myUserSession = user
        }
        
        if __req_page == 1 {
            self.make_as_loader()
        }else{
            self.viewManager.showAsLoading()
        }
        
        
        self.favoriteLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30",
        ]
        
        if let sess = Session.getInstance(), let user = sess.user {
            parameters["user_id"] = String(user.id)
        }else if let guest = Guest.getInstance(){
            parameters["guest_id"] = String(guest.id)
        }
        
        parameters["page"] = String(__req_page)
        
    
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.favoriteLoader.load(url: Constances.Api.API_GET_BOOKMARKS,parameters: parameters)
        
        
    }
    
    
    func success(parser: BookmarksParser,response: String) {
        
       Utils.printDebug("response \(response)")
        
        self.make_as_result()
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
        
        
        self.isLoading = false
        
        if parser.success == 1 {
            
            
            let favorites = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if favorites.count > 0 {
                
                Utils.printDebug("Data loaded \(favorites)")
                
                
                if self.__req_page == 1 {
                    self.LIST = favorites
                }else{
                    self.LIST += favorites
                }
                
               // self.LIST.saveAll()
                self.collectionView.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
                
            }else{
                
                    if self.LIST.count == 0 || self.__req_page == 1{
                                   
                        emptyAndReload()
                        viewManager.showAsEmpty()
                                                      
                    }
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListFavorites")
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
        
        if self.LIST.count == 0{
            self.viewManager.showAsError()
        }
        
        Utils.printDebug("===> Request Error! ListFavorites")
        Utils.printDebug("\(response)")
        
    }
    
    
    func onReloadAction(action: ErrorLayout) {
        
        Utils.printDebug("onReloadAction ErrorLayout")
        
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
    
    func onReloadAction(action: CustomLayout) {
        
        Utils.printDebug("Nice! open login interface")
        
        __req_page = 1
        load()
        
    }
    
    
    
    func refreshToTop(object: Bookmark) {
        
        
        
    }
    
    
    
    func markMessagesAsLoaded(favoriteId: Int) {
    
        var parameters = ["test":""]
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["favoriteId"] = String(favoriteId)
        }
        
        Utils.printDebug("inboxLoaded===> \(parameters)")
        
        self.isLoading = true
        self.favoriteLoader.markMessagesAsLoaded(url: Constances.Api.API_INBOX_MARK_AS_LOADED, parameters: parameters, compilation: { parser in
        
            if let p = parser {
            
                if p.success == 1 {
                    
                }
                
            }
        
            
        })
      
    }
    
    
    
    
    
    
}


extension ListBookmarksCell{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Bookmark()
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
