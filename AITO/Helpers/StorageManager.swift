import Foundation

private extension String {
    static let playerNameKey = "playerNameKey"
    static let matchKey = "matchKey"
}

class StorageManager {
    static let shared = StorageManager()
    var matches: [PlayerMatch]?
    
    private init() {
        updateMatches()
    }
    
    private func updateMatches() {
        self.matches = loadMatches()
    }
    
    func saveName(_ name: String) {
        UserDefaults.standard.set(name, forKey: .playerNameKey)
    }
    
    func loadName() -> String {
        guard let name = UserDefaults.standard.object(forKey: .playerNameKey) as? String else { return "Player" }
        return name
    }
    
    func saveMatch(match: PlayerMatch) {
        if match.score != 0 {
            if self.matches == nil {
                var matches: [PlayerMatch] = []
                matches.append(match)
                UserDefaults.standard.set(encodable: matches, forKey: .matchKey)
                updateMatches()
            } else {
                self.matches?.append(match)
                self.matches = self.matches?.sorted { $0.score > $1.score }
                UserDefaults.standard.set(encodable: self.matches, forKey: .matchKey)
            }
        }
    }
    
    func loadMatches() -> [PlayerMatch]? {
        guard let matches = UserDefaults.standard.value([PlayerMatch].self, forKey: .matchKey) else { return nil }
        return matches
    }
    
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: .matchKey)
    }
    
}

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T?  {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        
        return nil
    }
}
