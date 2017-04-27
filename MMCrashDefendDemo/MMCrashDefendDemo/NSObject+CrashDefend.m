//
//  NSObject+CrashDefend.m
//  MMCrashDefend
//
//  Created by wyy on 2017/4/13.
//  Copyright © 2017年 wyy. All rights reserved.
//

#import "NSObject+CrashDefend.h"
#import <objc/objc-runtime.h>
#import "MMErrorMessageInformation.h"
@implementation NSObject (CrashDefend)
+ (void)mm_swizzleWithSourceMethod:(SEL)sourceSel
                         targetSel:(SEL)targetSel {
 
    [self mm_swizzleWithSourceClass:[self class]   sourceMethod:sourceSel targetClass:[self class] targetMethod:targetSel];
}

+ (void)mm_swizzleWithSourceMethod:(SEL)sourceSel
                   targetClassName:(NSString *)targetClassName
                      targetMethod:(SEL)targetSel {
  if (!sourceSel && !targetClassName && !targetSel) return;
   [self mm_swizzleWithSourceClass:[self class] sourceMethod:sourceSel targetClass:NSClassFromString(targetClassName) targetMethod:targetSel];
}

+ (void)mm_swizzleWithSourceClass:(Class)sourceClass
                     sourceMethod:(SEL)sourceSel
                      targetClass:(Class)targetClass
                     targetMethod:(SEL)targetSel {
    if (!sourceClass && !sourceSel && !targetClass && !targetSel) return;

    Method srcInstance = class_getInstanceMethod(sourceClass, sourceSel);
    Method tarInstance = class_getInstanceMethod(targetClass, targetSel);
    method_exchangeImplementations(srcInstance, tarInstance);

}

+ (void)mm_swizzleWithSameClass:(Class)class
                   sourceMethod:(SEL)sourceSel
                   targetMethod:(SEL)targetSel {
   [self mm_swizzleWithSourceClass:class   sourceMethod:sourceSel targetClass:class targetMethod:targetSel];
}


- (void)mm_logErrorMessage:(NSString *)message {
    NSString *startStr = @"=======================错误信息=======================";
    NSString *endStr = @"=====================================================";
//    NSString *str = [NSString stringWithFormat:@"\n%@\n错误提示：\n%@\n调用栈情况：\n%@\n\n%@",startStr, message, [NSThread callStackSymbols], endStr];
    
    NSLog(@"%@",message);
}
@end

#pragma mark - NSDictionary && NSMutableDictionary
@implementation NSDictionary (CrashDefend)

+ (void)load {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       NSString *className = @"__NSPlaceholderDictionary";
       [self mm_swizzleWithSourceMethod:@selector(mm_initWithObjects:forKeys:count:) targetClassName:className targetMethod:@selector(initWithObjects:forKeys:count:)];
       [self mm_swizzleWithSourceMethod:@selector(mm_dictionaryWithObjects:forKeys:count:) targetClassName:className targetMethod:@selector(dictionaryWithObjects:forKeys:count:)];
          });
}

- (instancetype)mm_initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id newKeys[cnt];
    id newObjects[cnt];
    NSUInteger newCount = 0;
    for (int index = 0; index < cnt; index ++) {
        id key = keys[index];
        id obj = objects[index];
        if (!key) continue;
        if (!obj) obj = [NSNull null];
        newKeys[index] = key;
        newObjects[index] = obj;
        newCount ++;
    }
    return [self mm_initWithObjects:newObjects forKeys:newKeys count:newCount];
}

+ (instancetype)mm_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id newKeys[cnt];
    id newObjects[cnt];
    NSUInteger newCount = 0;
    for (int index = 0; index < cnt; index ++) {
        id key = keys[index];
        id obj = objects[index];
        if (!key) continue;
        if (!obj) obj = [NSNull null];
        newKeys[index] = key;
        newObjects[index] = obj;
        newCount ++;
    }
    return [self mm_dictionaryWithObjects:newObjects forKeys:newKeys count:newCount];
}
@end

@implementation NSMutableDictionary (CrashDefend)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSDictionaryM");
        [class mm_swizzleWithSourceMethod:@selector(setObject:forKey:) targetSel:@selector(mm_setObject:forKey:)];
        
    });
}

