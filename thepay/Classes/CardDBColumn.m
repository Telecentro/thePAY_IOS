//
//  CardDBColumn.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "CardDBColumn.h"

@implementation CardDBColumn
+(NSString *) TABLE_NAME { return @"TN_CARD";}

+(NSString *) ID 				{ return @"_id";}
+(NSString *) CREDIT_CODE 		{ return @"CL_CREDIT_CODE";}		//-card_code
+(NSString *) IMAGE_NAME 		{ return @"CL_IMAGE_NAM";}		//-이미지명
+(NSString *) NAME_KR 			{ return @"CL_NAME_KR";}			//-name_kr
+(NSString *) NAME_EN 			{ return @"CL_NAME_EN";}			//-name_en
+(NSString *) SORT_NO  		{ return @"CL_SORT_NO";}			//-sort no
@end
