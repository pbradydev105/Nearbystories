//
//  MainV2TabBarController.swift
//  NearbyStores
//
//  Created by Amine  on 8/18/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import SwiftEventBus


class MyUITabBarController : UITabBarController {
    
    struct ViewControllerConfig {
        var toolbar: Bool = true
        var backHome: Bool = true
    }
    
    var config: ViewControllerConfig = ViewControllerConfig()
    
    override func viewDidLoad() {
        InComingDataParser.openViewEventBus(controller: self)
    }
    
    
}


class MainV2TabBarController: MyUITabBarController, UITabBarControllerDelegate, BottomOptLauncherDelegate {
    

    lazy var bottomOptionsLauncher: BottomOptLauncher = {
        let launcher = BottomOptLauncher()
        launcher.delegate = self
        return launcher
    }()

    func onItemPressed(option: OptItem) {
        
        if option.id == MenuIDList.CATEGORIES{
            
            startCategoriesList()
            
        }else if option.id == MenuIDList.LOGOUT{
            
            if Session.logout() {
                self.bottomOptionsLauncher.load()
            }
            
        }else if option.id == MenuIDList.CHAT_LOGIN{
            if Session.isLogged() == false {
                 self.startLoginVC()
            }
        }else if option.id == MenuIDList.PEOPLE_AROUND_ME {
            
            let sb = UIStoryboard(name: "PeopleList", bundle: nil)
            
             let vc: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
                           navigationController?.pushViewController(vc, animated: true)
            
        }else if option.id == MenuIDList.GEO_STORES {
            
            let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if option.id == MenuIDList.FAVOURITES {
            
            if(Session.isLogged()){
                startFavoritesList()
            }else{
                startLoginVC()
            }
            
            
        }else if option.id == MenuIDList.EDIT_PROFILE {
            
            if Session.isLogged(){
                startEditProfileVC()
            }
            
        }else if option.id == MenuIDList.ABOUT {
            
            startAboutVC()
            
        }else if option.id == MenuIDList.SETTING {
            
            self.startSettingVC()
            
        }else if option.id == MenuIDList.MANAGE_STORES{
            
            startBusinessManager()
            
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(AppStyle.isDarkModeEnabled){
            tabBar.isTranslucent = true
            //tabBar.barTintColor = Colors.Appearance.white.withAlphaComponent(0.1)
        }else{
            tabBar.isTranslucent = true
            tabBar.barTintColor = Colors.Appearance.white
        }
       
    
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        self.setup()
        
        self.delegate = self
        
        
        setupMenu()
    
        
        
         SwiftEventBus.onMainThread(self, name: "on_main_refresh") { result in
            if let _ = result?.object{
                self.setupMenu()
            }
        }
        
    }
    
    var last_selected_tab = 0
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
       
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
        let page = AppStyle.TabsV2.Pages[tabBarController.selectedIndex]
        
        if page.name == AppStyle.TabsV2.Tags.TAG_MORE{
            
            self.bottomOptionsLauncher.showOptions()
            
            tabBarController.selectedIndex = last_selected_tab
          
        }else if page.name == AppStyle.TabsV2.Tags.TAG_NOTIFICATION{
            
            
            //tabBarController.selectedIndex = last_selected_tab
            
             startNotificationVC()
             tabBarController.selectedIndex = last_selected_tab
            
        }else if page.name == AppStyle.TabsV2.Tags.TAG_ACCOUNT{
            
           // tabBarController.selectedIndex = last_selected_tab
            if !Session.isLogged(){
                  startLoginVC()
            }else{
                 startEditProfileVC()
            }
         
             tabBarController.selectedIndex = last_selected_tab
            
        }else{
            last_selected_tab = tabBarController.selectedIndex
        }
      
        
    }
    
    
    func setupMenu() {
        
        
        bottomOptionsLauncher.settings = []
        bottomOptionsLauncher.index = 0
        
    
        bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.GEO_STORES,
            name: "Geo Stores".localized,
            image: bottomOptionsLauncher.createIcon(.ionicons(.map))
        ))
        
