//
//  File.swift
//  
//
//  Created by Hardik Modha on 09/12/23.
//

import Foundation

enum Constants {
    
    enum ErrorMessage {
        static let successMessage = "Everything worked as expected"
        static let badRequestMessage = "The request was unacceptable, often due to missing a required parameter."
        static let invalidTokenMessage = "Invalid Access Token"
        static let forbiddenMessage = "Missing permissions to perform request"
        static let notFoundMessage = "The requested resource doesn’t exist"
        static let internalServerError = "Server Not Found"
        static let serviceUnavailableMessage = "Something went wrong on our end"
        static let jsonNotParseMessage = "Response can not parse"
        static let unExpectedValueMessage = "Unexpected value come from the API"
    }
}
