//
//  CallHistoryDBColumn.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "CallHistoryDBColumn.h"

@implementation CallHistoryDBColumn

+(NSString *)TABLE_NAME         {   return @"TN_CALLHISTORY";}
+(NSString *)ID 				{ return @"_id";}
+(NSString *)COUNTRY_CODE 	{ return @"CH_CODE";}		//-country_alpha2_code
+(NSString *)COUNTRY_NUMBER 	{ return @"CH_NUMBER";}		//-country_number
+(NSString *)INTER_NUMBER 	{ return @"CH_INTER_NUMBER";}		//-국제전화번호
+(NSString *)CALL_NUMBER 		{ return @"CH_CALL_NUMBER";}	//-발신 번호
+(NSString *)NAME 			{ return @"CH_NAME";}		//-이름
+(NSString *)DATE 			{ return @"CH_DATE";}		//-발신 날자


+(NSInteger) COL_IDX_ID 				{ return  0;}
+(NSInteger) COL_IDX_COUNTRY_CODE	{ return  1;}
+(NSInteger) COL_IDX_COUNTRY_NUMBER 	{ return  2;}
+(NSInteger) COL_IDX_INTER_NUMBER 	{ return  3;}
+(NSInteger) COL_IDX_CALL_NUMBER 	{ return  4;}
+(NSInteger) COL_IDX_NAME 			{ return  5;}
+(NSInteger) COL_IDX_DATE 			{ return  6;}


@end
