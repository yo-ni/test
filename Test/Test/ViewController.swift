//
//  ViewController.swift
//  Test
//
//  Created by Yoni on 18/02/2018.
//  Copyright © 2018 Yoni. All rights reserved.
//

import UIKit
import YHUIKit

class ViewController: UIViewController {

    static let maxRandomViewSize = 60
    static let minRandomViewSize = 10
    
    //MARK: - Main UI
    
    lazy var mainView: UIView = {
        let mainView = UIView()
        mainView.width = 44
        mainView.height = mainView.width
        mainView.backgroundColor = UIColor.blue
        mainView.layer.borderColor = UIColor.black.cgColor
        mainView.layer.borderWidth = 1
        
        let panReco = UIPanGestureRecognizer(target: self, action: #selector(moveMainView))
        mainView.addGestureRecognizer(panReco)
        
        return mainView
    }()
    
    lazy var staticViews: [UIView] = {
        var staticViews = [UIView]()
        
        for _ in 0...10 {
            staticViews.append(newRandomView())
        }
        
        return staticViews
    }()
    
    //MARK: - View Lifecycle
    
    override func loadView() {
        super.loadView()
        buildViewTree()
        layout()
    }
    
    func buildViewTree() {
        
        for staticView in staticViews {
            view.addSubview(staticView)
        }
        view.addSubview(mainView)
    }

    func layout() {
        mainView.centerInSuperview()
    }
    
    //MARK: - Gesture
    
    @objc func moveMainView(_ panReco: UIPanGestureRecognizer) {
        struct Static {
            static var delta: CGPoint = CGPoint.zero
        }
        
        let location = panReco.location(in: view)
        
        if panReco.state == .began {
            Static.delta = CGPoint(x: mainView.centerX - location.x, y: mainView.centerY - location.y)
        } else if panReco.state == .changed{
            mainView.center = CGPoint(x: location.x + Static.delta.x, y: location.y + Static.delta.y)
        }
    }
    
    //MARK: - Helper
    
    func newRandomView() -> UIView {
        let randomView = UIView()
        let randomWidth = Int(arc4random()) % (ViewController.maxRandomViewSize - ViewController.minRandomViewSize) + ViewController.minRandomViewSize
        let randomHeight = Int(arc4random()) % (ViewController.maxRandomViewSize - ViewController.minRandomViewSize) + ViewController.minRandomViewSize
        let randomHue = CGFloat( Int(arc4random()) % 360 ) / 360.0
        
        randomView.width = CGFloat(randomWidth)
        randomView.height = CGFloat(randomHeight)
        
        randomView.centerX = CGFloat(Int(arc4random()) % Int(view.bounds.width))
        randomView.centerY = CGFloat(Int(arc4random()) % Int(view.bounds.height))
        
        randomView.backgroundColor = UIColor(hue: randomHue, saturation: 1, brightness: 1, alpha: 1)

        return randomView
    }
}

