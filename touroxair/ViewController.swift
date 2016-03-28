//
//  ViewController.swift
//  touroxair
//
//  Created by Marc Plouhinec on 28/03/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a radial background
        let screenCentre = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height/2)
        let innerColour = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).CGColor
        let outterColour = UIColor.blackColor().CGColor
        let radialGradientBackground = RadialGradientLayer(center: screenCentre, radius: CGFloat(self.view.frame.size.width * 0.9), colors: [innerColour, outterColour])
        radialGradientBackground.frame = self.view!.bounds
        self.view!.layer.insertSublayer(radialGradientBackground, atIndex: 0)
        radialGradientBackground.setNeedsDisplay()
    }



}

