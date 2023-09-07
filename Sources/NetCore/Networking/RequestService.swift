//
//  RequestService.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Combine
import Foundation

public protocol RequestService {
    func send<Response>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> where Response: Decodable

    func sendAuthorized<Response>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> where Response: Decodable

    func uploadAuthorized<Response>(
        _ responseType: Response.Type,
        route: Routable,
        data: Data,
        name: String
    ) -> AnyPublisher<Response, APIError> where Response: Decodable
}
