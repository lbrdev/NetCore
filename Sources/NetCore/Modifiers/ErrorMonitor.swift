//
//  ErrorMonitor.swift
//
//
//  Created by Ihor Kandaurov on 17.11.2021.
//

import Alamofire
import Combine
import Foundation

public protocol ErrorMonitor {
    var failures: PassthroughSubject<APIError, Never> { get set }
    var unauthorized: PassthroughSubject<Void, Never> { get set }
}
