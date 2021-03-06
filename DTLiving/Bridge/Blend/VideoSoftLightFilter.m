//
//  VideoSoftLightFilter.m
//  DTLiving
//
//  Created by Dan Jiang on 2020/5/27.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#import "VideoSoftLightFilter.h"

@implementation VideoSoftLightFilter

- (instancetype)init {
    self = [super initWithName:kVideoSoftLightBlendEffect];
    if (self) {
    }
    return self;
}

- (NSString *)vertexShaderFile {
    return @"effect_two_input_vertex";
}

- (NSArray<NSString*> *)resources {
    return @[self.imageName];
}

@end
