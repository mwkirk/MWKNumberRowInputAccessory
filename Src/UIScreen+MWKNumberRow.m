//
//  UIScreen+MWKNumberRow.m
//  MWKNumberRowInputAccessory
//
//  Created by Mark Kirk on 10/3/16.
//  Copyright © 2016 Mark Kirk. All rights reserved.
//

#import "UIScreen+MWKNumberRow.h"

@implementation UIScreen (MWKNumberRow)

- (BOOL)isRetinaDisplay
{
    static dispatch_once_t once;
    static BOOL result;
    
    dispatch_once(&once, ^{
        result = ([self respondsToSelector:@selector(scale)] && (self.scale == 2 || self.scale == 3));
    });
    
    return result;
}


- (BOOL)isRetina4
{
    static dispatch_once_t once;
    static BOOL result;
    
    dispatch_once(&once, ^{
        CGRect bounds = [self bounds];
        result = (bounds.size.height == 568) ? YES : NO;
    });
    
    return result;
}


- (BOOL)isRetina35
{
    static dispatch_once_t once;
    static BOOL result;
    
    dispatch_once(&once, ^{
        CGRect bounds = [self bounds];
        result = ([self isRetinaDisplay] && bounds.size.height == 480) ? YES : NO;
    });
    
    return result;
}


- (BOOL)isRetinaHD47
{
    static dispatch_once_t once;
    static BOOL result;
    
    dispatch_once(&once, ^{
        CGRect bounds = [self bounds];
        result = (bounds.size.height == 667) ? YES : NO;
    });
    
    return result;
}


- (BOOL)isRetinaHD55
{
    static dispatch_once_t once;
    static BOOL result;
    
    dispatch_once(&once, ^{
        CGRect bounds = [self bounds];
        result = (bounds.size.height == 736 && [self respondsToSelector:@selector(scale)] && self.scale == 3) ? YES : NO;
    });
    
    return result;
}

@end
