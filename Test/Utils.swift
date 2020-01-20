//

import TinyConstraints

public protocol ScopeFunc {}
extension ScopeFunc {
    @inline(__always) public func apply(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
    @discardableResult
    @inline(__always) public func run<R>(block: (Self) -> R) -> R {
        return block(self)
    }
}
extension NSObject: ScopeFunc {}

extension CFRange {
    static let zero = CFRangeMake(0, 0)
}
