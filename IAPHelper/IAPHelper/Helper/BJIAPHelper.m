//
//  BJIAPHelper.m
//  01-内购
//
//  Created by yiche on 2019/3/27.
//  Copyright © 2019 itcast. All rights reserved.
//

#import "BJIAPHelper.h"
#import "AppDelegate.h"



static NSString *productId = @"productId";



@interface BJIAPHelper ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, strong)SKProductsRequest *productsRequest;
@property (nonatomic, copy)ProductsRequestCompletionHandler productsRequestCompletionHandler;
@property (nonatomic, strong)SKPayment *payMent;

@end

@implementation BJIAPHelper

+ (void)addTransactionObserver {
     [[SKPaymentQueue defaultQueue] addTransactionObserver:[BJIAPHelper defaultHelper]];
}

+ (instancetype)defaultHelper {
    static dispatch_once_t onceToken;
    static BJIAPHelper *_helper = nil;
    dispatch_once(&onceToken, ^{
        if (_helper == nil) {
            _helper = [[BJIAPHelper alloc] init];
        }
    });
    return _helper;
}

- (void)requestProductsWithCompletionHandler:(ProductsRequestCompletionHandler)completionHandler {
    [self.productsRequest cancel];
    self.productsRequestCompletionHandler = completionHandler;
    NSArray *result = [[NSArray alloc] initWithObjects:productId, nil];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:result]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)buyProduct:(SKProduct *)product {
    NSLog(@"Buying %@ ... ",product.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)buyPayment:(SKPayment *)payment {
     [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}


#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    NSArray *products = response.products;
    self.productsRequestCompletionHandler(YES, products);
    [self clearRequestAndHandler];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    NSLog(@"Error: %@",error.localizedDescription);
    self.productsRequestCompletionHandler(NO, nil);
    [self clearRequestAndHandler];
}

- (void)clearRequestAndHandler {
    self.productsRequest = nil;
    self.productsRequestCompletionHandler = nil;
}

- (void)appStoreMoveToViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:iAPAPPStoreNotification object:self.payMent];
}

#pragma mark - SKPaymentTransactionObserver
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    if (payment) {
        NSLog(@"从APP Store点击订阅的跳转");
        //交给对应控制器去处理内购事宜，一般是交付给APPDelegate
        [self appStoreMoveToViewController];
    }
    return NO;
}

/*
 SKPaymentTransactionStatePurchasing,    // 交易在队列中.
 SKPaymentTransactionStatePurchased,     // 交易在队列中, 已经付款了.  客户端应该完成交易.
 SKPaymentTransactionStateFailed,        // 交易被添加到队列中之前,被取消.
 SKPaymentTransactionStateRestored,      // 用户从购买历史中又一次购买
 SKPaymentTransactionStateDeferred      // 交易信息不明.
 */
// 购买操作后的回调.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    // 这里的事务包含之前没有完成的.
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: // 交易在队列中.
                NSLog(@"交易中...");
                break;
            case SKPaymentTransactionStatePurchased:  // 交易在队列中, 已经付款了.  客户端应该完成交易.
                [self completeWithTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:   // 交易被添加到队列中之前,被取消.
                [self failWithTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:  // 用户从购买历史中又一次购买
                [self restoreWithTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:  // 交易信息不明.
                break;
        }
    }
}

- (void)completeWithTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"complete..");
    [self deliverPurchaseNotification:transaction];
}

- (void)restoreWithTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"restore..");
    [self deliverPurchaseNotification:transaction];
}

- (void)failWithTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"%@",transaction.error.localizedDescription);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


/// 创建订单
- (void)createOrderWithPaymentTransaction:(SKPaymentTransaction *)paymentTransaction {
    // 创建订单后，返回订单号
    [self verificationWithOrderId:@"订单号" paymentTransaction:paymentTransaction];
}

/**
 验证订单

 @param orderNo 订单号
 @param paymentTransaction 交易记录
 */
- (void)verificationWithOrderId:(NSString *)orderNo paymentTransaction:(SKPaymentTransaction *)paymentTransaction {
    NSLog(@"发给服务器进行验证");
   
}

- (void)deliverPurchaseNotification:(SKPaymentTransaction*)transaction {
    if (transaction)
        [self createOrderWithPaymentTransaction:transaction];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
