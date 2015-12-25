//
//  FaceDetector.swift
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

import Foundation

class FaceDetector {
    private static let sharedFaceDetector = GCFaceDetector()
    
    class func processImage(image: UIImage, completionHandler: (faceImages: [UIImage]) -> ()) {
        sharedFaceDetector.processImage(image) { (faces) -> Void in
            completionHandler(faceImages: faces as! [UIImage])
        }
    }
}