
import UIKit
import TinyConstraints
import OpenSansSwift

class ViewController: UIViewController {

    // MARK: - UI components

    private let scrollview = UIScrollView().apply {
        $0.backgroundColor = .purple
    }

    private let contentView = UIView().apply {
        $0.backgroundColor = .orange
    }

    private  let subview1 = UIView().apply {
        $0.backgroundColor = .green
    }

    private let subview2 = UIView().apply {
        $0.backgroundColor = .blue
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        buildViewTree()
        setConstraints()
    }
    @objc
    private func buildViewTree() {
        [scrollview].forEach(self.view.addSubview)
        [contentView].forEach(scrollview.addSubview)
        [subview1, subview2].forEach(contentView.addSubview)
    }
    
    private func setConstraints() {
        scrollview.edgesToSuperview(insets: .uniform(16), usingSafeArea: true)

        contentView.run {
            $0.edgesToSuperview()
            $0.widthToSuperview()
            $0.heightToSuperview(priority: .defaultHigh)
        }

        subview1.run {
            $0.width(100)
            $0.height(700)

            $0.topToSuperview()
            $0.leftToSuperview()
        }

        subview2.run {
            $0.width(200)
            $0.height(800)


            $0.topToBottom(of: subview1, offset: 16)
            $0.leftToSuperview()
            $0.bottomToSuperview()
        }





    }
}
