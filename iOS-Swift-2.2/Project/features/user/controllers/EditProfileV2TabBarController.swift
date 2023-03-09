
//
//  MainV2TabBarController.swift
//  NearbyStores
//
//  Created by Amine  on 8/18/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import SwiftIcons


class EditProfileV2TabBarController: MyUITabBarController, EditProfileControllerDelegate, EditProfilePasswordControllerDelegate {
    
    
    func editPasswordSuccess(controller: EditProfilePasswordViewController, user: User) {
        
    }
    
    func editPasswordFaild(controller: EditProfilePasswordViewController) {
        
    }
    
    func onBackPressed(controller: EditProfilePasswordViewController) {
        
        if let _controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            _controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
        
    }
    
    
    
    func editProfilSuccess(controller: EditProfileViewController, user: User) {
        self.showAlert(title: "Success",content: ["msg": "Your profile was updated successful!".localized],msgBnt: "OK")
    }
    
    func editProfileFaild(controller: EditProfileViewController) {
        
    }
    
    func onBackPressed(controller: EditProfileViewController) {
        
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
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        self.setup()
        
        
    }
    
    var last_selected_tab = 0
    
    func setup() {
        
        let vc1 = editUserInformation()
        let vc3 = editUserPassword()
     
        viewControllers = [vc1,vc3]
        
    }
    
    
    func editUserInformation() -> UIViewController {
        
        // setup main controller
        let main_sb = UIStoryboard(name: "EditProfile", bundle: nil)
        let main_vc: EditProfileViewController = main_sb.instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileViewController
        
        main_vc.config.backHome = true
        
        main_vc.delegate = self
        
        let main_navigation_vc = UINavigationController(rootViewController: main_vc)
        
        let mainIconSelected = UIImage.init(icon: .linearIcons(.user), size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let mainIconUnelected = UIImage.init(icon: .linearIcons(.user), size: CGSize(width: 26, height: 26), textColor: .gray)
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        main_navigation_vc.tabBarItem.title = "Edit Profile".localized
        
        //////////////////////////////
        
        return main_navigation_vc
    }
    
    
    func editUserPassword() -> UIViewController {
        
        // setup main controller
        let main_sb = UIStoryboard(name: "EditProfilePassword", bundle: nil)
        let main_vc: EditProfilePasswordViewController = main_sb.instantiateViewController(withIdentifier: "editprofilepsswdVC") as! EditProfilePasswordViewController
        
        main_vc.config.backHome = true
        main_vc.delegate = self
        
        let main_navigation_vc = UINavigationController(rootViewController: main_vc)
        
        let mainIconSelected = UIImage.init(icon: .linearIcons(.lock), size: CGSize(width: 26, height: 26), textColor: Colors.Appearance.primaryColor)
        let mainIconUnelected = UIImage.init(icon: .linearIcons(.lock), size: CGSize(width: 26, height: 26), textColor: .gray)
        
        main_navigation_vc.tabBarItem.image = mainIconUnelected.withRenderingMode(.alwaysOriginal)
        main_navigation_vc.tabBarItem.selectedImage = mainIconSelected.withRenderingMode(.alwaysOriginal)
        
        main_navigation_vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        main_navigation_vc.tabBarItem.title = "Change Password".localized
        
        //////////////////////////////
        
        return main_navigation_vc
    }
    
 
    
}




