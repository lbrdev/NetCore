//
//  DecodingError+.swift
//
//
//  Created by Ihor Kandaurov on 26.08.2021.
//

import Foundation

public extension DecodingError {
    var debugString: String {
        switch self {
        case let .keyNotFound(codingKey, context):
            return handleKeyNotFound(codingKey: codingKey, context: context)
        case let .typeMismatch(_, context):
            return handleTypeMismatch(context: context)
        case let .valueNotFound(_, context):
            return handleValueNotFound(context: context)
        case let .dataCorrupted(context):
            return handleDataCorrupted(context: context)
        default:
            return defaultHandler()
        }
    }

    // MARK: - PRIVATES

    // MARK: Properties

    private var prefix: String {
        return "\n"
    }

    private func handleKeyNotFound(codingKey: CodingKey, context: Context) -> String {
        var str = String()
        str += "\(prefix)KEY NOT FOUND IN HIERARCHY"

        for (index, codingPath) in context.codingPath.enumerated() {
            str += "\(prefix)\("-".repeatFor(index + 1))> \(codingPath.stringValue)"
        }
        str += "\(prefix)\("-".repeatFor(context.codingPath.count + 1))> \(codingKey.stringValue)"

        return str
    }

    private func handleTypeMismatch(context: Context) -> String {
        var str = String()
        str += "\(prefix)TYPE MISMATCH IN HIERARCHY"

        for (index, codingPath) in context.codingPath.enumerated() {
            str += "\(prefix)\("-".repeatFor(index + 1))> \(codingPath.stringValue)"
        }
        str += "\(prefix)\("-".repeatFor(context.codingPath.count + 1))> \(context.debugDescription)"
        return str
    }

    private func handleValueNotFound(context: Context) -> String {
        var str = String()
        str += "\(prefix)VALUE NOT FOUND IN HIERARCHY"

        for (index, codingPath) in context.codingPath.enumerated() {
            str += "\(prefix)\("-".repeatFor(index + 1))> \(codingPath.stringValue)"
        }
        str += "\(prefix)\("-".repeatFor(context.codingPath.count + 1))> \(context.debugDescription)"
        return str
    }

    private func handleDataCorrupted(context: Context) -> String {
        var str = String()
        str += "\(prefix)DATA CORRUPTED"
        str += "\(prefix)-> \(context.debugDescription)"

        guard let error = context.underlyingError else { return str }

        str += "\(prefix)-> \(error.localizedDescription)"

        if let errorMessage = (error as NSError).userInfo[NSDebugDescriptionErrorKey] {
            str += "\(prefix)-> \(errorMessage)"
        }

        return str
    }

    private func defaultHandler() -> String {
        var str = String()
        str += "\(prefix)UNKNOWN ERROR"
        str += localizedDescription
        return str
    }
}

private extension String {
    func repeatFor(_ times: Int) -> String {
        var newString = self

        for _ in 1 ..< times {
            newString += self
        }

        return newString
    }
}
