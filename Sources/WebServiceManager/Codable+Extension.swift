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

public extension Encodable {
    var toData: Data? {
        do {
            let data = try Coders.jsonEncoder.encode(self)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    var toJSON: [String: Any] {
        do {
            let data =  self.toData
            let dictioanry = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            return dictioanry as? [String : Any] ?? [:]
        } catch {
            return [:]
        }
    }
}



