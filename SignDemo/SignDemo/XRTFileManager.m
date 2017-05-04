//
//  XRTFileManager.m
//  SignDemo
//
//  Created by wyy on 2017/5/3.
//  Copyright © 2017年 hubei. All rights reserved.
//

#import "XRTFileManager.h"

@implementation XRTFileManager
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)information {
    if (path.length == 0 || information == nil) return NO;
    if (![self isExistsAtPath:path]) {
        if (![self createDirectoryAtPath:path error:nil]) return NO;
    }
    
    NSError *error = nil;
    if ([information isKindOfClass:[NSString class]]) {
        if ([(NSString *)information writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            return YES;
        }
    }else if([information isKindOfClass:[NSArray class]]) {
        //读取以前的数据
        
        NSArray * array= [self readFileFromPath:[self preferencesDir]];
        NSArray *jointArray = [self jointFromSourceArray:array targetArray:(NSArray *)information];
        if ([(NSArray *)jointArray writeToFile:path atomically:YES]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path  error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager createFileAtPath:path contents:nil attributes:nil];;
    return isSuccess;
}

+ (NSString *)libraryDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)preferencesDir {
    NSString *libraryDir = [self libraryDir];
    return [libraryDir stringByAppendingPathComponent:@"test.txt"];
}


+ (NSArray *)readFileFromPath:(NSString *)path {
    NSArray *content = [NSArray arrayWithContentsOfFile:path];
//    NSLog(@"read success: %@",content);
    return content;
}

+ (NSArray *)jointFromSourceArray:(NSArray *)sourceArray targetArray:(NSArray *)targetArray {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [mutableArray addObjectsFromArray:sourceArray];
    [mutableArray addObject:@"===================================================================================="];
    [mutableArray addObject:targetArray];
    return [mutableArray copy];
}
@end
