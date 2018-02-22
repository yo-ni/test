//
//  PairView.swift
//  Test
//
//  Created by Yoni on 22/02/2018.
//  Copyright © 2018 Yoni. All rights reserved.
//

import UIKit

class PairView: UIView {

    var selected: Bool {
        didSet {
            
            if selected {
                var hue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                
                hue += 0.5
                
                if hue > 1 {
                    hue -= 1
                }
                
                layer.borderColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
                layer.borderWidth = 2
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        selected = false

        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spin(completion: (() -> Void)? ) {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(rotationAngle:CGFloat.pi)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(rotationAngle:CGFloat.pi)
            }, completion: { (success) in
                self.transform = .identity
                
                if let completion = completion {
                    completion()
                }
            })
        })
    }
    
    func bump(middleCompletion: (() -> Void)?, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { (success) in
            
            if let middleCompletion = middleCompletion {
                middleCompletion()
            }

            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
            }, completion: { (success) in
                
                if let completion = completion {
                    completion()
                }
            })
        })
    }
}
