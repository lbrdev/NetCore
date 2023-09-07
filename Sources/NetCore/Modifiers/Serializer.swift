//
//  Serializer.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Combine
import Foundation

public struct Serializer {
    public func serialize<Response>(
        _ output: DataResponsePublisher<Data>.Output,
        responseType: Response.Type,
        decoder: JSONDecoder
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        return Future<Response, APIError> { promise in
            self.serialize(
                output,
                responseType: responseType,
                decoder: decoder) { result in
                    switch result {
                    case let .success(value):
                        promise(.success(value))
                    case let .failure(error):
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }

    public func serialize<Response>(
        _ output: DataResponsePublisher<Data>.Output,
        responseType: Response.Type,
        decoder: JSONDecoder,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) where Response: Decodable {
        Delegate(
            output: output,
            decoder: decoder,
            completion: completion
        ).serialize()
    }
}

private extension Serializer {
    struct Delegate<Response> where Response: Decodable {
        let output: DataResponsePublisher<Data>.Output
        let decoder: JSONDecoder
        let completion: (Result<Response, APIError>) -> Void

        func serialize() {
            switch output.response?.statusCode {
            case (200 ..< 300)?:
                onSuccess()
            default:
                completion(.failure(.init(output: output)))
            }
        }
    }
}

private extension Serializer.Delegate {
    // Check if we have any response at all
    func onSuccess() {
        guard let data = output.data ?? "{}".data(using: .utf8), !data.isEmpty else {
            completion(.failure(.init(output: output)))
            return
        }

        do {
            // Trying to parse to our object
            completion(.success(try decoder.decode(Response.self, from: data)))
        } catch let error {
            // Something went wrong and data corrupted
            if case let decodingError as DecodingError = error {
                print(decodingError.debugString)
                completion(.failure(.init(output: output, decodingError: decodingError)))
            } else {
                completion(.failure(.init(output: output)))
            }
        }
    }
}
