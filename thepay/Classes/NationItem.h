//
//  NationItem.h
//  thePAY
//
//  Created by Telecentro on 2015. 11. 27..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NationItem : NSObject

//private static final long serialVersionUID = 7194329678715891308L;

//private int dbId = -1;
@property long serialVersionUID;
@property NSInteger dbID;
@property (nonatomic, strong)NSString *countryCode;
@property (nonatomic, strong)NSString *nameKr ;
@property (nonatomic, strong)NSString *nameUs ;
@property (nonatomic, strong)NSString *nameCn ;
@property (nonatomic, strong)NSString *countryNumber ;
@property (nonatomic, strong)NSString *gmt ;
-(NSString *)getImgNm;
@end
