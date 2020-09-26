//
//  ViewController.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var ColorControlClicked: Bool = false
    @IBOutlet weak var HueSlider: GradientSlider!
    @IBOutlet weak var SaturationSlider: GradientSlider!
    @IBOutlet weak var BrightnessSlider: GradientSlider!
    
    
    @IBOutlet weak var mainView: RoundedView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        //used in this case just to toggle the ui
        animateColorControlView()
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
        HueSlider.hasRainbow = true
        HueSlider.minColor = UIColor.blue
    }
    
    func animateColorControlView() {
        ColorControlClicked ? mainView.animateView(show: false) : mainView.animateView(show: true)
        ColorControlClicked ? (ColorControlClicked = false) : (ColorControlClicked = true)
    }
}
