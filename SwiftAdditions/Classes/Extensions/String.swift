import Foundation

public extension String {
    
    var localised: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(params: [String]) -> String{
        return String(format: NSLocalizedString(self, comment: ""), params)
    }
    
    func localised(param: String) -> String {
        return String(format: NSLocalizedString(self, comment: ""), param)
    }
    
    func localised(param1: String, param2: String) -> String {
        return String(format: NSLocalizedString(self, comment: ""), param1, param2)
    }
    
    func localised(param1: String, param2: String, param3: String) -> String {
        return String(format: NSLocalizedString(self, comment: ""), param1, param2, param3)
    }
    
    func localised(param1: String, param2: String, param3: String, param4: String) -> String {
        return String(format: NSLocalizedString(self, comment: ""), param1, param2, param3, param4)
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    func nsRange(of string: String) -> NSRange? {
        if let range = self.range(of: string) {
            return NSRange(range, in: self)
        }
        return nil
    }
    
    func getURLRange() -> [NSTextCheckingResult] {
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        return matches
    }
    
    
    func extractURL(from location: Int) -> URL? {
        let matches = self.getURLRange()
        for match in matches {
            guard  NSLocationInRange(location, match.range),
                let text = self as NSString?,
                let urlToOpen = URL(string: (text.substring(with: match.range)))  else { continue }
            
            var link = urlToOpen.absoluteString
            if link.lowercased().hasPrefix("http://") == false  && link.lowercased().hasPrefix("https://") == false {
                link = "http://\(link)"
            }
            guard let url = URL(string: link) else { continue }
            return url
            
        }
        return nil
    }
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

}
