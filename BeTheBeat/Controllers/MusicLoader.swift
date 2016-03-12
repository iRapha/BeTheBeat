//
//  MusicLoader.swift
//  BeTheBeat
//
//  Created by Kevin Randrup on 3/12/16.
//  Copyright © 2016 Kevin Randrup. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

/// Makes sure that the app has access to music library.
class MusicLoader {
    
    init() {
        let musicOnlyFIlter = MPMediaPropertyPredicate(value: NSNumber(unsignedInteger: MPMediaType.Music.rawValue), forProperty: MPMediaItemPropertyMediaType)
        let query = MPMediaQuery(filterPredicates: [musicOnlyFIlter])
        let allSongs = (query.items ?? []).map({ AVURLAsset(URL: $0.assetURL!) })
        
        for song in allSongs {
            print(song)
        }
    }
}