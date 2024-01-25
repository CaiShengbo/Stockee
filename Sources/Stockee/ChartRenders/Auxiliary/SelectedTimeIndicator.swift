//
//  SelectedTimeIndicator.swift
//  Stockee
//
//  Created by octree on 2022/3/31.
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

/// 用于显示选择的 Quote 的日期
public class SelectedTimeIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    /// 背景颜色
    public var backgroundColor: UIColor {
        didSet {
            textLayer.backgroundColor = backgroundColor.cgColor
        }
    }

    /// 文字颜色
    public var textColor: UIColor {
        didSet {
            textLayer.textColor = textColor
        }
    }

    /// 日期格式，默认为：yyyy-MM-dd HH:mm
    private var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    private let textLayer: InsetsTextLayer
    
    public init(
        backgroundColor: UIColor = .black,
        textColor: UIColor = .white,
        textBoxInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3),
        dateFormat: String
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.formatter.dateFormat = dateFormat
        textLayer = InsetsTextLayer(insets: textBoxInsets)
        textLayer.alignmentMode = .center
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.textColor = textColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.allowsEdgeAntialiasing = true
        textLayer.cornerRadius = 2
    }

    public func updateZPosition(_ position: CGFloat) {
        textLayer.zPosition = .greatestFiniteMagnitude
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(textLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        defer { textLayer.isHidden = context.selectedIndex == nil }
        guard let selectedIndex = context.selectedIndex else {
            return
        }
        textLayer.font = context.configuration.captionFont
        let midX = context.layout.quoteMidX(at: selectedIndex)
        let date = context.data[selectedIndex].date
        textLayer.text = formatter.string(from: date)
        textLayer.sizeToFit()
        var layerFrame = textLayer.frame
        let minX = view.contentOffset.x
        let maxX = minX + view.frame.width - layerFrame.width
        let x = min(maxX, max(minX, midX - layerFrame.width / 2))
        let y = (context.contentRect.maxY - context.contentRect.minY - layerFrame.height) / 2 + context.contentRect.minY
        layerFrame.origin = .init(x: x, y: y)
        textLayer.frame = layerFrame
    }

    public func tearDown(in view: ChartView<Input>) {
        textLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}
