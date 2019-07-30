//
//  Procedure.m
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "Procedure.h"

static NSMutableDictionary *poolTargets;

@implementation Procedure

-(id)initWithTarget:(id)target selector:(SEL)selector;
{
    _target = target;
    _selector = selector;
    return self;
}

+ (id)getTarget:(NSString *)className
{
    if (!poolTargets)
        poolTargets = [[NSMutableDictionary alloc] init];
    
    id target = [poolTargets objectForKey:className];
    if (!target) {
        target = [[NSClassFromString(className) alloc] init];
        [poolTargets setObject:target forKey:className];
    }
    
    return target;
}

@end
