
import UIKit

class CollapsibleView: UIView {
    var expandHandler: () -> Void = {}

    private let collapsedTextHeight: CGFloat = 128
    private var collapsedConstraint = NSLayoutConstraint()

    // MARK: - UI components

    private let label = UILabel().apply {
        $0.numberOfLines = 0
        $0.text = """
        Cum haec taliaque sollicitas eius aures everberarent expositas semper eius modi rumoribus et patentes, varia animo tum miscente consilia, tandem id ut optimum factu elegit: et Vrsicinum primum ad se venire summo cum honore mandavit ea specie ut pro rerum tunc urgentium captu disponeretur concordi consilio, quibus virium incrementis Parthicarum gentium a arma minantium impetus frangerentur.

        Dum haec in oriente aguntur, Arelate hiemem agens Constantius post theatralis ludos atque circenses ambitioso editos apparatu diem sextum idus Octobres, qui imperii eius annum tricensimum terminabat, insolentiae pondera gravius librans, siquid dubium deferebatur aut falsum, pro liquido accipiens et conperto, inter alia excarnificatum Gerontium Magnentianae comitem partis exulari maerore multavit.
        """
    }

    private let gradient = GradientView().apply {
        $0.gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        $0.gradientLayer.locations = [0, 0.5]
        $0.gradientLayer.startPoint = .zero
        $0.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        $0.clipsToBounds = true
    }

    private lazy var seeMoreButton = UIButton().apply {
        $0.setTitle("SEE MORE", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 30)
        $0.addTarget(self, action: #selector(changeState), for: .touchUpInside)
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
        [label, gradient].forEach(self.addSubview)
        [seeMoreButton].forEach(gradient.addSubview)
    }

    private func setConstraints() {
        label.run {
            $0.edgesToSuperview(excluding: .bottom)
            $0.setCompressionResistance(.required, for: .vertical)
        }

        gradient.run {
            $0.edgesToSuperview(excluding: .top)
            $0.height(100)
            $0.topToBottom(of: label, priority: .defaultLow)
            self.collapsedConstraint = $0.topToSuperview(offset: self.collapsedTextHeight, priority: .defaultHigh)
        }

        seeMoreButton.run {
            $0.leadingToSuperview(offset: 16)
            $0.bottomToSuperview(offset: 8)
        }
    }

    // MARK: - UI Action

    @objc private func changeState() {
        self.collapsedConstraint.isActive.toggle()

        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }

        self.expandHandler()
    }

}
