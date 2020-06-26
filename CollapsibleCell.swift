//
//  TableViewCell.swift
//  Test
//
//  Created by Yoni on 30/01/2020.
//  Copyright © 2020 Yoni. All rights reserved.
//

import UIKit


class CollapsibleCell: UITableViewCell {

    let collapsibleView = CollapsibleView()


    // MARK: - View lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let truc = "ewifyubwef"

        print (truc)
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
        self.contentView.addSubview(collapsibleView)
    }

    private func setConstraints() {
        collapsibleView.edgesToSuperview()
    }
}
