//
//  Banners_HCards.swift
//  NearbyBanners
//
//  Created by Amine  on 8/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit
import SwiftIcons
import SwiftWebVC


class Banners_HCards: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, NSimple_Slider_Delegate, BannerLoaderDelegate {

    @IBOutlet weak var banner_container: EXUIView!

    func onPressed(object: Banner) {


        let banner_object = object
        
        if banner_object.module == "store"{
            
            let sb = UIStoryboard(name: "StoreDetailV2", bundle: nil)
            let ms: StoreDetailV2ViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailV2ViewController
            ms.storeId = Int(banner_object.module_id)
            
            if let controller = viewController{
                 controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                 controller.pushViewController(ms, animated: true)
            }
            
        }else if banner_object.module == "offer"{
            
            let sb = UIStoryboard(name: "OfferDetailV2", bundle: nil)
            let ms: OfferDetailV2ViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailV2ViewController
            ms.offer_id = Int(banner_object.module_id)
            
            if let controller = viewController{
                controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }
            
        }else if banner_object.module == "event"{
            
            let sb = UIStoryboard(name: "EventDetailV2", bundle: nil)
            let ms: EventDetailV2ViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailV2ViewController
            
            ms.event_id = Int(banner_object.module_id)
            
            if let controller = viewController{
                controller.present(ms, animated: true)
            }else if let controller = viewTabBarController{
                controller.navigationController?.pushViewController(ms, animated: true)
            }else if let controller = viewNavigationController{
                controller.pushViewController(ms, animated: true)
            }
            
        }else if banner_object.module == "link"{
            
            let link = banner_object.module_id
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                let webVC = SwiftModalWebVC(pageURL: url, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
                //self.navigationController?.pushViewController(webVC, animated: true)
                if let controller = viewController{
                    controller.present(webVC, animated: true)
                }else if let controller = viewNavigationController{
                    controller.present(webVC, animated: true)
                }else if let controller = viewTabBarController{
                    controller.present(webVC, animated: true)
                }
            }
            
        }
        
    }


    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    @IBOutlet weak var collection_constraint_left: NSLayoutConstraint!
    @IBOutlet weak var collection_constraint_right: NSLayoutConstraint!

    @IBOutlet weak var pageControl: UIPageControl!

    @IBAction func pageControle(_ sender: Any) {

    }

    @IBOutlet weak var h_header: UIStackView!
    @IBOutlet weak var h_header_sub: UIView!
    @IBOutlet weak var h_label: EdgeLabel!
    @IBOutlet weak var h_showAll: UIButton!

    @IBAction func showAllAction(_ sender: Any) {

    }


    var style: CardHorizontalStyle?

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    var viewController: UIViewController? = nil
    var viewNavigationController: UINavigationController? = nil
    var viewTabBarController: UITabBarController? = nil


    static func newInstance(style: CardHorizontalStyle) -> UIView {

        //load xib 
        let mBanners_HCards = instanceFromNib(name: "Banners_HCards") as! Banners_HCards
        
        if let title = style.Title{
            mBanners_HCards.h_label.text = title.localized
        }else{
            mBanners_HCards.h_header_sub.isHidden = true
        }

        mBanners_HCards.setup(style: style)
        
        mBanners_HCards.banner_container.backgroundColor = .clear

        return mBanners_HCards

    }


    enum Request {
        static let nearby = 0
        static let saved = -1
    }

    //request
    var __req_category: Int = 0
    var __req_redius: Int = AppConfig.distanceMaxValue
    //var __req_list: String = Request.nearby
    var __req_search: String = ""
    var __req_page: Int = 1

