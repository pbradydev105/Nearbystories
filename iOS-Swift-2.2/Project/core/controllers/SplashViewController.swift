//
//  SplashViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import CoreLocation
import AssistantKit
import SwiftEventBus
import FirebaseInstanceID
import RealmSwift

class SplashViewController: MyUIViewController, CLLocationManagerDelegate {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
        }
    }

    func setupAppearenceDarkColors() {


        if #available(iOS 13.0, *) {
           // overrideUserInterfaceStyle = .dark
        }

        if #available(iOS 12.0, *) {
            guard self.traitCollection.userInterfaceStyle == .dark else {
               // Colors.Appearance.darkColor = Colors.white
                return
            }
        } else {
            return
        }

        AppStyle.isDarkModeEnabled = true

        AppConfig.Design.uiColor = AppStyle.uiColor.dark
        Colors.Appearance.primaryColor = Colors.accentColor
        
        Colors.Appearance.darkColor = Colors.lightBlack
        Colors.Appearance.background = Colors.blackDarkModeBackgound

        Colors.Appearance.white = Colors.lightBlack
        Colors.Appearance.black = Colors.white
        Colors.Appearance.whiteGrey = Colors.lightBlack
        

        //setup tabBar appearance
        UITabBar.appearance().tintColor = Colors.white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.Appearance.primaryColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.lightBlack], for: .normal)

        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 10) {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
        }


        UINavigationBar.appearance().barTintColor = Colors.Appearance.white


        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        } else {
            // Fallback on earlier versions
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]

        }
    }

    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D? = nil


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }

        self.currentLocation = locValue

        Utils.printDebug("\(locations)")

    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        
        self.currentLocation = locValue

        Utils.printDebug("locationManager \(CLLocationManager.authorizationStatus().rawValue)")


        if CLLocationManager.locationServicesEnabled() {

            switch CLLocationManager.authorizationStatus() {

            case .notDetermined, .restricted, .denied:
                self.requestLocation()
            case .authorizedAlways, .authorizedWhenInUse:

                self.requestLocation()

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if Guest.isStored() == false {
                        self.guest_refresh(startMain: true)
                    } else {
                        self.guest_refresh(startMain: false)
                    }

                }

            default:
                self.startApp()
            }

        } else {

            if Constances.Global.GPS_REQUIRE_ENABLE {
                self.enableGPS()
            } else {
                self.requestLocation()
            }

        }


    }

    func requestLocation() {

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()


    }


    @IBOutlet weak var app_icon_height: NSLayoutConstraint!

    @IBOutlet weak var app_icon_width: NSLayoutConstraint!


    override func viewDidAppear(_ animated: Bool) {

        if stopExecute {
            return
        }
        
    

        if !Connectivity.isConnected() {
            self.showAlertInitError(title: "Opps - Connection error!".localized, msg: "\nCould't connect with server side!\n Please check your internet connection".localized, msgBnt: "Turn on".localized, clicked: {


                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }


                //if let url = URL(string:"App-Prefs:root=Settings&path=General") {
                //  UIApplication.shared.openURL(url)
                //}

                self.showAlertInitError(title: "Opps - Connection error!".localized, msg: "\nCould't connect with server side!\n Please check your internet connection".localized, msgBnt: "Refresh".localized, clicked: {
                    if Connectivity.isConnected() {
                        self.startApp()
                    } else {
                        self.viewDidAppear(true)
                    }
                })

            })
            //show alert
        } else {


            startApp()


        }
    }


    func init_config() {


    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.setupAppearenceDarkColors()
        self.requestLocation()

        self.view.backgroundColor = .white

        //SERVER SYNC
        //getCurrentUnredNotificationsCount()
        getAllModulesConfig();

        LoginViewController.listner(parent: self)
        SignUpViewController.listner(parent: self)


        UIApplication.shared.statusBarView?.backgroundColor = Colors.Appearance.darkColor

        app_icon_splash.isHidden = true


        if let language = Locale.current.languageCode {
            LocalData.setValue(key: "language", value: language)
        } else {
            LocalData.setValue(key: "language", value: "en")
        }

    }


    func startApp() {


        //remove caches
        self.initCache()

        //refresh FCM for push notification
        self.refreshFCM()

        //check user if is connected
        self.checkUserState()

        //check device version
        Utils.printDebug("Phone Inches => \(Device.screen)")
        Utils.printDebug("Phone Version => \(Device.version)")
        Utils.printDebug("Phone type => \(Device.type)")


        if Device.isPad {
            app_icon_width.constant = app_icon_width.constant+100
            app_icon_height.constant = app_icon_height.constant+100
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let animation = UIAnimation(view: self.app_icon_splash)
            animation.zoomIn()
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

            if AppSetting.isInitialized() == false {
                //load token from server
                self.app_init()
            } else {
                //start next interface
                self.refreshFCM()

                if (Constances.Global.GPS_REQUIRE_ENABLE) {
                    self.refreshLocationAndStartMain()
                } else {

                    self.guest_refresh(startMain: false)
                    self.startMainVC()
                    //self.app_init()
                }
            }
        }

    }


    func refreshLocationAndStartMain() {


        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {

            case .notDetermined, .restricted, .denied:
                self.requestLocation()
            case .authorizedAlways, .authorizedWhenInUse:

                if Guest.isStored() {
                    self.startMainVC()
                } else {
                    self.guest_refresh(startMain: true)
                }

            default: break

            }

        } else {

            if Constances.Global.GPS_REQUIRE_ENABLE {
                self.enableGPS()
            } else {
                self.requestLocation()
            }

        }

    }


    @IBOutlet weak var app_icon_splash: UIImageView!

    func startConnectionVC() {

        //stop updating location
        locationManager.stopUpdatingLocation()


        let animation = UIAnimation(view: self.app_icon_splash)
        animation.zoomOut()


        let sb = UIStoryboard(name: "Connection", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }


    func startMainVC() {


        //stop updating location
        locationManager.stopUpdatingLocation()

        let animation = UIAnimation(view: self.app_icon_splash)
        animation.zoomOut()

        _ = UICollectionViewFlowLayout()

        
        let main = UINavigationController(rootViewController: MainV2TabBarController())
        //self.navigationController?.pushViewController(main, animated: true)
        //main.setNavigationBarHidden(true, animated: true)
        main.navigationBar.isHidden = true

        main.modalPresentationStyle = .fullScreen
        
        self.present(main, animated: true) {
            self.stopExecute = true
        }


    }

    private var stopExecute = false;

    func app_init() {

        init_config()

        Utils.printDebug("Init started!")
        Utils.printDebug("Init started! \(Constances.Api.API_APP_INIT)")

        let api = MyApi()

        let headers = api.headers


        let params = [
            "Api-key-ios": AppConfig.Api.ios_api
        ]

        Utils.printDebug("Headers: \(headers)")

        Alamofire.request(Constances.Api.API_APP_INIT, method: .post, parameters: params, headers: headers).responseJSON { response in

            if let error = response.error {
                Utils.printDebug("\(error)")
            }


            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {

                Utils.printDebug("\(utf8Text)")

            }

            if let status = response.response?.statusCode {
                switch (status) {
                case 201:
                    Utils.printDebug("Load success")
                case 500:
                    self.showError(status: 500)
                default:

                    Utils.printDebug("error with response status: \(status)")
                }
            }

            Utils.printDebug("Init ended with data! ==> \(response.data!)")


            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {


                if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8) {
                    do {
                        _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)

                        Utils.printDebug("Init ended with json! ==> \(utf8Text)")

                        let parser = Parser(content: utf8Text)

                        if parser.success == 1 {

                            let token = parser.json!["token"].stringValue
                            LocalData.setValue(key: "token", value: token)


                            if (Constances.Global.GPS_REQUIRE_ENABLE) {
                                self.refreshFCM()
                                self.requestLocation()
                                self.refreshLocationAndStartMain()
                            } else {
                                self.guest_refresh(startMain: true)
                            }

                        } else {

                            self.locationManager.stopUpdatingLocation()
                            self.showAlertInitError(title: "Opps - Initialization error!".localized, msg: "\nCould't connect with server side!\n Please check API key".localized, msgBnt: "EXIT".localized, clicked: {
                                exit(0)
                            })
                            //show alert


                        }


                    } catch {

                        Utils.printDebug("Error deserializing JSON: \(error.localizedDescription)")

                        self.showAlertInitError(title: "Opps - Initialization error!".localized, msg: "\nCould't connect with server side!\n Please check your network".localized, msgBnt: "EXIT".localized, clicked: {
                            exit(0)
                        })

                        self.locationManager.stopUpdatingLocation()

                    }

                } else {

                    self.refreshFCM()
                    self.requestLocation()

                }

            } else {


            }

        }


    }


    func showError(status: Int) {
        self.showAlertInitError(title: "Opps - Initialization error!", msg: "\nCould't connect with server side!\n error with response status: \(status)", msgBnt: "EXIT", clicked: {
            exit(0)
        })
    }


    func refreshFCM() {


    }


    func guest_refresh(startMain: Bool) {


        let token = LocalData.getValue(key: "firebase_fcm", defaultValue: "")
        if token != ""{
            self.guest_api_loader(token: token,startMain: startMain)
        }else{
            self.guest_api_loader(token: "NaN",startMain: startMain)
        }


    }


    func guest_api_loader(token: String, startMain: Bool) {

        let api = MyApi()
        let headers = api.headers


        //Get current Location
        var lat = 0.0
        var lng = 0.0

        if let location = currentLocation {
            lat = location.latitude
            lng = location.longitude
        }


        let parameters = [
            "fcm_id": token,
            "sender_id": Token.getDeviceId(),
            "mac_adr": Token.getDeviceId(),
            "platform": "ios",
            "lat": String(lat),
            "lng": String(lng)
        ]


        Utils.printDebug("headers: \(headers)")
        Utils.printDebug("parameters: \(parameters)")


        Alamofire.request(Constances.Api.API_USER_REGISTER_TOKEN, method: .post, parameters: parameters, headers: headers).responseJSON { response in


            if let error = response.error {
                Utils.printDebug("\(error)")
            }


            if let status = response.response?.statusCode {
                switch (status) {
                case 201:
                    Utils.printDebug("Load success")
                case 500:
                    self.showError(status: 500)
                default:
                    Utils.printDebug("response with status: \(status)")
                    self.locationManager.stopUpdatingLocation()
                }
            }


            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {

                Utils.printDebug("\(utf8Text)")

                let parser = GuestParser(content: utf8Text)


                if parser.success == 1 {

                    let guests = parser.parse()

                    if guests.count > 0 {

                        Guest.saveGuest(guest: guests[0])

                        if let g = Guest.getInstance() {
                            Utils.printDebug("Guest Instance ==> \(startMain) \(g)")
                        }

                    }

                    if startMain {
                        self.startMainVC()
                    }


                } else if parser.success == -1 {

                    if let errors = parser.errors {

                        self.showAlertInitErrors(title: "Api error!".localized, content: errors, msgBnt: "EXIT")
                    }

                }

            } else {

                if startMain {
                    self.startMainVC()
                }


            }


        }

    }


    func enableGPS() {


        let alert = UIAlertController(
                title: "Enable GPS",
                message: "GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.",
                preferredStyle: UIAlertController.Style.alert
        )

        alert.addAction(UIAlertAction(title: "Go to Settings now".localized, style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in


            if !CLLocationManager.locationServicesEnabled() {

                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }


                //if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                // If general location settings are disabled then open general location settings
                //UIApplication.shared.openURL(url)
                //}
            } else {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.openURL(url)
                }
            }

        }))


        alert.addAction(UIAlertAction(title: "Open".localized, style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in

            self.startApp()

        }))

        self.present(alert, animated: true)
    }


    func initCache() {

        //remove all stored messages
        Message.removeAll()
        MessengerCache.removeAll()

    }


    func checkUserState() {

        guard Session.isLogged() else {
            return
        }
        guard let session = Session.getInstance(), let user = session.user else {
            return
        }

        let api = UserLoader()

        let params = [
            "email": user.email,
            "userid": String(user.id),
            "username": user.username,
            "senderid": user.senderid,
        ]


        api.run(url: Constances.Api.API_USER_CHECK_CONNECTION, parameters: params) { (userParser) in

            guard let parser = userParser else {
                return
            }

            if parser.success == 1 {
                let users = parser.parse()
                if users.count == 0 {
                    let _ = Session.logout()
                } else {
                    users[0].save()
                }
            }

        }

    }


    func getCurrentUnredNotificationsCount() {

        if let c = LocalData.getValue(key: "unread_notifications",
                defaultValue: Notification.unread_notifications) {
            Notification.unread_notifications = c
        }


        //sync
        var parameters = [
            "status": String("0"),
        ]

        if let sess = Session.getInstance(), let user = sess.user {
            parameters["auth_type"] = "user"
            parameters["auth_id"] = String(user.id)
        } else if let guest = Guest.getInstance() {
            parameters["auth_type"] = "guest"
            parameters["auth_id"] = String(guest.id)
        }

        Utils.printDebug("parameters \(parameters)")


        let api = SimpleLoader()

        api.run(url: Constances.Api.API_GET_NOTIFICATIONS_COUNT, parameters: parameters) { (parser) in

            Utils.printDebug("parser \(parser)")

            if let result = parser?.result, parser?.success == 1 {

                Notification.unread_notifications = result.intValue
                SwiftEventBus.post("on_badge_refresh", sender: true)

                LocalData.setValue(key: "unread_notifications", value: Notification.unread_notifications)

                UIApplication.shared.applicationIconBadgeNumber = Notification.unread_notifications


            }

        }

    }


    func getAllModulesConfig() {


        //sync
        let parameters = [
            "test": ""
        ]


        let api = SimpleLoader()

        api.run(url: Constances.Api.API_GET_MODULES, parameters: parameters) { (parser) in

            if let result = parser?.result, parser?.success == 1 {

                let modules_parser = ModulesParser(json: result)
                let modules = modules_parser.parse()
                modules.saveAll()

            }

        }

    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in
        (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
    })
}
