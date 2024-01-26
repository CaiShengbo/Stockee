//
//  HollowCandlestickChart.swift
//
//
//  Created by caishengbo on 2024/1/26.
//

import UIKit

/// 绘制蜡烛图的图表
public final class HollowCandlestickChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    /// 最小高度
    public let minHeight: CGFloat
    public let candleLineWidth: CGFloat
    
    private var upCandleLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()
    
    private var upLineLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()

    private var downCandleLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()
    
    private var downLineLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()

    /// 创建蜡烛图图表
    /// - Parameters:
    ///   - minHeight: 最小高度，默认为 1pt
    public init(minHeight: CGFloat = 1, candleLineWidth: CGFloat = 1) {
        self.minHeight = minHeight
        self.candleLineWidth = candleLineWidth
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(upLineLayer)
        view.layer.addSublayer(upCandleLayer)
        view.layer.addSublayer(downLineLayer)
        view.layer.addSublayer(downCandleLayer)
    }

    public func updateZPosition(_ position: CGFloat) {
        upLineLayer.zPosition = position
        upCandleLayer.zPosition = position
        downLineLayer.zPosition = position
        downCandleLayer.zPosition = position
    }

    public func render(in view: ChartView<Input>, context: Context) {
        let data = context.contextValues[QuoteContextKey<Input>.self] ?? []
        upCandleLayer.fillColor = UIColor.clear.cgColor
        upCandleLayer.strokeColor = context.configuration.upColor.cgColor
        upCandleLayer.lineWidth = candleLineWidth
        
        downCandleLayer.fillColor = UIColor.clear.cgColor
        downCandleLayer.strokeColor = context.configuration.downColor.cgColor
        downCandleLayer.lineWidth = candleLineWidth
        
        upLineLayer.fillColor = context.configuration.upColor.cgColor
        downLineLayer.fillColor = context.configuration.downColor.cgColor
        
        let upCandlePath = CGMutablePath()
        let upLinePath = CGMutablePath()
        let downCandlePath = CGMutablePath()
        let downLinePath = CGMutablePath()
        for index in context.visibleRange {
            let quote = data[index]
            if quote.open > quote.close {
                writePath(into: downCandlePath, linePath: downLinePath, data: data, context: context, index: index)
            } else {
                writePath(into: upCandlePath, linePath: upLinePath, data: data, context: context, index: index)
            }
        }

        upCandleLayer.path = upCandlePath
        upLineLayer.path = upLinePath
        downCandleLayer.path = downCandlePath
        downLineLayer.path = downLinePath
    }

    public func tearDown(in view: ChartView<Input>) {
        upCandleLayer.removeFromSuperlayer()
        upLineLayer.removeFromSuperlayer()
        downCandleLayer.removeFromSuperlayer()
        downLineLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        guard let data = contextValues[QuoteContextKey<Input>.self],
              data[visibleRange].count > 0
        else {
            return nil
        }
        let min = data[visibleRange].map { $0.low }.min()!
        let max = data[visibleRange].map { $0.high }.max()!
        return (min, max)
    }
}

private extension HollowCandlestickChart {
    private func writePath(into candlePath: CGMutablePath,
                           linePath: CGMutablePath,
                           data: [Input],
                           context: RendererContext<Input>,
                           index: Int)
    {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        let shadowWidth = context.configuration.shadowLineWidth
        let quote = data[index]
        let barX = (barWidth + spacing) * CGFloat(index)

        let lineX = barX + (barWidth - shadowWidth) / 2
        let barRect = rect(for: (quote.open, quote.close),
                           x: _pixelCeil(barX + candleLineWidth / 2),
                           width: barWidth - candleLineWidth,
                           context: context)
        candlePath.addRect(barRect)

        let lineRect = rect(for: (quote.low, quote.high),
                            x: _pixelCeil(lineX),
                            width: shadowWidth,
                            context: context)
        if lineRect.minY < barRect.minY {
            let hightLineRect = CGRect(x: lineRect.minX, y: lineRect.minY, width: lineRect.size.width, height: barRect.origin.y - lineRect.origin.y)
            linePath.addRect(hightLineRect)
        }
        if lineRect.maxY > barRect.maxY {
            let lowLineRect = CGRect(x: lineRect.minX, y: barRect.maxY, width: lineRect.size.width, height: lineRect.maxY - barRect.maxY)
            linePath.addRect(lowLineRect)
        }
    }
    
    private func writeBid(into path: CGMutablePath,
                              data: [Input],
                              context: RendererContext<Input>,
                              index: Int) {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        let quote = data[index]
        let barX = (barWidth + spacing) * CGFloat(index)
        
        let y1 = yOffset(for: quote.low, context: context)
        let height: CGFloat = 8
        let width: CGFloat = 8
        let barRect = CGRect(x: barX, y: y1, width: width, height: height)
        path.addRect(barRect)
    }
    

    private func rect(for pricePair: (CGFloat, CGFloat), x: CGFloat, width: CGFloat, context: Context) -> CGRect {
        let y1 = yOffset(for: pricePair.0, context: context)
        let y2 = yOffset(for: pricePair.1, context: context)
        let y = _pixelCeil(min(y1, y2))
        let height = max(_pixelCeil(abs(y1 - y2)), minHeight)
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func yOffset(for price: CGFloat, context: Context) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        let peak = context.extremePoint.max - context.extremePoint.min
        return height - height * (price - context.extremePoint.min) / peak + minY
    }
}

