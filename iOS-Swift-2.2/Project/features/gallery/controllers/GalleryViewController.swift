//
//  GalleryViewController.swift
//  NearbyStores
//
//  Created by Amine on 10/22/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit


class GalleryViewController: MyUIViewController {
    
    
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
    
    
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    
    var module_id: Int? = nil
    var type: String? = nil
    
    //request
    var __req_page: Int = 1
    var __req_limit: Int = 30
    
    
    
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
      
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        
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
        
        topBarTitle.text = "Gallery".localized
        
        navigationBarItem.titleView = topBarTitle
        
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
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        
        
        
        if let id = self.module_id, let type = self.type{
            
            let galleryView = StoreGalleryListView()
            mainContainer.addSubview(galleryView)
            galleryView.setPosition(parent: mainContainer)
            
            galleryView.module_id = id
            galleryView.type = type
            galleryView.short_mode = false
            galleryView.vc = self
            
            galleryView.loadGallery(module_id: id, type: type)
            
            
        }
        
        
        
    }
    
}
