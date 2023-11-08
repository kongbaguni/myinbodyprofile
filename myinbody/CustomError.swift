//
//  CustomError.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/16/23.
//

import Foundation
enum CustomError : Error {
    /** 이름 입력 안함*/
    case emptyName
    /** 이름을 잘못 입력함*/
    case incorrectName
    /** 이미 삭제된 프로필*/
    case deletedProfile
    /** 계정 탈퇴를 위한 인증에서 다른 아이디로 로그인함*/
    case wrongAccountSigninWhenLeave
    /** 포인트가 부족하다*/
    case notEnoughPoint
}

extension CustomError {
    public var description : String {
        switch self {
        case .notEnoughPoint:
            return "Not enough Point"
        case .wrongAccountSigninWhenLeave:
            return "wrong account signin when leave"
        case .incorrectName:
            return "incorrect name input error"
        case .emptyName:
            return "empty name err"
        case .deletedProfile :
            return "deleted profile"
        }
    }
}

extension CustomError : LocalizedError {
    public var errorDescription:String? {
        switch self {
        case .notEnoughPoint:
            return NSLocalizedString("Not enough Point", comment: "Not enough Point")
        case .wrongAccountSigninWhenLeave:
            return NSLocalizedString("wrongAccountSigninWhenLeave msg", comment: "wrong acount sign in")
        case .incorrectName:
            return NSLocalizedString("incorrect name input error", comment: "incorrect name input error")
        case .emptyName:
            return NSLocalizedString("empty name error", comment: "empty name")
        case .deletedProfile:
            return NSLocalizedString("deleted profile error", comment: "deleted profile")
        }
    }
}
