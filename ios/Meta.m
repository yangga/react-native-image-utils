//
//  Meta.m
//  react-native-image-utils
//
//  Created by Jake Yang on 31/07/2019.
//

#import <React/RCTBridgeModule.h>
#import "Meta.h"

@implementation Meta

+(void)metaReadData:(NSString *)imagePath callback:(RCTResponseSenderBlock)callback
{
    CGImageSourceRef imageSource;
    @try{
        NSURL *imageUrl = [[NSURL alloc] initWithString:imagePath];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        NSDictionary *dict =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL));
        if (!dict) {
            NSException* myException = [NSException
                                        exceptionWithName:@"Failed to read meta data"
                                        reason:@""
                                        userInfo:nil
                                        ];
            @throw myException;
        }
        callback(@[[NSNull null], dict]);
    }
    @catch(NSException *exception){
        NSLog(@"[react-native-image-utils] %@", exception);
        callback(@[[exception name], [exception reason]]);
    }
    @finally{
        if(imageSource){
            CFRelease(imageSource);
        }
    }
}

+(void)metaWriteData:(NSString *)imagePath metaDataInfo:(NSDictionary *)metaDataInfo callback:(RCTResponseSenderBlock)callback
{
    CGImageSourceRef imageSource;
    CFStringRef UTI;
    CGImageDestinationRef destination;
    @try{
        NSMutableDictionary *dictInfo = [metaDataInfo mutableCopy];
        NSMutableData *newImageData = [NSMutableData data];
        NSURL *imageUrl = [[NSURL alloc] initWithString:imagePath];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        if(imageSource == NULL){
            NSException* myException = [NSException
                                        exceptionWithName:@"Image path not found,Please check your path and metadata"
                                        reason:@""
                                        userInfo:nil
                                        ];
            @throw myException;
        }
        UTI = CGImageSourceGetType(imageSource);
        destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1,NULL);
        if(!destination){
            NSException* myException = [NSException
                                        exceptionWithName:@"Destination not found,Please check your path and metadata"
                                        reason:@""
                                        userInfo:nil
                                        ];
            @throw myException;
        }
        CGImageDestinationAddImageFromSource(destination, imageSource, 0, (__bridge CFDictionaryRef)dictInfo);
        CGImageDestinationFinalize(destination);
        [newImageData writeToFile: imagePath atomically:YES];
        callback(@[[NSNull null], metaDataInfo]);
    }
    @catch(NSException *exception){
        NSLog(@"[react-native-image-utils] %@", exception);
        callback(@[[exception name], [exception reason]]);
    }
    @finally{
        if(imageSource){
            CFRelease(imageSource);
        }
        if(UTI){
            CFRelease(UTI);
        }
        if(destination){
            CFRelease(destination);
        }
    }
}

@end
