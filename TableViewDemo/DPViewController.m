//
//  DPViewController.m
//  TableViewDemo
//
//  Created by haowenliang on 14-5-8.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPViewController.h"
#import "LCVItem.h"
#import "UITableView+Frames.h"
#import <QuartzCore/QuartzCore.h>

@interface DPViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (retain, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;

@end

static NSIndexPath *selectedIndex = nil;
#define kVesperCell @"assassins_cell"

@implementation DPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _items = [NSMutableArray arrayWithCapacity:0];
    
    @autoreleasepool {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DPList" ofType:@"plist"];
        NSArray *items = [[NSArray alloc] initWithContentsOfFile:path];
        for (NSDictionary *dict in items) {
            LCVItem *item = [[LCVItem alloc] init];
            item.img = [UIImage imageNamed:[dict objectForKey:@"image"]];
            item.content = [dict objectForKey:@"content"];
            [_items insertObject:item atIndex:0];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [_tableView addGestureRecognizer:longPress];
    
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVesperCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVesperCell];
    }
    LCVItem *item = [_items objectAtIndex:indexPath.row];
    
    if (item.img) {
        [cell layoutIfNeeded];
        cell.imageView.image = item.img;
    }
    else {
        [cell layoutIfNeeded];
    }
    cell.textLabel.text = item.content;
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath;
    
    NSLog(@"%@", [[_items objectAtIndex:indexPath.row] content]);
}

- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    cell.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [_items exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [_tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                cell.alpha = 1.0f;
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            sourceIndexPath = nil;
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    UIView* snapshot = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0) {
        //ios7.0 以下通过截图形式保存快照
        snapshot = [self customSnapShortFromViewEx:inputView];
    }else{
        //ios7.0 系统的快照方法
        snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    }
    
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (UIView *)customSnapShortFromViewEx:(UIView *)inputView
{
    CGSize inSize = inputView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(inSize, NO, [UIScreen mainScreen].scale);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView* snapshot = [[UIImageView alloc] initWithImage:image];
    
    return snapshot;
}

@end
