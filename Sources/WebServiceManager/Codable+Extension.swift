//
//  File.swift
//  
//
//  Created by Hardik Modha on 30/11/23.
//

import Foundation

enum Coders {
    static let jsonDecoder = JSONDecoder()
    static let jsonEncoder = JSONEncoder()
}

public extension Decodable {
    static func decode<A: Codable>(_ data: Data) -> Result<A, ServerStatus> {
        do {
            let decoder = Coders.jsonDecoder
            let result = try decoder.decode(A.self, from: data)
            return .success(result)
        } catch  {
            print(error.localizedDescription)
            return .failure(.unExpectedValue)
        }
    }
}

public extension Encodable {
    var jsonData: Data {
        get throws {
            try Coders.jsonEncoder.encode(self)
        }
    }
}


extension Encodable {
    var toJSON: [String: Any] {
        do {
            let data = try self.jsonData
            let dictioanry = try JSONSerialization.jsonObject(with: data)
            return dictioanry as? [String : Any] ?? [:]
        } catch {
            return [:]
        }
    }
}
