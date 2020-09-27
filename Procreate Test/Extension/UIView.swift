//
//  UiView.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

extension UIView {
    func roundedCorners(corners: UIRectCorner, radius: CGFloat) {
        let edges = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = edges.cgPath
        layer.mask = mask
    }
}
