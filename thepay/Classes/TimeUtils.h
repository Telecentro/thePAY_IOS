//
//  TimeUtils.h
//  thePAY
//
//  Created by Telecentro on 2015. 11. 30..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtils : NSObject

+(NSString *)getCurrentDate;
+(NSString *)getGMTDate:(NSString *)gmtInfo;
+(NSString *)getDate:(NSInteger)type;

@end
