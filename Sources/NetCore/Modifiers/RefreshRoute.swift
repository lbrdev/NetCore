//
//  RefreshRoute.swift
//  CoreApi
//
//  Created by Ihor Kandaurov on 14.07.2023.
//

import Foundation

struct RefreshRoute: Routable {
    private let token: String
    init(token: String) {
        self.token = token
    }

    var path: String = "/refresh-token"
    var endpoint: String = "/auth"
    var body: Data? {
        try? JSONSerialization.data(withJSONObject: ["refreshToken": token])
    }
}
