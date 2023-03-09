//
//  Users_HCards.swift
//  NearbyUsers
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit

class Users_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UserLoaderDelegate{
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBOutlet weak var h_header: UIView!
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_collection: UICollectionView!
    @IBOutlet weak var h_showAll: UIButton!
    
    @IBAction func showAllAction(_ sender: Any) {
        
        if let style = self.style{
            
            let sb = UIStoryboard(name: "PeopleList", bundle: nil)
            let ms: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
            
            if style.type == CardHorizontalViewTypes.Nearby_Users{
                //ms.request = Request.nearby
            }
            
            ms.config.backHome = true
            ms.config.customToolbar = true
            
            if let controller = self.viewController{
                
                controller.present(ms, animated: true)
                
            }else if let controller = self.viewNavigationController{
                
                controller.pushViewController(ms, animated: true)
                
            }else if let controller = self.viewTabBarController{
                
                controller.navigationController?.pushViewController(ms, animated: true)
            }
            
        }
        
    }
    
    var style: CardHorizontalStyle?
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
    
    static func newInstance(style: CardHorizontalStyle) -> UIView{
        
        //load xib
        let mUsers_HCards = instanceFromNib(name: "Users_HCards") as! Users_HCards
        
        mUsers_HCards.style = style
        mUsers_HCards.setup()
        
        mUsers_HCards.h_header.backgroundColor =  .clear
        
        return mUsers_HCards
        
    }
    
    
    enum Request {
        static let nearby = 0
        static let saved = -1
    }
    
    //request
    var __req_user: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list: Int = Request.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
    
    var __req_store: Int = 0
    
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [User] = [User]()
    
    
    let padding_size = CGFloat(20)
    
    func setup(){
        
        
        self.backgroundColor = .clear
        
        
        self.h_label.leftTextInset = padding_size
        self.h_label.rightTextInset = padding_size
        self.h_label.initBolodFont(size: 18)
        self.h_showAll.initItalicFont()
    
        self.h_showAll.setTitleColor(.black, for: .normal)
        self.h_showAll.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        self.h_showAll.setupShowMore()
               
        
        
        
        if let flowLayout = h_collection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            layoutIfNeeded()
        }
        
        
        
        h_collection.contentInset = UIEdgeInsets(top: padding_size, left: padding_size, bottom: padding_size, right: padding_size)
        
        h_collection.dataSource = self
        h_collection.delegate = self
        h_collection.showsHorizontalScrollIndicator = false
        
        h_collection.backgroundColor = .clear
        h_collection.register(UINib(nibName: "UserCardCell", bundle: nil), forCellWithReuseIdentifier: "userCardCellId")
        
        h_collection.isScrollEnabled = true
        
        h_showAll.isHidden = true
        
       
        self.load()
        //self.test()
    }
    
    func test() {
        
        let user = User()
        self.LIST.append(user)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: UserCardCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "userCardCellId", for: indexPath) as! UserCardCell
        
        if let style = self.style{
            cell.setting(style: style)
            
            let object = LIST[indexPath.row]
            
            if object.id > 0{
                cell.setup(object: object)
            }else{
                
                cell.setup(object: nil)
                
                //start scrolling from the first item
                if Utils.isRTL(){
                    h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
                }
            }
            
        }
        
        return cell
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          
        if(!Session.isLogged()){
            
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                                             
            if let controller = self.viewController {
                           controller.present(ms, animated: true)
            }else if let controller = self.viewNavigationController{
                           controller.pushViewController(ms, animated: true)
            }else if let controller = self.viewTabBarController{
                           controller.navigationController?.pushViewController(ms, animated: true)
            }
            
            return
        }
        
        
          let sb = UIStoryboard(name: "Messenger", bundle: nil)
          let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = self.LIST[indexPath.row].id
          
            ms.config.backHome = true
            ms.config.customToolbar = true
                     
            if let controller = self.viewController {
                controller.present(ms, animated: true)
            }else if let controller = self.viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }else if let controller = self.viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }
          
      }
    
    
    /*func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
     
     
     let ocount = LIST.count-1
     
     guard ocount >= 0 else { return }
     
     var index = targetContentOffset.move().x / self.frame.width
     
     if Utils.isRTL(){
     index = CGFloat( (index-CGFloat(ocount)) * CGFloat(-1) )
     }
     
     let indexPath = IndexPath(item: Int(index), section: 0)
     h_collection.scrollToItem(at: indexPath, at: .left, animated: true)
     
     
     }*/
    
    static let header_size = Float(50)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let style = self.style, let height = style.height, let width = style.width{
            //add 60 for store information
            
            let calculated_height = height-Users_HCards.header_size
            
            let ratio = Float(height/calculated_height)
            let calculated_width = Float(width/ratio)
            
            return CGSize(width: CGFloat(calculated_width-50),height: CGFloat(calculated_height))
        }else{
            return CGSize(width: CGFloat(60) , height: CGFloat(60))
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(padding_size.adaptScreen()/2)
    }
    
    //API
    
    var userLoader: UserLoader = UserLoader()
    
    func load () {
        
        make_as_loader()
        
        self.userLoader.delegate = self
        
        //Get current Location
        

        var parameters = [
            "limit"          : "6"
        ]
        
        if let guest = Guest.getInstance(){
            parameters["lat"] = String(describing: guest.lat)
            parameters["lng"] = String(describing: guest.lng)
        }
        
        if let user = Session.getInstance()?.user{
            parameters["user_id"] = String(describing: user.id)
        }
        
        parameters["page"] = String(describing: self.__req_page)

        
        self.userLoader.load(url: Constances.Api.API_GET_USERS,parameters: parameters)
        
    }
    
    
    func success(parser: UserParser,response: String) {
        
        make_as_result()
    
        if parser.success == 1 {
            
            
            let users = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if(GLOBAL_COUNT>6){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn(duration: 0.1)
                }
            }
            
            if users.count > 0 {
                
                Utils.printDebug("We loaded \(users.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = users
                }else{
                    self.LIST += users
                }
                
                self.h_collection.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                   
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    
                    
                    Utils.printDebug("===> Is Empty!")
                }
                
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListUsers")
                Utils.printDebug("\(errors)")
                
        
                
            }
            
        }
        
    }
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.h_collection.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        
        
        Utils.printDebug("===> Request Error! ListUsers")
        Utils.printDebug("\(response)")
        
    }
    
    
    
}

extension Users_HCards{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = User()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = false
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = true
    }
    
}

