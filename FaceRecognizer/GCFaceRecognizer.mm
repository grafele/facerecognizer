//
//  GCFaceRecognizer.m
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "GCFaceRecognizer.h"
#import "UIImage+OpenCV.h"

using namespace cv;

@interface GCFaceRecognizer() {
    Ptr<FaceRecognizer> _faceClassifier;
}

@property (nonatomic, strong) NSMutableDictionary *labelsDictionary;

@end

@implementation GCFaceRecognizer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _faceClassifier = createLBPHFaceRecognizer();
        //_faceClassifier = createEigenFaceRecognizer();
        //_faceClassifier = createFisherFaceRecognizer();
        
        NSString *path = [[self faceModelFileURL] path];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if (path && [fm fileExistsAtPath:path isDirectory:nil]) {
            _faceClassifier->load(path.UTF8String);
            
            NSDictionary *unarchivedNames = [NSKeyedUnarchiver
                                             unarchiveObjectWithFile:[path stringByAppendingString:@".names"]];
            
            self.labelsDictionary = [NSMutableDictionary dictionaryWithDictionary:unarchivedNames];
        } else {
            self.labelsDictionary = [NSMutableDictionary dictionary];
            NSLog(@"could not load paramaters file: %@", path);
        }
    }
    return self;
}

- (NSURL *)faceModelFileURL {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSURL *modelURL = [documentsURL URLByAppendingPathComponent:@"face-model.xml"];
    return modelURL;
}


@end
