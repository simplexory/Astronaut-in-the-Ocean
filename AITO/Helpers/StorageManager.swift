import Foundation

private extension String {
    static let playerNameKey = "playerNameKey"
    static let scoreKey = "scoreKey"
}

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    func saveName(_ name: String) {
        UserDefaults.standard.set(name, forKey: .playerNameKey)
    }
    
    func loadName() -> String {
        guard let name = UserDefaults.standard.object(forKey: .playerNameKey) as? String else { return "Player" }
        return name
    }
    
    func saveLastScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: .scoreKey)
    }
    
    func loadLastScore() -> Int? {
        guard let score = UserDefaults.standard.object(forKey: .scoreKey) as? Int else { return nil }
        return score
    }
    
}
