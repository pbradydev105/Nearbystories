//
//  StoreGalleryCell.swift
//  NearbyStores
//
//  Created by Amine on 10/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Kingfisher
import ImageSlideshow

class StoreGalleryCell: UICollectionViewCell {

    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    @IBAction func onClickItem(_ sender: Any) {
        
        if let id = self.module_id, let type = self.type, let vc = self.vc{//open gallery viewcontroller
           
        
            Utils.printDebug("Open ")
            
            let sb = UIStoryboard(name: "GalleryList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let gc: GalleryViewController = sb.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
                
                gc.module_id = id
                gc.type = type
                
                vc.present(gc, animated: true)
            }
            
            
        }else if let pos = self.position, let images = self.list, let vc = self.vc{//open image slider
            
            Utils.printDebug("Show \(pos)")
            
            //show slider
            var imagesInputs:[InputSource] = []
            
            for index in 0...images.count-1{
                let url = images[index].url500_500
                imagesInputs.append(KingfisherSource(urlString: url)!)
            }
            
            self.slideShow.setImageInputs(imagesInputs)   
            
            if #available(iOS 13.0, *){
                self.slideShow.presentFullScreenControllerForIos13(from: vc)
            }else{
                self.slideShow.presentFullScreenController(from: vc)
            }
        
        }
        
    }
    
    let slideShow = ImageSlideshow()
    
    
    var module_id: Int?
    var type: String?
    var list: [Images]?
    var position: Int?
    var vc: UIViewController?
    
    
    func setup(object: Images, nbr: Int) {
        
         self.image.contentMode = .scaleAspectFill
        
        mainContainer.backgroundColor = .clear

        self.seeMoreBtn.isHidden = false
        self.seeMoreBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.seeMoreBtn.setTitle("+\(nbr)", for: .normal)
        
        
        if object.url200_200 != ""{
            let url = URL(string: object.url200_200)
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
        }else{
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
    }
    
    func setup(object: Images) {
        
         self.image.contentMode = .scaleAspectFill
        
        mainContainer.backgroundColor = .clear
        
        self.seeMoreBtn.isHidden = false
        self.seeMoreBtn.backgroundColor = .clear
        self.seeMoreBtn.setTitle("", for: .normal)
        
        
        if object.url200_200 != ""{
            let url = URL(string: object.url200_200)
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
        }else{
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
        
        self.slideShow.pageIndicator = nil
        self.slideShow.contentScaleMode = .scaleAspectFill
        
        
    }

}
