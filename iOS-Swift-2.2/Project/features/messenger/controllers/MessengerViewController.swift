//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit

struct Messenger {
    static var nbrMessagesNotSeen = 0
}

class MessengerViewController: MyUIViewController,UITableViewDelegate, UITableViewDataSource, /*UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,*/
InboxLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate, UITextFieldDelegate,OptionsDelegate, UserLoaderDelegate{
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
        
        if let user = myUserSession, let clientId = client_id {
            
            let messengerCache = MessengerCache()
            
            messengerCache.id = clientId
            messengerCache.client_id = clientId
            messengerCache.user_id = user.id
            messengerCache.page = self.__req_page
            messengerCache.count = self.GLOBAL_COUNT
            
            messengerCache.save()
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
        
        MessengerViewController.isAppear = true
        
        if let discussionId = self.discussionId, let discussion = Discussion.getById(id: discussionId) {
            
            if discussion.nbrMessages > 0 {
                self.markMessagesAsSeen(discussionId: discussionId)
            }
            
        }else if let discussionId = self.discussionId {
            
            self.markMessagesAsSeen(discussionId: discussionId)
            
        }
        
    }
    
    
    static var isAppear = false
  
    
    
    var re_ordered_list: [[Message]] = []
    
    func re_group_section_by_date() {
        
        re_ordered_list = []
        
        var _latest_section_index = -1
        var _latest_section_date = ""
        
        for message: Message in self.LIST{
            
            let parsed_date = DateUtils.getPreparedDateDT(dateUTC: message.date,dateFormat: DateFomats.defaultFormatDateTime)
            
            if  _latest_section_date == parsed_date {
                //add it in to the latest section
            
                re_ordered_list[_latest_section_index].append(message)
                
            }else{
                
                //add it in to the new section
                
                _latest_section_date = parsed_date
                _latest_section_index = _latest_section_index+1
                
            
                var new_list: [Message] = []
                new_list.append(message)
                re_ordered_list.append(new_list)
                
            }
            
        
        }
       
    }
    
    //////
    //table protocoles
    //////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.re_ordered_list[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: senderCellId, for: indexPath) as! MyMessageTableViewCell
        let object = self.re_ordered_list[indexPath.section][indexPath.row]
        cell.chatMessage = object
        
        return cell
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.re_ordered_list.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = self.re_ordered_list[section].first {
            
            let date = DateUtils.getPreparedDateDT(dateUTC: firstMessageInSection.date,dateFormat: DateFomats.defaultFormatDateTime)
            
            let label = DateHeaderLabel()
            label.text = date
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
        }
        return nil
    }
    
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
   

    
    class DateHeaderLabel: UILabel {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = Colors.Appearance.primaryColor.withAlphaComponent(0.7)
            textColor = .white
            textAlignment = .center
            translatesAutoresizingMaskIntoConstraints = false // enables auto layout
            font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var intrinsicContentSize: CGSize {
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 12
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 20, height: height)
        }
        
    }
    
    
    //////
    //////////////////////////

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        Utils.printDebug(" Paginate Section: \(  indexPath.section ) - Row: \(  indexPath.row ) \(LIST.count) - \(GLOBAL_COUNT)")
        
        if indexPath.row == 0 && indexPath.section == 0 && LIST.count < GLOBAL_COUNT && !isLoading && __req_page > 1 {
            Utils.printDebug(" Paginate! Load \(__req_page) page ")
            self.load()
        }
    }
    
    //////////////////////////
    
    //request
    var __req_page: Int = 1
    var __req_discussion: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Message] = [Message]()
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()

    var discussionId: Int? = nil
    
    let senderCellId = "senderCellId"
    let receiverCellId = "receiverCellId"
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var view_container: UIView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBAction func onSendAction(_ sender: Any) {
        
        self.handleSend()
    }
    
    
    @IBOutlet weak var bottomContainerInput: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var discussionInstance: Discussion? = nil
    var client_id: Int? = nil
    
    func appBarTitle(title:String, subtitle:String) -> UIView {
        
        let titleLabel = UILabel(frame: CGRect(x: 0,y:  -3,width: 0,height:  0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        //titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        titleLabel.text = title
        titleLabel.textAlignment =  .center
        titleLabel.sizeToFit()
        titleLabel.font = titleLabel.font.withSize(16)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0,y:  14,width: 0,height:  0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        //subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 14)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment =  .center
        subtitleLabel.sizeToFit()
        subtitleLabel.font = titleLabel.font.withSize(12)
        
        let titleView = UIView(frame: CGRect(x: 0,y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width),height:  30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        
        return titleView
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        return view
    }()
    
    
    lazy var optionsLauncher: OptionsLauncher = {
        let launcher = OptionsLauncher()
        launcher.delegate = self
        return launcher
    }()
    
    
    @objc func handleMore() {
        
        optionsLauncher.clear()
        
        if let client = self.client_id  {
            
            if let user = User.findById(id: client) {
                
                if user.blocked {
                    
                    optionsLauncher.addBottomMenuItem(option: Option(
                        id: OptionsId.UNBLOCK,
                        name: "Unblock".localized,
                        image: optionsLauncher.createIcon(.ionicons(.androidClose)),
                        object: client
                    ))
                    
                }else{
                    
                    optionsLauncher.addBottomMenuItem(option: Option(
                        id: OptionsId.BLOCK,
                        name: "Block".localized,
                        image: optionsLauncher.createIcon(.ionicons(.androidClose)),
                        object: client
                    ))
                    
                    
                }
            }
  
            
        }
        
        optionsLauncher.load()
        optionsLauncher.showOptions()
        
    }
    
  
    func onOptionItemPressed(option: Option) {
        
        if let client = client_id {
            if option.id == OptionsId.BLOCK{
                
                self.block(user_id: client, state: true)
                
            }else if option.id == OptionsId.UNBLOCK{
                
                 self.block(user_id: client, state: false)
                
            }
        }
        
    }

   
    func setupNavBarButtons() {
        
        let _color = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)

        //arrow back icon
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        }
        
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        

        //more options icon
        let menuImage = UIImage.init(icon: .ionicons(.androidMoreVertical), size: CGSize(width: 30, height: 30), textColor: Colors.Appearance.darkColor)
        let moreBarButtonItem = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(handleMore))
        moreBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: _color)
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(moreBarButtonItem)
        
    }
    
    
  
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: viewContainer)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        if Session.isLogged() ==  false {
        
            return
        }else{
           
        }
    }
    
    var currentDate = ""
    
   private let refreshControl = UIRefreshControl()
    
    func setupRefreshControl() {
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.Appearance.darkColor
        self.bottomContainerInput.backgroundColor = Colors.Appearance.whiteGrey
        self.tableView.backgroundColor = Colors.Appearance.background
        self.inputTextField.initDefaultFont()
        self.sendButton.initBolodFont()
        
        
        sendButton.setTitle("Send".localized, for: .normal)
        inputTextField.placeholder = "Enter message ...".localized
        
        if Utils.isRTL(){
             inputTextField.textAlignment = .right
        }
        
        if Session.isLogged() == false{
            self.dismiss(animated: true)
        }
        
        
        Messenger.nbrMessagesNotSeen = 0
        SwiftEventBus.post("on_badge_refresh", sender: true)
       
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        if self.client_id == nil {
            self.dismiss(animated: true)
        }
        
    
        if let client = client_id{
            self.last_message_id =  Message.getLastMessageId(client_id: client)
        }
     
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = AppDesignUtils.defaultModeColor(dark: .white, light: Colors.Appearance.primaryColor)
    
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        //view_container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        //tableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellWithReuseIdentifier: senderCellId)
        tableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: senderCellId)
        tableView.separatorStyle = .none
        
        
        
        //get currenct date
        currentDate = DateUtils.getCurrentUTC(format: "yyyy-MM-dd HH:mm:ss")
        
        
        //load currenct discussion object from realm
        if let id = discussionId, let discussion = Discussion.getById(id: id) {
            self.discussionInstance = discussion
        }
        
        
        setupViewloader()
        
        setupNavBarTitles(name: "Messenger".localized, username: "Loading...".localized)
        //setup views
        setupNavBarButtons()
        
        
        
        if let client = self.client_id {
            
            if let user = User.findById(id: client) {
                
                setupNavBarTitles(name: user.name, username: "@"+user.username)
                
                //setup views
                setupNavBarButtons()
                setupInputComponents()
                setupRefreshControl()
                
                //load last messages
                //load()
                fetchStoredMessages()
                
                onReceiveListener()
                
            }else{
                syncUser()
            }
            
        }else{
            syncUser()
        }
     
        
       
        

        
    }
    

    
    func refreshInputField()  {
        
        if let client = client_id {
            if let user = User.findById(id: client) {
                
                if user.blocked {
                    self.sendButton.backgroundColor = Colors.gray
                    self.sendButton.isEnabled = false
                    self.inputTextField.isEnabled = false
                }else{
                    self.sendButton.backgroundColor = UIColor.clear
                    self.sendButton.isEnabled = true
                    self.inputTextField.isEnabled = true
                }
                
            }
        }
    }
    
    func fetchStoredMessages() {
        
        if let user = myUserSession, let clientId = client_id {
            
            if let messengerCache = MessengerCache.getCache(userId: user.id, clientId: clientId) {
                
                if messengerCache.id > 0{
                    self.__req_page = messengerCache.page
                    self.GLOBAL_COUNT = messengerCache.count
                    
                }
               
            }
            
            var messages = Message.findByDiscussion(userId: user.id, clientId: clientId)
            messages = messages.reversed()
            
      
            if self.GLOBAL_COUNT > 0 && self.__req_page > 1 && messages.count > 0 {
                
                      Utils.printDebug("\(messages) ")
                
                self.isLoading = true
                self.LIST = messages
                
                self.re_group_section_by_date()
                
                self.tableView.reloadData()
                
                self.scrollToButtom(animate: true)
                
               
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.isLoading = false
                }
               
                
            }else{
                self.__req_page = 1
                load()
            }
        }
        
    }
    
   
    func setupNavBarTitles(name: String, username: String) {
        
        var title  = ""
        var subtitle = ""
        
        title = name
        subtitle = username
        
        self.navigationBarItem.titleView = appBarTitle(title: title, subtitle: subtitle)
        
    }
    
    
    func onReceiveListener() {
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in
            
            if let object = result?.object{
                
                if Session.isLogged() {
                    
                    let message: Message = object as! Message
                    
                    guard let user = self.myUserSession  else {
                        self.pushNotificationIfNeeded(message: message)
                        return
                    }
                    
                    if message.receiver_id == user.id && message.senderId == self.client_id {
                        
                        if(!self.LIST.isExists(_message: message)){
                            
                            self.LIST += [message]
                            
                            self.re_group_section_by_date()
                            
                            self.tableView.reloadData()
                            self.scrollToButtom(animate: true)
                            
                            message.save()
                        }
                        
                    }else{
                        self.pushNotificationIfNeeded(message: message)
                    }
                    
                }
 
               
            }
            
        }
        
       
    }
   
    
    func pushNotificationIfNeeded(message: Message) {
        
        if Messenger.nbrMessagesNotSeen == 1 {
            
            NotificationManager.push(
                title: "New Message".localized,
                subtitle: message.message,
                identifier: InComingDataParser.tag_new_message
            )
            
        }else if Messenger.nbrMessagesNotSeen > 1 &&  Messenger.nbrMessagesNotSeen < 3 {
            
            NotificationManager.push(
                title: AppConfig.APP_NAME,
                subtitle: "You have %@ messages".localized.format(arguments: Messenger.nbrMessagesNotSeen),
                identifier: InComingDataParser.tag_new_message
            )
            
        }
        
    }
    
    func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       //self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputTextField.resignFirstResponder()
        return true
    }
    
    @objc func handleSend() {
        
        if let txt = inputTextField.text {
            
            if txt != "" {
                
                self.inputTextField.text = ""
                
               
                let messageId = Int(NSDate().timeIntervalSince1970)
                let message = createObject(text: txt,id: messageId)
                self.sendMessage(content: message)
                
                
                self.LIST += [message]
                
                self.re_group_section_by_date()
                
                self.tableView.reloadData()
                
                self.scrollToButtom(animate: true)
                //self.tableView.scrollToLast()
                
            }
            
        }
        
       // self.scrollToButtom(animate: true)
        
    }
    
    func createObject(text: String,id: Int) -> Message {
        
       
        let message = Message()
        message.date = DateUtils.getCurrent(format: DateUtils.defaultFormatUTC)
        message.message = text
        message.messageid = id
        message.senderId = (myUserSession?.id)!
        message.receiver_id = client_id!
        message.status = Message.Values.NO_SENT
        message.type = Message.Values.SENDER_VIEW
        
        return message
        
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
    
    
    
    
    
    @objc private func refreshData(_ sender: Any) {
       refreshControl.endRefreshing()
        
        if self.GLOBAL_COUNT == self.LIST.count{
            self.__req_page = 1
            load()
        }
        
        
    }
    
   
    private func setupInputComponents()  {
        
        inputTextField.placeholder = "Enter message...".localized

    
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        inputTextField.delegate = self
        
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            
            print(keyboardFrame)
        
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            self.scrollToButtom(animate: true)
            
        }
    }
    
    
    func scrollToButtom(animate: Bool) {
        
    
        
        if animate{
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
               self.tableView.scrollToLast()
               //self.tableView.layoutIfNeeded()
                
            })
        }else{
            
            self.tableView.scrollToLast()
            //self.tableView.layoutIfNeeded()
            
        }
        
        
        
    }
    
    
    private var isLoading = false
    //API
    
    var inboxLoader: InboxLoader = InboxLoader()
    
    private var last_message_id = -1
    
    func load () {
        
        self.viewManager.showAsLoading(parent: tableView)
        
        self.inboxLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30"
        ]
        
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["sender_id"] = String(user.id)
            parameters["receiver_id"] = String(client_id!)
            parameters["status"] = "0"
            parameters["date"] = currentDate
           // parameters["last_id"] = String(last_message_id)
            parameters["page"] = String(__req_page)
        }
        
        
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.inboxLoader.load(url: Constances.Api.API_LOAD_MESSAGES,parameters: parameters)
        
        
    }
    
    
    func sendMessage(content: Message) {
        
        
        self.inboxLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30"
        ]
        
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["sender_id"] = String(user.id)
            parameters["receiver_id"] = String(client_id!)
            parameters["content"] = content.message
            parameters["messageId"] = String(content.messageid)
        }
        
        
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.inboxLoader.sendMessage(url: Constances.Api.API_SEND_MESSAGE,parameters: parameters)
        
        
    }
    
    
    func success(parser: MessageParser,response: String) {
        
        Utils.printDebug("===> Load success")
        
        self.viewManager.showAsEmpty()
        self.viewManager.showMain()
        
        //self.refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
             self.isLoading = false
        }
       
        
        if parser.success == 1 {
            
            var messages = parser.parse()
            
          
            Utils.printDebug("===> \(messages)")
            
           
            if messages.count > 0 {
                
                Utils.printDebug("Loaded \(messages.count)")
                
                if let user = myUserSession {
                     messages.validateAll(sessId: user.id)
                }
               
                messages = messages.reversed()
                
                if self.__req_page == 1 && parser.messageId == nil {
                    self.LIST = messages
                    self.GLOBAL_COUNT = parser.count
                }else{
                    
                    if let messageId = parser.messageId{
                        self.LIST = self.LIST.refresh(messageId: messageId, status: Message.Values.SENT)
                    }else{
                        
                        if self.__req_page > 1 {
                             self.LIST = messages+self.LIST
                        }else{
                             self.LIST += messages
                        }
                        
                        self.GLOBAL_COUNT = parser.count
                    }
                    
                }
                
                
        
                self.re_group_section_by_date()
                
                self.tableView.reloadData()
                self.tableView.reloadData()
                messages.saveAll()
                
                if self.__req_page == 1 {
                    self.scrollToButtom(animate: true)
                }
               
                if self.LIST.count < self.GLOBAL_COUNT || self.GLOBAL_COUNT < 30 {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0  && self.__req_page == 1 {
                    
                    self.re_group_section_by_date()
                    
                    tableView.reloadData()
                }
            
            }
            
        }else {
            
            if let errors = parser.errors {
                
                if self.LIST.count == 0 {
                    Utils.printDebug("===> Request Error with Messages! ListDiscussions")
                    Utils.printDebug("\(errors)")
                    
                    viewManager.showAsError()
                }
                
                
            }
            
        }
        
        
    
        
        
    }
    
    
  
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        
        self.re_group_section_by_date()
        
        self.tableView.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        if self.LIST.count == 0 {
            
            self.isLoading = false
            self.viewManager.showAsError()
            
            Utils.printDebug("===> Request Error! ListDiscussions")
            Utils.printDebug("\(response)")
            
        }
        
    }
    
    

 
    
    func onReloadAction(action: ErrorLayout) {
        
        Utils.printDebug("onReloadAction ErrorLayout")
        
        self.viewManager.showAsLoading(parent: tableView)
        
        __req_page = 1
        
        load()
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
        
        self.viewManager.showAsLoading(parent: tableView)
        
        __req_page = 1
        
        load()
        
    }
    
    
    func markMessagesAsSeen(discussionId: Int) {
        
        var parameters = ["test":""]
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["discussionId"] = String(discussionId)
        }
        
        Utils.printDebug("markMessagesAsSeen===> \(parameters)")
        
        self.isLoading = true
        self.inboxLoader.markMessagesAsSeen(url: Constances.Api.API_INBOX_MARK_AS_SEEN, parameters: parameters, compilation: { parser in
        
        if let p = parser {
        
            if p.success == 1 {
                
            }

        }
        
        
        })
        
    }
    
    
    func block(user_id: Int, state: Bool) {
        
        if let user = myUserSession {
            
            MyProgress.showProgressWithSuccess(withStatus: "Success!".localized)
            
            let param = [
                "user_id": String(describing: user.id),
                "blocked_id":String(describing: user_id),
                "state": String(describing: state),
                ]
            
            Utils.printDebug("\(param)")
            
            let loader = SimpleLoader()
            loader.run(url: Constances.Api.API_BLOCK_USER, parameters: param) { (parser) in
                
                MyProgress.dismiss()
                
                if parser?.success == 1 {
                    
                    if let user = User.findById(id: user_id){
                        user.setBlockState(state)
                    }
                    
                    self.refreshInputField()
                    
                }
            }
            
        }
        
    }
    
    
    
    
    
    //load store
    var userLoader: UserLoader = UserLoader()
    
    func syncUser () {
        
        MyProgress.show(parent: self.view)
        self.userLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let user_id = self.client_id{
             parameters["uid"] = String(user_id)
        }
        
        Utils.printDebug("parameters: \(parameters)")
        
        self.userLoader.load(url: Constances.Api.API_GET_USERS,parameters: parameters)
        
    }
    
    func success(parser: UserParser,response: String) {
        
        self.viewManager.showMain()
        MyProgress.dismiss()
        
        Utils.printDebug("response: \(response)")
        
        if parser.success == 1 {
            
            let users = parser.parse()
            
            if users.count > 0 {
                
                users[0].save()
                
                self.client_id = users[0].id
                self.setupNavBarTitles(name: users[0].name, username: "@"+users[0].username)

            }else{
                viewManager.showAsEmpty()
            }
            
        }else {
            
            if parser.errors != nil {
                viewManager.showAsError()
            }
            
        }
        
    }

    

}




class CustomMessageinputTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15))
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15))
    }
}
