//
//  Procedure.h
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROCEDURE(TARGETCLASS, func)     [[Procedure alloc] initWithTarget:[Procedure getTarget:@#TARGETCLASS] selector:@selector(func)]

NS_ASSUME_NONNULL_BEGIN

@interface Procedure : NSObject

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL selector;

- (id)initWithTarget:(id)target selector:(SEL)selector;

+ (id)getTarget:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
