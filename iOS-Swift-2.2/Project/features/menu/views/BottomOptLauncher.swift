//
//  SettingsLauncher.swift
//  youtube
//
//  Created by Brian Voong on 6/17/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import SwiftIcons
import AssistantKit

class OptItem: NSObject {
    let name: String
    let image: UIImage
    let id: Int
    
    init(id: Int,name: String, image: UIImage) {
        self.name = name
        self.image = image
        self.id = id
    }
}

protocol BottomOptLauncherDelegate {
    func onItemPressed(option: OptItem)
}

class BottomOptLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
    
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    var settings: [OptItem] = {
        return []
    }()
    
    var delegate: BottomOptLauncherDelegate? = nil
   
    func load() {
        
        self.index = 0
        
        self.settings = []
        
      
        
        self.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.GEO_STORES,
            name: "Geo Stores".localized,
            image: createIcon(.ionicons(.map))
        ))
        
        if Session.isLogged() {
            
            self.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.PEOPLE_AROUND_ME,
                name: "People around me".localized,
                image: createIcon(.ionicons(.iosPeople))
            ))
            
        }else{
            
            self.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.CHAT_LOGIN,
                name: "Chat login".localized,
                image: createIcon(.ionicons(.chatbubbles))
            ))
        }
    
        
        
        self.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.MANAGE_STORES,
            name: "Manage your business".localized,
            image: createIcon(.ionicons(.iosBriefcase))
        ))
        
        if Session.isLogged() {
            
            self.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.EDIT_PROFILE,
                name: "Edit Profile".localized,
                image: createIcon(.ionicons(.iosContact))
            ))
            
            self.addBottomMenuItem(setting: OptItem(
                id: MenuIDList.LOGOUT,
                name: "Log out".localized,
                image: createIcon(.ionicons(.logOut))
            ))
            
        }
        
        
        self.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.ABOUT,
            name: "About us".localized,
            image: createIcon(.ionicons(.iosInformation))
        ))
        
        self.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.SETTING,
            name: "Setting".localized,
            image: createIcon(.ionicons(.iosSettingsStrong))
        ))
        
        
        self.addBottomMenuItem(setting: OptItem(
            id: MenuIDList.CLOSE,
            name: "Cancel".localized,
            image: createIcon(.ionicons(.close))
        ))
        
        collectionView.reloadData()
        
    }
    
    func showOptions() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(option: OptItem) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }
            
        }) { (completed: Bool) in
            if option.id != MenuIDList.CLOSE {
                if let del = self.delegate{
                    del.onItemPressed(option: option)
                }
            }
        }
    }
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SettingCell
        
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if Device.isPhone{
            return CGSize(width: collectionView.frame.width,height: cellHeight)
        }else if Device.isPad{
            
            return CGSize(width: collectionView.frame.width/1.5,height: cellHeight)
        }else{
            
            return CGSize(width: collectionView.frame.width,height: cellHeight)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let setting = self.settings[indexPath.item]
        handleDismiss(option: setting)
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
        
        load()
       
    }
    
    
    
    var index = 0
    func addBottomMenuItem(setting: OptItem)  {
        
        if AppConfig.Menu.list[setting.id] == true {
            self.settings.insert(setting, at: index)
            index += 1
        }
        
    }
    
    func createIcon(_ icon: FontType) -> UIImage {
        return UIImage.init(icon: icon, size: CGSize(width: 25, height: 25), textColor: UIColor.darkGray)
    }
    

    
}

struct MenuIDList {
    static let CATEGORIES = 1
    static let GEO_STORES = 2
    static let CHAT_LOGIN = 3
    static let PEOPLE_AROUND_ME = 4
    static let FAVOURITES = 5
    static let MY_EVENTS = 6
    static let EDIT_PROFILE = 7
    static let LOGOUT = 8
    static let MANAGE_STORES = 9
    static let SETTING = 10
    static let ABOUT = 11
    static let CLOSE = -1
    
}







