//
//  MusicLoader.swift
//  FixTheBeat
//
//  Created by Kevin Randrup on 3/12/16.
//  Copyright © 2016 Kevin Randrup. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

/// Makes sure that the app has access to music library.
class MusicLoader {
    init(song : MPMediaItem) {
        // Start playing song.
        let player = AVPlayer(URL: song.assetURL!)
        player.play()
        
        // Does the metadata include the BPMs?
        print(song.beatsPerMinute)
    }
}
