//
//  ViewController.swift
//  BeTheBeat
//
//  Created by Kevin Randrup on 3/12/16.
//  Copyright © 2016 Kevin Randrup. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    var musicPlayer: AVPlayer? = nil
    
    var songAsset: AVURLAsset? = nil {
        willSet(newValue) {
            guard let newValue = newValue else { return }
            let player = AVPlayer(URL: newValue.URL)
            player.play()
            player.rate = 2.0
            self.musicPlayer = player
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    private func adjustBeat(originalBeat originalBeat: Float, newBeat: Float) {
        musicPlayer?.rate = (originalBeat / newBeat)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if songAsset == nil {
            pickSong()
        }
    }
}

extension ViewController : MPMediaPickerControllerDelegate {
    private func pickSong() {
        let picker = MPMediaPickerController(mediaTypes: .Music)
        picker.delegate = self
        picker.showsCloudItems = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if let song = mediaItemCollection.representativeItem,
            let url = song.assetURL {
                self.dismissViewControllerAnimated(true, completion: nil)
                
                let asset = AVURLAsset(URL: url)
                self.songAsset = asset
        }
    }
}

