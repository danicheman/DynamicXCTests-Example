//
//  ParametrizedTestCase.m
//  DynamicXCTests-ExampleTests
//
//  Created by Denis Bogomolov on 20/03/2019.
//  Copyright © 2019 BDK. All rights reserved.
//

#import "ParametrizedTestCase.h"
//#import "DynamicXCTests-ExampleTests-Bridging-Header.h"
#import "DynamicXCTests_ExampleTests-Swift.h"

@implementation ParametrizedTestCase
/*static NSInvocation* invocationFromQSW(_QuickSelectorWrapper *wrapper) {
    SEL selector = wrapper.selector;
    NSMethodSignature *signature = [ParametrizedTestCase instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    return invocation
}*/

//static NSInvocation* invocationFromParamTest(ParamTest *paramTest) {
//}

/*
 + (NSArray<NSInvocation *> *)testInvocations {
    NSArray<_QuickSelectorWrapper *> *wrappers = [self _qck_testMethodSelectors];
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:wrappers.count];
    
    RuntimeTests rtt = [[RuntimeTests alloc ] init ];
    [rtt initGetParamTests];
    //RuntimeTests 
    for (_QuickSelectorWrapper *wrapper in wrappers) {
        NSInvocation *invocation = invocationFromQSW(wrapper);
        [invocations addObject:invocation];
    }
    [invocations addObjectsFromArray:[super testInvocations]];
    return invocations;
}*/
+ (NSArray<NSInvocation *> *)getParamInvocations: (NSDictionary<NSString*, ParamTest*>*)paramTests instance:(ParametrizedTestCase *)instance {
    NSMutableArray<NSInvocation *> *paramInvocations = [NSMutableArray new];
    [paramTests enumerateKeysAndObjectsUsingBlock:^(NSString *testName, ParamTest* paramTest, BOOL *stop) {
        SEL selector = method_getName(paramTest.test);
        //IMP implementation = ;
        
        //invoke the dataprovider
        NSDictionary<NSString*,NSObject*> *parameters = [instance performSelector:method_getName(paramTest.dataProvider)];
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull paramName, NSObject* _Nonnull parameter, BOOL * _Nonnull stop) {
            SEL paramTestSelector = NSSelectorFromString([NSString stringWithFormat:@"%@_%@", testName, paramName]);
            NSMethodSignature *signature = [instance methodSignatureForSelector:selector];
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            Account *myAccount = (Account*)parameter;
//            NSLog(@"Account locale: ");
            NSLog(@"%@", myAccount.locale);
            //invocation.selector = selector;
            [invocation setArgument:(__bridge_retained void *)(myAccount) atIndex:2];
            [invocation setSelector:paramTestSelector];
            class_addMethod(self, paramTestSelector, method_getImplementation(paramTest.test), method_getTypeEncoding(paramTest.test));
            [paramInvocations addObject:invocation];
            
        }];
        
    }];
    return [paramInvocations copy];
}

+ (NSArray<NSInvocation *> *)testInvocations {
    NSArray<NSInvocation *> *defaultInvocations = [super testInvocations];
    ParametrizedTestCase *instance = [self getInstance];
    if ([instance conformsToProtocol:@protocol(ParamTestProvider)]) {
        
        //ParametrizedTestCase<ParamTestProvider> *provider = (ParametrizedTestCase<ParamTestProvider> *)instance;
        NSDictionary<NSString*, ParamTest*> *paramTests = [(ParametrizedTestCase<ParamTestProvider> *)instance getParamTests];
        //NSDictionary<id, id> *paramTests = [provider getParamTests];
        NSArray<NSInvocation *> *paramInvocations = [self getParamInvocations:paramTests instance:instance];
        return [defaultInvocations arrayByAddingObjectsFromArray:paramInvocations];
    } else {
        return defaultInvocations;
    }
}

+ (ParametrizedTestCase*)getInstance {
    return [[self alloc]init];
}


@end
