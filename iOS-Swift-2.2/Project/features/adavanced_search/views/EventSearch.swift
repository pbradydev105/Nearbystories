//
//  EventSearch.swift
//  NearbyStores
//
//  Created by Amine  on 8/21/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField


class EventSearch: MySearchView, UITextFieldDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //variables
    
    var ex_parameters: [String: String] = [
        "__req_category": "0",
        "__req_redius": String(AppConfig.distanceMaxValue),
        "__req_list_order": String(ListEventCell.EventsListRequestOrder.nearby),
        "__req_search": "",
        "__req_opening_time": "0",
    ]
    
    @IBOutlet weak var date_begin_field: SkyFloatingLabelTextField!
    @IBOutlet weak var dateBeginBtn: UIButton!
    
    @IBAction func dateBeginAction(_ sender: Any) {
        
        
    }
    
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
        
        
        self.category_label.text = "Select Category".localized
        
        self.radius_label.text = "\("Radius".localized) \(AppConfig.distanceMaxValue) \(AppConfig.distanceUnit.localized)"
        
        
        //congig search field
        self.search_field.textColor = Colors.Appearance.black
        self.search_field.lineColor = UIColor.gray
        self.search_field.selectedTitleColor = Colors.Appearance.black
        self.search_field.selectedLineColor = Colors.Appearance.primaryColor
        self.search_field.selectedLineHeight = 1.5
        self.search_field.lineHeight = 0.5
        self.search_field.titleColor = Colors.Appearance.primaryColor
        self.search_field.titleLabel.textColor = Colors.Appearance.black
        self.search_field.placeholder = "Write something...".localized
          
              
        self.search_field.initDefaultFont()
        self.search_field.titleLabel.initDefaultFont()
        
        //////
        
        //config date begin
        self.dateBeginBtn.setTitle("", for: .normal)
        self.dateBeginBtn.isHidden =  true
        self.date_begin_field.textColor = UIColor.black
        self.date_begin_field.lineColor = UIColor.gray
        self.date_begin_field.selectedTitleColor = UIColor.black
        self.date_begin_field.selectedLineColor = Colors.Appearance.primaryColor
        self.date_begin_field.selectedLineHeight = 1.5
        self.date_begin_field.lineHeight = 0.5
        self.date_begin_field.titleColor = Colors.Appearance.primaryColor
    
        self.date_begin_field.placeholder = "Date Begin".localized
        
        self.date_begin_field.initDefaultFont()
        self.date_begin_field.titleLabel.initDefaultFont()
        
        ///////
    

        self.sliderView.minimumValue = Float(0)
        self.sliderView.maximumValue = Float(AppConfig.distanceMaxValue)
        self.sliderView.value = Float(AppConfig.distanceMaxValue)
        
        self.sliderView.tintColor = Colors.Appearance.primaryColor
        self.radius_label.text = "\("Radius".localized) +\(999) \(AppConfig.distanceUnit.localized)"
    
        search_field.delegate = self
        
        
        /*
        *   Setup Event Date begin Filter
        */
        
        
        setupDateBeginPicker()
        
     

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
    
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    func setupDateBeginPicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItem.Style.bordered, target: self, action: #selector(doneDateBeginPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized, style: UIBarButtonItem.Style.bordered, target: self, action: #selector(cancelDateBeginPicker))
        toolbar.setItems([cancelButton,spaceButton, doneButton],animated: false)
        
        
        // add toolbar to textField
        self.date_begin_field.inputAccessoryView = toolbar
        // add datepicker to textField
        self.date_begin_field.inputView = datePicker
                      
        
        if #available(iOS 13.0, *){
              
        }else{
            
        }
       
    }
    
    @objc func doneDateBeginPicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        self.date_begin_field.text = formatter.string(from: datePicker.date)
        self.endEditing(true)
        
    }
    
    
    @objc func cancelDateBeginPicker(){
        self.endEditing(true)
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
