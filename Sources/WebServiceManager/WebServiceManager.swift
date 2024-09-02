//
//  WebServiceManager.swift
//
//
//  Created by Hardik Modha on 29/11/23.
//

import UIKit
import Alamofire

final class WebServiceManager {
    
    static let shared = WebServiceManager()
    
    private init() {}
    
    static var isReachable: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    lazy var session: Session = {
        let configure = URLSessionConfiguration.ephemeral
        configure.httpCookieStorage = nil
        configure.httpCookieAcceptPolicy = .never
        configure.httpShouldSetCookies = false
        let session = Session(configuration: configure)
        return session
    }()
    
    
    func fetch<Value>(resource: WebResource<Value>) async throws -> Value {
        return try await withCheckedThrowingContinuation { continuation in
            let _ = self.fetching(resource: resource) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let serverStatus):
                    continuation.resume(throwing: serverStatus)
                }
            }
        }
    }
    
    private func fetching<Value>(resource: WebResource<Value>, witnCompletion completion: @escaping (Result<Value, ServerStatus>) -> Void) -> RequestToken? {
        
        guard let url = resource.url else {
            assertionFailure("Provide valid url")
            return nil
        }
        
        var headers: HTTPHeaders?
        let parameter = resource.httpMethod.parameter
        let method = resource.httpMethod.method
        
        if let header = resource.header {
            headers = HTTPHeaders(header)
        }
        
        print("------------ API Details ---------------")
        print("API URL: \(url)")
        print("API Method: \(resource.httpMethod.description)")
        print("API Parameter: \(String(describing: parameter))")
        print("API Headers: \(String(describing: headers))")
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems {
            for value in queryItems.enumerated() {
                print("Parameter Key: \(value.element.name) and Paramenter Value: \(String(describing: value.element.value))")
            }
        }
        
        let dataTask  = self.session.request(url, method: method, parameters: parameter, encoding: URLEncoding.default, headers: headers, interceptor: nil).responseData { (response) in
            
            self.processResponse(response: response, decode: resource.decode, completion: completion)
            
        }
        
        return RequestToken(task: dataTask)
        
    }
    
    private func processResponse<Value>(response: AFDataResponse<Data>, decode: (Data) -> Result<Value, ServerStatus>, completion: @escaping (Result<Value, ServerStatus>) -> Void) {
        
        
        guard let httpResponse = response.response else {
            completion(.failure(.internalServerError))
            return
        }
        
        if let serverStatus = ServerStatus(rawValue: httpResponse.statusCode) {
            switch serverStatus {
            case .success:
                switch response.result {
                case .success(let data):
                    completion(decode(data))
                case .failure:
                    completion(.failure(.forbidden))
                }
            default:
                completion(.failure(serverStatus))
            }
            
        }
        
        
    }
    
    
    func postResource<Value>(_ resource: WebResource<Value>, progressCompletion: ((Double)->Void)?, completion: @escaping (Result<Value, ServerStatus>)->Void)  {
        guard let url = resource.url else {
            completion(.failure(.unExpectedValue))
            return
        }
        
        let parameter = resource.httpMethod.parameter
        let headers = HTTPHeaders(resource.header ?? [:])
        let method = resource.httpMethod.method
        
        print("------------ API Details ---------------")
        print("API URL: \(url)")
        print("API Method: \(resource.httpMethod.description)")
        print("API Parameter: \(String(describing: parameter))")
        print("API Headers: \(String(describing: headers))")
        
        
        
        let prepareFormData: (MultipartFormData)->Void = { (multipartFormData) in
            guard let parameters = parameter else { return }
            
            for (key, value) in parameters {
                let (url, mimeType) = MediaType.generateMimeType(key: key, value: value)
                if let url = url {
                    multipartFormData.append(url, withName: key, fileName: url.fileNameWithExtension, mimeType: mimeType)
                }
                else if
                    let stringValue = value as? String,
                    let data = stringValue.data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: key)//, mimeType: "text/plain")
                }
                else if
                    let bool = value as? Bool,
                    let data = String(bool).data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: key)//, mimeType: "text/plain")
                }
                else if let int = value as? NSNumber {
                    let data = int.stringValue.data(using: String.Encoding.utf8)
                    multipartFormData.append(data!, withName: key)//, mimeType: "text/plain")
                } else if let data = value as? [URL] {
                    for value in data {
                        let (url, mimeType) = MediaType.generateMimeType(key: key, value: value)
                        if let url = url {
                            multipartFormData.append(url, withName: key, fileName: url.fileNameWithExtension, mimeType: mimeType)
                        }
                    }
                } else if let data = value as? [UIImage] {
                    for image in data {
                        let imagData = image.jpegData(compressionQuality: 0.5)!
                        let name = "image\(Date().timeIntervalSince1970).jpg"
                        
                        multipartFormData.append(imagData, withName: key, fileName: name, mimeType: "image/jpg")
                    }
                } else {
                    print("Unable to add form data for key: '\(key)'.")
                }
            }
        }
        
        self.session.upload(multipartFormData: prepareFormData, to: url, method: method, headers: headers)
            .uploadProgress(closure: { (progress) in
                progressCompletion?(progress.fractionCompleted)
            })
        
            .downloadProgress(closure: { (progress) in
                progressCompletion?(progress.fractionCompleted)
            })
        
            .responseData(completionHandler: { (response) in
                self.processResponse(response: response, decode: resource.decode, completion: completion)
            })
        
    }
}
