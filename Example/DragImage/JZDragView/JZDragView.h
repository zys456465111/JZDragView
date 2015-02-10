//
//  JZDragScrollView.h
//  DragImage
//
//  Created by Jazys on 15/1/15.
//  Copyright (c) 2015年 Jazys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZDragView;
@protocol JZDragViewDelegate <NSObject>
@optional

- (void)dragViewDidBeginDragging:(JZDragView *)dragView;

- (void)dragViewDidDragging:(JZDragView *)dragView;

- (void)dragViewDidEndDragging:(JZDragView *)dragView withVelocity:(CGPoint)velocity targetContentOffset:(CGFloat)targetContentOffset;

- (void)dragViewDidEndScrollingAnimation:(JZDragView *)dragView;

@end

/**
 *  you can change image for backgroundImage
 */
@interface JZDragView : UIImageView

@property (nonatomic, weak)id<JZDragViewDelegate> delegate;

/**
 *  images for dragView
 */
@property (nonatomic, strong)NSArray *images;

@property (nonatomic, assign)NSInteger currentIndex;

@property (nonatomic, weak)UIImageView *currentImageView;

/**
 *  @param images 存放UIImage(图片)或者NSString(图片名称)
 */
- (instancetype)initWithFrame:(CGRect)frame andImages:(NSArray *)images;

+ (instancetype)dragViewWithFrame:(CGRect)frame andImages:(NSArray *)images;

@end
