import Foundation

public extension Int {
    init?(safe value: String?) {
        guard let value = value, let safeInt = Int(value) else { return nil }
        self = safeInt
    }
}

public extension Double {
    init?(safe value: String?) {
        guard let value = value, let safeInt = Double(value) else { return nil }
        self = safeInt
    }
}

public extension String {
    init?(safe value: String?) {
        guard let value = value else { return nil }
        self = value
    }

    init?(safe value: Int64?) {
        guard let value = value else { return nil }
        self = String(value)
    }
}

public extension Bool {
    init?(safe value: String?) {
        guard let value = value else { return nil }
        if value == "true" {
            self = true
        } else if value == "false" {
            self = false
        } else {
            return nil
        }
    }

    init(safeFalse value: String?) {
        guard let value = value else { self = false; return }
        guard value == "true" else { self = false; return }
        self = true
    }

    init(safeTrue value: String?) {
        guard let value = value else { self = true; return }
        guard value == "false" else { self = true; return }
        self = false
    }
}

public extension URL {
    init?(safe string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
}
