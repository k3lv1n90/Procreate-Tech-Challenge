//
//  ViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    var colorControlClicked: Bool = false
    var actionHistory = [ColorModel]()
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    let context = CIContext()
    var initialImage: UIImage?
    var currentImage: UIImage?
    var actionNumber = 0
    
    var metalPreview: MTKView = MTKView()
    
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
        if actionNumber < 2 {
            guard let initial = self.initialImage else {return}
            self.imagePreview.image = initial
            hueSlider.value = 0
            saturationSlider.value = 1
            brightnessSlider.value = 0
        } else {
            applyValues(values: actionHistory[actionNumber-2])
            self.actionNumber -= 1
        }
        
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        if actionHistory.count > 9 || actionNumber >= actionHistory.count {
            return
        }
        applyValues(values: actionHistory[actionNumber])
        self.actionNumber += 1
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        imagePreview.image = initialImage
        hueSlider.value = 0
        saturationSlider.value = 1
        brightnessSlider.value = 0
        currentImage = nil
        actionHistory.removeAll()
        actionNumber = 0
    }
    
    @IBAction func previewButtonTouchedDown(_ sender: Any) {
        mainView.hideView(hide: true)
        self.imagePreview.image = initialImage
    }
    
    @IBAction func previewButtonTouchUpInside(_ sender: Any) {
        mainView.hideView(hide: false)
        if let current = currentImage {
            self.imagePreview.image = current
        }
    }
    
    @IBAction func previewButtonTouchExit(_ sender: Any) {
        mainView.hideView(hide: false)
        if let current = currentImage {
            self.imagePreview.image = current
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        metalPreview.delegate = self
        var metalDevice = MTLCreateSystemDefaultDevice()
        metalPreview.device = metalDevice
        metalPreview.isPaused = true
        metalPreview.enableSetNeedsDisplay = false
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

extension ViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
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
        saturationSlider.minColor = .gray
        saturationSlider.value = 1
        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0
//        undoButton.isEnabled = false //as at the beginning it has no function since nothing has been changed
//        redoButton.isEnabled = false
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
            self.saturationSlider.maxColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CATransaction.commit()
            let preview = self.previewHue(value: newValue)
            DispatchQueue.main.async {
                self.imagePreview.image = preview
            }
            if finished {
                self.currentImage = preview
                self.commitValues()
            }
            
        }
        
        saturationSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            CATransaction.commit()
            let preview = self.previewSaturation(value: newValue)
            DispatchQueue.main.async {
                self.imagePreview.image = preview
            }
            if finished {
                self.currentImage = preview
                self.commitValues()
            }
        }
        
        brightnessSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            CATransaction.commit()
            let preview = self.previewBrightness(value: newValue)
            DispatchQueue.main.async {
                self.imagePreview.image = preview
            }
            if finished {
                self.currentImage = preview
                self.commitValues()
            }
        }
    }
    
    func commitValues() {
        if actionHistory.count >= 10 { //the amount of undo available before it is replaced
            actionHistory.remove(at: 0)
        }
        actionHistory.append(ColorModel(hue: hueSlider.value, saturation: saturationSlider.value, brightness: brightnessSlider.value))
        actionNumber += 1
        print("Committed: ", hueSlider.value," ", saturationSlider.value," ", brightnessSlider.value, " and ActionNumber:", actionNumber)
    }
        
    func applyValues(values: ColorModel) {
        guard let initialImage = self.initialImage, let ciImage = CIImage(image: initialImage) else {return}
        print("Applying Values: ", values.hue," ", values.saturation," ", values.brightness, " and ActionNumber:", actionNumber)
        let hueFilter = CIFilter(name: "CIHueAdjust")
        hueFilter?.setValue(ciImage, forKey: "inputImage")
        hueFilter?.setValue(Float(values.hue) * Float.pi, forKey: "inputAngle")
        let hueResult = hueFilter?.outputImage
        
        let saturationBrightnessFilter = CIFilter(name: "CIColorControls")
        saturationBrightnessFilter?.setValue(hueResult, forKey: "inputImage")
        saturationBrightnessFilter?.setValue(Float(values.saturation), forKey: "inputSaturation")
        saturationBrightnessFilter?.setValue(Float(values.brightness), forKey: "inputBrightness")
        if let result = saturationBrightnessFilter?.outputImage {
            self.imagePreview.image = UIImage(ciImage: result)
            self.currentImage = self.imagePreview.image
        }
        
        hueSlider.value = values.hue
        saturationSlider.value = values.saturation
        brightnessSlider.value = values.brightness
        
    }
    
    func previewHue(value: CGFloat) -> UIImage { //hue will always take the hue of original image so as not to change the hue of an already changed hue
            let filter = CIFilter(name: "CIHueAdjust")
            guard let initialImage = self.initialImage, let ciImage = CIImage(image: initialImage) else {return UIImage()}
            filter?.setValue(ciImage, forKey: "inputImage")
            filter?.setValue(Float(value) * Float.pi, forKey: "inputAngle")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            return image
    }
    
    func previewSaturation(value: CGFloat) -> UIImage {
            let filter = CIFilter(name: "CIColorControls")
            guard let initial = self.initialImage, let initialCIImage = CIImage(image: initial) else {return UIImage()}
            if let current = self.currentImage, let ciImage = CIImage(image: current) {
                filter?.setValue(ciImage, forKey: "inputImage")
            } else {
                filter?.setValue(initialCIImage, forKey: "inputImage")
            }
            filter?.setValue(Float(value), forKey: "inputSaturation")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            return image
    }
    
    func previewBrightness(value: CGFloat) -> UIImage {
            let filter = CIFilter(name: "CIColorControls")
            guard let initial = self.initialImage, let initialCIImage = CIImage(image: initial) else {return UIImage()}
            if let current = self.currentImage, let ciImage = CIImage(image: current) {
                filter?.setValue(ciImage, forKey: "inputImage")
            } else {
                filter?.setValue(initialCIImage, forKey: "inputImage")
            }
            filter?.setValue(Float(value), forKey: "inputBrightness")
            let result = filter?.outputImage
            let image = UIImage(cgImage: self.context.createCGImage(result!, from: result!.extent)!)
            return image
    }
}
