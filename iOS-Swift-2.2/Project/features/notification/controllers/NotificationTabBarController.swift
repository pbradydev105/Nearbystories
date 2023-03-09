
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


class NotificationTabBarController: MyUITabBarController, NotificationViewControllerDelegate, DiscussionViewControllerDelegate {
   
    
    func onBackPressed(controller: NotificationViewController) {
        if let _controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            _controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
    }
    
    func onBackPressed(controller: DiscussionViewController) {
        if let _controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            _controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(AppStyle.isDarkModeEnabled){
            tabBar.isTranslucent = true
            self.tabBar.barTintColor = Colors.Appearance.white
           
        }else{
           tabBar.isTranslucent = false
            self.tabBar.barTintColor = .white
         }
        
         self.view.backgroundColor = Colors.Appearance.darkColor
        
        
        /*SwiftEventBus.onMainThread(self, name: "on_badge_refresh") { result in
            
            if let _ = result?.object{
                
                
               
                
              
            }
            
        }*/
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        self.setup()
        
    
        
    }
    
    var last_selected_tab = 0
    
    func setup() {
        
        let vc1 = notificationController()
        let vc3 = inboxController()
     
        viewControllers = [vc1,vc3]
        
    }
    
    
    func inboxController() -> UIViewController {
        
        // setup main controller
        let main_sb = UIStoryboard(name: "Discussion", bundle: nil)
        let main_vc: DiscussionViewController = main_sb.instantiateViewController(withIdentifier: "discussionListVC") as! DiscussionViewController
        
        main_vc.config.backHome = true
        
        main_vc.delegate = self
        
        let main_navigation_vc = UINavigationController(rootViewController: main_vc)
        
        let mainIconSelected = UIImage.init(icon: .linearIcons(.bubble), size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let mainIconUnelected = UIImage.init(icon: .linearIcons(.bubble), size: CGSize(width: 26, height: 26), textColor: .gray)
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        
        
        
        if Messenger.nbrMessagesNotSeen > 0{
            main_navigation_vc.tabBarItem.badgeValue = "\(Messenger.nbrMessagesNotSeen)"
        }
        
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        main_navigation_vc.tabBarItem.title = "Inbox".localized
        
        //////////////////////////////
        
        return main_navigation_vc
    }
    
    
    func notificationController() -> UIViewController {
        
        // setup main controller
        let main_sb = UIStoryboard(name: "Notification", bundle: nil)
        let main_vc: NotificationViewController = main_sb.instantiateViewController(withIdentifier: "notificationVC") as! NotificationViewController
        
        main_vc.config.backHome = true
        
        main_vc.delegate = self
        
        let main_navigation_vc = UINavigationController(rootViewController: main_vc)
        
        let mainIconSelected = UIImage.init(icon: .linearIcons(.alarm), size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let mainIconUnelected = UIImage.init(icon: .linearIcons(.alarm), size: CGSize(width: 26, height: 26), textColor: .gray)
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        
        if Notification.unread_notifications > 0{
             main_navigation_vc.tabBarItem.badgeValue = "\(Notification.unread_notifications)"
        }
        
    
        Utils.printDebug("Unread Notification:\(Notification.unread_notifications)")
                 
       
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        main_navigation_vc.tabBarItem.title = "Notification".localized
        
        //////////////////////////////
        
        return main_navigation_vc
    }
    

}




