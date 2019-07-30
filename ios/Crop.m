//
//  Crop.m
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "Crop.h"

CGPoint cartesianForPoint(CGPoint point, float height) {
    return CGPointMake(point.x, height - point.y);
}

@implementation Crop

- (CIImage *)cropPerspective:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    UIImage *uiimage = [UIImage imageWithCIImage:ciImage];
    
    CGPoint newLeft = CGPointMake([param[@"topLeft"][@"x"] floatValue], [param[@"topLeft"][@"y"] floatValue]);
    CGPoint newRight = CGPointMake([param[@"topRight"][@"x"] floatValue], [param[@"topRight"][@"y"] floatValue]);
    CGPoint newBottomLeft = CGPointMake([param[@"bottomLeft"][@"x"] floatValue], [param[@"bottomLeft"][@"y"] floatValue]);
    CGPoint newBottomRight = CGPointMake([param[@"bottomRight"][@"x"] floatValue], [param[@"bottomRight"][@"y"] floatValue]);
    
    CGFloat heightImg = uiimage.size.height;
    
    newLeft = cartesianForPoint(newLeft, heightImg);
    newRight = cartesianForPoint(newRight, heightImg);
    newBottomLeft = cartesianForPoint(newBottomLeft, heightImg);
    newBottomRight = cartesianForPoint(newBottomRight, heightImg);
    
    NSMutableDictionary *rectangleCoordinates = [[NSMutableDictionary alloc] init];
    
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:newLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:newRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:newBottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:newBottomRight];
    
    return [ciImage imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

- (CIImage *)cropRoundedCorner:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    const double radius = [param[@"radius"] doubleValue];
    NSObject *noantialias = param[@"noantialias"];
    
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    const CGSize size = image.size;

    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    
    if (noantialias) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, NO);
        CGContextSetAllowsAntialiasing(context, NO);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    }
    
    CGRect rc;
    rc.origin = CGPointZero;
    rc.size = size;
    
    [[UIBezierPath bezierPathWithRoundedRect:rc
                                cornerRadius:radius] addClip];

    [image drawInRect:rc];
    
    UIImage* resUIImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CIImage *resCiImage = [CIImage imageWithCGImage: [resUIImage CGImage]];
    
    return resCiImage;
}

@end
