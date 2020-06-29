
/*
 For the inspiration see the following source
 https://www.raywenderlich.com/578-core-text-tutorial-for-ios-making-a-magazine-app
 https://danielgorst.wordpress.com/2012/07/30/embedding-a-hyperlink-into-coretext/
 */

import UIKit

class FillTheBlanksView: UIScrollView {
    
    struct Text {
        var string = ""
        var blankLocations = [Int]()
    }

    var text = Text() {
        didSet { contentView.updateText(text.string, blankLocations: text.blankLocations) }
    }

    // MARK: - UI components
    
    private let contentView = FillTheBlanksContentView()
    
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
    }
    
    private func buildViewTree() {
        self.addSubview(contentView)
    }
    
    private func setConstraints() {
        contentView.apply {
            $0.edgesToSuperview()
            $0.widthToSuperview()
            $0.heightToSuperview(priority: .defaultLow)
        }
    }
}

fileprivate class FillTheBlanksContentView: UIView {
    

    private static let textSize: CGFloat = 14
    private static let blankString = String(repeating: "\u{00a0}", count: 30)
    private static let blankAttributeKey = NSAttributedString.Key.underlineColor
    private static let blankAttributes = [ blankAttributeKey: UIColor.green]
    
    private var attribuedString = NSAttributedString()
    private lazy var heightConstraint = self.height(0, priority: .defaultHigh)
    
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
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

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
    
        updateContentHeight(frameSetter: frameSetter)
        updateTextFieldsFrame(lines: lines, lineOrigins: lineOrigins)
    }
    
    // MARK: - Update
    
    func updateText(_ string: String, blankLocations: [Int]) {
        self.attribuedString = computeAttributedText(string: string, blanksLocation: blankLocations)
        updateTextFieldCount(blankLocations.count)
        
        setNeedsLayout()
    }

    // MARK: - Helper
    
    private func createTextField() -> UITextField {
        return UITextField().apply {
            $0.backgroundColor = .clear
            $0.font = UIFont.boldSystemFont(ofSize: FillTheBlanksContentView.textSize)
            $0.textColor = .black
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.textAlignment = .center
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
              
        blanksLocation.reversed().forEach { location in
            let blankAttributedString = NSAttributedString(
                string: FillTheBlanksContentView.blankString,
                attributes: FillTheBlanksContentView.blankAttributes
            )
            attributedString.insert(blankAttributedString, at: location)
        }
        
        let paragraphStyle = NSMutableParagraphStyle().apply { $0.lineSpacing = 14 }
        
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: FillTheBlanksContentView.textSize),
                .foregroundColor: UIColor.white.cgColor,
                .paragraphStyle: paragraphStyle
            ],
            range: NSRange(location: 0, length: attributedString.length))
        
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
    
    private func updateContentHeight(frameSetter: CTFramesetter) {
        self.heightConstraint.constant = CTFramesetterSuggestFrameSizeWithConstraints(
            frameSetter,
            CFRangeMake(0, self.attribuedString.length),
            nil,
            CGSize(width: self.boundsWidth, height: .greatestFiniteMagnitude),
            nil
        ).height
    }
    
    private func updateTextFieldsFrame(lines: [CTLine], lineOrigins: [CGPoint]) {
        var textFieldIndex = 0
        
        for (lineIndex, line) in lines.enumerated() {
            for run in CTLineGetGlyphRuns(line) as! [CTRun] {
                let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key: Any]
                
                if attributes[FillTheBlanksContentView.blankAttributeKey] != nil {
                    
                    let textField = self.textFields[textFieldIndex]
                    textFieldIndex += 1
                    
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    
                    textField.frameWidth = CGFloat(CTRunGetTypographicBounds(run, .zero, &ascent, &descent, nil))
                    textField.frameHeight = 28
                    textField.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    textField.centerY = self.boundsHeight - lineOrigins[lineIndex].y + descent - (ascent +  descent)/2
                }
            }
        }
    }
}


extension FillTheBlanksContentView: UITextFieldDelegate {
    
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
