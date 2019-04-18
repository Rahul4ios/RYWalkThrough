//
//  RYWalkThroughView.m
//  ZebPay
//
//  Created by Rahul Yadav on 31/07/18.
//  Copyright © 2018 ZebPay Pte Ltd. All rights reserved.
//

#import "RYWalkThroughView.h"
#import "SuperClass.h"

/*** Macros ***/
#define kColor_bg_walkthrough   [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8]
#define kColor_txt_walkthrough  [UIColor whiteColor]
#define kFont_size_txt_walkthrough  14.0
#define kMargin_walkthrough 13.0
#define kColor_bg_walkthrough_btn_skip  [UIColor clearColor]
#define kColor_bg_walkthrough_btn  [ObjCMacros4Swift appThemeColor]
#define kConstant_walkthrough_btn_lblCenter 6.0
#define kConstant_walkthrough_btn_height 32.0


@implementation WalkThroughInfo
@end

@implementation WalkthroughInfoHole
@end

@implementation WalkthroughInfoHoleRect
@end

@implementation WalkthroughInfoHoleCircle
@end

@interface WalkthroughBtn()

@property (nonatomic) WalkthroughBtnType type;

@end
@implementation WalkthroughBtn
@end

@implementation RYWalkThroughView

+(RYWalkThroughView*)addPage:(WalkThroughInfo *)info{
    
    // Check
//    if (!info.parentView || !info.holeInfo || ![[SuperClass sharedSingletonSuperClass] checkifStringNotNull:info.text]) {
    if (!info.parentView || !info.holeInfo) {
        // Case: these values are needed
        
        return nil;
    }
    
    RYWalkThroughView *overlay = [[RYWalkThroughView alloc] init];
    overlay.backgroundColor = [UIColor clearColor]; // clear BG
    
    // Add to superView as an overlay
    [[SuperClass sharedSingletonSuperClass] addOverlay:overlay onView:info.parentView superView:info.parentView];
    
    //// Layer
    
    // Black path
    UIBezierPath *blackPath = [UIBezierPath bezierPathWithRect:info.parentView.bounds];
    
    // Hole path
    
    UIBezierPath *holePath = nil;
    CGFloat centerXHole = 0.0, holeMaxY = 0.0, holeHeight = 0.0;
    
    if ([info.holeInfo isKindOfClass:[WalkthroughInfoHoleRect class]]) {
        // Case: rectangular hole
        
        WalkthroughInfoHoleRect *holeRectInfo = (WalkthroughInfoHoleRect*)info.holeInfo;
        
        holePath = [UIBezierPath bezierPathWithRoundedRect:holeRectInfo.rect cornerRadius:holeRectInfo.cornerRadius];
        
        centerXHole = CGRectGetMidX(holeRectInfo.rect);
        holeMaxY = CGRectGetMaxY(holeRectInfo.rect);
        holeHeight = holeRectInfo.rect.size.height;
    }
    else if([info.holeInfo isKindOfClass:[WalkthroughInfoHoleCircle class]]){
        // Case: circular hole
        
        WalkthroughInfoHoleCircle *holeCircleInfo = (WalkthroughInfoHoleCircle*)info.holeInfo;
        
        holePath = [UIBezierPath bezierPathWithArcCenter:holeCircleInfo.center radius:holeCircleInfo.radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        holePath.lineWidth = holeCircleInfo.radius;
        
        centerXHole = holeCircleInfo.center.x;
        holeMaxY = holeCircleInfo.center.y + holeCircleInfo.radius;
        holeHeight = holeCircleInfo.radius * 2;
    }
    else{
        // Case: return
        
        return nil;
    }
    
    [blackPath appendPath:holePath];
    [blackPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = blackPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = kColor_bg_walkthrough.CGColor;
    
    [overlay.layer addSublayer:fillLayer];
    
    //// Up/Down
    
    BOOL downwards = YES;
    
    UIFont *txtFont = [UIFont fontWithName:kFont_name_openSans size:kSize_dynamic(kFont_size_txt_walkthrough)];
    
    CGFloat globalMargin = kSize_dynamic(kMargin);
    CGFloat localMargin = kSize_dynamic(kMargin_walkthrough);
    
    CGSize txtSizeMax = CGSizeMake(CGRectGetWidth(overlay.bounds), CGRectGetHeight(overlay.bounds));
    CGRect txtRect = [info.text boundingRectWithSize:txtSizeMax options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: txtFont} context:nil];
    
    CGFloat reqContentMaxY = holeMaxY + localMargin + txtRect.size.height + localMargin + kSize_dynamic(kConstant_walkthrough_btn_height) + localMargin;
    if (reqContentMaxY > CGRectGetHeight(info.parentView.bounds)) {
        // Case: need to write content upwards
        
        downwards = NO;
    }
    
    UIView *firstView = nil;
    
    if (info.text) {
        // Case: text exists
        
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = kColor_txt_walkthrough;
        lbl.font = txtFont;
        lbl.numberOfLines = 0;
        
        lbl.text = info.text;
        
        //
        firstView = lbl;
    }
    else{
        // Case: text doesn't exist
        
        // Need to add a dummy view
        
        firstView = [[UIView alloc] initWithFrame:CGRectZero];
        firstView.backgroundColor = [UIColor clearColor];
    }
    [overlay addSubview:firstView];
    
    firstView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat txtTopConst = 0.0;
    if (downwards) {
        // Case: downwards
        
        txtTopConst = holeMaxY + localMargin;
    }
    else{
        // Case: upwards
        
        txtTopConst = holeMaxY - holeHeight - localMargin - kSize_dynamic(kConstant_walkthrough_btn_height) - localMargin - txtRect.size.height;
    }
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:firstView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:txtTopConst];
    [firstView.superview addConstraint:top];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:firstView.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:globalMargin];   // >=
    [firstView.superview addConstraint:leading];
    
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:firstView.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:-globalMargin];   // <=
    [firstView.superview addConstraint:trailing];
    
    CGFloat holeCenterXDiffParent = centerXHole - CGRectGetMidX(info.parentView.bounds);
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:firstView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:holeCenterXDiffParent];
    centerX.priority = UILayoutPriorityDefaultHigh; // not at required level
    [firstView.superview addConstraint:centerX];
    
    //// Buttons
    
    if (info.lastPage) {
        // Case: last page
        
        [overlay addBtnWithTitleLocKey:kKey_localizable_done firstView:firstView];
    }
    else{
        // Case: intermediate page
        
        [overlay addBtnWithTitleLocKey:kKey_localizable_skip firstView:firstView];
        [overlay addBtnWithTitleLocKey:kKey_localizable_next firstView:firstView];
    }
    
    return overlay;
}

