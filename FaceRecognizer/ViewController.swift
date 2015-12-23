//
//  ViewController.swift
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == PHAuthorizationStatus.Authorized {
            //self.loadAllSelfies()
            
            let testImage = UIImage(named: "test2")
            let faceDetector = GCFaceDetector(image: testImage)
            let faceRecognizer = GCFaceRecognizer()
            
            faceDetector.processImageWithCompletionHandler({ (faces) -> Void in
                for face in faces as! [UIImage] {
                    var confidence = 0.0
                    let name = faceRecognizer.predict(face, confidence: &confidence)
                    if confidence > 0 {
                        print("\(name): \(confidence)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imageView.image = face
                        })
                    }
                    
                    
                    
                    
                }
            })
            
        } else {
            self.requestPhotoAccess()
        }
        
    }
    
    func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue(), {
                switch(status) {
                case .Authorized:
                    print("[Photos] AUTHORIZATION HAS BEEN GRANTED")
                case .Denied:
                    print("[Photos] AUTHORIZATION HAS BEEN DENIED")
                default: break
                }
            })
        })
    }
    
    func loadAllSelfies() {
        let faceRecognizer = GCFaceRecognizer()
        
        let albums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumSelfPortraits, options: nil)
        for index in 0..<albums.count {
            let assetCollection = albums.objectAtIndex(index) as! PHAssetCollection
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
            print("Nr of images: \(fetchResult.count)")
            
            for i in 0...100 {
                if let asset = fetchResult.objectAtIndex(i) as? PHAsset {
                    asset.requestContentEditingInputWithOptions(nil) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                        // Get the full image
                        let image = contentEditingInput!.displaySizeImage
                        
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.imageView.image = image
                            })
                            
                            let faceDetector = GCFaceDetector(image: image)
                            
                            faceDetector.processImageWithCompletionHandler { (faces) -> Void in
                                if faces.count == 1 {
                                    print("alone: \(i)")
                                    let faceImage = faces.first!
                                    faceRecognizer.updateWithFace(faceImage as! UIImage, name: "Stefan")
                                } else {
                                    print("not alone: \(i)")
                                }
                            }
                        } else {
                            print("image is nil: \(i)")
                        }
                    }
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

