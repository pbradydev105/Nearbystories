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
import SVProgressHUD



protocol SignUpControllerDelegate {
    func signupSuccess(controller: SignUpViewController, user: User)
    func signupFaild(controller: SignUpViewController)
}

class SignUpViewController: MyUIViewController, UserLoaderDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    var delegate: SignUpControllerDelegate? = nil
    
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
        
        SwiftEventBus.onMainThread(self, name: "open_view_signup") { result in
            
            let sb = UIStoryboard(name: "SignUp", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: SignUpViewController = sb.instantiateViewController(withIdentifier: "signupVC") as! SignUpViewController
                parent.present(ms, animated: true, completion: nil)
            }
            
        }
    }
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    
    @IBOutlet weak var main_container: UIView!
    
    
    @IBOutlet weak var signinBtn: CustomButton!
    @IBOutlet weak var uploadAndFinishBtn: CustomButton!
    
    @IBAction func uploadAction(_ sender: Any) {
        
        if Session.isLogged(), let sess = Session.getInstance(), let user = sess.user{
             doUpload(user: user)
        }

    }
    
    
    @IBOutlet weak var signin_btn_container: UIView!
    @IBOutlet weak var user_photo_container: UIView!
    @IBOutlet weak var user_information_container: UIView!
    
    @IBOutlet weak var full_name_field: SkyFloatingLabelTextField!
    @IBOutlet weak var email_field: SkyFloatingLabelTextField!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var password_field: SkyFloatingLabelTextField!
    
    @IBOutlet weak var pick_photo_btn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var photo_profile: UIImageView!
    @IBOutlet weak var signup_container_bg: UIImageView!
    
    
    @IBAction func onPickPhotoAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
      
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        
        doSignup()
        
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
        
        
        topBarTitle.text = "Create Account".localized
        
        navigationBarItem.titleView = topBarTitle
        
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
        

        if(config.backHome ==  true){
            navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        }
        
        
    }
    
    
    var imageId: String = ""
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        self.user_photo_container.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        self.main_container.backgroundColor = Colors.Appearance.primaryColor
        
       
        self.user_information_container.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.user_information_container.roundCorners(radius: 4)
        
        self.user_photo_container.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.user_photo_container.roundCorners(radius: 4)
        
        self.signup_container_bg.contentMode = .scaleToFill
        self.signup_container_bg.image = UIImage(named: AppConfig.Design.loginBackgounds.randomElement()!)
               
    
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
        
        
        
        imagePicker.delegate = self
        

        setupView()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            
            _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
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
        
        onBackHandler()
    }
    
    
    func setupView ()  {
        
        full_name_field.textColor = UIColor.black
        full_name_field.lineColor = UIColor.gray
        full_name_field.selectedTitleColor = UIColor.black
        full_name_field.selectedLineColor = Colors.Appearance.primaryColor
        full_name_field.selectedLineHeight = 1.5
        full_name_field.lineHeight = 0.5
        full_name_field.titleColor = Colors.Appearance.primaryColor
        full_name_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)
        full_name_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: password_field.font!.pointSize)!
        
        
        
        email_field.textColor = UIColor.black
        email_field.lineColor = UIColor.gray
        email_field.selectedTitleColor = UIColor.black
        email_field.selectedLineColor = Colors.Appearance.primaryColor
        email_field.selectedLineHeight = 1.5
        email_field.lineHeight = 0.5
        email_field.titleColor = Colors.Appearance.primaryColor
        email_field.font = UIFont(name: AppConfig.Design.Fonts.regular, size: login_field.font!.pointSize)
        email_field.titleFont = UIFont(name: AppConfig.Design.Fonts.regular, size: password_field.font!.pointSize)!
        
        
        
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
        
        full_name_field.placeholder = "Enter full name".localized
        email_field.placeholder = "Enter email address".localized
        login_field.placeholder = "Enter login".localized
        password_field.placeholder = "Enter password".localized
        
        
        full_name_field.delegate = self
        email_field.delegate = self
        login_field.delegate = self
        password_field.delegate = self

      
        signUpBtn.setTitle("Sign Up".localized.uppercased(), for: .normal)
        

        self.photo_profile.roundCorners(radius: self.photo_profile.frame.height/2)
        self.photo_profile.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        self.pick_photo_btn.setTitle("", for: .normal)
        
        self.pick_photo_btn.roundCorners(radius: self.photo_profile.frame.height/2)
        //self.pick_photo_btn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        
        let camera = UIImage.init(icon:  .linearIcons(.camera), size: CGSize(width: 36, height: 36), textColor: Colors.white).withRenderingMode(.alwaysOriginal)
        self.pick_photo_btn.setImage(camera, for: .normal)
               
        self.signinBtn.setTitle("Have an account?".localized.uppercased(), for: .normal)
        self.uploadAndFinishBtn.setTitle("Finish".localized.uppercased(), for: .normal)
        
        
        
        self.pick_photo_btn.roundedCorners(radius: 5)
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
    func doSignup () {
        
        
        SVProgressHUD.setForegroundColor(Colors.Appearance.primaryColor)
        SVProgressHUD.setBorderColor(Colors.Appearance.primaryColor)
        SVProgressHUD.setBackgroundColor(Colors.white)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setBackgroundLayerColor( UIColor (white: 1, alpha: CGFloat(0.5))  )
        SVProgressHUD.show()
        
        self.userLoader.delegate = self
        
        
        guard let loginValue = login_field.text else {
            showErros(messages:["login":"Login field is empty".localized])
            return
        }
        
        guard let passwordValue = password_field.text else {
            showErros(messages:["password":"Password field is empty".localized])
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
        
        let parameters = [
            "username"  : loginValue,
            "email"     : emailValue,
            "name"      : nameValue,
            "password"  : passwordValue,
            "image"     : imageId,
            "lat"       : String(lat),
            "lng"       : String(lng),
            "guest_id"  : "\(guest_id)"
        ]
        
        self.userLoader.load(url: Constances.Api.API_USER_SIGNUP,parameters: parameters)
        
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
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_USER_UPLOAD64, parameters: parameters) { (parser) in
                if parser?.success == 1{
                   
                }
            }
            
        }
        
        
        if let del = delegate{
            del.signupSuccess(controller: self, user: user)
        }else{
            onBackHandler()
        }
        
       
    }
    
    func success(parser: UserParser,response: String) {
        
        SVProgressHUD.dismiss()
        
        if parser.success == 1 {
            
            
           // MyProgress.showProgressWithSuccess(withStatus: "Success!")
            
            
            let users = parser.parse()
            
            if users.count == 1 {
                
               
                Session.createSession(user: users[0])
                
                SwiftEventBus.post("on_main_refresh", sender: users[0])
                
                self.user_photo_container.isHidden = false
                self.user_information_container.isHidden = true
                self.signin_btn_container.isHidden = true
                
                
            }else{
                showErros(messages: ["err": "User not found!".localized])
            }
            
            
            
            
        }else {
            
            
            
            if let errors = parser.errors {
                
                SVProgressHUD.dismiss()
                self.showAlertError(title: "Error",content: errors ,msgBnt: "OK")
            }
            
        }
        
    }
    
    

    
    func error(error: Error?,response: String) {
        
        SVProgressHUD.dismiss()
        
        let errors: [String: String] = [
            "err": "Technical error"
        ]
        
        
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
                           SignUpViewController.imageProfile = SignUpViewController.imageProfile?.fixOrientation()
                           self.photo_profile.contentMode = .scaleAspectFill
                           self.photo_profile.image = SignUpViewController.imageProfile
                       }
        }
        
        picker.dismiss(animated: true)
        
    }
    
    
  

}

extension UIImage{
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    public func toBase64() -> String{
        let imageData = self.jpegData(compressionQuality: 1.0)
        return (imageData?.base64EncodedString())!
    }
    
    public func scaleTo(ratio: CGFloat) -> UIImage {
        let size = self.size
        let newSize: CGSize = CGSize(width: size.width  * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func isEqualToImage(image: UIImage) -> Bool {
        let data1 = self.pngData()
        let data2 = image.pngData()
        return data1 == data2
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
