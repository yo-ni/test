//
//  PairView.swift
//  Test
//
//  Created by Yoni on 22/02/2018.
//  Copyright © 2018 Yoni. All rights reserved.
//

import UIKit

class PairView: UIView {

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
