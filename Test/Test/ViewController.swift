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
        
        for _ in 0...100 {
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
            updateColorIfMinViewIntersect()
        }
    }
    
    func updateColorIfMinViewIntersect() {
        var biggestIntersectedView: UIView?
        for staticView in staticViews {
            let isStaticViewIntersets = staticView.frame.intersects(mainView.frame)
            if isStaticViewIntersets {
                let staticViewArea = staticView.width * staticView.height
                let biggestIntersectedViewArea = (biggestIntersectedView?.width ?? 0) * (biggestIntersectedView?.height ?? 0)
                
                if staticViewArea > biggestIntersectedViewArea {
                    biggestIntersectedView = staticView
                }
            }
        }
        
        if let biggestIntersectedView = biggestIntersectedView {
            updateMainViewBackgroundWith(biggestIntersectedView)
        }
    }
    
    func updateMainViewBackgroundWith(_ intersectedView: UIView) {
        struct Static {
            static var currentIntersectedView: UIView?
            static var animating = false
        }

        guard !Static.animating else {
            return
        }
        
        if Static.currentIntersectedView == nil || Static.currentIntersectedView != intersectedView {
            Static.currentIntersectedView = intersectedView
            
            Static.animating = true
            
            UIView.animate(withDuration: 0.15, animations: {
                self.mainView.backgroundColor = Static.currentIntersectedView?.backgroundColor
                self.mainView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (success) in
                UIView.animate(withDuration: 0.15, animations: {
                    self.mainView.transform = .identity
                }, completion: { (success) in
                    Static.animating = false
                })
            })
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

