//
//  StoreOfferListView.swift
//  NearbyStores
//
//  Created by Amine on 7/4/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

protocol StoreGalleryDelegate {
    func onPress(object: Images)
    func onLoaded(list: [Images])
    func loadMore(view: StoreGalleryListView)
}

class StoreGalleryListView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, GalleryLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate {
    
    
    var module_id: Int = 0
    var type: String = ""
    
    
    var delegate: StoreGalleryDelegate? = nil
    var vc: UIViewController?
    
    var short_mode = true
    
    var LIST:[Images] = []
    var GLOBAL_COUNT: Int = 0
    
    
    var nbr_per_line: Int = 4
    
    var req_page: Int = 1
    var req_limit: Int = 16
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        addSubview(myCollectionView)
        
        //Add constraint
        myCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        myCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        myCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
       
        if short_mode == false {
            req_limit = nbr_per_line*nbr_per_line
            req_limit = req_limit*2
        }else{
            req_limit = nbr_per_line*nbr_per_line
        }
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: self)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let refreshControl = UIRefreshControl()
    
    func setup() {
        
        
        if short_mode == false{
            
            if #available(iOS 10.0, *) {
                myCollectionView.refreshControl = refreshControl
            } else {
                myCollectionView.addSubview(refreshControl)
            }
            
            refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        }

    }
    
    @objc private func refreshData(_ sender: Any) {
        //Init params
        req_page = 1
        
        // Fetch Data
        loadGallery(module_id: self.module_id, type: self.type)
    }
    
    private var isLoading = false
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //item = 10, count = 10 , COUNT = 23
        
        if short_mode == false{
            
            Utils.printDebug(" Paginate \( (indexPath.item + 1) ) - \(LIST.count) - \(GLOBAL_COUNT)")
            
            if indexPath.item + 1 == LIST.count && self.LIST.count < GLOBAL_COUNT && !isLoading {
                Utils.printDebug(" Paginate! \(req_page) ")
                self.loadGallery(module_id: module_id, type: type)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.LIST.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: StoreGalleryCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCellId", for: indexPath) as! StoreGalleryCell
        
        let image = self.LIST[indexPath.row]
    
        if image.full == "" && short_mode{
            
            let rest_nbr = self.GLOBAL_COUNT-self.LIST.count
            cell.module_id = self.module_id
            cell.type = self.type
            cell.vc = vc
            cell.setup(object: image, nbr: rest_nbr)
            
        }else{
            
            cell.list = self.LIST
            cell.position = indexPath.row
            cell.vc = vc
            cell.setup(object: image)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGFloat(myCollectionView.frame.width/CGFloat(nbr_per_line))
        
        return CGSize(width: size-1, height: size)
    }
    
   
    
    lazy var myCollectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        //layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.register(UINib(nibName: "StoreGalleryCell", bundle: nil), forCellWithReuseIdentifier: "galleryCellId")
        cv.isScrollEnabled = false
        return cv
    }()
   
    /*///////////////////////////////////////////
     *   GALLERY LOADER
     *//////////////////////////////////////////*/
    
    
    func loadGallery(module_id: Int,type: String) {
        
        if short_mode == false {
            req_limit = nbr_per_line*nbr_per_line
            req_limit = req_limit*2
        }else{
            req_limit = nbr_per_line*nbr_per_line
        }
        
        if short_mode == false {
            self.viewManager.showAsLoading()
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
        
        self.isLoading = true
        
        let loader = GalleryLoader()
        loader.load(url: Constances.Api.API_LOAD_GALLERY, parameters: params)
        loader.delegate = self
        
        
    }
    
    
    func error(error: Error?, response: String) {
        
        if short_mode == false {
            self.viewManager.showAsError()
        }
        
    }
    
    
    func success(parser: ImagesParser, response: String) {
        
        Utils.printDebug("\(response)")
        if short_mode == false {
            self.viewManager.showMain()
        }
        
        
        self.isLoading = false
        
        
        if parser.success==1{
            let images = parser.parse()
            
            self.GLOBAL_COUNT = parser.count
            
            if images.count == 0 && req_page == 1{
                self.GLOBAL_COUNT = 1
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
               
                
                myCollectionView.reloadData()
            
                if short_mode == false{
                    if  self.GLOBAL_COUNT > self.LIST.count{
                        req_page = 1
                    }
                }
                
                if let del = delegate {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        del.onLoaded(list: self.LIST)
                    }
                }
                
            }else if self.GLOBAL_COUNT == 0{
                if short_mode == false {
                    self.viewManager.showAsError()
                }
            }
            
        }else{
            if short_mode == false {
                self.viewManager.showAsError()
            }
        }
        
        
    }
    
    
    func setPosition(parent: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.right,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parent,
            attribute: NSLayoutConstraint.Attribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parent,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
            toItem: parent,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.left,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: parent,
            attribute: NSLayoutConstraint.Attribute.left,
            multiplier: 1, constant: 0)
        )
        
        
        parent.addConstraints(constraints)
        
    }
    
    
    
    func onReloadAction(action: EmptyLayout) {
        self.req_page = 1
        self.loadGallery(module_id: module_id, type: self.type)
    }
    
    func onReloadAction(action: ErrorLayout) {
        self.req_page = 1
        self.loadGallery(module_id: module_id, type: self.type)
    }
    
}




