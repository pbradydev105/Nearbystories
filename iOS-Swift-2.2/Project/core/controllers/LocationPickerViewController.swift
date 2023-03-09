//
//  CityAutocompleteViewController.swift
//  NearbyStores
//
//  Created by Amine on 3/20/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import GooglePlaces

protocol LocationPickerViewControllerDelegate:class {
    func onSelect(query: String, object: LocationModel?)
}

class LocationPickerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    static var _last_query = ""
    static var _last_result: LocationModel? = nil
    

    var delegate: LocationPickerViewControllerDelegate?
    
    var _locations:[LocationModel] = []
    var searchedArray:[String] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.text = LocationPickerViewController._last_query
        
        self.searchBar.delegate = self
        self.table_view.delegate = self
        self.table_view.dataSource = self
        
        
        self.searchBar.barTintColor = Colors.Appearance.primaryColor
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
 

        // Do any additional setup after loading the view.
        //get it from realm
        //_cities.append("Casablanca, Morocco [MA]")
        
        self._locations = self._locations.getFromCache()
        self.table_view.reloadData()

    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        Utils.printDebug("Search: \(searchText)")
        
        if(!onLoading && searchText.count >= 2 ){
            self.getCities(query: searchText)
        }
        
        LocationPickerViewController._last_query = searchText
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        LocationPickerViewController._last_result = nil
        
        if let delegate = self.delegate{
            if(LocationPickerViewController._last_query == ""){
                delegate.onSelect(query: LocationPickerViewController._last_query, object: nil)
            }
        }
        
        self.dismiss(animated: true)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true)
    }
    
    //MARK:- UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let object = self._locations[indexPath.row]
        let string = "\(object.name)"
        cell?.textLabel?.text = string
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        LocationPickerViewController._last_result = self._locations[indexPath.row]
        
        if let delegate = self.delegate, let city = LocationPickerViewController._last_result{
            delegate.onSelect(query: LocationPickerViewController._last_query, object: city)
        }
        
        self.dismiss(animated: true)
        
    }
    
    var onLoading = false
    
    func getCities(query: String){
        
        onLoading = true
        
        MyProgress.show(parent: self.table_view)
        
        let parameters = [
            "q": query,
            "country": "",
            ]
        
        
         Utils.printDebug("Request: \(parameters)")
        
        let api = SimpleLoader()
    
        api.run(url: Constances.Api.API_LPICKER_GET_LOCATIONS, parameters: parameters) { (parser) in
            
            Utils.printDebug("self.parser \(String(describing: parser))")
            
            if let MY_parser = parser, let json = MY_parser.json{
             
                let locationParser = LocationParser(content: String(describing: json))
            
                if(locationParser.success == 1){
                    self._locations = locationParser.parse();
                    
                    Utils.printDebug("self._cities \(self._locations)")
                    
                    self.table_view.reloadData()
                    self._locations.clear()
                    self._locations.saveAll()

                }
                
                
                MyProgress.dismiss()
                
                self.onLoading = false
               
            }else{
                // self.onLoading = false
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