        if Session.isLogged() {
            
            bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.PEOPLE_AROUND_ME,
                name: "People around me".localized,
                image: bottomOptionsLauncher.createIcon(.ionicons(.iosPeople))
            ))
            
        }else{
            
            bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.CHAT_LOGIN,
                name: "Chat login".localized,
                image: bottomOptionsLauncher.createIcon(.ionicons(.chatbubbles))
            ))
        }
        
        
        bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
                     id: MenuIDList.MANAGE_STORES,
                     name: "Manage your business".localized,
                     image: bottomOptionsLauncher.createIcon(.fontAwesome(.briefcase))
        ))
        
        

        if Session.isLogged() {
        
            
            bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.EDIT_PROFILE,
                name: "Edit Profile".localized,
                image: bottomOptionsLauncher.createIcon(.ionicons(.iosContact))
            ))
            
            bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.LOGOUT,
                name: "Log out".localized,
                image: bottomOptionsLauncher.createIcon(.ionicons(.logOut))
            ))
            
        }
        
        
        bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.ABOUT,
            name: "About us".localized,
            image: bottomOptionsLauncher.createIcon(.ionicons(.iosInformation))
        ))
        
        bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.SETTING,
            name: "Setting".localized,
            image: bottomOptionsLauncher.createIcon(.ionicons(.iosSettingsStrong))
        ))
        
        
        bottomOptionsLauncher.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.CLOSE,
            name: "Cancel".localized,
            image: bottomOptionsLauncher.createIcon(.ionicons(.close))
        ))
        
        bottomOptionsLauncher.collectionView.reloadData()
        
    }


    func setup() {
        
        var vc_list: [UIViewController] = []
       
        
        for key in 0...AppStyle.TabsV2.Pages.count-1 {
            
            let page = AppStyle.TabsV2.Pages[key]
            
            if  page.name == AppStyle.TabsV2.Tags.TAG_HOME{
                
                let vc = mainController(config: page)
                vc_list.append(vc)
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_CATEGORIES{
                
                 let vc = categoriesController(config: page)
                vc_list.append(vc)
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_SETTING{
                
                let vc = settingController(config: page)
                vc_list.append(vc)
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_ACCOUNT{
                
                let vc = loginController(config: page)
                vc_list.append(vc)
                
              
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_NOTIFICATION{
                
                let vc = notificationController(config: page)
                vc_list.append(vc)
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_MORE{
                
                let vc = moreController(config: page)
                vc_list.append(vc)
                
            }else if  page.name == AppStyle.TabsV2.Tags.TAG_FAVORITES{
                
                let vc = favoritesController(config: page)
                vc_list.append(vc)
                
            }
            
        }
        
        
        viewControllers = vc_list
       

        
    }
    
    
    func mainController(config: NSv2Page) -> UIViewController {

        // setup main controller
        let main_vc = MainV2Controller.newInstance()
        main_vc.config.backHome = false
        
        let main_navigation_vc = UINavigationController(rootViewController: main_vc)
        
        var mainIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.black)
        let mainIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        if(!AppStyle.isDarkModeEnabled){
            mainIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        }
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.title = config.name?.localized
        main_navigation_vc.view.backgroundColor = .green
        //////////////////////////////
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return main_navigation_vc
    }
    
    func settingController(config: NSv2Page) -> UIViewController {
        
        // setup main controller
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let ms: SettingsViewController = sb.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        //ms.navigationController?.isToolbarHidden = false
        
        
        let main_navigation_vc = UINavigationController(rootViewController: ms)
        
        let mainIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let mainIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.title = config.name?.localized
        
        //////////////////////////////
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return main_navigation_vc
    }
    
    
    func loginController(config: NSv2Page) -> UIViewController {
        
        //setup login account
        let login_vc = LoginViewController.newInstance()
        
        login_vc.config.backHome = false
        login_vc.config.customToolbar = true
        
        let login_navigation_vc = UINavigationController(rootViewController: login_vc)
        
        let loginIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let loginIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        login_navigation_vc.tabBarItem.image = loginIconSelected
        login_navigation_vc.tabBarItem.selectedImage = loginIconUnelected
        login_navigation_vc.tabBarItem.title = config.name?.localized
        
        //////////////////////////////
        login_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return login_navigation_vc
        
    }

    
    func profileController(config: NSv2Page) -> UIViewController {
        
        
        //setup login account
        let profile_vc = EditProfileViewController.newInstance()
        profile_vc.config.backHome = false
        
        
        let profile_navigation_vc = UINavigationController(rootViewController: profile_vc)
        
        let profileIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let profileIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        profile_navigation_vc.tabBarItem.image = profileIconSelected
        profile_navigation_vc.tabBarItem.selectedImage = profileIconUnelected
        profile_navigation_vc.tabBarItem.title = config.name!.localized
        //////////////////////////////
        profile_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return profile_navigation_vc
        
    }
  

    
    func categoriesController(config: NSv2Page) -> UIViewController {
        
        //setup categories
        let categories_vc = CategoriesViewController.newInstance()
        
        categories_vc.config.backHome = false
        
        let categories_navigation_vc = UINavigationController(rootViewController: categories_vc)
        
        let catIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let catIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        categories_navigation_vc.tabBarItem.image = catIconUnelected
        categories_navigation_vc.tabBarItem.selectedImage = catIconSelected
        categories_navigation_vc.tabBarItem.title = config.name!.localized
        //////////////////////////////
        
        
        categories_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return categories_navigation_vc
        
    }
    
  
    func notificationController(config: NSv2Page) -> UIViewController {
        
        //setup categories
        let notification_vc = NotificationViewController.newInstance()
        notification_vc.config.backHome = false
        
        notification_vc.config.backHome = false
        notification_vc.config.customToolbar = true
        
        let notification_navigation_vc = UINavigationController(rootViewController: notification_vc)
        
        let notificationIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let notificationIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 26, height: 26), textColor: .gray)
        
        notification_navigation_vc.tabBarItem.image = notificationIconSelected
        notification_navigation_vc.tabBarItem.selectedImage = notificationIconUnelected
        
        
        let count = Messenger.nbrMessagesNotSeen+Notification.unread_notifications

        if count > 0{
            notification_navigation_vc.tabBarItem.badgeValue = "\(count)"
        }else{
            notification_navigation_vc.tabBarItem.badgeValue = nil
        }
        

        notification_navigation_vc.tabBarItem.title = config.name!.localized
        
        //////////////////////////////
        notification_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return notification_navigation_vc
        
    }
    
  
    func favoritesController(config: NSv2Page) -> UIViewController {
           
           //setup categories
            let vc = MyFavoritesViewController.newInstance()
          
           vc.config.backHome = false
           vc.config.customToolbar = true
           
           
           let navigation_vc = UINavigationController(rootViewController: vc)
           
           let iconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 32, height: 32), textColor: Colors.Appearance.primaryColor)
           let iconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 32, height: 32), textColor: .gray)
           
           navigation_vc.tabBarItem.image = iconUnelected
           navigation_vc.tabBarItem.selectedImage = iconSelected
           navigation_vc.tabBarItem.title = config.name!.localized
           
           //////////////////////////////
           navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
           
           return navigation_vc
           
       }
    
    
    func moreController(config: NSv2Page) -> UIViewController {
        
        //setup categories
        let more_sb = UIStoryboard(name: "Discussion", bundle: nil)
        let more_vc: DiscussionViewController = more_sb.instantiateViewController(withIdentifier: "discussionListVC") as! DiscussionViewController
       
        more_vc.config.backHome = false
        more_vc.config.customToolbar = true
        
        
        let more_navigation_vc = UINavigationController(rootViewController: more_vc)
        
        let moreIconSelected = UIImage.init(icon: config.icon!, size: CGSize(width: 32, height: 32), textColor: Colors.Appearance.primaryColor)
        let moreIconUnelected = UIImage.init(icon: config.icon!, size: CGSize(width: 32, height: 32), textColor: .gray)
        
        more_navigation_vc.tabBarItem.image = moreIconUnelected
        more_navigation_vc.tabBarItem.selectedImage = moreIconSelected
        more_navigation_vc.tabBarItem.title = config.name!.localized
        
        //////////////////////////////
        more_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        return more_navigation_vc
        
    }
    
   
    
    //////////// start viewControllers launcher
    
    func startLoginVC() {
        
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        navigationController?.pushViewController(ms, animated: true)
        
    }
    
    
    func startSignUpVC() {
        
        let sb = UIStoryboard(name: "SignUp", bundle: nil)
        let ms: SignUpViewController = sb.instantiateViewController(withIdentifier: "signupVC") as! SignUpViewController
        navigationController?.pushViewController(ms, animated: true)
        
    }
    
    func startNotificationVC() {
        
        
        let vc = NotificationTabBarController()
        vc.config.backHome = true
        vc.config.toolbar = true
        
        let main = UINavigationController(rootViewController:  vc)
        //self.navigationController?.pushViewController(main, animated: true)
        //main.setNavigationBarHidden(true, animated: true)
        main.navigationBar.isHidden = true
        
        
        navigationController?.pushViewController( vc, animated: true)
        
    }
    
    func startEditProfileVC() {

        
        let vc = EditProfileV2TabBarController()
        vc.config.backHome = true
        vc.config.toolbar = true
        
        let main = UINavigationController(rootViewController:  vc)
        //self.navigationController?.pushViewController(main, animated: true)
        //main.setNavigationBarHidden(true, animated: true)
        main.navigationBar.isHidden = true
        

        navigationController?.pushViewController( EditProfileV2TabBarController(), animated: true)
        
    }
    
    func startFavoritesList()  {
        
        let vc = MyFavoritesViewController.newInstance()
        
        vc.config.backHome = true
        vc.config.customToolbar = true
                   
        navigationController?.pushViewController( vc, animated: true)
                   
    }
    
    func startMessenger(client_id: Int,discussion_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            ms.discussionId = discussion_id
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    func startMessenger(client_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    func startPeopleList() {
        
        let sb = UIStoryboard(name: "PeopleList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            let vc: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    func startStoreDetailVC(store_id: Int) {
        
        let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
            ms.storeId = store_id
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    
    
    func startStoresList(request: String) {
        
        let sb = UIStoryboard(name: "ResultList", bundle: nil)
        let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
             
        ms.config.backHome = true
        ms.config.customToolbar = true
             
        ms.current_module = AppConfig.Tabs.Tags.TAG_STORES
                  
        ms.request = request
                   
        navigationController?.pushViewController(ms, animated: true)
        
        
            
    }
    
    func startCategoriesList() {
        
        let sb = UIStoryboard(name: "Categories", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: CategoriesViewController = sb.instantiateViewController(withIdentifier: "categoriesVC") as! CategoriesViewController
            
            self.navigationController!.pushViewController(ms, animated: true)
            
            
        }
        
        
        
        
        
        
        
    }
    
    
    func startOfferDetailVC(offerId: Int) {
        
        let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
            
            ms.offer_id = offerId
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    
    func startEventDetailVC(eventId: Int) {
        
        let sb = UIStoryboard(name: "EventDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController
            
            ms.event_id = eventId
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    
    func startEventsListVC(request: String) {
        
        let sb = UIStoryboard(name: "EventsList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: EventsLsitViewController = sb.instantiateViewController(withIdentifier: "eventslistVC") as! EventsLsitViewController
            
            ms.__req_list_order = request
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    
    func startAboutVC() {
        
        let sb = UIStoryboard(name: "About", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: AboutViewController = sb.instantiateViewController(withIdentifier: "aboutVC") as! AboutViewController
            
            navigationController?.pushViewController(ms, animated: true)
        }
        
    }
    
    
    func startSettingVC() {
        
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let ms: SettingsViewController = sb.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        
        //ms.navigationController?.isToolbarHidden = true
        //ms.navigationController?.navigationBar.isHidden = false
        
        navigationController?.pushViewController(ms, animated: true)
        
    }

    
    func startBusinessManager()  {
          
          let sb = UIStoryboard(name: "BusinessManager", bundle: nil)
          
          let ms: BusinessManagerViewcController = sb.instantiateViewController(withIdentifier: "busniss_manager_vc") as! BusinessManagerViewcController
          
          ms.config.backHome = true
          ms.config.customToolbar = true
          
          if let controller = self.navigationController{
              controller.pushViewController(ms, animated: true)
          }else{
               self.present(ms, animated: true)
          }
         
         
      }

 
}




struct NSv2Page {
    
    var icon: FontType? = nil
    var name: String? = nil
    //var vc: UIViewController? = nil
    
    init(name: String,icon: FontType) {
        self.icon = icon
        self.name = name
    }
    
    init(name: String,icon: FontType, vc: UIViewController.Type) {
        self.icon = icon
        self.name = name
        // self.vc = vc
    }
    
}
