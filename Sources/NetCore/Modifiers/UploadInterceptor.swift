//
//  UploadInterceptor.swift
//  CoreApi
//
//  Created by Ihor Kandaurov on 24.07.2023.
//

import Alamofire
import Combine
import Foundation

final class UploadInterceptor: Alamofire.RequestInterceptor {
    private let token: String?

    init(_ token: String? = nil) {
        self.token = token
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue("form-data", forHTTPHeaderField: "Content-Type")

        completion(.success(urlRequest))
    }
}
