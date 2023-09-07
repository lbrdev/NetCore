//
//  EmptyResponse.swift
//
//
//  Created by lbr on 31.10.2021.
//

import Foundation

public extension Response {
    struct Empty: Codable {
        public init() {}
    }
}
