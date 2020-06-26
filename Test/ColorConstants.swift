//

import UIKit

extension UIColor {

    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
    
    convenience init(hex: String) {
        let hexStringClean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexStringClean)
        
        if hexStringClean.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        self.init(hex: Int(color)) //ok to cast UInt32 down to (at worst) Int32 since hexa colors are coded with 24 bits
    }

    private convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }

    func darker(_ percent: CGFloat = 0.1) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let newBrightness = brightness * (1 - percent)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }

    func lighter(_ percent: CGFloat = 0.1) -> UIColor {
        return self.darker(-percent)
    }

    // as the name says
    static let standardBlue = UIColor(hex: 0x007Aff)
    
    // kind of blue green
    static let positive = UIColor(hex: 0x00C4A7)

    // red color
    static let negative = UIColor(hex: 0xF3001E)
    
    // grays
    static let gray0 = UIColor(hex: 0x212121)
    
    static let gray1 = UIColor(hex: 0x333333)

    static let gray3 = UIColor(hex: 0x9E9E9E)
    
    static let gray4 = UIColor(hex: 0xBBBBBB)
    
    static let gray5 = UIColor(hex: 0xE0E0E0)
    
    static let gray6 = UIColor(hex: 0xEEEEEE)
    
    static let gray7 = UIColor(hex: 0xFAFAFA)

    // objects
    static let border = UIColor.gray5
    
    static let tableView = UIColor.gray6

    static let webinarYellow = UIColor(hex: 0xFFCB0A)
    
    // Document colors
    static let media = UIColor(hex: 0xF3001E)

    // Object colors
    static let course = UIColor(hex: 0x00a0ff)
    
    static let activeMention = UIColor(hex: 0xE5F5FF)
    
}
