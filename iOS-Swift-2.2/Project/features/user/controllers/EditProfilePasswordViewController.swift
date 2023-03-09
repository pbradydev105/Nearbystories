//
//  SignUpViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftEventBus
import SwiftIcons
import SkyFloatingLabelTextField
import Kingfisher

protocol EditProfilePasswordControllerDelegate {
    func editPasswordSuccess(controller: EditProfilePasswordViewController, user: User)
    func editPasswordFaild(controller: EditProfilePasswordViewController)
    func onBackPressed(controller: EditProfilePasswordViewController)
}

class EditProfilePasswordViewController: MyUIViewController, UserLoaderDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: EditProfilePasswordControllerDelegate? = nil
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let controller = self.navigationController, config.customToolbar == true{
            controller.navigationBar.isHidden = true
        }
    }
    
    @IBOutlet weak var edit_container: UIView!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    

    @IBOutlet weak var user_information_container: UIStackView!
    
    @IBOutlet weak var current_password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var new_password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var confirm_password_field: SkyFloatingLabelTextField!
    
   
    
    @IBAction func saveChangesAction(_ sender: Any) {
        
        doSaveChanges()
        
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
        
        
        
        topBarTitle.text = "Edit Profile".localized
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    func setupNavBarButtons() {
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        
        
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        if config.backHome == true{
            navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
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
        
        if let del = delegate{
            del.onBackPressed(controller: self)
        }
        
    }
    
    
    var imageId: String = ""
    
    let imagePicker = UIImagePickerController()
    
    var myUserSession: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.edit_container.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.edit_container.roundCorners(radius: 4)
        
        
        
        if let session = Session.getInstance(), let user = session.user{
            myUserSession = user
        }else{
            dismiss(animated: true)
        }
        
        
        imagePicker.delegate = self
        
        if Session.isLogged() {
            
        }
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
        
        setupNavBarTitles()
        setupNavBarButtons()
        
        setupView()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            
            let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            
            if let textField = self.lastTextField, let _ = textField.superview?.convert(textField.frame, to: nil) {
                
                if isKeyboardShowing{
                    // so increase contentView's height by keyboard height
                   
                    UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }else{
                    // so increase contentView's height by keyboard height
                    UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                
            }
  
        }
        
    }
    
    
    
    @IBAction func haveAccountBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupView ()  {
        
       
        
        current_password_field.textColor = UIColor.black
        current_password_field.lineColor = UIColor.gray
        current_password_field.selectedTitleColor = UIColor.black
        current_password_field.selectedLineColor = Colors.Appearance.primaryColor
        current_password_field.selectedLineHeight = 1.5
        current_password_field.lineHeight = 0.5
        current_password_field.titleColor = Colors.Appearance.primaryColor
        current_password_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: current_password_field.font!.pointSize)
        current_password_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: current_password_field.font!.pointSize)!
        
    
        new_password_field.textColor = UIColor.black
        new_password_field.lineColor = UIColor.gray
        new_password_field.selectedTitleColor = UIColor.black
        new_password_field.selectedLineColor = Colors.Appearance.primaryColor
        new_password_field.selectedLineHeight = 1.5
        new_password_field.lineHeight = 0.5
        new_password_field.titleColor = Colors.Appearance.primaryColor
        new_password_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: new_password_field.font!.pointSize)
        new_password_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: new_password_field.font!.pointSize)!
              
        
        
        confirm_password_field.textColor = UIColor.black
        confirm_password_field.lineColor = UIColor.gray
        confirm_password_field.selectedTitleColor = UIColor.black
        confirm_password_field.selectedLineColor = Colors.Appearance.primaryColor
        confirm_password_field.selectedLineHeight = 1.5
        confirm_password_field.lineHeight = 0.5
        confirm_password_field.titleColor = Colors.Appearance.primaryColor
        confirm_password_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: confirm_password_field.font!.pointSize)
        confirm_password_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: confirm_password_field.font!.pointSize)!
          
        
        current_password_field.placeholder = "Enter old password".localized
        new_password_field.placeholder = "New password".localized
        confirm_password_field.placeholder = "Confirm".localized
        
        saveBtn.initDefaultFont()
        saveBtn.setTitle("Change Password".localized.uppercased(), for: .normal)
        saveBtn.backgroundColor = Colors.Appearance.primaryColor
        saveBtn.setTitleColor(.white, for: .normal)
        
        current_password_field.delegate = self
        
    }
    
    
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
    
    
    
    var userLoader: UserLoader = UserLoader()
    func doSaveChanges () {
        
        
        guard let user = myUserSession else { return }
        
        
        MyProgress.show(parent: self.view)
        
        self.userLoader.delegate = self
        
        
      
        guard let currentPasswordValue = current_password_field.text else {
            showErros(messages:["password":"Current password field is empty".localized])
            return
        }
        
        guard let newPasswordValue = new_password_field.text else {
            showErros(messages:["password":"New password field is empty".localized])
            return
        }
        
        guard let confirmPasswordValue = confirm_password_field.text else {
            showErros(messages:["password":"Confirmation field is empty".localized])
            return
        }
        
    
        
    
         self.userLoader.load(url: Constances.Api.API_UPDATE_ACCOUNT_PASSWORD,parameters: [
            "user_id"                   : String(user.id),
            "username"                  : String(user.username),
            "current_password"         : currentPasswordValue,
            "new_password"             : newPasswordValue,
            "confirm_password"         : confirmPasswordValue,
         ])
     
        
    }
    

    
    func success(parser: UserParser,response: String) {
        
        if parser.success == 1 {
            
            
            SVProgressHUD.dismiss()
            
            let users = parser.parse()
            
            if users.count == 1 {
                
                Utils.printDebug("\(users)")
                
                Session.createSession(user: users[0])
                
                
                self.current_password_field.text = ""
                self.new_password_field.text = ""
                self.confirm_password_field.text = ""
                
                
                self.showAlert(title: "Success",content: ["err": "Your password was changed successful!".localized],msgBnt: "OK")
        
                
                SwiftEventBus.post("on_main_refresh", sender: users[0])
                
                
            }else{
                showErros(messages: ["err": "User not found!".localized])
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
        
        Utils.printDebug("\(response)")
        
        self.showAlertError(title: "Error",content: errors,msgBnt: "OK")
        //
        
    }
    
    
    func showErros(messages: [String: String]) {
        
        self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    
    func startMainVC() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true)
        }
        
    }
    
   
    
    
}





