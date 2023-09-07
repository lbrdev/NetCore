//
//  URLBuilder.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Foundation

public struct URLBuilder: URLRequestConvertible {
    public let configuration: ApiConfig?
    public let route: Routable?
    public let url: URL?

    public init(
        configuration: ApiConfig,
        route: Routable
    ) {
        self.configuration = configuration
        self.route = route
        url = nil
    }

    public init(url: URL) {
        self.url = url
        configuration = nil
        route = nil
    }

    public func asURLRequest() throws -> URLRequest {
        let components = urlComponents(by: route)
        let requestUrl = components?.url ?? url

        guard let requestUrl else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: requestUrl)
        route?.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.name) }
        urlRequest.httpBody = route?.body
        urlRequest.httpMethod = (route?.method ?? .get).rawValue

        return urlRequest
    }

    public func urlComponents(by route: Routable?) -> URLComponents? {
        guard let route, let configuration else { return nil }

        var components = URLComponents()
        components.scheme = configuration.scheme
        components.host = configuration.host
        components.port = configuration.port
        components.path = (route.apiVersion ?? "") + route.endpoint + route.path
        components.queryItems = queryItems(by: route.queryParameters)

        return components
    }

    private func queryItems(by parameters: [String: CustomStringConvertible]?) -> [URLQueryItem]? {
        return parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value.description) }
    }
}
