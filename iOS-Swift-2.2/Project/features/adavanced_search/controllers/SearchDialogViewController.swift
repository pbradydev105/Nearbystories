//
//  SearchDialogViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/3/18.
//  Copyright © 2018 DT Team. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import GooglePlaces
import SwiftEventBus


protocol SearchDialogViewControllerDelegate:class  {
    //func successUtf8(data: String)
    func onSearch(type: String, view: UIView, controller: SearchDialogViewController)
    
}

class SearchDialogViewController: MyUIViewController, UITextFieldDelegate, RadioBoxDelegate {
    

    var module_checkbox = true
    var sort_checkbox = true
    var filterCache: FilterCache? = nil
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _  = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
    }
    
    
    @IBOutlet weak var viewContainer: UIView!
    
    var search_view: UIView? = nil
    
    //outlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var NavigationBarItem: UINavigationItem!
    
    //varaiables
    var search_type: String?
    var savedFilterInstance: [String: String]? = nil
    
    var delegate: SearchDialogViewControllerDelegate?
    
  
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var searchViewBtn: CustomButton!
    
    func setup(type: String, view: UIView) {
        self.search_type = type
        self.search_view = view
    }
    
    func setup( view: UIView) {
        self.search_type = nil
        self.search_view = view
    }


    @IBOutlet weak var search_button: CustomButton!
    @IBAction func searchAction(_ sender: Any) {
        
        if let del = self.delegate, let type = search_type, let view = search_view{
            del.onSearch(type: type, view: view, controller: self)
        }
        
    }
    
    
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
   
    
    func setupNavBarTitles() {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        if let title = search_type {
             topBarTitle.text = "\("Search on".localized) \(title.localized)"
        }else{
             topBarTitle.text = "\("Filter".localized)"
        }
       
        NavigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupNavBarButtons() {
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        let closeIcon: UIImage? =  UIImage.init(icon: .googleMaterialDesign(.close), size: CGSize(width: 30, height: 30), textColor: _color)
        
        let customBarButtonItem = UIBarButtonItem(image: closeIcon!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .googleMaterialDesign(.close), iconSize: 25, color: _color)
        
        
        NavigationBarItem.leftBarButtonItems = []
        NavigationBarItem.rightBarButtonItems = []
        NavigationBarItem.rightBarButtonItems?.append(customBarButtonItem)
        
    }
    
   
    
    @objc func onBackHandler()  {
        
        if let controller = self.navigationController{
            //controller.navigationBar.isHidden = true
            controller.popViewController(animated: true)
            ////controller.navigationBar.isHidden = false
        }else{
            self.dismiss(animated: true)
        }
        
          SwiftEventBus.post("on_main_refresh", sender: true)
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        self.scroll_view.backgroundColor = Colors.Appearance.white
        
        if let pick_location_init = LocalData.getValue(key: "listing_custom_location_init", defaultValue: false), !pick_location_init{
           // startAutocompleteController()
        }
        
        
        self.setupNavBarTitles()
        self.setupNavBarButtons()
       
        //get saved filter
        if let cache = self.filterCache, let type = cache._type, let view = cache._view{
            search_type = type
            search_view = view
        }
        
        self.setupRadioBoxType()
        self.setupRadioBoxSort()
        self.instance()
        self.setupViews();
        
        self.init_location()
        
        
    }
    
    func setupViews()  {
       
        self.search_button.backgroundColor = Colors.Appearance.primaryColor
        self.search_button.initDefaultFont()
        self.search_button.setTitleColor(.white, for: .normal)
        
        
    }
    
    var views_list:[String: UIView] = [:]
    
    func instance() {
        
        
        if let title = self.search_type {
            topBarTitle.text = "\("Search on".localized) \(title.localized)"
        }else{
            topBarTitle.text = "\("Filter".localized)"
        }
        
        for (key, view) in views_list{
            if let type = self.search_type, type == key {
                 view.isHidden = false
            }else{
                 view.isHidden = true
            }
        }
       
        if let type = self.search_type, let _ = views_list[type]{
            return
        }
        
        if let view = self.search_view , let type = self.search_type{
            
            let _view = view as! MySearchView
           
            //add to the subvviews
            self.viewContainer.addSubview(view)
            self.viewContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: view)
            self.viewContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: view)
            

            //create objects
            _view.setup()
            
            //save view instance
            views_list[type] = _view
           
            //focus without call onChange
            _modulesRadioBox.focusSilence(key: type)
            
            
            
            /*UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }*/
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        
        if isKeyboardShowing{
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                //self.constraintContentHeight.constant = -100
                self.view.layoutIfNeeded()
            })
            
        }else{
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                //self.constraintContentHeight.constant = 0
                self.view.layoutIfNeeded()
            })
            
        }
        
        
    }
    
    
    var nbrPress = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    @IBAction func current_location_action(_ sender: Any) {
        
        let string  = "Do you would change your location".localized
          let alert = UIAlertController(title: "Chanege location".localized, message: string, preferredStyle: .alert)
         
          alert.addAction(UIAlertAction(title: "Change Location".localized, style: .cancel, handler: { action in
              
             self.startAutocompleteController()
             alert.dismiss(animated: true)
              
             self.init_location()
              
          }))
          
          alert.addAction(UIAlertAction(title: "Use current location", style: .default, handler: { action in

              alert.dismiss(animated: true)
            
             SearchDialogViewController.listing_custom_location_enabled = false
              self.init_location()

          }))

          self.present(alert, animated: true)
        
    }
    
    
    @IBOutlet weak var radioBoxesHeaderStackView: UIStackView!
    @IBOutlet weak var radioBoxFilterTypeContainer: UIView!
    
    
    @IBOutlet weak var radioBoxSortTypeContainer: UIView!
    @IBOutlet weak var current_location_button: UIButton!
    
    var _modulesRadioBox = RadioBoxView()

    func setupRadioBoxType() {
        /*
         *   Setup Range Price for offer RadioBox
         */
        
        if !module_checkbox{
            radioBoxFilterTypeContainer.isHidden = true
            return
        }
        
        radioBoxFilterTypeContainer.addSubview(_modulesRadioBox)
        
        /*var style = RadioBoxStyle()
        
        style.disabledBorder = .lightGray
        style.disabledBackground = UIColor.white
        style.disabledText = .lightGray
        
        style.enabledBorder = Colors.Appearance.primaryColor
        style.enabledBackground = Colors.Appearance.primaryColor
        style.enabledText = .white*/
        
        
        var style1 = RadioBoxStyle()
               
        style1.disabledBorder = .lightGray
        style1.disabledBackground = Colors.Appearance.white
        style1.disabledText = .lightGray
               
        style1.enabledBorder = Colors.Appearance.primaryColor
        style1.enabledBackground = Colors.Appearance.whiteGrey
        style1.enabledText = Colors.Appearance.primaryColor
        
        
        _modulesRadioBox.setup(
            size: CGFloat(40),
            style: style1,
            items: [
                RadioObject(key: AppConfig.Tabs.Tags.TAG_STORES, state: true),
                RadioObject(key: AppConfig.Tabs.Tags.TAG_OFFERS, state: true),
                RadioObject(key: AppConfig.Tabs.Tags.TAG_EVENTS, state: true)
            ]
        )
        
        _modulesRadioBox.focus(key: AppConfig.Tabs.Tags.TAG_STORES)
        
        _modulesRadioBox.translatesAutoresizingMaskIntoConstraints = false
        _modulesRadioBox.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _modulesRadioBox.leadingAnchor.constraint(equalTo: radioBoxFilterTypeContainer.leadingAnchor, constant: 0).isActive = true
        _modulesRadioBox.trailingAnchor.constraint(equalTo: radioBoxFilterTypeContainer.trailingAnchor, constant: 0).isActive = true
        _modulesRadioBox.topAnchor.constraint(equalTo: radioBoxFilterTypeContainer.topAnchor, constant: 0).isActive = true
        _modulesRadioBox.bottomAnchor.constraint(equalTo: radioBoxFilterTypeContainer.bottomAnchor, constant: 0).isActive = true
        
        _modulesRadioBox.delegate = self
        
        
        
        
    }
    
    var sortRadioBox = RadioBoxView()
    static var selected_sort_type: String?
    static var listing_custom_location_enabled = false
    static var listing_custom_location_place_id = ""
    static var listing_custom_location_place_name = ""
    static var listing_custom_location_latitude = 0.0
    static var listing_custom_location_longitude = 0.0
    
   
    func setupRadioBoxSort() {
        
        
        if !sort_checkbox{
            radioBoxSortTypeContainer.isHidden = true
            SearchDialogViewController.selected_sort_type = SORT_RADIOBOW_KEY_GEO
            return
        }
        
        SearchDialogViewController.selected_sort_type = SORT_RADIOBOW_KEY_GEO
      
        /*
         *   Setup Range Price for offer RadioBox
         */
        
        
        
        radioBoxSortTypeContainer.addSubview(sortRadioBox)
        
        var style = RadioBoxStyle()
        
        style.disabledBorder = .lightGray
        style.disabledBackground = Colors.Appearance.white
        style.disabledText = .lightGray
        
        style.enabledBorder = Colors.Appearance.primaryColor
        style.enabledBackground = Colors.Appearance.primaryColor
        style.enabledText = .white
    
        
        sortRadioBox.setup(
            size: CGFloat(40),
            style: style,
            items: [
                RadioObject(key: SORT_RADIOBOW_KEY_GEO, state: true),
                RadioObject(key: SORT_RADIOBOW_KEY_RECENT, state: true),
            ]
        )
        
        
        sortRadioBox.translatesAutoresizingMaskIntoConstraints = false
        sortRadioBox.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sortRadioBox.leadingAnchor.constraint(equalTo: radioBoxSortTypeContainer.leadingAnchor, constant: 0).isActive = true
        sortRadioBox.trailingAnchor.constraint(equalTo: radioBoxSortTypeContainer.trailingAnchor, constant: 0).isActive = true
        sortRadioBox.topAnchor.constraint(equalTo: radioBoxSortTypeContainer.topAnchor, constant: 0).isActive = true
        sortRadioBox.bottomAnchor.constraint(equalTo: radioBoxSortTypeContainer.bottomAnchor, constant: 0).isActive = true
        
        sortRadioBox.delegate = self
        
        
        if let sort = SearchDialogViewController.selected_sort_type, sort == SORT_RADIOBOW_KEY_GEO{
             sortRadioBox.focus(key: SORT_RADIOBOW_KEY_GEO)
        }else if  let sort = SearchDialogViewController.selected_sort_type, sort == SORT_RADIOBOW_KEY_RECENT{
             sortRadioBox.focus(key: SORT_RADIOBOW_KEY_RECENT)
        }else{
            sortRadioBox.focus(key: SORT_RADIOBOW_KEY_GEO)
        }
       
        
    }
    
    let SORT_RADIOBOW_KEY_GEO = "Geo"
    let SORT_RADIOBOW_KEY_RECENT = "Recent"
    
    static let SORT_RADIOBOW_KEY_GEO = "Geo"
    static let SORT_RADIOBOW_KEY_RECENT = "Recent"
    
    func onChange(key: String, activeView: UIButton, views: [String : UIButton]) {
        
        
        if key == AppConfig.Tabs.Tags.TAG_STORES{
            
            let _view = UIView.loadFromNib(name: "StoreSearch")
            _view.isHidden = true
            self.setup(type: key, view: _view)
            self.instance()
            
           
             _view.isHidden = false
            
            /*UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }*/
            
        }else if key == AppConfig.Tabs.Tags.TAG_OFFERS{
            
            let _view = UIView.loadFromNib(name: "OfferSearch")
            self.setup(type: key, view: _view)
            self.instance()
            
             _view.isHidden = false
            
        }else if key == AppConfig.Tabs.Tags.TAG_EVENTS{
            
            let _view = UIView.loadFromNib(name: "EventSearch")
            self.setup(type: key, view: _view)
            self.instance()
            
             _view.isHidden = false
            
        }else if key == AppConfig.Tabs.Tags.TAG_USER{
            
            let _view = UIView.loadFromNib(name: "StoreSearch")
            self.setup(type: key, view: _view)
            self.instance()
            
             _view.isHidden = false
            
        }else if key == SORT_RADIOBOW_KEY_GEO{
            
            SearchDialogViewController.selected_sort_type = SORT_RADIOBOW_KEY_GEO
            UIView.animate(withDuration: 0.5) {
                 self.current_location_button.isHidden = false
            }
            
        }else if key == SORT_RADIOBOW_KEY_RECENT{
            
            SearchDialogViewController.selected_sort_type = SORT_RADIOBOW_KEY_RECENT
            
            UIView.animate(withDuration: 0.5) {
                 self.current_location_button.isHidden = true
            }
           
        }
        
    }
    
    
    struct FilterCache {
        var _view:UIView? = nil
        var _type: String? = nil
    }
    
   
    func startAutocompleteController() {
        

        
         let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        autocompleteController.tableCellBackgroundColor = Colors.Appearance.white
        
        autocompleteController.tintColor = .white
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
            
            UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            GMSPlaceField.addressComponents.rawValue |
            GMSPlaceField.formattedAddress.rawValue

            )
        
              
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
        
        
    }
    
    
    private func init_location(){
       // sortRadioBox.focus(key: SORT_RADIOBOW_KEY_GEO)
        
        self.current_location_button.initItalicFont()
        
        if SearchDialogViewController.listing_custom_location_enabled == true{
           
            let location_name = SearchDialogViewController.listing_custom_location_place_name
            
            self.current_location_button.setIcon(prefixText: "\("Location".localized): ", prefixTextColor: Colors.Appearance.black, icon: .googleMaterialDesign(.locationOn), iconColor: Colors.Appearance.primaryColor, postfixText: " \(location_name)", postfixTextColor: Colors.Appearance.primaryColor, forState: .normal, textSize: 15, iconSize: 15)
            
        }else{
            
            self.current_location_button.setIcon(prefixText: "\("Location".localized): ", prefixTextColor: Colors.Appearance.black, icon: .googleMaterialDesign(.myLocation), iconColor: Colors.Appearance.primaryColor, postfixText: " \("Current Location".localized)", postfixTextColor: Colors.Appearance.primaryColor, forState: .normal, textSize: 15, iconSize: 15)
            
        }
        
        
    }

}




extension SearchDialogViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    /*print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place ID: \(place.placeID)")
    print("Place coordinate: \(place.coordinate)")
    print("Place addressComponents: \(place.addressComponents)")
*/
    
    SearchDialogViewController.listing_custom_location_enabled = true
    SearchDialogViewController.listing_custom_location_place_id = place.placeID!
    SearchDialogViewController.listing_custom_location_place_name = place.formattedAddress!
    SearchDialogViewController.listing_custom_location_latitude = place.coordinate.latitude
    SearchDialogViewController.listing_custom_location_longitude = place.coordinate.longitude
    LocalData.setValue(key: "listing_custom_location_init", value: true)
    

    self.init_location()

    viewController.dismiss(animated: true)
       
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}

