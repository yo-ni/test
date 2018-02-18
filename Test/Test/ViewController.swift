//
//  ViewController.swift
//  Test
//
//  Created by Yoni on 18/02/2018.
//  Copyright © 2018 Yoni. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let mainView: UIView = {
        let mainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        mainView.backgroundColor = UIColor.blue
        
        let panReco = UIPanGestureRecognizer(target: self, action: #selector(moveMainView))
        mainView.addGestureRecognizer(panReco)
        
        return mainView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
    }

    
    
    @objc func moveMainView(panReco: UIPanGestureRecognizer) {
        struct Static {
            static var delta: CGPoint = CGPoint.zero
        }
        
        let location = panReco.location(in: view)
        
        if panReco.state == .began {
            Static.delta = CGPoint(x: mainView.center.y, y: <#T##CGFloat#>)
        }
        
    }
}

