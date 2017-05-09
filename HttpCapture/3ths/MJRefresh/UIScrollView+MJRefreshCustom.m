//
//  UIScrollView+MJRefreshCustom.m
//  weixindress
//
//  Created by 杨帆 on 16/2/24.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "UIScrollView+MJRefreshCustom.h"
#import "TTTAttributedLabel.h"
#import "UIImage+GIF.h"
#import "HttpCapture-Swift.h"

const CGFloat JZRefreshHeaderHeight = 73.0;
const CGFloat JZRefreshFooterHeight = 54.0;
const CGFloat JZMainPageRefreshHeaderHeight = 103.0;

#pragma mark - MainPage Header

@interface JZMainRefreshHeader ()

@property(nonatomic,strong) UIImageView *mainImageView;
@property(nonatomic,strong) UIImageView *animatedImageView;
@property(strong,nonatomic) CAShapeLayer *shapeLayer;
@property(nonatomic,assign) BOOL firstLoad;
@property(nonatomic,assign) BOOL isFinish;

@end

@implementation JZMainRefreshHeader

#pragma mark override
-(void)prepare {
    _firstLoad = true;
    [super prepare];
    self.stateLabel.hidden = true;
    self.lastUpdatedTimeLabel.hidden = true;
    self.mj_h = JZMainPageRefreshHeaderHeight;
    self.backgroundColor = [UIColor fromRGB: 0xf5f5f5];
}
-(void)placeSubviews {
    [super placeSubviews];
    if (_firstLoad) {
        _firstLoad = false;
        CGFloat raito = JZMainPageRefreshHeaderHeight/148;
        
        self.mainImageView.mj_size = CGSizeMake(_mainImageView.mj_w*raito, _mainImageView.mj_h*raito);
        CGFloat scaleRaito = [[UIScreen mainScreen] scale]/2;
        self.animatedImageView.mj_size = CGSizeMake(_animatedImageView.image.size.width *raito*scaleRaito,
                                                    _animatedImageView.image.size.height*raito*scaleRaito);
        
        CGFloat totalWidth = _mainImageView.mj_w + _animatedImageView.mj_w + 10 *raito;
        CGFloat offsetX = (self.mj_w - totalWidth)/18;
        
        CGFloat mainOffsetX = totalWidth/2 - _mainImageView.mj_w/2 - offsetX;
        CGFloat animOffsetX = mainOffsetX - totalWidth/2;
        CGFloat animOffsetY = (JZMainPageRefreshHeaderHeight - _animatedImageView.mj_h)/8;
        
        self.mainImageView.center     = CGPointMake(self.mj_w/2 + mainOffsetX, self.mj_h/2);
        self.animatedImageView.center = CGPointMake(self.mj_w/2 + animOffsetX,
                                                    self.mj_h/2 + animOffsetY);
        self.shapeLayer.position      = CGPointMake(self.mj_w/2 + mainOffsetX, self.mj_h*122/148);

    }
}

-(void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    if (state == MJRefreshStateIdle) {
        _isFinish = false;
    }
    if (state == MJRefreshStateRefreshing && !_isFinish) {
        // 调用updateAnimation:force:防止view还未加载即调用beginrefresh时 方框显示错误的问题
        [self updateAnimation:1.0 force:true];
        [self animation];
    }
}

-(void)endRefreshing {
    [super endRefreshing];
    [self stopAnimation];
}

#pragma mark getter
- (UIImageView *)animatedImageView {
    if (_animatedImageView == nil) {
        _animatedImageView = [[UIImageView alloc]init];
        UIImage *image = [UIImage sd_animatedGIFNamed:@"show"];
        _animatedImageView.image = image;
        _animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_animatedImageView];
        [_animatedImageView startAnimating];
    }
    return _animatedImageView;
    
}
-(UIImageView *)mainImageView {
    if (_mainImageView == nil) {
        UIImage* image = [UIImage imageNamed:@"newstyle_r"];
        _mainImageView = [[UIImageView alloc]initWithImage:image];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_mainImageView];
    }
    return _mainImageView;
}
- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer == nil) {
        _shapeLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_shapeLayer];
        _shapeLayer.strokeColor = [UIColor fromRGB:0xdddddd].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineWidth = 1.5f;
        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.lineCap = kCALineCapRound;
    }
    return _shapeLayer;
}

