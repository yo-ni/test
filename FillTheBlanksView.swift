
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
        observeKeyboardNotif()
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
            $0.edgesToSuperview(insets: .vertical(6))
            $0.widthToSuperview()
            $0.heightToSuperview(priority: .defaultLow)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Action
    
    func focusFirstBlank() {
        
    }
}

extension FillTheBlanksView {
    private func observeKeyboardNotif() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
    }
        
    @objc private func keyboardWillShow(notif: Notification) {
        guard let userInfo = notif.userInfo,
        let keyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
        else { return }

        var contentInset = self.contentInset
        contentInset.bottom = keyboardFrame.height
        self.contentInset = contentInset
    }
}


