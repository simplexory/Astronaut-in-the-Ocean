import Foundation

struct PlayerMatch: Codable {
    let name: String
    let score: Int
    let time: TimeInterval
    let difficult: Difficult
}