/**
 Add button at required place
 @param btnTitleLocKey    -   title of the btn
 @param firstView -   firstView(label/dummy view)
 */
-(void)addBtnWithTitleLocKey:(NSString*)btnTitleLocKey firstView:(UIView*)firstView{
    
    CGFloat globalMargin = kSize_dynamic(kMargin);
    CGFloat localMargin = kSize_dynamic(kMargin_walkthrough);
    
    WalkthroughBtn *btn = [[WalkthroughBtn alloc] init];
    [btn setTitle:NSLocalizedString(btnTitleLocKey, nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:kFont_name_openSans size:kSize_dynamic(kFont_size_txt_walkthrough)];
    [btn setTitleColor:kColor_txt_walkthrough forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *bgColor = [ObjCMacros4Swift appThemeColor];
    if ([btnTitleLocKey isEqualToString:kKey_localizable_skip]) {
        // Case: type: Skip
        
        bgColor = kColor_bg_walkthrough_btn_skip;
        
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = kColor_txt_walkthrough.CGColor;
        
        btn.type = WALKTHROUGH_BTN_TYPE_SKIP;
    }
    else if ([btnTitleLocKey isEqualToString:kKey_localizable_next]){
        // Case: type: next
        
        btn.type = WALKTHROUGH_BTN_TYPE_NEXT;
    }
    else{
        // Case: type: done
        
        btn.type = WALKTHROUGH_BTN_TYPE_DONE;
    }
    btn.backgroundColor = bgColor;
    
    [self addSubview:btn];
    
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeBottom multiplier:1 constant:localMargin];
    [btn.superview addConstraint:top];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:btn.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:globalMargin];   // >=
    [btn.superview addConstraint:leading];
    
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:btn.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:-globalMargin];   // <=
    [btn.superview addConstraint:trailing];
    
    NSLayoutAttribute centerXAttr = NSLayoutAttributeCenterX;   // Case: Done
    CGFloat centerXConstant = 0.0;
    if ([btnTitleLocKey isEqualToString:kKey_localizable_skip]) {
        // Case: Skip
        
        centerXAttr = NSLayoutAttributeTrailing;
        centerXConstant = -kSize_dynamic(kConstant_walkthrough_btn_lblCenter);
    }
    else if ([btnTitleLocKey isEqualToString:kKey_localizable_next]){
        // Case: Next
        
        centerXAttr = NSLayoutAttributeLeading;
        centerXConstant = kSize_dynamic(kConstant_walkthrough_btn_lblCenter);
    }
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:btn attribute:centerXAttr relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:centerXConstant];
    [btn.superview addConstraint:centerX];
    
    CGSize widthSizeMax = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));  // not significant
    CGFloat txtWidth = [[btn titleForState:UIControlStateNormal] boundingRectWithSize:widthSizeMax options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: btn.titleLabel.font} context:nil].size.width;
    txtWidth += 2 * localMargin;
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:txtWidth];
    [btn addConstraint:width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kSize_dynamic(kConstant_walkthrough_btn_height)];
    [btn addConstraint:height];
    
    btn.layer.cornerRadius = kSize_dynamic(kConstant_walkthrough_btn_height) * kCornerRadius_perc_height;
}

/**
 Button is tapped
 @param btn -   btn
 */
-(void)btnTapped:(WalkthroughBtn*)btn{
    
    if (self.delegate) {
        // Case: delegate exists
        
        if ([self.delegate respondsToSelector:@selector(RYWalkthroughBtnTapped:)]) {
            // Case: responds to selector
            
            [self.delegate RYWalkthroughBtnTapped:btn.type];
        }
    }
}
@end
