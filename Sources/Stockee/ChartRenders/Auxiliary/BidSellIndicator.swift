//
//  BidSellIndicator.swift
//  BMKLine
//
//  Created by caishengbo on 2024/1/17.
//
//  Copyright (c) 2024 Octree <fouljz@gmail.com>

import UIKit

public final class BidSellIndicator<Input: Quote>: ChartRenderer {
    
    public typealias Input = Input
    
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    
    private var layer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()
    
    private let bidImage: UIImage
    private let sellImage: UIImage
    
    /// 当前正在显示的layer
    private var visibleLayers: [ShapeLayer] = []
    /// 重用队列
    private var reusableLayers: [ShapeLayer] = []
    
    public init(bidImage: UIImage, sellImage: UIImage) {
        self.bidImage = bidImage
        self.sellImage = sellImage
    }
    
    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(layer)
    }
    
    public func updateZPosition(_ position: CGFloat) {
        layer.zPosition = position
    }
    
    public func render(in view: ChartView<Input>, context: Context) {
        visibleLayers.forEach { enqueueReusableLayer($0) }
        
        let datas = context.contextValues[QuoteContextKey<Input>.self] ?? []
        
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        
        for index in context.visibleRange {
            let data = datas[index]
            if data.bid != nil {
                let indicatorLayer = dequeueReusableLayer()
                indicatorLayer.contents = bidImage.cgImage
                                
                let barX = (barWidth + spacing) * CGFloat(index)
                let indicatorLayerX = barX + (barWidth - bidImage.size.width)/2
                indicatorLayer.frame = CGRect(x: indicatorLayerX, y: yOffset(for: data.low, context: context), width: bidImage.size.width, height: bidImage.size.height)
                layer.addSublayer(indicatorLayer)
            }
            if data.sell != nil {
                let indicatorLayer = dequeueReusableLayer()
                indicatorLayer.contents = sellImage.cgImage
                
                let barX = (barWidth + spacing) * CGFloat(index)
                let indicatorLayerX = barX + (barWidth - sellImage.size.width)/2
                indicatorLayer.frame = CGRect(x: indicatorLayerX, y: yOffset(for: data.high, context: context) - sellImage.size.height, width: sellImage.size.width, height: sellImage.size.height)
                layer.addSublayer(indicatorLayer)
            }
        }
    }
    
    public func tearDown(in view: ChartView<Input>) {
        visibleLayers.forEach { enqueueReusableLayer($0) }
        layer.removeFromSuperlayer()
    }
    
    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        return nil
    }
}

private extension BidSellIndicator {
    /// 把 Layer 放入重用队列
    private func enqueueReusableLayer(_ layer: ShapeLayer) {
        visibleLayers.removeAll(where: { layer == $0 })
        layer.removeFromSuperlayer()
        reusableLayers.append(layer)
    }

    /// 从队列中重用或者创建一个新的
    private func dequeueReusableLayer() -> ShapeLayer {
        let layer: ShapeLayer
        if reusableLayers.count > 0 {
            layer = reusableLayers.removeLast()
        } else {
            layer = ShapeLayer()
            layer.contentsScale = UIScreen.main.scale
            layer.allowsEdgeAntialiasing = true
        }
        visibleLayers.append(layer)
        return layer
    }
}

private extension BidSellIndicator {
    private func yOffset(for price: CGFloat, context: Context) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        let peak = context.extremePoint.max - context.extremePoint.min
        return height - height * (price - context.extremePoint.min) / peak + minY
    }
}
