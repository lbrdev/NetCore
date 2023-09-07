//
//  Stubable.swift
//
//
//  Created by Ihor Kandaurov on 26.08.2021.
//

import Alamofire
import Foundation

public protocol Stubable {
    var stubDataType: StubDataType { get }
    var stubStatusCode: Int? { get }
    var stubHeaders: [AnyHashable: Any]? { get }
    var stubRequestTime: TimeInterval? { get }
    var stubResponseTime: TimeInterval? { get }
}

public extension Stubable {
    var stubDataType: StubDataType {
        return .none
    }

    var stubStatusCode: Int? { return nil }
    var stubHeaders: [AnyHashable: Any]? { return nil }
    var stubRequestTime: TimeInterval? { return nil }
    var stubResponseTime: TimeInterval? { return nil }
}

public enum StubDataType {
    case justError(APIError)
    case fromFile(name: String)
    case fromJSON([String: Any] = [:])
    case fromCodable(StubCodableWrapper)
    case fromString(String)
    case none

    public var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
}
