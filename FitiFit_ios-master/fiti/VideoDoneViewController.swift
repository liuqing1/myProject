//
//  VideoDoneViewController.swift
//  fiti
//
//  Created by Juan Manuel Fluxa on 2/1/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit
import SCRecorder

class VideoDoneViewController: BaseViewController {
    
    @IBOutlet var previewView : UIView!
    @IBOutlet var playBt : UIButton!
    @IBOutlet var lbl1 : UILabel!
    @IBOutlet var lbl2 : UILabel!
    @IBOutlet var nextBt : UIButton!
    
    var videoPath : String?
    let player = SCPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = Theme.White
        setLocalizedTitle("video")

        lbl1.text = "video_done".localized
        lbl2.attributedText = NSAttributedString(string: "video_autosaved".localized, attributes: Constants.Attributes.getFitiSpacedStyleLight())
        nextBt.setTitle("next".localized.uppercaseString, forState: .Normal)
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
    }
    
    @IBAction func onPlayVideoButton(sender:UIButton) {
        player.seekToTime(CMTimeMake(0, player.currentItem!.asset.duration.timescale))
        player.play()
        playBt.hidden = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VideoDoneViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, itemReadyToPlay item: AVPlayerItem) {
        playBt.enabled = true
    }
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        playBt.hidden = false
    }
    
    
}
