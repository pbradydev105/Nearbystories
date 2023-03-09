//
//  OfferSearch.swift
//  NearbyStores
//
//  Created by Amine  on 8/21/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField


class OfferSearch: MySearchView, UITextFieldDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RadioBoxDelegate{
    
    var ex_parameters: [String: String] = [
           "__req_category": "0",
           "__req_redius": String(AppConfig.distanceMaxValue),
           "__req_list_order": String(ListOfferCell.OffersListRequestOrder.nearby),
           "__req_search": "",
           "__req_opening_time": "0",
       ]
    
    //variables
    var isDiscountType = false
    var isPriceType = false
    var priceRangeSelected = ""
    var discountRangeSelected = ""
    
    @IBOutlet weak var discountRangeRadioBoxContainer: UIView!
    @IBOutlet weak var offerTypeRadioBoxContainer: UIView!
    @IBOutlet weak var priceRangeRadioBoxContainer: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var category_label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search_field: SkyFloatingLabelTextField!
    @IBOutlet weak var radius_label: UILabel!
    @IBOutlet weak var sliderView: UISlider!
 
   
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
        
        self.radius_label.initDefaultFont()
        self.category_label.initBolodFont()
        self.search_field.initDefaultFont()
        self.search_field.titleLabel.initDefaultFont()
        
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
              
        self.search_field.placeholder = "Write something ...".localized
    

        self.sliderView.minimumValue = Float(0)
        self.sliderView.maximumValue = Float(AppConfig.distanceMaxValue)
        self.sliderView.value = Float(AppConfig.distanceMaxValue)
        
        self.sliderView.tintColor = Colors.Appearance.primaryColor

        self.radius_label.text = "\("Radius".localized) +\(999) \(AppConfig.distanceUnit.localized)"
    
        search_field.delegate = self
        
        
        /*
        *   Setup Offer Type RadioBox
        */
        
        let _offerTypeRadioBox = RadioBoxView()
        offerTypeRadioBoxContainer.addSubview(_offerTypeRadioBox)
        
        
        var style1 = RadioBoxStyle()
        
        style1.disabledBorder = .lightGray
        style1.disabledBackground = Colors.Appearance.white
        style1.disabledText = .lightGray
        
        style1.enabledBorder = Colors.Appearance.primaryColor
        style1.enabledBackground = Colors.Appearance.whiteGrey
        style1.enabledText = Colors.Appearance.primaryColor
        
        
        _offerTypeRadioBox.setup(
            size: CGFloat(50),
            style: style1,
            items: [
                RadioObject(key: "All", state: true),
                RadioObject(key: "Price", state: true),
                RadioObject(key: "Discount", state: true)
            ]
        )
    
        _offerTypeRadioBox.focus(key: "All")

        _offerTypeRadioBox.translatesAutoresizingMaskIntoConstraints = false
        _offerTypeRadioBox.heightAnchor.constraint(equalToConstant: 50).isActive = true
        _offerTypeRadioBox.leadingAnchor.constraint(equalTo: offerTypeRadioBoxContainer.leadingAnchor, constant: 0).isActive = true
        _offerTypeRadioBox.trailingAnchor.constraint(equalTo: offerTypeRadioBoxContainer.trailingAnchor, constant: 0).isActive = true
        _offerTypeRadioBox.topAnchor.constraint(equalTo: offerTypeRadioBoxContainer.topAnchor, constant: 0).isActive = true
        _offerTypeRadioBox.bottomAnchor.constraint(equalTo: offerTypeRadioBoxContainer.bottomAnchor, constant: 0).isActive = true
        
        _offerTypeRadioBox.delegate = self
        
        
        //focus
        self.priceRangeRadioBoxContainer.isHidden = true
        self.discountRangeRadioBoxContainer.isHidden = true
      
        
        
        /*
         *   Setup Range Price for offer RadioBox
         */
        
        let _priceRangeRadioBox = RadioBoxView()
        priceRangeRadioBoxContainer.addSubview(_priceRangeRadioBox)
        
        var style = RadioBoxStyle()
        
        style.disabledBorder = .lightGray
        style.disabledBackground = Colors.Appearance.white
        style.disabledText = .lightGray
        
        style.enabledBorder = Colors.Appearance.primaryColor
        style.enabledBackground = Colors.Appearance.primaryColor
        style.enabledText = .white
        
        
        
        _priceRangeRadioBox.setup(
            size: CGFloat(35),
            style: style,
            items: [
                RadioObject(key: "$", state: true),
                RadioObject(key: "$$", state: true),
                RadioObject(key: "$$$", state: true),
                RadioObject(key: "$$$$", state: true)
            ]
        )
        
        _priceRangeRadioBox.focus(key: "$")
        
