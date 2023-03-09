//
//  LoginViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import SkyFloatingLabelTextField
import SwiftWebVC


protocol LoginControllerDelegate {
    func loginSuccess(controller: LoginViewController, user: User)
    func loginFaild(controller: LoginViewController)
}

class LoginViewController: MyUIViewController,UserLoaderDelegate, UITextFieldDelegate, SignUpControllerDelegate {
   
    static func newInstance() -> LoginViewController{
        let login_sb = UIStoryboard(name: "Login", bundle: nil)
        let login_vc: LoginViewController = login_sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        return login_vc
    }
    
    func signupSuccess(controller: SignUpViewController, user: User) {
        
        controller.onBackHandler()
        
        if let del = delegate{
            del.loginSuccess(controller: self, user: user)
        }
        
    }
    
    func signupFaild(controller: SignUpViewController) {
        
    }
    
   
  
    var delegate: LoginControllerDelegate? = nil
    
    var request: Int = 0

    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
    }
    
    
    static func listner(parent: UIViewController) {
        
        SwiftEventBus.onMainThread(self, name: "open_view_login") { result in
            
            let sb = UIStoryboard(name: "Login", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                parent.present(ms, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var login_container_image_bg: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var main_container: UIView!
    @IBOutlet weak var login_container: UIView!
    
    @IBOutlet weak var forgotpassword: UIButton!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var signin: CustomButton!
    @IBOutlet weak var signup: CustomButton!
    
    @IBAction func signUpAction(_ sender: Any) {
        
        let sb = UIStoryboard(name: "Signup", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "signupVC") as! SignUpViewController
        
        vc.config.customToolbar = true
        vc.config.backHome = true
        vc.delegate = self
        
        if let controller = self.navigationController{
            
            controller.pushViewController(vc, animated: true)
        }else{
            self.present(vc, animated: true)
        }
        
    }
    
    
    @IBAction func signInAction(_ sender: Any) {
    
        dologin()
    
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
        if let url = URL(string: AppConfig.Api.base_url+"/fpassword"), UIApplication.shared.canOpenURL(url) {
            let webVC = SwiftModalWebVC(pageURL: url, theme: .dark, dismissButtonStyle: .cross, sharingEnabled: true)
            //self.navigationController?.pushViewController(webVC, animated: true)
            self.present(webVC, animated: true, completion: nil)
            
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
        
       
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        
        
        //
        //navigationBarItem.rightBarButtonItems?.append(createAccountBtn)
        
        
        if(config.backHome ==  true){
            navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
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
        
        
        topBarTitle.text = "Login".localized
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.navigationController?.navigationBar.isHidden = true
        
        
        self.main_container.backgroundColor = Colors.Appearance.primaryColor
        

        self.login_container.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.login_container.roundCorners(radius: 4)
        
        self.login_container_image_bg.contentMode = .scaleAspectFill
        self.login_container_image_bg.image = UIImage(named: AppConfig.Design.loginBackgounds.randomElement()!)
        
        
        forgotpassword.setTitleColor(.white, for: .normal)
        forgotpassword.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        forgotpassword.roundCorners(radius: 10)
        forgotpassword.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        
        
        if config.customToolbar{
            
            self.navigationBar.isTranslucent = false
            self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
            
            setupNavBarTitles()
            setupNavBarButtons()
        }else{
            self.navigationBar.isHidden = true
        }
       
        
        
          
        if !config.customToolbar{
            self.navigationBar.isHidden = true
        }
        
        /*if Session.isLogged() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.dismiss(animated: true)
            }
        }*/

        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        SwiftEventBus.onMainThread(self, name: "on_close_it") { result in
            
            if let _ = result?.object{
                
                if let mySession = Session.getInstance(), let user = mySession.user{
                    SwiftEventBus.post("on_main_refresh", sender: user)
                    self.dismiss(animated: true)
                }
            }
            
        }
        
       
      
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            
            if let textField = self.lastTextField, let _ = textField.superview?.convert(textField.frame, to: nil) {
                
                if isKeyboardShowing{
                    // so increase contentView's height by keyboard height
                    //self.constraintScrollBottomHeight.constant = keyboardFrame.height
                    UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }else{
                    // so increase contentView's height by keyboard height
                    //self.constraintScrollBottomHeight.constant = 0
                    UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                
            }
        
        }
    
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
    
    func startMainVC() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true)
        }
        
    }
    
    
    func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
   
    func setupViews() {
        
        let font = UIFont(name: AppConfig.Design.Fonts.bold, size: 14)
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : font!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]

        let attributeString = NSMutableAttributedString(string: "Forgot password?".localized,
                                                        attributes: yourAttributes)
        forgotpassword.setAttributedTitle(attributeString, for: .normal)
        
        login_field.delegate = self
        password_field.delegate = self
        
        
        login_field.textColor = UIColor.black
        login_field.lineColor = UIColor.gray
        login_field.selectedTitleColor = UIColor.black
        login_field.selectedLineColor = Colors.Appearance.primaryColor
        login_field.selectedLineHeight = 1.5
        login_field.lineHeight = 0.5
        login_field.titleColor = Colors.Appearance.primaryColor
        login_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)
        login_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: password_field.font!.pointSize)!
        
        
        password_field.textColor = UIColor.black
        password_field.lineColor = UIColor.gray
        password_field.selectedTitleColor = UIColor.black
        password_field.selectedLineColor = Colors.Appearance.primaryColor
        password_field.selectedLineHeight = 1.5
        password_field.lineHeight = 0.5
        password_field.titleColor = Colors.Appearance.primaryColor
        password_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)
        password_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: password_field.font!.pointSize)!
        
        
        login_field.placeholder = "Enter login".localized
        password_field.placeholder = "Enter password".localized
        signin.setTitle("Sign In".localized.uppercased(), for: .normal)
        signup.setTitle("Create An Account".localized.uppercased(), for: .normal)
        
        
        login_field.delegate = self
        password_field.delegate = self
        
      
        
        
     
    }

    

    var userLoader: UserLoader = UserLoader()
    func dologin () {
        
        
        MyProgress.show()
        
    
        self.userLoader.delegate = self
        
        
        guard let loginValue = login_field.text else {
            showErros(messages:["login":"Login field is empty"])
            return
        }
    
        guard let passwordValue = password_field.text else {
            showErros(messages:["password":"Password field is empty"])
            return
        }
        
        
        //Get current Location
        var lat = 0.0
        var lng = 0.0
        var guest_id = 0
        
        if let guest = Guest.getInstance() {
            lat = guest.lat
            lng = guest.lng
            guest_id = guest.id
        }
        
        self.userLoader.load(url: Constances.Api.API_USER_LOGIN,parameters: [
            "login"     : loginValue,
            "password"  : passwordValue,
            "lat"       : String(lat),
            "lng"       : String(lng),
            "guest_id"  : String(guest_id)
        ])
        
        
    }
    
    
    func success(parser: UserParser,response: String) {
        
        if parser.success == 1 {
            
        
            MyProgress.showProgressWithSuccess(withStatus: "Success!")
            
            let users = parser.parse()
            
            if users.count == 1 {
                
                Utils.printDebug("\(users)")
                
                Session.createSession(user: users[0])
                
                
                if let del = self.delegate{
                    del.loginSuccess(controller: self, user: users[0])
                }else{
                    onBackHandler()
                }
                
                SwiftEventBus.post("on_main_refresh", sender: users[0])
                
               
                
            }else{
                showErros(messages: ["err": "User not found!"])
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                //start main activity
                
            }
            
            
            
        }else {
            
        
            
            if let errors = parser.errors {
                
                MyProgress.dismiss()
                self.showAlertError(title: "Error",content: errors ,msgBnt: "OK")
            }
            
        }
        
    }
    
    func error(error: Error?,response: String) {
    
        MyProgress.dismiss()
        
        let errors: [String: String] = [
            "err": "Technical error"
        ]
        
       
        self.showAlertError(title: "Error",content: errors,msgBnt: "OK")
        
        
    }
    
    
    func showErros(messages: [String: String]) {
        
         self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
  


}




