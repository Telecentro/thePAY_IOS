//
//  VoiceGoodsDBColumn.m
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "VoiceGoodsDBColumn.h"

@implementation VoiceGoodsDBColumn

+(NSString *) TABLE_NAME { return @"TN_VOICE_GOODS";}

+(NSString *) ID 				{ return @"_id";}
+(NSString *) MVNO_ID 			{ return @"CL_MVNO_ID";}
+(NSString *) AMOUNT            { return @"CL_AMOUNT";}
+(NSString *) SORT_NO 			{ return @"CL_SORT_NO";}
+(NSString *) MVNO_NAME 		{ return @"CL_MVNO_NAME";}
+(NSString *) RCG_TYPE          { return @"RCG_TYPE"; }
+(NSString *) PPS_NAME          { return @"PPS_NAME"; }
+(NSString *) IMAGE_NAME          { return @"IMAGE_NAME"; }
+(NSString *) IMAGE_SEL_NAME          { return @"IMAGE_SEL_NAME"; }
+(NSString *) TITLE          { return @"TITLE"; }

@end


@implementation Voice2GoodsDBColumn

+(NSString *) TABLE_NAME { return @"TN_VOICE2_GOODS";}

+(NSString *) ID                 { return @"_id";}
+(NSString *) MVNO_ID             { return @"CL_MVNO_ID";}
+(NSString *) AMOUNT            { return @"CL_AMOUNT";}
+(NSString *) SORT_NO             { return @"CL_SORT_NO";}
+(NSString *) MVNO_NAME         { return @"CL_MVNO_NAME";}
+(NSString *) RCG_TYPE          { return @"RCG_TYPE"; }
+(NSString *) PPS_NAME          { return @"PPS_NAME"; }
+(NSString *) IMAGE_NAME          { return @"IMAGE_NAME"; }
+(NSString *) IMAGE_SEL_NAME          { return @"IMAGE_SEL_NAME"; }
+(NSString *) TITLE          { return @"TITLE"; }
@end
