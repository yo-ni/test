
/*
 see https://www.raywenderlich.com/578-core-text-tutorial-for-ios-making-a-magazine-app
 also https://danielgorst.wordpress.com/2012/07/30/embedding-a-hyperlink-into-coretext/

 - a special invisible attribute set has been set to the blank locations so we can retrieve those positions later
 - have a label to know the view size with autolayout (not uitextview. it renders text differently from CTFrame)
 - bottom padding added to the label because sometimes it sends the wrong size to autolayout. 2 px seems ok
 - add invisible last char to attributedString. It might not display entirely otherwise
 */

import UIKit

class FillTheBlanksView: UIView {
    
    struct Text {
        var string: String
        var blanksLocation: [Int]
    }

    private static let textSize: CGFloat = 14
    private static let blankString = String(repeating: "\u{00a0}", count: 30)
    private static let blankAttributes = [NSAttributedString.Key.underlineColor : UIColor.green]
    private let verticalPadding: CGFloat = 0
    
    
    var text = Text(string: "", blanksLocation: []) {
        didSet {
            self.attribuedString = computeAttributedText(string: text.string, blanksLocation: text.blanksLocation)
            updateTextFieldCount(text.blanksLocation.count)
        }
    }
    
    private var attribuedString = NSAttributedString() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: - UI components

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
        self.backgroundColor = UIColor.clear

        buildViewTree()
        setConstraints()
    }
    
    private func buildViewTree() {
    }
    
    private func setConstraints() {
    }

    override func draw(_ rect: CGRect) {
        guard
            let context = UIGraphicsGetCurrentContext()
        else { return }

        context.textMatrix = .identity
        context.translateBy(x: 0, y: self.boundsHeight)
        context.scaleBy(x: 1.0, y: -1.0)

        let boundsPath = CGMutablePath()
        boundsPath.addRect(self.bounds)
                
        let frameSetter = CTFramesetterCreateWithAttributedString(self.attribuedString)
        let textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, self.attribuedString.length), boundsPath, nil)
        
        CTFrameDraw(textFrame, context)

        let lines = CTFrameGetLines(textFrame) as! [CTLine]
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(textFrame, .zero, &lineOrigins)
    
        let calculedHeight = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, self.attribuedString.length), nil, CGSize(width: self.boundsWidth, height: .greatestFiniteMagnitude), nil).height

        self.height(calculedHeight, priority: .defaultHigh)
        
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
//            $0.append(NSAttributedString(
//                string: ".",
//                attributes: [.foregroundColor : UIColor.clear]))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 14
            $0.addAttributes(
                [
                    .font: UIFont.systemFont(ofSize: FillTheBlanksView.textSize),
                    .foregroundColor: UIColor.white.cgColor,
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
        UIView.animate(withDuration: 0.2) {
            textField.backgroundColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        
        UIView.animate(withDuration: 0.2) {
            textField.backgroundColor = isEmpty
                ? .clear
                : .white
        }
    }
}
