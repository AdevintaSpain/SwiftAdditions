import Foundation

extension Dictionary where Key == String, Value == String {
    static func + <K, V> (left: [K: V], right: [K: V]) -> [K: V] {
        var result = left
        for (k, v) in right {
            result[k] = v
        }

        return result
    }
}
