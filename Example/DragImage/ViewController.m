//
//  ViewController.m
//  DragImage
//
//  Created by Jazys on 15/1/15.
//  Copyright (c) 2015年 Jazys. All rights reserved.
//

#import "ViewController.h"
#import "JZDragView.h"

@interface ViewController () <JZDragViewDelegate>
@property (nonatomic, weak)JZDragView *dragView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JZDragView *dragView = [JZDragView dragViewWithFrame:self.view.bounds andImages:@[@"a.jpg",@"b.jpg",@"c.jpg",@"d.jpg"]];
    dragView.delegate = self;
    dragView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:dragView];
    self.dragView = dragView;
}

- (void)dragViewDidEndScrollingAnimation:(JZDragView *)dragView {
    NSLog(@"%s",__func__);
}
- (void)dragViewDidEndDragging:(JZDragView *)dragView withVelocity:(CGPoint)velocity targetContentOffset:(CGFloat)targetContentOffset {
    NSLog(@"%s",__func__);
}
- (void)dragViewDidBeginDragging:(JZDragView *)dragView {
    NSLog(@"%s",__func__);
}
- (void)dragViewDidDragging:(JZDragView *)dragView {
    NSLog(@"%s",__func__);
}

@end
