//
//  HomeViewController.swift
//  Simo Vegetables
//
//  Created by Apple on 10/01/21.
//  Copyright © 2021 Gunjan. All rights reserved.
//

import UIKit

class HomeViewController: ParentClass  ,UITableViewDelegate,UITableViewDataSource{
    
    fileprivate var headerview:UIView!
    fileprivate var yPosition: Int!
    fileprivate var buttonBack: CustomButton!
    fileprivate var buttonDate : CustomComboBoxView!
    fileprivate var mainView  : UIView!
    fileprivate var topView : UIView!
    fileprivate var buttonPlaceOrder: CustomButton!

    fileprivate var tblList: UITableView!
    fileprivate var tblconfirmOrderList: UITableView!

    var orderDetails : [OrderPlaceProduct]! = [OrderPlaceProduct]()
    var placeorderDetails : [OrderPlaceProduct]! = [OrderPlaceProduct]()

    var tabHeight : Int = 0
    var bottmheightAdjust : Int = 0

    var confirmOrder : ConfirmOrderViewController!
    var strOrder : String!
    var paramQuntity = NSMutableDictionary()

    var mainConfimVIew : UIView!
    fileprivate var buttonsubmitOrder: CustomButton!
    fileprivate var buttonEditOrder: CustomButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        tabHeight = Int((self.tabBarController?.tabBar.bounds.height)!)
        self.view.backgroundColor = .white
        loadHeaderView()
        apiCallingFuncation(strDate: "")
        // Do any additional setup after loading the view.
    }
