//
//  RequestProvider.swift
//
//
//  Created by Ihor Kandaurov on 25.08.2021.
//

import Alamofire
import Combine
import Foundation

public class RequestProvider: RequestService {
    public let session: Session
    public let repository: RepositoryProtocol

    private let responseQueue = DispatchQueue(
        label: "\(Bundle.main.bundleIdentifier ?? "App").responseQueue",
        qos: .utility
    )

    private let requestQueue = DispatchQueue(
        label: "\(Bundle.main.bundleIdentifier ?? "App").requestQueue",
        qos: .utility
    )

    private let authInterceptor: AuthenticationInterceptor<SAuthenticator>
    private let serializer: Serializer

    public init(repository: RepositoryProtocol) {
        self.repository = repository

        serializer = Serializer()
        authInterceptor = .init(authenticator: SAuthenticator(
            serializer: serializer,
            repository: repository
        ))
        session = Session(
            requestQueue: requestQueue,
            serializationQueue: responseQueue
        )
    }

    public func send<Response>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        return createRequest(
            route: route,
            responseType,
            interceptors: [CommonInterceptor()]
        )
    }

    public func sendAuthorized<Response>(
        _ responseType: Response.Type,
        route: Routable
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        updateCredentials()

        return createRequest(
            route: route,
            responseType,
            interceptors: [CommonInterceptor(), authInterceptor]
        )
    }

    public func uploadAuthorized<Response>(
        _ responseType: Response.Type,
        route: Routable,
        data: Data,
        name: String
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        updateCredentials()

        let urlBuilder = URLBuilder(configuration: repository.apiConfiguration, route: route)
        return session
            .upload(
                multipartFormData: {
                    $0.append(data, withName: name, fileName: "\(name).jpeg", mimeType: "image/jpeg")
                },
                with: urlBuilder,
                usingThreshold: .init(),
                interceptor: Interceptor(interceptors: [authInterceptor])
            )
            .cURLDescription { self.repository.logger.request(url: urlBuilder.urlRequest?.url, message: $0) }
            .responseData { self.repository.logger.response($0) }
            .publishData()
            .receive(on: responseQueue)
            .setFailureType(to: APIError.self)
            .flatMap { self.serializer.serialize($0, responseType: Response.self, decoder: route.decoder) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.repository.errorMonitor.failures.send(error)
                }
            })
            .eraseToAnyPublisher()
    }

    private func updateCredentials() {
        guard let accessToken = repository.securityStorage.accessToken,
              let refreshToken = repository.securityStorage.refreshToken,
              let lastRefreshDate = repository.securityStorage.lastRefreshDate
        else { return }

        let credential = AuthCredential(
            accessToken: accessToken,
            refreshToken: refreshToken,
            lastRefreshDate: lastRefreshDate
        )
        authInterceptor.credential = credential
    }

    private func createRequest<Response>(
        route: Routable,
        _ responseType: Response.Type,
        interceptors: [RequestInterceptor]
    ) -> AnyPublisher<Response, APIError> where Response: Decodable {
        let urlBuilder = URLBuilder(configuration: repository.apiConfiguration, route: route)
        return session
            .request(urlBuilder, interceptor: Interceptor(interceptors: interceptors))
            .cURLDescription { self.repository.logger.request(url: urlBuilder.urlRequest?.url, message: $0) }
            .responseData { self.repository.logger.response($0) }
            .publishData()
            .receive(on: responseQueue)
            .setFailureType(to: APIError.self)
            .flatMap { self.serializer.serialize($0, responseType: Response.self, decoder: route.decoder) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.repository.errorMonitor.failures.send(error)
                }
            })
            .eraseToAnyPublisher()
    }
}
