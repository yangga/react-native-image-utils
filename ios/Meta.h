//
//  Meta.h
//  react-native-image-utils
//
//  Created by Jake Yang on 31/07/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Meta : NSObject

+(void)metaReadData:(NSString *)imagePath callback:(RCTResponseSenderBlock)callback;
+(void)metaWriteData:(NSString *)imagePath metaDataInfo:(NSDictionary *)metaDataInfo callback:(RCTResponseSenderBlock)callback;

@end

NS_ASSUME_NONNULL_END