        _priceRangeRadioBox.translatesAutoresizingMaskIntoConstraints = false
        _priceRangeRadioBox.heightAnchor.constraint(equalToConstant: 35).isActive = true
        _priceRangeRadioBox.leadingAnchor.constraint(equalTo: priceRangeRadioBoxContainer.leadingAnchor, constant: 0).isActive = true
        _priceRangeRadioBox.trailingAnchor.constraint(equalTo: priceRangeRadioBoxContainer.trailingAnchor, constant: 0).isActive = true
        _priceRangeRadioBox.topAnchor.constraint(equalTo: priceRangeRadioBoxContainer.topAnchor, constant: 0).isActive = true
        _priceRangeRadioBox.bottomAnchor.constraint(equalTo: priceRangeRadioBoxContainer.bottomAnchor, constant: 0).isActive = true
        
        _priceRangeRadioBox.delegate = self
        
        
        
        
        /*
         *   Setup Range Price for offer RadioBox
         */
        
        let _percentRangeRadioBox = RadioBoxView()
        discountRangeRadioBoxContainer.addSubview(_percentRangeRadioBox)
        
        var style2 = RadioBoxStyle()
        
        style2.disabledBorder = .lightGray
        style2.disabledBackground = Colors.Appearance.white
        style2.disabledText = .lightGray
        
        style2.enabledBorder = Colors.Appearance.primaryColor
        style2.enabledBackground = Colors.Appearance.primaryColor
        style2.enabledText = .white
        
        
        
        _percentRangeRadioBox.setup(
            size: CGFloat(35),
            style: style2,
            items: [
                RadioObject(key: "0-25%", state: true),
                RadioObject(key: "25-50%", state: true),
                RadioObject(key: "50-75%", state: true),
                RadioObject(key: "75-100%", state: true)
            ]
        )
        
        _percentRangeRadioBox.focus(key: "0-25%")
        
        _percentRangeRadioBox.translatesAutoresizingMaskIntoConstraints = false
        _percentRangeRadioBox.heightAnchor.constraint(equalToConstant: 35).isActive = true
        _percentRangeRadioBox.leadingAnchor.constraint(equalTo: discountRangeRadioBoxContainer.leadingAnchor, constant: 0).isActive = true
        _percentRangeRadioBox.trailingAnchor.constraint(equalTo: discountRangeRadioBoxContainer.trailingAnchor, constant: 0).isActive = true
        _percentRangeRadioBox.topAnchor.constraint(equalTo: discountRangeRadioBoxContainer.topAnchor, constant: 0).isActive = true
        _percentRangeRadioBox.bottomAnchor.constraint(equalTo: discountRangeRadioBoxContainer.bottomAnchor, constant: 0).isActive = true
        
        _percentRangeRadioBox.delegate = self
        
    
       
        self.isPriceType = false
        self.isDiscountType = false
        
        priceRangeSelected = "$"
        discountRangeSelected = ""
      
       

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
    
    
    
    func onChange(key: String, activeView: UIButton, views: [String : UIButton]) {
        
        if key == "Price"{
            
            self.priceRangeRadioBoxContainer.isHidden = false
            self.discountRangeRadioBoxContainer.isHidden = true
            
            self.isPriceType = true
            self.isDiscountType = false
            
            priceRangeSelected = "$"
            discountRangeSelected = ""
            
        }else if(key == "Discount"){
            
            self.priceRangeRadioBoxContainer.isHidden = true
            self.discountRangeRadioBoxContainer.isHidden = false
            
            self.isPriceType = false
            self.isDiscountType = true
            
            priceRangeSelected = ""
            discountRangeSelected = "0-25%"
            
        }else if(key == "All"){
            
            self.priceRangeRadioBoxContainer.isHidden = true
            self.discountRangeRadioBoxContainer.isHidden = true
            
            self.isPriceType = false
            self.isDiscountType = false
            
            priceRangeSelected = ""
            discountRangeSelected = ""
            
        }else if isPriceType && (key == "$" || key == "$" || key == "$$"  || key == "$$$"  || key == "$$$$" ) {
            
            priceRangeSelected = key
            discountRangeSelected = ""
            
        }else if isDiscountType && (key == "0-25%" || key == "25-50%" || key == "50-75%" || key == "75-100%" ){
            
            priceRangeSelected = ""
            discountRangeSelected = key
            
        }
        
        self.layoutIfNeeded()
        
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
    
    
    var LIST: [Category] = [Category]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CatetorySelectCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "catgorySelectCellId", for: indexPath) as! CatetorySelectCell
        
        let cat = LIST[indexPath.row]
        
        cell.setup(object: cat)
        cell.isDeselected()
        
        
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
    
    
  
    
  
    
}
