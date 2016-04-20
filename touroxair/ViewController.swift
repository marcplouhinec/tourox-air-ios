//
//  ViewController.swift
//  touroxair
//
//  Created by Marc Plouhinec on 28/03/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    let carouselItems: [String] = ["StepImage1", "StepImage2"]
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var volumeControl: UISlider!
    var errorDialogDelegate : ErrorDialogDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        errorDialogDelegate = ErrorDialogDelegate(viewController: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initialize the background
        updateGradientBackground()
        
        // Initialize the volume control
        volumeControl.value = 1
        
        // Start the VoIP service
        startVoip()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopVoip()
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateGradientBackground()
    }
    
    // Add or update a radial gradient background to the view
    private func updateGradientBackground() {
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
    
    // MARK: VoIP and sound management
    
    @IBAction func volumeValueChanged(sender: UISlider) {
        let voipService = ApplicationServices.getVoipService()
        voipService.setVolume(volumeControl.value)
    }
    
    // Initialize the VoipService and handle errors
    private func startVoip() {
        NSLog("Start VoIP...")
        
        onVoipConnectionStateChanged(.NOT_CONNECTED)
        
        // Get the current IP address of the WIFI connection and check it is correct
        let wifiAddress = NetworkUtils.getWiFiAddress();
        if wifiAddress == nil {
            showUnrecoverableErrorDialog(NSLocalizedString("no_wifi_connection_error_title", comment: "No WIFI connection detected!"), message: NSLocalizedString("no_wifi_connection_error_message", comment: "Please connect to the guide\'s WIFI router and restart the application."))
            return;
        }
        if !wifiAddress!.hasPrefix("192.168.85.") {
            showUnrecoverableErrorDialog(NSLocalizedString("wrong_wifi_connection_error_title", comment: "Wrong WIFI connection detected!"), message: NSLocalizedString("wrong_wifi_connection_error_message", comment: "Please connect to a WIFI network starting with the word \'tourox\' and restart the application."))
            return;
        }
        
        // Start the VOIP service
        let voipService = ApplicationServices.getVoipService()
        if voipService.getVoipConnectionState() == .NOT_CONNECTED {
            let usernameSuffixIndex = wifiAddress!.rangeOfString(".", options: .BackwardsSearch)?.endIndex
            let username = "u" + wifiAddress!.substringFromIndex(usernameSuffixIndex!)
            let hostname = "192.168.85.1"
            NSLog("Computed configuration: username = %@, hostname = %@", username, hostname)
            
            // Open the connection with the VoIP server
            do {
                try voipService.initialize({(state: VoipConnectionState) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.onVoipConnectionStateChanged(state)
                    }
                })
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC)) // Wait 1 second before opening the connection
                dispatch_after(time, dispatch_get_main_queue()) {
                    do {
                        try voipService.openConnection(username, password: "pass", hostname: hostname)
                    }
                    catch VoipServiceError.ConnectionError(let message) {
                        NSLog("VoIP service connection error: \(message)")
                        self.showUnrecoverableErrorDialog(NSLocalizedString("unable_to_open_connection_to_voip_service_error_title", comment: "Connection error"), message: NSLocalizedString("unable_to_open_connection_to_voip_service_error_message", comment: "Unable to open a connection to the VoIP service. Please restart the application to try again."))
                    }
                    catch {
                        self.showUnrecoverableErrorDialog(NSLocalizedString("unable_to_open_connection_to_voip_service_error_title", comment: "Connection error"), message: NSLocalizedString("unable_to_open_connection_to_voip_service_error_message", comment: "Unable to open a connection to the VoIP service. Please restart the application to try again."))
                    }
                }
            } catch VoipServiceError.InitializationError(let message) {
                NSLog("VoIP service initialization error: \(message)")
                showUnrecoverableErrorDialog(NSLocalizedString("unable_to_load_voip_service_error_title", comment: "Internal error"), message: NSLocalizedString("unable_to_load_voip_service_error_message", comment: "Unable to load the VoIP service! You may try to restart the application, but if it still doesn\'t work it means your device is incompatible."))
            } catch {
                showUnrecoverableErrorDialog(NSLocalizedString("unable_to_load_voip_service_error_title", comment: "Internal error"), message: NSLocalizedString("unable_to_load_voip_service_error_message", comment: "Unable to load the VoIP service! You may try to restart the application, but if it still doesn\'t work it means your device is incompatible."))
            }
        }
        
        NSLog("VoIP started.")
    }
    
    private func stopVoip() {
        NSLog("Stop VoIP...")
        
        let voipService = ApplicationServices.getVoipService()
        voipService.closeConnection()
        voipService.destroy()
        
        NSLog("VoIP stopped.")
    }
    
    // Restart the VoipService
    private func restartVoip() {
        stopVoip()
        startVoip()
    }
    
    // MARK: Error message
    
    class ErrorDialogDelegate: NSObject, UIAlertViewDelegate {
        let viewController: ViewController
        
        init(viewController: ViewController) {
            self.viewController = viewController
        }
        
        func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
            self.viewController.restartVoip()
        }
    }
    
    private func showUnrecoverableErrorDialog(title: String, message: String) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle(NSLocalizedString("restart_button", comment: "Restart"))
        alert.delegate = errorDialogDelegate
        alert.show()
    }
    
    // MARK: Steps

    private func onVoipConnectionStateChanged(state: VoipConnectionState) {
        switch state {
        case .NOT_CONNECTED:
            stepImage.image = UIImage(named: carouselItems[0])
            stepDescriptionLabel.text = NSLocalizedString("step1_description", comment: "Connecting to the router…")
        case .UNABLE_TO_CONNECT:
            stepImage.image = UIImage(named: carouselItems[0])
            stepDescriptionLabel.text = NSLocalizedString("step1_error_description", comment: "Error: unable to connect with the router VoIP!")
        case .ONGOING_CALL:
            stepImage.image = UIImage(named: carouselItems[1])
            stepDescriptionLabel.text = NSLocalizedString("step2_description", comment: "Communication ongoing")
        }
    }
}

