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
 
div>Rien dans le ciel <u>6</u> ne laissait prévoir que des choses étranges et <u>12</u> allaient bien se produire. Alors que les Moldus dormaient du sommeil de l\'innocence, une énorme moto chevauchée par un véritable <u>5</u>, perça les ténèbres. Le géant, qui répondait au nom de <u>6</u>, laissa un petit tas de couverture devant la porte du 4, Privet Drive. Niché au cœur de ce paquet rudimentaire dormait un bébé... » « Harry Potter... Le <u>9</u>!
 */


/*

 - have a label to know the view size with autolayout (not uitextview. it renders text differently from CTFrame)
 - bottom padding because textfields may not display, 2 px is ok\
 - add invisible last char to attributedString. It might not display entirely otherwise
 */

import UIKit

class FillTheBlanksView: UIView {
    
    struct Text {
        var string: String
        var blanksLocation: [Int]
    }

    private static let textSize: CGFloat = 20
    private static let blankString = String(repeating: "\u{00a0}", count: 30)
    private static let blankAttributes = [NSAttributedString.Key.underlineColor : UIColor.green]
    private let verticalPadding: CGFloat = 0
    
    
    var text = Text(string: "", blanksLocation: []) {
        didSet {
            label.attributedText = computeAttributedText(string: text.string, blanksLocation: text.blanksLocation)
            updateTextFieldCount(text.blanksLocation.count)
        }
    }
    
    // MARK: - UI components
        
    private let label = UILabel().apply {
        $0.numberOfLines = 0
        $0.textColor = .white
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
        self.contentMode = .redraw

        buildViewTree()
        setConstraints()
    }
    
    private func buildViewTree() {
        [label].forEach(self.addSubview)
    }
    
    private func setConstraints() {
        label.edgesToSuperview(insets: .bottom(2))
    }

    override func draw(_ rect: CGRect) {
        guard
            let context = UIGraphicsGetCurrentContext(),
            let attributedText = self.label.attributedText
        else { return }

        context.textMatrix = .identity
        context.translateBy(x: 0, y: self.boundsHeight)
        context.scaleBy(x: 1.0, y: -1.0)

        let boundsPath = CGMutablePath()
        boundsPath.addRect(self.bounds)
                
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        
        let textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), boundsPath, nil)
        let lines = CTFrameGetLines(textFrame) as! [CTLine]
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(textFrame, .zero, &lineOrigins)
    
        var textFieldIndex = 0
        
        for (lineIndex, line) in lines.enumerated() {
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
                    textField.y = self.boundsHeight - lineOrigins[lineIndex].y - textField.frameHeight + descent + self.verticalPadding
                }
            }
        }
    }

    
    // MARK: - Helper
    
    private func createTextField() -> UITextField {
        return UITextField().apply {
            $0.backgroundColor = .clear
            $0.font = UIFont.boldSystemFont(ofSize: FillTheBlanksView.textSize)
            $0.textColor = .black
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.delegate = self
            
            $0.layer.apply {
                $0.cornerRadius = 4
                $0.borderWidth = 1
                $0.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            }
                                    
            $0.leftView = UIView().apply { $0.frameWidth = 8 }
            $0.rightView = UIView().apply { $0.frameWidth = 8 }
            $0.leftViewMode = .always
            $0.rightViewMode = .always
        }
    }
    
    private func computeAttributedText(string: String, blanksLocation: [Int]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
                
        blanksLocation.enumerated().forEach { index, location in
            let blankAttributedString = NSAttributedString(
                string: FillTheBlanksView.blankString,
                attributes: FillTheBlanksView.blankAttributes
            )
            
            let updatedLocation = location + index * FillTheBlanksView.blankString.count
            
            attributedString.insert(blankAttributedString, at: updatedLocation)
        }
        
        attributedString.apply {

            // needed because UILabel is buggy with some attributed texts
            $0.append(NSAttributedString(
                string: ".",
                attributes: [.foregroundColor : UIColor.clear]))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 14
            $0.addAttributes(
                [
                    .font: UIFont.systemFont(ofSize: FillTheBlanksView.textSize),
                    .paragraphStyle: paragraphStyle
                ],
                range: NSRange(location: 0, length: $0.length))
        }
        
        return attributedString
    }
    
    private func updateTextFieldCount(_ blankCount: Int) {
        
        self.textFields.forEach { $0.removeFromSuperview() }
        
        (0..<blankCount).forEach { _ in
            let textField = self.createTextField()
            self.textFields.append(textField)
            addSubview(textField)
        }
    }
}


extension FillTheBlanksView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.backgroundColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        
        UIView.animate(withDuration: 0.3) {
            textField.backgroundColor = isEmpty
                ? .clear
                : .white
        }
    }
}
