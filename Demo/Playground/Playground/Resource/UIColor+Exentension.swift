//
//  UIColor+Exentension.swift
//  Playground
//
//  Created by Octree on 2022/9/7.
//
//  Copyright (c) 2022 Octree <fouljz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

extension UIColor {
    enum Stockee {
        static var background: UIColor { UIColor(named: #function)! }
        static var red: UIColor { UIColor(named: #function)! }
        static var green: UIColor { UIColor(named: #function)! }
        static var border: UIColor { UIColor(named: #function)! }
        static var indicator1: UIColor { UIColor(named: #function)! }
        static var indicator2: UIColor { UIColor(named: #function)! }
        static var indicator3: UIColor { UIColor(named: #function)! }
    }
}

extension UIColor {
    class func hex(_ hex: UInt) -> UIColor {
        if hex > 0xFFFFFF {
            return UIColor(red: CGFloat((hex & 0xFF000000) >> 16) / 255.0,
                           green: CGFloat((hex & 0x00FF0000) >> 8) / 255.0,
                           blue: CGFloat(hex & 0x0000FF00) / 255.0,
                           alpha: CGFloat(hex & 0x000000FF) / 255.0)
        } else {
            return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                           green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                           blue: CGFloat(hex & 0x0000FF) / 255.0,
                           alpha: 1)
        }
    }
}
