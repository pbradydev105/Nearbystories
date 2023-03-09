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

protocol EditProfileControllerDelegate {
    func editProfilSuccess(controller: EditProfileViewController, user: User)
    func editProfileFaild(controller: EditProfileViewController)
    func onBackPressed(controller: EditProfileViewController)
}

class EditProfileViewController: MyUIViewController, UserLoaderDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static func newInstance() -> EditProfileViewController{
        let profile_sb = UIStoryboard(name: "EditProfile", bundle: nil)
        let profile_vc: EditProfileViewController = profile_sb.instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileViewController
        return profile_vc
    }
    
    var delegate: EditProfileControllerDelegate? = nil
    
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
    
    @IBOutlet weak var full_name_field: SkyFloatingLabelTextField!
    @IBOutlet weak var email_field: SkyFloatingLabelTextField!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var pick_photo_btn: UIButton!
    @IBOutlet weak var photo_profile: UIImageView!
    
    @IBAction func onPickPhotoAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
        
    }
    
    
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
        
        
        if let del = delegate {
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
        
        full_name_field.textColor = UIColor.black
        full_name_field.lineColor = UIColor.gray
        full_name_field.selectedTitleColor = UIColor.black
        full_name_field.selectedLineColor = Colors.Appearance.primaryColor
        full_name_field.selectedLineHeight = 1.5
        full_name_field.lineHeight = 0.5
        full_name_field.titleColor = Colors.Appearance.primaryColor
        full_name_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: full_name_field.font!.pointSize)
        full_name_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: full_name_field.font!.pointSize)!
        
        
        email_field.textColor = UIColor.black
        email_field.lineColor = UIColor.gray
        email_field.selectedTitleColor = UIColor.black
        email_field.selectedLineColor = Colors.Appearance.primaryColor
        email_field.selectedLineHeight = 1.5
        email_field.lineHeight = 0.5
        email_field.titleColor = Colors.Appearance.primaryColor
        email_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: email_field.font!.pointSize)
        email_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: email_field.font!.pointSize)!
        
        
        login_field.textColor = UIColor.black
        login_field.lineColor = UIColor.gray
        login_field.selectedTitleColor = UIColor.black
        login_field.selectedLineColor = Colors.Appearance.primaryColor
        login_field.selectedLineHeight = 1.5
        login_field.lineHeight = 0.5
        login_field.titleColor = Colors.Appearance.primaryColor
        login_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)
        login_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)!
        
      
        full_name_field.placeholder = "Enter full name".localized
        email_field.placeholder = "Enter email address".localized
        login_field.placeholder = "Enter login".localized
        
        saveBtn.initDefaultFont()
        saveBtn.setTitle("Save Changes".localized.uppercased(), for: .normal)
        saveBtn.backgroundColor = Colors.Appearance.primaryColor
        saveBtn.setTitleColor(.white, for: .normal)
        
        
        full_name_field.delegate = self
        email_field.delegate = self
        login_field.delegate = self
        
        self.photo_profile.roundCorners(radius: self.photo_profile.frame.height/2)
        self.photo_profile.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        self.pick_photo_btn.setTitle("", for: .normal)
        
        self.pick_photo_btn.roundCorners(radius: self.photo_profile.frame.height/2)
        self.pick_photo_btn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let camera = UIImage.init(icon:  .linearIcons(.camera), size: CGSize(width: 36, height: 36), textColor: Colors.white).withRenderingMode(.alwaysOriginal)
        self.pick_photo_btn.setImage(camera, for: .normal)
        
        //put data inside views
        
        if let user = myUserSession {
            
            full_name_field.text = user.name
            login_field.text = user.username
            email_field.text = user.email
            
            //set image
            if let cached_image = EditProfileViewController.imageProfile{
                
                self.photo_profile.image = cached_image
                
            }else if let cached_image = SignUpViewController.imageProfile{
                
                self.photo_profile.image = cached_image
                
            }else{
                
                if let image = user.images {
                    
                    let url = URL(string: image.url100_100)
                    
                    self.photo_profile.kf.indicatorType = .activity
                    self.photo_profile.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }else{
                    if let img = UIImage(named: "profile_placeholder") {
                        self.photo_profile.image = img
                    }
                }
                
            }
            
            
        }
       
        
        
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
        
        
        guard let loginValue = login_field.text else {
            showErros(messages:["login":"Login field is empty".localized])
            return
        }
        
        guard let emailValue = email_field.text else {
            showErros(messages:["email":"Email field is empty".localized])
            return
        }
        
        guard let nameValue = full_name_field.text else {
            showErros(messages:["name":"Full Name field is empty".localized])
            return
        }
        
        var lat = 0.0
        var lng = 0.0
        var guest_id = 0
        
        if let guest = Guest.getInstance() {
            
            guest_id = guest.id
            lat = guest.lat
            lng = guest.lng
            
        }
        
        
        self.userLoader.load(url: Constances.Api.API_UPDATE_ACCOUNT,parameters: [
            "username"      : loginValue,
            "oldUsername"   : user.username,
            "user_id"       : String(user.id),
            "email"         : emailValue,
            "name"          : nameValue,
            "image"         : imageId,
            "lat"           : String(lat),
            "lng"           : String(lng),
            "guest_id"      : String(guest_id)
            ])
        
    }
    
    
    func doUpload(user: User){
        
        //upload image
        if let image = SignUpViewController.imageProfile{
            
            let parameters = [
                "image":    image.toBase64(),
                "module_id":   String(user.id),
                "type":     "user",
                "module":   "user",
            ]
            
            Utils.printDebug("\(parameters)")
                         
          
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_USER_UPLOAD64, parameters: parameters) { (parser) in
                
                Utils.printDebug("\(parser)")
                             
             
                if parser?.success == 1{
                    
                }else{
                    
                }
            }
            
        }
        
        
        if let del = delegate{
            del.editProfilSuccess(controller: self, user: user)
        }else{
            onBackHandler()
        }
        
        
    }
    
    func success(parser: UserParser,response: String) {
        
        if parser.success == 1 {
            
            
            SVProgressHUD.dismiss()
            
            let users = parser.parse()
            
            if users.count == 1 {
                
                Utils.printDebug("\(users)")
                
                Session.createSession(user: users[0])
                
                SwiftEventBus.post("on_main_refresh", sender: users[0])
                
                doUpload(user: users[0])
                
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
    
    static var imageProfile:UIImage? = nil
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            if let imageData = pickedImage.jpeg(.lowest) {
                SignUpViewController.imageProfile = UIImage(data: imageData)
                //SignUpViewController.imageProfile = EditProfileViewController.imageProfile?.fixOrientation()
                self.photo_profile.contentMode = .scaleAspectFill
                self.photo_profile.image = SignUpViewController.imageProfile
            }
        }
        
        picker.dismiss(animated: true)
        
    }
    
    
    
    
}



extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
