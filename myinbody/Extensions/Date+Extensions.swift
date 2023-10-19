//
//  Date+Extensions.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/19/23.
//

import Foundation
extension Date {
    func formatting(format:String)->String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
