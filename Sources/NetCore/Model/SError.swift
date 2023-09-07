//
//  SError.swift
//  CoreApi
//
//  Created by Ihor Kandaurov on 19.07.2023.
//

import Foundation

public struct SError: Decodable {
    public let message: String
    public let statusCode: Int
    public var cause: Cause? {
        Cause.allCases.first { message == $0.rawValue }
    }

    public init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }
}

public enum Cause: String, CaseIterable, LocalizedError {
    case invalidRefreshToken = "INVALID_REFRESH_TOKEN"
    case invalidAccessToken = "INVALID_ACCESS_TOKEN"
    case emailExist = "EMAIL_EXIST"
    case codeDoesNotMatch = "CODE_DOES_NOT_MATCH"
    case userIsNotVerified = "USER_IS_NOT_VERIFIED"
    case profileNotFound = "PROFILE_NOT_FOUND"
    case tokenExpired = "TOKEN_EXPIRED"
    case emailNotFound = "EMAIL_NOT_FOUND"
    case userNotFound = "USER_NOT_FOUND"
    case fileUploadError = "FILE_UPLOAD_ERROR"

    public var errorDescription: String {
        switch self {
        case .invalidRefreshToken:
            return "Invalid athorization data"
        case .invalidAccessToken:
            return "Invalid athorization data"
        case .emailExist:
            return "User with email exist"
        case .codeDoesNotMatch:
            return "Invalid code"
        case .userIsNotVerified:
            return "Problems with user"
        case .profileNotFound:
            return "Profile not found"
        case .tokenExpired:
            return "Please log in"
        case .emailNotFound:
            return "No user with this email"
        case .userNotFound:
            return "User not found"
        case .fileUploadError:
            return "Unable to upload image"
        }
    }
}
