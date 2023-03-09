//
//  Categories_HCards.swift
//  NearbyCategories
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit

class Categories_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CategoryLoaderDelegate{
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBOutlet weak var h_header: UIView!
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_collection: UICollectionView!
    @IBOutlet weak var h_showAll: UIButton!
    
    @IBAction func showAllAction(_ sender: Any) {
        
        let sb = UIStoryboard(name: "Categories", bundle: nil)
        let ms: CategoriesViewController = sb.instantiateViewController(withIdentifier: "categoriesVC") as! CategoriesViewController
        
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
    
    
    var style: CardHorizontalStyle?
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
    
    static func newInstance(style: CardHorizontalStyle) -> UIView{
        
        //load xib
        let mCategories_HCards = instanceFromNib(name: "Categories_HCards") as! Categories_HCards
        
        mCategories_HCards.style = style
        mCategories_HCards.setup()
        
        mCategories_HCards.h_header.backgroundColor =  .clear
        
        return mCategories_HCards
        
    }
    
    
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
    
    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Category] = [Category]()
    
    
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
        h_collection.register(UINib(nibName: "CategoryCardCell", bundle: nil), forCellWithReuseIdentifier: "categoryCardCellId")
        
        h_collection.isScrollEnabled = true
       
        
        h_showAll.isHidden = true
        
        self.load()
        //self.test()
    }
    
    func test() {
        
        let category = Category()
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        self.LIST.append(category)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: CategoryCardCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCardCellId", for: indexPath) as! CategoryCardCell
        
        if let style = self.style{
            
            cell.setting(style: style)
            
            let object = LIST[indexPath.row]
            
            if object.numCat > 0{
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
    
    
    
    
   
    
    
    static let header_size = Float(50)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let style = self.style, let height = style.height, let width = style.width{
            //add 60 for store information
            
            let calculated_height = height-Categories_HCards.header_size
            
            let ratio = Float(height/calculated_height)
            let calculated_width = Float(width/ratio)
            
            return CGSize(width: CGFloat(calculated_width-45),height: CGFloat(calculated_height))
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
        return CGFloat(padding_size)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cat = self.LIST[indexPath.row].numCat
        
        startResultController(cat_id: cat)
        
        
    }
    
    
    func startResultController(cat_id: Int) {
        
        
        let sb = UIStoryboard(name: "ResultList", bundle: nil)
        let ms: ResultListViewController = sb.instantiateViewController(withIdentifier: "resultlistVC") as! ResultListViewController
        
        
        ms.current_module = AppConfig.Tabs.Tags.TAG_STORES
        ms.request = ListStoresCell.StoresListRequestOrder.nearby
        
        if let cat = Category.findById(id: cat_id){
            ms.config.custom_title = cat.nameCat
        }
        
        ms.config.backHome = true
        ms.config.customToolbar = true
        
        ms.parameters["__req_category"] = String(cat_id)
        
        if let controller = viewTabBarController{
             controller.navigationController?.pushViewController(ms, animated: true)
        }else if let controller = viewNavigationController{
            controller.pushViewController(ms, animated: true)
        }else if let controller = viewController{
             controller.present(ms, animated: true)
        }
        
        
    }
    

    
    //API
    
    var categoryLoader: CategoryLoader = CategoryLoader()
    
    func load () {
        
        make_as_loader()
        
        self.categoryLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "8"
        ]
        
        
        
        parameters["page"] = String(describing: self.__req_page)
        
        Utils.printDebug("\(parameters)")
        
 
        self.categoryLoader.load(url: Constances.Api.API_USER_GET_CATEGORY,parameters: parameters)
        
        
    }
    
    
    func success(parser: CategoryParser,response: String) {
        
        make_as_result()
    
        if parser.success == 1 {
            
            
            let categories = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if(GLOBAL_COUNT>6){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn()
                }
            }
            
            if categories.count > 0 {
                
                Utils.printDebug("We loaded \(categories.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = categories
                }else{
                    self.LIST += categories
                }
                
                self.h_collection.reloadData()
                
                
                //start scrolling from the first item
                if self.__req_page  == 1 && Utils.isRTL(){
                    h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
                }
                
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
                
                Utils.printDebug("===> Request Error with Messages! ListCategories")
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
        
        
        
        Utils.printDebug("===> Request Error! ListCategories")
        Utils.printDebug("\(response)")
        
    }
    
    
    
}

extension Categories_HCards{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Category()
        for _ in 0...5{
            self.LIST.append(object)
        }
        
        self.h_collection.reloadData()
        
        
        //start scrolling from the first item
        if Utils.isRTL(){
            h_collection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: false)
        }
        
        self.h_collection.isScrollEnabled = false
     
        
    }
    
    func make_as_result() {
        
        self.LIST = []
        self.h_collection.reloadData()
        self.h_collection.isScrollEnabled = true
    }
    
}

