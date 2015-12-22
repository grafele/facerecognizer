//
//  GCFaceDetector.h
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^GCFaceDetectorCompletionBlock)(NSArray* detectedFaces);

@interface GCFaceDetector : NSObject

- (instancetype)initWithImage:(UIImage *)image;
- (void)processImageWithCompletionHandler:(GCFaceDetectorCompletionBlock)completionHandler;

@end
