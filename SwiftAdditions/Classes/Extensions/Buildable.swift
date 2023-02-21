import Foundation

public protocol Buildable {}

public extension Buildable {
    func set<T>(_ keyPath: WritableKeyPath<Self, T>, to newValue: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = newValue
        return copy
    }
}
