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
    
    @IBOutlet weak var currentBPMLabel: UILabel!
    
    var musicPlayer: AVPlayer? = nil
    
    var songAsset: AVURLAsset? = nil {
        willSet(newValue) {
            guard let newValue = newValue else { return }
            let player = AVPlayer(URL: newValue.URL)
            player.play()
            self.musicPlayer = player
        }
        didSet {
            runBPMCalculations()
        }
    }
    
    var songBPM: Float? = nil
    
    var tempRecordingURL: NSURL? = nil {
        didSet {
            print(tempRecordingURL)
        }
    }
    var recorder: AVAudioRecorder? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpRecorder()
    }
    
    func setUpRecorder() {
        tempRecordingURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("tempSong")
        let recordSettings: [String:AnyObject] = [AVEncoderAudioQualityKey: NSNumber(long: AVAudioQuality.Min.rawValue),
            AVEncoderBitRateKey: NSNumber(long: 16),
            AVNumberOfChannelsKey: NSNumber(long: 2),
            AVSampleRateKey: NSNumber(floatLiteral: 44100.0)]
        
        do {
            try recorder = AVAudioRecorder(URL: tempRecordingURL!, settings: recordSettings)
            recorder?.prepareToRecord()
            record10Sec()
        } catch {
            
        }

    }
    
    private func runBPMCalculations() {
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
                print(self.songBPM)
            })
        }
    }

    func record10Sec() {
        recorder?.record()
        let triggerTime = (Int64(NSEC_PER_SEC) * 10)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.stopRecording()
        })
    }
    
    func stopRecording() {
        recorder?.stop()
        getBPMForRecording()
//        record10Sec() // uncomment when you feel confident it works!
    }
    
    func getBPMForRecording() {
        let currentRecordingBPM = BPMDetector().getBPM(tempRecordingURL)
        adjustBeat(originalBeat: self.songBPM!, newBeat: currentRecordingBPM)
        self.currentBPMLabel.text = String(currentRecordingBPM)
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

