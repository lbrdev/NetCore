//
//  ApiConfig.swift
//  Swanly
//
//  Created by Ihor Kandaurov on 04.07.2023.
//

import Foundation

public protocol ApiConfig {
    var name: String { get }
    var scheme: String { get }
    var host: String { get }
    var port: Int? { get }
    var path: String? { get }
    var enabled: Bool { get }
}

public extension ApiConfig {
    var port: Int? { return nil }
    var path: String? { return nil }
    var enabled: Bool { return true }
}
