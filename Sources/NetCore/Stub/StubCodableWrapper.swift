//
//  StubCodableWrapper.swift
//
//
//  Created by Ihor Kandaurov on 21.10.2021.
//

import Foundation

public class StubCodableWrapper {
    public var data: Data?

    public init<T: Codable>(_ codable: T) {
        do {
            data = try JSONEncoder().encode(codable)
        } catch {
            print("Unable to encode stubbed response \(codable)")
        }
    }
}
