//
//  TimeIndicator.swift
//  Stockee
//
//  Created by octree on 2022/3/22.
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

/// 用来展示 X 轴日期
public class TimeAnnotation<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var formatter: DateFormatter
    private var visibleLayers: [InsetsTextLayer] = []
    private var reusableLayers: [InsetsTextLayer] = []
    private var zPosition: CGFloat = 0 {
        didSet {
            visibleLayers.forEach { $0.zPosition = zPosition }
        }
    }

    /// 创建 X 轴日期的图表
    /// - Parameter dateFormat: 日期格式
    public init(dateFormat: String) {
        formatter = DateFormatter()
        formatter.dateFormat = dateFormat
    }

    public func updateZPosition(_ position: CGFloat) {
        zPosition = position
    }

    public func setup(in view: ChartView<Input>) {}

    public func render(in view: ChartView<Input>, context: Context) {
        let width = view.frame.width
        var x = view.contentOffset.x
        let count = context.layout.horizontalGridCount(width: width)
        let interval = width / CGFloat(count)
        let xs = (0 ... count).map { x + interval * CGFloat($0) }
        let indices = xs.compactMap { x -> Int? in
            if x < 0, context.data.count > 0 { return 0 }
            return context.layout.quoteIndex(at: .init(x: x, y: 0))
        }
        setupLayers(count: indices.count, configuration: context.configuration, in: view)
        let midY = context.contentRect.midY
        zip(visibleLayers, indices).forEach { (layer, index) in
            layer.text = formatter.string(from: context.data[index].date)
            layer.sizeToFit()
            layer.frame = CGRect(x: x - layer.bounds.width/2, y: midY - layer.bounds.height/2, width: layer.bounds.width, height: layer.bounds.height)
            x += interval
        }
    }

    public func tearDown(in view: ChartView<Input>) {
        visibleLayers.forEach { $0.removeFromSuperlayer() }
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

// MARK: - Reuse Caption

extension TimeAnnotation {
    private func setupLayers(count: Int, configuration: Configuration, in view: UIView) {
        if visibleLayers.count > count {
            for i in count..<visibleLayers.count {
                let layer = visibleLayers[i]
                enqueueReusableLayer(layer)
            }
        } else {
            for _ in visibleLayers.count..<count {
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
            layer = InsetsTextLayer(insets: .zero)
        }
        layer.textColor = configuration.style.captionColor
        layer.font = configuration.captionFont
        layer.alignmentMode = .center
        layer.zPosition = zPosition
        visibleLayers.append(layer)
        view.layer.addSublayer(layer)
        return layer
    }
}
