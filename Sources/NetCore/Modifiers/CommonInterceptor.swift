//
//  CommonInterceptor.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Combine
import Foundation

// Example
final class CommonInterceptor: Alamofire.RequestInterceptor {
    private let token: String?

    init(_ token: String? = nil) {
        self.token = token
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.timeoutInterval = 5

        completion(.success(urlRequest))
    }
}
