//
//  ControlsViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 28/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

class ControlsViewController : UIView {

    var controlsDelegate : ControlsDelegate?
    var undoMng = UndoManager()
    var colorValues = ColorModel(hue: 0, saturation: 1, brightness: 0)
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        hueSlider.value = 0
        saturationSlider.value = 1
        brightnessSlider.value = 0
        resetButton.isEnabled = false
        previewButton.isEnabled = false
        redoButton.isEnabled = false
        undoButton.isEnabled = false
        undoMng.removeAllActions()
        controlsDelegate?.reset()
    }
    
    @IBAction func undoButtonTouchedDown(_ sender: Any) {
        if undoMng.canUndo {
            undoMng.undo()
        }
        controlsDelegate?.valueChanged(values: colorValues)
    }
    
    @IBAction func undoButtonTouchUpInside(_ sender: Any) {
        if !undoMng.canUndo {
            undoButton.isEnabled = false
        }
        if undoMng.canRedo {
            redoButton.isEnabled = true
        }
    }
    
    @IBAction func redoButtonTouchDown(_ sender: Any) {
        if undoMng.canRedo {
            undoMng.redo()
        }
        controlsDelegate?.valueChanged(values: colorValues)
    }
    
    @IBAction func redoButtonTouchUpInside(_ sender: Any) {
        if !undoMng.canRedo {
            redoButton.isEnabled = false
        }
        if undoMng.canUndo {
            undoButton.isEnabled = true
        }
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
        
        undoMng.levelsOfUndo = 250
        
        resetButton.isEnabled = false
        previewButton.isEnabled = false
        redoButton.isEnabled = false
        undoButton.isEnabled = false
        
        hueSlider.minColor = .blue
        hueSlider.hasRainbow = true
        hueSlider.minimumValue = -1
        hueSlider.maximumValue = 1
        hueSlider.value = 0
        
        saturationSlider.minimumValue = 0
        saturationSlider.maximumValue = 2
        saturationSlider.value = 1
        saturationSlider.maxColor = UIColor(hue: hueSlider.value, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        saturationSlider.minColor = .gray
        
        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0
        
        handleTouch()
    }
    
    func handleTouch() {
        hueSlider.actionBlock = {slider, newValue, finished in
            let values = ColorModel(hue: newValue, saturation: self.saturationSlider.value, brightness: self.brightnessSlider.value)
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            self.saturationSlider.maxColor = UIColor(hue: newValue < 0 ? (newValue + 1) : newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            self.controlsDelegate?.valueChanged(values: values)
            CATransaction.commit()
            if finished {
                slider.thumbSize = GradientSlider.defaultThumbSize
                self.commitValues(newValue: values)
                self.handleButtons()
            }
        }

        saturationSlider.actionBlock = {slider, newValue, finished in
            let values = ColorModel(hue: self.hueSlider.value, saturation: newValue, brightness: self.brightnessSlider.value)
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            self.controlsDelegate?.valueChanged(values: values)
            CATransaction.commit()
            if finished {
                slider.thumbSize = GradientSlider.defaultThumbSize
                self.commitValues(newValue: values)
                self.handleButtons()
            }
        }

        brightnessSlider.actionBlock = {slider, newValue, finished in
            let values = ColorModel(hue: self.hueSlider.value, saturation: self.saturationSlider.value, brightness: newValue)
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            self.controlsDelegate?.valueChanged(values: values)
            CATransaction.commit()
            if finished {
                slider.thumbSize = GradientSlider.defaultThumbSize
                self.commitValues(newValue: values)
                self.handleButtons()
            }
        }
    }
    
    func handleButtons() {
        resetButton.isEnabled = true
        previewButton.isEnabled = true
        redoButton.isEnabled = undoMng.canRedo
        undoButton.isEnabled = undoMng.canUndo
    }
    
    func commitValues(newValue: ColorModel) {
            
        let oldValues = colorValues
        
        undoMng.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.commitValues(newValue: oldValues)
            if let hue = oldValues.hue {
                self.hueSlider.value = hue
            }
            if let saturation = oldValues.saturation {
                self.saturationSlider.value = saturation
            }
            if let brightness = oldValues.brightness {
                self.brightnessSlider.value = brightness
            }
        }
        colorValues = newValue
     }
    
}