    var __req_current_date: String = ""
    var __req_default_tz: String = ""
    var __req_opening_time: Int = 0


    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Banner] = [Banner]()


    let padding_size = CGFloat(20)

    let padding = CGFloat(20)

    @IBOutlet weak var collectionView: UICollectionView!

    func setup(style: CardHorizontalStyle) {
        
        self.backgroundColor = .clear
        

        self.style = style

        pageControl.numberOfPages = 0

        self.h_label.leftTextInset = padding_size
        self.h_label.rightTextInset = padding_size
        self.h_label.initBolodFont(size: 18)


        self.h_showAll.initDefaultFont()
        self.h_showAll.setTitleColor(.black, for: .normal)
        self.h_showAll.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        // Icon with text around it
        self.h_showAll.setIcon(prefixText: "Show All ".localized, icon: .googleMaterialDesign(.chevronRight), postfixText: "", forState: .normal)

        self.h_showAll.isHidden = true


        //self.rightConstraint.constant = padding_size
        //self.leftConstraint.constant = padding_size

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }

        collection_constraint_left.constant = padding_size
        collection_constraint_right.constant = padding_size


        //collectionView.contentInset = UIEdgeInsets(top: padding_size, left: padding_size, bottom: padding_size, right: padding_size)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "NSimple_SliderCell", bundle: nil), forCellWithReuseIdentifier: cellId)


        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = true

        collectionView.roundCorners(radius: 15)


        //get from cache
        let banners = Banner.findAll()

        if banners.count > 0 {
            
            pageControl.numberOfPages = banners.count
            
            LIST = banners
            collectionView.reloadData()
            
            load()
            
        } else {
            load()
        }


    }

    let cellId = "NSimple_SliderCell"


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: NSimple_SliderCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NSimple_SliderCell

        let itemIndex = indexPath.item % self.LIST.count

        let banner = LIST[itemIndex]

        cell.setup(banner: banner)
        cell.delegate = self

        return cell

    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    private func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let itemIndex = indexPath.item % self.LIST.count
        let item = self.LIST[itemIndex]
        print(item)
    }


    static let header_size = Float(50)

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let style = self.style, let height = style.height {
            //add 60 for store information

            if style.Title != nil{
                let calculated_height = height - Banners_HCards.header_size
                let calculated_width = self.frame.width
                return CGSize(width: CGFloat(calculated_width - (padding_size * 2)), height: CGFloat(calculated_height))
             }else{
                let calculated_height = height
                let calculated_width = self.frame.width
                return CGSize(width: CGFloat(calculated_width - (padding_size * 2)), height: CGFloat(calculated_height))
            }
            
          
        } else {
            return CGSize(width: CGFloat(60), height: CGFloat(60))
        }


    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyCount * LIST.count
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }


    var timer: Timer?
    let dummyCount = 12

    // -------------------------------------------------------------------------------
    //    Infinite Scroll Controls
    // -------------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.LIST.count > 0{
            self.centerIfNeeded()
        }
        
    }

    func centerIfNeeded() {

        let currentOffset = collectionView.contentOffset
        let contentWidth = self.totalContentWidth
        let width = contentWidth / CGFloat(dummyCount)

        if 0 > currentOffset.x {
            //left scrolling
            collectionView.contentOffset = CGPoint(x: width - currentOffset.x, y: currentOffset.y)
        } else if (currentOffset.x + cellWidth) > contentWidth {
            //right scrolling
            let difference = (currentOffset.x + cellWidth) - contentWidth
            collectionView.contentOffset = CGPoint(x: width - (cellWidth + difference), y: currentOffset.y)
        }
    }

    var totalContentWidth: CGFloat {
      
        var size = LIST.count
        if(size == 0){
            size = 1
        }
        
        return CGFloat(LIST.count * dummyCount) * cellWidth
    }

    var cellWidth: CGFloat {
        return collectionView.frame.width
    }


    // -------------------------------------------------------------------------------
    //    Timer Controls
    // -------------------------------------------------------------------------------
    func startTimer() {
        if LIST.count > 1 && timer == nil {
            let timeInterval = 5.0;
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rotate), userInfo: nil, repeats: true)
            timer!.fireDate = NSDate().addingTimeInterval(timeInterval) as Date
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func rotate() {

        let offset = CGPoint(x: collectionView.contentOffset.x + cellWidth, y: collectionView.contentOffset.y)
        collectionView.setContentOffset(offset, animated: true)

        updatePageControle()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }


    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let visibleIndex = Int(targetContentOffset.pointee.x / collectionView.frame.width)
        let index = visibleIndex % self.LIST.count
        pageControl.currentPage = index

        //updatePageControle()

    }


    func updatePageControle() {

        let offset = CGPoint(x: collectionView.contentOffset.x + cellWidth, y: collectionView.contentOffset.y)

        let visibleIndex = Int(offset.x / collectionView.frame.width)
        let index = visibleIndex % self.LIST.count

        pageControl.currentPage = index

    }


    // -------------------------------------------------------------------------------
    //    Banners API's
    // -------------------------------------------------------------------------------


    var bannerLoader: BannerLoader = BannerLoader()

    func load() {

        make_as_loader()
        self.bannerLoader.delegate = self

        let parameters = [
            "limit": "6"
        ]

        self.bannerLoader.load(url: Constances.Api.API_GET_BANNERS, parameters: parameters)

    }


    func success(parser: BannerParser, response: String) {


        if parser.success == 1 {

            make_as_result()

            let banners = parser.parse()

            self.GLOBAL_COUNT = parser.count

            if banners.count > 0 {

                pageControl.numberOfPages = banners.count

                Utils.printDebug("We loaded \(banners.count)")

                if self.__req_page == 1 {
                    self.LIST = banners
                } else {
                    self.LIST += banners
                }

                Banner.removeAll()
                
                banners.saveAll()

                self.collectionView.reloadData()

                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }

                startTimer()

            }

        } else {

            if let errors = parser.errors {

                Utils.printDebug("===> Request Error with Messages! ListUsers")
                Utils.printDebug("\(errors)")

            }

        }

    }

    func emptyAndReload() {

        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.collectionView.reloadData()

    }

    func error(error: Error?, response: String) {

        Utils.printDebug("===> Request Error! ListUsers")
        Utils.printDebug("\(response)")

    }


}


extension Banners_HCards {

    func make_as_loader() {

        if(LIST.count == 0){
            pageControl.numberOfPages = 0
            self.banner_container.isSkeletonable = true
            self.banner_container.showAnimatedGradientSkeleton()
        }
        
    }

    func make_as_result() {

        self.banner_container.isSkeletonable = false
        self.banner_container.hideSkeleton()

    }

}
