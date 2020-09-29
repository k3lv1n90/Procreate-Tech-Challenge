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
    var commitedEffect: Bool = false
    var currentImage: CIImage?
    var colorValues: ColorModel?
    var controlsView: ControlsViewController?
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var metalView: MTKView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        animateColorControlView()
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
        guard let color = self.colorValues, let result = self.previewEffect(values: color, image: imageToProcess),
              let buffer = self.metalCommandQueue.makeCommandBuffer(),
              let currentDrawable = view.currentDrawable else {return}
        if commitedEffect {
            self.currentImage = result
            commitedEffect.toggle()
        }
        self.context.render(result, to: currentDrawable.texture, commandBuffer: buffer, bounds: CGRect(origin: .zero, size: view.drawableSize), colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(currentDrawable)
        buffer.commit()
    }
    
}


extension MainViewController : ControlsDelegate {
      
    func reset() {
        currentImage = nil
        colorValues = ColorModel(hue: 0, saturation: 1, brightness: 0)
        actionHistory.removeAll()
        actionNumber = 0
        metalView.setNeedsDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
    func previewButton(type: TouchType) {
        guard let preview = self.controlsView else {return}
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            switch type {
            case .touchDown:
                self.metalView.alpha = 0
                preview.alpha = 0
            case .touchExit, .touchInside:
                self.metalView.alpha = 1
                preview.alpha = 1
            }
        }, completion: nil)
    }

    func sliderChange(values: ColorModel, commit: Bool) {
        colorValues = values
        self.commitedEffect = commit
        metalView.setNeedsDisplay()
    }

}


extension MainViewController {
    
    func configureLayout(){
        guard let image = UIImage(named: "Neon-Source") else {return}
        initialImage = CIImage(image: image)
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
            self.controlsView?.controlsDelegate = self
            self.controlsView?.configureControls(radius: 20.0)
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
    
    func previewEffect(values: ColorModel, image: CIImage) -> CIImage? {
        var result: CIImage?
        
        if let hue = values.hue {
            let filter = CIFilter(name: "CIHueAdjust")
            filter?.setValue(image, forKey: "inputImage")
            filter?.setValue(Float(hue) * Float.pi, forKey: "inputAngle")
            result = filter?.outputImage
        }
        
        if let saturation = values.saturation {
            let saturationFilter = CIFilter(name: "CIColorControls")
            if let processed = result {
                saturationFilter?.setValue(processed, forKey: "inputImage")
            } else {
                saturationFilter?.setValue(image, forKey: "inputImage")
            }
            saturationFilter?.setValue(Float(saturation), forKey: "inputSaturation")
            result = saturationFilter?.outputImage
        }
        
        if let brightness = values.brightness {
            let brightnessFilter = CIFilter(name: "CIColorControls")
            if let processed = result {
                brightnessFilter?.setValue(processed, forKey: "inputImage")
            } else {
                brightnessFilter?.setValue(image, forKey: "inputImage")
            }
            brightnessFilter?.setValue(Float(brightness), forKey: "inputBrightness")
            result = brightnessFilter?.outputImage
        }
        
        return result
    }

}
