import SwiftUI
import Combine

@available(iOS 13.0, *)
extension Binding {
    public func onChange(_ closure: @escaping (Value) -> Void) -> Self {
        return Binding(
            get: {
                wrappedValue
            },
            set: {
                self.wrappedValue = $0
                closure($0)
            }
        )
    }
}
