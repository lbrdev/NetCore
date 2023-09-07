//
//  APIError.swift
//  CoreAPI
//
//  Created by Ihor Kandaurov on 03.01.2023.
//

import Alamofire
import Foundation

public struct APIError: Error {
    public let statusCode: Int?
    public let afError: AFError?
    /// Ошибка, возвращенная нашим собственным сервером ``Swanly``
    public let sError: SError?
    public let decodingError: DecodingError?

    public init(
        statusCode: Int? = nil,
        afError: AFError? = nil,
        sError: SError? = nil,
        decodingError: DecodingError? = nil
    ) {
        self.statusCode = statusCode
        self.afError = afError
        self.sError = sError
        self.decodingError = decodingError
    }

    public init(
        output: DataResponsePublisher<Data>.Output,
        decodingError: DecodingError? = nil
    ) {
        statusCode = output.response?.statusCode
        afError = output.error
        if let data = output.data {
            let decoded = try? JSONDecoder().decode(SError.self, from: data)
            sError = decoded
        } else {
            sError = nil
        }
        self.decodingError = nil
    }
}

public extension APIError {
    /// Internet connection hasn’t been established and can’t be established automatically
    var isNetworkConnection: Bool {
        // В URLError много ошибок, но мы обрабатываем только networkConnectionLost, notConnectedToInternet и т.п.
        // Остальные попадают под общую гребенку и обрабатываются аналогичным образом.
        // При желании можно сделать проверку через switch
        afError?.underlyingError is URLError || afError?.isSessionTaskError == true || afError?.isRequestAdaptationError == true
    }
}
