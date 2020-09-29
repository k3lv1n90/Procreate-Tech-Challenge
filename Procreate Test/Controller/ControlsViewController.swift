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
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        hueSlider.value = 0
        saturationSlider.value = 1
        brightnessSlider.value = 0
        controlsDelegate?.reset()
    }
    @IBAction func undoButtonPressed(_ sender: Any) {
        controlsDelegate?.undo()
    }
    @IBAction func redoButtonPressed(_ sender: Any) {
        controlsDelegate?.redo()
    }
    @IBAction func previewButtonTouchDown(_ sender: Any) {
        controlsDelegate?.previewButton(type: .touchDown)
    }
    @IBAction func previewButtonTouchInside(_ sender: Any) {
        controlsDelegate?.previewButton(type: .touchInside)
    }
    @IBAction func previewButtonTouchExit(_ sender: Any) {
        controlsDelegate?.previewButton(type: .touchExit)
    }
    
    func configureControls(radius: CGFloat) {
        backgroundView.layer.cornerRadius = 20.0
        backgroundView.clipsToBounds = true
        backgroundView.layer.masksToBounds = true
        
        hueSlider.minColor = .blue
        hueSlider.hasRainbow = true
        hueSlider.minimumValue = -1
        hueSlider.maximumValue = 1
        hueSlider.value = 0
        saturationSlider.minimumValue = 0
        saturationSlider.maximumValue = 2
        saturationSlider.maxColor = UIColor(hue: hueSlider.value, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        saturationSlider.minColor = .gray
        saturationSlider.value = 1
        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0
        
        handleTouch()
    }
    
    func handleTouch() {
        hueSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.saturationSlider.maxColor = UIColor(hue: newValue < 0 ? (newValue + 1) : newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CATransaction.commit()
            self.controlsDelegate?.sliderChange(values: ColorModel(hue: newValue, saturation: nil, brightness: nil), commit: false)
            if finished {
                self.controlsDelegate?.sliderChange(values: ColorModel(hue: newValue, saturation: nil, brightness: nil), commit: true)
                slider.thumbSize = GradientSlider.defaultThumbSize
            }
        }

        saturationSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.commit()
            self.controlsDelegate?.sliderChange(values: ColorModel(hue: nil, saturation: newValue, brightness: nil),commit: false)
            if finished {
                self.controlsDelegate?.sliderChange(values: ColorModel(hue: nil, saturation: newValue, brightness: nil),commit: true)
                slider.thumbSize = GradientSlider.defaultThumbSize
            }
        }

        brightnessSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.commit()
            self.controlsDelegate?.sliderChange(values: ColorModel(hue: nil, saturation: nil, brightness: newValue), commit: false)
            if finished {
                self.controlsDelegate?.sliderChange(values: ColorModel(hue: nil, saturation: nil, brightness: newValue), commit: true)
                slider.thumbSize = GradientSlider.defaultThumbSize
            }
        }
    }
    
    
}
