
import TinyConstraints
import UIKit

public final class CollapsibleTextView: UIView {

    private static let relativeGradientMaskStart = 0.5

    private enum State {

        case collapsed
        case collapsing
        case expanded
        case expanding

        var isCollapsed: Bool {
            switch self {
            case .collapsing, .collapsed:
                return true
            case .expanding, .expanded:
                return false
            }
        }
    }

    // MARK: - UI components

    private lazy var textView = UITextView().apply {
        $0.backgroundColor = .clear
        $0.isSelectable = true
        $0.isScrollEnabled = false
        $0.isEditable = false
        $0.mask = self.gradientView
    }

    private let gradientView = GradientView().apply {
        $0.gradientLayer.run {
            $0.startPoint = .zero
            $0.endPoint = .init(x: 0, y: 1)
            $0.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        }
    }

    private let separator = UIView().apply {
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 0.5
        $0.alpha = 0
    }

    private let seeMoreLabel = UILabel().apply {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }

    private let seeMoreButton = UIButton().apply {
        $0.backgroundColor = .clear
        $0.tintColor = .clear
    }

    // MARK: - Public properties

    public var attributedText = NSAttributedString() {
        didSet {
            textView.attributedText = attributedText
            setNeedsLayout()
        }
    }

    public var willPrepareHeightAnimation: () -> Void = {}
    public var didPrepareHeightAnimation: () -> Void = {}
    public var didEndHeightAnimation: () -> Void = {}

    public var didUpdateCollapseState: (_ isCollapsed: Bool) -> Void = { _ in }

    public weak var textViewDelegate: UITextViewDelegate? {
        didSet { textView.delegate = textViewDelegate }
    }

    // MARK: - Private properties

    private var seeMoreText = ""
    private var seeLessText = ""

    private var collapsedTextViewHeight: CGFloat = 132

    private func estimatedTextHeight(fittingSize size: CGSize? = nil) -> CGFloat {
        let size = size ?? .init(width: bounds.width, height: .greatestFiniteMagnitude)
        return textView.sizeThatFits(size).height
    }

    private var state: State = .collapsed {
        didSet { didUpdateCollapseState(state.isCollapsed) }
    }

    private var seeMoreHeightConstraint: Constraint!

    private var hideSeeMoreConstraint = NSLayoutConstraint()
    private var collapsedConstraint = NSLayoutConstraint()

    // MARK: - Initialize

    public convenience init(
        seeMoreText: String,
        seeLessText: String,
        collapsedTextViewHeight: CGFloat = 132,
        isCollapsed: Bool = true
    ) {
        self.init(frame: .zero)

        self.seeMoreText = seeMoreText
        self.seeLessText = seeLessText
        self.collapsedTextViewHeight = collapsedTextViewHeight
        self.state = isCollapsed
            ? .collapsed
            : .expanded
    }

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {

        backgroundColor = UIColor.white

        buildViewTree()
        setConstraints()
        setInteractions()

        state.isCollapsed
            ? collapse(isAnimated: false, isForced: true)
            : expand(isAnimated: false, isForced: true)
    }


    // MARK: - Layout

    private func buildViewTree() {
        [textView, seeMoreButton].forEach(addSubview)
        [separator, seeMoreLabel].forEach(seeMoreButton.addSubview)
    }

    private func setConstraints() {

        textView.run {
            $0.edgesToSuperview(excluding: .bottom)
            $0.setCompressionResistance(.required, for: .vertical)
        }

        seeMoreButton.run {
            $0.edgesToSuperview(excluding: .top)

            $0.topToBottom(of: textView, priority: .defaultHigh)
            self.collapsedConstraint = $0.topToSuperview(offset: self.collapsedTextViewHeight, isActive: false)

            $0.height(48, priority: .defaultHigh)
            self.hideSeeMoreConstraint =  $0.height(0, isActive: false)
        }

        gradientView.run {
            $0.horizontalToSuperview()
            $0.height(56)
            $0.bottomToTop(of: seeMoreButton)
        }

        separator.run {
            $0.edgesToSuperview(excluding: .bottom)
            $0.height(1)
        }

        seeMoreLabel.run {
            $0.horizontalToSuperview()
            $0.topToSuperview(offset: 8)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateSeeMoreLabel()

        DispatchQueue.main.async {
            self.updateSeeMoreVisibility()
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {

        let insetedSize = CGSize(
            width: size.width - 32,
            height: size.height
        )

        let textViewHeight = state.isCollapsed
            ? min(collapsedTextViewHeight, estimatedTextHeight(fittingSize: insetedSize))
            : estimatedTextHeight(fittingSize: insetedSize)
        let hairlineHeight: CGFloat = 1
        let seeMoreLabelHeight = seeMoreHeightConstraint.constant
        let spacing: CGFloat = seeMoreLabelHeight > 0 ? 28 : 0

        return .init(
            width: size.width,
            height: textViewHeight + 8 + hairlineHeight + seeMoreLabelHeight + spacing
        )
    }

    public func updateSeeMoreVisibility(fittingSize size: CGSize? = nil) {
        self.hideSeeMoreConstraint.isActive = estimatedTextHeight(fittingSize: size) <= collapsedTextViewHeight
            ? true
            : false
    }

    // MARK: - Interactions

    private func setInteractions() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        seeMoreButton.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        state.isCollapsed
            ? expand()
            : collapse()
    }


    // MARK: - Methods

    private func updateSeeMoreLabel() {
        seeMoreLabel.text = state.isCollapsed
            ? seeMoreText.uppercased()
            : seeLessText.uppercased()
    }


    // MARK: - Animations

    public func expand(
        isAnimated: Bool = true,
        isForced: Bool = false
    ) {
        guard state.isCollapsed || isForced else { return }
        state = .expanding


        if !isForced { willPrepareHeightAnimation() }

        let udpateTextViewHeight = {
            self.gradientView.alpha = 0
            self.collapsedConstraint.isActive = false
            self.setNeedsLayout()
            self.layoutIfNeeded()

            if !isForced { self.didPrepareHeightAnimation() }
        }

        if isAnimated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
                animations: udpateTextViewHeight,
                completion: { _ in
                    self.state = .expanded
                    if !isForced { self.didEndHeightAnimation() }
                }
            )
        } else {
            udpateTextViewHeight()
        }

        updateSeeMoreLabel()
    }

    public func collapse(
        isAnimated: Bool = true,
        isForced: Bool = false
    ) {
        guard !state.isCollapsed || isForced else { return }
        state = .collapsing


        if !isForced { willPrepareHeightAnimation() }

        let udpateTextViewHeight = {
            self.gradientView.alpha = 1
            self.collapsedConstraint.isActive = false
            self.setNeedsLayout()
            self.layoutIfNeeded()

            if !isForced { self.didPrepareHeightAnimation() }
        }

        if isAnimated {

            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
                animations: udpateTextViewHeight,
                completion: { _ in
                    self.state = .collapsed
                    if !isForced { self.didEndHeightAnimation() }
                }
            )


        } else {
            udpateTextViewHeight()
        }

        updateSeeMoreLabel()
    }
}
