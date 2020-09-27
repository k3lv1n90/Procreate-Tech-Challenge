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
    let context = CIContext()
    var initialImage: UIImage?
    var currentImage: UIImage?
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet weak var mainView: RoundedView!
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        animateColorControlView()
        handleTouch()
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        //go back in time
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        imagePreview.image = initialImage
        hueSlider.value = 0
        saturationSlider.value = 1
        brightnessSlider.value = 0
        currentImage = nil
    }
    
    @IBAction func previewButtonTouchedDown(_ sender: Any) {
       //to hide the view
    }
    
    @IBAction func previewButtonTouchUpInside(_ sender: Any) {
        //to show the view again
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
        initialImage = imagePreview.image
        hueSlider.minColor = .blue
        hueSlider.hasRainbow = true
        hueSlider.minimumValue = -1
        hueSlider.maximumValue = 1
        hueSlider.value = 0
        saturationSlider.minimumValue = 0
        saturationSlider.maximumValue = 2
        saturationSlider.value = 1
        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0
        undoButton.isEnabled = false //as at the beginning it has no function since nothing has been changed
        redoButton.isEnabled = false
        //resetButton.isEnabled = false
    }
    
    func animateColorControlView() {
        colorControlClicked ? mainView.animateView(show: false) : mainView.animateView(show: true)
        colorControlClicked ? (colorControlClicked = false) : (colorControlClicked = true)
    }
    
    func handleTouch() {
        hueSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.saturationSlider.setGradientVaryingSaturation(hue: newValue, brightness: 1.0)
            CATransaction.commit()
            self.applyHue(value: newValue)
        }
        
        saturationSlider.actionBlock = {slider, newValue, finished in
            let brightness = self.brightnessSlider.value
            let hue = self.hueSlider.value
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            CATransaction.commit()
            print(newValue)
            self.applySaturation(value: newValue)
        }
        
        brightnessSlider.actionBlock = {slider, newValue, finished in
            let saturation = self.saturationSlider.value
            let hue = self.hueSlider.value
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            CATransaction.commit()
            self.applyBrightness(value: newValue)
        }
    }
    
    func applyHue(value: CGFloat) {
        DispatchQueue.main.async {
            let filter = CIFilter(name: "CIHueAdjust")
            var ciImage : CIImage?
            if let current = self.currentImage  {
                ciImage = CIImage(image: current)
            } else {
                ciImage = CIImage(image: self.initialImage!)
            }
            filter?.setValue(ciImage, forKey: "inputImage")
            filter?.setValue(Float(value) * Float.pi, forKey: "inputAngle")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            self.imagePreview.image = image
            self.currentImage = image
        }
    }
    
    func applySaturation(value: CGFloat) {
        DispatchQueue.main.async {
            let filter = CIFilter(name: "CIColorControls")
            var ciImage : CIImage?
            if let current = self.currentImage  {
                ciImage = CIImage(image: current)
            } else {
                ciImage = CIImage(image: self.initialImage!)
            }
            filter?.setValue(ciImage, forKey: "inputImage")
            filter?.setValue(Float(value), forKey: "inputSaturation")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            self.imagePreview.image = image
            self.currentImage = image
        }
    }
    
    func applyBrightness(value: CGFloat) {
        DispatchQueue.main.async {
            let filter = CIFilter(name: "CIColorControls")
            var ciImage : CIImage?
            if let current = self.currentImage  {
                ciImage = CIImage(image: current)
            } else {
                ciImage = CIImage(image: self.initialImage!)
            }
            filter?.setValue(ciImage, forKey: "inputImage")
            filter?.setValue(Float(value), forKey: "inputBrightness")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            self.imagePreview.image = image
            self.currentImage = image
        }
    }
}
