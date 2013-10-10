//
//  MKUserLocation+TexaGPS.h
//  TexaGPSTEST
//
//  Created by ISSHO on 12/11/07.
//  Copyright (c) 2012年 ISSHO. All rights reserved.
//

#ifndef TexaGPSTEST_MKUserLocation_TexaGPS_h
#define TexaGPSTEST_MKUserLocation_TexaGPS_h

#ifdef DEBUG
    #define TexaLOG(...) NSLog(__VA_ARGS__)
    #define LOG_METHOD NSLog(@"%s", __func__)
#else
    #define TexaLOG(...) ;
    #define LOG_METHOD ;
#endif

#endif
