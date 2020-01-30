//
//  TableViewCell.swift
//  Test
//
//  Created by Yoni on 30/01/2020.
//  Copyright © 2020 Yoni. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    let subview = CollapsibleView()



    // MARK: - View lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        buildViewTree()
        setConstraints()
    }

    private func buildViewTree() {
        self.contentView.addSubview(subview)
    }

    private func setConstraints() {
        subview.edgesToSuperview()
    }
}
