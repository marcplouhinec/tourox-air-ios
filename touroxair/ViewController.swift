//
//  ViewController.swift
//  touroxair
//
//  Created by Marc Plouhinec on 28/03/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import UIKit

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    // MARK: Properties
    let carouselItems: [String] = ["StepCarouselImage1", "StepCarouselImage2", "StepCarouselImage3"]
    @IBOutlet weak var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateGradientBackground()
        
        carousel.type = .Rotary
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateGradientBackground()
    }
    
    // Add or update a radial gradient background to the view
    func updateGradientBackground() {
        let screenCentre = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height/2)
        let innerColour = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0).CGColor
        let outterColour = UIColor.blackColor().CGColor
        let radialGradientBackground = RadialGradientLayer(center: screenCentre, radius: CGFloat(self.view.frame.size.width * 0.9), colors: [innerColour, outterColour])
        radialGradientBackground.frame = self.view!.bounds
        if let sublayers = self.view!.layer.sublayers where !sublayers.isEmpty && sublayers[0] is RadialGradientLayer {
            self.view!.layer.replaceSublayer(sublayers[0], with: radialGradientBackground)
        }
        else {
            self.view!.layer.insertSublayer(radialGradientBackground, atIndex: 0)
        }

        radialGradientBackground.setNeedsDisplay()
    }
    
    // MARK: iCarousel
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return carouselItems.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil) {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:160, height:160))
            itemView.image = UIImage(named: carouselItems[index])
            itemView.contentMode = .ScaleToFill
        }
        else
        {
            itemView = view as! UIImageView;
        }
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .Spacing) {
            return value * 4
        }
        return value
    }

}