- (void)mm_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) return;
    if (!anObject) anObject = [NSNull null];
    
    return [self mm_setObject:anObject forKey:aKey];
}
@end

#pragma mark - NSArray
@implementation NSArray (CrashDefend)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self mm_swizzleWithSourceMethod:@selector(mm_initWithObjects:count:) targetClassName:@"__NSPlaceholderArray" targetMethod:@selector(initWithObjects:count:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_objectAtIndex:) targetClassName:@"__NSArrayI" targetMethod:@selector(objectAtIndex:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_emptyArrayobjectAtIndex:) targetClassName:@"__NSArray0" targetMethod:@selector(objectAtIndex:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_singleArrayobjectAtIndex:) targetClassName:@"__NSSingleObjectArrayI" targetMethod:@selector(objectAtIndex:)];
    });
}

- (instancetype)mm_initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    NSUInteger newCount = 0;
    id newObjects[cnt];
    for (int index = 0; index < cnt; index ++) {
        id obj = objects[index];
        if (!obj) {
            [self mm_logErrorMessage:Array_InitMethodContainedNil];
        }
#ifdef isNeedNull
        if (!obj) obj = [NSNull null];
        newObjects[index] = obj;
        newCount ++;
#else
        if (!obj) continue;
        newObjects[newCount] = obj;
        newCount ++;
#endif
        
    }
    return [self mm_initWithObjects:newObjects count:newCount];
}

- (instancetype)mm_objectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return nil;
    }
    return [self mm_objectAtIndex:index];
}


- (instancetype)mm_emptyArrayobjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return nil;
    }
    return [self mm_emptyArrayobjectAtIndex:index];
}

- (instancetype)mm_singleArrayobjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return nil;
    }
    return [self mm_singleArrayobjectAtIndex:index];
}

@end

@implementation NSMutableArray (CrashDefend)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self mm_swizzleWithSourceMethod:@selector(mm_mutableArrayObjectAtIndex:) targetClassName:@"__NSArrayM" targetMethod:@selector(objectAtIndex:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_addObject:) targetClassName:@"__NSArrayM" targetMethod:@selector(addObject:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_removeObjectAtIndex:) targetClassName:@"__NSArrayM" targetMethod:@selector(removeObjectAtIndex:)];
        [self mm_swizzleWithSourceMethod:@selector(mm_insertObject:atIndex:) targetClassName:@"__NSArrayM" targetMethod:@selector(insertObject:atIndex:)];
    });
}

- (instancetype)mm_mutableArrayObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return nil;
    }
    return [self mm_mutableArrayObjectAtIndex:index];
}

- (void)mm_addObject:(id)object {
    if(!object) {
    [self mm_logErrorMessage:Array_addNil];
#ifdef isNeedNull
      object = [NSNull null];
#else
      return;
#endif
    }
    [self mm_addObject:object];
}

- (void)mm_removeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return;
    }
    return [self mm_removeObjectAtIndex:index];
}

- (void)mm_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index > self.count) {
        [self mm_logErrorMessage:Array_BeyondBounds];
        return;
    }
    
    if (!anObject) {
#ifdef isNeedNull
        anObject = [NSNull null];
#else   
        [self mm_logErrorMessage:Array_addNil];
        return;
#endif
    }
    return [self mm_insertObject:anObject atIndex:index];
}
@end

#pragma mark - NSNull
@implementation NSNull (CrashDefend)
void swizzle(Class class, SEL sourceSel, SEL targetSel) {
    Method origMethod = class_getInstanceMethod(class, sourceSel);
    Method newMethod = class_getInstanceMethod(class, targetSel);
    if (class_addMethod(class, sourceSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(class, targetSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzle(self, @selector(methodSignatureForSelector:) , @selector(mm_methodSignatureForSelector:));
        swizzle(self, @selector(mm_forwardInvocation:) ,@selector(forwardInvocation:));
    
    });
}

- (NSMethodSignature *)mm_methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [self mm_methodSignatureForSelector:sel];
    if (signature) return signature;
    return [NSMethodSignature signatureWithObjCTypes:@encode(void)];
}

- (void)mm_forwardInvocation:(NSInvocation *)invocation {
    NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];
    if (!returnLength) return;
    
    char buffer[returnLength];
    memset(buffer, 0, returnLength);
    [invocation setReturnValue:buffer];
    free(buffer);
}

@end
