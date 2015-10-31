//
//  RequestDefine.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#ifndef RequestDefine_h
#define RequestDefine_h

//=====================================================================
// google
//=====================================================================
#define GOOGLE_API_KEY @"AIzaSyACAcdpaZApsptCFVmjMyuq6MtfIBJgCnA"

//=====================================================================
// parmeter contsntats
//=====================================================================
#define LANGUAGE_CODE_KOREA @"Ko-kr"
#define LANGUAGE_CODE_ENGLISH @"en-US"
#define DEFAULT_MAXRESULTS @"20"

//=====================================================================
// youtube
//=====================================================================

#define YOUTUBE_GUIDED_CHANNEL_LIST @"https://www.googleapis.com/youtube/v3/guideCategories?part=snippet&hl=%@&regionCode=%@&key=%@"

#define YOUTUBE_PLAY_LIST @"https://www.googleapis.com/youtube/v3/playlists?part=snippet&hl=%@&channelId=%@&maxResults=%@&key=%@"
#define YOUTUBE_PLAY_MORE_LIST @"https://www.googleapis.com/youtube/v3/playlists?part=snippet&hl=%@&channelId=%@&maxResults=%@&pageToken=%@&key=%@"

#endif /* RequestDefine_h */
