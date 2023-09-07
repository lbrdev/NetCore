//
//  Routable+Encoder.swift
//
//
//  Created by Ihor Kandaurov on 21.10.2021.
//

import Foundation

public extension Routable {
    func encode<T>(_ encodable: T) -> Data? where T: Encodable {
        do {
            return try encoder.encode(encodable)
        } catch {
            print("Unable to encode request body \(encodable)")
            return nil
        }
    }

    func decode<T>(_ data: Data) -> T? where T: Decodable {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Unable to decode response data")
            return nil
        }
    }
}
