//
//  Trans.m
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "Trans.h"
#import "lib/UIImageCate.h"

@implementation Trans

- (CIImage *)transOrientRotate:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    const int degrees = [param[@"degrees"] intValue];

    int orientation = 0;
    switch ((int)round(degrees / 90)) {
        case 1: orientation = kCGImagePropertyOrientationRight; break;
        case 2: orientation = kCGImagePropertyOrientationDown; break;
        case 3: orientation = kCGImagePropertyOrientationLeft; break;
        default: return ciImage;
    }

    return [ciImage imageByApplyingOrientation:orientation];
}

- (CIImage *)transResize:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    const float width = [param[@"width"] floatValue];
    const float height = [param[@"height"] floatValue];
    
    CGSize newSize = CGSizeMake(width, height);
    
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    UIImage *newImage = [image imageScaledToSize:newSize];
    
    return [CIImage imageWithCGImage: [newImage CGImage]];
}

- (CIImage *)transScale:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    const float scale = [param[@"scale"] floatValue];
    
    CIFilter *f = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [f setValue:ciImage forKey:kCIInputImageKey];
    [f setValue:[NSNumber numberWithFloat:scale] forKey:kCIInputScaleKey];
    [f setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputAspectRatioKey];
    
    return [f outputImage];
}

@end
