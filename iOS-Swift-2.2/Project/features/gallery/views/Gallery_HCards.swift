//
//  Gallery_HCards.swift
//  NearbyGallery
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit


protocol Gallery_HCards_Delegate {
    func onGalleryloaded(count: Int)
}

class Gallery_HCards: UIView ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, GalleryLoaderDelegate{
    
    
    
    
    var delegate: Gallery_HCards_Delegate? = nil
    
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_collection: UICollectionView!
    @IBOutlet weak var h_showAll: UIButton!
    
    @IBAction func showAllAction(_ sender: Any) {
        
        if let _ = self.style{
            
            let sb = UIStoryboard(name: "GalleryList", bundle: nil)
            let ms: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
            ms.module_id = module_id
            ms.type = type
            
            if let controller = self.viewController{
                controller.present(ms, animated: true)
            }else if let controller = self.viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }else if let controller = self.viewTabBarController{
                controller.present(ms, animated: true)
            }
            
            
        }
        
    }
    
    
    var style: CardHorizontalStyle?
    
    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil
    
    
    static func newInstance(style: CardHorizontalStyle) -> UIView{
        
        //load xib
        let mGallery_HCards = instanceFromNib(name: "Gallery_HCards") as! Gallery_HCards
        
        mGallery_HCards.style = style
        mGallery_HCards.setup()
        
        return mGallery_HCards
        
    }
    
    
    
    
    var module_id: Int = 0
    var type: String = ""

    var short_mode = true
    
    var LIST:[Images] = []
    var GLOBAL_COUNT: Int = 0
    
    
    var nbr_per_line: Int = 1
    
    var req_page: Int = 1
    var req_limit: Int = 6
    
    let padding_size = CGFloat(10)
    
    
    func setup(){
        
        self.h_label.leftTextInset = padding_size+10
        self.h_label.rightTextInset = padding_size+10
        self.h_label.initBolodFont(size: 18)
        
        
        self.h_showAll.initItalicFont()
        self.h_showAll.setTitleColor(.black, for: .normal)
        self.h_showAll.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        self.h_showAll.isHidden = true
        
        
        if let flowLayout = h_collection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            layoutIfNeeded()
        }
        
        
        
        h_collection.contentInset = UIEdgeInsets(top: padding_size, left: padding_size+10, bottom: padding_size, right: padding_size+10)
        
        
        
        h_collection.dataSource = self
        h_collection.delegate = self
        h_collection.showsHorizontalScrollIndicator = false
        
        h_collection.backgroundColor = .clear
        h_collection.register(UINib(nibName: "StoreGalleryCell", bundle: nil), forCellWithReuseIdentifier: "galleryCellId")
        h_collection.isScrollEnabled = true

        
        h_showAll.isHidden = true
        
        
    }
    
    func test() {
        
        let image = Images()
        self.LIST.append(image)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: StoreGalleryCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCellId", for: indexPath) as! StoreGalleryCell
        
        cell.image.roundedCorners(radius: 15)
        
        
        let image = self.LIST[indexPath.row]
        
        
        
        if image.id != "" {
            
            
            cell.list = self.LIST
            cell.position = indexPath.row
            
            if let controller = self.viewController{
                cell.vc = controller
            }else if let controller = self.viewNavigationController{
                cell.vc = controller
            }else if let controller = self.viewTabBarController{
                cell.vc = controller
            }
            
            cell.setup(object: image)
            
            cell.image.isSkeletonable = false
            cell.image.hideSkeleton()
            
        }else{
            
            cell.image.isSkeletonable = true
            cell.image.showAnimatedGradientSkeleton()
            
        }
       
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photos = self.LIST[indexPath.row]
        //photod.save()
        
        if let controller = self.viewController{
            
            let sb = UIStoryboard(name: "GalleryList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
                ms.module_id = 1
                ms.type = "store"
                
                controller.present(ms, animated: true)
            }
        }else if let controller = self.viewNavigationController{
            
            let sb = UIStoryboard(name: "GalleryList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
                ms.module_id = 1
                ms.type = "store"
                
                ms.config.backHome = true
                ms.config.customToolbar = true
                
                controller.pushViewController(ms, animated: true)
            }
            
        }else if let controller = self.viewTabBarController{
            
            let sb = UIStoryboard(name: "GalleryList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
                ms.module_id = 1
                ms.type = "store"
                
                ms.config.backHome = true
                ms.config.customToolbar = true
                
                
                controller.navigationController?.pushViewController(ms, animated: true)
            }
            
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
            
            let calculated_height = height-Gallery_HCards.header_size
            
            let ratio = Float(height/calculated_height)
            let calculated_width = Float(width/ratio)
            
            return CGSize(width: CGFloat(calculated_width),height: CGFloat(calculated_height))
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
    
    //API
    
    
    func load(module_id: Int,type: String) {
        
        make_as_loader()
        
        if short_mode == false {
            //req_limit = nbr_per_line*nbr_per_line
            //req_limit = req_limit*2
        }else{
            //req_limit = nbr_per_line*nbr_per_line
        }
        
    
        self.module_id = module_id
        self.type = type
        
        //get from server
        let params = [
            "module_id": String(module_id),
            "type"  : String(type),
            "limit": String(req_limit),
            "page": String(req_page)
        ]
        
        Utils.printDebug("Request store gallery \(params)")
        
        
        let loader = GalleryLoader()
        loader.load(url: Constances.Api.API_LOAD_GALLERY, parameters: params)
        loader.delegate = self
        
        
    }
    
    
    
    func error(error: Error?, response: String) {
       
        make_as_result()
        
    }
    
    
    func success(parser: ImagesParser, response: String) {
       
         make_as_result()
        
        if parser.success==1{
            
            let images = parser.parse()
            
            self.GLOBAL_COUNT = parser.count
            
            if images.count == 0 && req_page == 1{
                self.GLOBAL_COUNT = 1
            }
            
            if(GLOBAL_COUNT>3){
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let animation = UIAnimation(view: self.h_showAll)
                    animation.zoomIn()
                }
                
            }
            
            if images.count>0{
                
                self.LIST = []
                
                let size = images.count-1
                for index in 0 ... size{
                    
                    let obj = images[index]
                    if short_mode {
                        if self.GLOBAL_COUNT > req_limit && index == size{
                            obj.full = ""
                        }
                    }
                    
                    LIST.append(obj)
                    
                    if short_mode {
                        if self.GLOBAL_COUNT > req_limit && index == size{
                            Utils.printDebug("\(LIST)")
                            break
                        }
                    }
                }
                
                
                h_collection.reloadData()
                
                if short_mode == false{
                    if  self.GLOBAL_COUNT > self.LIST.count{
                        req_page = 1
                    }
                }
                
                
                
            }else if self.GLOBAL_COUNT == 0{
                
            }
            
        }else{
            
            
        }
        
        
        
        if let del = self.delegate{
            del.onGalleryloaded(count: LIST.count)
        }
        
    }
    
    
    
    
    
}

extension Gallery_HCards{
    
    func make_as_loader(){
        
        self.LIST = []
        
        let object = Images()
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

