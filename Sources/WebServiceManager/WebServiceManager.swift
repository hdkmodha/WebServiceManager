//
//  WebServiceManager.swift
//
//
//  Created by Hardik Modha on 29/11/23.
//

import UIKit

final class WebServiceManager: Sendable {
    
    static let shared = WebServiceManager()
    
    private init() {}
    
    func fetch<Value: Codable>(resource: WebResource<Value>, configureDecoder: ((JSONDecoder) -> Void)? = nil) async throws -> Result<Value, Error> {
        
        guard let url = resource.url else {
            assertionFailure("Provide valid url")
            return .failure(NetworkError.invalidURL(resource.url?.absoluteString ?? ""))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = resource.httpMethod.description
        
        if let parameters = resource.httpMethod.parameter {
            request.httpBody = parameters.toData
        }
        
        if let header = resource.header {
            request.allHTTPHeaderFields = header
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }
            print("Response: \(httpResponse)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(ServerStatus(rawValue: httpResponse.statusCode) ?? .internalServerError)
            }
            
            do {
                let decoder = Coders.jsonDecoder
                configureDecoder?(decoder)
                let result = try decoder.decode(Value.self, from: data)
                return .success(result)
            } catch let error as DecodingError {
                print(decodingError(error: error))
                return .failure(NetworkError.canNotParse(decodingError(error: error)))
            }
        } catch {
            print("Request Error: \(error.localizedDescription)")
            return .failure(ServerStatus.badRequest)
        }
        
    }
    
    private func decodingError(error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            """
            Decoding Error: Type mismatch for type \(type)
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .valueNotFound(let type, let context):
            """
            Decoding Error: Value of type \(type) not found
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .keyNotFound(let codingKey, let context):
            """
            Decoding Error: Key '\(codingKey.stringValue)' not found
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .dataCorrupted(let context):
            """
            Decoding Error: Data corrupted
            Context: \(context.debugDescription)
                Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        @unknown default:
            """
            Unknown error: \(error.localizedDescription)
            """
        }
    }
}
