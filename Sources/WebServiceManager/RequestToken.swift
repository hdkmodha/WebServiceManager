//
//  RequestToken.swift
//
//
//  Created by Hardik Modha on 30/11/23.
//

import Foundation
import Alamofire

public struct RequestToken {
    let task: DataRequest
    
    init(task: DataRequest) {
        self.task = task
    }
    
    func cancel() {
        self.task.cancel()
    }
}
