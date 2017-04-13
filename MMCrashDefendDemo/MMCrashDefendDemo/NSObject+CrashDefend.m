//
//  NSObject+CrashDefend.m
//  MMCrashDefend
//
//  Created by wyy on 2017/4/13.
//  Copyright © 2017年 wyy. All rights reserved.
//

#import "NSObject+CrashDefend.h"
#import <objc/objc-runtime.h>


@implementation NSObject (CrashDefend)
+ (void)mm_swizzleWithSourceMethod:(SEL)origSel
                         targetSel:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(self, origSel);
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!origMethod || !altMethod) {
        return ;
    }
    class_addMethod(self,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, origSel),
                                   class_getInstanceMethod(self, altSel));
    
//    [self mm_swizzleWithSourceClass:[self class]   sourceMethod:sourceSel targetClass:[self class] targetMethod:targetSel];
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
    
    /*
    method_exchangeImplementations(srcInstance, tarInstance);
        class_addMethod(self,
                        sourceSel,
                        class_getMethodImplementation(self, sourceSel),
                        method_getTypeEncoding(srcInstance));
        class_addMethod(self,
                        targetSel,
                        class_getMethodImplementation(self, targetSel),
                        method_getTypeEncoding(tarInstance));
    
        method_exchangeImplementations(class_getInstanceMethod(self, sourceSel),
                                       class_getInstanceMethod(self, targetSel));
    
   */
}

+ (void)mm_swizzleWithSameClass:(Class)class
                   sourceMethod:(SEL)sourceSel
                   targetMethod:(SEL)targetSel {
    
    Method srcInstance = class_getInstanceMethod(self, sourceSel);
    Method tarInstance = class_getInstanceMethod(self, targetSel);
    
    method_exchangeImplementations(srcInstance, tarInstance);
    class_addMethod(self,
                    sourceSel,
                    class_getMethodImplementation(self, sourceSel),
                    method_getTypeEncoding(srcInstance));
    class_addMethod(self,
                    targetSel,
                    class_getMethodImplementation(self, targetSel),
                    method_getTypeEncoding(tarInstance));
    
    method_exchangeImplementations(class_getInstanceMethod(self, sourceSel),
                                   class_getInstanceMethod(self, targetSel));
}

@end


@implementation NSDictionary (CrashDefend)
static dispatch_once_t onceToken;



+ (void)load {
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
