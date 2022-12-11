//
//  Date+Extension.swift
//  AITO
//
//  Created by Юра Ганкович on 5.12.22.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return rhs.timeIntervalSinceReferenceDate - lhs.timeIntervalSinceReferenceDate
    }
}

extension TimeInterval {
    func asMatchTime() -> String {
        if self < 60 {
            return "\(Int(self.truncatingRemainder(dividingBy: 60)))s"
        }
        
        return "\(Int(self / 60))m \(Int(self.truncatingRemainder(dividingBy: 60)))s"
    }
}
