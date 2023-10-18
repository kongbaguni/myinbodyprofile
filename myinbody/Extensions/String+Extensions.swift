//
//  String+Extensions.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/18/23.
//

import Foundation
extension String {
    var arrayValue : [String] {
        var result:[String] = []
        for char in Array(self) {
            result.append(String(char))
        }
        return result
    }
}
