import SwiftUI

public extension View {

    func injecting(_ modules: () -> [Register]) -> Self {
        CoreServiceLocator.shared.add(modules)
        return self
    }

    func injecting(_ module: () -> Register)  -> Self {
        CoreServiceLocator.shared.add(module)
        return self
    }
}
