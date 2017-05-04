//
//  UncaughtExceptionHandler.m
//  SignDemo
//
//  Created by wyy on 2017/4/12.
//  Copyright © 2017年 hubei. All rights reserved.
//

#import "XRTUncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "XRTFileManager.h"
NSString * const UncaughtExceptionHandlerSignalExceptionName=@"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey=@"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey=@"UncaughtExceptionHandlerAddressesKey";

volatile int32_t exceptionCount = 0;
const int32_t exceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerReportAddressCount = 10;//指明报告多少条调用堆栈信息
@interface XRTUncaughtExceptionHandler ()<UIAlertViewDelegate>
//获取堆栈指针，返回符号化之后的数组
+ (NSArray *)backtrace;

//处理异常2，包括抛出的异常和信号异常
- (void)handleException:(NSException *)exception;
@end

@implementation XRTUncaughtExceptionHandler
+ (NSArray *)backtrace{
    void *callStack[128];//堆栈方法数组
    int frames=backtrace(callStack, 128);//从iOS的方法backtrace中获取错误堆栈方法指针数组，返回数目
    char **strs=backtrace_symbols(callStack, frames);//符号化
    
    int i;
    NSMutableArray *symbolsBackTrace=[NSMutableArray arrayWithCapacity:frames];
    for (i=0; i<UncaughtExceptionHandlerReportAddressCount; i++) {
        [symbolsBackTrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return symbolsBackTrace;
}

- (void)handleException:(NSException *)exception{
    ///////////////
    CFRunLoopRef runLoop=CFRunLoopGetCurrent();
    CFArrayRef allModes=CFRunLoopCopyAllModes(runLoop);
    NSArray *arr=(__bridge NSArray *)allModes;
    while (!dismissed) {
        @try {
            for (NSString *mode in arr) {
                CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        
    }
//    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_IGN);
    signal(SIGILL, SIG_IGN);
    signal(SIGSEGV, SIG_IGN);
    signal(SIGFPE, SIG_IGN);
    signal(SIGBUS, SIG_IGN);
    signal(SIGPIPE, SIG_IGN);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        //[exception raise];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        dismissed=YES;
    }else{
        dismissed=false;
    }
}



+(void)InstallUncaughtExceptionHandler{
    NSSetUncaughtExceptionHandler(HandleUncaughtException);//设置未捕获的异常处理
    
    //设置信号类型的异常处理
    signal(SIGABRT, HandleSignal);
    signal(SIGILL, HandleSignal);
    signal(SIGSEGV, HandleSignal);
    signal(SIGFPE, HandleSignal);
    signal(SIGBUS, HandleSignal);
    signal(SIGPIPE, HandleSignal);
}

- (void)writeToLocation:(NSException *)exception  {
    NSArray *jointArray = [self jointFromsourceArray:exception.callStackSymbols currentDate: [self currentTime]exceptionReason:exception.reason];
   BOOL isSuccess = [XRTFileManager writeFileAtPath:[XRTFileManager preferencesDir] content:jointArray];
   NSLog(@"isSuccess == %d",isSuccess);
}

- (NSArray *)jointFromsourceArray:(NSArray *)array currentDate:(NSString *)date exceptionReason:(NSString *)reason {
    NSMutableArray * jointArray = [NSMutableArray array];
    [jointArray addObject:date];
    [jointArray addObject:reason];
    [jointArray addObjectsFromArray:array];
    return [jointArray copy];
}

- (NSString *)currentTime {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@============年-月-日  时：分：秒=====================",DateTime);
    return [NSString stringWithFormat:@"程序奔溃时间：%@",DateTime];
}
@end



void HandleUncaughtException(NSException *exception){
//    int32_t exceptionCount=OSAtomicIncrement32(&exceptionCount);
//    if (exceptionCount>exceptionMaximum) {
//        return;
//    }
    
    
    
    
    NSArray *callStack=[XRTUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    XRTUncaughtExceptionHandler *uncaughtExceptionHandler=[[XRTUncaughtExceptionHandler alloc] init];
    [uncaughtExceptionHandler writeToLocation:exception];
    NSException *uncaughtException=[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    [uncaughtExceptionHandler performSelectorOnMainThread:@selector(handleException:) withObject:uncaughtException waitUntilDone:YES];
    
    
   
}

void HandleSignal(int signal){
    int32_t exceptionCount= OSAtomicIncrement32(&exceptionCount);
    if (exceptionCount>exceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callBack=[XRTUncaughtExceptionHandler backtrace];
    [userInfo setObject:callBack forKey:UncaughtExceptionHandlerAddressesKey];
    
    XRTUncaughtExceptionHandler *uncaughtExceptionHandler=[[XRTUncaughtExceptionHandler alloc] init];
    NSException *signalException=[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:[NSString stringWithFormat:@"Signal %d was raised.",signal] userInfo:userInfo];
    [uncaughtExceptionHandler performSelectorOnMainThread:@selector(handleException:) withObject:signalException waitUntilDone:YES];
}
