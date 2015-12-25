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
            //self.loadSomePicturesOfStefan()
            self.testPrediction()
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
    
    func loadAllSelfies(completionHandler: (images: [UIImage]) -> ()) {
        var images = [UIImage]()
        
        let albums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumSelfPortraits, options: nil)
        for index in 0..<albums.count {
            let assetCollection = albums.objectAtIndex(index) as! PHAssetCollection
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
            
            var counter = 0
            let nrElements = 100
            print("Nr of images: \(fetchResult.count)")
            
            for i in 0..<nrElements {
                if let asset = fetchResult.objectAtIndex(i) as? PHAsset {
                    asset.requestContentEditingInputWithOptions(nil) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                        // Get the full image
                        let image = contentEditingInput!.displaySizeImage
                        
                        if image != nil {
                            FaceDetector.processImage(image, completionHandler: { (faceImages) -> () in
                                counter++
                                if faceImages.count == 1 {
                                    print("alone: \(i)")
                                    let faceImage = faceImages.first!
                                    FaceRecognizer.addUserPicture("Stefan", picture: faceImage)
                                    images.append(faceImage)
                                }
                                
                                if counter == 100 {
                                    completionHandler(images: images);
                                }
                            })
                        }
                    }
                }
            }
        }

    }
    
    func loadSomePicturesOfStefan() {
        let stefan1 = UIImage(named: "stefan1")
        let stefan2 = UIImage(named: "stefan2")
        let stefan3 = UIImage(named: "stefan3")
        let stefan4 = UIImage(named: "stefan4")
        let stefan5 = UIImage(named: "stefan5")
        let stefan6 = UIImage(named: "stefan6")
        let stefan7 = UIImage(named: "stefan7")
        let stefan8 = UIImage(named: "stefan8")
        let stefan9 = UIImage(named: "stefan9")
        let stefan10 = UIImage(named: "stefan10")
        
        let images = [stefan1, stefan2, stefan3, stefan4, stefan5, stefan6, stefan7, stefan8, stefan9, stefan10]

        var counter = 0
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        print("\(documentsPath)")


        for faceImage in images {
            FaceDetector.processImage(faceImage, completionHandler: { (faceImages) -> () in
                if faceImages.count == 1 {
                    let faceImage = faceImages.first!
                    FaceRecognizer.addUserPicture("Stefan", picture: faceImage)
                    
                    let destinationPath = documentsPath.stringByAppendingPathComponent("img\(counter).jpg")
                    UIImageJPEGRepresentation(faceImage, 1.0)!.writeToFile(destinationPath, atomically: true)
                    counter++
                }
            })
        }
    }
    
    func testPrediction() {
        let testImage = UIImage(named: "test2")
        
        FaceDetector.processImage(testImage) { (faceImages) -> () in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            print("\(documentsPath)")
            var counter = 0
            
            for face in faceImages {
                let (username, confidence) = FaceRecognizer.predictUserByPicture(face)
                if confidence > 0 {
                    print("\(username): \(confidence) \(counter)")
                    let destinationPath = documentsPath.stringByAppendingPathComponent("det\(counter).jpg")
                    UIImageJPEGRepresentation(face, 1.0)!.writeToFile(destinationPath, atomically: true)
                    counter++
                }
            }
        }
    }

}

