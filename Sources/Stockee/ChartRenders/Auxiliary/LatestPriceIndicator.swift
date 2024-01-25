//
//  LatestPriceIndicator.swift
//  Stockee
//
//  Created by octree on 2022/4/6.
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

/// 用于绘制最新成交价格
public class LatestPriceIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    
    private let priceLayer: InsetsTextLayer
    private var lineLayer: ShapeLayer = {
        let lineLayer = ShapeLayer()
        lineLayer.lineWidth = 1
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineDashPattern = [2, 2]
        return lineLayer
    }()

    private let rightSpace: CGFloat
    private let cornerRadius: CGFloat
    private let borderColor: UIColor
    private let textColor: UIColor
    private let boxBgColor: UIColor
    private let indicatorLineColor: UIColor
    
    /// - Parameters:
    ///   - rightSpace: 价格框距离右边的间距
    ///   - insets: 价格文本内间距
    ///   - cornerRadius: 价格文本框圆角
    ///   - borderColor: 价格文本框边框颜色
    ///   - textColor: 价格文本颜色
    ///   - boxBgColor: 价格文本框背景色
    ///   - indicatorLineColor: 指示线颜色
    public init(
        rightSpace: CGFloat = 10,
        insets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5),
        cornerRadius: CGFloat = 2,
        borderColor: UIColor,
        textColor: UIColor,
        boxBgColor: UIColor,
        indicatorLineColor: UIColor
    ) {
        self.rightSpace = rightSpace
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.textColor = textColor
        self.boxBgColor = boxBgColor
        self.indicatorLineColor = indicatorLineColor
        priceLayer = InsetsTextLayer(insets: insets)
        priceLayer.masksToBounds = true
        priceLayer.borderWidth = 1/UIScreen.main.scale
        priceLayer.contentsScale = UIScreen.main.scale
        priceLayer.alignmentMode = .center
    }

    public func updateZPosition(_ position: CGFloat) {
        lineLayer.zPosition = position
        priceLayer.zPosition = position
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(lineLayer)
        view.layer.addSublayer(priceLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let last = context.data.last else {
            lineLayer.isHidden = true
            priceLayer.isHidden = true
            return
        }
        lineLayer.isHidden = false
        priceLayer.isHidden = false
        
        lineLayer.strokeColor = indicatorLineColor.cgColor
        
        priceLayer.backgroundColor = boxBgColor.cgColor
        priceLayer.cornerRadius = cornerRadius
        priceLayer.borderColor = borderColor.cgColor
        
        let priceStr = context.preferredFormatter.format(last.close)
        priceLayer.font = context.configuration.captionFont
        priceLayer.textColor = textColor
        priceLayer.text = priceStr
        
        let y = context.yOffset(for: last.close)
        let priceLayerSize = priceLayer.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        
        let maxX = view.contentOffset.x + view.frame.width
        let minY = context.contentRect.minY
        let maxY = context.groupContentRect.maxY
        var boxFrame = CGRect(
            origin: CGPoint(x: maxX - priceLayerSize.width - rightSpace, y: y - priceLayerSize.height / 2),
            size: priceLayerSize
        )
        boxFrame.origin.y = min(max(boxFrame.origin.y, minY), maxY - priceLayerSize.height)
        priceLayer.frame = boxFrame
        
        print("boxFrame: \(boxFrame) ---- textFrame: \(priceLayer.textLayer.frame)")
        
        var lineStartX: CGFloat
        if context.visibleRange.contains(context.data.count - 1) {
            let barWidth = context.configuration.barWidth
            let spacing = context.configuration.spacing
            lineStartX = (barWidth + spacing) * CGFloat(context.data.count - 1) + barWidth
        } else {
            lineStartX = view.contentOffset.x
        }
        let path = CGMutablePath()
        let midY = boxFrame.midY
        path.move(to: .init(x: lineStartX, y: midY))
        path.addLine(to: .init(x: maxX, y: midY))
        lineLayer.path = path
    }

    public func tearDown(in view: ChartView<Input>) {
        lineLayer.removeFromSuperlayer()
        priceLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}
