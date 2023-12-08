//
//  WebResource.swift
//
//
//  Created by Hardik Modha on 30/11/23.
//

import Foundation
import Alamofire

public typealias JSONType = [String: Any]
public typealias Header = [String: String]
public typealias Progress = (Double) -> Void


public enum HTTPMethod {
    case get
    case post(JSONType)
    case put(JSONType)
    case delete
    
    public var parameter: JSONType? {
        switch self {
        case .get, .delete:
            return nil
        case .post(let parameter), .put(let parameter):
            return parameter
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .get:
            return .get
        case .delete:
            return .delete
        case .post:
            return  .post
        case .put:
            return .put
        }
    }
}

public enum ServerStatus: Int, CustomStringConvertible, Error {
    case success = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case internalServerError = 500
    case serviceUnavailable = 503
    case canNotParse = 0
    case unExpectedValue = 1
    
    
    public var description: String {
        switch self {
        case .success:
            return "Everything worked as expected"
        case .badRequest:
            return "The request was unacceptable, often due to missing a required parameter."
        case .unauthorized:
            return "Invalid Access Token"
        case .forbidden:
            return "Missing permissions to perform request"
        case .notFound:
            return "The requested resource doesn’t exist"
        case .internalServerError:
            return "Server Not Found"
        case .serviceUnavailable:
            return "Something went wrong on our end"
        case .canNotParse:
            return "Response can not parse"
        case .unExpectedValue:
            return "Unexpected value come from the API"
        }
    }
}



public struct WebResource<Value> {
    
    var path: APIService
    var httpMethod: HTTPMethod = .get
    var header: Header?
    var decode: (Data) -> Result<Value, ServerStatus>
    
    var url: URL? {
        return self.path.url
    }
    
    public init(path: APIService, httpMethod: HTTPMethod, header: Header? = nil, decode: @escaping (Data) -> Result<Value, ServerStatus>) {
        self.path = path
        self.httpMethod = httpMethod
        self.header = header
        self.decode = decode
    }
    
    @discardableResult
    public func request(completion: @escaping (Result<Value, ServerStatus>) -> Void)  -> RequestToken? {
        return WebServiceManager.shared.fetch(resource: self, witnCompletion: completion)
    }
    
    func uploadRequest(progress: Progress?, completion: @escaping (Result<Value, ServerStatus>) -> Void)  {
        WebServiceManager.shared.postResource(self, progressCompletion: progress, completion: completion)
    }
    
}






