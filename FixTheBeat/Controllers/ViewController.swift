//
//  ViewController.swift
//  FixTheBeat
//
//  Created by Kevin Randrup on 3/12/16.
//  Copyright © 2016 Kevin Randrup. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var currentBPMLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songBPMLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var coverArt: UIImageView!

    var musicPlayer: AVPlayer? = nil
    var isPlaying: Bool = false;
    
    var songAsset: AVURLAsset? = nil {
        willSet(newValue) {
            recorder.stopRecording()
            
            guard let newValue = newValue else { return }
            let player = AVPlayer(URL: newValue.URL)
            player.play()
            isPlaying = true
            self.musicPlayer = player
        }
        didSet {
            runSongBPMCalculations()
        }
    }
    
    var songBPM: Float? = nil
    let recorder = Recorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder.delegate = self
    }
    
    private func runSongBPMCalculations() {
        guard let song = songAsset else { return }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { () -> Void in
            //Copy file to Documents directory where we can access the data.
            let fileName = "temp_file_copy"
            let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString // (pathComponent)
            let newURL = NSURL(fileURLWithPath: documentsDir.stringByAppendingPathComponent(fileName))
            
            let exporter = AVAssetExportSession(asset: song, presetName: AVAssetExportPresetAppleM4A)!
            exporter.outputFileType = "com.apple.m4a-audio"
            exporter.outputURL = newURL
            
            exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                self.songBPM = BPMDetector().getBPM(newURL)
                self.songBPMLabel.text = "BPM: \(self.songBPM!)"
                
                // Start recording once we have our songBPM
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.recorder.startRecording()
                })
            })
        }
    }
    
    @IBAction func playPause() {
        if (isPlaying) {
            musicPlayer?.pause()
            isPlaying = false
            playPauseButton.setTitle("Play", forState: .Normal)
        } else {
            musicPlayer?.play()
            isPlaying = true
            playPauseButton.setTitle("Pause", forState: .Normal)
        }
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
                songAsset = asset
                songNameLabel.text = song.title
                artistLabel.text = song.artist
                coverArt.image = song.artwork?.imageWithSize(coverArt.frame.size)
        }
    }
}

extension ViewController : RecorderDelegate {
    func recorder(recorder: Recorder, didUpdateBPM bpm: Float) {
        guard let songBPM = songBPM else { return }
        adjustBeat(originalBeat: songBPM, newBeat: bpm)
    }
    
    private func adjustBeat(originalBeat originalBeat: Float, newBeat: Float) {
        print("New beat: \(newBeat)")
        if newBeat == 0 {
            return
        }
        musicPlayer?.rate = (newBeat / originalBeat)
        currentBPMLabel.text = "BPM: \(newBeat)"
    }
}