//    override func viewWillAppear(_ animated: Bool) {
//    }
    
    func loadHeaderView() {

        yPosition = STATUS_BAR_HEIGHT + Int(ParentClass.sharedInstance.iPhone_X_Top_Padding)

        headerview = UIView(frame: CGRect(x: 0, y: yPosition, width: Int(UIScreen.main.bounds.width), height: NAV_HEADER_HEIGHT));
        headerview.backgroundColor = colorPrimary
        self.view.addSubview(headerview)

        let buttonTitle = CustomButton(frame: CGRect(x: 0 , y: 0, width: SCREEN_WIDTH , height: 24))
        buttonTitle.setTitle("Item Listing", for: .normal)
        buttonTitle.titleLabel?.font = UIFont(name:APP_FONT_NAME_BOLD, size: HEADER_FONT_SIZE)
        buttonTitle.contentHorizontalAlignment = .center
        headerview.addSubview(buttonTitle)

        let buttonsubTitle = UIButton(frame: CGRect(x: 0 , y: 24, width: SCREEN_WIDTH , height: 17))
        buttonsubTitle.setTitle("Set quantity & place order", for: .normal)
        buttonsubTitle.titleLabel?.font = UIFont(name:APP_FONT_NAME_BOLD, size: SUB_HEADER_LABEL_FONT_SIZE)
        buttonsubTitle.contentHorizontalAlignment = .center
        headerview.addSubview(buttonsubTitle)

        yPosition += Int(headerview.bounds.height) + Y_PADDING

        if IS_IPHONE_X_XR_XMAX_12{
            bottmheightAdjust = 65
        }else{
            bottmheightAdjust = 50
        }

        mainConfimVIew = UIView (frame: CGRect(x: 0, y: yPosition, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - yPosition - tabHeight  - ParentClass.sharedInstance.iPhone_X_Bottom_Padding))
        //        mainConfimVIew.frame = self.view.frame
        mainConfimVIew.backgroundColor = .white
        self.view.addSubview(mainConfimVIew)
        mainConfimVIew.isHidden = true

        mainView = UIView (frame: CGRect(x: 0, y: yPosition, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - yPosition - tabHeight - ParentClass.sharedInstance.iPhone_X_Bottom_Padding))
        mainView.backgroundColor = .white
        self.view.addSubview(mainView)

        buttonPlaceOrder = CustomButton(frame: CGRect(x:  SCREEN_WIDTH - 160 , y: Int(mainView.bounds.height)  - bottmheightAdjust , width: 150 , height: 40))
        buttonPlaceOrder.setTitle("Place Order", for: .normal)
        buttonPlaceOrder.titleLabel?.font = UIFont(name:APP_FONT_NAME_BOLD, size: HEADER_FONT_SIZE)
        buttonPlaceOrder.addTarget(self, action: #selector(handelOrderPlace), for: .touchUpInside)
        buttonPlaceOrder.contentHorizontalAlignment = .center
        mainView.addSubview(buttonPlaceOrder)

        buttonEditOrder = CustomButton(frame: CGRect(x:  Y_PADDING , y:  Int(mainConfimVIew.bounds.height) - bottmheightAdjust , width: SCREEN_WIDTH/2 - X_PADDING , height: 40))
        buttonEditOrder.setTitle("Edit Order", for: .normal)
        buttonEditOrder.titleLabel?.font = UIFont(name:APP_FONT_NAME_BOLD, size: HEADER_FONT_SIZE)
        buttonEditOrder.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
        buttonEditOrder.contentHorizontalAlignment = .center
        mainConfimVIew.addSubview(buttonEditOrder)

        buttonsubmitOrder = CustomButton(frame: CGRect(x: SCREEN_WIDTH/2  + Y_PADDING, y: Int(mainConfimVIew.bounds.height)  - bottmheightAdjust , width: SCREEN_WIDTH/2  - X_PADDING , height: 40))
        buttonsubmitOrder.setTitle("Confirm & Submit", for: .normal)
        buttonsubmitOrder.titleLabel?.font = UIFont(name:APP_FONT_NAME_BOLD, size: HEADER_FONT_SIZE)
        buttonsubmitOrder.addTarget(self, action: #selector(placeOrderApiCallingFuncation), for: .touchUpInside)
        buttonsubmitOrder.contentHorizontalAlignment = .center
        mainConfimVIew.addSubview(buttonsubmitOrder)


    }
    @objc func onBackPressed(){
        mainConfimVIew.isHidden = true
        mainView.isHidden = false
    }
    @objc func handelOrderPlace(){

        if placeorderDetails.count > 0{
            self.mainConfimVIew.isHidden = false
            self.mainView.isHidden = true
            if self.tblconfirmOrderList != nil{
                self.tblconfirmOrderList.reloadData()
            }else{
                self.initConfirmOrderTableview()
            }
        }else{
            self.showAlert(message: "Please make order First.", type: AlertType.error, navBar: false)

        }

    }
    //––––––––––––––––––––––––––––––––––––––––
    //MARK: - API Function
    //––––––––––––––––––––––––––––––––––––––––

    func apiCallingFuncation( strDate : String){

        WebServicesManager .productList(ordered_products: 0, search: "", onCompletion: { response in

            if response!["success"].intValue == 1 {
                let res =  response!["products"].arrayValue
                for temp in res{
                    let value = OrderPlaceProduct.init(fromJson: temp)
                    self.orderDetails.append(value)
                }
                if self.tblList != nil{
                    self.tblList.reloadData()
                }else{
                    self.initTableview()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    self.getOrderApiCallingFuncation(strDate: dateFormatter.string(from: Date()))
                }
                self.mainView.isHidden = false
            } else {
                if self.tblList != nil{
                    self.tblList.isHidden = true
                }else{
                    self.lblSubTitle.isHidden = false
                }
//                self.showAlert(message: response!["message"].stringValue, type: AlertType.error, navBar: false)
            }
        },onError:{ error in
            if error != nil {
                self.showAlert(message:  CS.Common.wrongMsg, type: AlertType.error, navBar: false)
            }
        })
    }

    @objc func placeOrderApiCallingFuncation(){

        WebServicesManager .orderPlaceList(ordered_products: strOrder, user_id: ConnflixUtilities.shared.UserID!, order_id: "", onCompletion: { response in
            if response!["success"].intValue == 1 {
                self.showAlert(message: response!["message"].stringValue, type: AlertType.error, navBar: false)
                ParentClass.sharedInstance.tab.selectedIndex = 1
            }
        },onError:{ error in
            if error != nil {
                self.showAlert(message:  CS.Common.wrongMsg, type: AlertType.error, navBar: false)
            }
        })
    }

    func getOrderApiCallingFuncation( strDate : String){

        WebServicesManager .orderList(user_id: ConnflixUtilities.shared.UserID!, order_date: strDate, onCompletion: { response in
            if response!["success"].intValue == 1 {
                orderDetails = OrderListOrder.init(fromJson: response!["orders"][0])
            } else {
                if self.tblList != nil{
                    self.tblList.isHidden = true
                }else{
                    self.lblSubTitle.isHidden = false
                }
                self.mainView.isHidden = true

                self.showAlert(message: response!["message"].stringValue, type: AlertType.error, navBar: false)
            }
        },onError:{ error in
            if error != nil {
                self.showAlert(message:  CS.Common.wrongMsg, type: AlertType.error, navBar: false)
            }
        })
    }
//    Int((self.tabBarController?.tabBar.frame.height)!)
    func initTableview()  {
        // layer list
        self.tblList = UITableView (frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: Int(mainView.bounds.height) - bottmheightAdjust - 10), style: .plain)
        self.tblList.delegate = self
        self.tblList.dataSource = self
        self.tblList.tag = 8888
        self.tblList.register(PlaceOrderTableViewCell.self, forCellReuseIdentifier: "PlaceOrderTableViewCell")
        self.tblList.separatorStyle = .singleLine
        self.tblList.separatorInset = UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.backgroundColor = .white
        self.tblList.estimatedRowHeight = UITableView.automaticDimension
        self.tblList.rowHeight = TABLEVIEW_CELL_HEIGHT
        mainView.addSubview(self.tblList)
        self.tblList.tableFooterView = UIView()
        self.tblList.endEditing(true)
    }

    func initConfirmOrderTableview()  {
        // layer list
        self.tblconfirmOrderList = UITableView (frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: Int(mainView.bounds.height) - bottmheightAdjust - 10), style: .plain)
        self.tblconfirmOrderList.delegate = self
        self.tblconfirmOrderList.dataSource = self
        self.tblconfirmOrderList.tag = 7777
        self.tblconfirmOrderList.register(ConfirmOrderTableViewCell.self, forCellReuseIdentifier: "ConfirmOrderTableViewCell")
        self.tblconfirmOrderList.separatorStyle = .singleLine
        self.tblconfirmOrderList.separatorInset = UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
        self.tblconfirmOrderList.showsVerticalScrollIndicator = false
        self.tblconfirmOrderList.backgroundColor = .white
        self.tblconfirmOrderList.estimatedRowHeight = UITableView.automaticDimension
        self.tblconfirmOrderList.rowHeight = CONFIRM_CELL_HEIGHT
        mainConfimVIew.addSubview(self.tblconfirmOrderList)
        self.tblconfirmOrderList.tableFooterView = UIView()

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblList{
            return orderDetails.count
        }else{
            return placeorderDetails.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == tblList{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceOrderTableViewCell.self)) as! PlaceOrderTableViewCell
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
//            cell.delegate = self

            cell.txtquanty.delegate = self
            cell.txtquanty.tag = indexPath.row
//            cell.txtquanty.addTarget(self, action: #selector(textFieldDidEndEditing(textField:)), for: .valueChanged)

            let dic = orderDetails[indexPath.row]
            cell.lblFieldName.text = dic.productName
            cell.txtquanty.text = dic.salePrice
            cell.txtquanty.placeholder = "Quantity (\(dic.unit ?? ""))"
            cell.lblunitNote.text = dic.unitNote.htmlToString
            cell.imgItem.sd_setImage(with: URL (string: dic.image!), placeholderImage: nil, options: .progressiveLoad)

            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ConfirmOrderTableViewCell.self)) as! ConfirmOrderTableViewCell
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear

            let dic = placeorderDetails[indexPath.row]
            cell.btnqunty.setTitle("Qty : \(dic.myOrder ?? "0")", for: .normal)
            cell.lblFieldName.text = dic.productName

            cell.imgItem.sd_setImage(with: URL (string: dic.image!), placeholderImage: nil, options: .progressiveLoad)

            return cell
        }
    }
}


extension HomeViewController : UITextFieldDelegate{

     func textFieldDidEndEditing(_ textField: UITextField) {

        let keyExiest = paramQuntity[textField.tag] != nil
        let dic = orderDetails[textField.tag]

        if !textField.text!.isEmpty{
            if keyExiest{
                paramQuntity[textField.tag] = textField.text
            }else{
                dic.myOrder = textField.text
                placeorderDetails.append(dic)
                paramQuntity.setValue(textField.text!, forKey: dic.productId)
            }

            strOrder = Utils.stringFromJson(obj: paramQuntity as! [String : Any])

                        print(strOrder as Any)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
