//
//  RecordVideoViewController.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 1/24/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import SCRecorder

class RecordVideoViewController: BaseViewController {
    
    @IBOutlet var previewView : UIView!
    @IBOutlet var videoTimeLabel : UILabel!
    
    let recorder = SCRecorder.sharedRecorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavBar()
        
        previewView.backgroundColor = UIColor.blackColor()
        
        recorder.previewView = previewView
        recorder.delegate = self
        recorder.device = AVCaptureDevicePosition.Front
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh
        recorder.videoOrientation = AVCaptureVideoOrientation.Portrait
        recorder.videoConfiguration.sizeAsSquare = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        recorder.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func prepareSession() {
        if recorder.session == nil {
            let session = SCRecordSession()
            session.fileType = AVFileTypeQuickTimeMovie
            recorder.session = session
        }
    }
    
    @IBAction func onRecordButton(sender:UIButton) {
        if recorder.isRecording {
            recorder.pause()
        } else {
            recorder.record()
        }
    }
    
    @IBAction func onLoopButton(sender:UIButton) {
        if recorder.device == AVCaptureDevicePosition.Front {
            recorder.device = AVCaptureDevicePosition.Back
        } else {
            recorder.device = AVCaptureDevicePosition.Front
        }
        
    }
    
    @IBAction func onCancelButton(sender:UIButton) {
        if recorder.isRecording {
            recorder.pause()
            recorder.stopRunning()
        }
        
        if let session = recorder.session {
            session.cancelSession({ [unowned self] () -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            })
        } else {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
    
    func updateRecordingSeconds(totalSeconds : Float64) {
        let secs = Int(totalSeconds % 60)
        let mins = Int(totalSeconds / 60)
        videoTimeLabel.text = "\(String(format:"%02d",mins)):\(String(format:"%02d",secs))"
        
    }
}

extension RecordVideoViewController : SCRecorderDelegate {
    func recorder(recorder: SCRecorder, didBeginSegmentInSession session: SCRecordSession, error: NSError?) {
        print("did begin in segement")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession session: SCRecordSession) {
        print("did complete session")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        print("did complete segment")
        FitiLoadingHUD.showHUDForView(self.view, text: "")
        session.mergeSegmentsUsingPreset(AVAssetExportPresetMediumQuality) { (url : NSURL?, error : NSError?) -> Void in
            if let url = url {
                url.saveToCameraRollWithCompletion({ (path : String?, error : NSError?) -> Void in
                    if let path = path {
                        let url = NSURL(fileURLWithPath: path)
                        print("video saved at path: \(url.absoluteString)")
                        session.cancelSession({ [unowned self] () -> Void in
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.OnVideoPathPicked, object: nil, userInfo: ["videoPath":url.absoluteString])
                            })
                        })
                        
                    } else {
                        print("error saving video: \(error)")
                        FitiLoadingHUD.hide()
                    }
                    
                })
            } else {
                FitiLoadingHUD.hide()
                print("error merging video sessions: \(error)")
            }
        }
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        updateRecordingSeconds(CMTimeGetSeconds(session.duration))
    }
}
