//
//  ExceptionCatch.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "ExceptionCatch.h"
#import <signal.h>
#import <execinfo.h>

@implementation ExceptionCatch

+ (void)initCatcher
{
    struct sigaction newSignalAction;
    memset(&newSignalAction, 0,sizeof(newSignalAction));
    newSignalAction.sa_handler = &signalHandler;
    sigaction(SIGABRT, &newSignalAction, NULL);     // abort 函数生成的信号，例如 array 插入 为空的数据或者越界
    sigaction(SIGILL,  &newSignalAction, NULL);     // 执行了非法指令. 通常是因为可执行文件本身出现错误, 或者试图执行数据段. 堆栈溢出时也有可能产生这个信号
    sigaction(SIGSEGV, &newSignalAction, NULL);     // 对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)
    sigaction(SIGFPE,  &newSignalAction, NULL);     // 发生致命的算术运算错误
    sigaction(SIGBUS,  &newSignalAction, NULL);     // 非法地址, 包括内存地址对齐(alignment)出错
    sigaction(SIGPIPE, &newSignalAction, NULL);     // 管道破裂，通常在进程间通信产生，例如：用Socket通信的两个进程，写进程在写Socket的时候，读进程已经终止。
    
    //异常时调用的函数
    NSSetUncaughtExceptionHandler(&handleExceptions);
}


void handleExceptions(NSException *exception)
{
    NSArray *stackArray       = [exception callStackSymbols];
    NSString *exceptionReason = [exception reason];
    NSString *exceptionName   = [exception name];
    NSString *exceptionInfo   = [NSString stringWithFormat:@"Exception-reason：%@\nException-name：%@\nException-stack：%@", exceptionName,  exceptionReason, stackArray];
    
    GosLog(@"%@",exceptionInfo);
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    NSString *documentPath = [pathArray objectAtIndex:0];
    NSString *writeFlePath = [documentPath stringByAppendingPathComponent:@"ExceptionInfoLog.txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:writeFlePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"【yyyy/MM/dd HH:mm:ss】"];
    NSString *timeStr   = [formatter stringFromDate:currentDate];
    NSString *startFlag = [NSString stringWithFormat:@"========================= %@ start =========================", timeStr];
    NSString *endFlag   = [NSString stringWithFormat:@"========================= %@ end =========================", timeStr];
    NSString *crashLog  = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n\n\n\n\n\n%@", startFlag, exceptionInfo, endFlag, fileContents ? fileContents : @""];
    
    [crashLog writeToFile:writeFlePath
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:nil];
    
}


void signalHandler(int sig)
{
    //最好不要写，可能会打印太多内容
    GosLog(@"signal = %d", sig);
}

@end
