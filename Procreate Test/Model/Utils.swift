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
    func previewButton(type: TouchType)
    func valueChanged(values: ColorModel)
}

enum TouchType {
    case touchDown
    case touchInside
    case touchExit
}
