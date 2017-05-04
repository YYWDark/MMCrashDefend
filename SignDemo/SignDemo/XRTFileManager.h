//
//  XRTFileManager.h
//  SignDemo
//
//  Created by wyy on 2017/5/3.
//  Copyright © 2017年 hubei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XRTFileManager : NSObject
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)information;

+ (NSString *)preferencesDir;
@end
