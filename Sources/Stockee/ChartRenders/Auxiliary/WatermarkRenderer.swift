//
//  WatermarkRenderer.swift
//  BTCTuring
//
//  Created by caishengbo on 2024/1/23.
//  Copyright © 2024 Turing. All rights reserved.
//

import UIKit

public final class WatermarkRenderer<Input: Quote>: ChartRenderer {
    
    public enum WatermarkPosition {
        case leftTop(left: CGFloat, top: CGFloat)
        case leftBottom(left: CGFloat, bottom: CGFloat)
        case rightTop(right: CGFloat, top: CGFloat)
        case rightBottom(right: CGFloat, bottom: CGFloat)
    }
    
    public typealias Input = Input
    
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    
    private let watermarkPosition: WatermarkPosition
    private let image: UIImage
    private lazy var watermarkLayer: ShapeLayer = {
        let watermarkLayer = ShapeLayer()
        watermarkLayer.contentsScale = UIScreen.main.scale
        watermarkLayer.contents = image.cgImage
        watermarkLayer.frame = CGRect(origin: .zero, size: image.size)
        return watermarkLayer
    }()
    
    public init(image: UIImage, position: WatermarkPosition) {
        self.image = image
        self.watermarkPosition = position
    }
    
    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(watermarkLayer)
    }
    
    public func updateZPosition(_ position: CGFloat) {
        watermarkLayer.zPosition = position
    }
    
    public func render(in view: ChartView<Input>, context: Context) {
        let origin: CGPoint
        switch watermarkPosition {
            case .leftTop(let left, let top):
                origin = CGPoint(x: view.contentOffset.x + left, y: top)
            case .leftBottom(let left, let bottom):
                origin = CGPoint(x: view.contentOffset.x + left, y: context.groupContentRect.height - bottom - image.size.height)
            case .rightTop(let right, let top):
                origin = CGPoint(x: view.contentOffset.x + view.bounds.width - right - image.size.width, y: top)
            case .rightBottom(let right, let bottom):
                origin = CGPoint(x: view.contentOffset.x + view.bounds.width - right - image.size.width, y: context.groupContentRect.height - bottom - image.size.height)
        }
        watermarkLayer.frame = CGRect(origin: origin, size: image.size)
    }
    
    public func tearDown(in view: ChartView<Input>) {
        watermarkLayer.removeFromSuperlayer()
    }
    
    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        return nil
    }
}
