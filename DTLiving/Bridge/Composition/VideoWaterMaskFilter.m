//
//  VideoWaterMaskFilter.m
//  DTLiving
//
//  Created by Dan Jiang on 2020/5/18.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#import "VideoWaterMaskFilter.h"

@implementation VideoWaterMaskFilter

- (instancetype)init {
    self = [super initWithName:kVideoWaterMaskEffect];
    if (self) {
        self.scale = CGSizeMake(1.0, 1.0);
        self.rotate = 0;
        self.translate = CGSizeZero;
    }
    return self;
}

- (BOOL)isSizeAware {
    return YES;
}

- (NSDictionary<NSString*, NSArray<NSNumber*>*> *)floatParams {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform,
                                           self.translate.width / (self.size.width / 2.0),
                                           -self.translate.height / (self.size.width / 2.0));
    transform = CGAffineTransformScale(transform, self.scale.width, self.scale.height);
    transform = CGAffineTransformRotate(transform, self.rotate);
    CATransform3D transform3D = CATransform3DMakeAffineTransform(transform);
    NSArray<NSNumber*> *transformMatrix = [self convert3DTransformToArray:transform3D];
    return @{[NSString stringWithUTF8String:kVideoCompositionEffectModelMatrix]: transformMatrix};
}

- (NSArray<NSString*> *)resources {
    return @[self.imageName];
}

- (NSArray<NSNumber*> *)convert3DTransformToArray:(CATransform3D)transform3D {
    return @[@(transform3D.m11), @(transform3D.m12), @(transform3D.m13), @(transform3D.m14),
             @(transform3D.m21), @(transform3D.m22), @(transform3D.m23), @(transform3D.m24),
             @(transform3D.m31), @(transform3D.m32), @(transform3D.m33), @(transform3D.m34),
             @(transform3D.m41), @(transform3D.m42), @(transform3D.m43), @(transform3D.m44)];
}

@end
