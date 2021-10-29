//
//  AutoCompleteDBColumn.m
//  thepay
//
//  Created by seojin on 2020/11/20.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

#import "AutoCompleteDBColumn.h"

@implementation AutoCompleteDBColumn

+(NSString *)TABLE_NAME       {   return @"TN_AUTOCOMPLETE";}
+(NSString *)ID               { return @"_id";}
+(NSString *)COUNTRY_CODE     { return @"CH_CODE";}         //-country_alpha2_code
+(NSString *)COUNTRY_NUMBER   { return @"CH_NUMBER";}       //-country_number
+(NSString *)NAME             { return @"CH_NAME";}         //-이름
+(NSString *)TYPE             { return @"CH_TYPE";}         //-타입 (id, email, num)
+(NSString *)TEXT             { return @"CH_TEXT";}         //-데이터 (id - 텍스트, email - 텍스트, num - 숫자)
+(NSString *)DATE             { return @"CH_DATE";}         //-발신 날자
+(NSString *)CATE             { return @"CH_CATE";}         //-발신 날자
+(NSString *)INTER_NUMBER     { return @"CH_INTER_NUMBER";} //-발신 날자
+(NSString *)SAVE_TYPE        { return @"CH_SAVE_TYPE";} //-발신 날자

+(NSInteger) COL_IDX_ID               { return  0;}
+(NSInteger) COL_IDX_COUNTRY_CODE     { return  1;}
+(NSInteger) COL_IDX_COUNTRY_NUMBER   { return  2;}
+(NSInteger) COL_IDX_NAME             { return  3;}
+(NSInteger) COL_IDX_TYPE             { return  4;}
+(NSInteger) COL_IDX_TEXT             { return  5;}
+(NSInteger) COL_IDX_DATE             { return  6;}
+(NSInteger) COL_IDX_CATE             { return  7;}
+(NSInteger) COL_IDX_INTER_NUMBER     { return  8;}
+(NSInteger) COL_IDX_SAVE_TYPE        { return  9;}

@end
