//
//  RadialGradientLayer.swift
//  touroxair
//
//  Created by Marc Plouhinec on 28/03/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//
//  Thanks to http://stackoverflow.com/a/31854064
//

import UIKit

class RadialGradientLayer: CALayer {
    
    var center:CGPoint = CGPointMake(50,50)
    var radius:CGFloat = 20
    var colors:[CGColor] = [UIColor(red: 251/255, green: 237/255, blue: 33/255, alpha: 1.0).CGColor , UIColor(red: 251/255, green: 179/255, blue: 108/255, alpha: 1.0).CGColor]
    
    override init() {
        super.init()
        
        needsDisplayOnBoundsChange = true
    }
    
    init(center:CGPoint, radius:CGFloat, colors:[CGColor]) {
        self.center = center
        self.radius = radius
        self.colors = colors
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override func drawInContext(ctx: CGContext) {
        CGContextSaveGState(ctx)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorSpace, colors, [0.0, 1.0])
        
        CGContextDrawRadialGradient(ctx, gradient, center, 0.0, center, radius, .DrawsAfterEndLocation)
    }

}
