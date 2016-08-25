//
//  LBToAppStore.h
//  LBToAppStore
//
//  Created by gold on 16/5/3.
//  Copyright © 2016年 Bison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>



@interface LBToAppStore : NSObject<UIAlertViewDelegate>
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    
    UIAlertView *alertViewTest;
    
#else
    
    UIAlertController *alertController;
    
#endif
    
    
}

@property (nonatomic,strong) NSString * myAppID;//appID


- (void)showGotoAppStore:(UIViewController *)VC;

@end
