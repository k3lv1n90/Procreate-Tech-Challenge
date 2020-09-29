//
//  ViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit
import MetalKit

class MainViewController: UIViewController {

    var colorControlClicked: Bool = false
    var actionHistory = [ColorModel]()
    var actionNumber = 0
    var context : CIContext!
    var metalCommandQueue : MTLCommandQueue!
    var initialImage: CIImage?
    var currentImage: CIImage?
    var controlsView: ControlsViewController?
    
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
        
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    //@IBOutlet weak var mainView: RoundedView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var metalView: MTKView!
    
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        animateColorControlView()
        handleTouch()
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        //go back in time
        if actionNumber < 2 {
            hueSlider.value = 0
            saturationSlider.value = 1
            brightnessSlider.value = 0
            self.currentImage = nil
            self.metalView.setNeedsDisplay()
        } else {
            applyValues(values: actionHistory[actionNumber-2])
            self.actionNumber -= 1
        }
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        if actionHistory.count > 9 && actionNumber >= actionHistory.count {
            return
        }
        applyValues(values: actionHistory[actionNumber])
        self.actionNumber += 1
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        hueSlider.value = 0
        saturationSlider.value = 1
        brightnessSlider.value = 0
        currentImage = nil
        actionHistory.removeAll()
        actionNumber = 0
        metalView.setNeedsDisplay()
    }
    
    @IBAction func previewButtonTouchedDown(_ sender: Any) {
        //mainView.hideView(hide: true)
        self.metalView.isHidden = true
    }
    
    @IBAction func previewButtonTouchUpInside(_ sender: Any) {
        //mainView.hideView(hide: false)
        self.metalView.isHidden = false
    }
    
    @IBAction func previewButtonTouchExit(_ sender: Any) {
        //mainView.hideView(hide: false)
        self.metalView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureMetal()
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

extension MainViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        var imageToProcess = CIImage()
        if let current = self.currentImage {
             imageToProcess = current
        } else if let initial = self.initialImage {
            imageToProcess = initial
        }
        guard let result = self.applyEffects(image: imageToProcess),
              let buffer = self.metalCommandQueue.makeCommandBuffer(),
              let currentDrawable = view.currentDrawable else {return}
        self.context.render(result, to: currentDrawable.texture, commandBuffer: buffer, bounds: CGRect(origin: .zero, size: view.drawableSize), colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(currentDrawable)
        buffer.commit()
    }
    
}


extension MainViewController {
    
    func configureLayout(){
        //mainView.configureView(radius: 20.0)
        guard let image = UIImage(named: "Neon-Source") else {return}
        initialImage = CIImage(image: image)
        
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
    
    func configureMetal() {
        metalView.isOpaque = false
        guard let device = MTLCreateSystemDefaultDevice() else {return}
        metalView.device = device
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        context = CIContext(mtlDevice: device)
        metalCommandQueue = device.makeCommandQueue()
        metalView.delegate = self
        metalView.framebufferOnly = false
        metalView.setNeedsDisplay() // to make it load the initial image
    }
    
    func animateColorControlView() {
        colorControlClicked.toggle()
        animateView(show: colorControlClicked)
    }
    
    func animateView(show: Bool) {
        if show {
            let nib = UINib(nibName: "ControlsView", bundle: Bundle(for: type(of: self)))
            guard let createView = nib.instantiate(withOwner: nil, options: nil).first as? ControlsViewController else {return}
            createView.alpha = 0
            self.controlsView = createView
            self.controlsView?.roundTheView(radius: 20.0)
            if let viewToBePresented = self.controlsView {
                self.view.addSubview(viewToBePresented)
                viewToBePresented.frame = CGRect(x: self.imagePreview.bounds.minX, y: self.imagePreview.bounds.maxY - 130, width: self.imagePreview.frame.width, height: 130.0)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    viewToBePresented.alpha = 1.0
                }, completion: nil)
            }
        } else {
            guard let viewToBeDismissed = self.controlsView else {return}
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                viewToBeDismissed.alpha = 0
            }, completion: { (result) in
                viewToBeDismissed.removeFromSuperview()
            })
        }
    }
    
    func handleTouch() {
        hueSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.saturationSlider.maxColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CATransaction.commit()
            self.metalView.setNeedsDisplay()
            if finished {
                self.commitValues()
                slider.thumbSize = GradientSlider.defaultThumbSize
            }
        }
        
        saturationSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.commit()
            self.metalView.setNeedsDisplay()
            if finished {
                self.commitValues()
                slider.thumbSize = GradientSlider.defaultThumbSize
            }
        }
        
        brightnessSlider.actionBlock = {slider, newValue, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            slider.thumbSize = GradientSlider.magnifiedThumbSize
            CATransaction.commit()
            self.metalView.setNeedsDisplay()
            if finished {
                self.commitValues()
                slider.thumbSize = GradientSlider.defaultThumbSize
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
        hueSlider.value = values.hue
        saturationSlider.value = values.saturation
        brightnessSlider.value = values.brightness
        metalView.setNeedsDisplay()
    }
    
    func applyEffects(image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIHueAdjust")
        filter?.setValue(image, forKey: "inputImage")
        filter?.setValue(Float(hueSlider.value) * Float.pi, forKey: "inputAngle")
        guard let hueResult = filter?.outputImage else {return nil}
        
        let saturationBrightnessFilter = CIFilter(name: "CIColorControls")
        saturationBrightnessFilter?.setValue(hueResult, forKey: "inputImage")
        saturationBrightnessFilter?.setValue(Float(saturationSlider.value), forKey: "inputSaturation")
        saturationBrightnessFilter?.setValue(Float(brightnessSlider.value), forKey: "inputBrightness")
        if let result = saturationBrightnessFilter?.outputImage {
            return result
        }
        return nil
    }

}