- (void) updateAnimation:(CGFloat)percent force:(BOOL)force {
    
    if ((_isFinish || self.state == MJRefreshStateRefreshing)&& !force){
        return;
    }
    if (percent <= 0.01 && percent != 0) {
        _shapeLayer.path = nil;
        [self stopAnimation];
    }
    if (percent <= 0 && !force) {
        return;
    }
    
    if (_shapeLayer == nil) {
        [self shapeLayer];
    }
    
    UIBezierPath* path = [[UIBezierPath alloc]init];
    CGFloat raito = JZMainPageRefreshHeaderHeight/148;
    [path addArcWithCenter:CGPointZero radius:9 * raito startAngle:- M_PI_2+0.3 endAngle:(M_PI * 2)*percent - M_PI_2 - 0.3 clockwise:true];
    
    if (!_isFinish && percent > 1) {
        if (![_shapeLayer animationForKey:@"rotate"]) [self animation];
        _isFinish = true;
    }
    _shapeLayer.path = path.CGPath;
}

-(void)animation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.9; // 持续时间
    animation.repeatCount = MAXFLOAT; // 重复次数
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 终止角度
    [_shapeLayer addAnimation:animation forKey:@"rotate"];
}
-(void)stopAnimation {
    [_shapeLayer removeAnimationForKey:@"rotate"];
}

-(void)isMain {
    ;
}
@end

#pragma mark - Footer

@interface MJRefreshJZFooter ()

@property(strong,nonatomic) JZAnimationLayer *animationLayer;
@property(strong,nonatomic) CAShapeLayer *borderLayer;

@end

@implementation MJRefreshJZFooter
#pragma mark  getter
- (JZAnimationLayer *)animationLayer {
    if (_animationLayer == nil) {
        _animationLayer = [JZAnimationLayer layer];
        [self.layer addSublayer:_animationLayer];
    }
    return _animationLayer;
}


- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
    if(self.needAdjustContentSize)
    {
        self.mj_h =  self.scrollView.bounds.size.height - self.scrollView.mj_contentH > 44 ?  self.scrollView.bounds.size.height - self.scrollView.mj_contentH   : 44;
        self.mj_y = self.scrollView.mj_contentH;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollView.mj_insetB = self.scrollViewOriginalInset.bottom + self.mj_h;
        });
    }
    // 设置位置

}



#pragma mark  override

-(void)prepare {
    [super prepare];
    self.mj_h = JZRefreshFooterHeight;
    [self setTitle:@"" forState:MJRefreshStateRefreshing];
    [self setTitle:@"" forState:MJRefreshStateIdle];
    
}
- (void)placeSubviews
{
    [super placeSubviews];
    self.animationLayer.position = CGPointMake(self.mj_w/2 - 6, 22);
    self.stateLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 44);
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.position = CGPointMake(self.mj_w/2, 22);
        _borderLayer.strokeColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor;
        _borderLayer.lineWidth = 2.0;
        _borderLayer.lineJoin = kCALineJoinRound;
        _borderLayer.lineCap = kCALineCapRound;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, -15)];
        [path addLineToPoint:CGPointMake(15, 0)];
        [path moveToPoint:CGPointMake(15, 0)];
        [path addLineToPoint:CGPointMake(0, 15)];
        [path moveToPoint:CGPointMake(0, 15)];
        [path addLineToPoint:CGPointMake(-15, 0)];
        [path moveToPoint:CGPointMake(-15, 0)];
        [path addLineToPoint:CGPointMake(0, -15)];
        _borderLayer.path = path.CGPath;
        _borderLayer.hidden = true;
        [self.layer addSublayer:_borderLayer];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.state != MJRefreshStateIdle || !self.automaticallyRefresh || self.mj_y == 0) return;
    
    if (_scrollView.mj_insetT + _scrollView.mj_contentH > _scrollView.mj_h) { // 内容超过一个屏幕
        // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
        if (_scrollView.mj_offsetY >= _scrollView.mj_contentH - _scrollView.mj_h + self.mj_h * self.triggerAutomaticallyRefreshPercent + _scrollView.mj_insetB - self.mj_h - self.beginOffset) {
            // 防止手松开时连续调用
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            
            // 当底部刷新控件完全出现时，才刷新
            [self beginRefreshing];
        }
    }
}

