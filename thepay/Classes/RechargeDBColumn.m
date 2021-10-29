//
//  RechargeDBColumn.m
//  thePay
//
//  Created by Dukhee Kang on 2018. 1. 6..
//  Copyright © 2018년 Telecentro. All rights reserved.
//

#import "RechargeDBColumn.h"

@implementation RechargeDBColumn

+(NSString *)TABLE_NAME         {   return @"TN_RECHARGEHISTORY";}
+(NSString *)ID                 { return @"_id";}
+(NSString *)COUNTRY_CODE     { return @"CH_CODE";}        //-country_alpha2_code
+(NSString *)COUNTRY_NUMBER     { return @"CH_NUMBER";}        //-country_number
+(NSString *)CALL_NUMBER         { return @"CH_CALL_NUMBER";}    //-발신 번호
+(NSString *)DATE             { return @"CH_DATE";}        //-발신 날자


+(NSInteger) COL_IDX_ID                 { return  0;}
+(NSInteger) COL_IDX_COUNTRY_CODE    { return  1;}
+(NSInteger) COL_IDX_COUNTRY_NUMBER     { return  2;}
+(NSInteger) COL_IDX_CALL_NUMBER     { return  3;}
+(NSInteger) COL_IDX_DATE             { return  4;}

@end
