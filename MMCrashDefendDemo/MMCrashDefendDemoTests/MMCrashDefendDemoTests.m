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

#pragma mark - NSDictionary && NSMutableDictionary
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
    XCTAssertEqual([[mutableDic allKeys] count], 0);
    [mutableDic setObject:nilVal forKey:nonNilKey];
    id val = mutableDic[nonNilKey];
    XCTAssertNoThrow([val length]);
    [mutableDic setObject:nonNilVal forKey:nilKey];
    XCTAssertEqual([[mutableDic allKeys] count], 1);
}

#pragma mark - NSArray
- (void)testArray_InitMethod {
    id nilVal = nil;
    id value1 = @"1";
    id value2 = @"2";
    
    NSArray *empty = @[];
    XCTAssertEqual(empty.count, 0);
    
    NSArray *array1 = @[nilVal,value1];
    XCTAssertEqual([[array1 lastObject] integerValue], 1);
    
#ifdef isNeedNull
    NSArray *array2 = @[value1,nilVal];
    XCTAssertEqualObjects([array2 lastObject], [NSNull null]);
    NSArray *array3 = @[value1,nilVal,value2];
    XCTAssertEqual(array3.count, 3);
#else
    NSArray *array2 = @[value1,nilVal];
    XCTAssertEqual([[array2 lastObject] integerValue], 1);
    NSArray *array3 = @[value1,nilVal,value2];
    XCTAssertEqual(array3.count, 2);
#endif
}

- (void)testArray_GetValue {
    int count = 100;
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int index = 0; index < count; index ++) {
        [mutableArray addObject:@(index)];
    }
    for (int index = 0; index < (count + 1); index ++) {
        id value = mutableArray[index];
        (index == count)?XCTAssertNil(value):XCTAssertNotNil(value);
        
    }
    
    NSArray *array = [mutableArray copy];
    for (int index = 0; index < (count + 1); index ++) {
        id value = array[index];
        (index == count)?XCTAssertNil(value):XCTAssertNotNil(value);
    }
    
    NSArray *emptyCountArray = @[];
    XCTAssertNil(emptyCountArray[1]);
    NSMutableArray *emptyCountMutableArray = [emptyCountArray mutableCopy];
    XCTAssertNil(emptyCountMutableArray[1]);
    
    NSArray *singerCountArray = @[@"1"];
    XCTAssertNil(singerCountArray[2]);
    NSMutableArray *singerCountMutableArray = [emptyCountArray mutableCopy];
    XCTAssertNil(singerCountMutableArray[2]);
}

- (void)testMutableArray_addNil {
    id nilVal = nil;
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    [mutableArray addObject:@"1"];
    [mutableArray addObject:nilVal];
    
    [mutableArray removeObject:@"2"];
    [mutableArray removeObjectAtIndex:3];
    [mutableArray removeObjectAtIndex:0];
    
    [mutableArray insertObject:nilVal atIndex:2];
    [mutableArray insertObject:nilVal atIndex:1];
    [mutableArray insertObject:@"3" atIndex:3];
    
}
@end
