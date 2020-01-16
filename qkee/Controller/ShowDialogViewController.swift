//
//  ShowDialogViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/20.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
//-------------------------------------------------------------------
var ShowDialogClose: Bool = false
//-------------------------------------------------------------------
class ShowDialogViewController: UIViewController {
    var nCheckCloseDialogTimer:Timer?
    var sTitleStr:String      = ""
    var sMessageStr:String    = ""
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var ViewDialog: UIView!
    @IBOutlet weak var LabelTitleStr: UILabel!
    @IBOutlet weak var LabelMsgStr: UILabel!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    //-------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowDialogClose = false
        let yourColor : UIColor = UIColor(red:170.0/255.0, green:170.0/255.0, blue:170.0/255.0, alpha: 1.0 )
        ViewDialog.layer.masksToBounds = true
        ViewDialog.layer.borderColor = yourColor.cgColor
        ViewDialog.layer.cornerRadius = 5
        ViewDialog.layer.borderWidth = 2
        ViewDialog.layer.shadowOffset = CGSize(width: 5, height: 5)
        ViewDialog.layer.shadowOpacity = 0.7
        ViewDialog.layer.shadowRadius = 5
        ViewDialog.layer.shadowColor = UIColor(red:170.0/255.0, green:170.0/255.0, blue:170.0/255.0, alpha: 1.0 ).cgColor
        ViewDialog.backgroundColor = .white
        
        //LabelTitleStr.text = sTitleStr
        LabelMsgStr.text = sMessageStr
        //CheckCloseDialogTimerInit()
        //ActivityIndicatorStart()
    }
    //-------------------------------------------------------------------
    func CheckCloseDialogTimerInit()
    {
        nCheckCloseDialogTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                                      selector:#selector(self.CheckCloseDialogTimerDown),
                                                      userInfo: nil, repeats: true)
    }
    //-------------------------------------------------------------------
    @objc func CheckCloseDialogTimerDown()
    {
        if( ShowDialogClose == true)
        {
            self.nCheckCloseDialogTimer?.invalidate()
            ActivityIndicatorStop()
            dismiss(animated: true, completion: nil)
        }
    }
    //-------------------------------------------------------------------
    @objc func ActivityIndicatorStart()
    {
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.isHidden = false
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    //-------------------------------------------------------------------
    @objc func ActivityIndicatorStop()
    {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    //-------------------------------------------------------------------
    
    @IBAction func CloseDialog(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
//----------------------------
