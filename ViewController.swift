//
//  ViewController.swift
//  Test
//
//  Created by Yoni on 22/11/2019.
//  Copyright © 2019 Yoni. All rights reserved.
//

import UIKit
import TinyConstraints
import OpenSansSwift

class ViewController: UIViewController {

    // MARK: - UI components

    private let subview = CTView()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buildViewTree()
        setConstraints()
    }

    private func buildViewTree() {
        [subview].forEach(self.view.addSubview)
    }

    private func setConstraints() {
        subview.horizontalToSuperview(insets: .horizontal(8))
        subview.centerYToSuperview()
    }


}
