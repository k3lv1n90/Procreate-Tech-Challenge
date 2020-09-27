//
//  ViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var colorControlClicked: Bool = false
    var actionHistory = [ColorModel]()
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet weak var mainView: RoundedView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        animateColorControlView()
        handleTouch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    //This is only for the purpose of this test, otherwise it would be in plist or appdelegate
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //This is only for the purpose of this test, otherwise it would be in plist or appdelegate
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}


extension ViewController {
    
    func configureLayout(){
        mainView.configureView(radius: 20.0)
        hueSlider.hasRainbow = true
        hueSlider.minColor = UIColor.blue
        undoButton.isEnabled = false //as at the beginning it has no function since nothing has been changed
        redoButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    func animateColorControlView() {
        colorControlClicked ? mainView.animateView(show: false) : mainView.animateView(show: true)
        colorControlClicked ? (colorControlClicked = false) : (colorControlClicked = true)
    }
    
    func handleTouch() {
        hueSlider.actionBlock = {slider, newValue, finished in
            let brightness = self.brightnessSlider.value
            let saturation = self.saturationSlider.value
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.saturationSlider.setGradientVaryingSaturation(hue: newValue, brightness: brightness)
            self.saturationSlider.thumbColor = UIColor(hue: newValue, saturation: saturation, brightness: brightness, alpha: 1.0)
            self.brightnessSlider.setGradientVaryingBrightness(hue: newValue, saturation: saturation)
            self.brightnessSlider.thumbColor = UIColor(hue: newValue, saturation: saturation, brightness: brightness, alpha: 1.0)
            slider.thumbColor = UIColor(hue: newValue, saturation: saturation, brightness: brightness, alpha: 1.0)
            CATransaction.commit()
        }
        
        saturationSlider.actionBlock = {slider, newValue, finished in
            let brightness = self.brightnessSlider.value
            let hue = self.hueSlider.value
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.hueSlider.setGradientVaryingHue(saturation: newValue, brightness: brightness)
            self.hueSlider.thumbColor = UIColor(hue: hue, saturation: newValue, brightness: brightness, alpha: 1.0)
            self.brightnessSlider.setGradientVaryingBrightness(hue: hue, saturation: newValue)
            self.brightnessSlider.thumbColor = UIColor(hue: hue, saturation: newValue, brightness: brightness, alpha: 1.0)
            slider.thumbColor = UIColor(hue: hue, saturation: newValue, brightness: brightness, alpha: 1.0)
            CATransaction.commit()
        }
        
        brightnessSlider.actionBlock = {slider, newValue, finished in
            let saturation = self.saturationSlider.value
            let hue = self.hueSlider.value
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.saturationSlider.setGradientVaryingHue(saturation: saturation, brightness: newValue)
            self.saturationSlider.thumbColor = UIColor(hue: hue, saturation: saturation, brightness: newValue, alpha: 1.0)
            self.hueSlider.setGradientVaryingBrightness(hue: hue, saturation: saturation)
            self.hueSlider.thumbColor = UIColor(hue: hue, saturation: saturation, brightness: newValue, alpha: 1.0)
            slider.thumbColor = UIColor(hue: hue, saturation: saturation, brightness: newValue, alpha: 1.0)
            CATransaction.commit()
        }
    }
}
