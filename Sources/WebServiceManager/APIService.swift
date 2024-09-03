//
//  APIService.swift
//
//
//  Created by Hardik Modha on 30/11/23.
//

import Foundation

public protocol APIService: Sendable {
    var base: String { get }
    var scheme: String { get }
    var fixed: String { get }
    var port: Int? { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var url: URL? { get }
}

public extension APIService {
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.base
        urlComponents.port = self.port
        urlComponents.queryItems = self.queryItems
        urlComponents.path = self.fixed.isEmpty ? self.path : self.fixed + path
        return urlComponents.url
    }
}
