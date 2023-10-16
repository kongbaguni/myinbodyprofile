//
//  CustomError.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/16/23.
//

import Foundation
enum CustomError : Error {
    case emptyName
}

extension CustomError {
    public var description : String {
        switch self {
        case .emptyName:
            return "empty name err"
        }
    }
}

extension CustomError : LocalizedError {
    public var errorDescription:String? {
        switch self {
        case .emptyName:
            return NSLocalizedString("empty name error", comment: "empty name")
        }
    }
}
