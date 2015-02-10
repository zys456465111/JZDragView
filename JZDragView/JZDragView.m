//
//  JZDragScrollView.m
//  DragImage
//
//  Created by Jazys on 15/1/15.
//  Copyright (c) 2015年 Jazys. All rights reserved.
//

#import "JZDragView.h"

typedef enum {
    JZDragViewDirectionUp,
    JZDragViewDirectionDown
}JZDragViewDirection;

@interface JZDragView ()

@property (nonatomic, assign)JZDragViewDirection direction;
@property (nonatomic, assign)NSInteger nextIndex;
@property (nonatomic, strong)NSMutableArray *imageViews;
@end

@implementation JZDragView

+ (instancetype)dragViewWithFrame:(CGRect)frame andImages:(NSArray *)images {
    return [[self alloc] initWithFrame:frame andImages:images];
}

- (instancetype)initWithFrame:(CGRect)frame andImages:(NSArray *)images
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert([images[0] isKindOfClass:[UIImage class]] || [images[0] isKindOfClass:[NSString class]], @"数组需要存放图片或图片名称");
        self.images = images;
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}

- (UIImageView *)currentImageView {
    return self.imageViews[0];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    
    if (currentIndex < 0)
        currentIndex = _images.count - 1;
    else if (currentIndex > _images.count - 1)
        currentIndex = 0;
    
    _currentIndex = currentIndex;
}

- (void)setNextIndex:(NSInteger)nextIndex {
    
    if (nextIndex < 0)
        nextIndex = _images.count - 1;
    else if (nextIndex > _images.count - 1)
        nextIndex = 0;
    
    _nextIndex = nextIndex;
    
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if (velocity.y > 0) {
            _direction = JZDragViewDirectionDown;
            self.nextIndex = self.currentIndex - 1;
        } else {
            _direction = JZDragViewDirectionUp;
            self.nextIndex = self.currentIndex + 1;
        }
        
        if ([self.delegate respondsToSelector:@selector(dragViewDidBeginDragging:)])
            [self.delegate dragViewDidBeginDragging:self];
        
    }
    
    [self handleUpDownGesture:sender];
    
}

- (void)handleUpDownGesture:(UIPanGestureRecognizer *)sender
{

    UIImageView *currentImageView = self.imageViews[0];
    currentImageView.image = self.images[self.currentIndex];
    
    UIImageView *nextImageView = self.imageViews[1];
    nextImageView.image = self.images[self.nextIndex];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        nextImageView.hidden = NO;
        
        CGRect beginFrame = nextImageView.frame;
        CGFloat height = self.bounds.size.height;

        if (_direction == JZDragViewDirectionUp)
            beginFrame.origin.y = height;
        else
            beginFrame.origin.y = -height;
        
        nextImageView.frame = beginFrame;

        [self bringSubviewToFront:nextImageView];
    }

    if (sender.state == UIGestureRecognizerStateChanged)
        if ([self.delegate respondsToSelector:@selector(dragViewDidDragging:)])
            [self.delegate dragViewDidDragging:self];
    
    CGFloat translationY = [sender translationInView:self].y;
    CGRect nextImageFrame = nextImageView.frame;
    nextImageFrame.origin.y += translationY;
    nextImageView.frame = nextImageFrame;
    
    CGFloat offset = 1000 - nextImageView.bounds.size.height * .35;
    CGFloat scale = (fabs(nextImageView.frame.origin.y) * .35 + offset) * 0.001;
    currentImageView.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGRect currentFrame = currentImageView.frame;
    if (_direction == JZDragViewDirectionDown)
        currentFrame.origin.y = self.bounds.size.height - currentImageView.frame.size.height;
    else
        currentFrame.origin.y = 0;
    currentImageView.frame = currentFrame;
    
    [sender setTranslation:CGPointZero inView:sender.view];

    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGFloat velocityY = [sender velocityInView:self].y;
        
        if ([self.delegate respondsToSelector:@selector(dragViewDidEndDragging:withVelocity:targetContentOffset:)])
            [self.delegate dragViewDidEndDragging:self withVelocity:[sender velocityInView:self] targetContentOffset:nextImageView.frame.origin.y];

        CGFloat height = self.bounds.size.height;
        CGFloat y = 0;
        BOOL changed = NO;
        if (_direction == JZDragViewDirectionUp) {
            changed = nextImageView.frame.origin.y < height - height * .2 || velocityY < -900;
            y = height;
        }
        else {
            changed = CGRectGetMaxY(nextImageView.frame) > height * .2 || velocityY > 800;
            y = -height;
        }

        CGRect nextImageFrame = nextImageView.frame;
        if (changed)
            nextImageFrame.origin.y = 0;
        else
            nextImageFrame.origin.y = y;
        
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{

            nextImageView.frame = nextImageFrame;
            
            if (!changed) {
                currentImageView.transform = CGAffineTransformIdentity;
                currentImageView.frame = self.bounds;
            }
            
        }completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
            if (changed) {
                self.currentIndex = self.nextIndex;
                [self.imageViews exchangeObjectAtIndex:0 withObjectAtIndex:1];
                currentImageView.transform = CGAffineTransformIdentity;
                currentImageView.frame = self.bounds;
                currentImageView.hidden = YES;
            }
            if ([self.delegate respondsToSelector:@selector(dragViewDidEndScrollingAnimation:)])
                [self.delegate dragViewDidEndScrollingAnimation:self];
        }];
    }
}

- (NSArray *)imageViews {
    if (!_imageViews) {
        NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:2];

        for (int i = 0; i < 2; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            if (self.images.count)
                imageView.image = self.images[i];
            imageView.hidden = i;
            [imageViews addObject:imageView];
            [self addSubview:imageView];
        }
        _imageViews = imageViews;
    }
    return _imageViews;
}

- (void)setImages:(NSArray *)images {
    
    if ([images[0] isKindOfClass:[NSString class]]) {
        NSMutableArray *uiImages = [NSMutableArray arrayWithCapacity:images.count];
        for (NSString *imageName in images) {
            UIImage *image = [UIImage imageNamed:imageName];
            [uiImages addObject:image];
        }
        images = uiImages;
    }

    _images = images;
    
    [self.imageViews[0] setImage:images[0]];
    [self.imageViews[1] setImage:images[1]];
}

@end
