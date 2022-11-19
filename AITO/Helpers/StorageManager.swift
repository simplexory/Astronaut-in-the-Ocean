import Foundation

private extension String {
    static let playerNameKey = "playerNameKey"
    static let matchKey = "matchKey"
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
    
    func saveMatch(_ playerMatches: PlayerMatch) {
        UserDefaults.standard.set(playerMatches, forKey: .matchKey)
    }
    
    func loadMatch() -> PlayerMatch? {
        guard let match = UserDefaults.standard.object(forKey: .matchKey) as? PlayerMatch else { return nil }
        return match
    }
    
}
