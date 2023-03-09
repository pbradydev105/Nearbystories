//
//  SettingViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/18/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import AssistantKit


struct Settings {
    struct Keys {
        static let OFFERS_NOTIFICATION = "offers_notification"
        static let STORES_NOTIFICATION = "stores_notification"
        static let EVENTS_NOTIFICATION = "events_notification"
        static let CEVENTS_NOTIFICATION = "cevents_notification"
        static let MESSENGER_NOTIFICATION = "messenger_notification"
    }
}

class SettingsViewController: UITableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        
       //navigationController?.navigationBar.isHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let _ = self.tabBarController{
            navigationController?.navigationBar.isHidden = true
        }else{
            navigationController?.navigationBar.isHidden = true
        }
        
    }
        
    @IBOutlet weak var offersnotificationLabel: UILabel!
    @IBOutlet weak var offernotificationDescription: UILabel!
    
    @IBOutlet weak var eventsnotificationLabel: UILabel!
    @IBOutlet weak var eventsotificationDescription: UILabel!
    
    @IBOutlet weak var storesnotificationLabel: UILabel!
    @IBOutlet weak var storesnotificationDescription: UILabel!
    
    @IBOutlet weak var coeventnotificationLabel: UILabel!
    @IBOutlet weak var coeventnotificationDescription: UILabel!
    
    @IBOutlet weak var messengernotificationLabel: UILabel!
    @IBOutlet weak var messengernotificationDescription: UILabel!
    
    
    @IBOutlet weak var offers_notification_switch: UISwitch!
    @IBOutlet weak var events_notification_switch: UISwitch!
    @IBOutlet weak var stores_notification_switch: UISwitch!
    @IBOutlet weak var cevents_notification_switch: UISwitch!
    @IBOutlet weak var messenger_notification_switch: UISwitch!
    
    
    @IBAction func offers_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.OFFERS_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func events_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.EVENTS_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func stores_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.STORES_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func cevents_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.CEVENTS_NOTIFICATION, value: view.isOn)
    }
    
    @IBAction func messenger_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.MESSENGER_NOTIFICATION, value: view.isOn)
    }
    
    
    
    @IBOutlet weak var termsanduse: UILabel!
    @IBOutlet weak var privacypolicy: UILabel!
    @IBOutlet weak var appversionValue: UILabel!
    @IBOutlet weak var appversionlabel: UILabel!
    
    
    @IBAction func termsAndUseAction(_ sender: Any) {
        
        
        if let url = URL(string: AppConfig.Api.terms_of_use_url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
    }
    
    @IBAction func pravicyPolicyAction(_ sender: Any) {
        
        if let url = URL(string: AppConfig.Api.privacy_policy_url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    

      
      @objc func onBackHandler()  {
          
          if let controller = self.navigationController{
              //controller.navigationBar.isHidden = true
              controller.popViewController(animated: true)
              ////controller.navigationBar.isHidden = false
          }else{
              self.dismiss(animated: true)
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
          
          
          
          topBarTitle.text = "Setting".localized
        
        
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
          
          
          navigationItem.titleView = topBarTitle
          
      }
      
      
      
      func setupNavBarButtons() {
          
          let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)

          //arrow back icon
          var arrowImage: UIImage? = nil
          if Utils.isRTL(){
              arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
          }else{
              arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
          }
          
          
          let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
          customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
          
          
          navigationItem.leftBarButtonItems = []
          navigationItem.rightBarButtonItems = []
          navigationItem.leftBarButtonItems?.append(customBarButtonItem)
          
      }
      
     

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        if let _ = self.tabBarController{
            self.tabBarController?.navigationController?.navigationBar.isHidden = false
        }else{
            //navigationController?.isToolbarHidden
            self.navigationController?.navigationBar.isHidden = false
        }

        
        setupNavBarTitles()
        setupNavBarButtons()
    
        navigationController?.navigationBar.tintColor = .white
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.backgroundView = backgroundView
        
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        
        offersnotificationLabel.initBolodFont()
        offernotificationDescription.initDefaultFont()
        
        eventsnotificationLabel.initBolodFont()
        eventsotificationDescription.initDefaultFont()
        
        storesnotificationLabel.initBolodFont()
        storesnotificationDescription.initDefaultFont()
        
        coeventnotificationLabel.initBolodFont()
        coeventnotificationDescription.initDefaultFont()
        
        messengernotificationLabel.initBolodFont()
        messengernotificationDescription.initDefaultFont()
        
        
        appversionlabel.initBolodFont()
        appversionValue.initDefaultFont()
        privacypolicy.initDefaultFont()
        termsanduse.initDefaultFont()
        
        
        
        offersnotificationLabel.text = "Offers notification".localized
        offernotificationDescription.text = "Receive a special offer notification".localized
        
        eventsnotificationLabel.text = "Nearby Events Notification".localized
        eventsotificationDescription.text = "Offers notification".localized
        
        storesnotificationLabel.text = "Nearby stores notifications".localized
        storesnotificationDescription.text = "Receive notification when there is a store near you".localized
        
        coeventnotificationLabel.text = "Coming event notification".localized
        coeventnotificationDescription.text = "Receive notification when there is a event coming".localized
        
        messengernotificationLabel.text = "Messenger notifications".localized
        messengernotificationDescription.text = "Receive notification when there is new messages".localized
        
        termsanduse.text = "Terms of use".localized
        privacypolicy.text = "Privacy Policy".localized
        appversionlabel.text = "Application Version".localized
        
        
        if(AppConfig.DEBUG){
            for (key,value) in Localization.list_to_translate{
                print("\"\(key)\" = \"\(value)\";")
            }
        }
        
       
        offers_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.OFFERS_NOTIFICATION, defaultValue: true)!
        events_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.EVENTS_NOTIFICATION, defaultValue: true)!
        stores_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.STORES_NOTIFICATION, defaultValue: true)!
        cevents_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.CEVENTS_NOTIFICATION, defaultValue: true)!
        
        messenger_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION, defaultValue: true)!
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        if(AppConfig.DEBUG){
            
            if let guest = Guest.getInstance(){
                self.appversionValue.text = "\(version) / Guest ID \(guest.id)"
            }else{
                self.appversionValue.text = "\(version)"
            }
           
        }else{
            self.appversionValue.text = "\(version)"
        }
        
        
    }

    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        
        headerView.textLabel?.textColor = Colors.Appearance.primaryColor.withAlphaComponent(0.8)
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17.0)
        headerView.textLabel?.font = font!
        
       // headerView.textLabel?.text = headerView.textLabel?.text?.localized
        
    }



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
