//
//  CTView.swift
//  test
//
//  Created by Yoni on 10/01/2020.
//  Copyright © 2020 Yoni. All rights reserved.
//


// see https://danielgorst.wordpress.com/2012/07/30/embedding-a-hyperlink-into-coretext/
// also https://www.raywenderlich.com/578-core-text-tutorial-for-ios-making-a-magazine-app



/*

 Rien dans le ciel étoilé ne laissait prévoir que des choses étranges et mystérieuses allaient bien se produire.
 Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable géant, perça les ténèbres.
 Le géant, qui répondait au nom de Hagrid, laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... » « Harry Potter... Le survivant!

 */


/*

 - have a label to know the view size with autolayout (not uitextview. it renders text differently from CTFrame)
 - bottom padding because textfields may not display, 2 px is ok\
 - add invisible last char to attributedString. It might not display entirely otherwise
 */

import UIKit

class CTView: UIView {

    private static let textSize: CGFloat = 20
    private static let blankString = String(repeating: "\u{00a0}", count: 30)
    private let verticalPadding: CGFloat = 0
    
    // MARK: - UI components
    
    private let attributed = NSMutableAttributedString(string: "").apply {
        $0.append(NSAttributedString(string: "Rien dans le ciel "))
        $0.append(NSAttributedString(
            string: CTView.blankString,
            attributes: [.underlineColor : UIColor.green]))
        $0.append(NSAttributedString(string: " ne laissait prévoir que des choses étranges et "))
        $0.append(NSAttributedString(
            string: CTView.blankString,
            attributes: [.underlineColor : UIColor.green]))
        $0.append(NSAttributedString(string: " allaient bien se produire. "))

        $0.append(NSAttributedString(string: "\n"))

        $0.append(NSAttributedString(string: "Alors que les Moldus dormaient du sommeil de l'innocence, une énorme moto chevauchée par un véritable "))
        $0.append(NSAttributedString(
            string: CTView.blankString,
            attributes: [.underlineColor : UIColor.green]))
        $0.append(NSAttributedString(string: " , perça les ténèbres."))

        $0.append(NSAttributedString(string: "\n"))

        $0.append(NSAttributedString(string: "Le géant, qui répondait au nom de "))
        $0.append(NSAttributedString(
            string: CTView.blankString,
            attributes: [.underlineColor : UIColor.green]))
        $0.append(NSAttributedString(string: " , laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... Harry Potter... Le "))
        $0.append(NSAttributedString(
            string: CTView.blankString,
            attributes: [.underlineColor : UIColor.green]))
        $0.append(NSAttributedString(string: " !"))

        // needed because UILabel is buggy with some attributed texts
        $0.append(NSAttributedString(
            string: ".",
            attributes: [.foregroundColor : UIColor.clear]))


        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        $0.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: textSize),
                .paragraphStyle: paragraphStyle
            ],
            range: NSRange(location: 0, length: $0.length))
    }
    
    private let label = UILabel().apply {
        $0.numberOfLines = 0
    }
    
    private var textFields = [UITextField]()
    
    // MARK: - View lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.purple.withAlphaComponent(0.4)
        self.contentMode = .redraw
        label.attributedText = self.attributed

        buildViewTree()
        setConstraints()
    }
    
    private func buildViewTree() {
        [label].forEach(self.addSubview)
        
        
        let blankCount = self.attributed.string.components(separatedBy: CTView.blankString).count - 1
        
        for _ in 0..<blankCount {
            self.textFields.append(self.createTextField())
        }
        
        textFields.forEach(self.addSubview)
    }
    
    private func setConstraints() {
        label.edgesToSuperview(insets: .bottom(2))
    }

    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.textMatrix = .identity
        context.translateBy(x: 0, y: self.boundsHeight)
        context.scaleBy(x: 1.0, y: -1.0)

        let boundsPath = CGMutablePath()
        boundsPath.addRect(self.bounds)
                
        let frameSetter = CTFramesetterCreateWithAttributedString(self.attributed)
        
        let textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, self.attributed.length), boundsPath, nil)
        let lines = CTFrameGetLines(textFrame) as! [CTLine]
        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(textFrame, .zero, &origins)
    
        var textFieldIndex = 0
        
        for (index, line) in lines.enumerated() {
            for run in CTLineGetGlyphRuns(line) as! [CTRun] {
                
                let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key: Any]
                if attributes[.underlineColor] != nil {
                    
                    let textField = self.textFields[textFieldIndex]
                    textFieldIndex += 1
                    
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    
                    textField.frameWidth = CGFloat(CTRunGetTypographicBounds(run, .zero, &ascent, &descent, nil))
                    textField.frameHeight = ascent + descent + 2 * self.verticalPadding
                    textField.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    textField.y = self.boundsHeight - origins[index].y - textField.frameHeight + descent + self.verticalPadding
                }
            }
        }
    }

    
    // MARK: - Helper
    
    private func createTextField() -> UITextField {
        return UITextField().apply {
            $0.backgroundColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: CTView.textSize)
            $0.textColor = UIColor.cyan
            $0.autocapitalizationType = .none
            
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.cyan.cgColor
            $0.layer.cornerRadius = 4
            
            let leftView = UIView().apply {
                $0.frameWidth = 8
            }
            let rightView = UIView().apply {
                $0.frameWidth = 8
            }
            
            $0.leftView = leftView
            $0.rightView = rightView
            $0.leftViewMode = .always
            $0.rightViewMode = .always
        }

    }

}
