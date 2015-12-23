//
//  GCFaceRecognizer.h
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GCFaceRecognizer : NSObject

- (NSString *)predict:(UIImage*)image confidence:(double *)confidence;
- (void)updateWithFace:(UIImage *)img name:(NSString *)name;

@end