- (void)setState:(MJRefreshState)state
{
    if (_scrollView.mj_header && _scrollView.mj_header.state == MJRefreshStateRefreshing) {
        return;
    }
    MJRefreshCheckState
    if (state == MJRefreshStateNoMoreData) {
        [self stopAnimation3];
    }
    if (state == MJRefreshStateRefreshing) {
        [self animation3];
    }
}

-(void)setTitle:(NSString *)title forState:(MJRefreshState)state {
    [super setTitle:title forState:state];
    if (![title isEqualToString:@""] && state == MJRefreshStateIdle) {
        [self stopAnimation3];
    }
}

-(void)endRefreshing {
    [super endRefreshing];
    [self stopAnimation3];
}
#pragma mark animation
-(void) animation3 {
    self.animationLayer.hidden = false;
    _borderLayer.hidden = false;
    [_animationLayer start];
}
-(void) stopAnimation3 {
    self.animationLayer.hidden = true;
    _borderLayer.hidden = true;
    [_animationLayer invalid];
}
@end

#pragma mark - BaseHeader

@interface MJRefreshJZBaseHeader ()

// protected method
- (void) updateAnimation:(CGFloat)percent;
- (void) updateAnimation:(CGFloat)percent force:(BOOL)force;

@end

@implementation MJRefreshJZBaseHeader

- (void) updateAnimation:(CGFloat)percent {
    [self updateAnimation:percent force:false];
}
- (void) updateAnimation:(CGFloat)percent force:(BOOL)force{}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    [self updateAnimation:pullingPercent];
}

-(void)setFont:(UIFont *)font {
    _font = font;
    self.stateLabel.font = font;
    NSString *text = self.stateLabel.text;
    self.stateLabel.text = text;
}
-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.stateLabel.textColor = textColor;
    NSString *text = self.stateLabel.text;
    self.stateLabel.text = text;
}

-(void)setUpdatedTimeHidden:(BOOL)updatedTimeHidden {
    _updatedTimeHidden = updatedTimeHidden;
    self.lastUpdatedTimeLabel.hidden = updatedTimeHidden;
}

@end

#pragma mark - Header

@interface MJRefreshJZHeader() {
    CGFloat LINE_HEIGHT;
    CGFloat mark_height;
}

@property(strong,nonatomic)  CAShapeLayer *shapeLayer;
@property(strong,nonatomic)  CAShapeLayer *lineLayer;
@property(assign,nonatomic)  BOOL isFinish;
@property(strong,nonatomic) TTTAttributedLabel * stateLabel2;
@property(strong,nonatomic) JZAnimationLayer *animationLayer;

@end

@implementation MJRefreshJZHeader

#pragma mark setter

-(JZAnimationLayer *)animationLayer {
    if (_animationLayer == nil) {
        _animationLayer = [JZAnimationLayer layer];
        _animationLayer.position = CGPointMake(self.mj_w/2 - 6, LINE_HEIGHT+mark_height/2);
        [self.layer addSublayer:_animationLayer];
    }
    return _animationLayer;
}
#pragma mark override

-(void)setState:(MJRefreshState)state {
    if (_scrollView.mj_footer && _scrollView.mj_footer.state == MJRefreshStateRefreshing) {
        return;
    }
    MJRefreshCheckState
    if (state == MJRefreshStateIdle) {
        _isFinish = false;
    }
    if (state == MJRefreshStateRefreshing && !_isFinish) {
        // 调用updateAnimation:force:防止view还未加载即调用beginrefresh时 方框显示错误的问题
        [self updateAnimation:1.0 force:true];
        [self animation3];
    }
}

// 覆写stateLabel的getter，用TTTAttributedLabel使其可以垂直贴底
- (UILabel *)stateLabel
{
    if (!_stateLabel2) {
        [self addSubview:_stateLabel2 = [TTTAttributedLabel label]];
        _stateLabel2.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
    }
    return _stateLabel2;
}

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    return [super headerWithRefreshingBlock:refreshingBlock];
}

