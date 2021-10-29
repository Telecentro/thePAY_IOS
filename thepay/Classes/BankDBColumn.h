//
//  BankDBColumn.h
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BankDBColumn : NSObject


+(NSString *)TABLE_NAME;// = "TN_BANK";
+(NSString *)ID;            //"_id";
+(NSString *)BANK_CODE; 	//	= "CL_BANK_CODE";		//-bank_code
+(NSString *)IMAGE_NAME; //		= "CL_IMAGE_NAM";		//-이미지명
+(NSString *)NAME_KR; 	//		= "CL_NAME_KR";			//-name_kr
+(NSString *)NAME_EN; 	//		= "CL_NAME_EN";			//-name_en
+(NSString *)SORT_NO;  //		= "CL_SORT_NO";			//-sort no
@end
