//
//  convertTimeZone.swift
//  Quotes
//
//  Created by Todd Meng on 12/24/20.
//

import Foundation
extension Date {
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(targetTimeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}
