//
//  UncaughtExceptionHandler.h
//  SignDemo
//
//  Created by wyy on 2017/4/12.
//  Copyright © 2017年 hubei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XRTUncaughtExceptionHandler : NSObject
{
    BOOL dismissed;//是否继续程序
}

//为两种类型的信号注册处理函数
+(void)InstallUncaughtExceptionHandler;

@end

//处理未捕获的异常
void HandleUncaughtException(NSException *exception);
//处理信号类型的异常
void HandleSignal(int signal);
