//
//  LYBSingleselectview.swift
//  單選框
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/6/23.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class LYBSingleselectview: UIView {
    
    var selectindex:Int=0//选中的
    var lastbtn:UIButton=UIButton.init()//保存上一个按钮
    
    //标题数组
    var titleArr:[String]=[""]{
        didSet{
            for i in  0..<titleArr.count{
                //组装按钮和label
                let   singleselectview:UIView=UIView.init(frame: CGRect.init(x: i*100, y: 100, width: 100, height: 50))
                
                let rightLbel:UILabel=UILabel.init(frame: CGRect.init(x: 50, y: 0, width: 50, height: 50))
                rightLbel.text=titleArr[i]
                singleselectview.addSubview(rightLbel)
                
                let leftBtn:UIButton=UIButton.init(frame: CGRect.init(x: 10, y: 10, width: 30, height: 30))
                leftBtn.tag=130+i
                leftBtn.setImage(UIImage.init(named: "fuxuankuangUnselect"), for: UIControl.State.normal)
                leftBtn.addTarget(self, action: #selector(leftBtnClcik), for: UIControl.Event.touchUpInside)
                singleselectview.addSubview(leftBtn)
                
                addSubview(singleselectview)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews(){
        let sureBtn:UIButton=UIButton.init(frame: CGRect.init(x: 200, y: 10, width: 100, height: 50))
        sureBtn.setTitle("确认", for: UIControl.State.normal)
        sureBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClcik), for: UIControl.Event.touchUpInside)
        addSubview(sureBtn)
    }
    
    //确认按钮,根据选中的按钮索引做相应的操作
    @objc func sureBtnClcik(){
        print("\(selectindex)")
    }
    
    //点击按钮选中或取消
    @objc func leftBtnClcik(sender:UIButton){
        let btnTag:Int=sender.tag-130
        sender.isSelected=true
        lastbtn.isSelected=false
        lastbtn.setImage(UIImage.init(named: "fuxuankuangUnselect"), for: UIControl.State.selected)
        sender.setImage(UIImage.init(named: "fuxuankuangselect"), for: UIControl.State.selected)
        lastbtn=sender
        selectindex = btnTag
    }
    
    
}
