#import "RNImageUtils.h"
#import <React/RCTLog.h>
#import <React/RCTImageLoader.h>

#include "Procedure.h"
#include "Crop.h"
#include "Meta.h"
#include "Scale.h"
#include "Trans.h"

@implementation RNImageUtils

@synthesize bridge = _bridge;

NSDictionary *procedures = [NSDictionary dictionaryWithObjectsAndKeys:
                            PROCEDURE(Crop, cropPerspective:), @"cropPerspective",
                            PROCEDURE(Crop, cropRoundedCorner:), @"cropRoundedCorner",
                            PROCEDURE(Scale, scaleCSB:), @"scaleCSB",
                            PROCEDURE(Trans, transOrientRotate:), @"transOrientRotate",
                            PROCEDURE(Trans, transResize:), @"transResize",
                            nil];

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(metaReadData:(NSString *)imagePath callback:(RCTResponseSenderBlock)callback){
    [Meta metaReadData:imagePath callback:callback];
}

RCT_EXPORT_METHOD(metaWriteData:(NSString *)imagePath metaDataInfo:(NSDictionary *)metaDataInfo callback:(RCTResponseSenderBlock)callback){
    [Meta metaWriteData:imagePath metaDataInfo:metaDataInfo callback:callback];
}

RCT_EXPORT_METHOD(proxies:(NSDictionary *)outOption imageSrcUri:(NSString *)imageSrcUri proxyParams:(NSArray *)proxyParams callback:(RCTResponseSenderBlock)callback)
{
    [_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:imageSrcUri] callback:^(NSError *error, UIImage *imageSrc) {
        if (error || imageSrc == nil) {
            if ([imageSrcUri hasPrefix:@"data:"] || [imageSrcUri hasPrefix:@"file:"]) {
                NSURL *imageUrl = [[NSURL alloc] initWithString:imageSrcUri];
                imageSrc = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
            } else {
                imageSrc = [[UIImage alloc] initWithContentsOfFile:imageSrcUri];
            }
            if (imageSrc == nil) {
                callback(@[@"Can't retrieve the file from the path.", @""]);
                return;
            }
        }
        
        CIImage *ciImage = [CIImage imageWithCGImage: [imageSrc CGImage]];
        CIImage *resImage = nil;
        @try {
            // calling procedures chaining
            for (NSDictionary* p in proxyParams) {
                NSString *cmd = p[@"cmd"];
                NSDictionary *param = p[@"param"];
                
                Procedure *procedure = [procedures objectForKey:cmd];
                if (!procedure) {
                    NSException* myException = [NSException
                                                exceptionWithName:@"Invalid command"
                                                reason:@""
                                                userInfo:p];
                    @throw myException;
                }
                
                
                id target = [procedure target];
                SEL sel = [procedure selector];
                NSArray *invokeParam = [NSArray arrayWithObjects:ciImage, param, nil];

                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [[target class] instanceMethodSignatureForSelector:sel]];
                [invocation setSelector:sel];
                [invocation setTarget:target];
                [invocation setArgument:&invokeParam atIndex:2];
                [invocation invoke];
                CIImage * __unsafe_unretained newImage;
                [invocation getReturnValue:&newImage];
                
                ciImage = newImage;
            }
            
            // save result image
            resImage = ciImage;
            
        } @catch (NSException *exception) {
            NSLog(@"[react-native-image-utils] %@", exception);
            callback(@[[exception name], [exception reason]]);
            return;
        }
        
        if (!resImage) {
            callback(@[@"Invalid result", @""]);
            return;
        }

        // CIImage -> File
        NSString *format = outOption[@"format"];
        const double quality = [outOption[@"quality"] doubleValue];
        NSString *outputPath = outOption[@"path"];
        
        NSString *extension = @"jpg";
        if ([format isEqualToString:@"PNG"]) {
            extension = @"png";
        }
        
        NSString* fullPath;
        @try {
            fullPath = generateFilePath(extension, outputPath);
        } @catch (NSException *exception) {
            callback(@[@"Invalid output path.", @""]);
            return;
        }
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgimage = [context createCGImage:ciImage fromRect:[resImage extent]];
        UIImage *image = [UIImage imageWithCGImage:cgimage];
        
        if (!saveImage(fullPath, image, format, quality)) {
            callback(@[@"Can't save the image. Check your compression format and your output path", @""]);
            return;
        }
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:fullPath];
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&attributesError];
        NSNumber *fileSize = fileAttributes == nil ? 0 : [fileAttributes objectForKey:NSFileSize];
        NSDictionary *response = @{@"path": fullPath,
                                   @"uri": fileUrl.absoluteString,
                                   @"fileSize": fileSize == nil ? @(0) : fileSize,
                                   @"width": [NSNumber numberWithFloat:image.size.width],
                                   @"height": [NSNumber numberWithFloat:image.size.height],
                                   };
        callback(@[[NSNull null], response]);
    }];
}

bool saveImage(NSString *fullPath, UIImage *image, NSString *format, float quality)
{
    NSData* data = nil;
    if ([format isEqualToString:@"JPEG"]) {
        data = UIImageJPEGRepresentation(image, quality / 100.0);
    } else if ([format isEqualToString:@"PNG"]) {
        data = UIImagePNGRepresentation(image);
    }
    
    if (data == nil) {
        return NO;
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}

NSString* generateFilePath(NSString *ext, NSString *outputPath)
{
    NSString* directory;
    
    if ([outputPath length] == 0) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        directory = [paths firstObject];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if ([outputPath hasPrefix:documentsDirectory]) {
            directory = outputPath;
        } else {
            directory = [documentsDirectory stringByAppendingPathComponent:outputPath];
        }
        
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"[react-native-image-utils] Error creating documents subdirectory: %@", error);
            @throw [NSException exceptionWithName:@"InvalidPathException" reason:[NSString stringWithFormat:@"Error creating documents subdirectory: %@", error] userInfo:nil];
        }
    }
    
    NSString* name = [[NSUUID UUID] UUIDString];
    NSString* fullName = [NSString stringWithFormat:@"%@.%@", name, ext];
    NSString* fullPath = [directory stringByAppendingPathComponent:fullName];
    
    return fullPath;
}

@end
