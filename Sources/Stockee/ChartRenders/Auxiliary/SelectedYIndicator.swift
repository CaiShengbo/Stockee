//
//  SelectedYIndicator.swift
//  Stockee
//
//  Created by octree on 2022/4/8.
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

/// 用于绘制当前滑动选择的 Y 轴的值
public class SelectedYIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    
    private let priceLayer: InsetsTextLayer
    
    private let edgeSpace: CGFloat
    
    /// 正在选择的 Y 轴的指示器
    /// - Parameters:
    ///   - edgeSpace: 指示器距离边缘的距离
    ///   - insets: 价格文本内间距
    ///   - cornerRadius: 价格文本框圆角
    ///   - bgColor: 价格文本框背景色
    ///   - textColor: 价格文本颜色
    public init(
        edgeSpace: CGFloat,
        insets: UIEdgeInsets,
        cornerRadius: CGFloat,
        bgColor: UIColor,
        textColor: UIColor
    ) {
        self.edgeSpace = edgeSpace
        priceLayer = InsetsTextLayer(insets: insets)
        priceLayer.masksToBounds = true
        priceLayer.contentsScale = UIScreen.main.scale
        priceLayer.alignmentMode = .center
        priceLayer.cornerRadius = cornerRadius
        priceLayer.backgroundColor = bgColor.cgColor
        priceLayer.textColor = textColor
    }

    public func updateZPosition(_ position: CGFloat) {
        priceLayer.zPosition = .greatestFiniteMagnitude
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(priceLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        let minY = context.groupContentRect.minY
        let maxY = context.groupContentRect.maxY
        guard context.extremePoint.max - context.extremePoint.min > 0,
              let position = context.indicatorPosition,
              position.y >= minY, position.y <= maxY
        else {
            priceLayer.isHidden = true
            return
        }
        let y = position.y
        priceLayer.isHidden = false
        priceLayer.font = context.configuration.captionFont
        let minX = view.contentOffset.x
        let maxX = minX + view.frame.width
        let midX = (minX + maxX) / 2
        let value = context.value(forY: y)
        let priceStr = context.preferredFormatter.format(value)
        priceLayer.text = priceStr
        
        let priceLayerSize = priceLayer.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        if position.x > midX {
            priceLayer.frame = CGRect(x: maxX - edgeSpace - priceLayerSize.width, y: y - priceLayerSize.height / 2, width: priceLayerSize.width, height: priceLayerSize.height)
        } else {
            priceLayer.frame = CGRect(x: minX + edgeSpace, y: y - priceLayerSize.height / 2, width: priceLayerSize.width, height: priceLayerSize.height)
        }
    }

    public func tearDown(in view: ChartView<Input>) {
        priceLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}