- (void)prepare
{
    [super prepare];
    LINE_HEIGHT = 18;
    mark_height = 30;
    self.mj_h = JZRefreshHeaderHeight;
    self.automaticallyChangeAlpha = true;
    self.updatedTimeHidden = true;
    self.font = [UIFont systemFontOfSize:10];
    self.textColor = [UIColor fromRGBA:0x999999ff];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    if (noConstrainsOnStatusLabel) {
        self.stateLabel.mj_h -= 6.0;
    }
    if (_lineLayer == nil) {
        [self initLineLayer];
    }
    
}

-(void)endRefreshing {
    [super endRefreshing];
    [self stopAnimation3];
}

#pragma mark animation

- (void) initShapeLayer {
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = self.bounds;
    [self.layer addSublayer:self.shapeLayer];
    self.shapeLayer.strokeColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor;
    _shapeLayer.lineWidth = 2.f;
    _shapeLayer.lineJoin = kCALineJoinRound;
    _shapeLayer.lineCap = kCALineCapRound;
}

- (void) initLineLayer {
    //竖线
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.frame = self.bounds;
    [self.layer addSublayer:_lineLayer];
    _lineLayer.strokeColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor;
    _lineLayer.lineWidth = 1.0/[UIScreen mainScreen].scale;
    UIBezierPath* linepath = [[UIBezierPath alloc]init];
    [linepath moveToPoint:CGPointMake(self.mj_w/2.0,-480.0)];
    [linepath addLineToPoint:CGPointMake(self.mj_w/2.0, LINE_HEIGHT)];
    _lineLayer.path = linepath.CGPath;
}

- (void) updateAnimation:(CGFloat)percent force:(BOOL)force {

    if ((_isFinish || self.state == MJRefreshStateRefreshing) && !force) {
        return;
    }
    // [0,1]-->[-1,1]映射
    percent = percent * 2 - 1;
    if (percent < - 0.99 && percent != -1.0) {
        _shapeLayer.path = nil;
        [self stopAnimation3];
    }
    if (percent <= 0 && !force) {
        return;
    }
    if (_shapeLayer == nil) [self initShapeLayer];
    
    UIBezierPath* path = [[UIBezierPath alloc]init];

    if (percent > 0) {
        CGFloat tpercent = (percent>0.25 ? 0.25 : percent);
        CGFloat offset = mark_height * tpercent * 2 ;
        [path moveToPoint:CGPointMake(self.mj_w/2.0,LINE_HEIGHT)];
        [path addLineToPoint:CGPointMake(self.mj_w/2.0 + offset, offset+ LINE_HEIGHT)];
    }
    if (percent > 0.25) {
        CGFloat tpercent = (percent > 0.5 ? 0.5 : percent);
        CGFloat offset = mark_height * tpercent * 2 ;
        [path moveToPoint:CGPointMake(self.mj_w/2.0 + mark_height/2,LINE_HEIGHT+ mark_height/2)];
        [path addLineToPoint:CGPointMake(self.mj_w/2.0 + mark_height - offset, offset+ LINE_HEIGHT)];
    }
    if (percent > 0.5) {
        CGFloat tpercent = (percent > 0.75 ? 0.75 : percent);
        CGFloat offset = mark_height * (tpercent - 0.5) * 2;
        [path moveToPoint:CGPointMake(self.mj_w/2.0,LINE_HEIGHT + mark_height)];
        [path addLineToPoint:CGPointMake(self.mj_w/2.0 - offset, LINE_HEIGHT + mark_height - offset)];
    }
    if (percent > 0.75) {
        CGFloat tpercent = (percent > 1 ? 1 : percent);
        CGFloat offset = mark_height * (tpercent - 0.5) * 2;
        [path moveToPoint:CGPointMake(self.mj_w/2.0 - mark_height/2,LINE_HEIGHT + mark_height/2)];
        [path addLineToPoint:CGPointMake(self.mj_w/2.0 - mark_height + offset, LINE_HEIGHT+ mark_height - offset)];
    }

    if (!_isFinish && percent > 1) {
        if (_animationLayer == nil || _animationLayer.hidden) {
            [self animation3];
        }
        _isFinish = true;
    }
    _shapeLayer.path = path.CGPath;
}

