//
//  Authorization.swift
//  CoreApi
//
//  Created by Ihor Kandaurov on 13.07.2023.
//

import Foundation

public extension Response {
    struct Authorization: Codable {
        public let accessToken: String
        public let refreshToken: String

        public init(accessToken: String, refreshToken: String) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
}
