
import TinyConstraints
import UI
import UIKit


let text = "Rien dans le ciel  ne laissait prévoir que des choses étranges et  allaient bien se produire. Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable  perça les ténèbres. Le géant, qui répondait au nom de , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le !"
let locations = [18, 66, 196, 251, 401]

class ViewController: UIViewController {

    // MARK: - UI components

    private let subview = FillTheBlanksView().apply {
        $0.text = FillTheBlanksView.Text(string: text, blankLocations: locations)
    }
    
    private let scrollview = UIScrollView()
    


    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = GradientView().apply {
            $0.gradientLayer.colors = [0x9A87FE, 0x4286ED, 0x00F0AF]
                .map { UIColor(hex: $0).cgColor }
            $0.gradientLayer.locations = [-0.3, 0.5, 1.2]
            $0.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            $0.gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        buildViewTree()
        setConstraints()
    }

    private func buildViewTree() {
        [subview].forEach(self.view.addSubview)
    }
    
    private func setConstraints() {
        subview.run {
            $0.edgesToSuperview(insets: .horizontal(16), usingSafeArea: true)
        }
    }
}