-(void) animation3 {
    self.animationLayer.hidden = false;
    [_animationLayer start];
}
-(void) stopAnimation3 {
    self.animationLayer.hidden = true;
    [_animationLayer invalid];
}

@end

#pragma mark - 3 dots Animation

@interface JZAnimationLayer(){
    CALayer *dot;
}

@end
@implementation JZAnimationLayer

-(instancetype)init {
    self = [super init];
    
    [self prepare];
    
    return self;
}

- (void) prepare {
    dot = [CALayer layer];
    dot.bounds = CGRectMake(0, 0, 3, 3);
    dot.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor;
    dot.cornerRadius = 1.5;
    [self addSublayer:dot];
    
    self.instanceCount = 3;
    self.instanceDelay = 0.25;
    self.instanceTransform = CATransform3DMakeTranslation(6.0, 0.0, 0.0);
}

- (void)start {
    NSMutableArray *moveValues = [NSMutableArray array];
    [moveValues addObject:[NSNumber numberWithFloat:0.0]];
    [moveValues addObject:[NSNumber numberWithFloat:-6.0]];
    [moveValues addObject:[NSNumber numberWithFloat:2.0]];
    [moveValues addObject:[NSNumber numberWithFloat:0.0]];
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    move.keyTimes = @[@0.1,@0.35,@0.45,@0.6];;
    move.values = moveValues;
    
    CAKeyframeAnimation *opacityAnima = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnima.keyTimes = @[@0.1,@0.35,@0.45,@0.6];
    opacityAnima.values = @[@1.0, @0.0, @0.0, @1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.removedOnCompletion = false;
    group.repeatCount = HUGE;
    group.duration = 2;
    group.animations = @[move, opacityAnima];
    
    [dot addAnimation:group forKey:@"group"];
}

- (void)invalid {
    [dot removeAnimationForKey:@"group"];    
}

@end

#pragma mark -

@implementation UIScrollView (MJRefreshCustom)

- (JZMainRefreshHeader *)addJDMainHeaderViewWithRefreshingBlock:(void (^)())block {
    JZMainRefreshHeader *header = (JZMainRefreshHeader*)[JZMainRefreshHeader headerWithRefreshingBlock:block];
    self.mj_header = header;
    
    return header;
}

- (MJRefreshJZFooter *)addLegendFooterWithRefreshingBlock:(void (^)())block
{
    self.mj_footer = [MJRefreshJZFooter footerWithRefreshingBlock:block];
    return (MJRefreshJZFooter*)self.mj_footer;
}

- (MJRefreshJZHeader *)addJDHeaderViewWithRefreshingBlock:(void (^)())block dateKey:(NSString *)dateKey
{
    MJRefreshJZHeader *header = [MJRefreshJZHeader headerWithRefreshingBlock:block];
    self.mj_header = header;
    
    return header;
}

- (MJRefreshJZHeader *)addJDHeaderViewWithRefreshingBlock:(void (^)())block
{
    MJRefreshJZHeader *header = [MJRefreshJZHeader headerWithRefreshingBlock:block];
    self.mj_header = header;
    
    return header;
}
- (MJRefreshJZBaseHeader *)addLegendHeaderWithRefreshingBlock:(void (^)())block dateKey:(NSString *)dateKey
{
    MJRefreshJZBaseHeader *header = [MJRefreshJZBaseHeader headerWithRefreshingBlock:block];
    self.mj_header = header;
    
    return header;
}

- (MJRefreshJZFooter *)addLegendFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    MJRefreshJZFooter *footer = [MJRefreshJZFooter footerWithRefreshingTarget:target refreshingAction:action];
    self.mj_footer = footer;
    return footer;
}

- (void)removeFooter
{
    self.mj_footer = nil;
}

- (void)removeHeader
{
    self.mj_header = nil;
}

//- (MJRefreshJDHeaderView *)addJDHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action dateKey:(NSString *)dateKey
//{
//    MJRefreshJDHeaderView *header = [self addJDHeader];
//    header.refreshingTarget = target;
//    header.refreshingAction = action;
//    header.dateKey = dateKey;
//    return header;
//}


@end
