//
//  MMCrashDefendDemoTests.m
//  MMCrashDefendDemoTests
//
//  Created by wyy on 2017/4/13.
//  Copyright © 2017年 wyy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+CrashDefend.h"

@interface MMCrashDefendDemoTests : XCTestCase

@end

@implementation MMCrashDefendDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - NSDictionary
- (void)testDictionary_InitMethod {
    id nilVal = nil;
    id nilKey = nil;
    id nonNilKey = @"non-nil-key";
    id nonNilVal = @"non-nil-val";
    NSDictionary *dict = @{nonNilKey: nilVal,
                           nilKey: nonNilVal,
                           };
    XCTAssertEqualObjects([dict allKeys], @[nonNilKey]);
    XCTAssertNoThrow([dict objectForKey:nonNilKey]);
    id val = dict[nonNilKey];
    XCTAssertEqualObjects(val, [NSNull null]);
    XCTAssertNoThrow([val length]);
    XCTAssertNoThrow([val count]);
    XCTAssertNoThrow([val anyObject]);
    XCTAssertNoThrow([val intValue]);
    XCTAssertNoThrow([val integerValue]);
}

- (void)testDictionary_SetObjectMethod {
    id nilVal = nil;
    id nilKey = nil;
    id nonNilKey = @"non-nil-key";
    id nonNilVal = @"non-nil-val";
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    
    [mutableDic setObject:nilVal forKey:nilKey];
    [mutableDic setObject:nilVal forKey:nonNilKey];
    [mutableDic setObject:nonNilVal forKey:nilKey];
    
}
@end
