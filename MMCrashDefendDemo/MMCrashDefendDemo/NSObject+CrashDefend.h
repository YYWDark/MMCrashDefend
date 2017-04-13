//
//  NSObject+CrashDefend.h
//  MMCrashDefend
//
//  Created by wyy on 2017/4/13.
//  Copyright © 2017年 wyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (CrashDefend)

@end

@interface NSDictionary (CrashDefend)

@end

@interface NSMutableDictionary (CrashDefend)

@end

@interface NSObject (CrashDefend)
+ (void)mm_swizzleWithSourceMethod:(SEL)sourceSel
                         targetSel:(SEL)sel;

+ (void)mm_swizzleWithSourceMethod:(SEL)sourceSel
                   targetClassName:(NSString *)targetClassName
                      targetMethod:(SEL)targetSel;

+ (void)mm_swizzleWithSourceClass:(Class)sourceClass
                     sourceMethod:(SEL)sourceSel
                      targetClass:(Class)targetClass
                     targetMethod:(SEL)targetSel;


+ (void)mm_swizzleWithSameClass:(Class)class
                   sourceMethod:(SEL)sourceSel
                   targetMethod:(SEL)targetSel;


@end

