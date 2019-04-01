//
//  BJIAPHelper.h
//  01-内购
//
//  Created by yiche on 2019/3/27.
//  Copyright © 2019 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

static NSString * _Nullable iAPAPPStoreNotification = @"iAPAPPStoreNotification";
/// 验证通知
static NSString * _Nullable iAPStartCreateOrder = @"iAPStartCreateOrder";
static NSString * _Nullable iAPVerificationSuccess = @"iAPEndVerification";
static NSString * _Nullable iAPCreateError = @"iAPCreateError";



typedef void(^ProductsRequestCompletionHandler)(BOOL isSuccess,NSArray<SKProduct*> * _Nullable products);

NS_ASSUME_NONNULL_BEGIN

@interface BJIAPHelper : NSObject
+ (instancetype)defaultHelper;
/// 添加监听最好是放在应用启动程序时
+ (void)addTransactionObserver;
- (BOOL)canMakePayments;

/// 发起购买列表的请求
- (void)requestProductsWithCompletionHandler:(ProductsRequestCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product ;
- (void)buyPayment:(SKPayment *)payment;

@end

NS_ASSUME_NONNULL_END
