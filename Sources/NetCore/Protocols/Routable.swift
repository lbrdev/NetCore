//
//  Routable.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Foundation

public protocol Routable {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var apiVersion: String? { get }
    var endpoint: String { get }
    var headers: [Alamofire.HTTPHeader]? { get }
    var queryParameters: [String: CustomStringConvertible]? { get }
    var body: Data? { get }
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
}

public extension Routable {
    var body: Data? {
        return nil
    }

    var apiVersion: String? {
        return nil
    }

    var method: Alamofire.HTTPMethod {
        return .post
    }

    var headers: [Alamofire.HTTPHeader]? {
        return nil
    }

    var queryParameters: [String: CustomStringConvertible]? {
        return nil
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.dateFormatter)
        return encoder
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.dateFormatter)
        return decoder
    }
}

private extension DateFormatter {
    /// DateFormat: ``yyyy-MM-dd'T'HH:mm:ss.SSSZ``
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}
