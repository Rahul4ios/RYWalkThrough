//
//  RYWalkThroughView.h
//  ZebPay
//
//  Created by Rahul Yadav on 31/07/18.
//  Copyright © 2018 ZebPay Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WALKTHROUGH_BTN_TYPE_SKIP,
    WALKTHROUGH_BTN_TYPE_NEXT,
    WALKTHROUGH_BTN_TYPE_DONE,
} WalkthroughBtnType;

@protocol RYWalkthroughDelegate

/**
 User taps on a button with type.
 @param type    -   button type
 */
-(void)RYWalkthroughBtnTapped:(WalkthroughBtnType)type;

@end

@interface WalkthroughInfoHole: NSObject    // Abstract class
@end

@interface WalkthroughInfoHoleRect: WalkthroughInfoHole
    
@property (nonatomic) CGRect rect;
@property (nonatomic) CGFloat cornerRadius;

@end

@interface WalkthroughInfoHoleCircle: WalkthroughInfoHole

@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;

@end

@interface WalkThroughInfo: NSObject

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic) WalkthroughInfoHole *holeInfo;
@property (nonatomic) NSString *text;
@property (nonatomic) BOOL lastPage;    // is it the last page?

@end

@interface WalkthroughBtn:UIButton
@end

@interface RYWalkThroughView : UIView

@property (nonatomic, weak) id<RYWalkthroughDelegate, NSObject> delegate;

/**
 Returns a fully configured overlay view
 @param info    -   a structure having hole dimension and type, text, buttons title and type.
 */
+(RYWalkThroughView*)addPage:(WalkThroughInfo*)info;

@end
