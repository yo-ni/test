
import UIKit

public extension UIView {
    
    var origin: CGPoint {
        set {
            var newFrame = frame
            newFrame.origin = newValue
            frame = newFrame
        }
        get {
            return frame.origin
        }
    }
    
    var x: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.x = newValue
            frame = newFrame
        }
        get {
            return frame.origin.x
        }
    }
    
    var y: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.y = newValue
            frame = newFrame
        }
        get {
            return frame.origin.y
        }
    }
    
    var frameRight: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.x = newValue - frame.size.width
            frame = newFrame
        }
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    var frameBottom: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.y = newValue - frame.size.height
            frame = newFrame
        }
        get {
            return frame.origin.y + frame.size.height
        }
    }
    
    var frameSize: CGSize {
        set {
            var newFrame = frame
            newFrame.size = newValue
            frame = newFrame
        }
        get {
            return frame.size
        }
    }
    
    var frameWidth: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.width = newValue
            frame = newFrame
        }
        get {
            return frame.size.width
        }
    }
    
    var frameHeight: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.height = newValue
            frame = newFrame
        }
        get {
            return frame.size.height
        }
    }

    var boundsWidth: CGFloat {
        set {
            var newBounds = self.bounds
            newBounds.size.width = newValue
            self.bounds = newBounds
        }
        get {
            return self.bounds.size.width
        }
    }
    
    var boundsHeight: CGFloat {
        set {
            var newBounds = self.bounds
            newBounds.size.height = newValue
            self.bounds = newBounds
        }
        get {
            return self.bounds.size.height
        }
    }

    var centerX: CGFloat {
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
        get {
            return center.x
        }
    }
    
    var centerY: CGFloat {
        set {
            center = CGPoint(x:center.x, y:newValue)
        }
        get {
            return center.y
        }
    }
    
    func centerFrameInSuperview() {
        if let superview = superview {
            center = CGPoint(x:superview.boundsWidth/2, y:superview.boundsHeight/2);
        }
    }
    
    class var windowHeigh: CGFloat? {
        return UIApplication.shared.keyWindow?.boundsHeight;
    }
    
    class var windowWidth: CGFloat? {
        return UIApplication.shared.keyWindow?.boundsWidth;
    }
}
