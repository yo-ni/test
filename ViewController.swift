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

//    private let subview = CollapsibleView()


    private lazy var subview = UITableView().apply {
        $0.register(TableViewCell.self, forCellReuseIdentifier: String(describing: TableViewCell.self))
        $0.dataSource = self
        $0.estimatedRowHeight = 100
        $0.rowHeight = UITableView.automaticDimension
    }

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
//        subview.horizontalToSuperview(insets: .horizontal(8))
//        subview.centerYToSuperview()
        subview.edgesToSuperview()
    }
}


extension ViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if
            indexPath.row == 0,
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self)) as? TableViewCell {
            cell.subview.expandHandler = {
                self.subview.beginUpdates()
                self.subview.endUpdates()

            }
            return cell
        }
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = .green
        return cell
    }


}
