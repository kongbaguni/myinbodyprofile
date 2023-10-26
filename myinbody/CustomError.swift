//
//  CustomError.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/16/23.
//

import Foundation
enum CustomError : Error {
    case emptyName
    case deletedProfile
}

extension CustomError {
    public var description : String {
        switch self {
        case .emptyName:
            return "empty name err"
        case .deletedProfile :
            return "deleted profile"
        }
    }
}

extension CustomError : LocalizedError {
    public var errorDescription:String? {
        print(self)
        switch self {
        case .emptyName:
            return NSLocalizedString("empty name error", comment: "empty name")
        case .deletedProfile:
            return NSLocalizedString("deleted profile error", comment: "deleted profile")
        }
    }
}
