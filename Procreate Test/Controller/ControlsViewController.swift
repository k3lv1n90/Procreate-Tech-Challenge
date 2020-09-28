//
//  ControlsViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 28/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import Foundation
import UIKit

class ControlsViewController : RoundedView {
    
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    
    
    var controlsDelegate : ControlsDelegate?
    

    @IBAction func resetButtonPressed(_ sender: Any) {
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
    }
    
    @IBAction func previewButtonTouchDown(_ sender: Any) {
    }
    
    @IBAction func previewButtonTouchInside(_ sender: Any) {
    }
    
    @IBAction func previewButtonTouchExit(_ sender: Any) {
    }
    
    
}
