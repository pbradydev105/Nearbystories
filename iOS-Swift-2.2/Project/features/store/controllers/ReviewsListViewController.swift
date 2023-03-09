//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus

class ReviewsListViewController: MyUIViewController, RateDialogViewControllerDelegate,
ReviewLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate, UITableViewDataSource, UITableViewDelegate{
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            ////controller.navigationBar.isHidden = false
        }
        
        ReviewsListViewController.isAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.navigationController, config.customToolbar == true{
            //controller.navigationBar.isHidden = true
        }
        
        ReviewsListViewController.isAppear = false
    }
    

    
    static var isAppear = false
    
  
    
    var store_id: Int? = nil
    //request
    var __req_page: Int = 1
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Review] = [Review]()
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "reviewCellId"
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var viewContainer: UIView!
    

    
    
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
        
        
        let rateImage = UIImage.init(icon: .googleMaterialDesign(.thumbUp), size: CGSize(width: 25, height: 25), textColor: Colors.Appearance.darkColor)
        let rateCustomBarButtonItem = UIBarButtonItem(image: rateImage, style: .plain, target: self, action: #selector(onRatehHandle))
        rateCustomBarButtonItem.setIcon(icon: .googleMaterialDesign(.thumbUp), iconSize: 25, color: _color)
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(rateCustomBarButtonItem)
        
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
    
    
    @objc func onRatehHandle() {
        let sb = UIStoryboard(name: "RateDialog", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            let rateDialog: RateDialogViewController = vc as! RateDialogViewController
            
            rateDialog.store_id = store_id
            rateDialog.delegate = self
            
            self.present(rateDialog, animated: true, completion: nil)
        }
    }
    
    func onRate(rating: Double, review: String) {
        //add review
        
        let message: [String: String] = ["alert": "Thank for your review!".localized]
        self.showAlertError(title: "Alert",content: message,msgBnt: "OK")
        self.__req_page = 1
        load()
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
        
    
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
        

        //tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "StoreReviewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        
        //get currenct date
        currentDate = DateUtils.getCurrentUTC(format: "yyyy-MM-dd HH:mm:ss")
        
        
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        setupViewloader()
        setupRefreshControl()
        
        
        load()
        
    }
    
    
    
 
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles() {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        if let store_id = self.store_id, let store = Store.findById(id: store_id){
            topBarTitle.text = store.name
        }else{
            topBarTitle.text = "Reviews".localized
        }
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
   
    
    
    @objc private func refreshData(_ sender: Any) {
        
        self.__req_page = 1
        load()
        
    }
    
    

    ////////////////////////
    //table protocoles
    //////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.LIST.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! StoreReviewCell
        let object = self.LIST[indexPath.row]
        
        cell.setup(object: object)
       
        return cell
        
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
        Utils.printDebug(" Paginate \( indexPath.row ) - \(LIST.count) - \(GLOBAL_COUNT)")
        
        if indexPath.row + 1 == LIST.count && LIST.count < GLOBAL_COUNT && !isLoading {
            Utils.printDebug(" Paginate! \(__req_page) ")
            self.load()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
   
    
    ////////////////////////
    // END table protocoles
    //////////////////
    
    
    private var isLoading = false
    //API
    
    var loader: ReviewLoader = ReviewLoader()
    
    
    func load () {
        
        self.viewManager.showAsLoading(parent: tableView)
        
        self.loader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "20"
        ]
        
        
        if let user = myUserSession{
            parameters["user_id"] = String(describing: user.id)
        }
        
        if let store_id = self.store_id{
            parameters["store_id"] = String(describing: store_id)
        }
        
        parameters["page"] = String(describing: self.__req_page)
        
        
        self.isLoading = true
        self.loader.load(url: Constances.Api.API_USER_GET_REVIEWS,parameters: parameters)
        
        
    }
    
    
    
    func success(parser: ReviewParser,response: String) {
        
        
        self.refreshControl.endRefreshing()
        
        self.viewManager.showMain()
        //self.refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.isLoading = false
        }
        
        
        if parser.success == 1 {
            
            let reviews = parser.parse()
            
            
            Utils.printDebug("===> \(reviews)")
            
            
            if reviews.count > 0 {
                
                Utils.printDebug("Loaded \(reviews.count)")
                
                if myUserSession != nil {
                    // users.validateAll(sessId: user.id)
                }
                
                
                if self.__req_page == 1  {
                    
                    self.LIST = reviews
                    self.GLOBAL_COUNT = parser.count
                    
                }else{
                    
                    self.LIST += reviews
                    self.GLOBAL_COUNT = parser.count
                    
                }
                
             
                self.tableView.reloadData()
                
                
                if self.LIST.count < self.GLOBAL_COUNT || self.GLOBAL_COUNT < 20 {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0  && self.__req_page == 1 {
                    
                    emptyAndReload()
                    //show emty layout
                    viewManager.showAsEmpty()
                    
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
        self.tableView.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        self.refreshControl.endRefreshing()
        
        
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
    
  
    
    
}





