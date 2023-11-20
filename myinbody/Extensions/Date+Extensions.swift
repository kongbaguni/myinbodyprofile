//
//  Date+Extensions.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/19/23.
//

import Foundation
extension Date {    
    var simpleString:String {
        let now = Date().timeIntervalSince1970
        let interval = now - timeIntervalSince1970
        
        if interval < 60 {
            return NSLocalizedString("Just before", comment: "time")
        }
        if interval < 3600 {
            return "\(Int(interval / 60)) \(NSLocalizedString("minute ago", comment: "time"))"
        }
        if interval < 86400 {
            let h = Int(interval / 3600)
            return "\(h) \(NSLocalizedString("hours ago", comment: "time"))"
        }
        return formatted(date: .complete, time: .shortened)
    }
    
    func formatting(format:String)->String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var age:Int {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let components = calendar.dateComponents([.year], from: self, to: currentDate)
        guard let years = components.year else { return 0 }
        
        return years
    }
}
