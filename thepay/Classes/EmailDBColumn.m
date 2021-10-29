//
//  EmailDBColumn.m
//  thePay
//
//  Created by Dukhee Kang on 2018. 2. 6..
//  Copyright © 2018년 Telecentro. All rights reserved.
//

#import "EmailDBColumn.h"

@implementation EmailDBColumn

+(NSString *)TABLE_NAME         {   return @"TN_EMAILHISTORY";}
+(NSString *)ID                 { return @"_id";}
+(NSString *)EMAIL_STRING                 { return @"EMAIL_STRING";}

@end
