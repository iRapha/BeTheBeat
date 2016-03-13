//
//  Recorder.swift
//  BeTheBeat
//
//  Created by Kevin Randrup on 3/12/16.
//  Copyright © 2016 Kevin Randrup. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecorderDelegate : class {
    func recorder(recorder: Recorder, didUpdateBPM bpm: Float)
}

class Recorder : NSObject {
    
    weak var delegate: RecorderDelegate?
    private var timer: NSTimer?
    
    func startRecording() {
        setUpRecorder()
        startTimer()
    }
    
    func stopRecording() {
        recorder = nil
        timer?.invalidate()
    }
    
    private func startTimer() {
        let duration = 2.0
        recorder.prepareToRecord()
//        recorder.record()
        recorder.recordForDuration(duration)
//        timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "timerEnded", userInfo: nil, repeats: false)
    }

    private var tempRecordingURL: NSURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("tempSong")
    private var recorder: AVAudioRecorder! = nil
}

extension Recorder : AVAudioRecorderDelegate {
    private func setUpRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        let recordSettings: [String:AnyObject] = [AVEncoderAudioQualityKey: NSNumber(long: AVAudioQuality.Min.rawValue),
            AVEncoderBitRateKey: NSNumber(long: 16),
            AVNumberOfChannelsKey: NSNumber(long: 2),
            AVSampleRateKey: NSNumber(floatLiteral: 44100.0)]
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)

            recorder = try AVAudioRecorder(URL: tempRecordingURL, settings: recordSettings)
            recorder.delegate = self
        } catch {
            print("Failed to create recorder: \(error)")
        }
    }
    
    dynamic func timerEnded() {
        if (recorder.recording) {
            recorder.stop()
        }
    }
    
    dynamic func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        let newBPM = BPMDetector().getBPM(tempRecordingURL)
        delegate?.recorder(self, didUpdateBPM: newBPM)
        startTimer()
    }
    
    dynamic func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print(error)
    }
}
