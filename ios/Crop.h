//
//  Crop.h
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTImageLoader.h>

NS_ASSUME_NONNULL_BEGIN

@interface Crop : NSObject

- (CIImage *)cropPerspective:(NSArray *)params;
- (CIImage *)cropRoundedCorner:(NSArray *)params;

@end

NS_ASSUME_NONNULL_END
