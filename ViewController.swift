
import TinyConstraints
import UI
import UIKit


let text = "Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !"
let locations = [18, 66, 196, 251, 401]


class ViewController: UIViewController {

    // MARK: - UI components

    private let subview = FillTheBlanksView().apply {
        $0.text = FillTheBlanksView.Text(string: text, blankLocations: locations)
    }

    private let editableContainer = GradientView().apply {
        $0.gradientLayer.colors = [0x9A87FE, 0x4286ED, 0x00F0AF]
            .map { UIColor(hex: $0).cgColor }
        $0.gradientLayer.locations = [-0.3, 0.5, 1.2]
        $0.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        $0.gradientLayer.endPoint = CGPoint(x: 1, y: 0)

        $0.alpha = 0
    }




    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buildViewTree()
        setConstraints()
    }

    private func buildViewTree() {
        [editableContainer].forEach(self.view.addSubview)
        editableContainer.addSubview(subview)
    }
    
    private func setConstraints() {
        editableContainer.edgesToSuperview()
        subview.run {
            $0.horizontalToSuperview(insets: .horizontal(16), usingSafeArea: true)
            $0.topToSuperview(usingSafeArea: true)
            $0.bottomToSuperview().keyboardAware()
        }
    }

    // MARK: - Animation

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self.view)
        displayEditableViewAnimated(from: touchPoint!)
        subview.focusFirstBlank()
    }

    private func displayEditableViewAnimated(from startPoint: CGPoint) {
        let startPath = startEditablePath(from: startPoint)
        let endPath = endEditablePath()

        let maskLayer = CAShapeLayer()
        maskLayer.path = startPath
        editableContainer.layer.mask = maskLayer
        editableContainer.alpha = 1

        let animation = CABasicAnimation(keyPath: (\CAShapeLayer.path).string)
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        maskLayer.add(animation, forKey: "displayEditableView")

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.path = endPath
        CATransaction.commit()
    }

    private func startEditablePath(from startPoint: CGPoint) -> CGPath {
        let startRect = CGRect(x: startPoint.x, y: startPoint.y, width: 0, height: 0)
        return CGPath(rect: startRect, transform: nil)
    }

    private func endEditablePath() -> CGPath {
        let endPathDiameter = self.view.center.distance(to: .zero) * 2
        let endPathOrigin = CGPoint (
            x: -(endPathDiameter - self.view.boundsWidth) / 2,
            y: -(endPathDiameter - self.view.boundsHeight) / 2
        )
        let endRect = CGRect(
            origin: endPathOrigin,
            size: CGSize(width: endPathDiameter, height: endPathDiameter)
        )

        return CGPath(
            roundedRect: endRect,
            cornerWidth: endPathDiameter / 2,
            cornerHeight: endPathDiameter / 2,
            transform: nil
        )
    }

}
