//
//  VideoUploadViewController.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 2/1/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import SCRecorder
import RealmSwift

class VideoUploadViewController: BaseViewController {
    
    @IBOutlet var previewView : UIView!
    @IBOutlet var playBt : UIButton!
    
    var videoPath : String?
    let player = SCPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = Theme.Dark
        setLocalizedTitle("video")

        setNavBarRightButtonWithTitle("upload".localized, action: "onUploadButton")
        
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        playBt.enabled = false
        if let videoPath = videoPath {
            player.delegate = self
            player.setItemByStringPath(videoPath)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = previewView.bounds
            previewView.layer.addSublayer(playerLayer)
            
        }
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.tintColor = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlayVideoButton(sender:UIButton) {
        player.seekToTime(CMTimeMake(0, player.currentItem!.asset.duration.timescale))
        player.play()
        playBt.hidden = true
    }
    
    

    func onUploadButton() {
        if let videoPath = videoPath {
            FitiLoadingHUD.showHUDForView(self.view, text: "uploading_video".localized)
            APIManager.shared.uploadVideo(videoPath, success: { [unowned self] (videoURL) -> Void in
                if let trainer = APIManager.shared.meTrainer {
                    let realm = try! Realm()
                    try! realm.write {
                        trainer.videoURL = videoURL
                    }
                    self.performSegueWithIdentifier("NextToVideoDone", sender: nil)
                }
                FitiLoadingHUD.hide()
                
                }) { (error) -> Void in
                    print(error)
                    FitiLoadingHUD.hide()
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NextToVideoDone" {
            if let vc = segue.destinationViewController as? VideoDoneViewController {
                if let videoPath = videoPath {
                    vc.videoPath = videoPath
                }
            }
        }
    }
}

extension VideoUploadViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, itemReadyToPlay item: AVPlayerItem) {
        playBt.enabled = true
    }
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        playBt.hidden = false
    }
    
    
}
