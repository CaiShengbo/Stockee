//
//  TextLayer.swift
//  BTCTuring
//
//  Created by caishengbo on 2024/1/19.
//  Copyright © 2024 Turing. All rights reserved.
//

import UIKit

public class TextLayer: CATextLayer {
    override public func action(forKey event: String) -> CAAction? {
        nil
    }
    override public class func defaultAction(forKey event: String) -> CAAction? {
        nil
    }
}
