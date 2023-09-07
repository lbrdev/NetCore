//
//  StubbedRequestProvider.swift
//
//
//  Created by Ihor Kandaurov on 26.08.2021.
//

import Alamofire
import Combine
import Foundation
import OHHTTPStubs

public class StubbedRequestProvider: RequestService {
    private let configuration: ApiConfig
    private let session: Alamofire.Session
    private let decoder = JSONDecoder()
    private let serializer = Serializer()

    private let responseQueue = DispatchQueue(
        label: "\(Bundle.main.bundleIdentifier ?? "App").responseQueue",
        qos: .utility
    )

    private let requestQueue = DispatchQueue(
        label: "\(Bundle.main.bundleIdentifier ?? "App").requestQueue",
        qos: .utility
    )

    private let log: NetworkLogger

    public init(
        configuration: ApiConfig,
        log: NetworkLogger
    ) {
        self.configuration = configuration
        self.log = log

        session = Alamofire.Session(
            configuration: .default,
            requestQueue: requestQueue,
            interceptor: Interceptor()
        )
    }

    public func send<Response>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        guard let route = route as? (Routable & Stubable) else {
            return Fail<Response, APIError>(error: .init(statusCode: 404))
                .eraseToAnyPublisher()
        }
        guard !route.stubDataType.isNone else {
            return Fail<Response, APIError>(error: .init(statusCode: 404))
                .eraseToAnyPublisher()
        }

        let urlBuilder = URLBuilder(configuration: configuration, route: route)
        let url = try? urlBuilder.asURLRequest().url
        let host: String
        if #available(iOS 16.0, *) {
            host = url?.host(percentEncoded: false) ?? ""
        } else {
            host = url?.host ?? ""
        }
        let urlString = url?.absoluteString ?? ""

        stub(condition: isHost(host)) { _ in
            switch route.stubDataType {
            case let .fromFile(name):
                let path = OHPathForFile(name, type(of: self))
                return HTTPStubsResponse(
                    fileAtPath: path!,
                    statusCode: Int32(route.stubStatusCode ?? 200),
                    headers: route.stubHeaders
                ).requestTime(
                    route.stubRequestTime ?? 0,
                    responseTime: route.stubResponseTime ?? 0
                )
            case let .fromJSON(json):
                return HTTPStubsResponse(
                    jsonObject: json,
                    statusCode: Int32(route.stubStatusCode ?? 200),
                    headers: route.stubHeaders
                ).requestTime(
                    route.stubRequestTime ?? 0,
                    responseTime: route.stubResponseTime ?? 0
                )
            case let .fromString(string):
                return HTTPStubsResponse(
                    data: string.data(using: .utf8) ?? Data(),
                    statusCode: Int32(route.stubStatusCode ?? 200),
                    headers: route.stubHeaders
                ).requestTime(
                    route.stubRequestTime ?? 0,
                    responseTime: route.stubResponseTime ?? 0
                )
            case let .fromCodable(wrapper):
                return HTTPStubsResponse(
                    data: wrapper.data ?? .init(),
                    statusCode: Int32(route.stubStatusCode ?? 200),
                    headers: nil
                ).requestTime(
                    route.stubRequestTime ?? 0,
                    responseTime: route.stubResponseTime ?? 0
                )
            case .none, .justError:
                return HTTPStubsResponse(
                    data: .init(),
                    statusCode: Int32(route.stubStatusCode ?? 200),
                    headers: nil
                ).requestTime(
                    route.stubRequestTime ?? 0,
                    responseTime: route.stubResponseTime ?? 0
                )
            }
        }

        let cancellable = session
            .request(urlBuilder)
            .cURLDescription { self.log.request(url: URL(string: urlString), message: $0) }
            .responseData { self.log.response($0) }
            .publishData()
            .setFailureType(to: APIError.self)
            .flatMap { output -> AnyPublisher<Response, APIError> in
                if case let .justError(error) = route.stubDataType {
                    return Fail<Response, APIError>(error: error).eraseToAnyPublisher()
                } else {
                    return self.serializer.serialize(output, responseType: Response.self, decoder: self.decoder)
                }
            }
            .eraseToAnyPublisher()

        return cancellable
    }

    public func sendAuthorized<Response: Decodable>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> {
        return send(responseType, route: route)
    }

    public func uploadAuthorized<Response>(
        _ responseType: Response.Type,
        route: Routable,
        data: Data,
        name: String
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        return send(responseType, route: route)
    }
}
