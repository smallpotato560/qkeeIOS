//
//  RoundArrowLabel.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/18.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class RoundArrowLabel: UILabel {
    //* 遮罩
    private var maskLayer: CAShapeLayer?
    //* 路径
    private var borderPath: UIBezierPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
            // 初始化遮罩
            maskLayer = CAShapeLayer()
            // 设置遮罩
            layer.mask = maskLayer
            // 初始化路径
            borderPath = UIBezierPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {

        // 遮罩层frame
        maskLayer?.frame = bounds


        // 设置path起点
        borderPath?.move(to: CGPoint(x: 0, y: 10))

        // 箭头
        borderPath?.addLine(to: CGPoint(x: bounds.size.width / 2 - 5, y: 10))
        borderPath?.addLine(to: CGPoint(x: bounds.size.width / 2 - 2.5, y: 5))
        // 圆尖角
        borderPath?.addQuadCurve(to: CGPoint(x: bounds.size.width / 2 + 2.5, y: 5), controlPoint: CGPoint(x: bounds.size.width / 2, y: 0))
        borderPath?.addLine(to: CGPoint(x: bounds.size.width / 2 + 5, y: 10))

        // 到右上角
        borderPath?.addLine(to: CGPoint(x: bounds.size.width, y: 10))
        // 到右下角
        borderPath?.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        // 到左下角
        borderPath?.addLine(to: CGPoint(x: 0, y: bounds.size.height))
        // 回到起点
        borderPath?.addLine(to: CGPoint(x: 0, y: 10))

        // 将这个path赋值给maskLayer的path
        maskLayer?.path = borderPath?.cgPath
    }
}
