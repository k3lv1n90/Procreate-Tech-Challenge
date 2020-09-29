//
//  Utils.swift
//  Procreate Test
//
//  Created by Kelvin on 28/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit
import MetalKit

protocol ControlsDelegate {
    func reset()
    func undo()
    func redo()
    func previewButton(type: TouchType)
    func sliderChange(values: ColorModel, commit: Bool)
}

enum TouchType {
    case touchDown
    case touchInside
    case touchExit
}
