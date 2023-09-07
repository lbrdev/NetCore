import Alamofire
import Foundation

public protocol SecurityStorageProtocol: AnyObject {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var lastRefreshDate: Date? { get }
}

class SAuthenticator: Authenticator {
    private let repository: RepositoryProtocol
    private let serializer: Serializer

    init(
        serializer: Serializer,
        repository: RepositoryProtocol
    ) {
        self.serializer = serializer
        self.repository = repository
    }

    func apply(_ credential: AuthCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }

    func refresh(
        _ credential: AuthCredential,
        for session: Session,
        completion: @escaping (Result<AuthCredential, Error>) -> Void
    ) {
        let urlBuilder = URLBuilder(
            configuration: repository.apiConfiguration,
            route: RefreshRoute(token: credential.refreshToken)
        )

        AF.request(urlBuilder, interceptor: CommonInterceptor(credential.accessToken))
            .cURLDescription { [weak self] message in
                self?.repository.logger.request(url: urlBuilder.urlRequest?.url, message: message)
            }
            .responseData { [weak self] responseData in
                self?.repository.logger.response(responseData)
                self?.serializer.serialize(
                    responseData,
                    responseType: Response.Authorization.self,
                    decoder: JSONDecoder()
                ) { result in
                    switch result {
                    case let .success(response):
                        let responseDate = Date()
                        self?.repository.securityStorage.accessToken = response.accessToken
                        self?.repository.securityStorage.refreshToken = response.refreshToken
                        let newCred = AuthCredential(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken,
                            lastRefreshDate: responseDate
                        )
                        completion(.success(newCred))
                    case let .failure(error):
                        if error.sError?.message == Cause.invalidRefreshToken.rawValue {
                            self?.repository.errorMonitor.unauthorized.send()
                        }

                        completion(.failure(error))
                    }
                }
            }
    }

    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        return response.statusCode == 401
    }

    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: AuthCredential) -> Bool {
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }
}
