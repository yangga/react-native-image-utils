//
//  Scale.m
//  RNImageUtils
//
//  Created by Jake Yang on 26/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "Scale.h"

double adjustValue(double value, double srcMin, double srcMax, double dstMin, double dstMax) {
    const double lenSrc = pow(srcMax-srcMin,2);
    const double lenVal = pow(value-srcMin,2);
    const double rate = lenVal / lenSrc;
    
    const double lenDst = pow(dstMax-dstMin,2);
    double valDst = lenDst * rate;
    return dstMin + sqrt(valDst);
}

@implementation Scale

- (CIImage *)scaleCSB:(NSArray *)params
{
    CIImage *ciImage = [params objectAtIndex:0];
    NSDictionary *param = [params objectAtIndex:1];
    
    const double contrast = adjustValue([param[@"contrast"] doubleValue], -100.0, 100.0, 0, 2);
    const double saturation = adjustValue([param[@"saturation"] doubleValue], -100.0, 100.0, 0, 3);
    const double brightness = adjustValue([param[@"brightness"] doubleValue], -100.0, 100.0, -1, 1);
    
    NSLog(@"#### scaleCSB : %f / %f / %f", contrast, saturation, brightness);
    
    CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    [colorControlsFilter setDefaults];
    [colorControlsFilter setValue:ciImage forKey:@"inputImage"];
    // min:0.25, max:4
    [colorControlsFilter setValue:[NSNumber numberWithFloat:contrast > 1 ? contrast*1.2 : contrast] forKey:@"inputContrast"];
    // min:0, max:3
    [colorControlsFilter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
    // min:-1, max:1
    [colorControlsFilter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
    ciImage = [colorControlsFilter valueForKey:@"outputImage"];
    
    return ciImage;
}

@end
