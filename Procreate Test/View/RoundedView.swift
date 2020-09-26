//
//  RoundedView.swift
//  Procreate Test
//
//  Created by Kelvin on 26/9/20.
//  Copyright © 2020 Kelvin. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    //subclassing this UIView so that if there is a need we can easily add more options to it such as moving it completely down and only rounding top corners
    func configureView(radius: CGFloat) {
        roundedCorners(corners: .allCorners , radius: radius)
    }
    
    func animateView(show: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            show ? (self.center.y -= self.bounds.height + 40) : (self.center.y -= 20)
        }, completion: { (result) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                show ? (self.center.y += 20) : (self.center.y += self.bounds.height + 40)
            }, completion: nil)
        })
         self.layoutIfNeeded()
    }
}
