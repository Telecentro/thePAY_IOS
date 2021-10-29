//
//  NationDBColumn.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "NationDBColumn.h"

@implementation NationDBColumn

+(NSString *) TABLE_NAME { return @"TN_COUNTRY";}

+(NSString *) ID 				{ return @"_id";}
+(NSString *) COUNTRY_CODE 	{ return @"CL_COUNTRY_CODE";}	//-country_alpha2_code
+(NSString *) NAME_KR 			{ return @"CL_NAME_KR";}			//-name_kr
+(NSString *) NAME_US 			{ return @"CL_NAME_US";}			//-name_us
+(NSString *) NAME_CN  		{ return @"CL_NAME_CN";}			//-name_cn
+(NSString *) COUNTRY_NUMBER 	{ return @"CL_COUNTRY_NUMBER";}	//-country_number
+(NSString *) GMT 				{ return @"CL_GMT";}				//-gmt

+(NSInteger) COL_IDX_ID 				{ return  0;}
+(NSInteger) COL_IDX_COUNTRY_CODE	{ return  1;}
+(NSInteger) COL_IDX_NAME_KR 		{ return  2;}
+(NSInteger) COL_IDX_NAME_US 		{ return  3;}
+(NSInteger) COL_IDX_NAME_CN 		{ return  4;}
+(NSInteger) COL_IDX_COUNTRY_NUMBER 	{ return  5;}
+(NSInteger) COL_IDX_GMT 			{ return  6;}

@end
