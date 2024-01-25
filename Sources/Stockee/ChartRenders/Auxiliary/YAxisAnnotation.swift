//
//  YAxisAnnotation.swift
//  Stockee
//
//  Created by octree on 2022/3/24.
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

/// 用于绘制图表 Group 的 Y 轴
public class YAxisAnnotation<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var formatter: NumberFormatting?
    ///  当前在屏幕上渲染的 Layers
    private var visibleLayers: [InsetsTextLayer] = []
    /// 重用队列
    private var reusableLayers: [InsetsTextLayer] = []
    
    private let edgePadding: CGFloat
    /// 创建 Y 轴标注
    /// - Parameters:
    ///   - formatter: Formatter
    ///   - edgePadding: 距离边框的间距
    public init(formatter: NumberFormatting? = nil,
                edgePadding: CGFloat = 5)
    {
        self.edgePadding = edgePadding
        self.formatter = formatter
    }

    public func updateZPosition(_ position: CGFloat) {
        visibleLayers.forEach { $0.zPosition = position }
        reusableLayers.forEach { $0.zPosition = position }
    }

    public func setup(in _: ChartView<Input>) {}

    public func render(in view: ChartView<Input>, context: Context) {
        let (low, high) = context.extremePoint
        let baseY = context.contentRect.maxY
        let unit = (high - low) / context.contentRect.height
        guard !unit.isNaN, unit != 0 else { return }
        let width = view.frame.width
        let maxX = view.contentOffset.x + width
        let height = context.groupContentRect.height
        let minY = context.groupContentRect.minY
        let count = context.layout.verticalGridCount(heigt: height)
        let interval = height / CGFloat(count)
        let ys = (0 ... count).map { minY + interval * CGFloat($0) }
        setupLayers(count: ys.count, configuration: context.configuration, in: view)
        let formatter = formatter ?? context.preferredFormatter
        zip(visibleLayers, ys).forEach { layer, y in
            layer.text = formatter.format(low + (baseY - y) * unit)
            layer.sizeToFit()
            layer.frame.origin.y = y
            layer.frame.origin.x = maxX - layer.frame.width
        }
        if let last = visibleLayers.last {
            last.frame.origin.y = min(last.frame.minY,
                                      context.groupContentRect.maxY - last.frame.height)
        }
    }

    public func tearDown(in _: ChartView<Input>) {
        visibleLayers.forEach { $0.removeFromSuperlayer() }
    }

    public func extremePoint(contextValues _: ContextValues, visibleRange _: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

// MARK: - Reuse Caption

extension YAxisAnnotation {
    private func setupLayers(count: Int, configuration: Configuration, in view: UIView) {
        if visibleLayers.count > count {
            for i in count ..< visibleLayers.count {
                let layer = visibleLayers[i]
                enqueueReusableLayer(layer)
            }
        } else {
            for _ in visibleLayers.count ..< count {
                dequeueReusableLayer(configuration: configuration, in: view)
            }
        }
    }

    /// 把 View 放入重用队列
    private func enqueueReusableLayer(_ layer: InsetsTextLayer) {
        visibleLayers.removeAll(where: { $0 == layer })
        layer.removeFromSuperlayer()
        reusableLayers.append(layer)
    }

    /// 从队列中重用或者创建一个新的
    @discardableResult
    private func dequeueReusableLayer(configuration: Configuration, in view: UIView) -> InsetsTextLayer {
        let layer: InsetsTextLayer
        if reusableLayers.count > 0 {
            layer = reusableLayers.removeLast()
        } else {
            layer = InsetsTextLayer(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: edgePadding))
        }
        layer.textColor = configuration.style.captionColor
        layer.font = configuration.captionFont
        layer.alignmentMode = .center
        visibleLayers.append(layer)
        view.layer.addSublayer(layer)
        return layer
    }
}
