//
//  ScanViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/20.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import UserNotifications
import FirebaseMessaging

let kMargin = 35
let kBorderW = 140
let scanViewW = UIScreen.main.bounds.width - CGFloat(kMargin * 2)
let scanViewH = UIScreen.main.bounds.width - CGFloat(kMargin * 2)

@available(iOS 10.2, *)
class ScanViewController: BasePageVC, AVCaptureMetadataOutputObjectsDelegate {
    
    var scanView: UIView? = nil
    var scanImageView: UIImageView? = nil
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet var qrCodeFrameView: UIView!
    
    var userid = 0
    var mobileNo: String!
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.qrCodeFrameView.isHidden = true
        
       (mobileNo, userid) = getUserInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OpenActivity(notification:)), name: NSNotification.Name("OPEN") , object: nil)
        
        qrCodeFrameView.clipsToBounds = true
        setupMaskView()
        setupScanView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CheckUserID(userid: userid)
    }
    
    //MARK: 整體遮罩設置
    fileprivate func setupMaskView() {
        let maskView = UIView(frame: CGRect(x: -(qrCodeFrameView.bounds.height - view.bounds.width) / 2, y: 0, width: qrCodeFrameView.bounds.height, height: qrCodeFrameView.bounds.height))
        maskView.layer.borderWidth = (qrCodeFrameView.bounds.height - scanViewW) / 2
        //maskView.layer.borderColor = UIColor.red.cgColor
        qrCodeFrameView.addSubview(maskView)
    }
    
    //MARK: 掃描區域設置
    fileprivate func setupScanView() {
        scanView = UIView(frame: CGRect(x: CGFloat(kMargin), y: CGFloat((qrCodeFrameView.bounds.height - scanViewW) / 2), width: scanViewW, height: scanViewH))
        scanView?.backgroundColor = UIColor.clear
        scanView?.clipsToBounds = true
        qrCodeFrameView.addSubview(scanView!)
        
        scanImageView = UIImageView(image: UIImage.init(named: "sweep_bg_line"));
     
        let bgImg = UIImageView(frame: CGRect(x: 0, y: 0, width: scanViewW, height: scanViewH))
       
        bgImg.image = UIImage(named: "QRCode_ScanBox")
        scanView?.addSubview(bgImg)
    }
    
    //MARK: 接收通知後打開頁面
    @objc func OpenActivity(notification: NSNotification) {
        print(notification.userInfo!)
        let userInfo = notification.userInfo!
        var urlStr: String!
        if ((userInfo["url"]) != nil) {
            urlStr = userInfo["url"]! as? String
        }
        else {
            if ((userInfo["aid"]) != nil) {
                let aid = userInfo["aid"]!
                urlStr = HttpServer.ActivityURL + "?aid=\(aid)"
            }
        }
        if let controller = storyboard?.instantiateViewController(withIdentifier: "WebView")
            as? WebViewController {
            controller.urlStr = urlStr
            present(controller, animated: true, completion: nil)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString: \(deviceTokenString)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetAnimatinon()

        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
            self.qrCodeFrameView.isHidden = true
        }
    }
    
    // MARK:  掃描QRCode
    @IBAction func ScanQRCode(sender: UIButton){
        //print("ScanStart")
        
        // 取得後置鏡頭來擷取影片
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // 使用前一個裝置物件來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // 在擷取 session 設定輸入裝置
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            captureSession.addInput(input)
            
            // 初始化一個 AVCaptureMetadataOutput 物件並將其設定做為擷取 session 的輸出裝置
            let captureMetadataOutput = AVCaptureMetadataOutput()
            if let outputs = captureSession.outputs as? [AVCaptureMetadataOutput] {
                for output in outputs {
                    captureSession.removeOutput(output)
                }
            }
            captureSession.addOutput(captureMetadataOutput)
            
            // 設定委派並使用預設的調度佇列來執行回呼（call back）
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = qrCodeFrameView.layer.bounds
            
            qrCodeFrameView.layer.insertSublayer(videoPreviewLayer!, at: 0)
            //qrCodeFrameView.layer.addSublayer(videoPreviewLayer!)
            
            // 開始影片的擷取
            captureSession.startRunning()
            
            // 初始化 QR Code 框來突顯 QR code
            qrCodeFrameView.isHidden = false
            
        } catch {
            // 假如有錯誤產生、單純輸出其狀況不再繼續執行
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func unSegueBack(segue: UIStoryboardSegue)
    {
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //print("ReadQR")
        
        // 檢查  metadataObjects 陣列為非空值，它至少需包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // 取得元資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            captureSession.stopRunning()
            qrCodeFrameView.isHidden = true
            
            if metadataObj.stringValue != nil {
                let result: String = metadataObj.stringValue!
                
                print("掃描結果：\(result)")
                
                var message = "您掃描的QRCode結果：\n"
                
                let qkeeString = "QKEE"
                let infexofQKEE = metadataObj.stringValue?.positionOf(sub: qkeeString)
                if infexofQKEE! >= 0 {
                    //print("QKEE")
                    var urlStr = metadataObj.stringValue!
                    let puchtimeString = "PunchTime"
                    let infexofQKEE = metadataObj.stringValue?.positionOf(sub: puchtimeString)
                    if infexofQKEE! >= 0 {
                        urlStr += "&uid=" + String(userid)
                    }
                    else {
                        //urlStr = String.backurl(urlStr)
                        urlStr += "&mobileNo=" + mobileNo
                    }
                    if let controller = storyboard?.instantiateViewController(withIdentifier: "WebView")
                    as? WebViewController {
                        controller.urlStr = urlStr
                        present(controller, animated: true, completion: nil)
                    }
                }
                else {
                    let httpString = "http"
                    let infexofHTTP = metadataObj.stringValue?.positionOf(sub: httpString)
                    if infexofHTTP == 0 {
                        message += metadataObj.stringValue!

                        url = URL(string: metadataObj.stringValue!)

                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowTitleTwoAlertID") as! ShowTitleTwoAlertView
                        showAlert.providesPresentationContextTransitionStyle = true
                        showAlert.definesPresentationContext = true
                        showAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        showAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        showAlert.delegate = self
                        showAlert.titleStr = "掃描結果"
                        showAlert.messageStr = message
                        showAlert.LeftButtonStr = "取消"
                        showAlert.RightButtonStr = "打開網頁"
                        
                        self.present(showAlert, animated: true, completion: nil)
                        //print("http")
                        //print("message: \(message)")
                    }
                    else {
                        message += metadataObj.stringValue!
                        
                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowTitleOnlyAlertID") as! ShowTitleOnlyAlertView
                        showAlert.providesPresentationContextTransitionStyle = true
                        showAlert.definesPresentationContext = true
                        showAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        showAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        showAlert.delegate = self
                        showAlert.titleStr = "掃描結果"
                        showAlert.messageStr = message
                        showAlert.ButtonStr = "OK"
                        self.present(showAlert, animated: true, completion: nil)
                        //print("nothttp")
                    }
                }
                
            }
        }
    }
    
    //MARK: 重置動畫
    @objc fileprivate func resetAnimatinon() {
        let anim = scanImageView?.layer.animation(forKey: "translationAnimation")
        if (anim != nil) {
            //將動畫的時間偏移量作為暫停時的時間點
            let pauseTime = scanImageView?.layer.timeOffset
            //根據媒體時間計算出準確的啓動時間,對之前暫停動畫的時間進行修正
            let beginTime = CACurrentMediaTime() - pauseTime!
            ///便宜時間清零
            scanImageView?.layer.timeOffset = 0.0
            //設置動畫開始時間
            scanImageView?.layer.beginTime = beginTime
            scanImageView?.layer.speed = 1.1
        } else {
            let scanImageViewH = 241
            let scanViewH = view.bounds.width - CGFloat(kMargin) * 2
            let scanImageViewW = scanView?.bounds.width
            
            scanImageView?.frame = CGRect(x: 0, y: -scanImageViewH, width: Int(scanImageViewW!), height: scanImageViewH)
            let scanAnim = CABasicAnimation()
            scanAnim.keyPath = "transform.translation.y"
            scanAnim.byValue = [scanViewH]
            scanAnim.duration = 1.8
            scanAnim.repeatCount = MAXFLOAT
            scanImageView?.layer.add(scanAnim, forKey: "translationAnimation")
            scanView?.addSubview(scanImageView!)
        }
    }
}

//MARK: 監聽彈出視窗按鈕
@available(iOS 10.2, *)
extension ScanViewController: ShowAlertViewDelegate {
    func ButtonTapped() {
        
    }
    
    func LeftButtonTapped() {
        print("cancelButtonTapped")
    }
    
    func RightButtonTapped() {
        //print("oklButtonTapped")
        
        UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey(rawValue: ""):""], completionHandler: nil)
    }
}
