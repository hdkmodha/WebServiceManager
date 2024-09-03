//
//  File.swift
//  
//
//  Created by Hardik Modha on 01/12/23.
//

import Foundation

public extension URL {
    
    var fileName: String {
        return self.deletingPathExtension().lastPathComponent
    }
    
    var fileExtension: String {
        return self.pathExtension
    }
    
    var fileNameWithExtension: String {
        return fileName + " " + fileExtension
    }
}

public enum MediaType: String {
    case jpg
    case png
    case doc
    case jpeg
}

extension MediaType {
    public var mimeType: String {
        switch self {
        case .png:
            return "image/png"
        case .jpg, .jpeg:
            return "image/jpeg"
        case .doc:
            return "application/msword"
        }
    }
}

extension MediaType {
   public static func generateMimeType(key: String, value: Any) -> (url: URL?, mimeType: String) {
        if let url = value as? URL {
            guard let mediaType = MediaType(rawValue: url.fileExtension.lowercased()) else {
                return (nil, "")
            }
            return (value as? URL, mediaType.mimeType)
        }
        return (nil, "")
    }
}
