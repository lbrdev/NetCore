//
//  RepositoryProtocol.swift
//  CoreApi
//
//  Created by Ihor Kandaurov on 14.07.2023.
//

import Foundation

public protocol RepositoryProtocol: AnyObject {
    var apiConfiguration: ApiConfig { get }
    var securityStorage: SecurityStorageProtocol { get }
    var logger: NetworkLogger { get }
    var errorMonitor: ErrorMonitor { get }
}
