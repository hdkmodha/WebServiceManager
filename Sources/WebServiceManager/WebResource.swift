//
//  WebResource.swift
//
//
//  Created by Hardik Modha on 30/11/23.
//

import Foundation


public typealias JSONType = (any Encodable & Sendable)
public typealias HTTPHeaders = [String: String]
public typealias Progress = @Sendable (Double) -> Void

public typealias ResponseCodable = Codable & Sendable

public enum HTTPMethod: CustomStringConvertible, Sendable {
    case get
    case post(JSONType)
    case put(JSONType)
    case delete
    
    public var parameter: (any Encodable & Sendable)? {
        switch self {
        case .get, .delete:
            return nil
        case .post(let parameter), .put(let parameter):
            return parameter
        }
    }
    
    public var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}

public enum ServerStatus: Int, CustomStringConvertible, Error, Sendable {
    case success = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case internalServerError = 500
    case serviceUnavailable = 503
    
    public var errorCode: Int {
        return self.rawValue
    }
    
    public var description: String {
        switch self {
        case .success:
            return Constants.ErrorMessage.successMessage
        case .badRequest:
            return Constants.ErrorMessage.badRequestMessage
        case .unauthorized:
            return Constants.ErrorMessage.invalidTokenMessage
        case .forbidden:
            return Constants.ErrorMessage.forbiddenMessage
        case .notFound:
            return Constants.ErrorMessage.notFoundMessage
        case .internalServerError:
            return Constants.ErrorMessage.internalServerError
        case .serviceUnavailable:
            return Constants.ErrorMessage.serviceUnavailableMessage
        }
    }
}

enum NetworkError: Error, CustomStringConvertible {
    case invalidURL(String)
    case invalidResponse
    case canNotParse(String)
    case unExpectedValue
    
    var description: String {
        switch self {
        case .invalidURL(let string):
            return string
        case .invalidResponse:
            return "invalid response"
        case .canNotParse(let error):
            return error
        case .unExpectedValue:
            return Constants.ErrorMessage.unExpectedValueMessage
        }
    }
}

public struct WebResource<Value: Codable> {
    
    let path: APIService
    var httpMethod: HTTPMethod
    var header: HTTPHeaders?
    
    var url: URL? { return self.path.url }
    
    public init(
        path: APIService,
        httpMethod: HTTPMethod = .get,
        header: HTTPHeaders? = nil
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.header = header
    }
    
    public func request() async throws -> Result<Value, Error>  {
        return try await WebServiceManager.shared.fetch(resource: self)
    }
    
//    func uploadRequest(progress: Progress?, completion: @escaping @Sendable (Result<Value, ServerStatus>) -> Void) async  {
//        await WebServiceManager.shared.postResource(self, progressCompletion: progress, completion: completion)
//    }
    
}
