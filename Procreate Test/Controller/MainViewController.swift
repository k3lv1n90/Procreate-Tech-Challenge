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
    var context = CIContext()
    var metalCommandQueue : MTLCommandQueue!
    var initialImage: CIImage?
    var currentImage: CIImage?
    var previewColorValues: ColorModel?
    var controlsView: ControlsViewController?
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var metalView: MTKView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        colorControlClicked.toggle()
        animateView(show: colorControlClicked)
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
        guard let initial = initialImage,
              let color = previewColorValues,
              let result = previewEffect(values: color, image: initial),
              let buffer = metalCommandQueue.makeCommandBuffer(),
              let currentDrawable = view.currentDrawable else {return}
        context.render(result, to: currentDrawable.texture, commandBuffer: buffer, bounds: CGRect(origin: .zero, size: view.drawableSize), colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(currentDrawable)
        buffer.commit()
    }
    
}


extension MainViewController : ControlsDelegate {
      
    func reset() {
        configureLayout()
        metalView.setNeedsDisplay()
    }
    
    func previewButton(type: TouchType) {
        guard let preview = controlsView else {return}
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

    func valueChanged(values: ColorModel) {
        previewColorValues = values
        metalView.setNeedsDisplay()
    }

}


extension MainViewController {
    
    func configureLayout(){
        guard let image = imagePreview.image, let initial = CIImage(image: image) else {return}
        initialImage = initial
        currentImage = initial
        previewColorValues = ColorModel(hue: 0, saturation: 1, brightness: 0)
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
    
    func animateView(show: Bool) {
        if show {
            if let viewToBePresented = controlsView {
                view.addSubview(viewToBePresented)
                viewToBePresented.frame = CGRect(x: imagePreview.bounds.minX, y: imagePreview.bounds.maxY - 130, width: imagePreview.frame.width, height: 130.0)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    viewToBePresented.alpha = 1.0
                }, completion: nil)
            } else {
                let nib = UINib(nibName: "ControlsView", bundle: Bundle(for: type(of: self)))
                guard let createView = nib.instantiate(withOwner: nil, options: nil).first as? ControlsViewController else {return}
                createView.alpha = 0
                controlsView = createView
                controlsView?.controlsDelegate = self
                controlsView?.configureControls(radius: 20.0)
                animateView(show: true)
            }
        } else {
            guard let viewToBeDismissed = controlsView else {return}
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
