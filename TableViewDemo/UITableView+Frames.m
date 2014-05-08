//
//  UITableView+Frames.m
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "UITableView+Frames.h"

@implementation UITableView (Frames)

- (NSDictionary *)framesForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[self cellForRowAtIndexPath:indexPath];
    CGRect cellFrameInTableView = [self rectForRowAtIndexPath:indexPath];
    CGRect cellFrameInWindow = [self convertRect:cellFrameInTableView toView:[UIApplication sharedApplication].keyWindow];
    
    NSMutableDictionary *frames = [NSMutableDictionary dictionary];
    [frames setObject:[NSValue valueWithCGRect:cellFrameInWindow] forKey:@"cell"];
    //FIXME: Hard Code
    [frames setObject:[NSValue valueWithCGRect:CGRectOffset(cell.imageView.frame, cellFrameInWindow.origin.x, cellFrameInWindow.origin.y-64.0)] forKey:@"img"];
    [frames setObject:[NSValue valueWithCGRect:CGRectOffset(cell.textLabel.frame, cellFrameInWindow.origin.x, cellFrameInWindow.origin.y-64.0)] forKey:@"content"];
    
    return [NSDictionary dictionaryWithDictionary:frames];
}

@end
