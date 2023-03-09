//
//  StoreSearch.swift
//  NearbyStores
//
//  Created by Amine  on 8/21/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class MySearchView: UIView {
    
    var initialized = false
    
    func setup()  {
       
        initialized = true
        
    }
}
class StoreSearch: MySearchView,CategoryLoaderDelegate, UITextFieldDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
  
    var ex_parameters: [String: String] = [
        "__req_category": "0",
        "__req_redius": String(AppConfig.distanceMaxValue),
        "__req_list_order": String(ListStoresCell.StoresListRequestOrder.nearby),
        "__req_search": "",
        "__req_opening_time": "0",
    ]
    
    @IBOutlet weak var category_label: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search_field: SkyFloatingLabelTextField!
    @IBOutlet weak var radius_label: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var openOnlyLabel: UILabel!
    @IBOutlet weak var openOnlySwitch: UISwitch!
    
    
    @IBOutlet weak var hasOfferlyLabel: UILabel!
    @IBOutlet weak var hasOfferlySwitch: UISwitch!
    
    @IBAction func onOpeningTimeSwitch(_ sender: Any) {
        if openOnlySwitch.isOn{
            ex_parameters["__req_opening_time"] = "1"
        }else{
            ex_parameters["__req_opening_time"] = "0"
        }
    }
    
    @IBAction func radiusSlide(_ sender: Any) {
        
        let slider: UISlider = sender as! UISlider
        let value = Int(slider.value)
        
        if value < 100  {
            radius_label.text = "\("Radius".localized) \(value) \(AppConfig.distanceUnit.localized)"
        }else{
            radius_label.text = "\("Radius".localized) +\(value) \(AppConfig.distanceUnit.localized)"
        }
        
    }
    
    var selected_category: Category? = nil
    
    
    override func setup() {
        guard !initialized else {
           return
        }
        
        super.setup()
        
        self.setupCollectionView()
        
        self.openOnlySwitch.onTintColor = Colors.Appearance.primaryColor
        self.hasOfferlySwitch.onTintColor = Colors.Appearance.primaryColor
        
        self.openOnlyLabel.initDefaultFont()
        self.hasOfferlyLabel.initDefaultFont()
        self.radius_label.initDefaultFont()
        self.category_label.initBolodFont()
        self.search_field.initDefaultFont()
        self.search_field.titleLabel.initDefaultFont()
        self.openOnlyLabel.text = "Open only".localized
        
        self.category_label.text = "Select Category".localized
        
        self.radius_label.text = "\("Radius".localized) \(AppConfig.distanceMaxValue) \(AppConfig.distanceUnit.localized)"
        self.search_field.textColor = Colors.Appearance.black
        self.search_field.lineColor = UIColor.gray
        self.search_field.selectedTitleColor = Colors.Appearance.black
        self.search_field.selectedLineColor = Colors.Appearance.primaryColor
        self.search_field.selectedLineHeight = 1.5
        self.search_field.lineHeight = 0.5
        self.search_field.titleColor = Colors.Appearance.primaryColor
        self.search_field.titleLabel.textColor = Colors.Appearance.black
        
        self.search_field.placeholder = "Write something...".localized
    

        self.sliderView.minimumValue = Float(0)
        self.sliderView.maximumValue = Float(AppConfig.distanceMaxValue)
        self.sliderView.value = Float(AppConfig.distanceMaxValue)
        
        self.sliderView.tintColor = Colors.Appearance.primaryColor
        
        
        self.radius_label.text = "\("Radius".localized) +\(999) \(AppConfig.distanceUnit.localized)"
    
        search_field.delegate = self
        
    
              NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
              
              NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
              
        }
          
          
          @objc func handleKeyboardNotification(notification: NSNotification) {
              
              let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
              
              if isKeyboardShowing{
                  // so increase contentView's height by keyboard height
                  UIView.animate(withDuration: 0.3, animations: {
                      //self.constraintContentHeight.constant = -100
                      self.layoutIfNeeded()
                  })
                  
              }else{
                  // so increase contentView's height by keyboard height
                  UIView.animate(withDuration: 0.3, animations: {
                      //self.constraintContentHeight.constant = 0
                      self.layoutIfNeeded()
                  })
                  
              }
              
              
          }
          
          
          var nbrPress = 0
          override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
              self.endEditing(true)
          }
          
          
          
          var lastTextField: UITextField? = nil
            
            func textFieldDidBeginEditing(_ textField: UITextField) {
            
                lastTextField = textField
            }
            
          
          
          func textFieldShouldReturn(_ textField: UITextField) -> Bool {
              textField.resignFirstResponder()
              lastTextField = textField
              return true
          }
    
    let padding_size = CGFloat(20)
    
    func setupCollectionView(){
        
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: padding_size, bottom: 0, right: padding_size)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.backgroundColor = Colors.Appearance.white
        collectionView.register(UINib(nibName: "CatetorySelectCell", bundle: nil), forCellWithReuseIdentifier: "catgorySelectCellId")
        
       // collectionView.isScrollEnabled = true
        
        
        //All categories
        let all_ca = Category()
        all_ca.numCat = -1
        all_ca.images = nil
        all_ca.nameCat = "All categories".localized
               
        self.LIST.append(all_ca)
               
        let i = Category.getAll()
               
        for c in i {
            self.LIST.append(c)
        }
    
        collectionView.reloadData()
             
    }
    
    func test() {
        
        let user = Category()
        self.LIST.append(user)
        self.LIST.append(user)
       
    }
    
  
    
    var LIST: [Category] = [Category]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CatetorySelectCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "catgorySelectCellId", for: indexPath) as! CatetorySelectCell
        
        let cat = LIST[indexPath.row]
        
        cell.setup(object: cat)
        cell.isDeselected()
        
        
        if let c = self.ex_parameters["__req_category"]{
           let selected_cid = Int(c)
            if(selected_cid == cat.numCat){
                cell.isSelected()
                self.selected_category = cat
            }
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
  
    
    static let header_size = Float(50)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.frame.height
        
        return CGSize(width: CGFloat(size-10) , height: CGFloat(size-10))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    
        
        
        if let selectedItems = collectionView.indexPathsForSelectedItems{
            for _indexPath in selectedItems {
                if let cell = collectionView.cellForItem(at: _indexPath){
                    let _cell = cell as! CatetorySelectCell
                    _cell.isSelected()
                    collectionView.scrollToItem(at: _indexPath, at: .centeredHorizontally, animated: true)
                    self.selected_category = self.LIST[indexPath.row]
                }
            }
        }
        
        
        var size = self.LIST.count
        size = size-1
        if size<0{
            size = 0
        }
        
        var indexes: [IndexPath] = []
        for index in 0...size{
            if(index == indexPath.item){
                
            }else{
                indexes.append(
                    IndexPath(item: index, section: 0)
                )
            }
        }
        
        self.collectionView.reloadItems(at: indexes)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
        /*if let cell = collectionView.cellForItem(at: indexPath){
            let _cell = cell as! CatetorySelectCell
            _cell.isDeselected()
            self.selected_category = nil
        }*/
 
        if let _cell = collectionView.cellForItem(at: indexPath){
            (_cell as! CatetorySelectCell).isDeselected()
            self.selected_category = nil
        }
        
        if let selectedItems = collectionView.indexPathsForSelectedItems{
            for _indexPath in selectedItems {
                if let cell = collectionView.cellForItem(at: _indexPath){
                    let _cell = cell as! CatetorySelectCell
                    _cell.isDeselected()
                   
                }
            }
        }
        
    }
    
 
  
    
    
    //API
    
    var loader: CategoryLoader = CategoryLoader()
    
    func updateCategories () {
        
        
        self.loader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "100"
        ]
        
        parameters["page"] = String("1")
        
        Utils.printDebug("\(parameters)")
        
        self.loader.load(url: Constances.Api.API_USER_GET_CATEGORY,parameters: parameters)
        
    }
    
    
    
    func success(parser: CategoryParser,response: String) {
        
    
        
        if parser.success == 1 {
            
            let categories = parser.parse()
            
            Utils.printDebug("===> \(categories)")
            
            if categories.count > 0 {
                
                Utils.printDebug("Loaded \(categories.count)")
                
                //if let user = myUserSession {
                // users.validateAll(sessId: user.id)
                //}
                
                
                //Category.removeAllFromRealm()
            
                self.LIST = categories
                
                categories.saveAll()
                
                self.collectionView.reloadData()
                
        
            }else{
              
                
            }
            
        }else {
            
           
            
        }
        
    }
    
    
    
    
    func emptyAndReload()  {
       
    }
    
    func error(error: Error?,response: String) {
        
      
        
    }
    
    
}
