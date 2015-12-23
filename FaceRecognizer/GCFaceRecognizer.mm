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

- (instancetype)init {
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

- (NSString *)predict:(UIImage*)image confidence:(double *)confidence {
    int label;
    cv::Mat src = [image cvMatRepresentationGray];
    
    _faceClassifier->predict(src, label, *confidence);
    
    return _labelsDictionary[@(label)];
}

- (void)updateWithFace:(UIImage *)img name:(NSString *)name {
    cv::Mat graySrc = [img cvMatRepresentationGray];
    
    NSSet *keys = [_labelsDictionary keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([name isEqual:obj]);
    }];
    
    NSInteger label;
    
    if (keys.count) {
        label = [[keys anyObject] integerValue];
    } else {
        label = _labelsDictionary.allKeys.count;
        _labelsDictionary[@(label)] = name;
    }
    
    vector<cv::Mat> images = vector<cv::Mat>();
    images.push_back(graySrc);
    vector<int> labels = vector<int>();
    labels.push_back((int)label);
    
    _faceClassifier->update(images, labels);
    
    [self serializeFaceRecognizerParamaters];
}


#pragma mark - Helper

- (NSURL *)faceModelFileURL {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSURL *modelURL = [documentsURL URLByAppendingPathComponent:@"face-model.xml"];
    return modelURL;
}

- (void)serializeFaceRecognizerParamaters {
    NSString *path = [[self faceModelFileURL] path];
    _faceClassifier->save(path.UTF8String);
    [NSKeyedArchiver archiveRootObject:self.labelsDictionary toFile:[path stringByAppendingString:@".names"]];
}



@end
