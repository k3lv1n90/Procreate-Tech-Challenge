//
//  RoundedView.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

//subclassing UIView so that if there is a need we can easily add more options to it
class RoundedView: UIView {
    
    func configureView(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.masksToBounds = false
    }
}
