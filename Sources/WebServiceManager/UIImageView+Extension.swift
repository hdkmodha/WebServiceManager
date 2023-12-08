//
//  File.swift
//  
//
//  Created by Hardik Modha on 30/11/23.
//

import UIKit
import AlamofireImage

public extension UIImageView {
    
    func setImage(with string: String?, placeholderImage: UIImage?, completion: (() -> ())? = nil) {
        guard let validString = string, let url = validString.toURL else {
            self.image = placeholderImage
            return
        }
        self.af.setImage(withURL: url, placeholderImage: placeholderImage, completion:  { result in
            completion?()
        })
    }
    
    func cancleRequest() {
        self.af.cancelImageRequest()
    }
}

