//
//  TimeUtils.m
//  thePAY
//
//  Created by Telecentro on 2015. 11. 30..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "TimeUtils.h"
#import "StringUtils.h"
@implementation TimeUtils


+(NSString *)getCurrentDate{
    
    NSDateFormatter *today = [[NSDateFormatter alloc] init];
    [today setDateFormat:@"yyyyMMddHHmmss"];
    
    
    NSDate *currentDate = [NSDate date];
//    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [calendar components:
                                    NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitMinute|
                                    NSCalendarUnitSecond
                                               fromDate:currentDate]; // Get necessary date components
    
    NSString *stryyyy;
    NSString *strMM;
    NSString *strdd;
    NSString *strHH;
    NSString *strmm;
    NSString *strss;
    
    
    NSInteger yyyy =[components year];
    stryyyy = [StringUtils int2str:yyyy];
    NSInteger MM = [components month];
    if (MM<10) {
        strMM = [NSString stringWithFormat:@"0%ld",MM];
    }
    else{
        strMM = [StringUtils int2str:MM];
    }
    NSInteger dd =[components day];
    if (dd<10) {
        strdd = [NSString stringWithFormat:@"0%ld",dd];
    }
    else{
        strdd = [StringUtils int2str:dd];
    }
    NSInteger HH = [components hour];
    if (HH<10) {
        strHH = [NSString stringWithFormat:@"0%ld",HH];
    }
    else{
        strHH = [StringUtils int2str:HH];
    }
    NSInteger mm = [components minute];
    if (mm<10) {
        strmm = [NSString stringWithFormat:@"0%ld",mm];
    }
    else{
        strmm = [StringUtils int2str:mm];
    }
    NSInteger ss = [components second];
    if (ss<10) {
        strss = [NSString stringWithFormat:@"0%ld",ss];
    }
    else{
        strss = [StringUtils int2str:ss];
    }
    
    NSString *date = [NSString stringWithFormat:@"%@%@%@%@%@%@",stryyyy,strMM,strdd,strHH,strmm,strss];
    
    return date;
//    return dateString;
}
+(NSString *)getDate:(NSInteger)type{

    NSDateFormatter *today = [[NSDateFormatter alloc] init];
    switch (type) {
        case 0:
                [today setDateFormat:@"yyyy-MM-dd"];
            break;
        case 1:
                [today setDateFormat:@"yyyy년 MM월 dd일"];
            break;
        case 2:
                [today setDateFormat:@"yyyy.MM.dd a hh:mm"];
            break;
        case 3:
                [today setDateFormat:@"yyyy년 MM월 dd일 a hh:mm"];
            break;
        case 4:
                [today setDateFormat:@"yyyyMMdd"];
            break;
        case 5:
                [today setDateFormat:@"MM/dd HH:mm"];
            break;
        case 6:
                [today setDateFormat:@"yy-MM-dd HH:mm:ss"];
            break;
        case 7:
                [today setDateFormat:@"yyMMddHHmmss"];
            break;
        case 8:
            [today setDateFormat:@"yyMMddHHmmssSSS"];
            break;
        case 10:                //월만
            [today setDateFormat:@"MM"];
            break;
        default:
                [today setDateFormat:@"yyyyMMddHHmmSS"];
            break;
    }

    NSString *date = [today stringFromDate:[NSDate date]];
    return date;
}
+(NSString *)getGMTDate:(NSString *)gmtInfo{
    if (gmtInfo == nil || [gmtInfo length]<1) {
        return @"";
    }
    if ([gmtInfo hasPrefix:@"Etc/GMT"]) {
        NSString *offset = [gmtInfo stringByReplacingOccurrencesOfString:@"Etc/GMT" withString:@""];
        NSInteger retVal = 0;

        retVal = [StringUtils str2int:offset];

        return [self getGMTDateInt:retVal];
        
    }
    else if([gmtInfo hasPrefix:@"ets/GMT"]){
        NSString *offset = [gmtInfo stringByReplacingOccurrencesOfString:@"ets/GMT" withString:@""];
        NSInteger retVal = 0;
        
        retVal = [StringUtils str2int:offset];
        
        return [self getGMTDateInt:retVal];
    }
    else if([gmtInfo isEqualToString:@"IST"])
    {
        return [self getISTDate];
    }
    return @"";
}
+(NSString *)getISTDate{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"MM/dd HH:mm"];
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"Asia/Kolkata"];
    [dateFormatter setTimeZone:gmtZone];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    return time;
    
}
+(NSString *)getGMTDateInt:(NSInteger)offsetHour{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"yy-MM/dd HH:mm:ss";
        dateFormatter.dateFormat = @"MM/dd HH:mm";
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmtZone];
    NSDate *curDate = [NSDate date];
    NSDate *plusDate = [curDate dateByAddingTimeInterval:(offsetHour*3600)];
    NSString *timeStamp = [dateFormatter stringFromDate:plusDate];
    
    return timeStamp;
}
@end
