//
//  GCFaceDetector.m
//  FaceRecognizer
//
//  Created by Stefan Kofler on 22.12.15.
//  Copyright © 2015 Stefan Kofler. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "GCFaceDetector.h"
#import "UIImage+OpenCV.h"

using namespace cv;

@interface GCFaceDetector () {
    CascadeClassifier _faceDetector;
    CascadeClassifier _eyesDetector;
}

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) GCFaceDetectorCompletionBlock completionHandler;

@end

@implementation GCFaceDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadFaceDetector];
    }
    return self;
}

- (void)processImage:(UIImage *)image withCompletionHandler:(GCFaceDetectorCompletionBlock)completionHandler {
    self.image = image;
    self.completionHandler = completionHandler;
    [self startProcessingImage];
}

#pragma mark - Private methods

- (void)loadFaceDetector {
    NSString *faceCascadeFilePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];

    // Load content of file to char array CASCADE_NAME -> Face detector
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadeFilePath, CASCADE_NAME, CASCADE_NAME_LEN);
    _faceDetector.load(CASCADE_NAME);

    // Load content of file to char array CASCADE_NAME -> Eye detector
    NSString *eyesCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye_tree_eyeglasses" ofType:@"xml"];
    CFStringGetFileSystemRepresentation( (CFStringRef)eyesCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    _eyesDetector.load(CASCADE_NAME);
    
    free(CASCADE_NAME);
}

- (void)startProcessingImage {
    cv:Mat img = [self.image cvMatRepresentationColor];
    int scale = self.image.scale;
    
    Mat gray, smallImg( cvRound (img.rows/scale), cvRound(img.cols/scale), CV_8UC1 );

    cvtColor(img, gray, COLOR_BGR2GRAY);
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
    equalizeHist(smallImg, smallImg);

    vector<cv::Rect> faceRects;
    
    _faceDetector.detectMultiScale(smallImg, faceRects);
    
    NSMutableArray *faceImages = @[].mutableCopy;

    for(vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++) {
        if(_eyesDetector.empty())
            continue;
        
        vector<cv::Rect> eyeRects;
        _eyesDetector.detectMultiScale(smallImg(*r).clone(), eyeRects);
        
        if (eyeRects.size() < 1)
            continue;
        
        UIImage *faceImage = [UIImage imageFromCVMat:smallImg(*r).clone()];
        [faceImages addObject:faceImage];
    }
    
    self.completionHandler(faceImages.copy);
}

@end
