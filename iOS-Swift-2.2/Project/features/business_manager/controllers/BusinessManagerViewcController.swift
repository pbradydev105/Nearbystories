//
//  BusinessManagerViewcController.swift
//  NearbyStoresPro
//
//  Created by Amine  on 3/22/20.
//  Copyright © 2020 Amine. All rights reserved.
//

import UIKit
import WebKit

class BusinessManagerViewcController: MyUIViewController, ErrorLayoutDelegate, EmptyLayoutDelegate, WKNavigationDelegate{
    
    func onReloadAction(action: ErrorLayout) {
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var view_container: UIView!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity_indicator.color = .white
        
        setupNavigationBar()
        setupNavBarButtons()
        setupNavBarTitles()
       
        topBarTitle.text = "Business Manager".localized
        
        
        
        if let sess = Session.getInstance(), let user = sess.user{
            self.business_manager_link = AppConfig.Api.base_url+"/business_manager/index?lang="+(Locale.current.languageCode!)+"&session="+user.username+"&uri=businesses"
            setupWebView()
        }

        
    }
    
    
    func setupNavigationBar() {
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
    }
    
    func setupNavBarTitles() {
           
           let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
           topBarTitle.frame = rect
           topBarTitle.textColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
           topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
           topBarTitle.leftTextInset = 5
           
           topBarTitle.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
           
           navigationBarItem.titleView = topBarTitle

       }
    
    let topBarTitle: EdgeLabel = {

         let titleLabel = EdgeLabel()

         let appname = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Home".localized

         titleLabel.text = appname

         if(AppConfig.Design.uiColor == AppStyle.uiColor.dark){
             titleLabel.textColor = UIColor.white
         }else{
             titleLabel.textColor = Colors.Appearance.primaryColor
         }

         titleLabel.font = UIFont.systemFont(ofSize: 20)

         return titleLabel

     }()
    
    
    func setupNavBarButtons() {
           
           //arrow back icon
           var icon: UIImage? = nil
            icon = UIImage.init(icon: .googleMaterialDesign(.close), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
           

           let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
           let customBackButtonItem = UIBarButtonItem(image: icon!, style: .plain, target: self, action: #selector(onBackHandler))
           customBackButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
           
           
           navigationBarItem.leftBarButtonItems = []
           navigationBarItem.rightBarButtonItems = []
           
           if(config.backHome){
               navigationBarItem.leftBarButtonItems?.append(customBackButtonItem)
           }
           
           
       }
    
    
    var customOptionsButtonItem:UIBarButtonItem?
    func addCraeteNavigationBarButton() {
        
        let icon = UIImage.init(icon: .ionicons(.androidMoreVertical), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        customOptionsButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onCreateHandler))
        customOptionsButtonItem!.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.rightBarButtonItems?.append(customOptionsButtonItem!)
        
    }
    
    @objc func onCreateHandler()  {
        
        let dict = [
                   "device": "ios",
                   "action": "manage_business_options"
               ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!

       
        if let _webview = self.webView{
            _webview.evaluateJavaScript("handle_device_events(\(jsonString))") { result, error in
                guard error == nil else {
                    //print(error)
                    return
                }
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
        
        /*
        if(links.count > 0){
            //alert
            let alert = UIAlertController(title: "Alert".localized, message: "Are you sure to leave business Manager".localized, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { action in
                if let controller = self.navigationController{
                               //controller.navigationBar.isHidden = true
                               controller.popViewController(animated: true)
                               ////controller.navigationBar.isHidden = false
                           }else{
                               self.dismiss(animated: true)
                           }
            }))
            
            
            alert.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: { action in
                alert.dismiss(animated: true)
            }))
            
            present(alert, animated: true)
        
        }*/
  
        
    }
    
    
    var business_manager_link:String? = ""
    var webView: WKWebView?

    
    private func setupWebView(){
        
        
        //init webview
        self.webView = WKWebView()
        self.webView?.frame = self.view_container.frame
        if let _webView  = self.webView {
            
            self.view_container.addSubview(_webView)
            
            self.view_container.addConstraintsWithFormat(format: "H:|[v0]|", views: _webView)
            self.view_container.addConstraintsWithFormat(format: "V:|[v0]|", views: _webView)
            
            _webView.navigationDelegate = self
            _webView.translatesAutoresizingMaskIntoConstraints = false
            
            _webView.isHidden = true
            
        }
        
        //start loding
        
        if let _webView = self.webView{
                   
           self.activity_indicator.isHidden = false
            self.activity_indicator.startAnimating()
            
            
            
            let url = URL(string: business_manager_link!)!
            _webView.load(URLRequest(url: url))
                            
            _webView.isHidden = false
            _webView.allowsBackForwardNavigationGestures = true
                              
            self.view.layoutIfNeeded()
                   
        }
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        self.activity_indicator.isHidden = false
        navigationBarItem.rightBarButtonItems = []
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
          if let url = navigationAction.request.url?.absoluteString {
            Utils.printDebug("BusinessManager: \(url)")
            checkCallbackURL(url: url)
          }
          
          decisionHandler(.allow)
      }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
                                 
           
           if let response = navigationResponse.response as? HTTPURLResponse {
               if response.statusCode != 200 {
                   self.webView?.isHidden = false
                   let message = "Error \(response.statusCode)"
                   self.showAlertError(title: "Error",content: ["":message] ,msgBnt: "OK")
                   decisionHandler(.allow)
                   return
               }
           }
           
           decisionHandler(.allow)
       }
    

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.activity_indicator.isHidden = true
        self.addCraeteNavigationBarButton();
        
        let javascript = "document.title\n"
        
        if let title = webView.title{
            self.topBarTitle.text = title
        }

    }
    
    var links:[String] = []
    
    func checkCallbackURL(url: String) -> Bool {
       
        let requestURLString = url
        if requestURLString.hasPrefix(AppConfig.Api.base_url) && requestURLString != business_manager_link {
            links.append(requestURLString)
            return false;
        }
        return true
    }
   
    
       
      
   
}
