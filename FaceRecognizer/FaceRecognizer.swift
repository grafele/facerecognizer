//
//  FaceRecognizer.swift
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

import Foundation
import UIKit

class FaceRecognizer {
    private static let sharedFaceRecognizer = GCFaceRecognizer()

    class func addUserPicture(username: String, picture: UIImage) {
        sharedFaceRecognizer.updateWithFace(picture, name: username)
    }
    
    class func predictUserByPicture(picture: UIImage) -> (username: String, confidence: Double) {
        var confidence = 0.0
        let username = sharedFaceRecognizer.predict(picture, confidence: &confidence)
        return (username: username, confidence: confidence)
    }
}