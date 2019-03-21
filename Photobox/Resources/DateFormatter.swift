//
//  DateFormatter.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/20/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation

extension Date {
    func stringWith(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
