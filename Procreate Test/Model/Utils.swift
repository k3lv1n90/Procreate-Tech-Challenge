//
//  Utils.swift
//  Procreate Test
//
//  Created by Kelvin on 28/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

protocol ControlsDelegate {
    func reset()
    func undo()
    func redo()
    func preview(type: TouchType)
    func hue(values: ColorModel)
    func saturation(values: ColorModel)
    func brightness(values: ColorModel)
}

enum TouchType {
    case touchDown
    case touchInside
    case touchExit
}
