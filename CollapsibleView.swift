
import UIKit

class CollapsibleView: UIView {
    var heightWillCHangeHandler: () -> Void = {}
    var heightDidCHangeHandler: () -> Void = {}

    private let collapsedTextHeight: CGFloat = 128
    private var collapsedConstraint = NSLayoutConstraint()

    // MARK: - UI components

    private let textView = UITextView().apply {
        $0.isScrollEnabled = false
    }

    private let gradient = GradientView().apply {
        $0.gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        $0.gradientLayer.startPoint = .zero
        $0.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    }

    private lazy var seeMoreButton = UIButton().apply {
        $0.backgroundColor = .white
        $0.addTarget(self, action: #selector(changeState), for: .touchUpInside)
    }

    private let separator = UIView().apply {
        $0.backgroundColor = .darkGray
    }



    private let seeMoreLabel = UILabel().apply {
        $0.text = "SEE MORE"
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 17)
    }

    // MARK: - View lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        buildViewTree()
        setConstraints()

        self.clipsToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
    }

    private func buildViewTree() {
        [textView, gradient, seeMoreButton].forEach(self.addSubview)
        [separator, seeMoreLabel].forEach(seeMoreButton.addSubview)
    }

    private func setConstraints() {
        textView.run {
            $0.edgesToSuperview(excluding: .bottom)
            $0.setCompressionResistance(.required, for: .vertical)
        }

        gradient.run {
            $0.height(44)
            $0.bottomToTop(of: seeMoreButton)
            $0.horizontalToSuperview()
        }

        seeMoreButton.run {
            $0.height(44)
            $0.topToBottom(of: textView, priority: .defaultLow)
            $0.edgesToSuperview(excluding: .top)
            self.collapsedConstraint = $0.topToSuperview(offset: self.collapsedTextHeight, priority: .defaultHigh)
        }

        separator.run {
            $0.edgesToSuperview(excluding: .bottom)
            $0.height(1)
        }

        seeMoreLabel.run {
            $0.leadingToSuperview(offset: 8)
            $0.topToSuperview(offset: 8)
        }
    }

    // MARK: - UI Action

    @objc private func changeState() {
        self.heightWillCHangeHandler()
        self.collapsedConstraint.isActive.toggle()

        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.3) {
            self.gradient.alpha = self.collapsedConstraint.isActive ? 1 : 0
        }

        self.heightDidCHangeHandler()
    }

    func setText(_ text: NSAttributedString, forEstimatedWidth estimatedWidth: CGFloat) {
        textView.attributedText = text

        let size = CGSize(width: estimatedWidth, height: .greatestFiniteMagnitude)
        let estimatedHeight = textView.sizeThatFits(size).height

        if estimatedHeight < self.collapsedTextHeight {
            
        }
    }

}
