//
//  ProgrammingDefine.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/30/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#ifndef ProgrammingDefine_h
#define ProgrammingDefine_h

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

#endif /* ProgrammingDefine_h */
