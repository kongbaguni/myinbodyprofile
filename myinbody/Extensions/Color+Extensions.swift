//
//  Color+Extensions.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/8/23.
//

import Foundation
import SwiftUI
extension Color {
    var ciColor : CIColor {
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        let cgColor = NativeColor(self).cgColor
        return CIColor(cgColor: cgColor)
    }
}
