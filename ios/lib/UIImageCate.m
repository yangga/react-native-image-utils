//
//  myUtil.m
//  idscanner
//
//  Created by yangga on 2015. 1. 4..
//  Copyright (c) 2015년 yangga. All rights reserved.
//

#import "UIImageCate.h"

@implementation UIImage (ExtensionMethods)

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees scale:(CGFloat)scale;
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, scale, (scale * -1.0));
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    return [self imageRotatedByDegrees:degrees scale:1.0];
}

- (UIImage *)imageScaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageScaledToScale:(CGFloat)scale
{
    CGSize newSize = self.size;
    newSize.width *= scale;
    newSize.height *= scale;
    return [self imageScaledToSize:newSize];
}

- (void)drawInRect:(CGRect)drawRect fromRect:(CGRect)fromRect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    fromRect.origin.x *= self.scale;
    fromRect.origin.y *= self.scale;
    fromRect.size.width *= self.scale;
    fromRect.size.height *= self.scale;
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(self.CGImage, fromRect);
    if (drawImage != NULL)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Push current graphics state so we can restore later
        CGContextSaveGState(context);
        
        // Set the alpha and blend based on passed in settings
        CGContextSetBlendMode(context, blendMode);
        CGContextSetAlpha(context, alpha);
        
        // Take care of Y-axis inversion problem by translating the context on the y axis
        CGContextTranslateCTM(context, 0, drawRect.origin.y + fromRect.size.height/self.scale);
        
        // Scaling -1.0 on y-axis to flip
        CGContextScaleCTM(context, 1, -1);
        
        // Then accommodate the translate by adjusting the draw rect
        drawRect.origin.y = 0.0f;
        
        // Draw the image
        CGContextDrawImage(context, drawRect, drawImage);
        
        // Clean up memory and restore previous state
        CGImageRelease(drawImage);
        
        // Restore previous graphics state to what it was before we tweaked it
        CGContextRestoreGState(context);
    }
}

@end
