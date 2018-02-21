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
    static let numberOfViews = 100

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
        
        let tapReco = UITapGestureRecognizer(target: self, action: #selector(selectView))
        mainView.addGestureRecognizer(tapReco)
        
        return mainView
    }()
    
    lazy var staticViews: [UIView] = {
        var staticViews = [UIView]()
        
        for _ in 0...ViewController.numberOfViews {
            staticViews.append(newRandomView())
        }
        
        return staticViews
    }()
    
    var currentIntersectedView: UIView?
    
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
    
    
    //MARK: - Animation
    
    func updateColorIfMainViewIntersect() {
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
        
        
        if let biggestIntersectedView = biggestIntersectedView, biggestIntersectedView != currentIntersectedView {
            mainView.backgroundColor = biggestIntersectedView.backgroundColor
        }
        currentIntersectedView = biggestIntersectedView

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
    
    func spinView(_ currentView: UIView, completion: (() -> Void)? ) {
        UIView.animate(withDuration: 0.3, animations: {
            currentView.transform = CGAffineTransform(rotationAngle:CGFloat.pi)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.3, animations: {
                currentView.transform = CGAffineTransform(rotationAngle:CGFloat.pi)
            }, completion: { (success) in
                currentView.transform = .identity
                
                if let completion = completion {
                    completion()
                }
            })
        })
    }
    
    func bringToFrontAndBumpView(_ currentView: UIView, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.15, animations: {
            currentView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { (success) in
            self.view.bringSubview(toFront: currentView)
            UIView.animate(withDuration: 0.15, animations: {
                currentView.transform = .identity
            }, completion: { (success) in
                
                if let completion = completion {
                    completion()
                }
            })
        })

    }
    
}

//MARK: - Gesture

extension ViewController {
    
    @objc func moveMainView(_ panReco: UIPanGestureRecognizer) {
        struct Static {
            static var delta: CGPoint = CGPoint.zero
        }
        
        let location = panReco.location(in: view)
        
        if panReco.state == .began {
            Static.delta = CGPoint(x: mainView.centerX - location.x, y: mainView.centerY - location.y)
        } else if panReco.state == .changed{
            mainView.center = CGPoint(x: location.x + Static.delta.x, y: location.y + Static.delta.y)
            updateColorIfMainViewIntersect()
        }
    }
    
    @objc func selectView(_ tapReco: UITapGestureRecognizer) {
        
        guard let currentIntersectedView = currentIntersectedView else {
            return
        }
        
        currentIntersectedView.layer.borderWidth = 1
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        currentIntersectedView.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        hue += 0.5
        
        if hue > 1 {
            hue -= 1
        }
        
        currentIntersectedView.layer.borderColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            spinView(mainView, completion: nil)
        }
    }
}

