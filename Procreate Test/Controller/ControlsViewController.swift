//
//  ControlsViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 28/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import Foundation
import UIKit

class ControlsViewController : UIView {
    
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var controlsDelegate : ControlsDelegate?
    
    func roundTheView(radius: CGFloat) {
        backgroundView.layer.cornerRadius = 20.0
        backgroundView.clipsToBounds = true
        backgroundView.layer.masksToBounds = true
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        controlsDelegate?.reset()
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        controlsDelegate?.undo()
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        controlsDelegate?.redo()
    }
    
    @IBAction func previewButtonTouchDown(_ sender: Any) {
        controlsDelegate?.preview(type: .touchDown)
    }
    
    @IBAction func previewButtonTouchInside(_ sender: Any) {
        controlsDelegate?.preview(type: .touchInside)
    }
    
    @IBAction func previewButtonTouchExit(_ sender: Any) {
        controlsDelegate?.preview(type: .touchExit)
    }
    
    
    
    
}
