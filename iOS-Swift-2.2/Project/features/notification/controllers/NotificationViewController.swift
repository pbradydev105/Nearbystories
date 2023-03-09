//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit


protocol NotificationViewControllerDelegate {
    func onBackPressed(controller: NotificationViewController)
}


class NotificationViewController: MyUIViewController{
    
    var delegate: NotificationViewControllerDelegate? = nil
    
    
    static func newInstance() -> NotificationViewController{
        let notification_sb = UIStoryboard(name: "Notification", bundle: nil)
        let notification_vc: NotificationViewController = notification_sb.instantiateViewController(withIdentifier: "notificationVC") as! NotificationViewController
        return notification_vc
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let controller = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
        
        NotificationViewController.isAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let controller = self.navigationController, config.customToolbar == true{
            controller.navigationBar.isHidden = true
        }
        
         NotificationViewController.isAppear = true
    }

    static var isAppear = false
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var viewContainer: UIView!
    
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
        
    
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        if(config.backHome ==  true){
             navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        }
       
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        
        //init list notification
        listNotificationSetup();
      
        
        SwiftEventBus.post("on_badge_refresh",sender: true)
    
        
    }
    
    
    private func listNotificationSetup() {
        
        let view = ListNotificationCell();
        self.viewContainer.addSubview(view)
        self.viewContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: view)
        self.viewContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: view)
        
        
        
              
        if let controller = tabBarController{
            view.viewTabBarController = controller
        }else if let controller = navigationController{
            view.viewNavigationController = controller
        }else{
            view.viewController = self
        }
              
             
        if view.isFetched  == false {
            view.fetch(request: ListNotificationCell.Request.nearby)
        }
              
        view.checker()
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
        
        topBarTitle.text = "Notifications".localized
        
        navigationBarItem.titleView = topBarTitle
    
    }
    
    @objc func onBackHandler() {
        
        if let controller = self.tabBarController{
            //controller.navigationBar.isHidden = true
            controller.dismiss(animated: true)
            ////controller.navigationBar.isHidden = false
        }else if let controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
        
        //SwiftEventBus.post("on_main_refresh", sender: true)
        
        
        if let del = delegate{
            del.onBackPressed(controller: self)
        }
    }
    
  
    
    
   /*
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let cellId = AppConfig.Tabs.Tags.TAG_INBOX
        let cell: ListNotificationCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListNotificationCell
        
        
        if let controller = tabBarController{
            cell.viewTabBarController = controller
        }else if let controller = navigationController{
            cell.viewNavigationController = controller
        }else{
            cell.viewController = self
        }
        
        
        cell.setupViews()
        
        if cell.isFetched  == false {
            cell.fetch(request: ListNotificationCell.Request.nearby)
        }
        
        cell.checker()
        
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
         return CGSize(width: view.frame.width ,height: view.frame.height-50-60)
        
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
        
        //item = 10, count = 10 , COUNT = 23
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }*/
    
  
    
}




