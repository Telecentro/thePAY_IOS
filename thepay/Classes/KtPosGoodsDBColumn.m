//
//  KtPosGoodsDBColumn.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "KtPosGoodsDBColumn.h"

@implementation KtPosGoodsDBColumn

+(NSString *)TABLE_NAME { return @"TN_KTPOS_GOODS";}
+(NSString *) ID 				{ return @"_id";}
+(NSString *) MVNO_ID 			{ return @"CL_MVNO_ID";}
+(NSString *) AMOUNT 			{ return @"CL_AMOUNT";}
+(NSString *) SORT_NO 			{ return @"CL_SORT_NO";}
+(NSString *) MVNO_NAME 		{ return @"CL_MVNO_NAME";}

@end
