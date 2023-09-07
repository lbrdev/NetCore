//
//  NetworkLogger.swift
//  CoreAPI
//
//  Created by Ihor Kandaurov on 31.12.2022.
//

import Alamofire
import Foundation

public protocol NetworkLogger {
    func request(url: URL?, message: String?)
    func response(_ response: AFDataResponse<Data>)
}
