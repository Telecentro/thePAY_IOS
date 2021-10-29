//
//  NationItem.m
//  thePAY
//
//  Created by Telecentro on 2015. 11. 27..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "NationItem.h"

@implementation NationItem
@synthesize serialVersionUID,dbID;
-(id)init{
    self = [super init];
    if (self) {
        dbID = -1;
        serialVersionUID = 7194329678715891308.0;
    }
    return self;
}

-(NSString *)getImgNm{

        
        NSString *retStr = nil;
        if(_countryCode){
            retStr = [NSString stringWithFormat:@"flag_%@", _countryCode];
        }
        else{
            retStr = @"flag_0";
        }
        return retStr;
}
@end
