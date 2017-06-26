//
//  UIColor+hexColor.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexColor: String) {
        var cString:String = hexColor.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    var hexValue: String {
        get {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let ri = ((Int)(r*255)<<16)
            let gi = ((Int)(g*255)<<8)
            let bi = ((Int)(b*255)<<0)
            let rgb: Int = ri | gi | bi
            
            return String(format:"#%06x", rgb)
        }
    }
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r: CGFloat=0
        var g: CGFloat=0
        var b: CGFloat=0
        var a: CGFloat=0
        
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)) {
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}

extension UIViewController {
    
    @objc func closeKeyboardOnTouch() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func closeKeyboard() {
        self.view.endEditing(true)
    }
}

precedencegroup AssignIfNotNillPrecedence {
    associativity: right
    assignment: true
}

infix operator ?=: AssignIfNotNillPrecedence

func ?=<T>( left: inout T?, right: T?) {
    if let value  = right {
        left = value
    } else {
        left = nil
    }
}
