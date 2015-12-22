//
//  ViewController.swift
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let testImage = UIImage(named: "test")!
        let faceDetector = GCFaceDetector(image: testImage)
        faceDetector.processImageWithCompletionHandler { (faces) -> Void in
            print("Nr of faces detected: \(faces.count)")
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            
            print("\(documentsPath)")

            var counter = 0
            for face in faces {
                let destinationPath = documentsPath.stringByAppendingPathComponent("img\(counter).jpg")
                UIImageJPEGRepresentation(face as! UIImage, 1.0)!.writeToFile(destinationPath, atomically: true)
                counter++
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

