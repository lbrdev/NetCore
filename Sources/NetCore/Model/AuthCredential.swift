//
//  AuthCredential.swift
//
//
//  Created by lbr on 31.10.2021.
//

import Alamofire
import Foundation

public struct AuthCredential: AuthenticationCredential {
    public let accessToken: String
    public let refreshToken: String
    public let lastRefreshDate: Date

    public var requiresRefresh: Bool {
        return Date() > Date(timeInterval: 10 * 60, since: lastRefreshDate)
    }
}
