//
//  Scale.h
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Scale : NSObject

- (CIImage *)scaleCSB:(NSArray *)params;

@end

NS_ASSUME_NONNULL_END
