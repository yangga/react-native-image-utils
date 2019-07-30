//
//  myUtil.h
//  idscanner
//
//  Created by yangga on 2015. 1. 4..
//  Copyright (c) 2015년 yangga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ExtensionMethods)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees scale:(CGFloat)scale;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage *)imageScaledToSize:(CGSize)newSize;
- (UIImage *)imageScaledToScale:(CGFloat)scale;

- (void)drawInRect:(CGRect)drawRect fromRect:(CGRect)fromRect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
